;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ GENERAL VERSION OF TRIGON v0.04              ~
;~ Many optimisation in code. Not readable ;-)  ~
;~ START: 29.01.96      LAST UPDATE: 15.02.96   ~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;LITTLE3_OUT ;if we want some little trigons send out
;LINEREVISION ;controlling of line in line field
;QUADRIC equ 50 ;varibale for outing trigons (dx*dy)


Pointx1	equ 0
Pointy1	equ 2
Pointx2	equ 4
Pointy2	equ 6
Pointx3	equ 8
Pointy3	equ 10
;Color_Relative equ 102 ;relative adress of number of color to Pointx1

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ MADE A TRIGON - 16 COLORS                    ~
;~ START: 29.01.96      LAST UPDATE: 15.02.96   ~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COMPUTE_Y:
	move.l SCREEN2,a0 ;screen addr
	lea VARIABLE(pc),a6
	lea Polyx1(a6),a4	;ukazatel na pole bodu trojuhleniku
	movem.w (a4),d0-d5	;naplneni poli o bodech trojuhelnik do d0-d6
	cmp.w d3,d1
	bls.s .TEST_Y2
	exg d2,d0		;Srovnani bodu polygonu podle Y od nejvyssiho bodu po nejnizsi
	exg d1,d3
.TEST_Y2:	cmp.w d5,d3
	bls.s .ALL_OK
	exg d4,d2
	exg d5,d3
	cmp.w d3,d1
	bls.s .ALL_OK
	exg d2,d0
	exg d1,d3
.ALL_OK:	
	move.w d1,d7	;right screen line
	mulu #LINEWIDTH,d7	;widht of one line is 160 bytes x lines
	add.l d7,a0		;add result
	move.l a0,a3

	movem.w d0-d1/d4-d5,(a4)      ;X1,Y1 X3,Y3 sort points in Y order back (format to lines)
	movem.w d0-d1/d2-d3,8(a4)      ;X1,Y1 X2,Y2 sort points in Y order back (format to lines)
	movem.w d2-d3/d4-d5,16(a4)      ;X2,Y2 X3,Y3 sort points in Y order back (format to lines)


;~~~~~ Make absolute XY Clipping   ~~~~~~~~~~~~~
;~~~~~ in case, trigon will be out of screen ~~~
;~~~~~ we will not paint it	        ~~~~
	move.w #319,d7 ;mez X
	move.w #199,d6 ;mez Y

	tst.w d0 ;x1
	bmi SETAGAIN
	tst.w d2 ;x2
	bmi SETAGAIN
	tst.w d4 ;x3
	bmi SETAGAIN
POSITIVEX:	cmp.w d7,d0
	bhi SETAGAIN
	cmp.w d7,d2
	bhi SETAGAIN
	cmp.w d7,d4
	bhi SETAGAIN

	tst.w d1 ;y1
	bmi SETAGAIN
	tst.w d3 ;y2
	bmi SETAGAIN
	tst.w d5 ;y3
	bmi SETAGAIN
.POSITIVEY:	cmp.w d6,d1
	bhi SETAGAIN
	cmp.w d6,d3
	bhi SETAGAIN
	cmp.w d6,d5
	bhi SETAGAIN
	
	ifd LITTLE3_OUT
;~~~~~ Compute of absolute DX & DY ~~~~~~~~~~~~~
;~~~~~ in case, trigon is little, we can't  ~~~~
;~~~~~ paint it		        ~~~~
;~~~~~ BEWARE you need correc x&y, rechange ~~~~
;~~~~~ XY Clipping                          ~~~~
	sub.w d1,d5	;in d5 dy
	sub.w d2,d0
	bpl.s .PLUS_R
	neg.w d0
.PLUS_R:	sub.w d2,d4
	bpl.s .PLUS_R2
	neg.w d4
