#include <string>
#include <unistd.h>
#include <string.h>
#include "Message.h"

extern "C" void * _recv_thread(void *arg)
{
    Client * server = static_cast<Client *>(arg);

    server->recv_thread();

    return 0;
}

extern "C" void * _send_thread(void *arg)
{
    Client * server = static_cast<Client *>(arg);

    server->send_thread();

    return 0;
}

int main(int argc, char **argv)
{
    Client ec(argv[1], argv[2], argv[3]);

    pthread_attr_t attr;
    pthread_t id;

    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);

    ec.login();

    pthread_create(&id, &attr, _recv_thread, static_cast<void *>(&ec));
    pthread_create(&id, &attr, _send_thread, static_cast<void *>(&ec));


    while (true)
    {
        std::string m;
        std::getline(std::cin, m);

        if(m == "ready")
        {
            ec.ready();
        }
        else if(m == "roll")
        {
            int n = (rand() % 6) + 1;
            std::cout << "rolled a " << n << '\n';

            ec.send(Message::ROLL, n);
        }
        else if(m == "logout")
        {
            ec.logout();
        }
        else if(m == "end")
        {
            ec.send(Message::TURN_END, 0);
        }
        else if(m == "int")
        {
            ec.send(Message::GameEnum::NAME, 12);
        }
        else if(m == "float")
        {
            ec.send(Message::GameEnum::NAME, 12.5f);
        }
        else
        {
            ec.send(Message::GameEnum::NAME, m);
        }
    }
    
}

