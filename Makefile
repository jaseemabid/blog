# Makefile for github blog

SRC_DIR = js

JS_ENGINE ?= `which node nodejs 2>/dev/null`
COMPILER = jsmin

JS_LIBS = ${SRC_DIR}/jquery-1.7.1.min.js \
	${SRC_DIR}/jquery.timeago.min.js \
	${SRC_DIR}/raphael.js \
	${SRC_DIR}/bootstrap.min.js

BASE_FILES = ${SRC_DIR}/script.js \
	${SRC_DIR}/bubbles.js \

MODULES = ${JS_LIBS}\
	${BASE_FILES}

SC = ${SRC_DIR}/jaseemabid.js
SC_MIN = ${SRC_DIR}/jaseemabid.min.js

SC_VER = $(shell git log --pretty=format:"%h" -n 1)

DATE = $(shell git log -1 --pretty=format:%ad)

all: script min lessc Jekyll
	@@echo "Jekyll build complete."

script: ${SC}

${SC}: ${MODULES} | ${SRC_DIR}
	@@echo "Building the file" ${SC};
	@@cat ${MODULES} > ${SC};

min: script ${SC_MIN}

${SC_MIN}: ${SC}
	@@if test ! -z ${JS_ENGINE}; then \
		echo "Minifying script" ${SC_MIN}; \
		${COMPILER} < ${SC} > ${SC_MIN} Version:${SC_VER} ; \
	else \
		echo "You must have NodeJS installed in order to minify jekyll scripts"; \
	fi

Jekyll :
	bash -c "jekyll"

lessc :
	bash -c "lessc -x css/style.less > css/style.min.css"

clean:
	@@echo "Cleaning up build files"
	@@rm -f ${SRC_DIR}/foochat.js ${SRC_DIR}/foochat.min.js

.PHONY: all script jekyll min clean
