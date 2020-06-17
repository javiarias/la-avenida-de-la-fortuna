#include "Message.h"

size_t Message::getSize(){
    if(type == STR || type == NAMES) return STR_MESSAGE_SIZE;
    else if(type == FLOAT) return FLOAT_MESSAGE_SIZE;
    else return INT_MESSAGE_SIZE;
}

void Message::to_bin()
{
    int MESSAGE_SIZE = getSize();

	//std::cout << MESSAGE_SIZE << " message size\n";
	//std::cout << type << " type\n";

    alloc_data(MESSAGE_SIZE);

    memset(_data, 0, MESSAGE_SIZE);
        
    char* it = _data;
    
    memcpy(it, &id, sizeof(uint32_t));
    it += sizeof(uint32_t);
    
    memcpy(it, &dest, sizeof(uint32_t));
    it += sizeof(uint32_t);

    memcpy(it, &type, sizeof(uint8_t));
    it += sizeof(uint8_t);

    memcpy(it, &game_enum, sizeof(uint8_t));
    it += sizeof(uint8_t);


    if(type == STR || type == NAMES)
    {		
		char str_c[MAX_STR];
        strcpy(str_c, strMsg.c_str());		
        memcpy(it, str_c, MAX_STR * sizeof(char));
        it += MAX_STR * sizeof(char);
    }
    else if(type == FLOAT)
    {
        memcpy(it, &floatMsg, sizeof(float));
        it += sizeof(float);
    }
    else
    {
        memcpy(it, &intMsg, sizeof(int));
        it += sizeof(int);
    }
} 

int Message::from_bin(char * bobj)
{
    int MESSAGE_SIZE = getSize();

    alloc_data(MESSAGE_SIZE);

    memcpy(static_cast<void *>(_data), bobj, MESSAGE_SIZE);


    char* it = _data;

    //el único caso de error de la función que se nos ocurre es que se
    //sobrepase el tamaño de data, de ahi que usemos un try/catch para lanzar
    //el return -1

    try
    {
        memcpy(&id, it, sizeof(uint32_t));
        it += sizeof(uint32_t);

        memcpy(&dest, it, sizeof(uint32_t));
        it += sizeof(uint32_t);

        memcpy(&type, it, sizeof(uint8_t));
        it += sizeof(uint8_t);

        memcpy(&game_enum, it, sizeof(uint8_t));
        it += sizeof(uint8_t);


        if(type == INT)
        {
            memcpy(&intMsg, it, sizeof(int));
            it += sizeof(int);
        }
        else if(type == FLOAT)
        {
            memcpy(&floatMsg, it, sizeof(float));
            it += sizeof(float);
        }
        else
        {
            char str_c[MAX_STR];
            memcpy(str_c, it, MAX_STR * sizeof(char));
            strMsg = std::string(str_c);
            it += MAX_STR * sizeof(char);
        }
    }
    catch(const std::exception& e)
    {
        id = 0;
        dest = 0;
        type = INT;
        game_enum = -1;
        intMsg = -1;
    }

    return 0;
}

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

void Server::do_messages()
{
    while (true)
    {
        Message msg;
        Socket* sock;
        socket.recv(msg, sock);

		Message m(msg);

		std::cout << getPlayerByID(m.id);
		std::cout << " sends: TYPE = " << m.type << " ENUM = " << m.game_enum << " CONTENT = " << m.intMsg << " " << m.floatMsg << " " << m.strMsg << '\n';

		socket.send(m, *sock);

		continue;
		
		if (!gameStarted)
		{
			switch (m.type)
			{
			case Message::LOGIN:
				std::cout << "login attempt from\n";

				clients.push_back(sock);
				handshake(sock, m);
				break;
			case Message::LOGOUT:
				std::cout << "logout!\n";
				
				logout(sock);
				break;
			case Message::HANDSHAKE:
				std::cout << "verification required!\n";

				verify(m, sock);
				break;
			case Message::NAMES:
				if(getPlayerByID(m.id) > 0)
				{
					std::cout << "name request received!\n";

					for (Player p : players)
					{
						if (p.id != m.id) {
							Message msg = Message(p.id, getPlayerByID(m.id), Message::GameEnum::NAME, p.n);
							send(msg);
						}
					}
				}
				break;
			case Message::READY:
				if(getPlayerByID(m.id) > 0)
				{
					std::cout << "player ready!\n";
					send(m);
					players[getPlayerByID(m.id)].ready = true;
					tryStart();
				}
				break;
			}
		}
		else
		{
			if (!ordered)
			{
				//si aún no se ha establecido el orden, se capturan solo los mensajes de tipo ROLL
				if (m.game_enum == Message::GameEnum::ROLL) {

					firstRoll[getPlayerByID(m.id)] = std::make_pair(m.intMsg, getPlayerByID(m.id));
					turn++;

					//una vez todos los jugadores han lanzado su dado, se establece el orden
					if (turn == (players.size() - 1)) {
						turn = 0;
						ordered = true;

						//ordenar según los resultados de los dados
						std::sort(firstRoll.begin(), firstRoll.end());

						//vector copia para ir ordenando los jugadores
						std::vector<Player> players_copy(players);

						//se avisa a todos los jugadores del orden, incluyendo el jugador al cual nos referimos en el id del mensaje
						for (int i = 0; i < firstRoll.size(); i++) {
							std::pair<int, int> p = firstRoll[i];
							Message msg = Message(players[p.second].id, 0, Message::GameEnum::ORDER, i);

							send(msg);

							players_copy[i] = players[p.second];
						}

						//se ordena el vector players
						players = players_copy;

						//se envía el primer mensaje de start a TODOS, con el número de jugador
						Message msg = Message(0, Message::GameEnum::TURN_START, turn);
					}
				}
			}
			else
			{
				if (m.game_enum == Message::GameEnum::TURN_END)
				{
					turn = (turn == (players.size() - 1)) ? 0 : turn++;
					Message msg = Message(0, Message::GameEnum::TURN_START, turn);
					send(msg);
				}
				//si no es un mensaje de que ha acabado el turno, se reenvía
				else
					send(m);
			}
		}

    }
}

