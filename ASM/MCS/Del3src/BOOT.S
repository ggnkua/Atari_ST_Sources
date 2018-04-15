	;MOVE.W #1,-(A7)
	;MOVE.W #2,-(A7)
	;MOVE.L #-1,-(A7)
	;MOVE.L #BOOT,-(A7)
	;MOVE.W #$18,-(A7)
	;TRAP #14
	;ADD.L	#14,A7
	;CLR.L -(A7)
	;TRAP #1

BOOT	MOVE.W #6,-(A7)
	MOVE.W #1,-(A7)	* FACE 1
	MOVE.W #0,-(A7)
	MOVE.W #2,-(A7)
	MOVE.W #0,-(A7)
	CLR.L -(A7)
	MOVE.L	#$10000,-(A7)
	MOVE.W #8,-(A7)
	TRAP #14
	ADD.L #20,A7
	;MOVE.L #$BB00,$AA1F
	move.b	#$12,$fffc02
	bclr.b	#0,$484
	move.l	#0,$10
	JMP	$10000
 DC.B "Read the followings sector =>"
 ;dc.b 'Be careful because this demo contains a new protection.'
 ;dc.b 'Noone have cracked it.Those who tried have seen their drive '
 ;dc.b 'runnig so fast than it started to smoke.'
 ;dc.b 'Others have seen their monitor ended up.'
 ;dc.b 'And others cried when their 1040 ST back to a half-meg for ever.'
 ;dc.b 'GOOD LUCK       AH! AH! AH!'

