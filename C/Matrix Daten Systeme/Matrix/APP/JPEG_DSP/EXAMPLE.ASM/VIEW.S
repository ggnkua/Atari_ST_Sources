RAM	equ	1
;  #[ Includes:

 include VIEW.I

;  #] Includes: 
;  #[ Sprintf EQUates & Structures:

_WORD	equ	0		;default size
_BEVEN	equ	2
_BODD	equ	4
_LONG	equ	6
	StructInit
	Ptr	START_BUF
	Byte	SIGNED_FLAG
	Byte	CHAR_FLAG
	Byte	HEXA_FLAG
	Byte	DECIMAL_FLAG
	Byte	EXTENDED_FLAG
	Byte	FLOAT_FLAG
	Byte	DOUBLE_FLAG
	Byte	PACKED_FLAG
	Byte	STRING_FLAG
	Byte	PADDING_CHAR
	Byte	PTR_FLAG
	Byte	COLON_FLAG
	Byte	EQUAL_FLAG
	Byte	RIGHT_FLAG
	Byte	MEMORY_FLAG
	WordEven
	Word	NUMBER_SIZE	;BEVEN,...
	Word	LEFT_SIZE
	Word	RIGHT_SIZE
	Word	FORMAT_COUNT
	Word	MIXED_COUNT
	Ptr	NUMBER_PTR
	Ptr	FORMAT_PTR
	Ptr	MIXED_PTR
	Ptr	STAR_PTR
	Byte	LOCAL_STRING,32
	SizeOF	LOCALS_SIZE

;  #] Sprintf EQUates & Structures: 
;  #[ Assembly Options:

 output VIEW.TTP

;  #] Assembly Options: 
 TEXT
;  #[ Main:

Main:
 move.l 4(sp),a5
 lea MyStack(pc),sp
 move.l $c(a5),d0
 add.l $14(a5),d0
 add.l $1c(a5),d0
 add.l #$100,d0
 move.l d0,-(sp)
 move.l a5,-(sp)
 clr.w -(sp)
 move.w #$4a,-(sp)
 trap #1
 lea $c(sp),sp
 lea $80(a5),a0
 moveq #0,d0
 move.b (a0)+,d0
 beq Exit
 sf 0(a0,d0.w)
 move.l a0,a5
 bsr GetCookie
 bmi Exit
 pea MyDTA(pc)
 move.w #$1a,-(sp)
 trap #1
 addq.w #6,sp
 clr.w -(sp)
 move.l a5,-(sp)
 move.w #$4e,-(sp) 
 trap #1
 addq.w #8,sp
 tst.w d0
 sne d0
 ext.w d0
 bne Exit
 pea Txt8(pc)
 bsr Print
 move.l MyDTA+26(pc),d0
 move.l d0,FileSize
 add.l #10,d0
 move.l d0,-(sp)
 move.w #$48,-(sp)
 trap #1
 addq.w #6,sp
 tst.l d0
 bmi Exit
 move.l d0,FilePointer
 clr.w -(sp)
 move.l a5,-(sp)
 move.w #$3d,-(sp)
 trap #1
 addq.w #8,sp
 move.w d0,d3
 move.l FilePointer(pc),-(sp)
 move.l FileSize(pc),-(sp)
 move.w d3,-(sp)
 move.w #$3f,-(sp)
 trap #1
 lea $c(sp),sp
 move.w d3,-(sp)
 move.w #$3e,-(sp)
 trap #1
 addq.w #4,sp
 move.l FilePointer(pc),a0
 add.l FileSize(pc),a0
 rept 8
 st (a0)+
 endr
 sf (a0)+
 sf (a0)+
 move.l CookieAddress(pc),a5
 move.l CookieGetStructSize(a5),a0
 jsr (a0)
 move.l d0,d3
 move.l d0,-(sp)
 move.w #$48,-(sp)
 trap #1
 addq.w #6,sp
 move.l d0,a0
 move.l d0,a4
 subq.w #1,d3
.Loop:
 sf (a0)+
 dbf d3,.Loop
 move.l a4,a0
 move.l CookieOpenDriver(a5),a1
 jsr (a1)
 move.l a4,a0
 move.l FilePointer,InPointer(a0)
 move.l FileSize,InSize(a0)
 move.l CookieGetImageInfo(a5),a1
 jsr (a1)
 move.l a4,a0
 IFNE RAM
 move.w #3,OutComponents(a0)
 move.w #2,OutPixelSize(a0)
 ELSEIF
 move.w #3,OutComponents(a0)
 move.w #2,OutPixelSize(a0)
 ENDC
 move.l CookieGetImageSize(a5),a1
 jsr (a1)
 move.l a4,a0
 move.w OutMFDB+MFDBPixelWidth(a0),ImageXSize
 move.w OutMFDB+MFDBPixelHeight(a0),ImageYSize
 move.w OutMFDB+MFDBWordSize(a0),d0
 add.w d0,d0
 move.w d0,ImageRealXSize
 IFNE RAM
 move.l OutSize(a0),-(sp)
 move.w #$48,-(sp)
 trap #1
 addq.w #6,sp
 move.l a4,a0
 move.l d0,OutPointer(a0)
 move.l d0,ImageAddress
 clr.w OutFlag(a0)
 ELSEIF
 move.l a4,a0
 clr.l OutPointer(a0)
 st OutFlag(a0)
 ENDC
 pea Txt9(pc)
 bsr Print
 bsr StartTime
 move.l CookieDecodeImage(a5),a1
 jsr (a1)
 move.w d0,DecoderReturnCode
 move.l a4,a0
 move.l CookieCloseDriver(a5),a1
 jsr (a1)
 bsr StopTime
 IFNE RAM
 bsr Display
 ENDC
 bsr DisplayStats
Exit:
 clr.w -(sp)
 trap #1

;  #] Main: 
;  #[ Get Cookie:

GetCookie:
 movem.l d1-d2/a0-a2,-(sp)
 pea .GetCookie(pc)
 move.w #$26,-(sp)
 trap #$e
 addq.w #6,sp
 move.w ReturnCode(pc),d0
 movem.l (sp)+,d1-d2/a0-a2
 rts

.GetCookie:
 move.l #'_JPD',d1
 move.l $5a0.w,a0
.Loop:
 move.l (a0),d0
 addq.w #8,a0
 beq.s .Error
 cmp.l d1,d0
 bne.s .Loop
 move.l -4(a0),CookieAddress
 clr.w ReturnCode
 rts
.Error:
 move.w #-1,ReturnCode
 rts

;  #] Get Cookie: 
;  #[ Display Stats:

