*****************************************************************
*	EXAMPLE OF						*
*    ROUTINE TO USE THE LTK's MUSIX				*
*								*
*			Code by Mr SPIRIT. 1st of December 1990	*
*								*
*****************************************************************

	SECTION TEXT

Begin		DC.W	$A00A
		clr.l	-(sp)		SUPERVISOR
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,userstack
		move.b	#$12,$FFFFFC02.w
		bclr	#5,$FFFFFA15.w
		move.b	$484.w,old_click
		clr.b	$484.w
		pea	text(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	#vbl,$4D2.w	VBL
		move.w	#$FF00,musix	Start song 0 ($FF00+4*Song number)

		move.w	#7,-(sp)	Wait...
		trap	#1
		addq.l	#2,sp

		move.w	#$FFFF,musix	SOFT-MUSIX STOP
		move.l	$466.w,d0
vsync		cmp.l	$466.w,d0
		beq.s	vsync
		clr.l	$4D2.w		STOP VBL
		bset	#5,$FFFFFA15.w
		move.b	old_click(pc),$484.w
		move.b	#8,$FFFFFC02.w
		move.l	userstack(pc),-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		DC.W	$A009

		clr.l	-(sp)
		trap	#1

vbl		move.w	#$2700,sr
		lea	$FFFF8209.w,a0
		moveq	#15,d1
sync_start	move.b	(a0),d0
		beq.s	sync_start
		sub.w	d0,d1
		lsr.w	d1,d0
		move.w	#$700,$FFFF8240.w
		bsr	musix+2		call Musix
		move.w	#$777,$FFFF8240.w
		move.w	#$2300,sr
		rts

	SECTION DATA

musix		INCBIN	COMPLETE.SMB

	EVEN
text		DC.B	27,'E'
		DC.B	'***************************************',$D,$A
		DC.B	'*  Hello guy !                        *',$D,$A
		DC.B	'*  Just some few notes to help you... *',$D,$A
		DC.B	'*                ~~~                  *',$D,$A
		DC.B	'* The LTK''s Musics like MADMAX''s ones *',$D,$A
		DC.B	'* are position independent.           *',$D,$A
		DC.B	'* It uses the registers d0-d4/a0-a3.  *',$D,$A
		DC.B	'* The first word is essential as it   *',$D,$A
		DC.B	'* enables to control musix or to read *',$D,$A
		DC.B	'* some information ...  Look at the   *',$D,$A
		DC.B	'* routine in ASCII for their meaning. *',$D,$A
		DC.B	'* Our demo will be finished in        *',$D,$A
		DC.B	'* FEBRUARY/MARCH so wait for more help*',$D,$A
		DC.B	'* or write to us !!                   *',$D,$A
		DC.B	'***************************************',$D,$A
		DC.B	'* Gold greetings for all our friends  *',$D,$A
		DC.B	'* or good contact: ATARI CLUB-VANTAGE *',$D,$A
		DC.B	'* BEETLEJUICE-DBUG II-NTM-MAXI-AYOROS *',$D,$A
		DC.B	'* CENTAURUS-SNAKE-LITTLE SWAP-RBOY-   *',$D,$A
		DC.B	'* NAR-PIXEL-PHIL-T.ORO-SYL-FLYTOX ... *',$D,$A
		DC.B	'***************************************',$D,$A
		DC.B	'* ',189,'  MYSTIC 1st of DECEMBER 1990      *',$D,$A 
		DC.B	'***************************************',$D,$A
		DC.B	0
**************************************************
* If you want to contact us or send donations    *
* then write to:				 *
*                  MYSTIC                        *
*              Franck MARCHIS                    *
*              32, Rue des rosiers               *
*              31140 FONBEAUZARD                 *
*                  FRANCE                        *
**************************************************
	SECTION	BSS

userstack	DS.L	1
old_click	DS.W	1

	END