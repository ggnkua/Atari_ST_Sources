



;-------------------------------------------------------------------------;
;       The following source code and art have been released by           ;
;       PERSISTENCE OF VISION for use by others for NON-Profit            ;
;   making purposes only. The code is supplied as is and no claim can     ;
;    be made against PERSISTENCE OF VISION for loses incured through      ;
;                    the use and/or missuse of it.                        ;
;                                                                         ;
;     Copyright for the soundtrack remains with the original authors.     ;
;-------------------------------------------------------------------------;
;
;                       This code was released on
;                         Persistence Of Vision
;                      Official Source Code Disc 1


;************************************************************************
;* MICROMIX compilation disc containing MICROMIX 1 & 2                  *
;*                                                                      *
;* Written entirely by Mark Sherdley-Davies                             *
;* Written using K_SEKA V1.6 AND DEVPAC                                 *
;*                                                                      *
;* Started 3/3/89   Finished 7/3/89                                     *
;* Include files;-                                                      *
;*                RAM_MASK.IMG into SET                                 *
;*                TUNE_1.WAS into TUNE                                  *
;* Other files needed;-                                                 *
;*                TITLE_PIC.MSD on root directory                       *
;*                                                                      *
;* P.O.V is the group name for M.S.D and DR.SYNE                        *
;************************************************************************

GO:
;Size the job and free back to GEM unused memory.
	move.l	A7,A5
	move.l	4(A5),A5	;get basepage
	move.l	$C(A5),D0	;text segment
	add.l	$14(A5),D0	;data segment
	add.l	$1C(A5),D0	;unitialized
	add.l	#$100,D0	;basepage size
M_SHRINK
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	D0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

init	equ	$A000		;A-LINE variables
hide_m	equ	init+10
show_m	equ	init+9

	dc.w	init	;INITIALISE A_LINE ROUTINES
	dc.w	hide_m	;hide mouse

;test for supervisor
	move.l	#1,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	D0
	bne.s	IN_SUPER

;set 68000 to supervisor mode
	clr.l	-(sp)		;Set super stack equal
	move.w	#32,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stksv	;save old supervisor stack value
	bra.s	JUMP
IN_SUPER:
	move.l	A7,stksv
JUMP:
	bsr	GET_BASE
	BSR	GET_REZ
	lea	B_PAL,A0
	BSR	SET_PALETTE
	move.w	#0,D0
	bsr	SET_REZ

	clr.b 	$484	;no keyclick

; START THE MUSIC
	move.l	#vbl,$4d2
	move.w	#$1,D0
	JSR	TUNE+$4D2

	lea	pic+2,A0
	BSR	SET_PALETTE
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
.loop:	move.l	(a0)+,(a1)+
	dbf	d0,.loop

;set up pixel scroll
	lea	SENTENCE,A0
	move.l	A0,POSITION
	move.w	#3,COUNT	;COUNT is a count down timer for PAUSING
				;the higher COUNT, the faster the scroll

;	Now wait for a sign from the user.
WAIT:	bsr	TST_KBD
	tst.w	D0
	bne.s	KYBD_ACTIVE

	move.l	POSITION,A0
	clr.w	D0
	move.b	(A0)+,D0	;get character
	cmp.b	#$FF,D0		;is it end of SENTENCE?
	beq.s	SWAIT		;YES!
	move.l	A0,POSITION	;no so poke new position back
	bsr	LETTER_PRINTER
;OKAY NOW SCROLL IT
	move.w	#16-1,D0	;characters are 16 bits wide
GG:	move.l	D0,-(sp)
	bsr	SCROLL_MESS
	move.l	(sp)+,D0
	dbra	D0,GG
	bra.s	WAIT

SWAIT:	lea	SENTENCE,A0	;end of SENTENCE so restart message
	move.l	A0,POSITION
	bra.s	WAIT

KYBD_ACTIVE:	;something has pressed the keyboard!
	cmp.b	#'1',D0		;key 1
	beq.s	MICRO_1

	cmp.b	#'2',D0		;key 2
	beq.s	MICRO_2
	bra.s	WAIT
MICRO_1:
	lea	F_MICRO_1,A6
	bra.s	JOINT
MICRO_2:
	lea	F_MICRO_2,A6

JOINT:
;   TURN MUSIC OFF THEN LOAD
endmus:
	CLR.L	$4d2
	MOVE.L	#$FF8800,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)

;set 68000 to user mode from supervisor
	move.l	stksv,-(sp)	;recover old supervisor stack
	move.w	#32,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack

	pea	CLS
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	lea	SHIFT,A0
	move.l	#$30000,A1
	move.l	#PAUSE-SHIFT,D0
UPMEM:	move.l	(A0)+,(A1)+
	sub.l	#1,D0
	bne.s	UPMEM
	jmp	$30000

SHIFT:	move.l	#GO,-(sp)
	move.l	#GO,-(sp)
	move.l	A6,-(sp)	;filename
	move.w	#0,-(sp)
	move.w	#75,-(sp)
	trap	#1
	add.l	#16,sp
	clr.w	-(sp)
	trap	#1
	addq.l	#4,sp