.PLUS_R2:	add.w d4,d0
	mulu d5,d0 ;in d2 quadric result (Dx*Dy)
	cmp.w #QUADRIC,d0 ;quadric result, lower than eight
	blo SETAGAIN
	endc

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ TRIGON - MAKE BUFFER LINE FOR X1,Y1-X3,Y3    ~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LINE_COMPUTE:
	ifd STE
	move.w Color(a6),d1 ;color of line (be taking via blitter)
	endc
	lea LINES1(pc),a1
	ifd LINEREVISION
	move.l #LINE1,a0
	else
	;clr.l -(a7) ;supervizor
	;move.w #32,-(a7)
	;trap #1
	;addq.l #6,a7	
	;move.l $44e,a0
	endc

	move.w #2,LOOPLINE ;write X1Y1 X3Y3
	lea LINES1(pc),a1
.ANOTHER_LINE:
	move.w (a4)+,d7   ;x1
	move.w (a4)+,d4  ;y1
	move.w (a4)+,d6  ;x3
	move.w (a4)+,d5  ;y3

	move.w d7,d3 ;x counting[d3]
	move.w d4,d2 ;y counting[d2]
	move.w #1,d1 ;firstly we try a countX as positive
	sub.w d7,d6  ;dx[d7]=x2-x1
	bpl.s .POSITIVE ;negative to positive
	neg.w d1		
	neg.w d6 ;positive dx (we working with add, OK?)
.POSITIVE:	sub.w d4,d5  ;dy[d5]=y2-y1
	suba.l a5,a5 ;what type
	;move.w d5,a2 ;a2 as loop
	cmp.w #2,LOOPLINE
	bne.s .DONT_WRITE
	move.w d5,(a1)+ ;lines in trigon - 1, because we used DBF
.DONT_WRITE:
	;addq.w #1,a2 ;we must add one, d5 as loop
	cmp.w d5,d6  ;tst dx, dy
	bhi.s .TSTDD ;if dx<dy - not change
;dx>dy
	move.w d6,d7 ;AincrX[d6]=2*(dx-dy)
	move.w d6,d0 ;ddX[d0]
	asl.w #1,d0
	sub.w d5,d0  ;ddX=2*dx-dy
	sub.w d5,d7  ;dx[d7]-dy[d4]
	asl.w #1,d7  ;AincrX[d7]
	asl.w #1,d6  ;BincrX[d6] = 2xdx
	bra.s .ALL_INICIAL
.TSTDD:		
	addq.l #1,a5 ;change TYPE
	move.w d5,d7 ;AincrY[d7]=2*(dy-dx)
	move.w d5,d0 ;ddY[d0]
	asl.w #1,d0  ;2xd0
	sub.w d6,d0  ;ddY[d0]=2*dy-dx
	sub.w d6,d7  ;dy[d7]-dx[d6]
	asl.w #1,d7  ;AincrY[d7]
	move.w d5,d6 ;BincrY
	asl.w #1,d6  ;BincrY[d6] = 2xdy


.ALL_INICIAL: ;transform into words & points (d3)	
	move.w d3,d4   ;X counting into d4
	and.w #$fff0,d4 ;words in d4
	lsr.w #1,d4
	and.w #$000f,d3 ;points in d3
	bra.s .WRITE_LINE	


;~~~~~~~~~ macro for computing of one line  ~~~~~
;~~~~~~~~~ in whole trigon it is 3 times :) ~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ NOW PAINTING of LINES:                       ~
;~ D3 - X counting - bits                       ~
;~ D4 - X counting - words                      ~
;~ D2 - Y counting                              ~
;~ D0 - ddX/ddY                                 ~
;~ D7 - AincrY/AincrX                           ~
;~ D6 - BincrY/BincrX                           ~
;~ D1 - Count X (+-)                            ~
;~ D5 - Loop counting for substraction to zero  ~
;~ A1 - Trigon lines pointer 		~
;~ A5 - Type (dx>dy or dy<dx)		~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


MAKE_LINE	macro
.X_PART:	
	cmp.w #0,a5 ;if type=1 then dx>dy
	bne.s .Y_PART ;dx>dy
.OWN_X:	addq.w #1,d2
	tst.w d0 ;tst ddX
	bmi.s .ADD_DDX
	add.w d7,d0 ;ddX=ddX+AincrX
	add.w d1,d3 ;X=X+Xincr
	bmi.s .SUBX_WORD
	cmp.w #16,d3
	beq.s .ADDX_WORD
