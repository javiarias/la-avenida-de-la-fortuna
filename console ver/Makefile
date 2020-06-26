CC=g++
CFLAGS=-g -I.
DEPS = Socket.h Server.h Client.h Message.h 
OBJ = Socket.o Server.o Client.o Message.o
LIBS=-lpthread

%.o: %.cc $(DEPS)
	$(CC) -g -c -o $@ $< $(CFLAGS)

all: server client

server: $(OBJ) ServerScript.o
	g++ -o $@ $^ $(CFLAGS) $(LIBS)

client: $(OBJ) ClientScript.o
	g++ -o $@ $^ $(CFLAGS) $(LIBS)


.PHONY: clean

clean:
	rm -f *.o server client

