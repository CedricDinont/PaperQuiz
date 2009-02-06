CFLAGS=-Wall -g

OMR3:main.o image.o zone.o
	gcc main.o image.o zone.o `sdl-config --libs` -lSDL_image -lSDL_gfx -O3 -o OMR3

main.o: main.c image.h zone.h
	gcc ${CFLAGS} -c main.c

image.o: image.c image.h
	gcc ${CFLAGS} `sdl-config --cflags` -c image.c

zone.o: zone.c zone.h
	gcc ${CFLAGS} -c zone.c

clean:
	rm *.o OMR3