;compare to zero & 16
	bra.s .WRITE_LINE1
.ADDX_WORD:
	addq.w #8,d4 ;X words
	clr.w d3
	bra.s .WRITE_LINE1
.SUBX_WORD: subq.w #8,d4 ;X words	
	move.w #15,d3

;for X call only
.WRITE_LINE1:
	;tst.w d2	;test Y, if negative,no-write this line
	;bra.s .ALL_WRITTEN ; good trick ;-)
	move.w d4,(a1)+ ;information about line
	move.w d3,(a1)+ ;about points in word, second word
	dbf d5,.OWN_X
	bra.s .ALL_WRITTEN
			
.ADD_DDX:	add.w d6,d0 ;ddX=ddX+BincrX
	bra.s .WRITE_LINE1
;dx>dy
.Y_PART:	
	add.w d1,d3
	bmi.s .SUBX_WORD2
	cmp.w #16,d3
	beq.s .ADDX_WORD2
.TST_Y:	tst.w d0 ;tst ddY
	bmi.s .ADD_DDY
	addq.w #1,d2 ;Y=Y+Yincr
	add.w d7,d0  ;ddY=ddY+AincrY
;for Y call only
.WRITE_LINE2:
	;tst.w d2	;test Y, if negative,no-write this line
	;bra .ALL_WRITTEN ;no change DBF good trick ;-)

	move.w d4,(a1)+ ;information about line
	move.w d3,(a1)+ ;about points in word, second word
	dbf d5,.Y_PART
	bra.s .ALL_WRITTEN
.ADD_DDY:	add.w d6,d0  ;ddY=ddY+BincrY		
	bra.s .Y_PART ;we need every time change Y
.ADDX_WORD2:
	addq.w #8,d4 ;X words
	clr.w d3
	bra.s .TST_Y
.SUBX_WORD2:
	move.w #15,d3
	subq.w #8,d4 ;X words	
	bra.s .TST_Y

;for first call only
.WRITE_LINE:
	;tst.w d2	;test Y, if negative,no-write this line
	;bra.s d5,.ALL_WRITTEN ; good trick ;-)

	move.w d4,(a1)+ ;information about line
	move.w d3,(a1)+ ;about points in word, second word
	dbf d5,.X_PART

.ALL_WRITTEN:
	endm

	MAKE_LINE

	SUBQ.W #1,LOOPLINE
	bmi.s WHOLE_TRIGON
	beq .ANOTHER_LINE
	lea LINES2(pc),a1
	bra .ANOTHER_LINE

WHOLE_TRIGON: 
	move.w Color(a6),d2 ;color
	lsl.w #2,d2 ;any routine have got 4 bytes adress, so 4xCOLOR
	lea TAB_PAR2(pc),a1	;parametr table
	move.l 64(a1,d2.w),a5
	jmp (a5) ;jump to right location 
SETAGAIN:
	lea VARIABLE(pc),a6 ;back pointer to variable table
	rts
	
LOOPLINE:	ds.w 1

	
;macro for own painting of TRIGON

FILL_TRIGON macro
	clr.l d7
	clr.l d3
	
.FILL_LINE:	
	lea LINES1(pc),a2 ;offset 
	lea LINES2(pc),a4
	move.w (a2)+,d0 ;dbf (for lines on screen)
.PAINTL:	move.w (a2)+,a5 ;first lenght
	move.w (a4)+,d4 ;second lenght
	move.w (a4)+,d7 ;bits (points) offset
	;swap d3
	move.w (a2)+,d3 ;bits (points) offset
	
	lsl.w #1,d3 ;2x (we need a table)
	lsl.w #1,d7 ;2x (we need a table)
	cmp.w a5,d4
	beq .ZERO_FILL
	bpl.s .ORDEROK
	exg a5,d4 ;word
	exg d7,d3 ;& points change
.ORDEROK:	

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~  if line will be more than one word  ~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	add.l a5,a0 ;screen offset  
	sub.w a5,d4 ;computing of lenght of line in words
	lsr.w #3,d4
	move.l \1(pc),a5
	move.l \1+4(pc),a6 ;fill words	
	move.w -32(a1,d3.w),d2	;real mask (but inversion, one not out ;-)
	and.w d2,(a0)+	;masking of area
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	not.w d2
	\2or.w d2,\3(a0)
	\4or.w d2,\5(a0)
	\6or.w d2,\7(a0)
	\8or.w d2,\9(a0)
	subq.w #2,d4	;two words down, what happen?
	bmi.s .NOT_COPY
