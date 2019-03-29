		opt x+
*********************************************************
*							*
*          Memory Configuration Program v1.01		*
*							*
* 	 Coded by Eagle of Sentry on 18.1.1991		*
*		for the D.B.A. Magazine 3		*
*							*
*********************************************************

		pea	0.w		supervisor mode
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

		move.b	$ffff8001.w,d0	get memory configuration
		andi.w	#%1111,d0	only low nibble is needed
		move.w	d0,d1
		lsr.w	#2,d0		d0 is bank0 configuration
		andi.w	#%11,d1		d1 is bank1 configuration

		lea	memsize(pc),a0	table with banksizes
		lsl.w	#3,d0		offset in table
		lsl.w	#3,d1		offset in table
		move.l	(a0,d0),d7	d7 is memory top
		add.l	(a0,d1),d7
		lea	bank0(pc),a1	print banksize 0
		move.l	4(a0,d0),(a1)
		lea	bank1(pc),a1	print banksize 1
		move.l	4(a0,d1),(a1)

		cmp.l	$42e.w,d7	check phystop with oure calculation
		beq.s	mem_ok		everything is allright
		move.l	d7,$42e.w	install oure configuration
		move.l	4.w,a0		get reset-adres
		jmp	(a0)		force a reset to instal the whole
;					system
mem_ok		pea	text(pc)	print text-message
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#5*50,d7	wait till spacebar or 5 sec.
wait		move.w	#37,-(sp)	vsync=1/50 sec.
		trap	#14
		addq.l	#2,sp
		cmpi.b	#57,$fffffc02.w	spacebar?
		beq.s	exit		yes
		dbf	d7,wait
exit		pea	0.w		warm start
		trap	#1

	section data

memsize	dc.l	128*1024		; 128Kb
	dc.l	"128K"
	dc.l	512*1024		; 512Kb
	dc.l	"512K"
	dc.l	2048*1024		; 2Mb
	dc.l	"  2M"
	dc.l	4096*1024		; 4Mb Only TT
	dc.l	"  4M"

text	dc.b	13,10,"Memory Configuration Program v1.01",10,13
	dc.b	"Coded by Eagle of Sentry.",10,13,10
	dc.b	"Current memory status: ",10,13
	dc.b	"Bank 0:"
bank0	dc.b	"    b     Bank 1: "
bank1	dc.b	"    b",10,13,10,0
 