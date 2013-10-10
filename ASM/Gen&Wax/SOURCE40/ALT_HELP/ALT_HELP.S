
	; Alt + Help
	; (c) Wax 19 / XI / 1996
	; Cod‚ en 2 heures top chrono en VA 4.0

	output d:\assemble\sources.v40\alt_help\alt_help.app

;OPT_FULL_PATHNAMES

DEBUT_TSR:	lea objet_application,a1

	include alt_help.def
	include visual40.s
	include alt_help.hs
	include alt_help.obj

	comment HEAD=7
	section TEXT

*-------------------------------------------------------------------------*

my_inits:	move #FORM_DIALOG,d0
	move #FD_TEXT_SELECT_F,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR

	lea save_name_file,a0
	move.w #40-1,d1
.copy:	move.b (a0)+,(a1)+
	dbf d1,.copy

	lea objet_fenetre1,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	tst d7
	bmi VISUAL40_END
	rts
*-------------------------------------------------------------------------*

click_bton_cancel:
event_window1_closed:
app_term:
	bra VISUAL40_END

*-------------------------------------------------------------------------*

click_bton_choose:
	lea choose_file,a0
	lea mask_everything,a1
	lea save_name_file,a2
	bsr FILE_SELECTOR
	tst d0
	ble.s .annule

	lea save_name_file,a3
	COPY_STRING_0 a2,a3

	move #FORM_DIALOG,d0
	move #FD_TEXT_SELECT_F,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR

	lea save_name_file,a0
	move.w #40-1,d1
.copy:	move.b (a0)+,(a1)+
	dbf d1,.copy

	lea objet_fenetre1,a0

	move #FD_TEXT_SELECT_F,d0
	move #1,d1		; profondeur 1
	clr d2		; l'int‚rieur
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART

.annule:	rts
*-------------------------------------------------------------------------*

bad_params:	rts

click_bton_ok:
	move #FORM_DIALOG,d0
	move #FIELD_SCREEN_X,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	clr.b d0
	move.l a1,a0
	bsr DECI2VALUE
	move d1,scr_size_x

	move #FORM_DIALOG,d0
	move #FIELD_SCREEN_Y,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	clr.b d0
	move.l a1,a0
	bsr DECI2VALUE
	move d1,scr_size_y

	move #FORM_DIALOG,d0
	move #FIELD_SCREEN_NBP,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	clr.b d0
	move.l a1,a0
	bsr DECI2VALUE
	move d1,scr_nbbp
	beq bad_params

	move #FORM_DIALOG,d0
	move #FIELD_GRAB_X,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	clr.b d0
	move.l a1,a0
	bsr DECI2VALUE
	move d1,grab_size_x

	move #FORM_DIALOG,d0
	move #FIELD_GRAB_Y,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	clr.b d0
	move.l a1,a0
	bsr DECI2VALUE
	move d1,grab_size_y

	move #FORM_DIALOG,d0
	move #FIELD_GRAB_W,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	clr.b d0
	move.l a1,a0
	bsr DECI2VALUE
	move d1,grab_size_w
	beq bad_params

	move #FORM_DIALOG,d0
	move #FIELD_GRAB_H,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	clr.b d0
	move.l a1,a0
	bsr DECI2VALUE
	move d1,grab_size_h
	beq bad_params

	move bouton_2files,flag_2_files

	lea save_name_file,a0
.fend:	tst.b (a0)+		; . R A W 0 x
	bne.s .fend
	cmp.l #'.RAW',-5(a0)
	bne click_bton_choose

	cmp.b #'*',-6(a0)
	beq click_bton_choose
	cmp.b #'?',-6(a0)
	beq click_bton_choose
	cmp.b #'\',-6(a0)
	beq click_bton_choose

	move grab_size_y,d0
	add grab_size_h,d0
	cmp scr_size_y,d0
	bgt bad_params

	move grab_size_x,d0
	add grab_size_w,d0
	cmp scr_size_x,d0
	bgt bad_params

	move.l #FIN_TSR-DEBUT_TSR+4*4096,objet_application+GWVA_APP_OBJ_TSR_SIZE

	SUPER 0
	move.l $70,old_vbl
	move.w sr,-(sp)
	move.w #$2700,sr
	move.l #my_vbl,$70
	move.w (sp)+,sr
	USER
	bra VISUAL40_END

