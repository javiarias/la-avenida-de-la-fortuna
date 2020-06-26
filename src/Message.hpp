#ifndef MESSAGE_HPP
#define MESSAGE_HPP

#include <string>
#include <unistd.h>
#include <string.h>
#include <vector>
#include <queue>
#include <map>
#include <algorithm>

#include "Serializable.hpp"
#include "Socket.hpp"
#include <cstdlib>
#include <sys/time.h>

class Message : public Serializable
{
public:

	//tipos de mensaje INTERNOS. Los tres primeros son genéricos, el resto sirven para identificar mensajes específicos de servidor-cliente
    enum Type { INT, FLOAT, STR, LOGIN, LOGOUT, HANDSHAKE, VERIFIED, FAILED, READY, FULL, NAMES, ERROR};

	enum GameEnum { IGNORE, SHUTDOWN, REPEATED_NAME, LOGGED, GAME_FULL, NAME, PLAYER_READY, GAME_START, ORDER, ROLL, TURN_START, TURN_END, LOGGED_OUT };


    static const uint8_t MAX_STR = 200;
    static const size_t BASE_SERV_SIZE = sizeof(uint) + sizeof(int);
    static const size_t BASE_SIZE = sizeof(Type) + sizeof(GameEnum) + BASE_SERV_SIZE;
    static const size_t INT_MESSAGE_SIZE = BASE_SIZE + sizeof(int);
    static const size_t FLOAT_MESSAGE_SIZE = BASE_SIZE + sizeof(float);
    static const size_t STR_MESSAGE_SIZE = BASE_SIZE + (sizeof(char) * MAX_STR);

    Message() {};

    virtual void to_bin() override;

    virtual int from_bin(char * bobj) override;

    size_t getSize();

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

    Type type;
    GameEnum game_enum;

    int intMsg = 0;
    float floatMsg = 0;
    std::string strMsg = "";

    uint id;
    int dest = 0;
};

#endif