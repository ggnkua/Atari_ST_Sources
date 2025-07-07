
* (simple) assembly-language test program for X-Debug Tutorial

* assembled using Devpac 2

	opt	x+			Extended debug
	
start	move.l	#hellotx,a0
	bsr	print
	
	move.l	#12345,d0
	bsr	print_num

	clr.w	-(sp)
	trap	#1
		

* print the number d0.w in decimal, unsigned
* leading zeros, just to make life easier
* (not a terribly efficient algorithm)

print_num
	subq.w	#6,sp				max 5 digits+null
	move.l	sp,a0				use temp buffer on stack
	
	divu	#10000,d0
	add.b	#'0',d0
	move.b	d0,(a0)+
	clr.w	d0
	swap	d0				get remainder

thousands
	divu	#1000,d0
	add.b	#'0',d0
	move.b	d0,(a0)+			and so on
	clr.w	d0
	swap	d0

hundreds
	divu	#100,d0
	add.b	#'0',d0
	move.b	d0,(a0)+			and on
	swap	d0
	
tens
	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,(a0)+
	clr.w	d0
	swap	d0

digits
	add.b	#'0',d0
	move.b	d0,(a0)+
	clr.b	(a0)				null term it
	move.l	sp,a0
	bsr	print				and print it
	addq.w	#6,sp
	rts
	

* print the message at a0
print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	rts

	DATA
hellotx	dc.b	'A simple program',13,10,0
