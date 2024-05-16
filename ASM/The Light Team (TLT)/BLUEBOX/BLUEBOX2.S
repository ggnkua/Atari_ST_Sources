; DTMF Tone Dialer & Software Bluebox for Atari ST - Coded by Zaphod/TLT.
; Beta-Version for TLT members only..... 
; Spett-A-Box - Yet another TLT Production.......
;
; T////////B46018XXXXXXC

	opt	d+

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,super

	lea	stack,a7

	dc.w	$a000
	dc.w	$a00a

	move.b	#6,$484

	move.w	#$19,-(sp)
	trap	#1
	lea	2(sp),sp
	move.w	d0,drive

	move.w	drive,-(sp)
	pea	path
	move.w	#$47,-(sp)
	trap	#1
	lea	8(sp),sp

	lea	bluename,a0
	bsr	load

	lea	info,a0
	bsr	print

	lea	cursor_on,a0
	bsr	print
	
	bsr	update

main_loop:
	bsr	mosslass_on
	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp
	bsr	mosslass_off
	swap	d0

	cmp.b	#$4b,d0
	beq	not_up1

	cmp.b	#$48,d0
	bne	not_up

	cmp.w	#0,numy1
	ble	not_up1

	move.w	numy1,d7
	sub.w	#1,d7
	bsr	move_cur
	bra	main_loop

not_up1:
	cmp.w	#0,numy2
	ble	not_up
	sub.w	#1,numy2
	move.w	#9,numy1

	bsr	update
	bra	main_loop

not_up:
	cmp.b	#$4d,d0
	beq	not_down1

	cmp.b	#$50,d0
	bne	not_down

	cmp.w	#9,numy1
	bge	not_down1

	move.w	numy1,d7
	add.w	#1,d7
	bsr	move_cur
	bra	main_loop

not_down1:
	cmp.w	#9,numy2
	bge	not_down
	add.w	#1,numy2
	clr.w	numy1

	bsr	update
	bra	main_loop


not_down:
	cmp.b	#$3b,d0
	bne	not_f1

	bsr	dial_last
	bra	main_loop

not_f1:
	cmp.b	#$3c,d0
	bne	not_f2

	lea	numbers+40,a2
	move.w	numy1,d5
	move.w	numy2,d6
	mulu.w	#(40+70+70),d5
	adda.w	d5,a2
	mulu.w	#(40+70+70)*10,d6
	adda.w	d6,a2
	tst.w	blueflag
	beq	notb
	lea	70(a2),a2

notb:
	bsr	dial_loop
	bra	main_loop

not_f2:
	cmp.b	#$3d,d0
	bne	not_f3

	lea	iprompt0,a0
	bsr	print
	bsr	mosslass_on
	lea	manual,a1
	bsr	getnum
	lea	clrip,a0
	bsr	print
	bsr	mosslass_off
	bra	main_loop

not_f3:
	cmp.b	#$3e,d0
	bne	not_f4
	clr.w	blueflag
	move.l	tabz+08,ctabz+00
	move.l	tabz+12,ctabz+04
	bra	main_loop

not_f4:
	cmp.b	#$3f,d0
	bne	not_f5
	move.w	#1,blueflag
	move.l	tabz+00,ctabz+00
	move.l	tabz+04,ctabz+04
	bra	main_loop
	
not_f5:
	cmp.b	#$44,d0
	beq	exit

	cmp.b	#$40,d0
	bne	not_f6

	lea	iprompt1,a0
	bsr	print
	lea	temp1,a1
	bsr	getnum
	lea	iprompt2,a0
	bsr	print
	bsr	mosslass_on
	lea	temp2,a1
	bsr	getnum
	lea	iprompt3,a0
	bsr	print
	lea	temp3,a1
	bsr	getnum
	lea	clrip,a0
	bsr	print
	bsr	mosslass_off

	lea	temp1+2,a0
	move.w	#40-1,d7
	lea	numbers,a2
	move.w	numy1,d5
	move.w	numy2,d6
	mulu.w	#(40+70+70),d5
	adda.w	d5,a2
	mulu.w	#(40+70+70)*10,d6
	adda.w	d6,a2
	lea	(a2),a1

copper1:
	move.b	(a0)+,(a1)+
	dbra	d7,copper1

	lea	temp2+2,a0
	move.w	#70-1,d7
	lea	40(a2),a1

copper2:
	move.b	(a0)+,(a1)+
	dbra	d7,copper2

	lea	temp3+2,a0
	move.w	#70-1,d7
	lea	110(a2),a1

copper3:
	move.b	(a0)+,(a1)+
	dbra	d7,copper3
	bsr	update
	bra	main_loop

