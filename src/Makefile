MAKE_DIRECTORIES=omr1 omr2 omr3
ANT_DIRECTORIES=mail

all:
	@for DIRECTORY in ${MAKE_DIRECTORIES}; do \
		make -C $${DIRECTORY} all; \
	done
	@for DIRECTORY in ${ANT_DIRECTORIES}; do \
		pushd $${DIRECTORY}; \
		ant all; \
		popd; \
	done;

clean:
	@for DIRECTORY in ${MAKE_DIRECTORIES}; do \
		make -C $${DIRECTORY} clean; \
	done
	@for DIRECTORY in ${ANT_DIRECTORIES}; do \
		pushd $${DIRECTORY}; \
		ant clean; \
		popd; \
	done
