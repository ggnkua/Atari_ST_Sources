	bra	start
	
go	move.l	4(a7),a3		;Basepage in a3
	move.l	#nmgame,d0		;Code length
	sub.l	a3,d0			; + data length
	move.l	d0,-(a7)		;Length to save
	move.l	a3,-(a7)		; where to save from
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1			;Mshrink
	lea	12(a7),a7

	pea	null
	move.l	(a7),-(a7)
	move.l	nmgame,-(a7)
	clr.w	-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	lea	16(a7),a7
	
	clr.w	-(a7)
	trap	#1
	
	even
	
gamelst	dc.l	game1,game2
game1	dc.b	"a:\progs\revenge\revenge.prg",0    ;list all files here
game2	dc.b	"a:\dummy2.prg",0

null	dc.l	0
nmgame	ds.l	1


start	move.w	#4,-(a7)
	trap	#14			;Get res
	addq.l	#2,a7
	cmp.w	#2,d0			;Hi res?
	beq	finish			; yes - jump to end
	jsr	mousof			;Kill skweeky
	dc.w	$a00a			; and hide the body!
	jsr	svmode			;Go super
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,old_pal		;Save old palette
	jsr	usmode			;Back to user
	move.w	#2,-(a7)
	trap	#14			;Get phys base
	addq.l	#2,a7
	move.l	d0,old_phy		; and save it
	move.w	#3,-(a7)
	trap	#14			;Get log base
	addq.l	#2,a7
	move.l	d0,old_log		; and save it
	move.w	#0,-(a7)		;Force lo res
	move.l	#$68000,-(a7)		; & new screen address
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14			;Set new screen
	lea	12(a7),a7
	move.l	#pic+4,-(a7)
	move.w	#6,-(a7)
	trap	#14			;Set new palette
	addq.l	#6,a7
	movea.l	#$6fd00,a0		;Below picture
	move.w	#1799,d0
loop1	move.l	#0,(a0)+		;Clear scroll area
	dbf	d0,loop1		; all of it!
	movea.l	#pic,a0
	adda.l	#128,a0
	move.w	#7999,d0
	movea.l	#$68000,a1
loop2	move.l	(a0)+,(a1)+		;Whack piccy onscreen
	dbf	d0,loop2		; the lot!
	jsr	saveint			;Save old interupts
	jsr	newint			;Install new interupts
loop3	jsr	waitkey			;Get keypress
	sub.b	#48,d0
	cmp.b	#1,d0
	bmi	loop3			; must be between 1
	cmp.b	numgame,d0
	bgt	loop3			; and numgame
	sub.b	#1,d0
	lsl.b	#2,d0			;* 4
	clr.l	d1
	move.b	d0,d1
	add.l	#gamelst,d1		;(d1) is pointer to game name!
	move.l	d1,a6
	move.l	(a6),nmgame		;Nmgame has pointer
	jsr	restint			;Restore old interupts
	move.w	#$87,-(a7)
	move.w	#$ff,-(a7)
	move.w	#$1c,-(a7)
	trap	#14			;Kill sound
	addq.l	#6,a7
	move.l	#old_pal,-(a7)
	move.w	#6,-(a7)
	trap	#14			;Restore palette
	addq.l	#6,a7
	move.w	#-1,-(a7)		;Stay in lo res
	move.l	old_phy,-(a7)		; restore old phys
	move.l	old_log,-(a7)		; and log bases
	move.w	#5,-(a7)
	trap	#14			;Reset screen
	lea	12(a7),a7
	jsr	cls			;Clear screen
	jsr	mouson			;Rodent resurection
	bra	go
	
finish	clr.w	-(a7)
	trap	#1			;End of the line matey!
	
*******************
* Subroutines
*******************
	
cls	MOVE.W	#2,-(A7)
	TRAP	#14			;Get screen address
	ADDQ.L	#2,A7
	MOVEA.L	D0,A0
	MOVE.W	#$1F3F,D0
.loop	MOVE.L	#0,(A0)+		;& blank it
	DBF	D0,.loop
	RTS
	
mousof	MOVE.L	#msof,-(A7)
	MOVE.W	#1,-(A7)
	MOVE.W	#$19,-(A7)
	TRAP	#14			;Send offcode to IKBD
	ADDQ.L	#8,A7
	RTS
	
