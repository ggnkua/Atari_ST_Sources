
*************************************************************************
*	NEW PRINT TITLES ROUT - NOW MASKS TO KEEP 16 COLOUR PIC		*
*									*
* Revision:	1.1							*
* Date:		6/9/92							*
* By:		MSD 							*
*									*
* More comments added to allow others to understand			*
*									*
*************************************************************************
*
* Now is fully masking to give black line around letters.
*
* Here is a little option to allow you to print the titles in any colour
* simply enable the planes you require..
*
* If you disable them all the titles will be colour 0


ENABLE_PLANE1	equ	yes
ENABLE_PLANE2	equ	yes
ENABLE_PLANE3	equ	yes
ENABLE_PLANE4	equ	yes

COLOUR0		equ	ENABLE_PLANE1+ENABLE_PLANE2+ENABLE_PLANE3+ENABLE_PLANE4

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*30,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2
		lea	screen_titles_font+(60*9),a3

		move.w	#16-1,d0	;max titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#9,d1		;chars are 9 bytes each

BYTE_OFF	set	0
LINE_OFF	set	0

		REPT	9
		move.b	BYTE_OFF(a2,d1.w),d5	;get char
		move.b	BYTE_OFF(a3,d1.w),d3	;get char mask

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ELSE	
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+0(a0),d4	;1st plane
		and.b	d3,d4			;and mask with scrn data
		or.b	d5,d4			;or char data into mask
		move.b	d4,LINE_OFF+0(a0)	;poke data back to scrn
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+2(a0),d4	;2nd plane
		and.b	d3,d4			;use same mask calculated previously
		or.b	d5,d4
		move.b	d4,LINE_OFF+2(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+4(a0),d4	;3rd plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+4(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+6(a0),d4	;4th plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+6(a0)
		ENDC
		ENDC


BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR


BYTE_OFF	set	0
LINE_OFF	set	0
		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#9,d1		;chars are 8 bytes each

		REPT	9
		move.b	BYTE_OFF(a2,d1.w),d5
		move.b	BYTE_OFF(a3,d1.w),d3

		IFEQ	COLOUR0
		not.b	d5
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ELSE
		IFNE	ENABLE_PLANE1
		move.b	LINE_OFF+1(a0),d4	;1st plane
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+1(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ELSE
		IFNE	ENABLE_PLANE2
		move.b	LINE_OFF+3(a0),d4	;2nd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+3(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ELSE
		IFNE	ENABLE_PLANE3
		move.b	LINE_OFF+5(a0),d4	;3rd
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+5(a0)
		ENDC
		ENDC

		IFEQ	COLOUR0
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ELSE
		IFNE	ENABLE_PLANE4
		move.b	LINE_OFF+7(a0),d4	;4th
		and.b	d3,d4
		or.b	d5,d4
		move.b	d4,LINE_OFF+7(a0)
		ENDC
		ENDC

BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR

		addq.w	#8,a0

		dbf	d6,.loop2
		lea	160*10(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts


screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"        EXCELLENT COMPILATION 29        "
	dc.b	"                                        "
	dc.b	"        1: ASTEROIDS                    "
	dc.b	"        2:                              "
	dc.b	"        3:                              "
	dc.b	"        4:                              "
	dc.b	"        5:                              "
	dc.b	"        6:                              "
	dc.b	"        7:                              "
	dc.b	"        8:                              "
	dc.b	"              0: 50/60 HZ               "
	even

screen_titles_font
 dc.l	0,0,$1E1E,$1E1E001E,$1E000014,$14000000,0,$93F1212,$7F242400,$1C2A28
 dc.l	$1C0A2A1C,$113A,$1204050B,$100003C,$62386266,$663C0000,$C0C0000,0
 dc.l	$60C0C,$C0C0C06,$180C,$C0C0C0C,$18000000,$10543854,$10000000,$8083E
 dc.l	$8080000,0,$81800,0,$3C0000,0,$C,$C000000,$2040408,$8100000
 dc.l	$3C7E66,$66667E3C,$1838,$18181818,$1800003C,$7E060C18,$3E7E0000,$7E0C181C
 dc.l	$6463C00,$E1626,$467F0606,$7E60,$7C06467E,$3C00003C,$607C6666,$7E3C0000
 dc.l	$7E7E060C,$18181800,$3C7E66,$3C667E3C,$3C7E,$66663E06,$3C000000,$C0C000C
 dc.l	$C000000,$C0C00,$C0C1800,$60C18,$30180C06,$3F,$3F003F3F,$18
 dc.l	$C060306,$C180000,$3C460C18,$18001800,$3C425E,$725C403E,$3C7E,$667E7E66
 dc.l	$6600007C,$7E667C66,$7E7C0000,$3C7E6660,$667E3C00,$7C7E66,$66667E7C,$7E7E
 dc.l	$607C607E,$7E00007E,$7E607C7C,$60600000,$3C7E606E,$667E3C00
 dc.l	$66667E,$7E7E6666,$1818,$18181818,$18000006,$6060666,$7E3C0000,$666C7870
 dc.l	$786C6600,$606060,$60607E7E,$6377,$7F7F6B63,$63000066,$767E7E6E,$66660000
 dc.l	$3C7E6666,$667E3C00,$7C7E66,$667C6060,$3C7E,$6666666C,$3600007C,$7E667C7E
 dc.l	$66660000,$3C7E3018,$C7E3C00,$7E7E18,$18181818,$6666,$6666667E,$3C000066
 dc.l	$66666666,$7C780000,$5A5A5A5A,$5A7E7C00,$666666,$3C666666,$6666,$663C1818
 dc.l	$1800007E,$7E0C1830,$7E7E0000,0,0,$FFFFFFFF,$FFFFFFFF,$FFC0C0C0
 dc.l	$C0C0C0C0,$C0C0C1C1,$C1C1FFFF,$FFFFFFE0,$80808000,$8181,$C1808080,$80808080
 dc.l	$C1C48080,$80C0E0E0,$E0FC8100,0,$81E1,$E1E1E1FF,$FFFFFFFF,$F0E0E0E1
 dc.l	$E1E1E0E0,$F0C3C1C1,$E1E1E1C1,$C1C3FFC7,$1010101,$1C7FFFF
 dc.l	$E3E38080,$80E3E3FF,$FFFFFFFF,$E3C3C3C3,$FFFFFFFF,$818181FF
 dc.l	$FFFFFFFF,$FFFFE1E1,$E1E1FFF8,$F0F0E1E1,$C3C3C7FF,$81000000
 dc.l	0,$81C38383,$83C3C3C3,$C3C38100,$C080,0,$C1C0,$81,$E0C08000,$F0
 dc.l	$F0000000,0,$818101,$1000000,$8100,$C0,$C1C3C3C3,$81000000
 dc.l	0,$81810000,$80,$8081FFE1,$E1E1E1E1,$E1E1FFFF,$E1E1E1E1,$E1C1C1C3
 dc.l	$F0E0C081,$8381C0E0,$F0FF8080,$80808080,$80FFC3C1,$C0E0F0E0
 dc.l	$C0C1C381,$C1,$C3C3C3C3,$81000000,0,$80810000,0,$100,0,$181,0,$81
 dc.l	$1000000,0,$1000000,$10000,0,$101,$10F0F81,0,$81,0,0,$C3C3C3
 dc.l	$C3C3C3C3,$C3C3F0F0,$F0F00000,$8100,$103,$1000000,$F0F0F0F,$F000000
 dc.l	$80000,0,$8080000,0,$81,0,$81,$1000000,$10F,$F810000,0,$800100
 dc.l	0,$81,$81,$81,0,$C3C3C3C3,$C3000000,0,$810000,0,$10300,0,1,0,0,0
 dc.l	$81C3,$C3C30000,$8100,$FF,$FFFFFFFF,$FFFFFFFF