int Server::decode(int msg)
{
	return ((msg + 48.5) - (37.5 * 2.0)) / 1.5;
}

int Server::encode(int msg)
{
	return ((msg * 2.5) - 375.0) * 5.0;
}

void Server::handshake(Socket* s, const Message& m)
{
	std::cout << "handshake protocol initiated\n";

	int id = 0;

	//generamos un ID único para cada jugador. Se suma 1 para dejar el 0 libre, que vale como "broadcast"
	do { id = rand() % 100000 + 1; } while (idExists(id));

	Player p;
	p.s = s;
	p.id = id;
	p.n = m.strMsg;

	unverified[s] = p;

	std::cout << "creating handshake message\n";

	int encoded = encode(id);
	
	Message msg = Message(0, 0, encoded);
	msg.type = Message::HANDSHAKE;
	ids_in_use.push_back(id);

	std::cout << "sending handshake message\n";
	std::cout << *s << '\n';

	//socket.send(msg, *s);

	std::cout << "handshake message sent\n";
	
}

void Server::verify(const Message& m, Socket* s)
{
	Message msg;

	auto it_m = unverified.find(s);

	if (it_m != unverified.end()) {
		float check = decode(m.floatMsg);

		if (check == unverified[s].id)
		{
			msg = Message(check, Message::GameEnum::LOGGED, (int)players.size());
			msg.type = Message::VERIFIED;

			if (players.size() >= 4)
			{
				msg.type = Message::FULL;
				msg.game_enum = Message::GameEnum::GAME_FULL;
			}
		}
		else {
			msg = Message(0, 0, 0);
			msg.type = Message::FAILED;

			//erase from id list and client list and unverified list
		}

		socket.send(msg, *s);

		if(idExists(unverified[s].id))
			ids_in_use.erase(std::find(ids_in_use.begin(), ids_in_use.end(), unverified[s].id));
		unverified.erase(s);

		if (msg.type == Message::VERIFIED)
		{
			Player p = unverified[s];

			unverified.erase(s);

			players.push_back(p);

			msg = Message(p.id, Message::GameEnum::NAME, p.n);

			send(msg);
		}
		else
		{
			auto x = std::find(clients.begin(), clients.end(), s);
			if(x != clients.end())
				clients.erase(x);
		}
	}
}

int Server::getPlayerByID(int id)
{
	for (int i = 0; i < players.size(); i++)
		if (players[i].id == id)
			return i;

	return 0;
}

void Server::tryStart()
{
	//se comprueba si todos los jugadores están listos para empezar
	int test = true;

	for (Player p : players)
		test = test && p.ready;

	if (test)
	{
		Message m = Message(0, Message::GameEnum::GAME_START, 0);
		send(m);
		gameStarted = true;

		//se limpian los arrays de clientes y ids si se ha empezado la partida, ya que no se necesita el resto
		clients.erase(clients.begin(), clients.end());
		ids_in_use.erase(ids_in_use.begin(), ids_in_use.end());

		for (Player p : players) 
		{
			clients.push_back(p.s);
			ids_in_use.push_back(p.id);
		}
	}
}

bool Server::idExists(int id)
{
	return (std::find(ids_in_use.begin(), ids_in_use.end(), id) != ids_in_use.end());
}

void Server::logout(Socket* s)
{
	//se busca y limpia todo rastro del socket (en clients, unverified y players) y se eliminan los ids relacionados de estar en ids_in_use

	auto it = std::find(clients.begin(), clients.end(), s);

	if (it != clients.end()) {
		clients.erase(it);

		auto it_m = unverified.find(s);

		if (it_m != unverified.end()) {

			auto it_id = std::find(ids_in_use.begin(), ids_in_use.end(), unverified[s].id);
			if (it_id != ids_in_use.end()) ids_in_use.erase(it_id);

			unverified.erase(s);
		}
		else {
			for (int i = 0; i < players.size(); i++) {
				if (players[i].s == s) {

					auto it_id = std::find(ids_in_use.begin(), ids_in_use.end(), players[i].id);
					if (it_id != ids_in_use.end()) ids_in_use.erase(it_id);

					delete players[i].s;
					players.erase(players.begin() + i);

					break;
				}
			}
		}
	}
}

