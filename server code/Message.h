#include <string>
#include <unistd.h>
#include <string.h>
#include <vector>
#include <queue>
#include <map>
#include <algorithm>

#include "Serializable.h"
#include "Socket.h"
#include <cstdlib>
#include <sys/time.h>

class Message : public Serializable
{
public:

	//tipos de mensaje INTERNOS. Los tres primeros son genéricos, el resto sirven para identificar mensajes específicos de servidor-cliente
    enum Type { INT, FLOAT, STR, LOGIN, LOGOUT, HANDSHAKE, VERIFIED, FAILED, READY, FULL, NAMES, ERROR};

	enum GameEnum { IGNORE, REPEATED_NAME, LOGGED, GAME_FULL, NAME, PLAYER_READY, GAME_START, ORDER, ROLL, TURN_START, TURN_END };


    static const uint8_t MAX_STR = 200;
    static const size_t BASE_SERV_SIZE = sizeof(uint) + sizeof(int);
    static const size_t BASE_SIZE = sizeof(Type) + sizeof(GameEnum) + BASE_SERV_SIZE;
    static const size_t INT_MESSAGE_SIZE = BASE_SIZE + sizeof(int);
    static const size_t FLOAT_MESSAGE_SIZE = BASE_SIZE + sizeof(float);
    static const size_t STR_MESSAGE_SIZE = BASE_SIZE + (sizeof(char) * MAX_STR);

    Message(){};
	//tenemos una constructora por copia, pero sólamente copia los valores de Message, no de Serializable, para evitar errores de "double free"
    Message(const Message& m) : id(m.id), type(m.type), dest(m.dest), game_enum(m.game_enum), intMsg(m.intMsg), floatMsg(m.floatMsg), strMsg(m.strMsg){};

	//constructoras para los tres tipos básicos de mensaje: INT, FLOAT y STR, con o sin destinatario
	//si se quiere especificar un TYPE distinto (sólamente necesario en mensajes de cliente-servidor), se puede acceder a la variable y cambiarlo manualmente
    Message(const uint& id, const GameEnum& game_enum, const int& m):id(id), type(INT),intMsg(m), game_enum(game_enum), dest(0){};
    Message(const uint& id, const GameEnum& game_enum, const float& m):id(id), type(FLOAT),floatMsg(m), game_enum(game_enum), dest(0){};
    Message(const uint& id, const GameEnum& game_enum, const std::string& m):id(id), type(STR),strMsg(m), game_enum(game_enum), dest(0){};

    Message(const uint& id, const uint& dest, const GameEnum& game_enum, const int& m):id(id), type(INT),intMsg(m), game_enum(game_enum), dest(dest){};
    Message(const uint& id, const uint& dest, const GameEnum& game_enum, const float& m):id(id), type(FLOAT),floatMsg(m), game_enum(game_enum), dest(dest){};
    Message(const uint& id, const uint& dest, const GameEnum& game_enum, const std::string& m):id(id), type(STR),strMsg(m), game_enum(game_enum), dest(dest){};

    void to_bin();

    int from_bin(char * bobj);

    size_t getSize();

    Type type;
    GameEnum game_enum;

    int intMsg = 0;
    float floatMsg = 0;
    std::string strMsg = "";

    uint id;
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

        //hay que asegurarse de que los rand() siempre den algo distinto
        //así que se inicializa srand() usando el tiempo como seed, con la mayor precisión posible (microsegundos)
        struct timeval t1;
        gettimeofday(&t1, NULL);
        srand(t1.tv_usec * t1.tv_sec);
    };

    /**
     *  Thread principal del servidor recive mensajes en el socket y
     *  lo distribuye a los clientes. Mantiene actualizada la lista de clientes
     */
    void do_messages();

private:

	//struct que define un jugador
	struct Player {
		Socket* s;
		uint32_t id;
		std::string n;
		bool ready = false;
		bool firstRoll = false;
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

	//funciones muy sencillas, pero que verifican que el servidor sea el servidor, y el cliente el cliente
	int decode(int msg);
	int encode(int msg);

	void handshake(Socket* s, const Message& m);
	void verify(const Message& m, Socket* s);
	bool idExists(int id);
	void logout(Socket* s);
	void send(Message msg);
	int getPlayerByID(int id);
	void tryStart();


	//bool para indicar si se ha empezado la partida
	bool gameStarted = false;

	//bool para indicar si se han ordenado los jugadores tras empezar la partida
	bool ordered = false;

	//int que determina el turno
	int turn = 0;

	//vector que sirve para ordenar los jugadores después de que lancen el dado
	std::vector<std::pair<int, int>> firstRoll;

	//lista de jugadores sin verificar
	std::map<Socket, Player> unverified;

	//lista de jugadores verificados, máximo 4
	std::vector<Player> players;

	//lista de ids que se están usando, para evitar repetir
	std::vector<int> ids_in_use;
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
        nick(n)
        {};

    virtual ~Client() { logout(); };

	//funciones para enviar mensajes de login, logout y ready (señal de comenzar la partida)
    void login();
    void logout();
	void ready();

	//funciones para enviar mensajes, con o sin destinatario (siendo este el id del jugador)
	void send(const Message::GameEnum& game_enum, const int& m);
	void send(const Message::GameEnum& game_enum, const float& m);
	void send(const Message::GameEnum& game_enum, const std::string& m);

	void sendTo(const uint& player, const Message::GameEnum& game_enum, const int& m);
	void sendTo(const uint& player, const Message::GameEnum& game_enum, const float& m);
	void sendTo(const uint& player, const Message::GameEnum& game_enum, const std::string& m);

    /**
     *  envía mensajes en la queue
     */
    void send_thread();

    /**
     *  recibe mensajes del servidor
     */
    void recv_thread();

private:

	void handshake(const Message& m);

    /**
     * Socket para comunicar con el servidor
     */
    Socket socket;

    /**
     * Nick del usuario
     */
    std::string nick;

	//orden del jugador
	int playerNum = 0;

	//por seguridad, hay un límite a las colas de mensajes
	static const uint8_t QUEUE_MAX = 50;

	//id del jugador
	uint id = 0;

	//señaliza si el cliente está o no conectado
	bool connected = false;

	//funciones muy sencillas, pero que verifican que el servidor sea el servidor, y el cliente el cliente
	int decode(int msg);
	int encode(int msg);

	//colas de envío y recibo de mensajes
	std::queue<Message> send_queue;
	std::queue<Message> recv_queue;
};

