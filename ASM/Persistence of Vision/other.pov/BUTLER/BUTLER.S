*****************************************************************
*                      WHAT THE BUTLER SAW RECODE               *
*								*
*                                 BY				*
*								*
*                 MAC SYS DATA of PERSISTENCE OF VISION         *
*								*
*								*
*****************************************************************

	bsr	set_super		;supervisor mode
	move.b	#$12,$fffffc02.w	;disable mouse
	move.b	#2,$484			;stop keyclick/bell
	movem.l	$ffff8240.w,d0-d7	;store original palette
	movem.l	d0-d7,old_pal
	bsr	get_base		;get screen address
	move.l	present_base,a0
	move.w	#0,d0
	bsr	set_rez			;set low rez
	clr.w	$ffff8240.w		;background colour black
	move.w	#$777,$ffff8246.w	;text colour white
	pea	init_text		;print instructions
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)		;get a key
	trap	#1
	addq.l	#2,sp
	move.l	present_base,a0		;set low rez again (clears screen as well)
	move.w	#0,d0
	bsr	set_rez
	move.w	#1,d0			;init music
	jsr	music
	move.l	#music+8,$4de		;set music going on interrupts
	bsr	flip_screen		;set screen
loop	move.w	#64-1,d7		;64 pics to sequence through
 	lea	picture_lookup,a6	;lookup table to pictures
animate	move.w	d7,store
	bsr	flip_screen		;flip the screen so ya cannot see depack

	move.w	delay,d5		;pause length
delay_loop
	bsr	v_sync			;do a loop for a delay
	dbf	d5,delay_loop

	move.w	#11,-(sp)		;is there a key waiting???
	trap	#1
	addq.l	#2,sp
	tst.l	d0			;well?
	bne.s	get_key			;yes so go get one
ret	move.l	(a6)+,a0		;NO so depack a pic
	move.l	last_base,a1
	bsr	tiny
	movem.l	tinypal,d0-d7		;set new palette
	movem.l	d0-d7,$ffff8240.w
	move.w	store,d7
	dbf	d7,animate		;carry on with next pic
	bra	loop			;when all pics have been shown
					;start again with this loop

exit	clr.l	$4de			;stop music
	lea	$ffff8800.w,a0		;turn sound chip off
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	move.b	#$8,$fffffc02.w		;enable mouse

	move.w	#1,d0			;set medium rez
	move.l	old_base,a0
	bsr	set_rez
	movem.l	old_pal,d0-d7		;return original palette
	movem.l	d0-d7,$ffff8240.w
	bsr	set_user		;go into user mode
	clr.w	-(sp)			;exit to desktop
	trap	#1


********** SUBROUTINES **********
get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.b	d0		;check if not a normal ASCII key
	bne.s	.no_swap
	swap	d0		;if not ASCII then swap high word
.no_swap
	cmp.b	#" ",d0		;pause
	beq.s	get_another

	cmp.b	#27,d0		;ESCape
	beq	exit

	cmp.b	#$61,d0		;UNDO
	beq.s	reset

	cmp.b	#$3b,d0		;F1
	blt	ret

	cmp.b	#$44,d0		;F10
	bgt	ret

	sub.w	#$3a,d0		;calculate delay time from key value
	lsl.w	#1,d0		;*2
	move.w	d0,delay
	bra	ret		;goto main loop for pic sequencing

reset	move.l	4.w,a0		;reset ST bit
	jmp	(a0)

get_another			;if a space wait here for another key
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra	ret		;carry on in main loop

flip_screen			;flip between two screens to stop flicker
	move.l	present_base,last_base
	move.l	base,a0
	eor.w	#-1,screen_toggle
	beq.s	.scrn1
	add.w	#32000,a0
.scrn1	move.l	a0,present_base
	move.l	a0,d0
	lsr.l	#8,d0
	lea	$ffff8201,a0
	movep.w	d0,(a0)
	
v_sync	movem.l	d0-a6,-(sp)	;sync to VBL
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-a6
	rts

set_rez	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

