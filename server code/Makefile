CC=g++
CFLAGS=-g -I.
DEPS = Socket.h Message.h
OBJ = Socket.o Message.o
LIBS=-lpthread

%.o: %.cc $(DEPS)
	$(CC) -g -c -o $@ $< $(CFLAGS)

all: server client

server: $(OBJ) Server.o
	g++ -o $@ $^ $(CFLAGS) $(LIBS)

client: $(OBJ) Client.o
	g++ -o $@ $^ $(CFLAGS) $(LIBS)


.PHONY: clean

clean:
	rm -f *.o server client

