#include <string>
#include <unistd.h>
#include <string.h>
#include <signal.h>

//#include "Socket.h"
//#include "Message.h"
#include <Godot.hpp>
#include <Node.hpp>

//para que godot lo reconozcla
namespace godot
{
	class GodotInterface : public Node
	{
	GODOT_CLASS(GodotInterface, Node)

	public:

		static void _register_methods();

		GodotInterface() {};

		void _init() { }

		//void start(String s, String p, String n, bool h = false);

		virtual ~GodotInterface();

		/*

		bool getMessage();

		//para enviar mensajes
		void send(const Message::GameEnum& game_enum, const int& m);
		void send(const Message::GameEnum& game_enum, const float& m);
		void send(const Message::GameEnum& game_enum, const std::string& m);

		void sendTo(const uint& player, const Message::GameEnum& game_enum, const int& m);
		void sendTo(const uint& player, const Message::GameEnum& game_enum, const float& m);
		void sendTo(const uint& player, const Message::GameEnum& game_enum, const std::string& m);

		void ready();
		*/

		int test(int a) { return a + 1; }

		/*

		//como godot no tiene par�metros por referencia, y no puedo hacer arrays libres en c++, hay que meter
		//funciones para "partir" el mensaje y "recomponerlo" ya luego en godot
		int getMessage_game_enum();

		int getMessage_intMsg();
		float getMessage_floatMsg();
		std::string getMessage_strMsg();

		int getMessage_id();
		*/

	private:
		/*
		int orderToID(int order);
		int IDtoOrder(int id);

		struct Player {
			uint32_t id;
			std::string n;
		};
		
		bool host = false;

		Server server;
		Client client;

		pthread_attr_t attr;
		pthread_t id_serv;
		pthread_t id_cli;

		sigset_t waitset;
		int      sig;

		std::string nick;
		int id;

		Message storedMessage;

		std::vector<Player> unordered_players;
		std::vector<Player> players{ Player(), Player(), Player(), Player() };
		
		void * _recv_thread(void *arg);
		void * _send_thread(void *arg);
		*/
	};
}