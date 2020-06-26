#include "Client.h"

void Client::login()
{
	Message em(id, Message::IGNORE, nick);
	em.type = Message::LOGIN;

	send_queue.push(em);
}

void Client::logout()
{
	Message em(id, Message::LOGGED_OUT, nick);
	em.type = Message::LOGOUT;

	//queremos que el mensaje de logout se envíe de inmediato, sin importar el thread de envío
	socket.send(em, socket);

	loggedOut = true;
}

void Client::ready()
{
	//std::cout << "ready: " << id << '\n';

	Message em(id, Message::PLAYER_READY, nick);
	em.type = Message::READY;

	send_queue.push(em);
}

void Client::send(const Message::GameEnum& game_enum, const int& m)
{
	sendTo(0, game_enum, m);
}

void Client::send(const Message::GameEnum& game_enum, const float& m)
{
	sendTo(0, game_enum, m);
}

void Client::send(const Message::GameEnum& game_enum, const std::string& m)
{
	sendTo(0, game_enum, m);
}

void Client::sendTo(const uint& player, const Message::GameEnum& game_enum, const int& m)
{
	Message msg = Message(id, player, game_enum, m);
	send_queue.push(msg);
}

void Client::sendTo(const uint& player, const Message::GameEnum& game_enum, const float& m)
{
	Message msg = Message(id, player, game_enum, m);
	send_queue.push(msg);
}

void Client::sendTo(const uint& player, const Message::GameEnum& game_enum, const std::string& m)
{
	Message msg = Message(id, player, game_enum, m);

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

			//std::cout << "message sent!!!\n";
		}
    }
}

void Client::recv_thread()
{
    while(true)
    {

        Message msg;
        
        socket.recv(msg);

		//esto es para la versión de consola entregada
		if(msg.id == 0)
			std::cout << "The server sent the following message:\n";
		else
			std::cout << "Player id = " << msg.id << " sent the following message:\n";

		switch(msg.type)
		{
			case Message::Type::ERROR:
				std::cout << "There's been an error: ";
				switch(msg.game_enum)
				{
					case Message::GameEnum::SHUTDOWN:
						std::cout << "Server shutdown\n";
						break;
					case Message::GameEnum::REPEATED_NAME:
						std::cout << "Nickname is already in use\n";
						break;
					case Message::GameEnum::IGNORE:
						std::cout << "Message deserialization error\n";
						break;
				}
				break;
			case Message::Type::FAILED:
				std::cout << "Verification failed\n";
				break;
			case Message::Type::FULL:
				std::cout << "Game is full\n";
				break;
			case Message::Type::HANDSHAKE:
				std::cout << "Handshake received\n";
				break;
			case Message::Type::LOGIN:
				std::cout << "User " + msg.strMsg + " logged in!\n";
				break;
			case Message::Type::LOGOUT:
				std::cout << "User " + msg.strMsg + " logged out!\n";
				break;
			case Message::Type::READY:
				std::cout << "User " + msg.strMsg + " is ready to play!\n";
				break;
			case Message::Type::VERIFIED:
				std::cout << "Client verified\n";
				break;
			case Message::STR:
				switch(msg.game_enum)
				{
					case Message::GameEnum::TURN_START:
						std::cout << "It's " + msg.strMsg + "'s turn\n";
						break;
					case Message::GameEnum::ORDER:
						std::cout << "Player " + msg.strMsg + " plays in turn " << msg.id << "\n";
						break;
					default:
						std::cout << msg.strMsg + '\n';
						break;
				}
				break;
			case Message::INT:
				switch(msg.game_enum)
				{
					case Message::GameEnum::ROLL:
						std::cout << "Rolled a " << msg.intMsg << "\n";
						break;
					default:
						std::cout << msg.intMsg << '\n';
						break;
				}
				break;
			case Message::FLOAT:
				switch(msg.game_enum)
				{
					default:
						std::cout << msg.floatMsg << '\n';
						break;
				}
				break;
		}

		//casos especiales para los mensajes
		//handshake, verified (que "conecta" al jugador y ya le deja recibir todos los mensajes), failed (en caso de haber algún error de verificación, se reintenta)
		//y order (que señaliza el orden del jugador)
		if (msg.type == Message::HANDSHAKE)
		{
			handshake(msg);
		}
		else if (msg.type == Message::VERIFIED)
		{
			connected = true;
			playerNum = msg.intMsg;

			//al ser verificado, quiero recibir los nombres e ids de los otros jugadores en espera
			Message em(id, Message::IGNORE, 0);
			em.type = Message::NAMES;

			socket.send(em, socket);
		}
		else if (msg.type == Message::FAILED)
		{
			login();
		}
		
		//solo queremos que el jugador "reciba" (o séase, que tenga acceso mediante la cola) mensajes si ha sido verificado (incluyendo el mensaje de verificación, que dice el número de jugador)
		//pero queremos avisar al jugador aunque no esté "connected" de algunos tipos de mensaje (errores, partida llena, o recibir los nombres de otros jugadores)
		else if (connected || msg.type == Message::FULL || msg.game_enum == Message::NAME || msg.type == Message::ERROR || msg.game_enum == Message::ORDER || msg.type == Message::VERIFIED)
		{

			//se mete el mensaje a la cola, y si se pasa del límite se elimina el primero (FIFO)
			recv_queue.push(msg);

			if (recv_queue.size() > QUEUE_MAX)
				recv_queue.pop();
		}

		//este mensaje solo se enviará una vez los jugadores ya estén en partida
		//queremos procesarlo el último para que pueda verse en pantalla
		if(msg.game_enum == Message::SHUTDOWN)
			logout();
    }
}

bool Client::getMessage(Message& m)
{
	if (recv_queue.size() > 0)
	{
		m = recv_queue.front();	recv_queue.pop();
		return true;
	}
	else
		return false;
}

int Client::getID()
{
	return playerNum;
}

void Client::handshake(const Message& m)
{

	//el handshake le da el id al jugador y reenvía un mensaje para verificar
	id = decode(m.intMsg);

	Message em(id, Message::IGNORE, encode(id));
	em.type = Message::HANDSHAKE;
	
	std::cout << "handshake in: " << m.intMsg << '\n';
	std::cout << "id = " << id << '\n';
	std::cout << "handshake out: " << em.intMsg << '\n';

	socket.send(em, socket);
}

int Client::decode(int msg)
{
	return (msg + 375) - (49 * 4);
}

int Client::encode(int msg)
{
	return (msg - 48) + (37 * 2.0);
}
