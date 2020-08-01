*****************************************
*					*
*	TwentyOne.x 「とぅぇにぃわん」	*
*	patch for human Ver 2.02,2.03	*
*					*
*****************************************
*
*	file name:	options.s
*	author:		Ｅｘｔ (T.Kawamoto)
*	last modify:	92/3/1
*			92/3/17 thanks YUU(HARUKA)
*
blpeek:	macro
	moveq.l	#$84,d0
	trap	#15
	endm
*
getpdb:	macro
	dc.w	$ff51
	endm
*
	.xdef	_TwentyOneOptions
*
	.text
*
_TwentyOneOptions:
	movem.l	a0-a2,-(sp)
	bsr	search_memory_blindly
	tst.l	d0
	bne	return
	bsr	search_device_blindly
return:
	movem.l	(sp)+,a0-a2
	rts
*
search_device_blindly:
	lea	$00006800,a1
search_NUL_device_loop:
	cmp.l	#$00020000,a1
	bcc	sd_not_found
	blpeek
	cmp.l	#'NUL ',d0
	beq	found_NUL_device
*	lea	4(a1),a1			* 以下の要領より
						* ここでインクリメントする必要は
						* ありません	1992.03.17 YUU(HARUKA).
	cmp.w	#'NU',d0
	bne	search_NUL_device_loop
	lea	-2(a1),a1
	bra	search_NUL_device_loop
*
found_NUL_device:
*	lea	-14(a1),a1			* ← ここがおかしい
	lea	-18(a1),a1			* IOCS B_LPEEK の戻り値 a1
						* は d0 の値を取得したアドレス + 4
						* なので次のデバイスへのアドレスは
						* -18(a1) となります	1992.03.17 YUU.
search_device:
	blpeek
sd_loop:
	move.l	d0,a0
	lea	$000E(a0),a2
	bsr	check_TW
	tst.l	d0
	bne	sd_end
	lea.l	(a0),a1
	blpeek
	cmp.l	#$ffffffff,d0
	bne	sd_loop
sd_not_found:
	moveq.l	#0,d0
sd_end:
	rts
*
search_memory_blindly:
	getpdb
	move.l	d0,a1
	lea	-16(a1),a1
search_top_loop:
	lea	4(a1),a1
	blpeek
	tst.l	d0
	beq	found_top
	move.l	d0,a1
	bra	search_top_loop
*
found_top:
	lea	-8(a1),a1			* なぜかこの行がコメント行になっていました
*	lea	8(a1),a1			* 多分こっちがコメント行だと思います
						* 1992.03.17 YUU(HARUKA).
search_memory:
	lea	12(a1),a1
	blpeek
sm_loop:
	move.l	d0,a0
	lea	$010E(a0),a2
	bsr	check_TW
	tst.l	d0
	bne	sm_end
	lea	$000C(a0),a1
	blpeek
	tst.l	d0
	bne	sm_loop
	moveq.l	#0,d0
sm_end:
	rts
*
check_TW:
	lea	(a2),a1
	blpeek
	cmp.l	#'?Twe',d0
	beq	check_new
	cmp.l	#'*Twe',d0
	bne	check_error
check_old:
	lea	$0004(a2),a1
	blpeek
	cmp.l	#'nty*',d0
	bne	check_error
	moveq.l	#-1,d0
	rts
*
check_new:
	lea	$0004(a2),a1
	blpeek
	cmp.l	#'nty?',d0
	beq	check_new_E
	cmp.l	#'ntyE',d0
	bne	check_error
check_new_E:
	lea	$0008(a2),a1
	blpeek
	rts
*
check_error:
	moveq.l	#0,d0
	rts
*
	dc.b	'TwentyOne Option Checker Ver 1.00 '
	dc.b	'Copyright 1991,92 Ｅｘｔ (Ｔ.Ｋawamoto)',0
*
	.end