DisplayStats:
 movem.l d0-d2/a0-a2,-(sp)
 pea Txt1(pc)
 bsr Print
 lea -80(sp),sp
 move.l sp,a0
 move.w ImageYSize(pc),-(sp)
 move.w ImageXSize(pc),-(sp)
 move.l FileSize(pc),-(sp)
 lea Txt2(pc),a1
 moveq #$50,d0
 bsr Sprintf
 addq.w #8,sp
 move.l sp,-(sp)
 bsr Print
 move.l sp,a0
 move.w ImageXSize(pc),d0
 mulu ImageYSize(pc),d0
 add.l d0,d0
 move.l d0,-(sp)
 lea Txt3(pc),a1
 moveq #$50,d0
 bsr Sprintf
 addq.w #4,sp
 move.l sp,-(sp)
 bsr Print
 move.l sp,a0
 move.l Time(pc),d0
 lsr.l #1,d0
 divu #100,d0
 swap d0
 move.l d0,-(sp)
 lea Txt4(pc),a1
 moveq #$50,d0
 bsr Sprintf
 addq.w #4,sp
 move.l sp,-(sp)
 bsr Print
 move.l sp,a0
 move.w DecoderReturnCode(pc),-(sp)
 lea Txt6(pc),a1
 moveq #$50,d0
 bsr Sprintf
 addq.w #2,sp
 move.l sp,-(sp)
 bsr Print
 lea 80(sp),sp
 pea Txt7(pc)
 bsr Print
 move.w #7,-(sp)
 trap #1
 addq.w #2,sp
 movem.l (sp)+,d0-d2/a0-a2
 rts

;  #] Display Stats: 
;  #[ Display:

Display:
 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.w #6,sp
 move.l d0,-(sp)
 bsr InitDisplay
 bmi.s ErrorDisplay
 sf d7
 movem.w ScreenWidth(pc),d0-d1
 lsr.w #1,d0
 lsr.w #1,d1
 movem.w d0-d1,(a0)
DisplayLoop:
 bsr TestKey
 bne.s EndDisplay
 movem.w (a0),d2-d3
 cmp.w d2,d0
 bne.s .Scroll
 cmp.w d3,d1
 bne.s .Scroll
 tas d7
 bne.s DisplayLoop

.Scroll:
 movem.w d0-d1,(a0)
 bsr Scroll
 bra.s DisplayLoop

EndDisplay:
 bsr ExitDisplay
 move.w #$20,-(sp)
 trap #1
 addq.w #6,sp
 rts

ErrorDisplay:
 pea ErrorDisplayTxt(pc)
 move.w #9,-(sp)
 trap #1
 addq.w #6,sp
 move.w #$20,-(sp)
 trap #1
 addq.w #6,sp
 rts

;  #] Display: 
;  #[ Scroll:
;
; IN:
; D0 = X
; D1 = Y
Scroll:
 movem.l d0-d2/a0,-(sp)
 sub.w d2,d0
 sub.w d3,d1
 sub.w d0,XOffset
 sub.w d1,YOffset
 movem.w XOffset(pc),d0-d1
 tst.w d0
 bpl.s .NotXUnderflow
.XUnderflow:
 clr.w d0
.NotXUnderflow:
 tst.w d1
 bpl.s .NotYUnderflow
.YUnderflow:
 clr.w d1
.NotYUnderflow:
 cmp.w XMaxOffset,d0
 ble.s .NotXOverflow
.XOverflow:
 move.w XMaxOffset,d0
.NotXOverflow:
 cmp.w YMaxOffset,d1
 ble.s .NotYOverflow
.YOverflow:
 move.w YMaxOffset,d1
.NotYOverflow:
 movem.w d0-d1,XOffset
 move.l ImageAddress(pc),d2
 and.w #$fffe,d0
 and.w #$fffe,d1
 mulu ImageRealXSize(pc),d1
 add.l d1,d2
 ext.l d0
 add.l d0,d0
 add.l d0,d2
 moveq #0,d1
 move.w ImageRealXSize(pc),d0
 sub.w ScreenWidth(pc),d0
 sub.w ScreenWidth(pc),d0
 asr.w #1,d0
 bmi.s .OffsetUnderflow
 move.w d0,d1
.OffsetUnderflow:
 move.w #$8200,a0
 move.l $462.w,d0
.Synchro:
 cmp.l $462.w,d0
 beq.s .Synchro
 move.w d1,$e(a0)
 ror.l #8,d2
 movep.w d2,1(a0)
 rol.l #8,d2
 move.b d2,$d(a0)
 movem.l (sp)+,d0-d2/a0
 rts

;  #] Scroll: 
;  #[ Init Display:
;
; OUT:
; D0 = 0 / -1
; A0 = Mouse Coords Pointer
InitDisplay:
 movem.l d1-d2/a1-a2,-(sp)
 move.l $44e.w,ScreenAddress
 move.w #$59,-(sp)
 trap #$e
 addq.w #2,sp
 move.w d0,d1
 moveq #-1,d0
 move.w d1,MonType
 beq .End
 move.w #-1,-(sp)
 move.w #$58,-(sp)
 trap #$e
 addq.w #4,sp
 move.w d0,OldModeWord
 cmp.w #2,MonType
 beq.s .VGA
 move.w d0,-(sp)
 or.w #$40,d0
 move.w d0,-(sp)
 move.w #$5b,-(sp)
 trap #$e
 addq.w #4,sp
 move.l d0,-(sp)
 move.w #$48,-(sp)
 trap #1
 addq.w #6,sp
 move.l d0,DummyScreen
 move.l d0,a0
 move.w (sp),d0
 or.w #$40,d0
 move.w d0,-(sp)
 move.w #3,-(sp)
 move.l a0,-(sp)
 move.l a0,-(sp)
 move.w #5,-(sp)
 trap #$e
 lea $e(sp),sp
 move.w (sp)+,d0
.VGA:
 and.w #7,d0
 cmp.w #4,d0
 sne d0
 ext.w d0
 bne.s .End
 dc.w $a000
 move.l d0,a1
 move.w -$c(a1),ScreenWidth
 move.w -4(a1),ScreenHeight
 move.w #$8200,a0
 move.w $e(a0),ScreenOffset
 clr.w XOffset
 clr.w YOffset
 move.w ImageXSize(pc),d0
 sub.w ScreenWidth(pc),d0
 bpl.s .XGood
 clr.w d0
.XGood:
 move.w d0,XMaxOffset
 move.w ImageYSize(pc),d0
 sub.w ScreenHeight(pc),d0
 bpl.s .YGood
 clr.w d0
.YGood:
 move.w d0,YMaxOffset
 lea -$25a(a1),a0
 moveq #0,d0
.End:
 tst.w d0
 movem.l (sp)+,d1-d2/a1-a2
 rts

;  #] Init Display: 
;  #[ Exit Display:

