;
; Music Equalizer Bars by JFB & Dazzer
;
; Disassembled by MUG U.K for pure nosiness !!
;

get_scr	MOVE.W	#3,-(A7)	; Get screen address into 'screen'
	TRAP	#14
	ADDQ.L	#2,A7
	MOVE.L	D0,screen
	ADDI.L	#$60E0,D0	; add 24800 to it to get 'screen1'
	MOVE.L	D0,screen1

	BSR	super	; supervisor mode
	BSR	mouseoff	; turn off mouse
	MOVE.B	#0,$484.W	; turn off key-click
	BSR	setscree	; set new screen address
	BSR	setpal	; store & set new palette

	move.l	#text,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp	

	BSR	musicon	; start music going
	MOVE.L	#rip,$4D6.W ; install music analyzer onto VBL

main	CMPI.B	#$39,$FFFC02 ; wait for space bar
	BNE.S	main	; not space bar - redo loop
	BRA	exit	; it is - so exit program
;
; Music Analyzer - installed on VBL
;
rip	MOVEQ	#0,D0
	MOVEQ	#$F,D1
	LEA	$FF8800,A3
	MOVE.B	#8,(A3)
	MOVE.B	(A3),D0
	AND.W	D1,D0
	MOVE.B	#1,(A3)
	MOVE.B	(A3),D1
	LSL.W	#8,D1
	MOVE.B	#0,(A3)
	MOVE.B	(A3),D1
	LEA	table(PC),A1
	ANDI.L	#$FF,D1
	LSL.W	#2,D1
	SUBA.L	D1,A1
	MOVE.W	2(A1),D5
	MOVEA.W	(A1),A1
	ADDA.L	screen1(PC),A1
	MOVEA.L	A1,A2
	ADDQ.W	#8,D0
L28C0C	OR.B	D5,(A1)
	OR.B	D5,2(A1)
	OR.B	D5,$A0(A2)
	OR.B	D5,$A2(A2)
	LEA	-$A0(A1),A1
	LEA	$A0(A2),A2
	DBF	D0,L28C0C
chanb	MOVEQ	#0,D0
	MOVEQ	#$F,D1
	MOVE.B	#9,(A3)
	MOVE.B	(A3),D0
	AND.W	D1,D0
	MOVE.B	#3,(A3)
	MOVE.B	(A3),D1
	LSL.W	#8,D1
	MOVE.B	#2,(A3)
	MOVE.B	(A3),D1
	LEA	table(PC),A1
	ANDI.L	#$FF,D1
	LSL.W	#2,D1
	SUBA.L	D1,A1
found2	MOVE.W	2(A1),D5
	MOVEA.W	(A1),A1
	ADDA.L	screen1(PC),A1
two	MOVEA.L	A1,A2
	ADDQ.W	#8,D0
L28C5C	OR.B	D5,(A1)
	OR.B	D5,$A0(A2)
	LEA	-$A0(A1),A1
	LEA	$A0(A2),A2
	DBF	D0,L28C5C
chanc	MOVEQ	#0,D0
	MOVEQ	#$F,D1
	MOVE.B	#$A,(A3)
	MOVE.B	(A3),D0
	AND.W	D1,D0
	MOVE.B	#5,(A3)
	MOVE.B	(A3),D1
	LSL.W	#8,D1
	MOVE.B	#4,(A3)
	MOVE.B	(A3),D1
	LEA	table(PC),A1
	ANDI.L	#$FF,D1
	LSL.W	#2,D1
	SUBA.L	D1,A1
found3	MOVE.W	2(A1),D5
	MOVEA.W	(A1),A1
	ADDA.L	screen1(PC),A1
three	MOVEA.L	A1,A2
	ADDQ.W	#8,D0
L28CA4	OR.B	D5,2(A1)
	OR.B	D5,$A2(A2)
	LEA	-$A0(A1),A1
	LEA	$A0(A2),A2
	DBF	D0,L28CA4
decay	MOVEQ	#$1F,D0
	MOVEA.L	screen1(PC),A0
	MOVEA.L	A0,A1
