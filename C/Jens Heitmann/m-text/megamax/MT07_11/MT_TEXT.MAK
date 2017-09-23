OFILES = 	mt_calc.o   mt_disc.o   mt_edit.o   mt_io.o\
										 mt_find.o   mt_font.o   mt_form.o   mt_funkt.o\
										 mt_iff.o    mt_img.o 	 mt_main.o   mt_note.o\
									   mt_pack.o   mt_paint.o  mt_pic.o		 mt_print.o\
									   mt_ruler.o	 mt_scren.o	 mt_toper.o	 mt_unpck.o

CFLAGS =
LFLAGS = -Z

M_TEXT: $(OFILES)
	$(CC) $(LFLAGS) $(OFILES)\
						 				 -o          M_TEXT.PRG
