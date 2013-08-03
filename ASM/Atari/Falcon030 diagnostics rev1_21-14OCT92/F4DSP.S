*********************************
* DSP.S : Sparrow DSP routines
*--------------------------------
* V0.0 : 26MAR92 : RWS : Works
* V1.0 : 24APR92 : RWS : Made into Falcon test - uses RAM
*--------------------------------

.macro TRISTATEMATRIX
	move.w	#$0000,DATAMXSRC
	move.w	#$0000,DATAMXREC
.endm

	.include	"68040.s"
	.include 	sermacs
	.include	f4def
	.include	f4mac
	
	.extern	Prompt
	.globl	DSP

NORAM = 0	; can use RAM

	.text
*--------------------------------------------
* New Bindings for Sparrow Diagnostic code

dspmsg:
	movem.l	d0-d7/a0-a7,-(sp)
	DMSG2				; send (a5) to serial
	movem.l	(sp)+,d0-d7/a0-a7
	rts
dspbyt:
	movem.l	d0-d7/a0-a7,-(sp)
	move.l	d1,d0
	DSPBYT
	movem.l	(sp)+,d0-d7/a0-a7
	rts
dspwrd:
	movem.l	d0-d7/a0-a7,-(sp)
	move.l	d1,d0
	DSPWRD
	movem.l	(sp)+,d0-d7/a0-a7
	rts
dspadd:
	movem.l	d0-d7/a0-a7,-(sp)
	move.l	a0,d0
	DSPLONG
	movem.l	(sp)+,d0-d7/a0-a7
	rts
crlf:
	movem.l	d0-d7/a0-a7,-(sp)
	CRLF
	movem.l	(sp)+,d0-d7/a0-a7
	rts

;
; DSP Host interface constants
;
DSPICR	=	$ffffa200		; Interrupt Control Register
DSPCVR	=	$ffffa201		; Command Vector Register
DSPISR	=	$ffffa202		; Interrupt Status Register
DSPIVR	=	$ffffa203		; Interrupt Vector Register
DSPRXH	=	$ffffa205		; Receive byte High
DSPRXM	=	$ffffa206		; Receive byte Mid
DSPRXL	=	$ffffa207		; Receive byte Low
DSPTXH	=	$ffffa205		; Transmit byte High
DSPTXM	=	$ffffa206		; Transmit byte Mid
DSPTXL	=	$ffffa207		; Transmit byte Low

; HOSTVECT =	$3fc			; interrupt vector number 255

; define test result codes for SSI loopback
LB_TESTING	EQU	$000050		; testing begun (not passed)
LB_TIMEOUT	EQU	$000051		; no data received (failure)
LB_NOT_EQUAL	EQU	$000052		; data recv != data xmit (failure)
LB_SUCCESS	EQU	$000053		; test successful (pass)

;* Test IDs for RAM1 Test
MT_TESTING		EQU	$111111	; test started, but not yet passed
MT_SUCCESS		EQU	$123456	; Test passed
MT_ALL_ONES		EQU	$200000 ; Leave the LS bits = 0 for OR ing with the address.
MT_ALL_ZEROS		EQU	$300000
MT_ALL_AA		EQU	$400000
MT_ALL_55		EQU	$500000
MT_RANDOM		EQU	$600000
MT_WALK_ONES		EQU	$700000


*------------------------
DSP:
	DSPMSG	DSPMsg
	GETUCHAR
	PCHAR d0
	cmpi.b	#'1',d0
	beq	TestSRAM
	cmpi.b	#'2',d0
	beq	TestSSI
	cmpi.b	#'B',d0
	beq	Beatlock
ToMenu:
	bra	Prompt     

TestSRAM:
;	PCHAR d0
	bsr	DSPRAMTEST
	bra	ToMenu   

TestSSI:
;	PCHAR d0
	bsr	DSPSSITEST
	bra	ToMenu   

Beatlock:
	move.b	DSPICR,d0
	CHECKIN
	bmi	ToMenu
	bra	Beatlock

*-------------------------
* DSPLoad - load a program into DSP
* entry: a0 = address of DSP code in 32 bit LW's (upper byte = 0)
* (terminated by $ffffffff)
* format is {DATA P0 implied} $00XXXXXX ... $ffffffff (endmark)
* exit:	DSP ready to go..
DSPLoad:
	movem.l	d0-d1/a0,-(sp)
; - RESET DSP
;;	bset.b	#1,DDR2		; set MFP i/o bit 3 to output
;;	bclr.b	#1,GPIP2		; set bit 3 i/o low

	move.b	#7,PSGA
	move.b	#$c0,PSGW
	move.b	#14,PSGA
	move.b	#00,PSGW
	move.b	#14,PSGA
	move.b	#$10,PSGW

	move.l	#$ffff,d1	; wait a bit (was : 1 tick of 200Hz) dunno if this is long enuf.
