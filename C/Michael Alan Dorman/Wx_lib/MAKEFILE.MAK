ARCHIV = ar.ttp
WINLIB = wx_lib.a
LIBHDR = wx_lib.h
REPLAC = -r
WINTST = wx_tst.prg
LIBDIR = c:\hnsc\lib\wx_lib.a
INCDIR = c:\hnsc\inc\wx_lib.h
LIBOBJ = wx_clear.o wx_close.o wx_free.o wx_fscro.o wx_full.o wx_get.o\
wx_info.o wx_init.o wx_move.o wx_name.o wx_new.o wx_open.o wx_print.o\
wx_puts.o wx_outst.o wx_setcl.o wx_setty.o wx_size.o
LIBG = $(WINLIB) aesfast.a vdifast.a

ALL : CLEAN $(WINLIB) $(WINTST)

$(WINLIB) : $(LIBOBJ)
	$(ARCHIV) $(REPLAC) $(WINLIB) $(LIBOBJ)

$(WINTST) : $(WINLIB)

$(LIBOBJ) : $(LIBHDR)

CLEAN :
	$(RM) *.o
