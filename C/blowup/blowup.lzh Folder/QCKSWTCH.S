/* Guter Anfang */
; Schnelle Aufl”sungsumschaltung 

flag1	equ 0		; 
flag2 	equ 2
flag3	equ 4
;
xres 	equ $40				; farbregister brauchen wir nicht
yres 	equ xres+2			; 2
bpl 	equ yres+2			; 4
slen 	equ bpl+2			; 6
celwr	equ slen+4			; a
planes 	equ celwr+2			; c
c_cfrequ equ planes+2		; e
pll_flag equ c_cfrequ+2		; 10=blubber[40]
pll_res	 equ pll_flag+2		; 12=42
pll_r1	 equ pll_res+2		; 14 paddle-wert
pll_r2 	 equ pll_r1+2		; 16
pll_r3   equ pll_r2+2		; 18
vscr_flag equ pll_r3+2		; 1a
vscr_rx	  equ vscr_flag+2	; 1c	(real xres)
vscr_ry		equ vscr_rx+2	; 1e
col_mode	equ vscr_ry+2	; 20
monitor_type1 equ col_mode+2; 22
critical_flag equ monitor_type1+2; 24		(blubber[50])
max_s_c equ critical_flag+2	; 26
sav_act equ max_s_c+4		; 28
	
		GLOBL install_qckswtch,Xmontype,actres
		GLOBL actbank,tabele,set_video,pieps
		GLOBL disable_vscr_cookie,enable_vscr_cookie

install_qckswtch:
	move.l $4f2,a0	; sysbase
	move.l $24(a0),shift
	move.l $502,old_hardcopy
	move.l #qckswtch,$502	; sprt...
	
	rts
	
	dc.b "XBRA"
	dc.b "BLOW"
old_hardcopy:
	dc.l 0
qckswtch:
	movem.l d0-a6,-(a7)
	move.b ([shift]),d0
	andi #3,d0
	beq qckswtch_noshift
	cmpi #4,Xmontype
	bne qckswtch_rots
	clr.l d7
	move actres,d7
	tst d7
	bmi qckswtch_rots
	move actbank,d1	; augenblickliche bank
	moveq #1,d2
	sub d1,d2		; die andere Bank
	lsl.l #8,d7
	move.l #tabele,a0
	add.l d7,a0 
	move.l a0,a1
	adda.l #5*256,a1
	cmpi #1,flag1(a0)
	bgt qckswtch_rots
	cmpi #1,flag1(a1)
	bgt qckswtch_rots
	move.l xres(a0),d3
	cmp.l xres(a1),d3		; x & y vergleichen
	bne qckswtch_rots
	move d2,actbank
	tst d1
	beq use_bank1
	move.l a0,actdat
	move $ffff9214.w,pll_r1(a1)	; paddle_wert merken
	bra die_firma
use_bank1:
	move.l a1,actdat
	move $ffff9214.w,pll_r1(a0)
die_firma:
	
	bsr set_video
	move.l screen_mem,d1
	rol.l #8,d1
	rol.l #8,d1
	move.b d1,$ff8201
	rol.l #8,d1
	move.b d1,$ff8203
	rol.l #8,d1
	move.b d1,$ff820d

	move.l actdat,a1
		
	clr v_curx
	clr v_cury
	move vscr_rx(a1),_vscr_rx
	move vscr_ry(a1),_vscr_ry

	move vscr_flag(a1),vscr_enable
	beq do_disablex
	bsr enable_vscr_cookie		; cookie richtig
	bra sla1x
do_disablex:
	bsr disable_vscr_cookie
sla1x:

	move bpl(a1),_bpl
	move col_mode(a1),_col_mode
	
qckswtch_rots:	
	movem.l (a7)+,d0-a6
	rts
qckswtch_noshift:
	movem.l (a7)+,d0-a6
	jmp ([old_hardcopy])
	
	data
		
shift: dc.l 0






/* Happy End */