L28CC0	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	DBF	D0,L28CC0
	RTS

exit	CLR.L	$4D6.W
	CLR.L	$4D2.W

offmusic	LEA	$FF8800,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)
	BSR	mouseon
	MOVE.B	#6,$484.W
	MOVEM.L	oldpal,D0-D7
	MOVEM.L	D0-D7,$FF8240

user	MOVE.L	#oldsp,-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	CLR.W	-(A7)
	TRAP	#1

setscree	MOVE.W	#0,-(A7)
	MOVE.L	screen,-(A7)
	MOVE.L	screen,-(A7)
	MOVE.W	#5,-(A7)
	TRAP	#14
	ADDA.L	#$C,A7
	RTS

setpal	MOVEM.L	$FF8240,D0-D7
	MOVEM.L	D0-D7,oldpal
	MOVEM.L	cols,D0-D7
	MOVEM.L	D0-D7,$FF8240
	RTS

super	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,oldsp
	RTS

vsync	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$25,-(A7)
	TRAP	#14
	ADDQ.L	#2,A7
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

mouseoff	MOVE.L	#moff,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$19,-(A7)
	TRAP	#14
	ADDQ.L	#8,A7
	DC.W	$A00A
	RTS

mouseon	MOVE.L	#mon,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$19,-(A7)
	TRAP	#14
	ADDQ.L	#8,A7
	DC.W	$A009
	RTS

moff	DC.W	$1212
	
mon	DC.W	$0808

musicon	MOVE.L 	#tune_no,D0
	JSR	muz
	MOVE.L	#play,$4D2.W
	RTS

tune_no	equ	1
vbl	equ	8

play	movem.l	d0-d7/a0-a6,-(a7)
	jsr	muz+vbl
	movem.l	(a7)+,d0-d7/a0-a6
	rts

