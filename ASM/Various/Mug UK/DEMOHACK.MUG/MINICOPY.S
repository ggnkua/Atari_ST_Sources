* Mini-copy v1.00
* copies from A to B!

		bra	hit_it
		
*---------------
no_tracks	dc.w	80		; no trax
sects		dc.w	10		; no sex (shame!)
rside		dc.w	0		; side 2 read
wside		dc.w	1		; side 2 write
*---------------

hit_it
		lea	buffer,a5
		move	no_tracks,d7
rtrax0
		move	d7,track
		bsr	read_track
		moveq.l	#0,d6
		move	sects,d6
		mulu	#512,d6
		add.l	d6,a5
		
		movem.l	d0-d7/a0-a6,-(sp)
		lea	str1,a1
		lea	hexs,a0
		move	track,d0
		and	#$f,d0
		move.b	(a0,d0.w),d7
		move.b	d7,1(a1)
		move	track,d0
		lsr	#4,d0
		and	#$f,d0
		move.b	(a0,d0.w),d7
		move.b	d7,(a1)
		pea	allstr1
		move	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-d7/a0-a6
		
		dbf	d7,rtrax0

*--------------- write disk side	
ws1
		lea	buffer,a5
		move	no_tracks,d7
wtrax0
		move	d7,track

		bsr	format_track
		
		bsr	write_track
		
		moveq.l	#0,d6
		move	sects,d6
		mulu	#512,d6
		add.l	d6,a5
		
		movem.l	d0-d7/a0-a6,-(sp)
		lea	str2,a1
		lea	hexs,a0
		move	track,d0
		and	#$f,d0
		move.b	(a0,d0.w),d7
		move.b	d7,1(a1)
		move	track,d0
		lsr	#4,d0
		and	#$f,d0
		move.b	(a0,d0.w),d7
		move.b	d7,(a1)
		pea	allstr2
		move	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-d7/a0-a6
		
		dbf	d7,wtrax0

		clr	-(sp)
		trap	#1

*--------------- read a track	a5-buffer
read_track
		move	sects,-(sp)
		move	rside,-(sp)
		move	track,-(sp)
		move	#1,-(sp)
		move	#0,-(sp)		; read drive
		clr.l	-(sp)
		move.l	a5,-(sp)
		move	#8,-(sp)
		trap	#14
		add.l	#20,sp
		rts
		
*--------------- write a track	a5-buffer
write_track
		move	sects,-(sp)
		move	wside,-(sp)
		move	track,-(sp)
		move	#1,-(sp)
		move	#1,-(sp)		; read drive
		clr.l	-(sp)
		move.l	a5,-(sp)
		move	#9,-(sp)
		trap	#14
		add.l	#20,sp
		rts

*--------------- format a track	
format_track
		move	#$0,-(sp)
		move.l	#$87654321,-(sp)
		move	#1,-(sp)
		move	wside,-(sp)
		move	track,-(sp)
		move	sects,-(sp)
		move	#1,-(sp)
		clr.l	-(sp)
		pea	space
		move	#10,-(sp)
		trap	#14
		add.l	#26,sp
		rts
*---------------
allstr1		dc.b	27,"Y  Reading track :"
str1		dc.b	"00",0
allstr2		dc.b	27,"Y  Writing track :"
str2		dc.b	"00",0
hexs		dc.b	"0123456789ABCDEF"
track		ds.w	1
space		ds.b	8192
buffer				