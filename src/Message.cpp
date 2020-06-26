#include "Message.hpp"


size_t Message::getSize(){
    if(type == STR || type == NAMES || type == LOGIN) return STR_MESSAGE_SIZE;
    else if(type == FLOAT) return FLOAT_MESSAGE_SIZE;
    else return INT_MESSAGE_SIZE;
}

void Message::to_bin()
{
    int MESSAGE_SIZE = getSize();

    alloc_data(MESSAGE_SIZE);

    memset(_data, 0, MESSAGE_SIZE);
        
    char* it = _data;
    
    memcpy(it, &id, sizeof(uint));
    it += sizeof(uint);
    
    memcpy(it, &dest, sizeof(uint));
    it += sizeof(uint);

    memcpy(it, &type, sizeof(Type));
    it += sizeof(Type);

    memcpy(it, &game_enum, sizeof(GameEnum));
    it += sizeof(GameEnum);


	//hay que especificar cómo serializar el mensaje según el TYPE
    if(type == STR || type == NAMES || type == LOGIN)
    {		
		char str_c[MAX_STR];
        strcpy(str_c, strMsg.c_str());		
        memcpy(it, str_c, MAX_STR * sizeof(char));
        it += MAX_STR * sizeof(char);
    }
    else if(type == FLOAT)
    {
        memcpy(it, &floatMsg, sizeof(float));
        it += sizeof(float);
    }
    else
    {
        memcpy(it, &intMsg, sizeof(int));
        it += sizeof(int);
    }
} 

int Message::from_bin(char * bobj)
{
    int MESSAGE_SIZE = getSize();

    alloc_data(MESSAGE_SIZE);

    memcpy(static_cast<void *>(_data), bobj, MESSAGE_SIZE);


    char* it = _data;

    //el único caso de error de la función que se nos ocurre es que se
    //sobrepase el tamaño de data, de ahi que usemos un try/catch para lanzar
    //el return -1

    try
    {
        memcpy(&id, it, sizeof(uint));
        it += sizeof(uint);

        memcpy(&dest, it, sizeof(uint));
        it += sizeof(uint);

        memcpy(&type, it, sizeof(Type));
        it += sizeof(Type);

        memcpy(&game_enum, it, sizeof(GameEnum));
        it += sizeof(GameEnum);

		//hay que especificar cómo deserializar el mensaje según el TYPE
		if(type == STR || type == NAMES || type == LOGIN)
		{	
            char str_c[MAX_STR];
            memcpy(str_c, it, MAX_STR * sizeof(char));
            strMsg = std::string(str_c);
            it += MAX_STR * sizeof(char);
        }
        else if(type == FLOAT)
        {
            memcpy(&floatMsg, it, sizeof(float));
            it += sizeof(float);
        }
        else
        {	
            memcpy(&intMsg, it, sizeof(int));
            it += sizeof(int);
        }
    }
    catch(const std::exception& e)
    {
		//en caso de error
        id = 0;
        dest = 0;
        type = ERROR;
        game_enum = IGNORE;
        intMsg = 12345678;
        floatMsg = 0.12345678;
        strMsg = "something deserialized wrong";
    }

    return 0;
}