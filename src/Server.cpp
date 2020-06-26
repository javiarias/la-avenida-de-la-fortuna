#include "Server.hpp"

void Server::do_messages()
{
    while (true)
    {
        Message msg;
        Socket* sock;
        socket.recv(msg, sock);

		Message m(msg);

		//std::cout << getPlayerByID(m.id);
		//std::cout << " sends: TYPE = " << m.type << " ENUM = " << m.game_enum << " CONTENT = " << m.intMsg << " " << m.floatMsg << " " << m.strMsg << '\n';

		//queremos que los logout SIEMPRE se procesen
		if (m.type == Message::LOGOUT)
		{
			logout(sock);
			if (gameStarted)
			{
				logoutInProgress = true;
				shutdown();
			}
			else
			{
				Message log = Message(m.id, Message::GameEnum::LOGGED_OUT, m.strMsg);
				send(m);
			}
		}
		else
		{

			if (!gameStarted)
			{
				switch (m.type)
				{
				case Message::LOGIN:
					clients.push_back(sock);
					handshake(sock, m);
					break;

				case Message::HANDSHAKE:
					verify(m, sock);
					break;
				case Message::NAMES:
					if (getPlayerByID(m.id) > 0)
					{
						//si se piden los nombres, se reenvían los nombres de todos los jugadores menos el emisor del mensaje
						for (Player p : players)
						{
							if (p.id != m.id) {
								Message msg = Message(p.id, m.id, Message::GameEnum::NAME, p.n);
								//std::cout << "sending name: " << p.n << " " << p.id << "\n";
								send(msg);
							}
						}
					}
					break;
				case Message::READY:
					if (getPlayerByID(m.id) > 0)
					{
						send(m);
						players[getPlayerByID(m.id) - 1].ready = true;
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

						int i = getPlayerByID(m.id);

						//se recicla la variable ready para comprobar si ha tirado ya los dados
						if (!(players[i - 1].firstRoll))
						{
							//std::cout << "roll received!: " << m.intMsg << " from player " << i << '\n';
							players[i - 1].firstRoll = true;
							firstRoll.push_back(std::make_pair(m.intMsg, i - 1));
							turn++;
							send(m);
							//std::cout << "turn: " << turn << " size: " << players.size() << '\n';
						}



						//una vez todos los jugadores han lanzado su dado, se establece el orden
						if (turn >= players.size())
						{

							turn = 0;
							ordered = true;

							//ordenar según los resultados de los dados
							std::sort(firstRoll.begin(), firstRoll.end());

							//vector copia para ir ordenando los jugadores
							std::vector<Player> players_copy(players);

							//se avisa a todos los jugadores del orden, incluyendo el jugador al cual nos referimos en el id del mensaje
							for (int i = 0; i < firstRoll.size(); i++) {

								std::pair<int, int> p = firstRoll[i];
								Message msg = Message(i, 0, Message::GameEnum::ORDER, players[p.second].n);

								send(msg);

								players_copy[i] = players[p.second];
							}

							//se ordena el vector players
							players = players_copy;

							//se envía el primer mensaje de start a TODOS, con el número de jugador
							Message msg = Message(0, Message::GameEnum::TURN_START, players[turn].n);
							send(msg);
						}
					}
				}
				else
				{
					if (m.game_enum == Message::GameEnum::TURN_END)
					{
						if (turn == (getPlayerByID(m.id) - 1))
						{
							turn = (turn >= (players.size() - 1)) ? 0 : turn + 1;
							Message msg = Message(0, Message::GameEnum::TURN_START, players[turn].n);
							send(msg);

							//std::cout << "turn ended! turn is now: " << turn << "\n";
						}
					}
					//si no es un mensaje de que ha acabado el turno, se reenvía
					else
						send(m);
				}
			}
		}
    }
}

void Server::waitForLogout()
{
	//simplemente para asegurarnos de que no se cierra el servidor sin avisar a todos

	while (!logoutFinished)
	{
		continue;
	}
}

int Server::decode(int msg)
{
	return (msg + 48) - (37 * 2);
}

int Server::encode(int msg)
{
	return (msg - 375) + (49 * 4);
}

void Server::handshake(Socket* s, const Message& m)
{
	//se comprueba si el nick empleado ya existe
	bool test = false;
	for(int i = 0; i < players.size(); i++){
		test = test || (players[i].n == m.strMsg);
	}

	//si existe, se envía un mensaje de error
	if(test)
	{
		Message msg = Message(0, Message::REPEATED_NAME, "nickname already in use");
		msg.type = Message::ERROR;
		socket.send(msg, *s);
		clients.pop_back();
	}
	else
	{
		int id = 0;

		//generamos un ID único para cada jugador. Se suma 5 para dejar el 0 libre, que vale como "broadcast", y del 1 al 4 libres para emplearlos como orden de jugador
		do { id = rand() % 100000 + 5; } while (idExists(id));

		Player p;
		p.s = s;
		p.id = id;
		p.n = m.strMsg;

		unverified[(*s)] = p;

		//std::cout << "id generated: " << p.id << '\n';

		int encoded = encode(id);
		
		Message msg = Message(0, Message::IGNORE, encoded);
		msg.type = Message::HANDSHAKE;
		ids_in_use.push_back(id);

		socket.send(msg, *s);
	}
}