;~~  more than two words on line ~~~~~~~~~~~~~~~
;7384	
	;illegal
	sub.w #18,d4
	neg.w d4
	lsl.w #2,d4
	addq.w #2,d4
	jmp (pc,d4.w)
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+
	move.l a5,(a0)+	;lower part, word by word
	move.l a6,(a0)+

.NOT_COPY:	
	move.w -64(a1,d7.w),d2	;second mask & one not out ;-)
	and.w d2,(a0)+	;nejdriv si oblast peclive zmaskujeme
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	not.w d2
	\2or.w d2,\3(a0)	;paint last word
	\4or.w d2,\5(a0)
	\6or.w d2,\7(a0)
	\8or.w d2,\9(a0)	;that's all
	lea 160(a3),a3
	move.l a3,a0
	dbf d0,.PAINTL ;next line
	bra SETAGAIN  ;back to main loop


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~  if line will be one word only   ~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.ZERO_FILL:
	add.l a5,a0 ;screen line offset add 
	move.w d3,d2 ;backup
	sub.w d7,d2 ;widht of word
	bpl.s .ALREADYP ;second version for cross of lines
	neg.w d2 ;absolute
	exg d3,d7 ;d3 is lower
.ALREADYP:	lsr.l #1,d7 ;lsr because we need rotation number only
	move.w 32(a1,d2.w),d2	;real lenght of line (points)
	lsr.w d7,d2 ;fill this line

.SIMPLE_SLOW2:		  
.PAINT:	
	not.w d2
	and.w d2,(a0)+	;mask this line
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	not.w d2
	\2or.w d2,\3(a0)        ;paint line
	\4or.w d2,\5(a0)
	\6or.w d2,\7(a0)
	\8or.w d2,\9(a0)
	lea 160(a3),a3
	move.l a3,a0
	dbf d0,.PAINTL
	bra SETAGAIN
	endm
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~  16 macros for 16 colors of trigons        ~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VZOREK15:	dc.l $ffffffff,$ffffffff		
FILL15:	FILL_TRIGON VZOREK15,,-2,,-4,,-6,,-8,15,15,15,15,15
;$ff8240
VZOREK0:	dc.l 0,0	
FILL0:	FILL_TRIGON VZOREK0,;,,;,,;,,;,,0,0,0,0,0

;ff8242
VZOREK1:	dc.l $ffff0000,$00000000	
FILL1:	FILL_TRIGON VZOREK1,,-8,;,,;,,;,,1,15,0,0,0

;ff8244
VZOREK2:	dc.l $0000ffff,$00000000	
FILL2:	FILL_TRIGON VZOREK2,;,,,-6,;,,;,,2,0,15,0,0

;ff8246
VZOREK3:	dc.l $ffffffff,$00000000	
FILL3:	FILL_TRIGON VZOREK3,,-8,;,,,-6,;,,3,15,15,0,0

;$ff8248
VZOREK4:	dc.l $00000000,$ffff0000	
FILL4:
	FILL_TRIGON VZOREK4,;,,;,,;,,,-4,4,0,0,15,0
	
;$ff824a
VZOREK5:	dc.l $ffff0000,$ffff0000

FILL5:	FILL_TRIGON VZOREK5,,-8,;,,,-4,;,,5,15,0,15,0


;ff824a
VZOREK6:	dc.l $0000ffff,$ffff0000

FILL6:	FILL_TRIGON VZOREK6,,-6,;,,,-4,;,,6,0,15,15,0

;$ff824e
VZOREK7:	dc.l $ffffffff,$ffff0000

FILL7:	FILL_TRIGON VZOREK7,,-8,,-6,,-4,;,,7,15,15,15,0


;$ff8250
VZOREK8:	dc.l $00000000,$0000ffff
FILL8:	FILL_TRIGON VZOREK8,,-2,;,,;,,;,,8,0,0,0,15