ExitDisplay:
 movem.l d0-d2/a0-a2,-(sp)
 move.w OldModeWord(pc),-(sp)
 move.w #3,-(sp)
 move.l ScreenAddress(pc),-(sp)
 move.l ScreenAddress(pc),-(sp)
 move.w #5,-(sp)
 trap #$e
 lea $e(sp),sp
 move.l DummyScreen(pc),-(sp)
 move.w #$49,-(sp)
 trap #1
 addq.w #6,sp
 pea .Supexec(pc)
 move.w #$26,-(sp)
 trap #$e
 addq.w #6,sp
 movem.l (sp)+,d0-d2/a0-a2
 rts

.Supexec:
 move.w #$8200,a0
 move.l ScreenAddress(pc),d0
 move.b d0,$d(a0)
 lsr.l #8,d0
 movep.w d0,1(a0)
 move.w ScreenOffset(pc),$e(a0)
 rts

;  #] Exit Display: 
;  #[ Test Key:
;
; OUT:
; D0 = 0 / -1
TestKey:
 movem.l d0-d2/a0-a2,-(sp)
 move.w #2,-(sp)
 move.w #1,-(sp)
 trap #$d
 addq.w #4,sp
 tst.w d0
 beq.s .End
 move.w #2,-(sp)
 move.w #2,-(sp)
 trap #$d
 addq.w #4,sp
 moveq #-1,d0
.End:
 movem.l (sp)+,d0-d2/a0-a2
 rts

;  #] Test Key: 
;  #[ Start Time:

StartTime:
 movem.l d0-d2/a0-a2,-(sp)
 pea .StartTime(pc)
 move.w #$26,-(sp)
 trap #$e
 addq.w #6,sp
 movem.l (sp)+,d0-d2/a0-a2
 rts

.StartTime:
 move.l $4ba.w,Time
 rts

;  #] Start Time: 
;  #[ Stop Time:

StopTime:
 movem.l d0-d2/a0-a2,-(sp)
 pea .StopTime(pc)
 move.w #$26,-(sp)
 trap #$e
 addq.w #6,sp
 movem.l (sp)+,d0-d2/a0-a2
 rts

.StopTime:
 move.l Time(pc),d0
 sub.l $4ba.w,d0
 neg.l d0
 move.l d0,Time
 rts

;  #] Stop Time: 
;  #[ Print:

Print:
 movem.l d0-d2/a0-a2,-(sp)
 move.l 28(sp),-(sp)
 move.w #9,-(sp)
 trap #1
 addq.w #6,sp
 movem.l (sp)+,d0-d2/a0-a2
 move.l (sp)+,(sp)
 rts

;  #] Print: 
;  #[ Test Screen:

TestScreen:
 movem.l d1-d2/a0-a2,-(sp)
 move.w #-1,-(sp)
 move.w #$58,-(sp)
 trap #$e
 addq.w #4,sp
 and.w #7,d0
 cmp.w #4,d0
 sne d0
 ext.w d0
 movem.l (sp)+,d1-d2/a0-a2
 rts

;  #] Test Screen: 
;  #[ Sprintf:

Sprintf:
	link	a2,#0
	movem.l	d1-d2/a0-a3,-(sp)
	addq.w	#8,a2
	movem.l	d0-d2/a0-a2,-(sp)
	movem.l	(sp)+,d0-d2/a0-a2
	bsr.s	.sprintf
	movem.l	(sp)+,d1-d2/a0-a3
	unlk	a2
	rts

.sprintf:
	movem.l	d3-d7/a3-a5,-(sp)
	lea	-LOCALS_SIZE(sp),sp
	move.l	sp,a5
	move.l	a0,START_BUF(a5)
	move.l	d1,STAR_PTR(a5)
	move.l	a0,a4
	move.l	a1,a3
	move.l	d0,d7

.next_percent:
	;stack checking
	;buffer checking
	tst.w	d7
	ble.s	.end
	lea	SIGNED_FLAG(a5),a0
	clr.l	(a0)+	;signed,char,hexa,decimal
	clr.l	(a0)+	;extended,float,double,packed
	clr.l	(a0)+	;string,padding,ptr,colon
	clr.l	(a0)+	;equal,right,memory,dummy
	clr.w	(a0)+	;number size
	clr.l	(a0)+	;left size,right size
;	clr.l	(a0)+	;format count,mixed count
	moveq	#'%',d1

.next_char:
	move.b	(a3)+,d0
	cmp.b	d1,d0
	beq.s	.percent_reached
	move.b	d0,(a4)+
	bne.s	.next_char
.end:
	move.l	a3,a1
	move.l	a4,a0
	clr.b	(a0)
	move.l	a0,d0
	sub.l	START_BUF(a5),d0
	move.l	STAR_PTR(a5),d1
	lea	LOCALS_SIZE(sp),sp
	movem.l	(sp)+,d3-d7/a3-a5
	rts

.percent_reached:
	moveq	#0,d0
	move.b	(a3)+,d0
	bmi	.unknown
	sub.b	#' ',d0
	bmi	.unknown
	add.w	d0,d0
	move.w	.table(pc,d0.w),d0
	jmp	.table(pc,d0.w)