.dly:
	nop			; bubbles in the pipe!
	nop
	dbra	d1,.dly
	
	move.b	#14,PSGA
	move.b	#00,PSGW

;	bset.b	#1,GPIP2	; set bit 3 high

; - DUMP IN DATA
.dump1:
	move.l	(a0)+,d0	; get next DSP data word
	bmi	.exit		; non zero MSbit = exit
	bsr	.DoLoad		; no, send it to DSP
	bra	.dump1     
.exit:
	movem.l	(sp)+,d0-d1/a0
	rts
*---------------------------
* loads a longword in d0 into DSP (lower 3 bytes ONLY)
.DoLoad:
	swap	d0		; I hope handshaking is in hardware
	move.b	d0,DSPTXH
	rol.l	#8,d0
	move.b	d0,DSPTXM
	rol.l	#8,d0
	move.b	d0,DSPTXL
	rts
*---------------------------
* loads d0.l from DSP (lower 3 bytes ONLY)
DSPRead:			; I hope handshaking is in hardware
	clr.l	d0
	move.b	DSPTXH,d0
	rol.l	#8,d0
	move.b	DSPTXM,d0
	rol.l	#8,d0
	move.b	DSPTXL,d0
	rts

*----------------------------
* DSPRun - starts the DSP executing
* if less than 512 words loaded into DSP ram
DSPRun:
;- SET HF0 in Host ICR
	bset.b	#3,DSPICR	;set flag 0 to 1 to signal end of transfer
	rts

*------------------------------------
* SSI LOOPBACK TEST (comments from SSI.asm)
* Test of DSP56k's SSI port by connecting it back to itself. 
* To perform this test, connect:
*	STD to SRD
*	SCK to SC0	(SCK output, SC0 input, asynchronous mode clocks)
*	SC1 to SC2	(mode to be defined)

;*  The SSI loopback test will begin by writing LB_TESTING to the 56k's
;*  Host Interface Data Register, HTX.  It will then try to send and
;*  receive LB_NUM_WORDS via the SSI in loopback mode.  If the received
;*  data does not match the transmitted data, it will return LB_NOT_EQUAL
;*  to the HTX register.  If the test times-out while waiting for data to
;*  be received, then it will send a LB_TIMEOUT to the HTX register.  If 
;*  it sends and receives all of the words correctly, it will send a
;*  LB_SUCCESS to the HTX register.  If the test fails completely, then
;*  LB_TESTING will be left in the HTX register, so the host (your 68xxx
;*  CPU) should give up after 2-3 seconds and consider the test hung (a
;*  failure).  See the section, Initialize SSI Port (baud rate
;*  determination by setting CRA_BITS), for timing information.

* You can test this program by disconnecting wires in the loopback.
* If you disconnect STD-SRD you should get a LB_NOT_EQUAL
* If you disconnect SCK-SC0 you should get a LB_TIMEOUT
* If you disconnect SC1-SC2 you should get a LB_TIMEOUT

DSPSSITEST:
; - TURN OFF CACHE
;	movecacrd0
;	move.l	d0,d3		; save old cache status
;	move.l	#$00000000,d0	; DISABLE I & D CACHES on 030
;	moved0cacr

	lea.l	DSPL0msg,a5
	bsr	dspmsg

	lea.l	DSPSSIHEX,a0
	bsr	DSPLoad
	bsr	DSPRun
	move.l	#$fffff,d1
.isstart:
	btst.b	#0,DSPISR	; wait for data ready bit
	bne	.getdata
	subq.l	#1,d1
	bne	.isstart	
	bra	.notstart	; timed out
.getdata:
	bsr	DSPRead
	cmpi.l	#LB_TESTING,d0	;if not testing, error not started
	beq	.started
	bra	.notstart
.started:
	move.l	#$fffff,d1
.isdone:
	btst.b	#0,DSPISR	; wait for data ready bit
	bne	.getdata2
	subq.l	#1,d1
	bne	.isdone	
	bra	.notdone	; timed out while running
.getdata2:
	bsr	DSPRead		; the next thing out will be a message
 	cmpi.l	#LB_SUCCESS,d0
	beq	.success
	cmpi.l	#LB_TIMEOUT,d0
	bne	.ntime
	lea.l	DSPL2err,a5	; timeout error
	bsr	dspmsg
	bra	.fail
.ntime:
	cmpi.l	#LB_NOT_EQUAL,d0	;not same data error
	bne	.notdone
	lea.l	DSPL3err,a5
	bsr	dspmsg
	bra	.fail
