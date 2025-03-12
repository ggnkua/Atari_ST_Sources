xykbind set modkbind
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	moveq	#15,d0

	dcb	2,$4e71

lo3464:
	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	87,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo3464

	dcb	4,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a0
	moveq	#32,d1
	move.b	(a0),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a0),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+xykbind
xykbind set xykbind+2

	dcb	38,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	moveq	#15,d0

	dcb	2,$4e71

lo7441:
	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	87,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo7441

	dcb	4,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a0
	moveq	#32,d1
	move.b	(a0),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a0),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+xykbind
xykbind set xykbind+2

	dcb	38,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	moveq	#15,d0

	dcb	2,$4e71

lo5648:
	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	87,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo5648

	dcb	4,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a0
	moveq	#32,d1
	move.b	(a0),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a0),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+xykbind
xykbind set xykbind+2

	dcb	38,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	moveq	#15,d0

	dcb	2,$4e71

lo4613:
	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	87,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo4613

	dcb	4,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a0
	moveq	#32,d1
	move.b	(a0),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a0),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+xykbind
xykbind set xykbind+2

	dcb	38,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	moveq	#16,d0

	dcb	2,$4e71

lo7845:
	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	87,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo7845

	dcb	4,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	moveq	#0,d3
	lea	$ffff8209.w,a0
	moveq	#32,d1
	move.b	(a0),d0
	and.w	#$1f,d0
	sub.w	d0,d1
	lsl.l	d1,d1

	move.b	$fffffc02.w,d3
	moveq	#32,d1
	move.b	(a0),d2
	and.w	#$1f,d2
	sub.w	d2,d1
	lsl.l	d1,d1

	lsl.l	d0,d1

	move.w	d3,key_buf+xykbind
xykbind set xykbind+2

	dcb	38,$4e71
	move.b	#0,$ffff820a.w
	dcb	12,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	dcb	83,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	moveq	#13,d0

	dcb	2,$4e71

lo4511:
	dcb	5,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	87,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dbf	d0,lo4511
	dcb	4,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	dcb	87,$4e71
	move.b	#0,$ffff820a.w
	dcb	12,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb	9,$4e71
	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	dcb	79,$4e71
	rts

