#include "GodotInterface.hpp"

using namespace godot;

void GodotInterface::_register_methods()
{
	register_method("getMessage", &GodotInterface::getMessage);
	register_method("start", &GodotInterface::start);
	register_method("getMessage_Data", &GodotInterface::getMessage_Data);
	register_method("logout", &GodotInterface::logout);
	register_method("ready", &GodotInterface::ready);
	register_method("roll", &GodotInterface::roll);

	register_method("sendInt", &GodotInterface::sendInt);
	register_method("sendFloat", &GodotInterface::sendFloat);
	register_method("sendString", &GodotInterface::sendString);

	register_method("sendIntTo", &GodotInterface::sendIntTo);
	register_method("sendFloatTo", &GodotInterface::sendFloatTo);
	register_method("sendStringTo", &GodotInterface::sendStringTo);	
}

extern "C" void * _recv_thread(void *arg)
{
	Client * server = static_cast<Client *>(arg);

	server->recv_thread();

	return 0;
}

extern "C" void * _send_thread(void *arg)
{
	Client * server = static_cast<Client *>(arg);

	server->send_thread();

	return 0;
}

extern "C" void * _server_thread(void *arg)
{
	Server * server = static_cast<Server *>(arg);

	server->do_messages();

	return 0;
}

int GodotInterface::orderToID(int order)
{
	if(order > 0)
		return players[order - 1].id;
	else
		return 0;
}

int GodotInterface::IDToOrder(int id)
{
	int order = 0;

	if(started)
	{
		for(int i = 0; i < players.size(); i++)
		{
			if (players[i].id == id)
			{
				order = i + 1;
				break;
			}
		}
	}
	else
	{
		for(int i = 0; i < unordered_players.size(); i++)
		{
			if (unordered_players[i].id == id)
			{
				order = i + 1;
				break;
			}
		}
	}

	return order;
}

void GodotInterface::logout()
{
	if(host)
		server.shutdown();
	else
		client.logout();
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
	else if (m.type == Message::VERIFIED)
	{
		int id = m.intMsg;
		unordered_players[0].id = id;
	}
	else if (m.game_enum == Message::GAME_START)
	{
		started = true;
	}

	storedMessage = m;

	return true;
}

void GodotInterface::start(String s, String p, String n, bool h)
{
	host = h;

	Player pl;
	pl.n = n.ascii().get_data();

	unordered_players.push_back(pl);

	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);

	if (host)
	{
		server = Server(s.ascii().get_data(), p.ascii().get_data());
		pthread_create(&id_serv, &attr, _server_thread, static_cast<void *>(&server));
	}

	client = Client(s.ascii().get_data(), p.ascii().get_data(), n.ascii().get_data());

	//como el send va con una cola, podemos hacer login antes de iniciar los threads
	client.login();

	//inicio de threads
	pthread_create(&id_cli, &attr, _recv_thread, static_cast<void *>(&client));
	pthread_create(&id_cli, &attr, _send_thread, static_cast<void *>(&client));
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

void GodotInterface::sendInt(const int& game_enum, const int& m)
{
	sendIntTo(0, game_enum, m);
}

void GodotInterface::sendFloat(const int& game_enum, const float& m)
{
	sendFloatTo(0, game_enum, m);
}

void GodotInterface::sendString(const int& game_enum, const String& m)
{
	sendStringTo(0, game_enum, m.ascii().get_data());
}

void GodotInterface::sendIntTo(const uint& player, const int& game_enum, const int& m)
{
	client.sendTo(orderToID(player), static_cast<Message::GameEnum>(game_enum), m);
}

void GodotInterface::sendFloatTo(const uint& player, const int& game_enum, const float& m)
{
	client.sendTo(orderToID(player), static_cast<Message::GameEnum>(game_enum), m);
}

void GodotInterface::sendStringTo(const uint& player, const int& game_enum, const String& m)
{
	client.sendTo(orderToID(player), static_cast<Message::GameEnum>(game_enum), m.ascii().get_data());
}

void GodotInterface::ready()
{
	client.ready();
}

void GodotInterface::roll(int roll)
{
	players[roll] = unordered_players[0];

	client.send(Message::ROLL, roll);
}

Array GodotInterface::getMessage_Data()
{
	Array ret;
	ret.append(IDToOrder(storedMessage.id));
	ret.append(storedMessage.game_enum);
	ret.append(storedMessage.intMsg);
	ret.append(storedMessage.floatMsg);
	ret.append(storedMessage.strMsg.c_str());

	return ret;
}