not_f6:
	cmp.b	#$41,d0
	bne	not_f7

	lea	numbers,a2
	move.w	numy1,d5
	move.w	numy2,d6
	mulu.w	#(40+70+70),d5
	adda.w	d5,a2
	mulu.w	#(40+70+70)*10,d6
	adda.w	d6,a2
	move.l	#(40+70+70)-1,d7

clrnum:
	clr.b	(a2)+
	dbra	d7,clrnum
	bsr	update

not_f7:
	cmp.b	#$42,d0
	bne	not_f8

	lea	bluename,a0
	bsr	load

not_f8:
	cmp.b	#$43,d0
	bne	not_f9

	lea	bluename,a0
	bsr	save

not_f9:
	swap	d0
	cmp.b	#'T',d0
	bne	nobreak
	bsr	break
	bra	main_loop

nobreak:
	bsr	dial_digit
	bra	main_loop

dial_last:
	lea	manual+2,a2
	
dial_loop:
	move.b	(a2)+,d0
	and.l	#$ff,d0
	cmp.b	#0,d0
	beq	done

	cmp.b	#'T',d0
	bne	nobreak2
	
	bsr	break
	bra	dial_loop

nobreak2:
	cmp.b	#'/',d0
	bne	notpause

	move.l	#3-1,d6
	bsr	quiet
	bra	dial_loop

notpause:
	bsr	dial_digit
	bra	dial_loop

dial_digit:
	move.l	ctabz+00,a1
	move.l	ctabz+04,a4
	and.l	#$ff,d0

testloop:
	tst.b	(a4)
	beq	nonexist
	cmp.b	(a4)+,d0
	bne.s	testloop

	move.b	16(a4),d1
	and.l	#$ff,d1
	adda.w	d1,a1
	move.l	a1,a3

	move.b	(a3)+,d1
	move.b	(a3)+,d2
	move.b	(a3)+,d3
	move.b	(a3)+,d4
	move.b	(a3)+,d6
	bsr	dial
	bsr	delay
	move.b	(a3)+,d6
	bsr	quiet

nonexist:
	rts
	
dial:
	lea	$ffff8800.w,a0
	move.b	#$7,(a0)
	move.b	#%11111100,2(a0)
	move.b	#$8,(a0)		; Channel 1 Volume MAX.
	move.b	#$c,2(a0)
	move.b	#$9,(a0)		; Channel 2 Volume MAX.
	move.b	#$c,2(a0)
	move.b	#$a,(a0)
	clr.b	2(a0)
	move.b	#0,(a0)
	move.b	d1,2(a0)
	move.b	#1,(a0)
	move.b	d2,2(a0)
	move.b	#2,(a0)
	move.b	d3,2(a0)
	move.b	#3,(a0)
	move.b	d4,2(a0)
	rts

quiet:
	lea	$ffff8800.w,a0
	move.b	#$8,(a0)
	clr.b	2(a0)
	move.b	#$9,(a0)
	clr.b	2(a0)
	move.b	#$a,(a0)
	clr.b	2(a0)
	bsr	delay
	rts

break:
	lea	breaktab,a6
	move.w	badd,d6
	mulu.w	#12,d6
	adda.l	d6,a6

	move.b	(a6)+,d1	; 1:st Break tone.
	move.b	(a6)+,d2
	move.b	(a6)+,d3	
	move.b	(a6)+,d4
	bsr	dial
	move.b	(a6)+,d6
	bsr	delay
	move.b	(a6)+,d6
	bsr	quiet

	move.b	(a6)+,d1	; 1:st Break tone.
	move.b	(a6)+,d2
	move.b	(a6)+,d3	
	move.b	(a6)+,d4
	bsr	dial
	move.b	(a6)+,d6
	bsr	delay
	move.b	(a6)+,d6
	bsr	quiet
	rts

	dc.w	$6042
	
delay:
	and.l	#$ff,d6
	move.l	$4ba,d0
	addq.l	#4,d0

wait:
	cmp.l	$4ba,d0
	bne	wait
	dbra	d6,delay
	rts

print:
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	lea	6(sp),sp
	rts

getnum:
	lea	2(a1),a2
	move.w	#100-1,d7

clearnum:
	clr.b	(a2)+
	dbra	d7,clearnum

	move.l	a1,-(sp)
	move.w	#10,-(sp)
	trap	#1
	lea	6(sp),sp
	rts

done:
	lea	$ffff8800.w,a0
	move.b	#$8,(a0)
	clr.b	2(a0)
	move.b	#$9,(a0)
	clr.b	2(a0)
	move.b	#$a,(a0)
	clr.b	2(a0)
	rts

move_cur:
	lea	cursor_off,a0
	bsr	print
	move.w	d7,numy1
	move.w	numy1,d7
	add.w	#32+4,d7
	and.l	#$ff,d7
	move.b	d7,cursor_on+2
	move.b	d7,cursor_off+2
	lea	cursor_on,a0
	bsr	print
	rts

