* QuikSet By Carl Sandy 10/5/90
* This program was written with HiSofts Devpac2
* The Resource file for Quikset was created with K-Resource2
gdos	MACRO
	move.w		#\1,-(a7)
	trap		#1
	lea		\2(a7),a7
	ENDM

	opt 		d-,x-
	OUTPUT		QUIKSET.ACC
	include		gemmacro.s
start	move.l		#mystack,a7		must have a stack!
	appl_init
	move.w		d0,ap_id		store the application id
	rsrc_load	#rscname		load resource file during boot up!
	rsrc_gaddr	#0,#0			get address of tree
	move.l		addr_out,form_addrs	save address of tree
	menu_register	ap_id,#mymenu		Install accessory
	bsr		setup_pointers

waitforevent
	evnt_mesag	#messagebuf
	move.l		#messagebuf,a0
	move.w		(a0),d0			message type
	cmp.w		#40,d0
	beq		open_acc
	bra.s		waitforevent

open_acc
	bsr		blank
	bsr		gettime
	bsr		getdate
	form_center	form_addrs
	movem.w		int_out+2,d1-d4
	movem.w		d1-d4,coords
	form_dial	#0,#0,#0,#0,#0,coords,coords+2,coords+4,coords+6
	objc_draw	form_addrs,#0,#2,coords,coords+2,coords+4,coords+6

loop	form_do		form_addrs,#3
	cmpi.w		#5,int_out
	beq		set
	cmpi.w		#6,int_out
	beq		cancel
	bra.s		loop

set	objc_change	form_addrs,int_out,#0,#0,#0,#0,#0,#1
	bsr		settime
	bsr		setdate
	form_dial	#3,#0,#0,#0,#0,coords,coords+2,coords+4,coords+6
	bra		waitforevent

cancel	objc_change	form_addrs,int_out,#0,#0,#0,#0,#0,#1
	form_dial	#3,#0,#0,#0,#0,coords,coords+2,coords+4,coords+6
	bra		waitforevent

* MISCELLANEOUS ROUTINES
atoi	clr.w		d0		d0=number
	clr.w		d1		d1=digit_value
	move.w		#1,d3
	move.l		in_addrs,a3
.loop	move.b		(a3)+,d1
	cmpi.b		#' ',d1
	beq.s		.exit
	cmpi.b		#'0',d1
	blt.s		.error
	cmpi.b		#'9',d1
	bgt.s		.error
	subi.b		#48,d1
	mulu.w		#10,d0
	add.w		d1,d0
	dbf		d3,.loop
.exit	move.w		d0,parm_out
.error	rts

itoa	move.l		value,d6
	move.l		#value_str,a5
.loop	divu.w		#10,d6
	swap		d6
	addi.w		#48,d6
	move.b		d6,(a5)+
	clr.w		d6
	swap		d6
	cmpi.w		#0,d6
	beq.s		.exit
	bra.s		.loop
.exit	clr.b		(a5)
	clr.w		d1
.leave	move.l		#value_str,a5	
	move.l		#value_str2,a6
	move.l		a5,a4
.loop1	cmpi.b		#0,(a4)
	beq.s		.exit1
	addq.w		#1,a4
	addq.w		#1,d1
	bra.s		.loop1
.exit1	clr.w		d0
	move.w		d1,d0
	adda.w		d1,a6
	clr.b		(a6)
.loop2	cmpi.b		#0,(a5)
	beq.s		.exit2
	move.b		(a5)+,-(a6)
	dbf		d0,.loop2
.exit2	rts

setup_pointers
	rsrc_gaddr	#8,#2
	move.l		addr_out,a3
	move.l		(a3),time_str		Get address of channel field
	rsrc_gaddr	#8,#3
	move.l		addr_out,a3
	move.l		(a3),date_str		Get address of voice number field
	rts

copy	cmpi.b		#0,(a5)
	beq.s		.exit
	move.b		(a5)+,(a6)+
	bra.s		copy
.exit	rts

blank	move.l		time_str,a3
	move.l		#3,d1
.loop	move.b		#' ',(a3)+
	dbf		d1,.loop
	move.w		#5,d1
	move.l		date_str,a3
.loop1	move.b		#' ',(a3)+
	dbf		d1,.loop1
	rts