get_base			;get screen address
	move.w	#3,-(sp)
	trap	#14
	add.l	#2,sp
	move.l	d0,old_base

	lea	screen,a0
	move.l	a0,d0
	clr.b	d0
	move.l	d0,base
	move.l	d0,present_base
	rts

set_super
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_stack
	rts
set_user
	move.l	old_stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
old_stack	dc.l	0

; Source for unpacking Tiny-pictures - Written by Axe of Delight
; Assemble with Devpac 2.08, Tab-position: 10
; You need source (packed tiny screen) and destination (screen address)
; for unpacking. After unpacking, the palette is saved at tinpal.

tiny:	movem.l	d1-d6/a2-a5,-(sp)
	bsr	t_getpal		; read resolution and palette
	move.l	a4,d5
	move.l	a1,d6
	add.l	#$7d00,d6
	move.l	a1,d4
	add.l	#$a0,d4
	bra.s	t17a0a
t179be:	moveq	#0,d0
	move.b	(a5)+,d0
	beq.s	t179ce
	cmp.b	#1,d0
	beq.s	t179d6
	ext.w	d0
	bra.s	t179de
t179ce:	move.b	(a5)+,d0
	lsl.w	#8,d0
	move.b	(a5)+,d0
	bra.s	t179de
t179d6:	move.b	(a5)+,d0
	lsl.w	#8,d0
	move.b	(a5)+,d0
	neg.w	d0


t179de:	tst.w	d0
	bmi.s	t179ea
	move.b	(a4)+,d3
	lsl.w	#8,d3
	move.b	(a4)+,d3
	bra.s	t17a2e
t179ea:	neg.w	d0
	bra.s	t17a06
t179ee:	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	lea	$9e(a1),a1
	cmp.l	d6,a1
	blt.s	t17a06
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a06
	lea	$ffffff62(a1),a1
t17a06:	dbf	d0,t179ee
t17a0a:	cmp.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
t_end:	movem.l	(sp)+,d1-d6/a2-a5
	rts
t17a18:	move.w	d3,(a1)+
	lea	$9e(a1),a1
	cmp.l	d6,a1
	blt.s	t17a2e
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a2e
	lea	$ffffff62(a1),a1
t17a2e:	dbf	d0,t17a18
	cmp.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
	movem.l	(sp)+,d1-d6/a2-a5
	rts

t_getpal
	cmpi.b	#2,(a0)+	; Color mode?
	ble.s	t_color
	addq.l	#4,a0
t_color	moveq	#31,d0		; install palette
	lea	tinypal(pc),a2
t_copypal
	move.b	(a0)+,(a2)+
	dbra	d0,t_copypal
	move.b	(a0)+,d1
	lsl.w	#8,d1
	move.b	(a0)+,d1
	addq.l	#2,a0
	movea.l	a0,a5		; beginning of Data
	ext.l	d1
	adda.l	d1,a0
	movea.l	a0,a4		; end of Data
	moveq	#1,d0
	rts
tinypal	ds.w 16
delay	dc.w	10
store	dc.w	0
old_pal	ds.b	32
old_base	dc.l	0
last_base	dc.l	0
present_base	dc.l	0
base		dc.l	0
screen_toggle	dc.w	0

picture_lookup		;lookup tables to start of each picture
	dc.l	p0001
	dc.l	p0002
	dc.l	p0003
	dc.l	p0004
	dc.l	p0005
	dc.l	p0006
	dc.l	p0007
	dc.l	p0008
	dc.l	p0009
	dc.l	p0010
	dc.l	p0011
	dc.l	p0012
	dc.l	p0013
	dc.l	p0014
	dc.l	p0015
	dc.l	p0016
	dc.l	p0017
	dc.l	p0018
	dc.l	p0019
	dc.l	p0020
	dc.l	p0021
	dc.l	p0022
	dc.l	p0023
	dc.l	p0024
	dc.l	p0025
	dc.l	p0026
	dc.l	p0027
	dc.l	p0028
	dc.l	p0029
	dc.l	p0030
	dc.l	p0031
	dc.l	p0032
	dc.l	p0033
	dc.l	p0034
	dc.l	p0035
	dc.l	p0036
	dc.l	p0037
	dc.l	p0038
	dc.l	p0039
	dc.l	p0040
	dc.l	p0041
	dc.l	p0042
	dc.l	p0043
	dc.l	p0044
	dc.l	p0045
	dc.l	p0046
	dc.l	p0047
	dc.l	p0048
	dc.l	p0049
	dc.l	p0050
	dc.l	p0051
	dc.l	p0052
	dc.l	p0053
	dc.l	p0054
	dc.l	p0055
	dc.l	p0056
	dc.l	p0057
	dc.l	p0058
	dc.l	p0059
	dc.l	p0060
	dc.l	p0061
	dc.l	p0062
	dc.l	p0063
	dc.l	p0064

