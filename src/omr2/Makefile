PROG=omr2
OUTPUT_DIR=../../bin/

CC=gcc
CFLAGS = -O2 -Wall  
LDFLAGS = -lm -lSDL


all: ${PROG}

install: ${PROG}
	cp ${PROG} ${OUTPUT_DIR}

${PROG}: omr2.o filtre.o

clean:
	rm -fv *.o *~ ${PROG} ${OUTPUT_DIR}/${PROG}
