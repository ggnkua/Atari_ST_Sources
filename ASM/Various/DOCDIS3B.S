	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,rezstore
	; Get old screen rez

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	; Super

	lea	$ff8240,a0
	lea	oldpal,a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	; Old pallette

	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	; Med rez

	lea	$ff8240,a0
	lea	newpal,a1
	rept	8
	move.l	(a1)+,(a0)+
	endr
	; New pallette

	pea	top
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	; Top line
	pea	bottom
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	; Bottom line (No movement instructions)

	pea	device
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	; The device question

keyloop	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	keyloop
	; Scan keyboard

	swap	d0
	cmp.b	#$10,d0
	beq	exit
	; Q
	cmp.b	#$1f,d0
	beq	screen
	; S
	cmp.b	#$19,d0
	beq	printer
	; P
	bra.s	keyloop
	; Another key

printer
; The printer display routine
	lea	doc,a6
	; Document
loop	cmp.b	#$ff,(a6)
	beq	exitprint
	; Check for end
	move.b	(a6),d0
	move.w	d0,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	; Print
	addq.l	#1,a6
	clr.w	d0
	; Move to next char
	bra	loop
	; Carry on

exitprint	move.w	#12,-(sp)
	move.w	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	bra	exit
	; Form Feed and Exit

screen
; This is the screen display routine
	pea	clearquest
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	; Remove the Question mark

	pea	nextpage
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	; The instructions
	
	pea	overflow
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	; Overflow command


	pea	posstart
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	; Start line	
	clr.w	page
	clr.b	line
	; No lines have been displayed
	lea	doc,a0
.loop1	bsr	get_line_and_print
	; Print line of data at a0 (moving it as go)
	tst.w	d7
	; D7=0 End of doc found
	beq	finished_doc
	add.b	#1,line
	cmp.b	#23,line
	bne	.loop1
	; One page has now been completed
; Now get the next command
key_scan	move.l	#$600ff,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	key_scan
	swap	d0
	cmp.w	#$10,d0
	beq	exit
	cmp.w	#$30,d0
	beq	back_page
	cmp.w	#$39,d0
	beq	forward_page
	cmp.w	#$21,d0
	beq	forward_page
	bra	key_scan

back_page
	cmp.w	#0,page
	beq	key_scan
	sub.w	#1,page
	bsr	set_up_page
	bsr	display_page
	bra	key_scan

forward_page
	add.w	#1,page
	bsr	set_up_page
	bsr	display_page
	bra	key_scan

set_up_page
	bsr	.clear_current
	lea	doc,a0
	move.w	page,d6
	move.w	#23,d5
	mulu	d5,d6
	sub.w	#1,d6
	move.w	#-2,d5
.loop	bsr	get_line
	tst.w	d0
	beq	.end_found
	add.w	#1,d5
	cmp.w	d5,d6
	bne	.loop
	rts

.clear_current
	pea	cltobot
	move.w	#9,-(Sp)
	trap	#1
	addq.l	#6,sp
	pea	posstart
	move.w	#9,-(Sp)
	trap	#1
	addq.l	#6,sp
	rts

.end_found
	rts

finished_doc
; This is the end of the doc being found
.key	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	.key
	swap	d0
	cmp.w	#$10,d0
	beq	exit
	cmp.w	#$30,d0
	beq	back_page
	bra	.key

display_page
	clr.b	line
	; No lines have been displayed
.loop1	bsr	get_line_and_print
	; Print line of data at a0 (moving it as go)
	tst.w	d7
	; D7=0 End of doc found
	beq	finished_doc
	add.b	#1,line
	cmp.b	#23,line
	bne	.loop1
	; One page has now been completed

	rts

get_line_and_print
; D7=0 if end of doc found
	lea	temp_str,a1
	move.w	#80,d7
.clear	move.b	#0,(a1)+
	dbf	d7,.clear
	move.w	#$1010,d7
	bsr	get_line
	tst.w	d0
	bne	.cont
	clr.w	d7
.cont	movem.l	d0/a0,-(sp)
	pea	temp_str
	move.w	#9,-(Sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0/a0
	rts

get_line
; This routine scans from a0 into a1 until it finds $a or $ff
; If $ff then d0=0 otherwise d0=random
	lea	temp_str,a1
.loop	move.b	(a0)+,(a1)+
	cmp.b	#9,-1(a0)
	beq	.expand_tab
	cmp.b	#$a,-1(a0)
	beq	.finished1
	cmp.b	#$ff,-1(a0)
	beq	.finished2
	bra	.loop
.finished1
	move.w	#$1000,d0
	rts
.finished2	clr.w	d0
	move.b	#0,-1(a1)
	rts

.expand_tab	sub.l	#1,a1
	move.l	a1,a2
	sub.l	#temp_str,a2
	move.w	a2,d0
	lea	tab_table,a2
.scan	move.w	(a2),d1
	cmp.b 	d0,d1
	bgt	.found_it
	add.l	#4,a2
	bra	.scan

.found_it	move.w	2(a2),d1
	sub.w	d0,d1
	move.w	d1,d0
.place	move.b	#' ',(a1)+
	dbf	d0,.place
	bra	.loop
	
tab_table	dc.w	8,7
	dc.w	16,15
	dc.w	24,23
	dc.w	32,31
	dc.w	40,39
	dc.w	48,47
	dc.w	56,55
	dc.w	64,63
	dc.w	72,71
	dc.w	80,79
	even
exit
	move.w	rezstore,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	lea	oldpal,a0
	lea	$ff8240,a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)

	clr.l	-(sp)
	trap	#1

	section	data
	even
page	dc.w	0
rezstore	dc.w	0
	even
oldpal	ds.w	16
	even
newpal	dc.w	$003,$700,$070,$666,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000
	even
line	dc.b	0
	even
top	dc.b	27,'Y',32,32,27,'p',27,'w',27,'f'
;		 123456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890
	dc.b	'                       Karl (the Camel) Doc Displayer 3b                        ',27,'q',0
	even
cltobot	dc.b	27,'Y',33,32
	rept	23
	dc.b	27,'l'
	dc.b	$d,$a
	endr
	dc.w	0
	even
bottom	dc.b	27,'Y',56,32,27,'p',27,'w'
	dc.b	'                                   '
	dc.b	'<Q> QUITS                          '
	dc.b	'               ',27,'q',27,'v',0
	even
device	dc.b	27,'Y',45,45
	dc.b	'              Press (S)creen or (P)rinter.'
	dc.b	27,'Y',48,60
	dc.b	'    Doc Displayer By'
	dc.b	27,'Y',49,60
	dc.b	'    Karl (THE CAMEL)'
	dc.b	0
	even
clearquest	dc.b	27,'Y',45,32,27,'l'
	dc.b	27,'Y',48,60,27,'l'
	dc.b	27,'Y',49,60,27,'l'
	dc.b	27,'Y',50,60,27,'l'
	dc.b	0
	even
nextpage	dc.b	27,'Y',56,40,27,'p',27,'w'
	dc.b	' <B> BACK ONE PAGE'
	DC.B	27,'Y',56,66
	DC.B	' <Q> QUITS'
	DC.B	27,'Y',56,82
	DC.B	' <F> FORWARD ONE PAGE         '
	dc.b	27,'q',27,'v',0
	even
cls	dc.b	27,'E',0
	even
posstart	dc.b	27,'Y',33,32
	even
overflow	dc.b	27,'v',0
	even
temp_str	dcb.b	100,0
	even
doc
	incbin	source.lst
	dc.b	$ff