void Server::send(Message msg)
{
	//std::cout << "sending\n";

	int player = msg.dest;
	int id = msg.id;

	//esto se hace para que, cuando se reenvíen los mensajes, estos tengan de procedencia el orden del jugador en vez del id (el cual los clientes no puede interpretar)
	msg.id = getPlayerByID(id);

	if (player == 0)
	{
		for (Player p : players)
		{
			if (p.id != id)
				socket.send(msg, *(p.s));
		}
	}
	else
		socket.send(msg, *(players[player].s));

	//std::cout << "all sent!\n";
}


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


void Client::login()
{
	Message em(id, 0, nick);
	em.type = Message::LOGIN;

	send_queue.push(em);
}

void Client::logout()
{
	Message em(id, 0, 0);
	em.type = Message::LOGOUT;

	send_queue.push(em);
}

void Client::ready()
{
	Message em(id, 0, nick);
	em.type = Message::READY;

	send_queue.push(em);
}

void Client::send(const uint8_t& game_enum, const int& m)
{
	sendTo(0, game_enum, m);
}

void Client::send(const uint8_t& game_enum, const float& m)
{
	sendTo(0, game_enum, m);
}

void Client::send(const uint8_t& game_enum, const std::string& m)
{
	sendTo(0, game_enum, m);
}

void Client::sendTo(const int& player, const uint8_t& game_enum, const int& m)
{
	Message msg = Message(id, player, game_enum, m);
	send_queue.push(msg);
}

void Client::sendTo(const int& player, const uint8_t& game_enum, const float& m)
{
	Message msg = Message(id, player, game_enum, m);
	send_queue.push(msg);
}

void Client::sendTo(const int& player, const uint8_t& game_enum, const std::string& m)
{
	Message msg = Message(id, player, game_enum, m);

	//std::cout << "message made\n";

	send_queue.push(msg);
}

void Client::send_thread()
{
    while (true)
    {
		if(!send_queue.empty())
		{
			Message msg = send_queue.front();	send_queue.pop();

			//std::cout << "sending\n";

			socket.send(msg, socket);

			std::cout << "message sent!!!\n";
		}
    }
}

void Client::recv_thread()
{
    while(true)
    {
		std::cout << "looking for messages...\n";

        Message msg;
        
        socket.recv(msg);

		std::cout << "message received!\n";

		//casos especiales para los mensajes de handshake, verified (que "conecta" al jugador y ya le deja recibir todos los mensajes), failed (en caso de haber algún error de verificación, se reintenta)
		if (msg.type == Message::HANDSHAKE)
		{
			handshake(msg);
		}
		else if (msg.type == Message::VERIFIED)
		{
			connected = true;
			playerNum = msg.intMsg;

			//al ser verificado, quiero recibir los nombres e ids de los otros jugadores en espera
			Message em(id, 0, 0);
			em.type = Message::NAMES;

			socket.send(em, socket);
		}
		else if (msg.type == Message::FAILED)
		{
			login();
		}
		else if (msg.game_enum == Message::GameEnum::ORDER)
		{
			if(msg.id == id)
				playerNum = msg.intMsg;
		}
		
		//solo queremos que el jugador "reciba" (o séase, que tenga acceso mediante la cola) mensajes si ha sido verificado (incluyendo el mensaje de verificación, que dice el número de jugador)
		//pero si el juego ya tiene 4 jugadores, queremos avisar al jugador aunque no esté "connected"
		else if (connected || msg.type == Message::FULL)
		{
			std::cout << msg.id;
			std::cout << " sends: TYPE = " << msg.type << " ENUM = " << msg.game_enum << " CONTENT = " << msg.intMsg << " " << msg.floatMsg << " " << msg.strMsg << '\n';
			
			recv_queue.push(msg);

			if (recv_queue.size() > QUEUE_MAX)
				recv_queue.pop();
		}
    }
}

void Client::handshake(const Message& m)
{
	std::cout << "replying to handshake\n";

	//el handshake le da el id al jugador y reenvía un mensaje para verificar
	id = decode(m.intMsg);

	Message em(id, 0, encode(id));
	em.type = Message::HANDSHAKE;
	
	std::cout << "id = " << id << '\n';

	socket.send(em, socket);

	std::cout << "reply sent\n";
}

int Client::decode(int msg)
{
	return ((msg / 5.0) + 375.0) / 2.5;
}

int Client::encode(int msg)
{
	return ((msg * 1.5) - 48.5) + (37.5 * 2.0);
}
