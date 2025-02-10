
EWIN_entry:
 D_miniframe	62-8,72,196+16,64,<"Information">
 D_frame_up		64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text		e_intro_text
 both_jump		EWIN_Ok

EWIN_write:
 D_miniframe	62-8,72,196+16,64,<"Doublecheck">
 D_frame_up		64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text		e_write_text
 both_jump		EWIN_Ok

EWIN_warning1:
 D_miniframe	62-8,72-16,196+16,64+32,<"Warning">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		e_warning1_text
 both_jump		EWIN_Funct_proc2

EWIN_check:
 D_miniframe	62-8,72-16,196+16,64+32,<"Warning">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		e_warning2_text
 both_jump		EWIN_Funct_proc3

EWIN_register:
 D_miniframe	62-8-32-10,72-16-32,196+16+64+20,64+32+64+16,<"Registration">
 D_frame_up		64-8+32-20-1-32-10,72+24-16+5-16-32,192-64+40+2+16+64+20,62-48+8+32+64
bit_num		set	0
 D_editline		100,50+0*20,16+(6*28),10,EINST,NAME,nameline,6,28
 D_editline		100,50+1*20,16+(6*28),10,EINST,ADDR,addrline,6,28
 D_editline		100,50+2*20,16+(6*28),10,EINST,CITY,cityline,3,28
 D_editline		130,50+3*20,16+(6*18),10,EINST,POST,postline,0,18
 D_editline		130,50+4*20,16+(6*18),10,EINST,COUN,counline,3,18
 D_text		e_reg_text
 both_jump		EWIN_Funct_reg

EWIN_Funct_accept:
bit_num		set	0
 D_frmbutton	160-64-8,112,048,10,WIN,EASK,NO,<"REJECT">
 D_frmbutton	160+16+8,112,048,10,WIN,EASK,YES,<"ACCEPT">
 both_jump		WIN_Quit

EWIN_Funct_proc2:
 D_frmbutton	160-64-8,112+16,048,10,WIN,EASK,A2,<"ABORT">
 D_frmbutton	160+16+8,112+16,048,10,WIN,EASK,P2,<"PROCEED">
 both_jump		WIN_Quit

EWIN_Funct_proc3:
 D_frmbutton	160-64-8,112+16,048,10,WIN,EASK,A3,<"GO BACK">
 D_frmbutton	160+16+8,112+16,048,10,WIN,EASK,P3,<"INSTALL">
 both_jump		WIN_Quit

EWIN_Funct_reg:
 D_frmbutton	160-64-8,112+16+40,048,10,WIN,EASK,A4,<"ABORT">
 D_frmbutton	160+16+8,112+16+40,048,10,WIN,EASK,P4,<"PROCEED">
 both_jump		WIN_Quit

EWIN_Ok:
bit_num		set	0
 D_frmbutton	160-24-4,112,56,12,WIN,EDIALOG,QUIT,<"CONTINUE">
 both_jump		WIN_Quit

EWIN_error:
 D_miniframe	62-8,72-16,196+16,64+32,<"Warning">
 D_frame_up		64-8+32-20-1,72+24-16+5-16,192-64+40+2+16,62-48+8+32
 D_text		e_error_text
 both_jump		EWIN_Funct_proc2

Button_EINST_NAME:
	pushall
	move.l	editline_list,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_EINST_ADDR:
	pushall
	move.l	editline_list+4,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_EINST_CITY:
	pushall
	move.l	editline_list+8,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_EINST_POST:
	pushall
	move.l	editline_list+12,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_EINST_COUN:
	pushall
	move.l	editline_list+16,line_ptr
	jsr		Press_button
	jsr		edit_textline
	jsr		Release_button
	jsr		show_textline
	popall	
	rts

Button_EASK_YES:
Button_EASK_P2:
Button_EASK_P3:
Button_EASK_P4:
	move.w	#1<<Bit_EASK_YES|1<<Bit_EASK_P2|1<<Bit_EASK_P3|1<<Bit_EASK_P4,EASK_BITS
	st		OK_CANCEL
	move.w	#-1,DIALOG_BITS
	rts

Button_EASK_NO:
Button_EASK_A2:
Button_EASK_A3:
Button_EASK_A4:
	move.w	#1<<Bit_EASK_NO|1<<Bit_EASK_A2|1<<Bit_EASK_A3|1<<Bit_EASK_A4,EASK_BITS
	sf		OK_CANCEL
	move.w	#-1,DIALOG_BITS
	rts

Button_EDIALOG_QUIT:
	move.w	#-1,DIALOG_BITS
	move.w	#-1,EDIALOG_BITS
	rts