.notstart:
	lea.l	DSPL0err,a5
	bsr	dspmsg
	bra	.fail
.notdone:
	lea.l	DSPL1err,a5
	bsr	dspmsg
.fail:				; - DO FAIL STUFF
	movea.l	#failmsg,a5
	bsr	dspmsg
*	move.w	#red,palette
	bra	.exit
.success:
	movea.l	#passmsg,a5
	bsr	dspmsg
	bsr	crlf
*	move.w	#green,palette  
; - DO PASS STUFF!
.exit:
;	move.l	d3,d0	; RESTORE CACHES
;	moved0cacr
	rts

*------------------------------------
* DSP RAM TEST (comments from RAM1.asm)
;* When the program begins testing, it writes a MT_TESTING to the Host
;* Interface data register, HTX.  If the test succeeds, MT_SUCCESS will 
;* be put in the HTX register.  If it fails, the test ID will be ORed 
;* with the 16 bit address of the memory that failed and put in the HTX
;* register.  For example, if a $604E5F is returned, the $6 means the
;* random value memory test (see Test IDs below) failed at address $4E5F.
;* The test indicates memory failure if the host (68xxx CPU) does not 
;* see a MT_SUCCESS flag in a few seconds (or the program has died from 
;* a 56k failure.  The complete RAM test took 0.78 seconds on a 27 Mhz 
;* 56001.  Most of the time is spent running the WalkingOnes test.

DSPRAMTEST:
; - TURN OFF CACHE
;	movecacrd0
;	move.l	d0,d3		; save old cache status
;	move.l	#$00000000,d0	; DISABLE I & D CACHES on 030
;	moved0cacr
	lea.l	DSPR0msg,a5
	bsr	dspmsg
	lea.l	DSPRAM1HEX,a0
	bsr	DSPLoad
	bsr	DSPRun
	move.l	#$fffff,d1
.isstart:
	btst.b	#0,DSPISR	; wait for data ready bit
	bne	.getdata
	subq.l	#1,d1
	bne	.isstart	
	bra	.notstart	; timed out
.getdata:
	bsr	DSPRead
	cmpi.l	#MT_TESTING,d0
	beq	.started
	bra	.notstart	; some strange error here.. not running code though
.started:
	move.l	#$fffff,d1
.isdone:
	btst.b	#0,DSPISR	; wait for data ready bit
	bne	.getdata2
	subq.l	#1,d1
	bne	.isdone	
	bra	.notdone	; timed out while running
.getdata2:
	bsr	DSPRead
	cmpi.l	#MT_SUCCESS,d0
	beq	.success
	lea.l	DSPR2err,a5
	bsr	dspmsg
	move.l	d0,a0
	bsr	dspadd		; show failure code
	bsr	crlf
	bra	.fail
.notstart:
.notdone:			; timedout
	lea.l	DSPR1err,a5
	bsr	dspmsg
; - DO FAIL STUFF!
.fail:
	movea.l	#failmsg,a5
	bsr	dspmsg
;	move.w	#red,palette
	bra	.exit
.success:
	move.l	#passmsg,a5
	bsr	dspmsg
	bsr	crlf
*	move.w	#green,palette
; - DO PASS STUFF!
.exit:
;	move.l	d3,d0	; RESTORE CACHES
;	moved0cacr
	rts

*------------------------------------
*------------------------------------
* SAMPLE DSPCODE FROM DSPBIND.ASM
* GO LOOK THERE IF YOU WANT IT.

	.data

******************************
* DSP HEX CODE BELOW!
******************************

*------------------------
* SSI test 27MAR92 : RWS
* sent from SUVL - source in \dsp\dsptests\ssi.asm
* CHANGED SLIGHTLY 27MAR92 : RWS
*------------------------
SSIDELY	=	$006102		;bit time delay	!!NOTE!! THESE VALUES FAIL IF A LONG CABLE 
SSIWAIT	=	$000000		;0ws ram        IS USED FOR LOOPBACK. KEEP IT SHORT!!
	.even
DSPSSIHEX:
;_START SSI1 0000 0000 0000 DSP56000 4.1.1 
;
;_DATA P 0000
	dc.l	$0C0040 
; - nop out to program at $40
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000	; ,$000000 ;<-???
;_DATA P 0040
	dc.l	$0003F8,$08F4BE,SSIWAIT,$08F4AB,$000050,$0BF080,$00006F,$0BF080 
	dc.l	$00004D,$08F4AB,$000053,$0AF080,$00006D,$0004FA,$60F400,$000100 
	dc.l	$05FFA0,$200013,$2C0100,$218700,$54F400,$00EA60,$4CD800,$08C42F 
	dc.l	$57F400,$001500,$0AAEA7,$000062,$20007C,$0E705A,$08F4AB,$000051 
	dc.l	$0AF080,$00006D,$084F2F,$20004D,$0AF0A2,$000069,$200074,$0E7056 
	dc.l	$00000C,$08F4AB,$000052,$0AF080,$00006D,$000086,$0C006D,$08F4BF 
	dc.l	$002C00,$08F4AC,SSIDELY,$08F4A3,$000000,$08F4A1,$0001FF,$0BAE24 
	dc.l	$08F4AF,$000000,$08F4AD,$003130,$00000C 
;_SYMBOL P
;SineTest             I 00004D
;BadData              I 000069
;DeadLoop             I 00006D
;SetupSSI             I 00006F
;_END 0000
	dc.l	$ffffffff

*------------------------
* RAM1 test 26MAR92 : RWS
* sent from SUVL - source in \dsp\dsptests\ram1.asm
*------------------------
DSPRAM1HEX:
;_START RAM1 0000 0000 0000 DSP56000 4.1.1 
;_DATA P 0000
	dc.l	$0C0040 
; - nop out to program at $40
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
	dc.l	$000000,$000000,$000000 ;- $000000 ???
;_DATA P 0040
	dc.l	$0003F8,$08F4BE,$000000,$08F4AB,$111111,$0BF080,$00004F,$0BF080 
	dc.l	$00009A,$0BF080,$000078,$08F4AB,$123456,$0AF080,$0000BF,$272000 
	dc.l	$44F400,$FFFFFF,$0BF080,$000063,$273000,$240000,$0BF080,$000063 
	dc.l	$274000,$44F400,$AAAAAA,$0BF080,$000063,$275000,$44F400,$555555 
	dc.l	$0BF080,$000063,$00000C,$60F400,$000200,$45F400,$007E00,$06C520 
	dc.l	$075884,$60F400,$000200,$45F400,$007E00,$56F400,$C3C3C3,$06C500 
	dc.l	$000076,$07E08F,$20004D,$07588E,$0AF0A2,$0000C1,$000000,$00000C 
	dc.l	$277000,$20001B,$240000,$0BF080,$000093,$60F400,$000200,$45F400 
	dc.l	$007E00,$200013,$06C500,$000091,$2C0100,$061880,$00008F,$07508C 
	dc.l	$07588F,$07E084,$218E00,$200045,$0AF0A2,$0000C2,$200032,$000000 
	dc.l	$200013,$07588E,$00000C,$60F400,$000200,$45F400,$007E00,$06C520 
	dc.l	$075884,$00000C,$276000,$60F400,$000200,$45F400,$007E00,$57F400 
	dc.l	$987654,$06C500,$0000A9,$20003A,$0AF0A5,$0000A9,$46F400,$1D872B 
	dc.l	$20005B,$07588D,$60F400,$000200,$45F400,$007E00,$57F400,$987654 
	dc.l	$06C500,$0000BD,$20003A,$0AF0A5,$0000B8,$46F400,$1D872B,$20005B 
	dc.l	$21AE00,$07D884,$200045,$0AF0A2,$0000C1,$000000,$00000C,$000086 
	dc.l	$0C00BF,$07F88E,$220F00,$20007A,$08CD2B,$0C00BF 
;_SYMBOL P
;SingleTests          I 00004F
;AllSame              I 000063
;WalkingOnes          I 000078
;PaintMem             I 000093
;RandomTest           I 00009A
;FillRandLoop         I 0000AA
;CheckRandLoop        I 0000BE
;DeadLoop             I 0000BF
;BadTest              I 0000C1
;BadWord              I 0000C2
;_END 0000
	dc.l	$ffffffff

** ERROR MESSAGES **

DSPL0msg:	dc.b	'Testing DSP SSI Loopback... ',EOT
DSPL0err:	dc.b	'DSP Not Executing Program',CR,LF,EOT
DSPL1err:	dc.b	'SSI Test Timeout',CR,LF,EOT
DSPL2err:	dc.b	'SSI Loopback Timeout',CR,LF,EOT
DSPL3err:	dc.b	'SSI Bad Data',CR,LF,EOT

DSPR0msg:	dc.b	'Testing DSP SRAM... ',EOT
DSPR1err:	dc.b	'SRAM Test Timeout',CR,LF,EOT
DSPR2err:	dc.b	'SRAM Fail: ',EOT
failmsg:	dc.b	' Fail ',EOT
passmsg:	dc.b	' Pass ',EOT
 
DSPMsg:		dc.b	CR,LF,'DSP [1|2]: ',EOT
