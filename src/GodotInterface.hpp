#ifndef GodotInterface_HPP
#define GodotInterface_HPP

#include <string>
#include <unistd.h>
#include <string.h>
#include <signal.h>

#include "Client.hpp"
#include "Server.hpp"
#include <Godot.hpp>
#include <Node2D.hpp>

//para que godot lo reconozcla
namespace godot
{

	class GodotInterface : public Node2D
	{
	GODOT_CLASS(GodotInterface, Node2D)

	public:

		//empleo un array de godot, que admite cualquier tipo de dato
		Array getMessage_Data();

		static void _register_methods();

		GodotInterface() {};

		void _init() {};

		String test(String n) { return n; };

		virtual ~GodotInterface();

		void start(String s, String p, String n, bool h = false);

		bool getMessage();

		void logout();

		void ready();

		void order(int order);

		//para enviar mensajes
		void sendInt(const int& game_enum, const int& m);
		void sendFloat(const int& game_enum, const float& m);
		void sendString(const int& game_enum, const String& m);

		void sendIntTo(const uint& player, const int& game_enum, const int& m);
		void sendFloatTo(const uint& player, const int& game_enum, const float& m);
		void sendStringTo(const uint& player, const int& game_enum, const String& m);
		

	private:
		
		int orderToID(int order);
		int IDToOrder(int id);

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

		bool started = false;
	};
}

#endif