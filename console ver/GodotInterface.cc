#include "GodotInterface.h"

void* GodotInterface::_recv_thread(void *arg)
{
	Client * server = static_cast<Client *>(arg);

	server->recv_thread();

	return 0;
}

void* GodotInterface::_send_thread(void *arg)
{
	Client * server = static_cast<Client *>(arg);

	server->send_thread();

	return 0;
}

void* GodotInterface::_server_thread(void *arg)
{
	Server * server = static_cast<Server *>(arg);

	server->do_messages();

	return 0;
}

int GodotInterface::orderToID(int order)
{
	return players[order].id;
}

int GodotInterface::IDToOrder(int id)
{
	int order = -1;

	for(int i = 0; i < players.size(); i++)
	{
		if (players[i].id == id)
		{
			order = i;
			break;
		}
	}

	return order;
}

bool GodotInterface::getMessage()
{
	Message m;
	
	if (!client.getMessage(m))
		return false;

	if (m.game_enum == Message::GameEnum::NAME)
	{
		Player p;
		p.id = m.id;
		p.n = m.strMsg;

		unordered_players.push_back(p);
	}
	else if (m.game_enum == Message::GameEnum::ORDER)
	{
		std::string name = m.strMsg;
		int order = m.id;
		for (Player p : unordered_players) {
			if (p.n == name)
			{
				players[order] = p;
				break;
			}
		}
	}
	else if (m.game_enum == Message::VERIFIED)
	{
		int id = m.intMsg;
		unordered_players[0].id = id;
	}

	storedMessage = m;

	return true;
}

GodotInterface::GodotInterface(const char * s, const char * p, const char * n, bool h = false)
{
	host = h;
	nick = n;

	Player p;
	p.n = nick;

	unordered_players.push_back(p);

	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);

	if (host)
	{
		server = Server(s, p);
		pthread_create(&id, &attr, _server_thread, static_cast<void *>(&server));
	}

	client = Client(s, p, n);

	//como el send va con una cola, podemos hacer login antes de iniciar los threads
	client.login();

	//inicio de threads
	pthread_create(&id, &attr, _recv_thread, static_cast<void *>(&client));
	pthread_create(&id, &attr, _send_thread, static_cast<void *>(&client));
}

GodotInterface::~GodotInterface()
{
	client.logout();

	if (host)
	{
		server.waitForLogout();

		sigemptyset(&waitset);
		sigaddset(&waitset, SIGQUIT);

		sigwait(&waitset, &sig);
	}
}


void GodotInterface::send(const Message::GameEnum& game_enum, const int& m)
{
	sendTo(0, game_enum, m);
}

void GodotInterface::send(const Message::GameEnum& game_enum, const float& m)
{
	sendTo(0, game_enum, m);
}

void GodotInterface::send(const Message::GameEnum& game_enum, const std::string& m)
{
	sendTo(0, game_enum, m);
}

void GodotInterface::sendTo(const uint& player, const Message::GameEnum& game_enum, const int& m)
{
	client.sendTo(orderToID(player), game_enum, m);
}

void GodotInterface::sendTo(const uint& player, const Message::GameEnum& game_enum, const float& m)
{
	client.sendTo(orderToID(player), game_enum, m);
}

void GodotInterface::sendTo(const uint& player, const Message::GameEnum& game_enum, const std::string& m)
{
	client.sendTo(orderToID(player), game_enum, m);
}

void GodotInterface::ready()
{
	client.ready();
}

void GodotInterface::order(int order)
{
	players[order] = unordered_players[0];

	sendTo(Message::ORDER, order);
}


int GodotInterface::getMessage_intMsg()
{
	return storedMessage.intMsg;
}
float GodotInterface::getMessage_floatMsg()
{
	return storedMessage.floatMsg;
}
std::string GodotInterface::getMessage_strMsg()
{
	return storedMessage.strMsg;
}
int GodotInterface::getMessage_id()
{
	return IDToOrder(storedMessage.id);
}
int GodotInterface::getMessage_game_enum()
{
	return storedMessage.game_enum;
}