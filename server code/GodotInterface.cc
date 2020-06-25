//thread para recibir mensajes
//extern "C" hace que se pueda compilar en C

int main(int argc, char **argv)
{
    sigset_t waitset;
    int      sig;

    bool host = argv[3];

    Server es(argv[1], argv[2]);

	//quiz� habr�a que abrir un thread para el servidor
    es.do_messages();

    sigemptyset(&waitset);
    sigaddset(&waitset, SIGQUIT);

    sigwait(&waitset, &sig);

    return 0;
}

void* GodotInterface::_recv_thread(void *arg)
{
    Client * server = static_cast<Client *>(arg);

    server->recv_thread();

    return 0;
}
