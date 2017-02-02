CFLAGS ?= -O3

#cachesim: main.o cachesim.o

#cachesim.o: cachesim.c cachesim.h
#main.o: main.c cachesim.h
all:
	gcc -c cachesim.c -std=c99
	gcc -c main.c
	gcc main.o cachesim.o -o cachesim -lm

clean:
	rm -f *.o *~ \#* cachesim
