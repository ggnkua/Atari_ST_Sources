************************************
* File Maker+                      *
* Made by: Anders Nilsson in 92'   *
************************************

max_trk	equ	80	*maximum tracks on disk
side	equ	0	*0 or 1
drive	equ	1	*0=a 1=b

x:
	lea	mega_text,a0
	jsr	print_and_wait
	jsr	get_information	*get info from sec 1 trk 0
	tst.w	d1		*error ?
	bmi.s	no_more_read	*yes\no
	move.w	super_info+280,max_s
	move.w	d1,no_sec	*move no_sec to read into variable

	move.l	#mega_buffer,pek *point at the mega_buffer
	move.w	#0,trk		*the "file" starts at sec 2 trk 0
	move.w	#2,sec		
read_loop:
	jsr	read_sec	*read a sector from the disk
	addq.w	#1,sec		*add sec
	move.w	max_s,d0	*reached the top of track?
	cmp.w	sec,d0
	blo.s	add_trk		*yes\no
back_loop:
	sub.w	#1,no_sec	*count the sectors to read
	bpl.s	read_loop
	lea	mega_text2,a0
	jsr	print_and_wait
	jsr	make_file	*make a file of the data
	tst.w	d0		*error
	bmi.s	no_more_read	*yes\no
	moveq	#0,d0
	illegal			*no_error	
no_more_read:
	moveq	#-1,d0
	illegal			*error
add_trk:
	move.w	#1,sec		*restore sec to lowest part of track
	add.w	#1,trk		*add trk with one
	cmp.w	#max_trk,trk	*reached the top o disk
	bhi.s	no_more_read	*yes\no
	bra	read_loop	*continue
get_information:
	move.w	#0,trk		*read info sector on sec 1 trk 0
	move.w	#1,sec
	move.l	#super_info,pek	*point at the super_info buffer
	jsr	read_sec	*read a sector
	move.l	super_info+260,d0	*calc........
	move.l	super_info+264,d1
	sub.l	d0,d1
	divu	#512,d1
	swap	d1
	tst.w	d1
	beq	no_add
	swap	d1
	addq.w	#1,d1
	swap	d1
no_add:
	swap	d1
	sub.w	#1,d1		*(d1=0 => ß ok) (d1=-1 => -ß bad)
	rts
make_file:
	clr.w	-(sp)			*the normal o.s. blaha!!
	move.l	#filename,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	urrk
	move.w	d0,handle
	move.l	super_info+260,d0
	move.l	super_info+264,d1
	sub.l	d0,d1
	move.l	#mega_buffer,-(sp)
	move.l	d1,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	urrk
	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	urrk
	moveq	#0,d0
	rts
urrk:
	moveq	#-1,d0
	rts

read_sec:
	move.w	#1,-(sp)		*the normal o.s. blaha!!
	move.w	#side,-(sp)
	move.w	trk,-(sp)
	move.w	sec,-(sp)
	move.w	#drive,-(sp)
	clr.l	-(sp)
	move.l	pek,-(sp)
	move.w	#8,-(sp)
	trap	#14
	add.l	#20,sp
	add.l	#512,pek
	rts
print_and_wait:
	move.l	a0,-(sp)	*print a message and wait for key
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts
filename:
 	dc.b	"f:\hokkfont.img"	*your filename
	even
handle:	dc.l	0			*some variables
no_sec:	dc.w	0	
trk:	dc.w	0
sec:	dc.w	0
pek:	dc.l	0
max_s:	dc.w	0
mega_text:	dc.b	$d,$a,"Insert the explorer disk+any key.",0
mega_text2:	dc.b	$d,$a,"Insert the destination disk+any key.",0
	even
super_info:
	ds.b	512
mega_buffer:				*you can define this if your 
					*computer crashes but mine
					*never does so I don't care about
					*that......