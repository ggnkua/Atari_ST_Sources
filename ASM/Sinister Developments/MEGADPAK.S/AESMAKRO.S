ctrlarray	MACRO
	moveq.w	#\1,d0	
	bsr	set_up_ctrl
	ENDM


intnarray	MACRO
	IFEQ	NARG
	FAIL	NO PARAMETERS FOR INTIN ARRAY!!!
	MEXIT	
	ENDC
	IFNE	NARG-9
	FAIL	MISSING PARAMETERS FOR INTIN ARRAY!!!
	MEXIT	
	ENDC
;	zap_intin

	IFEQ	\1
	ifeq	\2
	clr.l	int_in+0
	elseif
	move.l	#$\1000\2,int_in+0
	endc
	ELSEIF
	move.l	#$\1000\2,int_in+0
	ENDC

	IFEQ	\3
	ifeq	\4
	clr.l	int_in+4
	elseif
	move.l	#$\3\4,int_in+4
	endc
	ELSEIF
	move.l	#$\3000\4,int_in+4
	ENDC

	IFEQ	\5
	ifeq	\6
	clr.l	int_in+8
	elseif
	move.l	#$\5000\6,int_in+8
	endc
	ELSEIF
	move.l	#$\5000\6,int_in+8
	ENDC

	IFEQ	\7
	ifeq	\8
	clr.l	int_in+12
	elseif
	move.l	#$\7000\8,int_in+12
	endc
	ELSEIF
	move.l	#$\7000\8,int_in+12
	ENDC

	IFEQ	\9
	clr.w	int_in+16
	ELSEIF
	move.w	#$\9,int_in+16
	ENDC
	ENDM

zap_intin	MACRO
	movem.l	blank(pc),d0-7
	movem.l	d0-7,int_in+0
	ENDM

; Initialise macros 

init_aes	MACRO
	ctrlarray	10
	bsr	call_aes
	move.w	d0,app_id
	ENDM

menu_reg	MACRO
	ctrlarray	35
	zap_intin
	move.w	\1,int_in+0
	move.l	#\2,addr_in+0	
	bsr	call_aes
	move.w	d0,\3
	ENDM

evnt_mess	MACRO
	ctrlarray	23
	zap_intin
	move.l	#\1,addr_in+0
	bsr	call_aes
	move.w	parms(pc),d0
	ENDM
	
; file select macro

fsel	MACRO
	ctrlarray	90
;	zap_intin
	move.l	#\1,addr_in
	move.l	#\2,addr_in+4
	bsr	call_aes
	ENDM

; Graphics macros

grph_mse	MACRO
	ctrlarray	78
	intnarray	\1,0,0,0,0,0,0,0,0
	IFNC	'\2',''
	move.l	#\2,addr_in
	ENDC
	bsr	call_aes
	ENDM

; Resource macros 

load_rsc	MACRO
	ctrlarray	110
	move.l	#\1,addr_in
	bsr	call_aes
	beq	resource_missing
	ENDM

rsc_gaddr	MACRO
	move.w	#\1,int_in
	move.w	\2,int_in+2
	bsr	call_aes
	move.l	addr_out(pc),\3
	ENDM

rsc_free	MACRO
	ctrlarray	111
	zap_intin
	bsr	call_aes
	ENDM

; Form macros

form_cntr	MACRO
	ctrlarray	54
	zap_intin
	move.l	\1,addr_in
	bsr	call_aes
	move.l	int_out+2(pc),\2
	move.l	int_out+6(pc),\2+4
	ENDM

form_dial	MACRO
	ctrlarray	51
	intnarray	\1,0,0,0,0,0,0,0,0
	move.l	\2(pc),int_in+10
	move.l	\2+4(pc),int_in+14
	bsr	call_aes
	ENDM

form_do	MACRO
	ctrlarray	50
	intnarray	\1,0,0,0,0,0,0,0,0
	bsr	call_aes
	ENDM

form_alrt	MACRO
	ctrlarray	52
	move.w	#\2,int_in
;	zap_intin
	move.l	#\1,addr_in+0
	bsr	call_aes
	ENDM

show_form	MACRO
	lea	form_tab+(\1*4)(pc),a0
	bsr	display_form
	ENDM

kill_form	MACRO
	hidemouse
	lea	form_tab+(\1*4)(pc),a0
	bsr	close_form
	ENDM

; Object macros

obj_draw	MACRO
	ctrlarray	42
	intnarray	\1,\2,0,0,0,0,0,0,0
	movem.l	\3(pc),d0-1
	movem.l	d0-1,int_in+4
	bsr	call_aes
	ENDM

obj_chnge	MACRO
	move.w	#\1,a4
	move.w	#\2,a5
	move.w	#\3,a6
	lea	form_tab+(\4*4)(pc),a0
	bsr	object_change
	ENDM
; various
tedinfo	MACRO
	lea	obj_tab+((\1)*4)(pc),\2
	move.l	(\2),\2
	ENDM


; Ugh! Alines

hidemouse	MACRO
	dc.w	$a00a
	ENDM

showmouse	MACRO
	dc.w	$a009
	ENDM
