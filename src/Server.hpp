#include "Message.hpp"

/**
 *  Clase para el servidor de chat
 */
class Server
{
public:
    Server() {};

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

	void waitForLogout();

	void shutdown();
	
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

	bool logoutInProgress = false;
	bool logoutFinished = false;
};