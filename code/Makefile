# Soccer Makefile
# 
# Make shared, static or debug targets.
# 
# Distribution: GPL 

OS := $(shell uname)
OBJ = build
TARGET = game
RENAME = install_name_tool
GNATMAKE = gnatmake -D $(OBJ)
CARGS = -cargs -O3 -gnatp -gnatwu
BARGS = -bargs
LARGS = -largs
VERBOSE = -v
SHARED = libgnat-4.3.dylib
ADA_LIB ?= /usr/local/ada-4.3/lib
.PHONEY: clean cleaner dist-clean tar

all:
	@echo ""
	@echo "Soccer build targets:"
	@echo ""
	@echo "    shared     Use the shared Ada libraries."
	@echo "    static     Link the Ada libraries statically."
	@echo "    debug      Enable debugging."
	@echo ""
	@echo "Support targets:"
	@echo ""
	@echo "    clean      Remove *.ali *.o b~.*"
	@echo "    cleaner    Remove target, too."
	@echo "    dist-clean Remove Xcode build directory, too."
	@echo "    tar        Build a clean distribution tarball."
	@echo ""

shared: $(OBJ)
shared: INCLUDE = $(shell gtkada-config --cflags)
shared: BARGS += -shared
shared: LARGS += $(shell gtkada-config --libs)
shared: LARGS += -dead_strip
shared: *.ad[sb]
	@echo "building with shared libraries:"
	$(GNATMAKE) $(TARGET) $(INCLUDE) $(CARGS) $(BARGS) $(LARGS)
ifeq ($(OS), Darwin)
#	$(RENAME) -change $(SHARED) $(ADA_LIB)/$(SHARED) $(TARGET)
endif

static: $(OBJ)
static: INCLUDE = $(shell gtkada-config --static --cflags)
static: BARGS += -static
static: LARGS += $(shell gtkada-config --static --libs)
static: LARGS += -dead_strip
static: *.ad[sb]
	$(GNATMAKE) $(TARGET) $(INCLUDE) $(CARGS) $(BARGS) $(LARGS)

debug: $(OBJ)
debug: INCLUDE = $(shell gtkada-config --static --cflags)
debug: BARGS += -static
debug: LARGS += $(shell gtkada-config --static --libs)
debug: *.ad[sb]
	$(GNATMAKE) -g $(TARGET) $(INCLUDE) $(LARGS)

$(OBJ):
	mkdir $(OBJ)

clean:
	${RM} $(OBJ)/* b~*

cleaner: clean
	${RM} $(TARGET)

dist-clean: cleaner
	${RM} -r $(OBJ) 

tar: dist-clean
ifeq ($(OS), Darwin)
	(export COPYFILE_DISABLE=true; \
	tar --exclude '.svn' -zcvf soccer.tgz ../0.1)
else
	tar --exclude '.svn' -zcvf soccer.tgz ../0.1
endif
