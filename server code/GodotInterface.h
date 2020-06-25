#include <string>
#include <unistd.h>
#include <string.h>
#include <signal.h>

#include "Serializable.h"
#include "Socket.h"
#include "Message.h"

class GodotInterface
{
public:

    GodotInterface(const char * s, const char * p, bool h = false);


private:
    
    bool host = false;



    extern "C" void * _recv_thread(void *arg);
}