getdate	gdos		$2A,2			Get system date
	move.w		d0,date
	moveq.w		#11,d2
	lsl.w		d2,d0
	moveq.w		#11,d2
	lsr.w		d2,d0	
	move.w		d0,day			Exstract day
	move.w		date,d0
	moveq.w		#9,d2
	lsr.w		d2,d0
	add.w		#80,d0
	move.w		d0,year			Exstract month
	move.w		date,d0
	moveq.w		#7,d2
	lsl.w		d2,d0
	moveq.w		#12,d2
	lsr.w		d2,d0
	move.w		d0,month		Exstract month

	move.w		day,d0
	ext.l		d0
	move.l		d0,value
	bsr		itoa

	move.l		#value_str2,a5
	move.l		date_str,a6
	bsr		copy

	move.w		month,d0
	ext.l		d0
	move.l		d0,value
	bsr		itoa
	move.l		#value_str2,a5
	move.l		date_str,a6
	addq.l		#2,a6
	bsr		copy

	move.w		year,d0
	ext.l		d0
	move.l		d0,value
	bsr		itoa
	move.l		#value_str2,a5
	move.l		date_str,a6
	addq.l		#4,a6
	bsr		copy
	rts

gettime	gdos		$2C,2			Get system time
	clr.w		time
	move.w		d0,time			save time
	moveq.w		#11,d2
	lsr.w		d2,d0			extract time from
	move.w		d0,hours		time format
	clr.w		d0
	clr.l		d2
	move.w		time,d0
	moveq.w		#5,d2
	lsl.w		d2,d0
	moveq.w		#10,d2
	lsr.w		d2,d0			extract minutes
	move.w		d0,minutes		from time format

	move.w		hours,d0
	ext.l		d0
	move.l		d0,value
	bsr		itoa

	move.l		#value_str2,a5
	move.l		time_str,a6
	bsr		copy

	move.w		minutes,d0
	ext.l		d0
	move.l		d0,value
	bsr		itoa

	move.l		#value_str2,a5
	move.l		time_str,a6
	addq.l		#2,a6
	bsr		copy
	rts

setdate	move.l		date_str,in_addrs	Get ascii day string
	bsr		atoi			convert to integer
	cmpi.w		#31,parm_out		> 31 days ?
	bgt		loop			Yes, repeat input	
	move.w		parm_out,day
	move.l		date_str,a3		Get ascii month string
	addq.l		#2,a3
	move.l		a3,in_addrs
	bsr		atoi			convert to integer
	cmpi.w		#12,parm_out		> 12 months ?
	bgt		loop			Yes, repeat input	
	move.w		parm_out,month
	move.l		date_str,a3		Get ascii year string
	addq.l		#4,a3
	move.l		a3,in_addrs
	bsr		atoi			convert to integr
	subi.w		#80,parm_out		-80 for this century
	move.w		parm_out,year

	clr.w		d0
	moveq.w		#9,d2
	move.w		year,d0
	lsl.w		d2,d0
	move.w		d0,date			Set year
	clr.w		d0
	moveq.w		#5,d2
	move.w		month,d0
	lsl.w		d2,d0
	add.w		d0,date			Set month
	clr.w		d0
	add.w		day,d0
	add.w		d0,date			Set day
	move.w		date,-(a7)
	gdos		$2B,4			Call GEMDOS, to set system date
	rts

settime	move.l		time_str,in_addrs
	bsr		atoi			Convert ascii minutes to integer
	cmpi.w		#23,parm_out		> 23 hours ?
	bgt		loop			Yes, repeat input	
	move.w		parm_out,hours		Save hours!
	move.l		time_str,a3
	addq.w		#2,a3
	move.l		a3,in_addrs
	bsr		atoi			Convert ascii hours to integer
	cmpi.w		#59,parm_out		> 59 minutes ?
	bgt		loop			Yes, repeat input
	move.w		parm_out,minutes	Save minutes!

	clr.l		d0
	clr.w		time
	moveq.w		#11,d2
	move.w		hours,d0
	lsl.w		d2,d0
	move.w		d0,time			Set hours
	clr.l		d0
	move.w		minutes,d0
	moveq.w		#5,d2
	lsl.w		d2,d0
	add.w		d0,time			Set minutes
	move.w		time,-(a7)
	gdos		$2D,4			Call GEMDOS, to set system time
	rts

		SECTION	DATA
mymenu		dc.b	'  QuikSet',191,0
rscname		dc.b	'quikset.rsc',0

		SECTION	BSS
ap_id		ds.w 	1			Application id number
messagebuf	ds.b 	16			Message buffer
		ds.l	100			stack space
mystack		ds.w	1			(stacks go backwards)
form_addrs	ds.l	1			Address of tree
value		ds.l	1
in_addrs	ds.l	1			General purpose pointer
coords		ds.w	4			Co-ordinates of dialogue box
parm_out	ds.w	1			output parameters
time_str	ds.l	1			pointer to time string
date_str	ds.l	1			pointer to date string
time		ds.w	1
hours		ds.w	1
minutes		ds.w	1
date		ds.w	1
day		ds.w	1
month		ds.w	1
year		ds.w	1
value_str	ds.b	11			string for integer to ascii
value_str2	ds.b	11			string for integer to ascii

	IFEQ	__LK
	include	aeslib.s
	ENDC