mouson	MOVE.L	#mson,-(A7)
	MOVE.W	#1,-(A7)
	MOVE.W	#$19,-(A7)
	TRAP	#14			;Send oncode to IKBD
	ADDQ.L	#8,A7
	RTS
	
saveint	JSR	svmode			;Go super
	MOVE.L	$70,old_vbl		;Save old VBL
	MOVE.L	$120,old_tmb		; timer B
	MOVE.B	$FFFA07,old_iea		; int enable A
	MOVE.B	$FFFA09,old_ieb		; int enable B
	MOVE.B	$FFFA0F,old_isa		; int in-service A
	MOVE.B	$FFFA13,old_ima		; int mask A
	MOVE.B	$FFFA15,old_imb		; int mask B
	MOVE.B	$FFFA1B,old_tbc		; timer B control
	MOVE.B	$FFFA21,old_tbd		; timer B data
	JSR	usmode			;Back to user
	RTS
	
newint	JSR	svmode			;Super
	ANDI.B	#$FE,$484		;No keyclick
	MOVEQ	#1,D0			;Tune 1
	JSR	music			; init music
	MOVE.B	#0,done			;Init columns counter
	MOVE.L	#scrtext,scr_ptr	;Init scroll pointer
	OR.W	#$0400,SR		;Disable ints
	MOVE.B	#1,$FFFA07		;Install new int enable A
	MOVE.B	#1,$FFFA13		; int mask A
	MOVE.B	#$C0,$FFFA09		; int enable B
	MOVE.B	#$C0,$FFFA15		; int mask B
	MOVE.L	#new_vbl,$70		; new VBL
	AND.W	#$FBFF,SR		;Re-enable ints
	JSR	usmode			;User
	RTS
	
restint	JSR	svmode			;Super
	OR.W	#$0400,SR		;Kill ints
	MOVE.L	old_vbl,$70		;Restore old VBL
	MOVE.L	old_tmb,$120		; timer B
	MOVE.B	old_iea,$FFFA07		; int enable A
	MOVE.B	old_ieb,$FFFA09		; int enable B
	MOVE.B	old_isa,$FFFA0F		; int in-service A
	MOVE.B	old_ima,$FFFA13		; int mask A
	MOVE.B	old_imb,$FFFA15		; int mask B
	MOVE.B	old_tbc,$FFFA1B		; timer B control
	MOVE.B	old_tbd,$FFFA21		; timer B data
	AND.W	#$FBFF,SR		;Re-enable ints
	ORI.B	#1,$484			;Clicky keys
	JSR	usmode			;User
	RTS
	
new_vbl	MOVEM.L	D0-d7/A0-a6,-(A7)	;Stack registers
	JSR	new_tmb			;Install timer B
	MOVEM.L	pic+4,D0-d7
	MOVE.B	#2,$FF820A		;50 Hz
	MOVEM.L	D0-d7,$FF8240		;Picture palette
	JSR	music+8			;Keep music going
	JSR	scroll			; and scroller
	MOVEM.L	(A7)+,D0-d7/A0-a6	;Retrieve registers
	RTE
	
new_tmb	ORI.B	#1,$FFFA07		;Enable timer A
	ORI.B	#1,$FFFA13
	CLR.B	$FFFA1B			;Hold timer B
	MOVE.B	#199,$FFFA21		;Clear main pic
	MOVE.B	#8,$FFFA1B		;Go timer B
	BCLR	#0,$FFFA0F		;Int A not in-service
	MOVE.L	#timerb,$120		;Install timer B code
	MOVE.B	#2,$FF820A		;50 Hz
	RTS
	
timerb	OR.W	#$0400,SR		;Kill ints
	CLR.B	$FFFA1B			;Clear controller
	MOVEM.L	D0-d7,-(A7)		;Stack registers
	MOVEQ	#$12,D0
.wait1	NOP				;Get to very end of pic
	DBF	D0,.wait1
	MOVE.B	#0,$FF820A		;Switch to 60 Hz
	MOVEQ	#5,D0
