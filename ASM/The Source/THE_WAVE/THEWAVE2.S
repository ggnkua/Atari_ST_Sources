;
; The Wave Demo II by MUG U.K¿ (of The Source)
; --------------------------------------------
;
; Original version by: Quick Brown Fox Productions
;
; Disassembled, Re-Coded & added to by: MUG U.K¿ (of The Source)

	opt	d+,p+

	output	.exe

start	movea.l	a7,a5		; work out how much memory
	lea	new_sp(pc),a7	; to grab
	movea.l	4(a5),a5
	move.l	$C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	addi.l	#$A8100,d0	; 20 screens + 256 bytes workspace
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	adda.w	#12,a7

	tst.l	d0	; error generated during memory grab ?
	bne	not_enuf 	; you musn't have enough memory

	bra	continue

not_enuf	lea	no_mem(pc),a0	; Not enough memory error message
	bra	print		; print it
	ds.w	401
new_sp	ds.w	1

continue	pea	stuff		; store palette, bell off etc.
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#4,-(a7)		; get screen resolution
	trap	#14
	addq.l	#2,a7

	lea	col_dem(pc),a0	; colour only error message
	cmpi.w	#2,d0 		; are we in mono
	beq	print 		; if so - bye bye
	move.w	d0,old_rez	; old resolution

	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7 
	move.l	d0,old_scr

	lea	coded_by(pc),a6
	move.l	a6,d0 
	addi.l	#$ff,d0 
	andi.l	#$ffff00,d0 	; ensure on 256-byte boundary
	movea.l	d0,a6 
	movea.l	a6,a5 

;	
; Loop to read in all 20 picture files into memory
;
	move.w	#1,d6 		; start with picture 1
pic_load	move.b	d6,d0		; move loop number to d0
	addi.b	#64,d0 		; add 64 to it (ie. A, B, C etc)
	move.b	d0,endchar	; place it into end of filename

	clr.w	-(a7)		; open to read
	pea	file(pc) 		; filename
	move.w	#$3D,-(a7)	; f_open
	trap	#1		; gemdos 
	addq.l	#8,a7 		; tidy stack
	lea	nofile(pc),a0	; file not found error message
	tst.w	d0		; found OK
	bmi	print		; gemdos error instead
	move.w	d0,d7		; handle

	move.l	a5,-(a7)		; load address
	move.l	#$7d00,-(a7)	; 32000 bytes
	move.w	d7,-(a7)		; file handle
	move.w	#$3F,-(a7)	; f_read
	trap	#1		; gemdos 
	adda.w	#12,a7		; tidy stack

	lea	disk_err(pc),a0	; set up disk error message
	cmpi.l	#$7d00,d0 	; 32000 bytes in length ?
	blt	print 		; any less - send an error

	move.w	d7,-(a7)		; file handle
	move.w	#$3e,-(a7)	; f_close
	trap	#1		; gemdos 
	addq.l	#4,a7 		; tidy stack
	adda.l	#$8000,a5 	; add 32768 bytes
	addq.w	#1,d6 		; next file
	cmpi.w	#21,d6 		; up to 21 files yet ?
	bne.s	pic_load 		; no - redo loop

	move.w	#4,d6		
	move.w	#1,d5 
	move.w	#-1,d4

	dc.w	$a00a		; mouse off

	clr.w	-(a7)		; low resolution
	move.l	#-1,-(a7) 
	move.l	#-1,-(a7) 
	move.w	#5,-(a7)
	trap	#14
	adda.w	#12,a7

	pea	palette(pc) 	; set new palette
	move.w	#6,-(a7)
	trap	#14
	addq.l	#6,a7

L0003	bsr	L0008 
	add.w	d4,d5 
	bpl	L0004 
	move.w	#$13,d5 
L0004	cmpi.w	#$14,d5 
	bne	L0005 
	clr.w	d5
L0005	move.w	d6,d3 

vloop	move.w	#$25,-(a7)	; vsync
	trap	#14		; xbios 
	addq.l	#2,a7 		; tidy stack
	dbf	d3,vloop

	move.w	#$00ff,-(a7)	; read character
	move.w	#6,-(a7)		; c_rawio
	trap	#1		; gemdos
	addq.l	#4,a7 		; tidy stack

	cmpi.b	#3,d0 		; Control C pressed ?
	beq	resetscr 		; Yes = quit demo
	cmpi.b	#$30,d0		
	bne	L0007 
	neg.w	d4

L0007	subi.b	#$31,d0
	bmi	L0003
	cmpi.b	#9,d0
	bgt.s	L0003
	ext.w	d0
	move.w	d0,d6
	bra	L0003

L0008	move.w	d5,d0 
	andi.l	#$1F,d0 
	swap	d0
	clr.w	d0
	lsr.l	#1,d0 
	add.l	a6,d0 

	move.w	#-1,-(a7) 	; rez unchanged
	move.l	d0,-(a7)		; set new screen address
	move.l	d0,-(a7)		; and here also
	move.w	#5,-(a7)		; setscreen
	trap	#14		; xbios
	adda.w	#12,a7		; tidy stack
	rts 

stuff	moveq	#1,d0
	bsr	muzak
	move.l	#muzak+16,$4da.w

	movem.l	$ffff8240,d0-d7	; store old palette
	movem.l	d0-d7,old_pal	
	move.b	#1,pal_flag	; palette stored flag
	bclr	#0,$484.w		; bell off
	rts

stuff2	cmpi.l	#0,$4da.w		; music running ?
	beq.s	others
	clr.l	$4da.w
	move.l	#$ff8800,a0	; silence sound
	move.l	#$08000000,(a0)
	move.l	#$09000000,(a0)
	move.l	#$0a000000,(a0)

others	cmpi.b	#1,pal_flag	; has palette been stored ?
	bne.s	others2
	movem.l	old_pal,d0-d7	; restore palette
	movem.l	d0-d7,$ff8240

others2	bset	#0,$484.w		; bell on
	rts

;
; Print Error Message in a0, wait for a key and quit
;
print	move.l	a0,-(a7)	
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7 

	move.w	#1,-(a7)
	trap	#1
	addq.l	#2,a7 
	bra.s	quit

resetscr	move.l	old_rez(pc),-(a7)	; set old screens
	move.l	old_scr(pc),-(a7)
	move.l	old_scr(pc),-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.w	#12,a7

quit	pea	stuff2		; reset palette & bell
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1

palette	dc.w	$335,$300,$400,$500,$600,$700,$330,$440,$550
	dc.w	$660,$770,$777,$755,$775,$766,$776,$000

old_rez	ds.w	1 
old_scr	ds.l	1
file	dc.b	'SCREEN'		; filename
endchar	dc.b	'A',$00		; different file endings

old_pal	ds.w	16
pal_flag	ds.b	1

muzak	incbin "new_mdrv.rpl"
	incbin "tsc_27.tun"
	even

no_mem	dc.b   'There is not enough memory available !',$00 

col_dem	dc.b   'This is a colour demo !',0

nofile	dc.b   'File not found !',0

disk_err	dc.b   'Disk error !',0,0,0,0 
 
coded_by	dc.b   'A MUG U.K¿ (of The Source) production - 15/11/1991',0,0 
