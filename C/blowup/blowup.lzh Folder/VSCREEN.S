/* VIRTUAL SCREEN EMULATOR */


	GLOBL actdat,screen_mem,linea
	
	GLOBL vscr_em,v_curx,v_cury,vscr_enable
	
	GLOBL saver_install,saver_deinstall,saver_counter
	
	GLOBL _vscr_rx,_vscr_ry,_bpl,_col_mode,_vscr_x,_vscr_y
	
	GLOBL infovscr,ivscr_cookie,ivscr_product,ivscrt_version
	GLOBL ivscr_x, ivscr_y, ivscr_w, ivscr_h
	GLOBL disable_vscr_cookie,enable_vscr_cookie

shi	equ 16
shiy    equ 16
	
xres 	equ $40				; 0
yres 	equ xres+2			; 2
bpl 	equ yres+2			; 4
slen 	equ bpl+2			; 6
celwr	equ slen+4			; a
planes 	equ celwr+2			; c
c_cfrequ equ planes+2		; e
pll_flag equ c_cfrequ+2		; 10
pll_res	 equ pll_flag+2		; 12
pll_r1	 equ pll_res+2		; 14
pll_r2 	 equ pll_r1+2		; 16
pll_r3   equ pll_r2+2		; 18
vscr_flag equ pll_r3+2		; 1a
vscr_rx	  equ vscr_flag+2	; 1c	(real videoxres)
vscr_ry		equ vscr_rx+2	; 1e
col_mode	equ vscr_ry+2	; 20

/* vscr_em wird im VBL von PLL aufgerufen */
	dc.b "XBRA"
	dc.b "BLOW"
	dc.l 0
vscr_em:
if 0
	addi.l #1,saver_counter
	cmpi.l #5*6000,saver_counter
	blt vscr_weiter
	bsr saver_server
vscr_weiter:
endif
	tst vscr_enable
	beq no_virtual_scr
	movem.l d0-a5,-(sp)
	move $ff82a0,d0
	cmp $ff82ac,d0
	bge no_change
	move.l actdat,a1
	move.l linea,a0
	move -$25a(a0),d0		; mouse x
	move -$258(a0),d1		; mouse y
	clr.l d6

	cmp v_oldx,d0
	bne	mouse_changes	
	cmp v_oldy,d1
	beq no_change
	
mouse_changes:				; x/y hat sich ge„ndert

	move v_curx,v_oldcx
	move v_cury,v_oldcy
	
	move d0,d2
	sub v_curx,d2	; dx
	move d2,d3
	tst _col_mode
	bne add_2x
	add #2*shi,d3
add_2x:
	add #2*shi,d3		; dx+Scrollrand
	sub _vscr_rx,d3		
	blt vsc1		; nach links scrollen
	add d3,v_curx		; nach rechts	
	bra vsc2
vsc1:
	sub #shi,d2		; scroll nach links
	tst d2
	bgt vsc2
	add d2,v_curx
vsc2:



	move d1,d2
	sub v_cury,d2	;dy
	move d2,d3
	add #shiy,d3
	sub _vscr_ry,d3
	blt vsc3
	add d3,v_cury
	bra vsc4
vsc3:
	sub #shiy,d2
	tst d2
	bgt vsc4
	add d2,v_cury
vsc4:
	
	move v_curx,d2
	move v_cury,d3	
	tst d2
	bge vsc10		; negative starts vermeiden
	clr d2
vsc10:
	tst d3
	bge vsc11
	clr d3
vsc11:
; nicht gr”žer als der echte screen werden lassen
	move _vscr_x,d4
	addq #1,d4
	sub _vscr_rx,d4
	cmp d2,d4
	bge no_max_x
	move d4,d2
no_max_x:
	move _vscr_y,d4
	addq #1,d4
	sub _vscr_ry,d4
	cmp d3,d4
	bge no_max_y
	move d4,d3	
no_max_y:

	move d2,d5
	move d3,d6
	move d5,v_curx
	move d6,v_cury
	
	move d5,ivscr_x		; cookie aktualisieren
	move d6,ivscr_y
	
	cmp v_oldcx,d5
	bne m_change
	cmp v_oldcy,d6
	beq no_change
	
m_change:
	ext.l d5
	move v_cury,d6
	mulu _bpl,d6		; Zeilen*bytes/line
		
	move _col_mode,d4
	cmpi #4,d4			; TC ?
	bne not_TC
	lsr #1,d5			; round
	lsl.l #2,d5			; *2
	bra compo
not_TC:
	cmpi #0,d4			; mono?
	bne not_mono
	andi #$ffe0,d5
not_mono:
	lsr #4,d5
	addq #1,d4
	lsl d4,d5
compo:	
	add.l d5,d6

	add.l screen_mem,d6
	move.l #0,$45e
	
	move sr,d0
	ori #$700,sr	
	move d6,d7
	ror.l #8,d6
	move.b d6,$ff8203
;	move.b d6,$ff8207
	ror.l #8,d6
	move.b d6,$ff8201
;	move.b d6,$ff8205
	move.b d7,$ff820d
;	move.b d7,$ff8209
	move d0,sr
	
	move d0,v_oldx
	move d1,v_oldy
	
	
no_change:
	movem.l (sp)+,d0-a5 
	rts
	
no_virtual_scr:
	rts
	
disable_vscr_cookie:
	move.l #'VSCx',ivscr_cookie
	rts
enable_vscr_cookie:
	move.l #'VSCR',ivscr_cookie
	move.w _vscr_rx,ivscr_w	; Sichtbare Breite!
	move.w _vscr_ry,ivscr_h	; Sichtbare H”he!
	rts
	
	bss
_vscr_rx: ds.w 1	; Physikalische Gr”že
_vscr_ry: ds.w 1
_vscr_x:  ds.w 1	; Logische Gr”že
_vscr_y:  ds.w 1	
_bpl:	ds.w 1	
_col_mode : ds.w 1

v_curx: ds.w 1
v_cury:	ds.w 1
v_oldcx: ds.w 1
v_oldcy: ds.w 1	
v_oldx:	ds.w 1
v_oldy:	ds.w 1
vscr_enable: ds.w 1