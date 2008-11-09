PROG=omr2
OUTPUT_DIR=../../bin/

CC=gcc
CFLAGS=-O2 -Wall `sdl-config --cflags`
LDFLAGS=`sdl-config --libs` -lm -lSDL -lSDL_image -lSDL_gfx

all: ${PROG}

install: ${PROG}
	cp ${PROG} ${OUTPUT_DIR}

${PROG}: omr2.o filtre.o

clean:
	rm -rf *.o *~ ${PROG} ${OUTPUT_DIR}/${PROG}
