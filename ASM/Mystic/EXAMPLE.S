		OPT	C+

*****************************************************************
* EXAMPLE OF USING LTK'S MUSIX					*
*		Code by Mr SPIRIT and LTK 1st of December 1990.	*
*****************************************************************
* If you want to contact us or send donations then write to:	*
*              MYSTIC						*
*              Franck MARCHIS					*
*              32, Rue des Rosiers				*
*              F31140 Fonbeauzard				*
*              FRANCE						*
*****************************************************************

		SECTION TEXT

Begin		DC.W	$A00A
		clr.l	-(sp)			Supervisor mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,-(sp)		Keep user stack
		move.b	#$12,$FFFFFC02.w	Mouse off
		bclr	#5,$FFFFFA15.w		Timer C off
		move.b	$484.w,old_click
		clr.b	$484.w
		pea	text(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	#vbl,$4D2.w		Install VBL slot
		lea	musix(pc),a6
		move.w	#$FF00,(a6)		Start ($FF00+4*Song number)

		move.w	#7,-(sp)		Wait for keypress
		trap	#1
		addq.l	#2,sp

		move.w	#$FFFF,(a6)		Stop music and timer
wait_until_off	cmpi.w	#$FFFE,(a6)
		bne.s	wait_until_off
		clr.l	$4D2.w			Clear slot
		bset	#5,$FFFFFA15.w		Enable Timer C
		move.b	old_click(pc),$484.w
		move.b	#8,$FFFFFC02.w
		move.w	#$20,-(sp)		User stack already on stack
		trap	#1
		addq.l	#6,sp
		DC.W	$A009
		clr.w	-(sp)
		trap	#1

vbl		move.w	#$2700,sr		Sync with screen top
		lea	$FFFF8209.w,a0
		moveq	#15,d1
sync_start	move.b	(a0),d0
		beq.s	sync_start
		sub.w	d0,d1
		lsr.w	d1,d0
		move.w	#$700,$FFFF8240.w	Time measurement on
		bsr	musix+2			Call musix
		move.w	#$777,$FFFF8240.w	Time measurement off
		move.w	#$2300,sr
		rts

		SECTION DATA

musix		INCBIN	MYSTIC\LTKMUSIC.\PS*.SMB
text		DC.B	27,"E"
		DC.B	"***************************************",13,10
		DC.B	"*  Hello guy !                        *",13,10
		DC.B	"*  Just some few notes to help you... *",13,10
		DC.B	"*                ~~~                  *",13,10
		DC.B	"* LTK's musics like MADMAX'           *",13,10
		DC.B	"* are position independent.           *",13,10
		DC.B	"* It uses the registers d0-d4/a0-a3.  *",13,10
		DC.B	"* The first word is essential as it   *",13,10
		DC.B	"* enables to control musix or to read *",13,10
		DC.B	"* some information ...  Look at the   *",13,10
		DC.B	"* routine in ASCII for their meaning. *",13,10
		DC.B	"* Our demo will be finished in        *",13,10
		DC.B	"* FEBRUARY/MARCH so wait for more help*",13,10
		DC.B	"* or write to us !!                   *",13,10
		DC.B	"***************************************",13,10
		DC.B	"* Golden greetings to all our friends *",13,10
		DC.B	"* & good contacts: ATARI CLUB-VANTAGE *",13,10
		DC.B	"* BEETLEJUICE-DBUG II-NTM-MAXI-AYOROS *",13,10
		DC.B	"* CENTAURUS-SNAKE-LITTLE SWAP-RBOY-   *",13,10
		DC.B	"* NAR-PIXEL-PHIL-T.ORO-SYL-FLYTOX ... *",13,10
		DC.B	"***************************************",13,10
		DC.B	"* (C) MYSTIC 1st of DECEMBER 1990     *",13,10
		DC.B	"***************************************",13,10
		DC.B	"* MEGAFUCK to ULM especially The FATE *",13,10
		DC.B	"***************************************",0
old_click	DC.B	0
		EVEN

		END