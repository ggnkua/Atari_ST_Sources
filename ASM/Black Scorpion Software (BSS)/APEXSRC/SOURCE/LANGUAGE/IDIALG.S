
GWIN_entry:
 D_miniframe	62-8,72,196+16,64,<"Information">
 D_frame_up		64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text		g_intro_text
 both_jump		GWIN_Ok

GWIN_write:
 D_miniframe	62-8,72-16,196+16,64+16,<"DOPPEL-CHECK">
 D_frame_up		64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text		g_write_text
 both_jump		GWIN_Ok

GWIN_warning1:
 D_miniframe	62-8,72-16,196+16,64+32,<"WARNUNG">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		g_warning1_text
 both_jump		GWIN_Funct_proc2

GWIN_check:
 D_miniframe	62-8,72-16,196+16,64+32,<"WARNUNG">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		g_warning2_text
 both_jump		GWIN_Funct_proc3

GWIN_register:
 D_miniframe	62-8-32-10,72-16-32,196+16+64+20,64+32+64+16,<"Registration">
 D_frame_up		64-8+32-20-1-32-10,72+24-16+5-16-32,192-64+40+2+16+64+20,62-48+8+32+64
bit_num		set	0
 D_editline		100,50+0*20,16+(6*28),10,GINST,NAME,nameline,6,28
 D_editline		100,50+1*20,16+(6*28),10,GINST,ADDR,addrline,6,28
 D_editline		100,50+2*20,16+(6*28),10,GINST,CITY,cityline,3,28
 D_editline		130,50+3*20,16+(6*18),10,GINST,POST,postline,0,18
 D_editline		130,50+4*20,16+(6*18),10,GINST,COUN,counline,3,18
 D_text		g_reg_text
 both_jump		GWIN_Funct_reg

GWIN_Funct_accept:
bit_num		set	0
 D_frmbutton	160-64-8-10,112,048+20,10,WIN,GASK,NO,<"ABBRUCH">
 D_frmbutton	160+16+8-10,112,048+20,10,WIN,GASK,YES,<"FORTFAHREN">
 both_jump		WIN_Quit

GWIN_Funct_proc2:
 D_frmbutton	160-64-8-10,112+16,048+20,10,WIN,GASK,A2,<"ABBRUCH">
 D_frmbutton	160+16+8-10,112+16,048+20,10,WIN,GASK,P2,<"FORTFAHREN">
 both_jump		WIN_Quit

GWIN_Funct_proc3:
 D_frmbutton	160-64-8-10,112+16,048+20,10,WIN,GASK,A3,<"ZURšCK">
 D_frmbutton	160+16+8-10,112+16,048+20,10,WIN,GASK,P3,<"FORTFAHREN">
 both_jump		WIN_Quit

GWIN_Funct_reg:
 D_frmbutton	160-64-8-10,112+16+40,048+20,10,WIN,GASK,A4,<"ABBRUCH">
 D_frmbutton	160+16+8-10,112+16+40,048+20,10,WIN,GASK,P4,<"FORTFAHREN">
 both_jump		WIN_Quit

GWIN_Ok:
bit_num		set	0
 D_frmbutton	160-24-4,112,56,12,WIN,GDIALOG,QUIT,<"WEITER">
 both_jump		WIN_Quit

GWIN_error:
 D_miniframe	62-8,72-16,196+16,64+32,<"WARNUNG">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		g_error_text
 both_jump		GWIN_Funct_proc2

Button_GINST_NAME:
	pushall
	move.l	editline_list,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_GINST_ADDR:
	pushall
	move.l	editline_list+4,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_GINST_CITY:
	pushall
	move.l	editline_list+8,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_GINST_POST:
	pushall
	move.l	editline_list+12,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_GINST_COUN:
	pushall
	move.l	editline_list+16,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_GASK_YES:
Button_GASK_P2:
Button_GASK_P3:
Button_GASK_P4:
	move.w	#1<<Bit_GASK_YES|1<<Bit_GASK_P2|1<<Bit_GASK_P3|1<<Bit_GASK_P4,GASK_BITS
	st		OK_CANCEL
	move.w	#-1,DIALOG_BITS
	rts

Button_GASK_NO:
Button_GASK_A2:
Button_GASK_A3:
Button_GASK_A4:
	move.w	#1<<Bit_GASK_NO|1<<Bit_GASK_A2|1<<Bit_GASK_A3|1<<Bit_GASK_A4,GASK_BITS
	sf		OK_CANCEL
	move.w	#-1,DIALOG_BITS
	rts

Button_GDIALOG_QUIT:
	move.w	#-1,DIALOG_BITS
	move.w	#-1,GDIALOG_BITS
	rts
