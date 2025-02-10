
FWIN_entry:
 D_miniframe	62-8,72,196+16,64,<"Information">
 D_frame_up		64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text		f_intro_text
 both_jump		FWIN_Ok

FWIN_write:
 D_miniframe	62-8,72-8-8,196+16,64+16,<"Verification">
 D_frame_up		64-8+32-20-1,72+24-16+5-8-8,192-64+40+2+16,62-48+8+16
 D_text		f_write_text
 both_jump		FWIN_Ok

FWIN_warning1:
 D_miniframe	62-8,72-16,196+16,64+32,<"Attention">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		f_warning1_text
 both_jump		FWIN_Funct_proc2

FWIN_check:
 D_miniframe	62-8,72-16,196+16,64+32,<"Attention">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		f_warning2_text
 both_jump		FWIN_Funct_proc3

FWIN_register:
 D_miniframe	62-8-32-10,72-16-32,196+16+64+20,64+32+64+16,<"Registration">
 D_frame_up		64-8+32-20-1-32-10,72+24-16+5-16-32,192-64+40+2+16+64+20,62-48+8+32+64
bit_num		set	0
 D_editline		100,50+0*20,16+(6*28),10,FINST,NAME,nameline,6,28
 D_editline		100,50+1*20,16+(6*28),10,FINST,ADDR,addrline,6,28
 D_editline		100,50+2*20,16+(6*28),10,FINST,CITY,cityline,3,28
 D_editline		130,50+3*20,16+(6*18),10,FINST,POST,postline,0,18
 D_editline		130,50+4*20,16+(6*18),10,FINST,COUN,counline,3,18
 D_text		f_reg_text
 both_jump		FWIN_Funct_reg

FWIN_Funct_accept:
bit_num		set	0
 D_frmbutton	160-64-8-8,112,048+16,10,WIN,FASK,NO,<"Annuler">
 D_frmbutton	160+16+8-8,112,048+16,10,WIN,FASK,YES,<"Commencer">
 both_jump		WIN_Quit

FWIN_Funct_proc2:
 D_frmbutton	160-64-8-8,112+16,048+16,10,WIN,FASK,A2,<"Annuler">
 D_frmbutton	160+16+8-8,112+16,048+16,10,WIN,FASK,P2,<"Commencer">
 both_jump		WIN_Quit

FWIN_Funct_proc3:
 D_frmbutton	160-64-8-8,112+16,048+16,10,WIN,FASK,A3,<"Retour">
 D_frmbutton	160+16+8-8,112+16,048+16,10,WIN,FASK,P3,<"Commencer">
 both_jump		WIN_Quit

FWIN_Funct_reg:
 D_frmbutton	160-64-8-8,112+16+40,048+16,10,WIN,FASK,A4,<"Annuler">
 D_frmbutton	160+16+8-8,112+16+40,048+16,10,WIN,FASK,P4,<"Commencer">
 both_jump		WIN_Quit

FWIN_Ok:
bit_num		set	0
 D_frmbutton	160-24-4-8,112,56+16,12,WIN,FDIALOG,QUIT,<"Continuer">
 both_jump		WIN_Quit

FWIN_error:
 D_miniframe	62-8,72-16,196+16,64+32,<"Attention">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		f_error_text
 both_jump		FWIN_Funct_proc2

Button_FINST_NAME:
	pushall
	move.l	editline_list,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_FINST_ADDR:
	pushall
	move.l	editline_list+4,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_FINST_CITY:
	pushall
	move.l	editline_list+8,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_FINST_POST:
	pushall
	move.l	editline_list+12,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_FINST_COUN:
	pushall
	move.l	editline_list+16,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_FASK_YES:
Button_FASK_P2:
Button_FASK_P3:
Button_FASK_P4:
	move.w	#1<<Bit_FASK_YES|1<<Bit_FASK_P2|1<<Bit_FASK_P3|1<<Bit_FASK_P4,FASK_BITS
	st		OK_CANCEL
	move.w	#-1,DIALOG_BITS
	rts

Button_FASK_NO:
Button_FASK_A2:
Button_FASK_A3:
Button_FASK_A4:
	move.w	#1<<Bit_FASK_NO|1<<Bit_FASK_A2|1<<Bit_FASK_A3|1<<Bit_FASK_A4,FASK_BITS
	sf		OK_CANCEL
	move.w	#-1,DIALOG_BITS
	rts

Button_FDIALOG_QUIT:
	move.w	#-1,DIALOG_BITS
	move.w	#-1,FDIALOG_BITS
	rts
