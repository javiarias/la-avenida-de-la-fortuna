
#include "Message.hpp"

/**
 *  Clase para el cliente de chat
 */
class Client
{
public:

    Client() {};

    /**
     * @param s dirección del servidor
     * @param p puerto del servidor
     * @param n nick del usuario
     */
    Client(const char * s, const char * p, std::string n):socket(s, p),
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

	bool getMessage(Message& m);

	int getID();

private:

	void handshake(const Message& m);

	//funciones muy sencillas, pero que verifican que el servidor sea el servidor, y el cliente el cliente
	int decode(int msg);
	int encode(int msg);

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

	//colas de envío y recibo de mensajes
	std::queue<Message> send_queue;
	std::queue<Message> recv_queue;
};