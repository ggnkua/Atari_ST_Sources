;
; macros utilis‚es dans Strack
;
hline	macro
	move	#\1,d0
	move	#\2,d1
	move	#\3,d2
	bsr	hline2
	endm
vline	macro
	move	#\1,d0
	move	#\2,d1
	move	#\3,d2
	bsr	vline2
	endm
hidem	macro
	dc.w	$a00a
	endm
showm	macro
	dc.w	$a009
	endm
print	MACRO
	lea	\1,a0
	move	#\2,coordx
	move	#\3,coordy
	bsr	print2
	endm
wait_vbl:macro
	move	#37,-(sp)
	trap	#14
	addq	#2,sp
	endm
set_aes:macro
	lea	control(pc),a0
	ifeq	\1+\2
	clr.l	(a0)+
	elseif
	move.l	#\1*65536+\2,(a0)+
	endc
	ifeq	\1+\2
	clr.l	(a0)+
	elseif
	move.l	#\3*65536+\4,(a0)+
	endc
	ifeq	\5
	clr	(a0)+
	elseif
	move	#\5,(a0)+
	endc
	move.l	#aes_params,d1
	move	#$c8,d0
	trap	#2
	endm
set_vdi:macro
	lea	contrl(pc),a0
	ifeq	\1+\2
	clr.l	(a0)+
	elseif
	move.l	#\1*65536+\2,(a0)+
	endc
	ifeq	\3
	clr	2(a0)
	elseif
	move	#\3,2(a0)
	endc
	move	current_handle(pc),contrl+12
	move.l	#vdi_params,d1
	moveq	#$73,d0
	trap	#2
	endm

form_alert:macro
	move	\1,int_in
	move.l	\2,addr_in
	set_aes	52,1,1,1,0
	move	intout(pc),d0
	endm

form_error:macro
	move	\1,int_in
	set_aes	53,1,1,0,0
	move	intout(pc),d0
	endm

graf_mouse:macro
	move	\1,int_in
	IFNC	'\2',''
	move.l	\2,addr_in
	ENDC
	set_aes	78,1,1,1,0
;	move	intout(pc),d0		;inutile !!!
	endm

fsel_input:macro
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	set_aes	90,0,2,2,0
	movem	intout(pc),d0/d1
	endm
;
; lit l'‚tat de la souris
;
; retourne :
;	d0=‚tat des boutons
;		bit 0=bouton gauche
;		bit 1=bouton droit
;	d1=X
;	d2=Y
;
vq_mouse:macro
	set_vdi	124,0,0
	move	intout(pc),d0
	movem	ptsout(pc),d1/d2
	endm

gem_init:macro
	dc.w	$a000
	move.l	d0,a_buf
	set_aes	10,0,1,0,0			;appl_init
	set_aes	77,0,5,0,0			;graf_handle
	move	intout(pc),current_handle
	lea	intin(pc),a0
	move.l	#$10001,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move	#2,(a0)
	set_vdi	100,0,11			;v_opnvwk
	move	contrl+12(pc),current_handle
	endm

gem_exit:macro
	set_aes	19,0,1,0,0			;appl_exit
	set_vdi	101,0,0				;v_clsvwk
	endm

	SECTION	DATA
aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out
vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout

	SECTION	BSS
a_buf		ds.l	1
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1

current_handle	ds.w	1

contrl	ds.w	12
intin	ds.w	128		min 30
intout	ds.w	128		min 45
ptsin	ds.w	128		min 30
ptsout	ds.w	128		min 12