.wait2	NOP				;Clear line
	DBF	D0,.wait2
	MOVE.B	#2,$FF820A		;50 Hz
	MOVEM.L	fontpal,D0-d7
	MOVEM.L	D0-d7,$FF8240		;Use font palette
	MOVEM.L	(A7)+,D0-d7		;Retrieve registers
	BCLR	#0,$FFFA0F
	AND.W	#$FBFF,SR		;Ints enabled
	RTE
	
scroll	MOVEM.L	D0-d7/A0-a6,-(A7)	;Stack registers
	CMPI.B	#0,done			;Char all done?
	BNE	.skip1			; no - go on
	JSR	getchar			; yes - get new char
.skip1	MOVEA.L	chardat,A1		;
	CLR.L	D0			;Start at line 0
.line	MOVE.L	D0,D1			;Line counter in d1
	LSL.W	#2,D1			; * 4
	ADD.W	D0,D1			; + d1 (= * 5)
	LSL.W	#5,D1			; * 160
	ADD.L	scrarea,D1		; + area to put scroller
	MOVEA.L	D1,A0			;Address of next line in a0
	MOVEQ	#18,D1			;19 times (most of line)
.main	MOVE.B	1(A0),(A0)		;Scroll it
	MOVE.B	8(A0),1(A0)
	MOVE.B	3(A0),2(A0)
	MOVE.B	$A(A0),3(A0)
	MOVE.B	5(A0),4(A0)
	MOVE.B	$C(A0),5(A0)
	MOVE.B	7(A0),6(A0)
	MOVE.B	$E(A0),7(A0)
	ADDQ.L	#8,A0			;Next block on line
	DBF	D1,.main		;Do whole line
	MOVE.B	1(A0),(A0)		;Add new char data on end
	MOVE.B	(A1)+,1(A0)
	MOVE.B	3(A0),2(A0)
	MOVE.B	(A1)+,3(A0)
	MOVE.B	5(A0),4(A0)
	MOVE.B	(A1)+,5(A0)
	MOVE.B	7(A0),6(A0)
	MOVE.B	(A1)+,7(A0)
	ADDQ.B	#1,D0			;Increment line number
	CMP.B	#$20,D0			;32 lines done?
	BNE	.line			; no - then do it!
	MOVE.L	A1,chardat		;Chardata ready for next time
	ADDQ.B	#1,done			;Increment column counter
	CMPI.B	#4,done			;All 4 done?
	BNE	.notfin			; no - go on
	MOVE.B	#0,done			; yes - reset to zero
.notfin	MOVEM.L	(A7)+,D0-d7/A0-a6	;Retrieve registers
	RTS
	
getchar	MOVEA.L	scr_ptr,A0		;Next letter
	CLR.L	D0
	MOVE.B	(A0),D0			;Letter in d0
	CMP.B	#0,D0			;Is it zero (end of text)?
	BNE	.newch			; no - carry on
	MOVE.L	#scrtext,scr_ptr	; yes - reset pointer to text start
	BRA	getchar			;       get new letter
.newch	CMP.B	#$5B,D0			;Capital?
	BLE	.caps			; yes - carry on
	SUBI.B	#$20,D0			; no - then make it
.caps	SUBI.B	#$20,D0
	LSL.W	#1,D0
	LSL.L	#8,D0			;*512
	ADDI.L	#fontdat,D0
	MOVE.L	D0,chardat		;Chardat at start of font data for char
	ADDQ.L	#1,scr_ptr		;Increment scroll pointer
	RTS
	
svmode	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1			;Go super
	ADDQ.L	#6,A7
	MOVE.L	D0,old_usp		;Store USP
	RTS
	
usmode	MOVE.L	old_usp,-(A7)		;Retrieve USP
	MOVE.W	#$20,-(A7)
	TRAP	#1			;Back to normal
	ADDQ.L	#6,A7
	RTS
	
waitkey	MOVE.W	#7,-(A7)
	TRAP	#1			;Read a keypress
	ADDQ.L	#2,A7
	RTS
	
*******************
* Included files
*******************

	even
	data

pic	incbin	"b:\ictari.neo"

	even

music	incbin	"b:\atomix.mus"
	
fontdat	incbin	"b:\x_font.bin"

*******************
* Data
*******************

	even
	data

fontpal	dc.w	$000,$410,$420,$530,$540,$660,$770,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777