;$ffff8252
VZOREK9:	dc.l $ffff0000,$0000ffff
FILL9:	FILL_TRIGON VZOREK9,,-2,;,,;,,,-8,9,15,0,0,15

;$ff8254
VZOREK10:	dc.l $0000ffff,$0000ffff
FILL10:	FILL_TRIGON VZOREK10,,-2,;,,;,,,-6,10,0,15,0,15


;$ff8256
VZOREK11:	dc.l $ffffffff,$0000ffff
FILL11:	FILL_TRIGON VZOREK11,,-2,;,,,-8,,-6,11,15,15,0,15

;$ff8258
VZOREK12:	dc.l $00000000,$ffffffff
FILL12:	FILL_TRIGON VZOREK12,,-2,;,,;,,,-4,12,0,0,0,15

;$ff825a
VZOREK13:	dc.l $ffff0000,$ffffffff
FILL13:	FILL_TRIGON VZOREK13,,-2,;,,,-4,,-8,13,15,0,15,15

;$FF825C
VZOREK14:	dc.l $0000ffff,$ffffffff
FILL14:	FILL_TRIGON VZOREK14,,-2,;,,,-4,,-6,14,0,15,15,15


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ tables for start & end of lines          ~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; inversion to TAB_PAR	(offset -64)
	dc.w %0111111111111111
	dc.w %0011111111111111
	dc.w %0001111111111111
	dc.w %0000111111111111
	dc.w %0000011111111111
	dc.w %0000001111111111
	dc.w %0000000111111111
	dc.w %0000000011111111
	dc.w %0000000001111111
	dc.w %0000000000111111
	dc.w %0000000000011111
	dc.w %0000000000001111
	dc.w %0000000000000111
	dc.w %0000000000000011
	dc.w %0000000000000001
	dc.w %0000000000000000


	
; inversion to TAB_PAR2 (offset -32)	
	dc.w %0000000000000000
	dc.w %1000000000000000
	dc.w %1100000000000000
	dc.w %1110000000000000
	dc.w %1111000000000000
	dc.w %1111100000000000
	dc.w %1111110000000000
	dc.w %1111111000000000
	dc.w %1111111100000000
	dc.w %1111111110000000
	dc.w %1111111111000000
	dc.w %1111111111100000
	dc.w %1111111111110000
	dc.w %1111111111111000
	dc.w %1111111111111100
	dc.w %1111111111111110


TAB_PAR2:
	dc.w %1111111111111111
	dc.w %0111111111111111
	dc.w %0011111111111111
	dc.w %0001111111111111
	dc.w %0000111111111111
	dc.w %0000011111111111
	dc.w %0000001111111111
	dc.w %0000000111111111
	dc.w %0000000011111111
	dc.w %0000000001111111
	dc.w %0000000000111111
	dc.w %0000000000011111
	dc.w %0000000000001111
	dc.w %0000000000000111
	dc.w %0000000000000011
	dc.w %0000000000000001

TAB_PAR:	
	dc.w %1000000000000000
	dc.w %1100000000000000
	dc.w %1110000000000000
	dc.w %1111000000000000
	dc.w %1111100000000000
	dc.w %1111110000000000
	dc.w %1111111000000000
	dc.w %1111111100000000
	dc.w %1111111110000000
	dc.w %1111111111000000
	dc.w %1111111111100000
	dc.w %1111111111110000
	dc.w %1111111111111000
	dc.w %1111111111111100
	dc.w %1111111111111110
	dc.w %1111111111111111


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ sixteen routines for 16 colors of trigon  ~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ROUTINES:
	dc.l FILL0,FILL1,FILL2,FILL3
	dc.l FILL4,FILL5,FILL6,FILL7
	dc.l FILL8,FILL9,FILL10,FILL11
	dc.l FILL12,FILL13,FILL14,FILL15
	

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ line buffers, 2 bytes per one line         ~~~
;~ LINES 1 is for line X1,Y1-X3,Y3            ~~~
;~ LINES 2 are for lines X1,Y1-X2,Y2-X3,Y3    ~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LINES1:	ds.l 200
LINES2:	ds.l 200
    