*	Created by TT-Digger vv6.1
*	Fri Sep 10 03:52:54 1999

*	TTD_6.1

*	TEXT	$00002A bytes, segment starts at L00+$0
*	DATA	$000000 bytes
*	BSS	$000000 bytes
*	SYMBOLS	$000000 bytes
*	FLAG	$0000


* RA_SYS names start
 include RA_SYS.I
* RA_SYS names end
	TEXT

	clr 	-(a7)
	pea 	$FFFFFFFF.w
	pea 	$FFFFFFFF.w
	move 	#$0005,-(a7)	; Setscreen
	trap	#14		; Xbios
	lea 	$000C(a7),a7
	move 	#$0025,-(a7)	; Vsync
	trap	#14		; Xbios
	addq 	#2,a7
	move 	#$0025,-(a7)	; Vsync
	trap	#14		; Xbios
	addq 	#2,a7
	move 	#$0000,-(a7)	; Pterm0
	trap	#1		; Gemdos

U2A:
	end	
