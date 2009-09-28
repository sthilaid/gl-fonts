PREFIX=.
INCLUDE_PATH=$(PREFIX)/include
SRC_PATH=$(PREFIX)/src
LIB_PATH=$(PREFIX)/lib
EXTERNAL_LIBS=$(PREFIX)/external-libs

scm-lib-PATH=git://github.com/sthilaid/scm-lib.git
open-gl-ffi-PATH=git://github.com/sthilaid/open-gl-ffi.git

export scm-lib-PATH
export open-gl-ffi-PATH

export-paths: scm-lib-PATH=$(scm-lib-PATH) open-gl-ffi-PATH=$(open-gl-ffi-PATH)

INCLUDE_FILES=scm-lib_.scm opengl_.scm glu_.scm glut_.scm \
              texture_.scm sprite_.scm font_.scm
LIB_FILES=scm-lib.o1 opengl.o1 glu.o1 glut.o1 \
          ppm-reader.o1 texture.o1 sprite.o1 font.o1

all: prefix include lib

prefix:
ifneq "$(PREFIX)" "."
	mkdir -p $(PREFIX)
endif

include: $(addprefix $(INCLUDE_PATH)/, $(INCLUDE_FILES))
$(INCLUDE_PATH)/%.scm: $(SRC_PATH)/%.scm
	mkdir -p $(INCLUDE_PATH)
	cp -f $< $@

lib: $(addprefix $(LIB_PATH)/, $(LIB_FILES))
$(LIB_PATH)/%.o1: $(SRC_PATH)/%.scm
	mkdir -p $(LIB_PATH)
	gsc -o $@ $<

$(SRC_PATH)/scm-lib.scm $(SRC_PATH)/scm-lib_.scm: setup-scm-lib
setup-scm-lib:
	mkdir -p $(LIB_PATH)
	mkdir -p $(EXTERNAL_LIBS)
ifeq "$(wildcard $(EXTERNAL_LIBS)/scm-lib)" ""
	cd $(EXTERNAL_LIBS) && git clone $(scm-lib-PATH)
endif
	cd $(EXTERNAL_LIBS)/scm-lib && git pull
	$(MAKE) -C $(EXTERNAL_LIBS)/scm-lib $(export-paths)
	cp $(EXTERNAL_LIBS)/scm-lib/include/* $(SRC_PATH)/
	cp $(EXTERNAL_LIBS)/scm-lib/src/* $(SRC_PATH)/
	cp $(EXTERNAL_LIBS)/scm-lib/lib/* $(LIB_PATH)/

$(addprefix $(SRC_PATH)/, opengl.scm opengl_.scm glu.scm glu_.scm glut.scm \
                          glut_.scm): setup-open-gl-ffi
setup-open-gl-ffi:
	mkdir -p $(LIB_PATH)
	mkdir -p $(EXTERNAL_LIBS)
ifeq "$(wildcard $(EXTERNAL_LIBS)/open-gl-ffi)" ""
	cd $(EXTERNAL_LIBS) && git clone $(open-gl-ffi-PATH)
endif
	cd $(EXTERNAL_LIBS)/open-gl-ffi && git pull
	$(MAKE) -C $(EXTERNAL_LIBS)/open-gl-ffi $(export-paths)
	cp $(EXTERNAL_LIBS)/open-gl-ffi/include/* $(SRC_PATH)/
	cp $(EXTERNAL_LIBS)/open-gl-ffi/src/* $(SRC_PATH)/
	cp $(EXTERNAL_LIBS)/open-gl-ffi/lib/* $(LIB_PATH)/

clean:
	rm -rf $(EXTERNAL_LIBS) $(INCLUDE_PATH) $(LIB_PATH)