noise_ta	DC.B	0,0,0,$80,0,0,0,$40
	DC.B	0,0,0,$20,0,0,0,$10
	DC.B	0,0,0,8,0,0,0,4
	DC.B	0,0,0,2,0,0,0,1
	DC.B	0,1,0,$80,0,1,0,$40
	DC.B	0,1,0,$20,0,1,0,$10
	DC.B	0,1,0,8,0,1,0,4
	DC.B	0,1,0,2,0,1,0,1
	DC.B	0,8,0,$80,0,8,0,$40
	DC.B	0,8,0,$20,0,8,0,$10
	DC.B	0,8,0,8,0,8,0,4
	DC.B	0,8,0,2,0,8,0,1
	DC.B	0,9,0,$80,0,9,0,$40
	DC.B	0,9,0,$20,0,9,0,$10
	DC.B	0,9,0,8,0,9,0,4
	DC.B	0,9,0,2,0,9,0,1
	DC.B	0,$10,0,$80,0,$10,0,$40
	DC.B	0,$10,0,$20,0,$10,0,$10
	DC.B	0,$10,0,8,0,$10,0,4
	DC.B	0,$10,0,2,0,$10,0,1
	DC.B	0,$11,0,$80,0,$11,0,$40
	DC.B	0,$11,0,$20,0,$11,0,$10
	DC.B	0,$11,0,8,0,$11,0,4
	DC.B	0,$11,0,2,0,$11,0,1
	DC.B	0,$18,0,$80,0,$18,0,$40
	DC.B	0,$18,0,$20,0,$18,0,$10
	DC.B	0,$18,0,8,0,$18,0,4
	DC.B	0,$18,0,2,0,$18,0,1
	DC.B	0,$19,0,$80,0,$19,0,$40
	DC.B	0,$19,0,$20,0,$19,0,$10
	DC.B	0,$19,0,8,0,$19,0,4
	DC.B	0,$19,0,2,0,$19,0,1
	DC.B	0,$20,0,$80,0,$20,0,$40
	DC.B	0,$20,0,$20,0,$20,0,$10
	DC.B	0,$20,0,8,0,$20,0,4
	DC.B	0,$20,0,2,0,$20,0,1
	DC.B	0,$21,0,$80,0,$21,0,$40
	DC.B	0,$21,0,$20,0,$21,0,$10
	DC.B	0,$21,0,8,0,$21,0,4
	DC.B	0,$21,0,2,0,$21,0,1
	DC.B	0,$28,0,$80,0,$28,0,$40
	DC.B	0,$28,0,$20,0,$28,0,$10
	DC.B	0,$28,0,8,0,$28,0,4
	DC.B	0,$28,0,2,0,$28,0,1
	DC.B	0,$29,0,$80,0,$29,0,$40
	DC.B	0,$29,0,$20,0,$29,0,$10
	DC.B	0,$29,0,8,0,$29,0,4
	DC.B	0,$29,0,2,0,$29,0,1
	DC.B	0,$30,0,$80,0,$30,0,$40
	DC.B	0,$30,0,$20,0,$30,0,$10
	DC.B	0,$30,0,8,0,$30,0,4
	DC.B	0,$30,0,2,0,$30,0,1
	DC.B	0,$31,0,$80,0,$31,0,$40
	DC.B	0,$31,0,$20,0,$31,0,$10
	DC.B	0,$31,0,8,0,$31,0,4
	DC.B	0,$31,0,2,0,$31,0,1
	DC.B	0,$38,0,$80,0,$38,0,$40
	DC.B	0,$38,0,$20,0,$38,0,$10
	DC.B	0,$38,0,8,0,$38,0,4
	DC.B	0,$38,0,2,0,$38,0,1
	DC.B	0,$39,0,$80,0,$39,0,$40
	DC.B	0,$39,0,$20,0,$39,0,$10
	DC.B	0,$39,0,8,0,$39,0,4
	DC.B	0,$39,0,2,0,$39,0,1
	DC.B	0,$40,0,$80,0,$40,0,$40
	DC.B	0,$40,0,$20,0,$40,0,$10
	DC.B	0,$40,0,8,0,$40,0,4
	DC.B	0,$40,0,2,0,$40,0,1
	DC.B	0,$41,0,$80,0,$41,0,$40
	DC.B	0,$41,0,$20,0,$41,0,$10
	DC.B	0,$41,0,8,0,$41,0,4
	DC.B	0,$41,0,2,0,$41,0,1
	DC.B	0,$48,0,$80,0,$48,0,$40
	DC.B	0,$48,0,$20,0,$48,0,$10
	DC.B	0,$48,0,8,0,$48,0,4
	DC.B	0,$48,0,2,0,$48,0,1
	DC.B	0,$49,0,$80,0,$49,0,$40
	DC.B	0,$49,0,$20,0,$49,0,$10
	DC.B	0,$49,0,8,0,$49,0,4
	DC.B	0,$49,0,2,0,$49,0,1
	DC.B	0,$50,0,$80,0,$50,0,$40
	DC.B	0,$50,0,$20,0,$50,0,$10
	DC.B	0,$50,0,8,0,$50,0,4
	DC.B	0,$50,0,2,0,$50,0,1
	DC.B	0,$51,0,$80,0,$51,0,$40
	DC.B	0,$51,0,$20,0,$51,0,$10
	DC.B	0,$51,0,8,0,$51,0,4
	DC.B	0,$51,0,2,0,$51,0,1
	DC.B	0,$58,0,$80,0,$58,0,$40
	DC.B	0,$58,0,$20,0,$58,0,$10
	DC.B	0,$58,0,8,0,$58,0,4
	DC.B	0,$58,0,2,0,$58,0,1
	DC.B	0,$59,0,$80,0,$59,0,$40
	DC.B	0,$59,0,$20,0,$59,0,$10
	DC.B	0,$59,0,8,0,$59,0,4
	DC.B	0,$59,0,2,0,$59,0,1
	DC.B	0,$60,0,$80,0,$60,0,$40
	DC.B	0,$60,0,$20,0,$60,0,$10
	DC.B	0,$60,0,8,0,$60,0,4
	DC.B	0,$60,0,2,0,$60,0,1
	DC.B	0,$61,0,$80,0,$61,0,$40
	DC.B	0,$61,0,$20,0,$61,0,$10
	DC.B	0,$61,0,8,0,$61,0,4
	DC.B	0,$61,0,2,0,$61,0,1
	DC.B	0,$68,0,$80,0,$68,0,$40
	DC.B	0,$68,0,$20,0,$68,0,$10
	DC.B	0,$68,0,8,0,$68,0,4
	DC.B	0,$68,0,2,0,$68,0,1
	DC.B	0,$69,0,$80,0,$69,0,$40
	DC.B	0,$69,0,$20,0,$69,0,$10
	DC.B	0,$69,0,8,0,$69,0,4
	DC.B	0,$69,0,2,0,$69,0,1
	DC.B	0,$70,0,$80,0,$70,0,$40
	DC.B	0,$70,0,$20,0,$70,0,$10
	DC.B	0,$70,0,8,0,$70,0,4
	DC.B	0,$70,0,2,0,$70,0,1
	DC.B	0,$71,0,$80,0,$71,0,$40
	DC.B	0,$71,0,$20,0,$71,0,$10
	DC.B	0,$71,0,8,0,$71,0,4
	DC.B	0,$71,0,2,0,$71,0,1
	DC.B	0,$78,0,$80,0,$78,0,$40
	DC.B	0,$78,0,$20,0,$78,0,$10
	DC.B	0,$78,0,8,0,$78,0,4
	DC.B	0,$78,0,2,0,$78,0,1
	DC.B	0,$79,0,$80,0,$79,0,$40
	DC.B	0,$79,0,$20,0,$79,0,$10
	DC.B	0,$79,0,8,0,$79,0,4
	DC.B	0,$79,0,2,0,$79,0,1
	DC.B	0,$80,0,$80,0,$80,0,$40
	DC.B	0,$80,0,$20,0,$80,0,$10
	DC.B	0,$80,0,8,0,$80,0,4
	DC.B	0,$80,0,2,0,$80,0,1
	DC.B	0,$81,0,$80,0,$81,0,$40
	DC.B	0,$81,0,$20,0,$81,0,$10
	DC.B	0,$81,0,8,0,$81,0,4
	DC.B	0,$81,0,2,0,$81,0,1
	DC.B	0,$88,0,$80,0,$88,0,$40
	DC.B	0,$88,0,$20,0,$88,0,$10
	DC.B	0,$88,0,8,0,$88,0,4
	DC.B	0,$88,0,2,0,$88,0,1
	DC.B	0,$89,0,$80,0,$89,0,$40
	DC.B	0,$89,0,$20,0,$89,0,$10
	DC.B	0,$89,0,8,0,$89,0,4
	DC.B	0,$89,0,2,0,$89,0,1

table	DC.L	0
screen1	DC.L	0
screen	DC.L	0
oldpal	DS.W	16
oldsp	DC.L	0
cols	DC.W	$000,$700,$070,$007,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$777

text	dc.b	27,"E"
	dc.b 	"  +----------------------------------+",$d,$a
	dc.b	"  | MUG U.K",$bf," presents: Killing Cloud |",$d,$a
	dc.b	"  +----------------------------------+",$d,$a,$a
	dc.b	"Thanks go to the Ultimate Ripper cart. ",$d,$a
	dc.b	"for making this job ten times easier - ",$d,$a
	dc.b	"even though it over-rips the files when",$d,$a
	dc.b	"you use the built-in music ripper !!",$d,$a,$a
	dc.b	"    Quartet Music by David Whittaker",$d,$a
	dc.b	"       Chip-Music Analyzer by JFB",$d,$a
	dc.b	"      All music hacks by: MUG U.K",$bf,$d,$a,$a,$a
	dc.b	"    Press any key to start the music.",$d,$a
	dc.b	0
;
; Any music file (data) can go here - ensure that the correct VBL
; offset is used (eg. Mad Max = +8, David. W = +14, Count Zero = +2)
;
muz	incbin	"great2.max"