* Ear you R young Lawz! Maybe Genesis Inc can menu your brilliant
* disk freespace program? Haw,haw,haw!

* By the way, I *THINK* this'll work with any number base, if you
* change the powers table! Neat, huh?

		move.l	#726016,d0		; decimal no. in d0!
		bsr	convert
		
		pea	store_dec
		move	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		
		move	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		
		clr.l	-(sp)
		trap	#1
		
convert
		lea	store_dec,a1
		lea	powers,a0		a0 points to powers of ten
		moveq.l	#6,d1			7 digits to move
reset_count
		moveq.l	#-1,d2			reset counter
count
		addq.b	#1,d2			add one to counter
		sub.l	(a0),d0			subtract power
		bcc	count			do again if no carry
		add.l	(a0)+,d0		carry occured so reset d0
ascii
		add.b	#48,d2			convert no, in d2 to ascii digit
		move.b	d2,(a1)+		store digit in alert string
		dbf	d1,reset_count		loop until 7 digits done
		rts
powers
		dc.l	1000000			10 to the 6
		dc.l	100000
		dc.l	10000
		dc.l	1000
		dc.l	100
		dc.l	10
		dc.l	1
		
store_dec	ds.b	7
		dc.b	0