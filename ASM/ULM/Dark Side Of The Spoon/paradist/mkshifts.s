parallax	equ	0
parallay	equ	0
bus		equ	10
digitest	equ	10
def_version	equ	10
d0_for_mcp	equ	0
mcp_adr		equ	$500
keyboard	set	10
test	equ	10
calc_mdist	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d3-d6
	ENDM
do_mdist	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d3/d4/d5,$ffff8250.w
 	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	move.l	d6,$ffff825c.w	
	ENDM
calc_mdist2	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d4-d6/a2
	ENDM
do_mdist2	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d4/d5/d6,$ffff8250.w
 	move.b	#2,$ffff8260.w	
	move.b	#0,$ffff8260.w
	move.l	a2,$ffff825c.w	
	ENDM
calc_mdist02	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d2/d4-d6
	ENDM
do_mdist02	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	d2/d4/d5,$ffff8250.w
 	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.l	d6,$ffff825c.w
	ENDM
digi1	MACRO
	moveq	#-1,d6		;~1
	move.b	(a6),d6		;~2
	add.w	d6,d6		;~1
	add.w	(a7,d6),d7	;~4
	andi.w	#$ff*4,d7	;~2
	move.l	(a7,d7),d6
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7
	ENDM
digi2	MACRO
	moveq	#-1,d6		;~1
	move.b	(a6)+,d6	;~2
	add.w	d6,d6		;~1
	add.w	2(a7,d6),d7	;~4
	andi.w	#$ff*4,d7	;~2
	move.l	(a7,d7),d6	;~5
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7
	ENDM
d_0	equr	d0
d_1	equr	d1
d_2	equr	d2
d_3	equr	d3
a_1	equr	a1
downthere	equ	$600
x:
y:
