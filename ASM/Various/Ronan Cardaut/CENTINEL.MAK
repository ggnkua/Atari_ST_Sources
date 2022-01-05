#.DEBUG: 
#######################################
#####    FICHIERS A ASSEMBLER    ######
#######################################
ASMDSP = dsp\dsp_bug.o dsp\dsp_desa.o dsp\load_cld.o dsp\load_lod.o dsp\load_p56.o dsp\gen_fen.o dsp\scroll.o
ASM40 = 40\main.inc\aff_dump.o 40\cent_bug.o 40\dessas.o 40\asm.inc\asm.o 40\main.inc\aff_desa.o 40\main.inc\aff_reg.o  40\main.inc\load.o 40\main.inc\r_total.o  40\main.inc\test.o
ASMBOTH = both\aff_font.o both\clavier.o both\hexedit.o both\eval.o both\gestion.o both\menu.o both\video.o both\cfg_file.o both\f_sel.o
#######################################
#####      FICHIERS A LINKER     ######
#######################################
LINKDSP = dsp\dsp_bug.o dsp\dsp_desa.o dsp\lod.o dsp\load_cld.o dsp\load_lod.o dsp\load_p56.o dsp\gen_fen.o dsp\scroll.o
LINK40 = 40\cent_bug.o 40\dessas.o 40\asm.inc\asm.o 40\main.inc\aff_desa.o 40\main.inc\aff_reg.o 40\main.inc\aff_dump.o 40\main.inc\load.o 40\main.inc\r_total.o 40\main.inc\test.o
LINKBOTH = both\aff_font.o both\clavier.o both\hexedit.o both\eval.o both\gestion.o both\menu.o both\video.o both\cfg_file.o both\f_sel.o

.INICMDS:
	@$(CHDIR) D:\CENTINEL 

DSP_BUG.PRG:	$(ASMDSP) $(ASM40) $(ASMBOTH) dsp\windows.o
 		@$(LINK68) -c=LINKDSP.LNK -G -L -S=128 -O=$@ 
CENTINEL.PRG:	$(ASMDSP) $(ASM40) $(ASMBOTH) both\windows.o
 		@$(LINK68) -c=CENTINEL.LNK -G -S=128 -O=$@ 
		$(CP) CENTINEL.PRG $(CODEPATH)\mon.prg
		$(CP) CENTINEL.PRG c:\auto\rentinel.prg
		



#######################################
#####         DEPENDANCES        ######
#######################################

# 040
40\asm.inc\asm.o : both\define.s 40\macros.s 
40\cent_bug.o	: both\define.s 40\macros.s 40\main.inc\fonction.s 40\main.inc\reloc.s
40\cent_bug.o	: 40\main.inc\saveload.s 40\main.inc\aff_dump.s 40\main.inc\scroll.s  
40\dessas.o	: both\define.s 40\desas.inc\aff_nb.s 40\desas.inc\aff_nb_z.s 40\desas.inc\mode.s 40\desas.inc\table_fp.s 40\desas.inc\table_i.s
40\main.inc\aff_desa.o	: both\define.s 40\macros.s 
40\main.inc\aff_reg.o	: both\define.s 40\macros.s 
40\main.inc\aff_dump.o	: both\define.s 40\macros.s 
40\main.inc\load.o	: both\define.s 40\macros.s
40\main.inc\r_total.o	: both\define.s 40\macros.s
# BOTH
both\aff_font.o : both\define.s both\tabaff.s both\open_win.s
both\clavier.o 	: both\define.s both\tab_car.S
both\hexedit.o 	: both\define.s 
both\eval.o 	: both\define.s 40\eval.inc\convert.s 40\eval.inc\aff_n.s  
both\gestion.o 	: both\define.s
both\video.o	: both\define.s both\xbios.equ both\video.rs both\gem.equ
both\cfg_file.o	: both\define.s both\default.inf
both\f_sel.o 	: both\define.s 
dsp\windows.o	: both\define.s
# DSP
dsp\dsp_bug.o : both\define.s dsp\dsp.p56 
dsp\load_cld.o:	both\define.s
dsp\load_lod.o:	both\define.s
dsp\load_p56.o:	both\define.s
dsp\gen_fen.o :	both\define.s
dsp\dsp_desa.o : both\define.s dsp\table.s dsp\instruct.s dsp\no_paral.s dsp\paral.s
dsp\scroll.o :	both\define.s
dsp\windows.o :	both\define.s

 	
 	


 	