void Server::verify(const Message& m, Socket* s)
{
	Message msg;

	//primero se mira si existe el socket en la lista de unverified
	auto it_m = unverified.find(*s);

	if (it_m != unverified.end()) {

		//si existe, se verifica el valor devuelto
		int check = decode(m.intMsg);

		if (check == unverified[(*s)].id)
		{
			msg = Message(check, Message::GameEnum::LOGGED, (int)players.size());
			msg.type = Message::VERIFIED;

			//std::cout << "verified!\n";

			if (players.size() >= 4)
			{
				msg.type = Message::FULL;
				msg.game_enum = Message::GameEnum::GAME_FULL;
				//std::cout << "game full\n";
			}
		}
		else {
			msg = Message(0, Message::IGNORE, "verification failed");
			msg.type = Message::FAILED;

			//std::cout << "verification failed\n";
		}

		socket.send(msg, *s);

		//si se ha verificado y la partida no está llena, se añade al cliente a la lista de jugadores.
		//si no, se elimina de la lista de clientes, y su id de la lista de ids en uso
		if (msg.type == Message::VERIFIED)
		{
			Player p = unverified[*s];

			players.push_back(p);

			//std::cout << "Player added: " << p.id << " " << p.n << " Total players: " << players.size() << '\n';

			unverified.erase(*s);

			msg = Message(p.id, Message::GameEnum::NAME, p.n);

			send(msg);
		}
		else
		{
			auto x = clients.begin();
			for(x; x < clients.end(); x++)
				if((**x) == *s)
					break;

			if(x != clients.end())
				clients.erase(x);
			

			if (idExists(unverified[*s].id))
				ids_in_use.erase(std::find(ids_in_use.begin(), ids_in_use.end(), unverified[*s].id));
		}

		//se verifique o no, queremos eliminar al jugador de la lista de no verificados
		unverified.erase(*s);
	}
}

int Server::getPlayerByID(int id)
{
	//traduce el id al orden del jugador, +1 para que empiece en 1 en vez de 0
	for (int i = 0; i < players.size(); i++)
		if (players[i].id == id)
			return i + 1;

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
		//std::cout << "\n----\nGAME START\n----\n\n";

		//si se puede empezar la partida, se avisa a todos los jugadores
		Message m = Message(0, Message::GameEnum::GAME_START, 0);

		//se limpian los arrays de clientes y ids si se ha empezado la partida, ya que no se necesita el resto
		clients.erase(clients.begin(), clients.end());
		ids_in_use.erase(ids_in_use.begin(), ids_in_use.end());

		for (Player p : players) 
		{
			clients.push_back(p.s);
			ids_in_use.push_back(p.id);
		}
		
		send(m);
		gameStarted = true;
	}
	//else
		//std::cout << "game couldn't start\n";
}

void Server::shutdown()
{
	Message m = Message(0, Message::GameEnum::SHUTDOWN, "shutdown");
	m.type = Message::ERROR;

	send(m);

	logoutFinished = true;
}

bool Server::idExists(int id)
{
	//comprueba si ya existe un ID
	return (std::find(ids_in_use.begin(), ids_in_use.end(), id) != ids_in_use.end());
}

void Server::logout(Socket* s)
{
	//se busca y limpia todo rastro del socket (en clients, unverified y players) y se eliminan los ids relacionados de estar en ids_in_use

	//primero se busca el socket en clients
	auto it = clients.begin();
	for(it; it< clients.end(); it++)
		if((**it) == *s)
			break;

	if (it != clients.end()) {
		clients.erase(it);

		//luego se busca el socket en unverified y en players
		auto it_m = unverified.find(*s);

		if (it_m != unverified.end()) {

			auto it_id = std::find(ids_in_use.begin(), ids_in_use.end(), unverified[*s].id);
			if (it_id != ids_in_use.end()) ids_in_use.erase(it_id);

			unverified.erase(*s);
		}
		else {
			for (int i = 0; i < players.size(); i++) {
				if ((*players[i].s) == (*s)) {

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

	//si player == 0, entonces se hace función de "broadcast" menos al emisor
	if (player == 0)
	{
		for (Player p : players)
		{
			if (p.id != id)
			{
				//std::cout << "sending message from: " << id << " to: " << p.id << " in addr: " << *(p.s) << "\n";
				socket.send(msg, *(p.s));
			}
		}
	}
	else
	{
		//std::cout << "sending message from: " << id << " to: " << player << " in addr: " << *(players[getPlayerByID(player) - 1].s) << "\n";
		socket.send(msg, *(players[getPlayerByID(player) - 1].s));
	}
}

