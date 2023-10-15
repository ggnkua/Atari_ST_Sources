*************************************************************************
*									*
*	-Clicksoff-		CLICK14.S				*
*=======================================================================*
*	Brian Duff							*
*	100494-033444-01.04						*
*-----------------------------------------------------------------------*
*	Specification:	Program must disable the key clicks (an AUTOPRG)*
*	Input(s):	N/A						*
*	Output(s):	N/A						*
*	Version 1.1:	Program created a bus error. Could not change	*
*			protected address when not in super mode.	*
*			?-XBIOS call required? Where's that manual?	*
*	Version 1.2:	Program terminates but doesn't work. I tried 	*
*			Using XBIOS 38, but it will not jump to doit	*
*			on the trap (even if I try 1 or 13). I'm sure	*
*			there is a GEMDOS routine called super(). I	*
*			will check this tommorow. Just now I'm going 	*
*			to sleep...zzzzz				*
*	Version 1.3:	OK. I got it! I just had the value for conterm	*
*			wrong. The definition I have is wrong...	*
*	Version 1.4:	I'm making it a little longer by adding a hello *
*************************************************************************

	SECTION TEXT
messag	move.l	#message,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

jmpspr	move.l	#doit,-(sp)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	clr.l	-(sp)
	trap	#1

doit	movea.l	#$484,a3
	move.b	#6,(a3)
	rts
	
message dc.b	27,'p  Clicksoff v1.4 by Brian Duff  '
	dc.b	13,10,27,'q   Key Clicks OFF!',0
	