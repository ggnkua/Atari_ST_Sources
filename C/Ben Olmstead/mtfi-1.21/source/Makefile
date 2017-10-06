# Makefile for MTFI.
#
# This Makefile should work fine under all POSIX-compliant platforms,
# but I give no guarantees, since my Unix knowledge is not wizardly.

# The name of your C compiler.
#CC =

# The name of your linker.
LINK = $(CC)

# If your OS (like MS-DOS or VMS) requires a certain extension on
# executable files, put it here.
EXEC =

# The extension of an object file.
OBJ = .o

# The compiler switch (if any) for compile only, no link.
NOLINK = -c

# The compiler switch to specify output file name.
OUTC = -o

# The linker switch to specify the output file name.
OUTL = -o

# Whatever flags should always be passed to the compiler should be put
# here.
CFLAGS = -O2

# Whatever flags should always be passed to the linker should be put
# here.
LINKFLAGS =

# Architecture-specific compile/link flags
ARCHLINK =
ARCHC =

WASH =
WASH2 =

# Nothing below this line should need modification... but it might
# anyway.
# -------------------------------------------------------------------- #
OBJECTS = mtfi$(OBJ) isets$(OBJ) idefs$(OBJ) iface$(OBJ)
GETOPT = getopt$(OBJ) getopt1$(OBJ)

HEADERS = mtfi.h iface.h

mtfi$(EXEC): $(OBJECTS) $(GETOPT)
	$(LINK) $(ARCHLINK) $(LINKFLAGS) $(OUTL) mtfi$(EXEC) $(OBJECTS)\
	        $(GETOPT)
	$(WASH)
	$(WASH2)

iface$(OBJ): ifacei.h
isets$(OBJ): ifacei.h

$(OBJECTS): %$(OBJ): %.c $(HEADERS)
	$(CC) $(CFLAGS) $(ARCHC) $(NOLINK) $(OUTC) $@ $<

$(GETOPT): %$(OBJ): %.c getopt.h
	$(CC) $(CFLAGS) $(ARCHC) $(NOLINK) $(OUTC) $@ $<

