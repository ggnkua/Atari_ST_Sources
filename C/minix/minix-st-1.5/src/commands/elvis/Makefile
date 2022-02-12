CFLAGS	= -O -DCRUNCH

CMD	= elvis ctags ref virecover
OBJ	= blk.o cmd1.o cmd2.o curses.o cut.o ex.o input.o main.o \
	  misc.o modify.o move1.o move2.o move3.o move4.o move5.o \
	  opts.o recycle.o redraw.o regexp.o regsub.o system.o \
	  tio.o tmp.o vars.o vcmd.o vi.o
HDR	= curses.h regexp.h vi.h nomagic.c

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

elvis:	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)

ctags:	ctags.c
	$(CC) $(CFLAGS) ctags.c -o $@

ref:	ref.c
	$(CC) $(CFLAGS) ref.c -o $@

virecover:	virecover.c
	$(CC) $(CFLAGS) virecover.c -o $@

# The file cmd1.c is compiled with the extra flag -DDATE="today's date".
# This date is reported when elvis is run and the :version command is given.
# If you have trouble defining the date in this way, then just comment out
# these two lines so cmd1.c is compiled normally.  The :version command
# won't report the compilation date, but that's really no big deal.
cmd1.o: cmd1.c vi.h
	eval $(CC) -c $(CFLAGS) -DDATE=\'\"`date`\"\' cmd1.c
