*
*  .TN? Decompator, converted from GFA to Devpac by Mr. Nice Guy!
* Original in ST World article, sorry but I forgot the name of the author.
*

	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,logbase

* Set screen resolution to low or medium
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,d7	screen resolution
	lea	tiny,a6
	move.b	(a6),d0	picture resolution
	move.b	d0,res	Store for future use
	cmp.b	#2,d0	is picture meant for monochrome
	beq	mono	in that case special routine
	cmp.b	#2,d7	is screen monochrome then
	beq	exit_imposs
	move.w	d0,-(sp)	otherwise set the correct resolution
	pea	-1	don't change the screens
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	bra	continue	with decompacting the screen
mono	cmp.w	#2,d7	check is the picture is for other resolution
	bne	exit_imposs
continue
* Get size and position of Control & Data bytes
* a6 = a%
	cmp.b	#2,res
	bgt	color_cyc
	moveq	#0,d0
	move.b	33(a6),d0
	lsl.w	#8,d0
	move.b	34(a6),d0
	move.w	d0,c_bytes
	move.b	35(a6),d0
	lsl.w	#8,d0
	move.b	36(a6),d0
	move.w	d0,d_words

	move.l	a6,d0
	addq.l	#1,d0
	move.l	d0,pal
	move.l	a6,d0
	add.l	#37,d0
	move.l	d0,control
	bra	no_color
* Colour cycling picture
color_cyc
	move.b	37(a6),d0
	lsl.w	#8,d0
	move.b	38(a6),d0
	move.w	d0,c_bytes
	move.b	39(a6),d0
	lsl.w	#8,d0
	move.b	40(a6),d0
	move.w	d0,d_words

	move.l	a6,d0
	addq.l	#5,d0
	move.l	d0,pal
	move.l	a6,d0
	add.l	#41,d0
	move.l	d0,control
no_color
	move.l	control,a0
	add.w	c_bytes,a0
	move.l	a0,data

* Copy palette bytes into array

	move.l	#palette,a0
	move.l	pal,a1
	moveq	#14,d0
non	move.b	(a1)+,d1
	lsl.w	#8,d1
	move.b	(a1)+,d1
	move.w	d1,(a0)+
	dbra	d0,non

* Set palette
	move.l	#palette,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	moveq.l	#0,d4
	move.l	d4,a2
	move.w	#1,d3
	moveq.l	#0,d2
	move.l	d4,a3
	move.l	logbase,a6

repeat	bsr	get_control
	cmp.w	#0,d7
	beq	case0
	cmp.w	#1,d7
	beq	case1
	cmp.w	#2,d7
	blt	no2
	cmp.w	#128,d7
	blt	case2to127
no2	cmp.w	#129,d7
	blt	no128
	cmp.w	#256,d7
	blt	case128to255
no128	bra	endselect
case0
*  Repeat next data word (128 to 32767) d6 times
	bsr	get_control
	move.l	d7,d6
	lsl.l	#8,d6
	bsr	get_control
	add.l	d7,d6
	bsr	get_data
	subq.w	#1,d6
forn1	move.w	d5,(a6)
	bsr	next_scr_word
	dbra	d6,forn1
	bra	endselect
case1
*  Get (128 to 32767) d6 words of unique data
	bsr	get_control
	move.l	d7,d6
	lsl.w	#8,d6
	bsr	get_control
	add.l	d7,d6
	subq.l	#1,d6
forn2  	bsr	get_data
	move.w	d5,(a6)
	bsr	next_scr_word
	dbra	d6,forn2
	bra	endselect
case2to127
* Get 1 word of data and repeat (1 to 127) d7 times
	move.l	d7,d6
	bsr	get_data
	subq.w	#1,d6
forn3	move.w	d5,(a6)
	bsr	next_scr_word
	dbra	d6,forn3
	bra	endselect
case128to255
* Get (1 to 127) words of unique data
	move.w	#255,d6
 	sub.w	d7,d6
forn4  	bsr	get_data
	move.w	d5,(a6)
	bsr	next_scr_word
	dbra	d6,forn4

endselect	move.w	a3,d0
	move.w	c_bytes,d1
	cmp.w	d0,d1
	bne	repeat

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
exit_imposs
	clr.w	-(sp)
	trap	#1

get_control
	moveq	#0,d7
	move.l	control,a0
	move.b	(a0),d7
	add.l	#1,control
	add.w	#1,a3
	rts

get_data	moveq	#0,d5
	move.l	data,a1
	move.b	(a1),d5
	lsl.w	#8,d5
	move.b	1(a1),d5
	add.l	#2,data
	rts

next_scr_word
	add.w	#2,d2
	add.w	#1,d3
	cmp.w	#201,d3
	bne	else
	move.w	#1,d3
	add.w	#1,d4
	cmp.w	#20,d4
	bne	endif1
	moveq.l	#0,d4
	add.w	#2,a2
endif1	move.l	logbase,a6
	move.l	d4,d0
	lsl.w	#3,d0
	add.w	d0,a6
	add.w	a2,a6
else	lea	160(a6),a6
endif	rts

logbase	ds.l	1
pal	ds.l	1
data	ds.l	1
control	ds.l	1

palette	ds.w	16

c_bytes	ds.w	1
d_words	ds.w	1
res	ds.b	1


	even

tiny	incbin	*.tn?