msof	dc.w	$1212
mson	dc.w	$0808
scrarea	dc.l	$68000+201*160

scrtext	dc.b	"          "
	dc.b	"WELCOME TO ICTARI USER GROUP'S DISK BASED MAGAZINE, ISSUE #2 "
	dc.b	"RELEASED ON MONDAY THE 12TH APRIL. (EASTER MONDAY). HAPPY "
	dc.b	"EASTER TO ALL READING THIS......                        "
	dc.b	"THIS EDITION FEATURES A WIDE VARIETY OF SOURCE CODE, TIPS "
	dc.b	"AND ADVICE IN ALL COMMON LANGUAGES USED ON ATARI COMPUTERS "
	dc.b	"SUCH AS STOS, GFA, 68K and C.......                         "
	dc.b	"ONE NEW IDEA FEATURED IN THIS EDITION IS A STEP BY STEP GUIDE "
	dc.b	"TO PROGRAMMING A PARTICULAR PACKAGE. I'VE DECIDED TO KICK OF "
	dc.b	"BY WRITING A PONTOON GAME IN STOS. ITS NOT FINISHED YET, BUT "
	dc.b	"YOU CAN CHECK OUT HOW FAR I GOT, AND READ DETAILS OF PROBLEMS "
	dc.b	"I ENCOUNTERED, AND HOW I OVERCAME THEM, ETC. HOPEFULLY OTHERS "
	dc.b	"WILL FOLLOW WITH THIS IDEA.....                              "
	dc.b	"ICTARI USER GROUP ACTS AS A MEDIUM FOR ATARI PROGRAMMERS "       "
	dc.b	"PROVIDING INVALUABLE SERVICES SUCH AS PLAY TESTING, CHECKING "
	dc.b	"COMPATIBILITY OF PROGRAMS, SHARING TIPS AND ADVICE, AS "
	dc.b	"WELL AS HELPING AND ENCOURAGING NEW MEMBERS JUST STARTING OUT. "
	dc.b	"                          "
	dc.b	"NOW FOR THE USUAL THANKS AND HI'S......                    "
	dc.b	"THANKS GOTO ALL MEMBERS WHO CONTRIBUTED TO THIS ISSUE. " 
	dc.b	"AND HI'S GOTO IN NO PARTICULAR ORDER.....                  "
        dc.b	"FALCON, WOLVERINE, THE WIZ!, HANOI, MORF, TRANTOR, MONKEY "
	dc.b    "DARKELF, HOTBLACK, ANDYM, DIRTY MIND, BCC, MORT, DEICIDE, CHRIS "
	dc.b    "ROBINSON, CLIVE AND NIGEL MOORE, MARK HELPS, PAUL ALCON, JASON "
	dc.b	"FLOOKS, MARTIN WRIGHT, BEN PRICE, (ITS BLOODY HARD TRYING TO "
	dc.b	"THINK OF EVERYONE), MICHAEL HERMAN, DARREN GOLDING, LEE BALL "
	dc.b	"(NEW MEMBER), SHAYNE JENNINGS (NEW MEMBER), PETER KING, AND "
	dc.b	"EVERYONE ELSE I'VE FORGOTTEN. HI ALSO TO ALL NEW MEMBERS, AND "
	dc.b	"TO POTENTIAL MEMBERS READING THIS.........                   "
	dc.b    "ICTARI DISK #3 WILL BE REALISED 12TH MAY 1993. UNTIL THEN "
        dc.b    "THIS IS ICTARI SIGNING OF ....... YEP YOU GUESSED IT, TIME TO "
	dc.b	"WRAP .....                        "
	dc.b	0
 
numgame	dc.b	2			;This is the number of progs

*******************
* Variables
*******************

	even
	bss
	
old_usp	ds.l	1
old_pal	ds.l	8
scr_ptr	ds.l	1
chardat	ds.l	1
old_phy	ds.l	1
old_log	ds.l	1
old_vbl	ds.l	1
old_tmb	ds.l	1
old_iea	ds.b	1
old_ieb	ds.b	1
old_isa	ds.b	1
old_ima	ds.b	1
old_imb	ds.b	1
old_tbc	ds.b	1
old_tbd	ds.b	1
done	ds.b	1
