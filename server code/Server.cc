#include <string>
#include <unistd.h>
#include <string.h>
#include <signal.h>

#include "Serializable.h"
#include "Socket.h"
#include "Message.h"

int main(int argc, char **argv)
{
    sigset_t waitset;
    int      sig;

    Server es(argv[1], argv[2]);

    es.do_messages();

    sigemptyset(&waitset);
    sigaddset(&waitset, SIGQUIT);

    sigwait(&waitset, &sig);

    return 0;
}
