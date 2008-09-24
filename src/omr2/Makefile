
CC=gcc

CFLAGS =  -I/usr/local/include/SDL/  -g -O2 -Wall  
OUTPUT_DIR=../../bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

LDFLAGS = -lm -lSDL


all: install

install: omr2
	cp omr2 ${OUTPUT_DIR}

omr2: omr2.o 
#$(LIBSDL)

clean:
	rm -rf *.o *~ omr2 ${OUTPUT_DIR}/omr2