TST_KBD:	;C_RAWIO
	MOVE.W	#255,-(SP)
	MOVE.W	#6,-(SP)
	TRAP	#1
	ADDQ.W	#4,SP
	RTS
PAUSE:	MOVE.L	D0,-(sp)
	MOVE.W	#8,D0
PAU:	NOP
	DBRA	D0,PAU
	MOVE.L	(sp)+,D0
	RTS
SET_PALETTE:	;palette address in A0 on entry
	move.W	#15,d0
	move.l	#$FF8240,A1
set_col:
	MOVE.W	(A0)+,D2
	MOVE.W	D2,(A1)+
	dbra	D0,set_col
	RTS
GET_BASE:
;	Get screen base address
	MOVE.W	#3,-(SP)
	TRAP	#14
	ADDQ.W	#2,SP
	MOVE.L	D0,screen_base
	rts
GET_REZ:
;	Get rez.	_GETREZ
	MOVE.W	#4,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,ORG_REZ	
	rts
SET_REZ:
;	Set screen address to logical base.
	MOVE.W	D0,-(SP)	; Set Res.
	move.l	screen_base,D0
	MOVE.L	D0,-(SP)	; PHYSBASE
	MOVE.L	D0,-(SP)	; LOGBASE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.l	#12,SP
	rts
	even
stksv:		dc.l	1	;old stack value
screen_base:	dc.L	1	;Screen base address
ORG_REZ:	dc.W	1	;Origional rez. store.


B_PAL:		dc.l	0,0,0,0,0,0,0,0	;blank palette

;************************************************************************
;* Main routines for pixel scroll routine follow                        *
;************************************************************************
LETTER_PRINTER:
;  *** Character number is in D0.W on entry ***
; print characters in one plane of display via buffer.
	move.l	A0,-(sp)
	sub.b	#32,D0	;correct for ASCII offset of 32 bytes
	lea	CHAR,A0
	mulu	#16,D0	;get char position in memory
	add.w	D0,A0	;A0=char position

	lea	BUFFER,A1	;print char into buffer
	add.w	#2,A1
	move.w	#8-1,D0		;chars are 8 bytes down
PRT_SET:
	move.w	(A0)+,(A1)+
	add.w	#2,A1
	and.w	#$FFEE,SR
	dbra	D0,PRT_SET
	move.l	(sp)+,A0
	and.w	#$FFEE,SR	;clear X and C flags to stop wrap
	rts
SCROLL_MESS:
	lea	BUFFER,A0	;scroll buffer first
	addq.w	#2,A0
	move.w	#8-1,D0
B_DOWN:	roxl	(A0)
	subq.w	#2,A0
	roxl	(A0)
	addq.w	#6,A0
	and.w	#$FFEE,SR
	dbra	D0,B_DOWN

	lea	BUFFER,A0		;now move buffer to screen
	move.l	screen_base,A1
	add.w	#32000-1280-8,A1
	move.w	#8-1,D0
B_TRANS:
	move.w	(A0),(A1)
	add.w	#4,A0
	add.w	#160,A1
	dbra	D0,B_TRANS

	move.l	screen_base,A0
	add.w	#32000-1280-8,A0
	move.w	#8-1,D0		;characters are 8 bits down
S_DOWN:	move.w	#20-1,D1	;screen is 20 * 8 bytes (1 plane)=160
S_ACROSS:
	roxl	(A0)
	sub.w	#8,A0
	dbra	D1,S_ACROSS
	and.w	#$FFEE,SR
	add.w	#160+160,A0
	dbra	D0,S_DOWN
	bsr.s	S_PAUSE
	rts
EXITALL:	rts
S_PAUSE:
	movem.l	D0-D3/A0-A4,-(sp)
VSYNC:	move.w	COUNT,D0	;COUNT is a count down for the pause
	sub.w	#1,D0		;the higher COUNT, the more the PAUSE
	beq.s	RST_COUNT	;routine is done.
	sub.w	#1,COUNT
	bra.s	EXIT_PAUSE
RST_COUNT:
	move.w	#3,COUNT
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
EXIT_PAUSE:
	movem.l	(sp)+,D0-D3/A0-A4
	rts
POSITION:	dc.l	0	;position in SENTENCE
COUNT:		dc.w	0	;pause counter for V_SYNC