.table:
	dc.w	.space-.table	;' '
	dc.w	.unknown-.table	;!
	dc.w	.unknown-.table	;"
	dc.w	.unknown-.table	;#
	dc.w	.unknown-.table	;$
	dc.w	.percent-.table	;%
	dc.w	.unknown-.table	;&
	dc.w	.unknown-.table	;'
	dc.w	.unknown-.table	;(
	dc.w	.unknown-.table	;)
	dc.w	.star-.table	;*
	dc.w	.plus-.table	;+
	dc.w	.unknown-.table	;,
	dc.w	.unknown-.table	;-
	dc.w	.colon-.table	;.
	dc.w	.unknown-.table	;/
	dc.w	.zero-.table	;0
	dc.w	.number-.table	;1
	dc.w	.number-.table	;2
	dc.w	.number-.table	;3
	dc.w	.number-.table	;4
	dc.w	.number-.table	;5
	dc.w	.number-.table	;6
	dc.w	.number-.table	;7
	dc.w	.number-.table	;8
	dc.w	.number-.table	;9
	dc.w	.unknown-.table	;:
	dc.w	.unknown-.table	;;
	dc.w	.unknown-.table	;<
	dc.w	.equal-.table	;=
	dc.w	.unknown-.table	;>
	dc.w	.unknown-.table	;?
	dc.w	.arobace-.table	;@
	dc.w	.upper-.table	;A
	dc.w	.upper-.table	;B
	dc.w	.upper-.table	;C
	dc.w	.upper-.table	;D
	dc.w	.upper-.table	;E
	dc.w	.upper-.table	;F
	dc.w	.upper-.table	;G
	dc.w	.upper-.table	;H
	dc.w	.upper-.table	;I
	dc.w	.upper-.table	;J
	dc.w	.upper-.table	;K
	dc.w	.upper-.table	;L
	dc.w	.upper-.table	;M
	dc.w	.upper-.table	;N
	dc.w	.upper-.table	;O
	dc.w	.upper-.table	;P
	dc.w	.upper-.table	;Q
	dc.w	.upper-.table	;R
	dc.w	.upper-.table	;S
	dc.w	.upper-.table	;T
	dc.w	.upper-.table	;U
	dc.w	.upper-.table	;V
	dc.w	.upper-.table	;W
	dc.w	.upper-.table	;X
	dc.w	.upper-.table	;Y
	dc.w	.upper-.table	;Z
	dc.w	.openbra-.table	;[
	dc.w	.unknown-.table	;\
	dc.w	.closbra-.table	;]
	dc.w	.unknown-.table	;^
	dc.w	.unknown-.table	;_
	dc.w	.unknown-.table	;`
	dc.w	.unknown-.table	;a
	dc.w	.byte-.table	;b
	dc.w	.char-.table	;c
	dc.w	.decimal-.table	;d
	dc.w	.extended-.table	;e
	dc.w	.float-.table	;f
	dc.w	.double-.table	;g
	dc.w	.unknown-.table	;h
	dc.w	.bin-.table	;i
	dc.w	.unknown-.table	;j
	dc.w	.unknown-.table	;k
	dc.w	.long-.table	;l
	dc.w	.memory-.table	;m
	dc.w	.unknown-.table	;n
	dc.w	.odd-.table	;o
	dc.w	.packed-.table	;p
	dc.w	.unknown-.table	;q
	dc.w	.right-.table	;r
	dc.w	.string-.table	;s
	dc.w	.unknown-.table	;t
	dc.w	.unknown-.table	;u
	dc.w	.unknown-.table	;v
	dc.w	.word-.table	;w
	dc.w	.hexa-.table	;x
	dc.w	.unknown-.table	;y
	dc.w	.unknown-.table	;z
	dc.w	.openacc-.table	;{
	dc.w	.unknown-.table	;|
	dc.w	.closacc-.table	;}
	dc.w	.unknown-.table	;~
	dc.w	.unknown-.table	;delta

.percent:	move.b	d1,(a4)+
	bra	.next_percent
.upper:	subq.w	#1,a3
	move.b	d1,(a4)+
	bra	.next_percent
.unknown:	illegal
	move.b	#'?',(a4)+
	bra	.percent_reached

;initiateurs
.memory:	st	MEMORY_FLAG(a5)
	bra	.percent_reached
.space:	move.b	#' ',PADDING_CHAR(a5)
	bra	.percent_reached
.zero:	move.b	#'0',PADDING_CHAR(a5)
	bra	.percent_reached
.equal:	st	EQUAL_FLAG(a5)
	bra	.percent_reached
;format numerique
.star:	move.l	STAR_PTR(a5),a0
	move.w	(a0)+,LEFT_SIZE(a5)
	move.l	a0,STAR_PTR(a5)
	bra	.percent_reached
.number:	subq.w	#1,a3
	moveq	#0,d0
	moveq	#0,d1
.n1:	move.b	(a3)+,d0
	sub.b	#'0',d0
	bmi.s	.end_number
	cmp.b	#9,d0
	bgt.s	.end_number
	mulu	#10,d1
	add.w	d0,d1
	bra.s	.n1
.end_number:
	subq.w	#1,a3
	tst.b	COLON_FLAG(a5)
	bne.s	.right_number
	move.w	d1,LEFT_SIZE(a5)
	bra	.percent_reached
.right_number:
	move.w	d1,RIGHT_SIZE(a5)
	bra	.percent_reached
.colon:	st	COLON_FLAG(a5)
	bra	.percent_reached
.plus:	st	SIGNED_FLAG(a5)
	bra	.percent_reached
.arobace:	st	PTR_FLAG(a5)
	move.l	(a2),NUMBER_PTR(a5)
	bra	.percent_reached

;size
.word:	move.w	#_WORD,NUMBER_SIZE(a5)
	bra	.percent_reached
.byte:	move.w	#_BEVEN,NUMBER_SIZE(a5)
	bra	.percent_reached
.odd:	move.w	#_BODD,NUMBER_SIZE(a5)
	bra	.percent_reached
.long:	move.w	#_LONG,NUMBER_SIZE(a5)
	bra	.percent_reached

;control
.openbra:	move.w	LEFT_SIZE(a5),FORMAT_COUNT(a5)	;nb de repetitions
	tst.b	PTR_FLAG(a5)
	beq.s	.next_bracket
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	;repartir en recursion
.next_bracket:
	;nb de chars restant
	move.l	d7,d0
	;buffer en l'etat
	move.l	a4,a0
	;format
	move.l	a3,a1
	move.l	STAR_PTR(a5),d1
	bsr	.sprintf
	;suite du buffer
	move.l	a0,a4
	;chars en moins
	sub.l	d0,d7
	ble.s	.no_more_bracket
	subq.w	#1,FORMAT_COUNT(a5)
	bgt	.next_bracket
.no_more_bracket:
	;suite du format apres %]
	move.l	a1,a3
	move.l	d1,STAR_PTR(a5)
	tst.b	PTR_FLAG(a5)
	beq	.next_percent
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent
.closbra:	bra	.end
.openacc:	move.l	a2,MIXED_PTR(a5)
	move.l	(a2),a2
	bra	.next_percent
.closacc:	move.l	MIXED_PTR(a5),a2
	bra	.next_percent

;terminateurs:
;.byte:
.char:	st	CHAR_FLAG(a5)
	tst.b	PADDING_CHAR(a5)
	beq.s	.zero_char
;.space_char:
	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_zero_char
	bsr	sprintf_space_char
	bra	.next_percent
.ptr_space_char:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_space_char
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent
.zero_char:
	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_zero_char
	bsr	sprintf_zero_char
	bra	.next_percent
.ptr_zero_char:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_zero_char
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent
.hexa:	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_hexa
	bsr	sprintf_hexa
	bra	.next_percent
.ptr_hexa:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_hexa
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent
.decimal:	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_decimal
	bsr	sprintf_decimal
	bra	.next_percent
.ptr_decimal:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_decimal
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent

.bin:	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_bin
	bsr	sprintf_bin
	bra	.next_percent
.ptr_bin:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_bin
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent

.float:
	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_single
	bsr	sprintf_single
	bra	.next_percent
.ptr_single:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_single
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent

.double:
	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_double
	bsr	sprintf_double
	bra	.next_percent
.ptr_double:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_double
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent

.extended:
	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_extended
	bsr	sprintf_extended
	bra	.next_percent
.ptr_extended:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_extended
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent

.packed:
	tst.b	PTR_FLAG(a5)
	bne.s	.ptr_packed
	bsr	sprintf_packed
	bra	.next_percent
.ptr_packed:
	move.l	a2,-(sp)
	move.l	NUMBER_PTR(a5),a2
	bsr	sprintf_packed
	move.l	(sp)+,a2
	addq.w	#4,a2
	bra	.next_percent

.right:	st	RIGHT_FLAG(a5)
	bra	.percent_reached
.string:	move.l	(a2)+,a0
	bsr	sprint_string
	clr.b	(a4)
	bra	.next_percent

pad_size_table:
 dc.w 4,2,2,8
pad_number:
 clr.b (a0)
 move.w d7,-(sp)
 lea LOCAL_STRING(a5),a1
 moveq #'0',d2
 move.b PADDING_CHAR(a5),d1
 beq.s .no_pad
 move.w LEFT_SIZE(a5),d3
 bne.s .not_default
 move.w NUMBER_SIZE(a5),d3
 move.w pad_size_table(pc,d3.w),d3
.not_default:
 move.l a0,d0
 sub.l a1,d0
 cmp.w d0,d3
 bgt.s .pad
 sub.w d3,d0
 add.w d0,a1
.pad:
 move.b (a1)+,d0
 beq.s .end
 cmp.b d2,d0
 bne.s .not_same
 move.b d1,(a4)+
 subq.w #1,d7
 bgt.s .pad
 bra.s .end
.not_same:
 move.b d0,(a4)+
 subq.w #1,d7
 beq.s .end
.pad_rest:
 move.b (a1)+,d0
 beq.s .end
 move.b d0,(a4)+
 subq.w #1,d7
 beq.s .end
 subq.w #1,d3
 bgt.s .pad_rest
 bra.s .end

.no_pad:
 move.b (a1)+,d0
 beq.s .end
 cmp.b d2,d0
 beq.s .no_pad
 move.b d0,(a4)+
 subq.w #1,d7
 beq.s .end
.strcpy:
 move.b (a1)+,(a4)
 beq.s .end
 addq.w #1,a4
 subq.w #1,d7
 bgt.s .strcpy
.end:
 move.w d7,d0
 sub.w (sp)+,d0
 bne.s .real_end
 move.b #'0',(a4)+
 subq.w #1,d7
.real_end:
 rts

;	clr.b	(a0)
;	move.w	d7,-(sp)
;	lea	LOCAL_STRING(a5),a1
;	moveq	#'0',d2
;	move.b	PADDING_CHAR(a5),d1
;	beq.s	.no_pad
;	move.w	LEFT_SIZE(a5),d3
;	bne.s	.not_default
;	move.w	NUMBER_SIZE(a5),d3
;	move.w	pad_size_table(pc,d3.w),d3
;.not_default:
;	;pb de size
;	move.l	a0,d0
;	sub.l	a1,d0
;	cmp.w	d0,d3
;	bgt.s	.pad
;	sub.w	d3,d0
;	add.w	d0,a1
;.pad:	move.b	(a1)+,d0
;	beq.s	.end
;	cmp.b	d2,d0
;	bne.s	.not_same
;	move.b	d1,(a4)+
;	subq.w	#1,d7
;	bgt.s	.pad
;	bra.s	.end
;.not_same:
;	move.b	d0,(a4)+
;	subq.w	#1,d7
;	beq.s	.end
;.pad_rest:
;	move.b	(a1)+,d0
;	beq.s	.end
;	move.b	d0,(a4)+
;	subq.w	#1,d7
;	beq.s	.end
;	subq.w	#1,d3
;	bgt.s	.pad_rest
;	bra.s	.end
;
;.no_pad:
;	move.b	(a1)+,d0
;	beq.s	.end
;	cmp.b	d2,d0
;	beq.s	.no_pad
;	move.b	d0,(a4)+
;	subq.w	#1,d7
;	beq.s	.end
;.strcpy:
;	move.b	(a1)+,(a4)
;	beq.s	.end
;	addq.w	#1,a4
;	subq.w	#1,d7
;	bgt.s	.strcpy
;.end:	;au moins un caractere
;	move.w	d7,d0
;	sub.w	(sp)+,d0
;	bne.s	.real_end
;	move.b	#'0',(a4)+
;	subq.w	#1,d7
;.real_end:
;	rts

sprintf_zero_char:
	move.w	NUMBER_SIZE(a5),d0
	lea	.table(pc),a0
	add.w	0(a0,d0.w),a0
	jmp	(a0)
.table:	dc.w	.word-.table
	dc.w	.even-.table
	dc.w	.odd-.table
	dc.w	.long-.table
.long:	move.b	(a2)+,d0
	beq.s	.next_1
	move.b	d0,(a4)+
.next_1:
	move.b	(a2)+,d0
	beq.s	.next_2
	move.b	d0,(a4)+
.next_2:
.word:	move.b	(a2)+,d0
	beq.s	.next_3
	move.b	d0,(a4)+
.next_3:
.odd:	move.b	(a2)+,d0
	beq.s	.next_4
	move.b	d0,(a4)+
.next_4:
	bra.s	.end
.even:	addq.w	#1,a2
	move.b	(a2)+,d0
	beq.s	.next_5
	move.b	d0,(a4)+
.next_5:
.end:	rts

sprintf_space_char:
	tst.b	MEMORY_FLAG(a5)
	bne.s	sprintf_mspace_char
	moveq	#' ',d1
	move.w	NUMBER_SIZE(a5),d0
	lea	.table(pc),a0
	add.w	0(a0,d0.w),a0
	jmp	(a0)
.table:	dc.w	.word-.table
	dc.w	.even-.table
	dc.w	.odd-.table
	dc.w	.long-.table
.long:	move.b	(a2)+,d0
	bne.s	.notnul1
	move.b	d1,d0
.notnul1:	move.b	d0,(a4)+
	move.b	(a2)+,d0
	bne.s	.notnul2
	move.b	d1,d0
.notnul2:	move.b	d0,(a4)+
.word:	move.b	(a2)+,d0
	bne.s	.notnul3
	move.b	d1,d0
.notnul3:	move.b	d0,(a4)+
.odd:	move.b	(a2)+,d0
	bne.s	.notnul4
	move.b	d1,d0
.notnul4:	move.b	d0,(a4)+
	bra.s	.end
.even:	addq.w	#1,a2
	move.b	(a2)+,d0
	bne.s	.notnul5
	move.b	d1,d0
.notnul5:	move.b	d0,(a4)+
.end:	rts

sprintf_mspace_char:
	moveq	#'%',d2			;echappement du '%'
	moveq	#' ',d1			;conversion du char null
	move.w	NUMBER_SIZE(a5),d0
	lea	.table(pc),a0
	add.w	0(a0,d0.w),a0
	jmp	(a0)
.table:	dc.w	.word-.table
	dc.w	.even-.table
	dc.w	.odd-.table
	dc.w	.long-.table
.long:	move.b	(a2)+,d0			;*
	bne.s	.notnul1
	move.b	d1,d0
	bra.s	.notper1
.notnul1:	cmp.b	d2,d0
	bne.s	.notper1
	move.b	d2,(a4)+
.notper1:	move.b	d0,(a4)+
	move.b	(a2)+,d0			;*
	bne.s	.notnul2
	move.b	d1,d0
	bra.s	.notper2
.notnul2:	cmp.b	d2,d0
	bne.s	.notper2
	move.b	d2,(a4)+
.notper2:	move.b	d0,(a4)+
.word:	move.b	(a2)+,d0			;*
	bne.s	.notnul3
	move.b	d1,d0
	bra.s	.notper3
.notnul3:	cmp.b	d2,d0
	bne.s	.notper3
	move.b	d2,(a4)+
.notper3:	move.b	d0,(a4)+
.odd:	move.b	(a2)+,d0			;*
	bne.s	.notnul4
	move.b	d1,d0
	bra.s	.notper4
.notnul4:	cmp.b	d2,d0
	bne.s	.notper4
	move.b	d2,(a4)+
.notper4:	move.b	d0,(a4)+
	rts

.even:	addq.w	#1,a2
	move.b	(a2)+,d0			;*
	bne.s	.notnul5
	move.b	d1,d0
	bra.s	.notper5
.notnul5:	cmp.b	d2,d0
	bne.s	.notper5
	move.b	d2,(a4)+
.notper5:	move.b	d0,(a4)+
.end:	rts

sprintf_hexa:
 movem.l a3-a4,-(sp)
 lea SprintfHexaTable(pc),a1
 lea LOCAL_STRING(a5),a4
	move.w	NUMBER_SIZE(a5),d0
	lea	.table(pc),a0
	add.w	0(a0,d0.w),a0
	jmp	(a0)
.table:	dc.w	.word-.table
	dc.w	.even-.table
	dc.w	.odd-.table
	dc.w	.long-.table
.long:
 moveq #0,d0
 move.b (a2)+,d0
 add.w d0,d0
 move.w 0(a1,d0.w),(a4)+
 moveq #0,d0
 move.b (a2)+,d0
 add.w d0,d0
 move.w 0(a1,d0.w),(a4)+
.word:
 moveq #0,d0
 move.b (a2)+,d0
 add.w d0,d0
 move.w 0(a1,d0.w),(a4)+
.odd:
 moveq #0,d0
 move.b (a2)+,d0
 add.w d0,d0
 move.w 0(a1,d0.w),(a4)+
 bra.s .end
.even:
 addq.w #1,a2
 moveq #0,d0
 move.b (a2)+,d0
 add.w d0,d0
 move.w 0(a1,d0.w),(a4)+
.end: 
 move.l a4,a0
 movem.l (sp)+,a3-a4	
 bra pad_number

SprintfHexaTable:
 dc.w '00','01','02','03','04','05','06','07'
 dc.w '08','09','0A','0B','0C','0D','0E','0F'
 dc.w '10','11','12','13','14','15','16','17'
 dc.w '18','19','1A','1B','1C','1D','1E','1F'
 dc.w '20','21','22','23','24','25','26','27'
 dc.w '28','29','2A','2B','2C','2D','2E','2F'
 dc.w '30','31','32','33','34','35','36','37'
 dc.w '38','39','3A','3B','3C','3D','3E','3F'
 dc.w '40','41','42','43','44','45','46','47'
 dc.w '48','49','4A','4B','4C','4D','4E','4F'
 dc.w '50','51','52','53','54','55','56','57'
 dc.w '58','59','5A','5B','5C','5D','5E','5F'
 dc.w '60','61','62','63','64','65','66','67'
 dc.w '68','69','6A','6B','6C','6D','6E','6F'
 dc.w '70','71','72','73','74','75','76','77'
 dc.w '78','79','7A','7B','7C','7D','7E','7F'
 dc.w '80','81','82','83','84','85','86','87'
 dc.w '88','89','8A','8B','8C','8D','8E','8F'
 dc.w '90','91','92','93','94','95','96','97'
 dc.w '98','99','9A','9B','9C','9D','9E','9F'
 dc.w 'A0','A1','A2','A3','A4','A5','A6','A7'
 dc.w 'A8','A9','AA','AB','AC','AD','AE','AF'
 dc.w 'B0','B1','B2','B3','B4','B5','B6','B7'
 dc.w 'B8','B9','BA','BB','BC','BD','BE','BF'
 dc.w 'C0','C1','C2','C3','C4','C5','C6','C7'
 dc.w 'C8','C9','CA','CB','CC','CD','CE','CF'
 dc.w 'D0','D1','D2','D3','D4','D5','D6','D7'
 dc.w 'D8','D9','DA','DB','DC','DD','DE','DF'
 dc.w 'E0','E1','E2','E3','E4','E5','E6','E7'
 dc.w 'E8','E9','EA','EB','EC','ED','EE','EF'
 dc.w 'F0','F1','F2','F3','F4','F5','F6','F7'
 dc.w 'F8','F9','FA','FB','FC','FD','FE','FF'
 dc.w '**'

; IN:
; D0 = Hexa number (L)
; D1 = 0 (unsigned conversion) / -1 (signed conversion)
; A0 = Buffer address
; OUT:
; D0 = String length
sprintf_decimal:
 move.l d4,-(sp)
 move.l a4,-(sp)
 lea LOCAL_STRING(a5),a4
 lea hex_dec_table(pc),a1
	move.w	NUMBER_SIZE(a5),d0
	lea	.table(pc),a0
	add.w	0(a0,d0.w),a0
	moveq	#0,d0
	jmp	(a0)
.table:	dc.w	.word-.table
	dc.w	.even-.table
	dc.w	.odd-.table
	dc.w	.long-.table
.word:
 move.w (a2),d0
 addq.w #2,a2
 bra.s .common
.odd:
 move.b (a2),d0
 addq.w #1,a2
 bra.s .common
.even:
 move.b 1(a2),d0
 addq.w #2,a2
 bra.s .common
.long:
 move.l (a2),d0
 addq.w #4,a2
.common:
 tst.b SIGNED_FLAG(a5)
 beq.s .unsigned
 tst.l d0
 bpl.s .unsigned
 neg.l d0
 move.b #'-',(a4)+
.unsigned:
 moveq #8,d4
.dec_loop:
 moveq #0,d2
 move.l (a1)+,d1
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
 sub.l d1,d0
 bcs.s .overflow
 addq.w #1,d2
.not_overflow:
 add.b #'0',d2
 move.b d2,(a4)+
 dbf d4,.dec_loop
 bra.s .last_char
.overflow:
 add.l d1,d0
 add.b #'0',d2
 move.b d2,(a4)+
 dbf d4,.dec_loop
.last_char:
 add.b #'0',d0
 move.b d0,(a4)+
decimal_end:
 move.l a4,a0
 move.l (sp)+,a4
 bsr pad_number
 move.l (sp)+,d4
 rts

hex_dec_table:
 dc.l 1000000000,100000000,10000000,1000000,100000,10000,1000,100,10

sprintf_bin:
 movem.l a3-a4,-(sp)
 lea .SprintfBinTable(pc),a1
 lea LOCAL_STRING(a5),a4
 move.w	NUMBER_SIZE(a5),d0
 lea .Table(pc),a0
 add.w 0(a0,d0.w),a0
 jmp (a0)
.Table:
 dc.w .Word-.Table
 dc.w .Even-.Table
 dc.w .Odd-.Table
 dc.w .Long-.Table
.Long:
 moveq #0,d0
 move.b (a2)+,d0
 lsl.w #3,d0
 move.l 0(a1,d0.w),(a4)+
 move.l 4(a1,d0.w),(a4)+
 moveq #0,d0
 move.b (a2)+,d0
 lsl.w #3,d0
 move.l 0(a1,d0.w),(a4)+
 move.l 4(a1,d0.w),(a4)+
.Word:
 moveq #0,d0
 move.b (a2)+,d0
 lsl.w #3,d0
 move.l 0(a1,d0.w),(a4)+
 move.l 4(a1,d0.w),(a4)+
.Odd:
 moveq #0,d0
 move.b (a2)+,d0
 lsl.w #3,d0
 move.l 0(a1,d0.w),(a4)+
 move.l 4(a1,d0.w),(a4)+
.Even:
 addq.w #1,a2
 moveq #0,d0
 move.b (a2)+,d0
 lsl.w #3,d0
 move.l 0(a1,d0.w),(a4)+
 move.l 4(a1,d0.w),(a4)+
.End: 
 move.l a4,a0
 movem.l (sp)+,a3-a4
 bra pad_number

.SprintfBinTable:
 dc.b '0000000000000001000000100000001100000100000001010000011000000111'
 dc.b '0000100000001001000010100000101100001100000011010000111000001111'
 dc.b '0001000000010001000100100001001100010100000101010001011000010111'
 dc.b '0001100000011001000110100001101100011100000111010001111000011111'
 dc.b '0010000000100001001000100010001100100100001001010010011000100111'
 dc.b '0010100000101001001010100010101100101100001011010010111000101111'
 dc.b '0011000000110001001100100011001100110100001101010011011000110111'
 dc.b '0011100000111001001110100011101100111100001111010011111000111111'
 dc.b '0100000001000001010000100100001101000100010001010100011001000111'
 dc.b '0100100001001001010010100100101101001100010011010100111001001111'
 dc.b '0101000001010001010100100101001101010100010101010101011001010111'
 dc.b '0101100001011001010110100101101101011100010111010101111001011111'
 dc.b '0110000001100001011000100110001101100100011001010110011001100111'
 dc.b '0110100001101001011010100110101101101100011011010110111001101111'
 dc.b '0111000001110001011100100111001101110100011101010111011001110111'
 dc.b '0111100001111001011110100111101101111100011111010111111001111111'
 dc.b '1000000010000001100000101000001110000100100001011000011010000111'
 dc.b '1000100010001001100010101000101110001100100011011000111010001111'
 dc.b '1001000010010001100100101001001110010100100101011001011010010111'
 dc.b '1001100010011001100110101001101110011100100111011001111010011111'
 dc.b '1010000010100001101000101010001110100100101001011010011010100111'
 dc.b '1010100010101001101010101010101110101100101011011010111010101111'
 dc.b '1011000010110001101100101011001110110100101101011011011010110111'
 dc.b '1011100010111001101110101011101110111100101111011011111010111111'
 dc.b '1100000011000001110000101100001111000100110001011100011011000111'
 dc.b '1100100011001001110010101100101111001100110011011100111011001111'
 dc.b '1101000011010001110100101101001111010100110101011101011011010111'
 dc.b '1101100011011001110110101101101111011100110111011101111011011111'
 dc.b '1110000011100001111000101110001111100100111001011110011011100111'
 dc.b '1110100011101001111010101110101111101100111011011110111011101111'
 dc.b '1111000011110001111100101111001111110100111101011111011011110111'
 dc.b '1111100011111001111110101111101111111100111111011111111011111111'

sprintf_single:
 movem.l a2-a4,-(sp)
 lea LOCAL_STRING(a5),a4
 clr.l -(sp)
 clr.l -(sp)
 clr.l -(sp)
 move.l (a2)+,-(sp)
 dc.w $f217,$4400			; fmove.s (sp),fp0
 addq.w #4,sp
 bra.s ConvFloat

sprintf_double:
 movem.l a2-a4,-(sp)
 lea LOCAL_STRING(a5),a4
 clr.l -(sp)
 clr.l -(sp)
 clr.l -(sp)
 subq.w #8,sp
 move.l (a2)+,(sp)
 move.l (a2)+,4(sp)
 dc.w $f217,$5400			; fmove.d (sp),fp0
 addq.w #8,sp
 bra.s ConvFloat

sprintf_packed:
 movem.l a2-a4,-(sp)
 lea LOCAL_STRING(a5),a4
 lea $c(sp),sp
 move.l (a2)+,(sp)
 move.l (a2)+,4(sp)
 move.l (a2)+,8(sp)
 bra.s ConvFloat2

sprintf_extended:
 movem.l a2-a4,-(sp)
 lea LOCAL_STRING(a5),a4
 clr.l -(sp)
 clr.l -(sp)
 clr.l -(sp)
 lea -$c(sp),sp
 move.w (a2)+,(sp)
 clr.w 2(sp)
 move.l (a2)+,4(sp)
 move.l (a2)+,8(sp)
 dc.w $f217,$4800			; fmove.x (sp),fp0
 lea $c(sp),sp
ConvFloat:
 dc.w $f217,$6c10			; fmove.p fp0,(sp){#$10}
ConvFloat2:
 move.l sp,a1
 move.w (a1),d0
 and.w #$fff,d0
 cmp.w #$999,d0
 bgt .InfiniteNANSNAN
 tst.l 4(a1)
 bne.s .InRange
 tst.l 8(a1)
 bne.s .InRange
.Zero:
 moveq #'+',d0
 tst.b (a1)
 bpl.s .PlusZero
.MinusZero:
 moveq #'-',d0
.PlusZero:
 move.b d0,(a4)+
 move.b #'0',(a4)+
 move.b #'.',(a4)+
 move.b #'0',(a4)+
.End:
 lea $c(sp),sp
 move.l a4,a0
 movem.l (sp)+,a2-a4
 bra pad_number

.InRange:
 lea SprintfHexaTable(pc),a2
 moveq #'+',d0
 tst.b (a1)
 bpl.s .PlusRange
.MinusRange:
 moveq #'-',d0
.PlusRange:
 move.b d0,(a4)+
 move.b 3(a1),d0
 and.w #$f,d0
 add.w #'0',d0
 move.b d0,(a4)+
 move.b #'.',(a4)+
 addq.w #4,a1
 moveq #7,d1
.MantissaLoop:
 moveq #0,d0
 move.b (a1)+,d0
 add.w d0,d0
 move.b 0(a2,d0.w),(a4)+
 move.b 1(a2,d0.w),(a4)+
 dbf d1,.MantissaLoop
 moveq #$f,d1
.CutMantissaLoop:
 cmp.b #'0',-(a4)
 dbne d1,.CutMantissaLoop
 addq.w #1,a4
 move.b #'e',(a4)+
 lea -$c(a1),a1
 moveq #'+',d0
 btst #6,(a1)
 beq.s .PlusExp
.MinusExp:
 moveq #'-',d0
.PlusExp:
 move.b d0,(a4)+
 moveq #0,d0
 move.b 2(a1),d0
 lsr.w #4,d0
 beq.s .Exp3Null
 add.w #'0',d0
 move.b d0,(a4)+
.Exp3Null:
 moveq #0,d0
 move.b (a1),d0
 and.w #$f,d0
 beq.s .Exp2Null
 add.w #'0',d0
 move.b d0,(a4)+
.Exp2Null:
 moveq #0,d0
 move.b 1(a1),d0
 lsr.b #4,d0
 beq.s .Exp1Null
 add.w #'0',d0
 move.b d0,(a4)+
.Exp1Null:
 moveq #0,d0
 move.b 1(a1),d0
 and.w #$f,d0
 add.w #'0',d0
 move.b d0,(a4)+
 bra .End

.InfiniteNANSNAN:
 cmp.w #$fff,d0
 bne.s .Unknown
 btst #6,(a1)
 beq.s .Unknown
 btst #5,(a1)
 beq.s .Unknown
 btst #4,(a1)
 beq.s .Unknown
 tst.l 4(a1)
 bne.s .NANSNAN
 tst.l 8(a1)
 bne.s .NANSNAN
 tst.l 4(a1)
 bne.s .NANSNAN
.Infinite:
 moveq #'+',d0
 tst.b (a1)
 bpl.s .PlusInfinite
.MinusInfinite:
 moveq #'-',d0
.PlusInfinite:
 move.b d0,(a4)+
 move.b #'ß',(a4)+
 bra .End

.NANSNAN:
 btst #6,4(a1)
 bne.s .NAN
.SNAN:
 move.b #'S',(a4)+
.NAN:
 move.b #'N',(a4)+
 move.b #'A',(a4)+
 move.b #'N',(a4)+
 bra .End

.Unknown:
 move.b #'?',(a4)+
 bra .End

sprint_string:
;				RAPHAEL
	move.w	LEFT_SIZE(a5),d0
	subq.w	#1,d0
	bmi.s	.no_pad
	tst.b	RIGHT_FLAG(a5)
	beq.s	.left_pad
;.right_pad:
	move.w	d0,d2
	bsr	StrLength
	sub.w	d0,d2
	bmi.s	.no_pad

	exg	d0,d2
	moveq	#' ',d1
.l2:
	move.b	d1,(a4)+
	subq.w	#1,d7
	dble	d0,.l2
	ble.s	.end
	move.w	d2,d0
	bra.s	.no_pad
.left_pad:
	move.b	(a0)+,(a4)+
	beq.s	.end_left_pad
	subq.w	#1,d7
	dble	d0,.left_pad
	rts
.end_left_pad:
	moveq	#' ',d1
.l1:
	move.b	d1,(a4)+
	subq.w	#1,d7
	dble	d0,.l1
	rts
.no_pad:
	move.b	(a0)+,(a4)+
	beq.s	.end_sub
	subq.w	#1,d7
	dble	d0,.no_pad
.end:
	rts
.end_sub:
	subq.w	#1,a4
	rts

;  #] Sprintf: 
;  #[ String Length:
;
; IN:
; A0 = String pointer
; OUT:
; D0 = String length
StrLength:
 move.l a0,-(sp)
 moveq #-1,d0
.loop:
 tst.b (a0)+
 dbeq d0,.loop
 not.w d0
 ext.l d0
 move.l (sp)+,a0
 rts

;  #] String Length: 
 DATA
;  #[ Strings:

Txt1:
 dc.b $1b,'E'
 dc.b 'JPEG DECODER STATISTICS:',$d,$a,0
Txt2:
 dc.b '    JPEG Size: %ld Bytes, %dx%d',$d,$a,0
Txt3:
 dc.b '   Image Size: %ld Bytes',$d,$a,0
Txt4:
 dc.b 'Decoding Time: %02d.%02d Second(s)',$d,$a,0
Txt6:
 dc.b '  Return Code: %+d',$d,$a,0
Txt7:
 dc.b 'Press any key',$d,$a,0

Txt8:
 dc.b 'Loading...',$d,$a,0
Txt9:
 dc.b 'Decoding...',$d,$a,0

ErrorDisplayTxt:
 dc.b 'Please Set True Color Mode...',$d,$a,0

;  #] Strings: 
 BSS
;  #[ BSS Section:

 ds.l 1000
MyStack:
 ds.l 1

MyDTA:
 ds.b 44

FilePointer:
 ds.l 1
FileSize:
 ds.l 1

ReturnCode:
 ds.w 1

CookieAddress:
 ds.l 1

DecoderReturnCode:
 ds.w 1

XOffset:
 ds.w 1
YOffset:
 ds.w 1
XMaxOffset:
 ds.w 1
YMaxOffset:
 ds.w 1

Time:
 ds.l 1

ImageXSize:				; Pixels
 ds.w 1
ImageYSize:				; Pixels
 ds.w 1
ImageAddress:
 ds.l 1
ImageRealXSize:				; Bytes
 ds.w 1

ScreenWidth:
 ds.w 1
ScreenHeight:
 ds.w 1
ScreenAddress:
 ds.l 1
ScreenOffset:
 ds.w 1

DummyScreen:
 ds.l 1

OldModeWord:
 ds.w 1
MonType:
 ds.w 1

 even

;  #] BSS Section: 
 END