update:
	lea	update2,a0
	bsr	print
	move.w	#10-1,d7

	lea	numbers,a2
	move.w	numy2,d6
	mulu.w	#(40+70+70)*10,d6
	adda.w	d6,a2

printloop:
	lea	line1,a0
	bsr	print
	lea	(a2),a0
	cmp.b	#0,(a0)
	bne	used
	
	lea	default,a0
used:
	bsr	print
	lea	line2,a0
	bsr	print
	lea	180(a2),a2
	dbra	d7,printloop

	move.w	numy1,d7
	bsr	move_cur
	rts

	
load:
	move.l	a0,-(sp)

	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	lea	8(sp),sp

	move.l	(sp)+,a0

	tst.w	d0
	bne	not_load

	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	lea	8(sp),sp
	move.w	d0,handle

	pea	numbers
	move.l	#18000,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	lea	4(sp),sp

not_load:
	rts

save:
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	lea	8(sp),sp
	move.w	d0,handle

	pea	numbers
	move.l	#18000,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	lea	4(sp),sp
	rts

mosslass_on:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#-1,-(sp)
	move.w	#$b,-(sp)
	trap	#13
	lea	4(sp),sp
	move.w	d0,moss

	bset	#4,d0
	move.w	d0,-(sp)
	move.w	#$b,-(sp)
	trap	#13
	lea	4(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

mosslass_off:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	moss,-(sp)
	move.w	#$b,-(sp)
	trap	#13
	lea	4(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	
exit:
	lea	$ffff8800.w,a0
	move.b	#$8,(a0)
	clr.b	2(a0)
	move.b	#$9,(a0)
	clr.b	2(a0)
	move.b	#$a,(a0)
	clr.b	2(a0)
	
	move.l	super,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp

	move.w	drive,-(sp)
	move.w	#$e,-(sp)
	trap	#1
	lea	4(sp),sp

	pea	path
	move.w	#$3b,-(sp)
	trap	#1
	lea	6(sp),sp

	dc.w	$a009
	
	clr.w	-(sp)
	trap	#1

super:		dc.l 	0
handle:		dc.w	0
drive:		dc.w	0
badd:		dc.w	0
moss:		dc.w	0

dtmftab:
	dc.b	094,0,133,0,02,02	; 0941 Hz & 1336 Hz = 0
 	dc.b	103,0,179,0,02,02	; 0697 Hz & 1209 Hz = 1
	dc.b	094,0,179,0,02,02	; 0697 Hz & 1336 Hz = 2
	dc.b	085,0,179,0,02,02	; 0697 Hz & 1477 Hz = 3
	dc.b	103,0,162,0,02,02	; 0770 Hz & 1209 Hz = 4	
	dc.b	094,0,162,0,02,02	; 0770 Hz & 1336 Hz = 5
	dc.b	085,0,162,0,02,02	; 0770 Hz & 1477 Hz = 6
	dc.b	103,0,147,0,02,02	; 0852 Hz & 1209 Hz = 7
	dc.b	094,0,147,0,02,02	; 0852 Hz & 1336 Hz = 8
	dc.b	085,0,147,0,02,02	; 0852 Hz & 1477 Hz = 9
	dc.b	103,0,133,0,02,02	; 0941 Hz & 1209 Hz = *
	dc.b	085,0,133,0,02,02	; 0941 Hz & 1477 Hz = #
	dc.b	076,0,179,0,02,02	; 0697 Hz & 1644 Hz = A
	dc.b	076,0,162,0,02,02	; 0770 Hz & 1644 Hz = B
	dc.b	076,0,147,0,02,02	; 0852 Hz & 1644 Hz = C
	dc.b	076,0,133,0,02,02	; 0941 Hz & 1644 Hz = D

	even

bluetab:
	dc.b	096,0,083,0,01,01	; 1300 Hz & 1500 Hz = 0
 	dc.b	179,0,139,0,01,01	; 0700 Hz & 0900 Hz = 1
	dc.b	179,0,114,0,01,01	; 0700 Hz & 1100 Hz = 2
	dc.b	139,0,114,0,01,01	; 0900 Hz & 1100 Hz = 3
	dc.b	179,0,096,0,01,01	; 0700 Hz & 1300 Hz = 4	
	dc.b	139,0,096,0,01,01	; 0900 Hz & 1300 Hz = 5
	dc.b	114,0,096,0,01,01	; 1100 Hz & 1300 Hz = 6
	dc.b	179,0,083,0,01,01	; 0700 Hz & 1500 Hz = 7
	dc.b	139,0,083,0,01,01	; 0900 Hz & 1500 Hz = 8
	dc.b	114,0,083,0,01,01	; 1100 Hz & 1500 Hz = 9
	dc.b	179,0,074,0,01,01	; 0700 Hz & 1700 Hz = C.11 (D)
	dc.b	139,0,074,0,01,01	; 0900 Hz & 1700 Hz = C.12 (E)
	dc.b	114,0,074,0,01,01	; 1100 Hz & 1700 Hz = KP1 (A)
        dc.b	096,0,074,0,01,01	; 1300 Hz & 1700 Hz = KP2 (B)
	dc.b	083,0,074,0,01,01	; 1500 Hz & 1700 Hz = ST (C)
	dc.b	068,0,000,0,01,01	; 1850 Hz = Disable Hold (H)

	even

breaktab:
	dc.b	052,0,048,0,5,30	; Nippon Break Tones.
	dc.b	052,0,000,0,5,30

	dc.b	052,0,048,0,8,01	; Hawaii Break Tones.
	dc.b	052,0,000,0,8,02

	even

compdtmf:
	dc.b	'0123456789*#ABCD',0
	dc.b	0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96
	dc.b	102,108,114,120,126,132,138,144,150,156,162

	even

compblue:
	dc.b	'0123456789DEABCH',0
	dc.b	0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96
	dc.b	102,108,114,120,126,132,138,144,150,156,162

	even

info:
	dc.b	27,'E',27,'p',27,'f'
	dc.b	'-------------------------------------------------------------------------------',13,10
	dc.b	'! TSC Multi-Frequency Dialer v2.4 - Coded by Zaphod Beeblebrox/ONC 19/8-91    !',13,10
	dc.b	'-------------------------------------------------------------------------------',13,10
	dc.b	27,'q',13,10,13
	dc.b	27,'Y',32+17,32+0,27,'p','  F1  ',27,'q',' - Re-Dial Last #.  '
	dc.b	27,'p','  F2  ',27,'q',' - Dial Highlighted #.  '
	dc.b	27,'p','  F3  ',27,'q',' - Manual Dial.',13,10
	dc.b	27,'p','  F4  ',27,'q',' - DTMF Tones.      '
	dc.b	27,'p','  F5  ',27,'q',' - CCITT #5 Tones.      '
	dc.b	27,'p','  F6  ',27,'q',' - Add Entry.',13,10
	dc.b	27,'p','  F7  ',27,'q',' - Delete Entry.    '
	dc.b	27,'p','  F8  ',27,'q',' - Load # Dir.          '
	dc.b	27,'p','  F9  ',27,'q',' - Save # Dir.',13,10
	dc.b	0

	even

bluename:
	dc.b	'BLUEBOX.DIR'
	dc.b	0

	even

cursor_on:
	dc.b	27,'Y',32+4,32+5,27,'p','>',27,'q'
	dc.b	0

	even

cursor_off:
	dc.b	27,'Y',32+4,32+5,' '
	dc.b	0

	even

update2:
	dc.b	27,'Y',32+4,32+0
	dc.b	0

	even

line1:
	dc.b	27,'l','        '
	dc.b	0

	even

line2:
	dc.b	13,10
	dc.b	0

	even

default:
	dc.b	'Unused Entry..................'
	dc.b	0

	even

iprompt0:
	dc.b	27,'Y',32+22,32+0,27,'l',27,'Y',32+22,32+0,27,'p','   #:',27,'q',27,'e',' '
	dc.b	0

	even

iprompt1:
	dc.b	27,'Y',32+21,32+0,27,'l',27,'Y',32+21,32+0,27,'p','  Name:',27,'q',27,'e',' '
	dc.b	0

	even

iprompt2:
	dc.b	27,'Y',32+22,32+0,27,'l',27,'Y',32+22,32+0,27,'p',' DTMF#:',27,'q',27,'e',' '
	dc.b	0

	even

iprompt3:
	dc.b	27,'Y',32+23,32+0,27,'l',27,'Y',32+23,32+0,27,'p','CCITT#:',27,'q',27,'e',' '
	dc.b	0

	even

clrip:
	dc.b	27,'Y',32+21,32+0,27,'l',27,'Y',32+22,32+0,27,'l',27,'Y',32+23,32+0,27,'l',27,'f'
	dc.b	0

	even

numy1:		dc.w	0
numy2:		dc.w	0
blueflag:	dc.w	1
ctabz:		dc.l	bluetab,compblue
tabz:		dc.l	bluetab,compblue,dtmftab,compdtmf

	even
	
manual:	
	dc.b 	70
	dc.b	0

	ds.b 	100
	ds.b	0

	even

temp1:	
	dc.b 	40-1
	dc.b	0

	ds.b 	100
	ds.b	0

	even

temp2:	
	dc.b 	70-1
	dc.b	0

	ds.b 	100
	ds.b	0

	even

temp3:	
	dc.b 	70-1
	dc.b	0

	ds.b 	100
	ds.b	0

	even

	section bss

path:	ds.b	128

numbers:	
	ds.b	(40+70+70)*100

	ds.l	100
stack:

	end