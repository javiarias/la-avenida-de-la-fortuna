#include <string>
#include <unistd.h>
#include <string.h>
#include <signal.h>

#include "Socket.h"
#include "Message.h"

class GodotInterface
{
public:

    GodotInterface(const char * s, const char * p, const char * n, bool h = false);

	virtual ~GodotInterface();

	bool getMessage();

	void send(const Message::GameEnum& game_enum, const int& m);
	void send(const Message::GameEnum& game_enum, const float& m);
	void send(const Message::GameEnum& game_enum, const std::string& m);

	void sendTo(const uint& player, const Message::GameEnum& game_enum, const int& m);
	void sendTo(const uint& player, const Message::GameEnum& game_enum, const float& m);
	void sendTo(const uint& player, const Message::GameEnum& game_enum, const std::string& m);

	void ready();


	int getMessage_game_enum();

	int getMessage_intMsg();
	float getMessage_floatMsg();
	std::string getMessage_strMsg();

	int getMessage_id();

private:

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
	pthread_t id;

	sigset_t waitset;
	int      sig;

	std::string nick;
	int id;

	Message storedMessage;

	std::vector<Player> unordered_players;
	std::vector<Player> players{ Player(), Player(), Player(), Player() };

    extern "C" void * _recv_thread(void *arg);
    extern "C" void * _send_thread(void *arg);
}