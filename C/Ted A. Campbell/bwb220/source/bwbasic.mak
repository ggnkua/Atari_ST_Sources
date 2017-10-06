PROJ	=BWBASIC
DEBUG	=0
CC	=qcl
CFLAGS_G	= /AL /W3 /Za /DMSDOS 
CFLAGS_D	= /Zd /Gi$(PROJ).mdt /Od 
CFLAGS_R	= /O /Ot /Gs /DNDEBUG 
CFLAGS	=$(CFLAGS_G) $(CFLAGS_R)
LFLAGS_G	= /CP:0xffff /NOI /NOE /SE:0x80 /ST:0x1fa0 
LFLAGS_D	= /INCR 
LFLAGS_R	= 
LFLAGS	=$(LFLAGS_G) $(LFLAGS_R)
RUNFLAGS	=
OBJS_EXT = 	
LIBS_EXT = 	

all:	$(PROJ).exe

bwbasic.obj:	bwbasic.c

bwb_cmd.obj:	bwb_cmd.c

bwb_cnd.obj:	bwb_cnd.c

bwb_dio.obj:	bwb_dio.c

bwb_elx.obj:	bwb_elx.c

bwb_exp.obj:	bwb_exp.c

bwb_fnc.obj:	bwb_fnc.c

bwb_inp.obj:	bwb_inp.c

bwb_int.obj:	bwb_int.c

bwb_mth.obj:	bwb_mth.c

bwb_ops.obj:	bwb_ops.c

bwb_par.obj:	bwb_par.c

bwb_prn.obj:	bwb_prn.c

bwb_stc.obj:	bwb_stc.c

bwb_str.obj:	bwb_str.c

bwb_tbl.obj:	bwb_tbl.c

bwb_var.obj:	bwb_var.c

bwx_tty.obj:	bwx_tty.c

$(PROJ).exe:	bwbasic.obj bwb_cmd.obj bwb_cnd.obj bwb_dio.obj bwb_elx.obj bwb_exp.obj \
	bwb_fnc.obj bwb_inp.obj bwb_int.obj bwb_mth.obj bwb_ops.obj bwb_par.obj bwb_prn.obj \
	bwb_stc.obj bwb_str.obj bwb_tbl.obj bwb_var.obj bwx_tty.obj $(OBJS_EXT)
	echo >NUL @<<$(PROJ).crf
bwbasic.obj +
bwb_cmd.obj +
bwb_cnd.obj +
bwb_dio.obj +
bwb_elx.obj +
bwb_exp.obj +
bwb_fnc.obj +
bwb_inp.obj +
bwb_int.obj +
bwb_mth.obj +
bwb_ops.obj +
bwb_par.obj +
bwb_prn.obj +
bwb_stc.obj +
bwb_str.obj +
bwb_tbl.obj +
bwb_var.obj +
bwx_tty.obj +
$(OBJS_EXT)
$(PROJ).exe

$(LIBS_EXT);
<<
	link $(LFLAGS) @$(PROJ).crf

run: $(PROJ).exe
	$(PROJ) $(RUNFLAGS)

