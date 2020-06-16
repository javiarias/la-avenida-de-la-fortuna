#include <string>
#include <unistd.h>
#include <string.h>
#include <vector>
#include <queue>
#include <map>
#include <algorithm>

#include "Serializable.h"
#include "Socket.h"

class Message : public Serializable
{
public:
    static const uint8_t MAX_STR = 200;
    static const size_t BASE_SERV_SIZE = sizeof(uint32_t) + sizeof(int);
    static const size_t BASE_SIZE = sizeof(uint8_t) * 2 + BASE_SERV_SIZE;
    static const size_t INT_MESSAGE_SIZE = BASE_SIZE + sizeof(int);
    static const size_t FLOAT_MESSAGE_SIZE = BASE_SIZE + sizeof(float);
    static const size_t STR_MESSAGE_SIZE = BASE_SIZE + sizeof(char) * MAX_STR;

	//tipos de mensaje INTERNOS. Los tres primeros son genéricos, el resto sirven para identificar mensajes específicos de servidor-cliente
    enum Type { INT = 0, FLOAT = 1, STR = 2, LOGIN = 3, LOGOUT = 4, HANDSHAKE = 5, VERIFIED = 6, FAILED = 7, READY = 8, FULL = 9, NAMES = 10};

	enum GameEnum { LOGGED, GAME_FULL, NAME, PLAYER_READY, GAME_START, ORDER, ROLL, TURN_START, TURN_END };

    Message(){};

    Message(const uint32_t& id, const uint8_t& game_enum, const int& m):id(id), type(INT),intMsg(m), game_enum(game_enum), dest(0){};
    Message(const uint32_t& id, const uint8_t& game_enum, const float& m):id(id), type(FLOAT),floatMsg(m), game_enum(game_enum), dest(0){};
    Message(const uint32_t& id, const uint8_t& game_enum, const std::string& m):id(id), type(STR),strMsg(m), game_enum(game_enum), dest(0){};

    Message(const uint32_t& id, const int& dest, const uint8_t& game_enum, const int& m):id(id), type(INT),intMsg(m), game_enum(game_enum), dest(dest){};
    Message(const uint32_t& id, const int& dest, const uint8_t& game_enum, const float& m):id(id), type(FLOAT),floatMsg(m), game_enum(game_enum), dest(dest){};
    Message(const uint32_t& id, const int& dest, const uint8_t& game_enum, const std::string& m):id(id), type(STR),strMsg(m), game_enum(game_enum), dest(dest){};

    void to_bin();

    int from_bin(char * bobj);

    size_t getSize();

    uint8_t type;
    uint8_t game_enum;

    int intMsg = 0;
    float floatMsg = 0;
    std::string strMsg = "";

    uint32_t id;
    int dest = 0;
};

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

/**
 *  Clase para el servidor de chat
 */
class Server
{
public:
    Server(const char * s, const char * p): socket(s, p)
    {
        socket.bind();
    };

    /**
     *  Thread principal del servidor recive mensajes en el socket y
     *  lo distribuye a los clientes. Mantiene actualizada la lista de clientes
     */
    void do_messages();

private:

	struct Player {
		Socket* s;
		uint32_t id;
		std::string n;
		bool ready = false;
	};

	/**
	 *  Lista de clientes conectados al servidor de Chat, representados por
	 *  su socket
	 */
	std::vector<Socket*> clients;

    /**
     * Socket del servidor
     */
    Socket socket;

	bool gameStarted = false;

	//funciones muy sencillas, pero que verifican que el servidor sea el servidor, y el cliente el cliente
	float decode(float msg);
	float encode(float msg);

	std::map<Socket*, Player> unverified;
	std::vector<Player> players;
	std::vector<int> ids_in_use;

	void handshake(Socket* s);
	void verify(const Message& m, Socket* s);
	bool idExists(int id);
	void logout(Socket* s);
	void send(Message msg);
	int getPlayerByID(int id);
	void tryStart();

	bool ordered = false;
	int turn = 0;
	std::vector<std::pair<int, int>> firstRoll;
};

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

/**
 *  Clase para el cliente de chat
 */
class Client
{
public:
    /**
     * @param s dirección del servidor
     * @param p puerto del servidor
     * @param n nick del usuario
     */
    Client(const char * s, const char * p, const char * n):socket(s, p),
        nick(n){};

    virtual ~Client() { logout(); };

    void login();

    void logout();

	void ready();

	void send(const uint8_t& game_enum, const int& m);
	void send(const uint8_t& game_enum, const float& m);
	void send(const uint8_t& game_enum, const std::string& m);

	void sendTo(const int& player, const uint8_t& game_enum, const int& m);
	void sendTo(const int& player, const uint8_t& game_enum, const float& m);
	void sendTo(const int& player, const uint8_t& game_enum, const std::string& m);

    /**
     *  envía mensajes en la queue
     */
    void send_thread();

    /**
     *  recibe mensajes del servidor
     */
    void recv_thread();

private:

	void handshake();

    /**
     * Socket para comunicar con el servidor
     */
    Socket socket;

    /**
     * Nick del usuario
     */
    std::string nick;

	int playerNum = 0;

	static const uint8_t MAX_NICK = 10;

	//por seguridad, hay un límite a las colas de mensajes
	static const uint8_t QUEUE_MAX = 50;

	uint32_t id = 0;
	uint32_t id = 0;

	bool connected = false;

	//funciones muy sencillas, pero que verifican que el servidor sea el servidor, y el cliente el cliente
	float decode(float msg);
	float encode(float msg);

	std::queue<Message> send_queue;
	std::queue<Message> recv_queue;
};