p0001	incbin	0001.tny		;all the TINY pics
p0002	incbin	0002.tny
p0003	incbin	0003.tny
p0004	incbin	0004.tny
p0005	incbin	0005.tny
p0006	incbin	0006.tny
p0007	incbin	0007.tny
p0008	incbin	0008.tny
p0009	incbin	0009.tny
p0010	incbin	0010.tny
p0011	incbin	0011.tny
p0012	incbin	0012.tny
p0013	incbin	0013.tny
p0014	incbin	0014.tny
p0015	incbin	0015.tny
p0016	incbin	0016.tny
p0017	incbin	0017.tny
p0018	incbin	0018.tny
p0019	incbin	0019.tny
p0020	incbin	0020.tny
p0021	incbin	0021.tny
p0022	incbin	0022.tny
p0023	incbin	0023.tny
p0024	incbin	0024.tny
p0025	incbin	0025.tny
p0026	incbin	0026.tny
p0027	incbin	0027.tny
p0028	incbin	0028.tny
p0029	incbin	0029.tny
p0030	incbin	0030.tny
p0031	incbin	0031.tny
p0032	incbin	0032.tny
p0033	incbin	0033.tny
p0034	incbin	0034.tny
p0035	incbin	0035.tny
p0036	incbin	0036.tny
p0037	incbin	0037.tny
p0038	incbin	0038.tny
p0039	incbin	0039.tny
p0040	incbin	0040.tny
p0041	incbin	0041.tny
p0042	incbin	0042.tny
p0043	incbin	0043.tny
p0044	incbin	0044.tny
p0045	incbin	0045.tny
p0046	incbin	0046.tny
p0047	incbin	0047.tny
p0048	incbin	0048.tny
p0049	incbin	0049.tny
p0050	incbin	0050.tny
p0051	incbin	0051.tny
p0052	incbin	0052.tny
p0053	incbin	0053.tny
p0054	incbin	0054.tny
p0055	incbin	0055.tny
p0056	incbin	0056.tny
p0057	incbin	0057.tny
p0058	incbin	0058.tny
p0059	incbin	0059.tny
p0060	incbin	0060.tny
p0061	incbin	0061.tny
p0062	incbin	0062.tny
p0063	incbin	0063.tny
p0064	incbin	0064.tny


init_text
	dc.b	27,'E'
 dc.b	27,'Y',32+0,32+10,"WHAT THE BUTLER SAW"
 dc.b	27,'Y',32+1,32+10,"-------------------"
 dc.b	27,'Y',32+4,32+8,"Coded and tune added by"
 dc.b	27,'Y',32+6,32+14,"MAC SYS DATA"
 dc.b	27,'Y',32+10,32+14,"INSTRUCTIONS"
 dc.b	27,'Y',32+12,32+9,"F1-F10 = Speed control"
 dc.b	27,'Y',32+13,32+9," Space = Stop animation"
 dc.b	27,'Y',32+14,32+9,"  Undo = exit"
 dc.b	27,'Y',32+19,32+8,"Press a key to continue."
 dc.b	0
	even
music	incbin "max1.mus"	change this filename for new MAD MAX music!!
	even

	SECTION BSS
	ds.b	256
screen			;space for 2 screens
	ds.b	32000
	ds.b	32000