my_vbl:	tst.w $4ee	; incr‚ment‚ lorsqu'on appuie sur alt+help
	beq.s RAZ

	move.l old_vbl(pc),-(sp)     ; voir article
	rts

RAZ:	move.w sr,-(sp)	; on sauvegarde SR
	move.w #$2700,sr	; on coupe les interrups.
	save.l d0-a6

	appel xbios,2,2	; ad. ‚cran

	move.l d0,a6	; on la met dans a6

	btst #0,flag_2_files+1
	beq.s .1file

	lea save_name_file,a0
.fend:	tst.b (a0)+		; . R A W 0 x
	bne.s .fend
	move.l #'.BIN',-5(a0)

.1file:	FILE_OPEN write,save_name_file,d7

	move grab_size_h,d6
	subq #1,d6

	move scr_size_x,d0
	mulu scr_nbbp,d0
	divu #8,d0
	mulu grab_size_y,d0
	add.l d0,a6		; pointe sur la premiŠre ligne

	move grab_size_x,d0
	mulu scr_nbbp,d0
	divu #8,d0
	add.w d0,a6

.all_lines:
	move grab_size_w,d0
	mulu scr_nbbp,d0
	divu #8,d0
	ext.l d0

	FWRITE a6,d0,d7	; on ‚crit l'image.

	move scr_size_x,d0
	mulu scr_nbbp,d0
	divu #8,d0
	add.w d0,a6

	dbf d6,.all_lines

	cmp #16,scr_nbbp
	beq true_color

	btst #0,flag_2_files+1
	beq.s .1file2

	FCLOSE d7

	lea save_name_file,a0
.fend2:	tst.b (a0)+		; . R A W 0 x
	bne.s .fend2
	move.l #'.PAL',-5(a0)

	FILE_OPEN write,save_name_file,d7

.1file2:	pea save_pal
	move scr_nbbp,d1
	moveq #1,d0
	lsl.l d1,d0
	move d0,-(sp)
	clr -(sp)
	appel xbios,$5e,10	; get palette

	move scr_nbbp,d1
	moveq #4,d0
	lsl.l d1,d0
	FWRITE #save_pal,d0,d7	; on ‚crit la palette.

true_color:	FCLOSE d7

	lea save_name_file,a0
.fend3:	tst.b (a0)+		; . R A W 0 x
	bne.s .fend3
	add.b #1,-6(a0)	; incr‚ment le nom de fichier

	MOVE.W #$FFFF,$4EE	; voir article 
     
	move.w #-1,-(sp)
	appel bios,11,4	; ‚tat des touches sp‚ciales

	bclr #3,d0
	move.w d0,-(sp)
	appel bios,11,4	; on d‚sactive alternate

	load.l d0-a6

	move.w (sp)+,sr	; on r‚tablit les interruptions
	move.l old_vbl(pc),-(sp)	; voir article
	rts

*-------------------------------------------------------------------------*

	section DATA

choose_file:	dc.b 'Enter generic name :',0
mask_everything:	dc.b '*.RAW',0
save_name_file:	dc.b 'A:\ALT_HLP0.RAW',0
		dcb.b GWVA_MAX_PATH_LENGTH,0

*-------------------------------------------------------------------------*

	section BSS

old_vbl:		ds.l 1	

flag_2_files:	ds.w 1	; bit 0 = 1 si 2 fichiers

scr_size_x:		ds.w 1
scr_size_y:		ds.w 1
scr_nbbp:		ds.w 1
grab_size_x:	ds.w 1
grab_size_y:	ds.w 1
grab_size_w:	ds.w 1
grab_size_h:	ds.w 1

save_pal:		ds.l 256

FIN_TSR:
 END