SENTENCE:
	dc.b	"           I'M BACK!!!           MSD HAS RETURNED WITH "
	DC.B	"THE FIRST EVER DEMO COMPILATION DISC.              I'VE "
	DC.B	"TEAMED UP WITH A "
	DC.B	"LOCAL LAD (DR.SYNE) AND NOW COME UNDER THE JOINT "
	DC.B	"NAME OF P.O.V.                 RIGHT, I'LL GIVE "
	dc.b	"50 QUID TO THE FIRST PERSON TO GUESS CORRECTLY WHAT "
	DC.B	"P.O.V. STANDS FOR!!         GIVE UP?     "
	DC.B	"        THE ANSWER IS               "
	DC.B	"          YOU'LL HAVE TO SEE SOME "
	DC.B	"FUTURE DEMOS TO FIND OUT."
	DC.B	"                    HAVE YOU SEEN THE "
	DC.B	"NEW VERSION OF THE GHOSTBUSTERS DEMO YET?       "
	DC.B	"  WHAT DO YOU MEAN NO?        GET A COPY "
	DC.B	"AND SEE WHAT IMPROVEMENTS I'VE MADE.        "
	DC.B	"            OKAY, NOW FOR THE MENTIONS,   "
	dc.b	"A BIG HELLO GOES TO;  -  WAS (NOT WAS),  L.S.D.,   TEX,"
	dc.b	"   A-HA,   THE UNION,   BASHER,   ALY,   STEVE C,   "
	dc.b	"AND   WOLIN KILSON (RIM, RAM, ROM, ST, ST, ST)!!!    "
	DC.B	"                     FOLLOWING IN THE "
	dc.b	"STYLE SET BY MARL FROM L.S.D., HERE IS A MESSAGE FOR "
	dc.b	"ALL YOU WHIZZ KIDS . . . . . . . "
	DC.B	"$41   $52   $45   $20   $59   $4F   $55   $20   $53   "
	DC.B	"$54   $49   $4C   $4C   $20   $44   $45   $43   $4F   "
	DC.B	"$44   $49   $4E   $47   $20   $54   $48   $45   $53   "
	DC.B	"$45   $20   $48   $45   $58   $20   $4D   $45   $53   "
	DC.B	"$53   $41   $47   $45   $53   $3F   $20   $53   $54   "
	DC.B	"$4F   $50   $20   $44   $45   $43   $4F   $44   $49   "
	DC.B	"$4E   $47   $20   $41   $4E   $44   $20   $53   $54   "
	DC.B	"$41   $52   $54   $20   $57   $52   $49   $54   $49   "
	DC.B	"$4E   $47   $20   $28   $4F   $52   $20   $43   $52   "
	DC.B	"$41   $43   $4B   $49   $4E   $47   $29   $2C   $20   "
	DC.B	"$42   $59   $45   $2E   $2E                           "
	DC.B	"           PLEASE NOTE:  THIS DISC IS 80 TRACK, 10 SECT"
	DC.B	"ORS AND DOUBLE SIDED, SORRY ABOUT THE FORMAT BUT I "
	DC.B	"DIDN'T HAVE TIME TO PACK THE ORIGINALS,"
	DC.B	" I'LL LEAVE THAT "
	DC.B	"TO AUTOMATION UNTIL I'VE WRITTEN A DECENT "
	DC.B	"PACKER.                                "
	DC.B	"PRESS 1 OR 2 FOR THE MICRO MIX DEMOS.          "
	DC.B	"                                            "
	DC.B	"YOU STILL THERE?                          "
	DC.B	"BAAL:   IN 'CONAN THE CONQUEROR', A MINION "
	DC.B	"OF XALTOTUN;  FROM BA'AL, HEBREW-PHOENICIAN FOR "
	DC.B	"'LORD'."
	DC.B	"                    THE FOLLOWING SPACE WAS LEFT FOR "
	DC.B	"DR.SYNE TO ADD HIS MESSAGE, BUT HE'S AT WORK "
	DC.B	"AT THE MOMENT, SO HE CAN'T!!             OH WELL,"
	DC.B	"  HE CAN HAVE A GO AT THE NEXT DEMO.            "
	DC.B	"       IF YOU LIKE THIS INTRO AND WOULD LIKE TO ADD "
	DC.B	"SOMETHING TO THE NEXT ONE THEN GET YOURSELF TO THE "
	DC.B	"BLACKPOOL CLUB.     WE ARE ESPECIALLY "
	DC.B	"LOOKING FOR MUSIC WIZARDS TO STEAL MORE TUNES FOR "
	DC.B	"OUR INTROS, BUT PLEASE NOTE - MACHINE CODERS ONLY, "
	DC.B	"NONE OF THIS GFA BASIC PAP.            "
	DC.B	"               RIGHT THAT'S IT,  NO MORE.       "
	DC.B	"      BYE.......                                "
	DC.B	"                   "
	DC.B	$FF,$FF
	even
CHAR:	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	even
SET:	INCBIN	'RAM_MASK.IMG'	;RAM_MASK.IMG to be loaded here
	even
BUFFER:	ds.b	32

CLS:		dc.b	27,'E',0,0
F_MICRO_1:	dc.b	'\1.POV\MIX1.PRG',0
	even
F_MICRO_2:	dc.b	'\2.POV\MIX2.PRG',0
	even
F_TUNE:		dc.b	'\MONTY.PRG',0
	even
vbl:		jsr	TUNE+$28	;jsr	$2c028
		move.w	#$ffff,$4ee
		rts
pic:	incbin	"micro.pi1"
TUNE:		INCBIN	'TUNE_1.WAS'
END:
	even

