	.include hardware
	.include defs
	.include nvram
	.include macros
	.include "scrn16.gbl"
	.extern pasmsg,falmsg,erflg0,dspreg
	.extern	DSPRAMTEST,DSPSSITEST,dsptest

*********************************
* DSP.S : Sparrow DSP routines
*--------------------------------
* V0.0 : 26MAR92 : RWS : Works
* V0.1 : 20MAY92 : RWS : Hacked up for RTC status bits.
* V0.2 : 11JUL92 : RWS : Changed for Rev. 3 boards
*--------------------------------
 DSPREV = 2

.macro TRISTATEMATRIX
	move.w	#$0000,DATAMXSRC
	move.w	#$0000,DATAMXREC
.endm

.macro SSISTATEMATRIX
;	move.w	#$0010,DATAMXSRC
;	move.w	#$0010,DATAMXREC
	move.w	#$0008,DACRECCTRL	; global sound reset
	nop
	move.w	#$0000,DACRECCTRL
;	move.w	#$0000,DATAMXSRC
;	move.w	#$0000,DATAMXREC
.endm

	.text
;
; DSP Host interface constants
;
.if DSPREV = 0
DSPICR	=	$ffffa201		; Interrupt Control Register
DSPCVR	=	$ffffa203		; Command Vector Register
DSPISR	=	$ffffa205		; Interrupt Status Register
DSPIVR	=	$ffffa207		; Interrupt Vector Register
DSPRXH	=	$ffffa20b		; Receive byte High
DSPRXM	=	$ffffa20d		; Receive byte Mid
DSPRXL	=	$ffffa20f		; Receive byte Low
DSPTXH	=	$ffffa20b		; Transmit byte High
DSPTXM	=	$ffffa20d		; Transmit byte Mid
DSPTXL	=	$ffffa20f		; Transmit byte Low
.endif
.if DSPREV = 1
DSPICR  =       $ffffa200
DSPCVR  =       $ffffa202
DSPISR  =	$ffffa204
DSPIVR  =       $ffffa206
DSPRXH  =       $ffffa20a
DSPRXM  =       $ffffa20c
DSPRXL  =       $ffffa20e
DSPTXH  =       $ffffa20a
DSPTXM  =       $ffffa20c
DSPTXL  =       $ffffa20e
.endif
.if DSPREV = 2
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
.endif

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


*-------------------------
* DSP TESTS FROM MENU
;dsptest:
;	lea.l	dspm,a5
;	bsr	dsptst
;	bsr	DSPRAMTEST
;	move.l	a5,d2
;	bsr	DSPSSITEST	; test DSP SSI CONNECTOR
;	cmp.l	#pasmsg,a5
;	bne	.Fail
;	cmp.l	#pasmsg,d2
;	bne	.Fail
;.Pass:
;	RTCSETPASS #t_DSP
;	rts
;.Fail:
;	RTCSETFAIL #t_DSP
;	lea.l	falmsg,a5
;	move.w	#red,palette
;	rts

.if 0
*-------------------------
* DSPLoad - load a program into DSP
* entry: a0 = address of DSP code in 32 bit LW's (upper byte = 0)
* (terminated by $ffffffff)
* format is {DATA P0 implied} $00XXXXXX ... $ffffffff (endmark)
* exit:	DSP ready to go..
DSPLoad:
	movem.l	d0-d1/a0,-(sp)
; - RESET DSP
;	bset.b	#3,mfp+ddr	; set MFP i/o bit 3 to output
;	bclr.b	#3,mfp+gpip	; set bit 3 i/o low
	
	bsr	DSPRead		;get any junk out of host port

	move.b	#7,psgsel
	move.b	#$c0,psgwr
	move.b	#14,psgsel
	move.b	#00,psgwr
	move.b	#14,psgsel
	move.b	#$10,psgwr

	move.w	#$ffff,d1	; wait a bit (was : 1 tick of 200Hz) dunno if this is long enuf.
.dly:
	nop			; bubbles in the pipe!
	nop
	dbra	d1,.dly
	
	move.b	#14,psgsel
	move.b	#00,psgwr

;	bset.b	#3,mfp+gpip	; set bit 3 high

; - DUMP IN DATA
.dump0:	
	move.l	(a0)+,d0	; get first word
	bmi	.exit
	bsr	.DoLoad
	clr.w	d1
	move.b	d0,d1
	sub.w	#1,d1
	move.l	#0,d0
.lp:				; fill up NOP space (to $40 usually)
	bsr	.DoLoad
	nop
	dbra	d1,.lp
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
	move.l	d0,DSPTXH-1
;	swap	d0		; I hope handshaking is in hardware
;	move.b	d0,DSPTXH
;	rol.l	#8,d0
;	move.b	d0,DSPTXM
;	rol.l	#8,d0
;	move.b	d0,DSPTXL
	rts
.endif
*-------------------------
* DSPLoad - load a program into DSP
* entry: a0 = address of DSP code in 32 bit LW's (upper byte = 0)
* (terminated by $ffffffff)
* format is {DATA P0 implied} $00XXXXXX ... $ffffffff (endmark)
* exit:	DSP ready to go..
OldDSPLoad:
	movem.l	d0-d1/a0,-(sp)
; - RESET DSP
;;	bset.b	#1,DDR2		; set MFP i/o bit 3 to output
;;	bclr.b	#1,GPIP2		; set bit 3 i/o low

	move.b	#7,psgsel
	move.b	#$c0,psgwr
	move.b	#14,psgsel
	move.b	#00,psgwr
	move.b	#14,psgsel
	move.b	#$10,psgwr

	move.l	#$ffff,d1	; wait a bit (was : 1 tick of 200Hz) dunno if this is long enuf.
.dly:
	nop			; bubbles in the pipe!
	nop
	dbra	d1,.dly
	
	move.b	#14,psgsel
	move.b	#00,psgwr

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
	move.l	d0,DSPTXH-1
;	swap	d0		; I hope handshaking is in hardware
;	move.b	d0,DSPTXH
;	rol.l	#8,d0
;	move.b	d0,DSPTXM
;	rol.l	#8,d0
;	move.b	d0,DSPTXL
	rts
*---------------------------
* loads d0.l from DSP (lower 3 bytes ONLY)
DSPRead:			; I hope handshaking is in hardware
	move.l	DSPTXH-1,d0
	andi.l	#$00ffffff,d0
;	clr.l	d0
;	move.b	DSPTXH,d0
;	rol.l	#8,d0
;	move.b	DSPTXM,d0
;	rol.l	#8,d0
;	move.b	DSPTXL,d0
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
;;RWS.TPEX	move.l	d2,-(sp)
;;	clr.b	d2		; OnceFlag
;;RWS.TPE	bclr.b	#5,SPControl	; turn off bus errors. 
	movecacrd0
	move.l	d0,d3		; save old cache status
	move.l	#$00000000,d0	; DISABLE I & D CACHES on 030
	moved0cacr

	SSISTATEMATRIX

	lea.l	DSPL0msg,a5
	bsr	dspmsg
.ReTest:
;RWS.TPED	move.b	#'.',d1
;	bsr	ascii_out

   	lea.l	DSPSSIHEX,a0
	bsr	OldDSPLoad
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
;;RWS.TPED	cmpi.b	#3,d2		;OnceFlag
;;	bgt	.Lost
;;	addq.b	#1,d2		; ok, one more try
;;	bra.s	.ReTest
.Lost:
	lea.l	DSPL2err,a5	; timeout error
	bra	.fail
.ntime:
	cmpi.l	#LB_NOT_EQUAL,d0	;not same data error
	bne	.notdone
	lea.l	DSPL3err,a5
	bra	.fail
.notstart:
	lea.l	DSPL0err,a5
	bra	.fail
.notdone:
	lea.l	DSPL1err,a5
	bsr	dspmsg
.fail:				; - DO FAIL STUFF
	or.b	#1,erflg0
	bsr	dspmsg		;show off message
	movea.l	#falmsg,a5
*	bsr	dspmsg
	move.w	#red,palette
	bra	.exit
.success:
	movea.l	#pasmsg,a5
	bsr	dspmsg
	bsr	crlf
*	move.w	#green,palette  
; - DO PASS STUFF!
.exit:
	move.l	d3,d0	; RESTORE CACHES
	moved0cacr
;;RWS.TPE	bset.b	#5,SPControl	; turn on bus errors. 
;;RWS.TPED	move.l	(sp)+,d2
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
	lea.l	DSPR0msg,a5
	bsr	dspmsg
.DRAMT:
; - TURN OFF CACHE
;;RWS.TPE	bclr.b	#5,SPControl	; turn off bus errors. 
	movecacrd0
	move.l	d0,d3		; save old cache status
	move.l	#$00000000,d0	; DISABLE I & D CACHES on 030
	moved0cacr
	
	TRISTATEMATRIX

;	lea.l	DSPRAM1HEX,a0
;	bsr	OldDSPLoad
;	bsr	DSPRun
	lea.l	DSPRAM1HEX,a0
	bsr	OldDSPLoad
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
	cmpi.l	#MT_TESTING,d0	;RWS.T attempt to fix the dsp power on prob.
	beq	.started	;RWS.T
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
;;;RWS.TPE 1.18d	sub.w	#1,tries
;;;	bne	DSPRAMTEST
;TEMP FOR TAIWAN RUN #1 (for some reason sound only works occasionally)
*	movea.l	#falmsg,a5
	move.w	#red,palette
	or.b	#1,erflg0	; set RAM fail bit
	bra	.exit
.success:
	move.l	#pasmsg,a5
	bsr	dspmsg
	bsr	crlf
*	move.w	#green,palette
; - DO PASS STUFF!
.exit:
	move.l	d3,d0	; RESTORE CACHES
	moved0cacr
;;RWS.TPE	bset.b	#5,SPControl	; turn on bus errors. 
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
SSIDELY	=	$006100		;bit time delay	!!NOTE!! THESE VALUES FAIL IF A LONG CABLE 
;SSIDELY	=	$006400		;bit time delay	!!NOTE!! THESE VALUES FAIL IF A LONG CABLE 
SSIWAIT	=	$000000		;0ws ram        IS USED FOR LOOPBACK. KEEP IT SHORT!!

SSIMAXW	=	$001500	; max wait for chars
;SSIMAXW	=	$015000	; max wait for chars

SSITSTG	=	$000050
SSITIMO	=	$000051
SSINEQU	=	$000052
SSISUCC	=	$000053

; SSITSTG	=	$222222
; SSITIMO	=	$122334
; SSINEQL	=	$112233
; SSISUCC	=	$654321

	.even
.if 0
DSPSSIHEX:
;_START SSI1 0000 0000 0000 DSP56000 4.1.1 
;
;_DATA P 0000
	dc.l	$0C0040 
; - nop out to program at $40
;	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
;	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
;	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
;	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
;	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
;	dc.l	$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000,$000000
;	dc.l	$000000,$000000,$000000	; ,$000000 ;<-???
;_DATA P 0040
	dc.l	$0003F8,$08F4BE,SSIWAIT,$08F4AB,SSITSTG,$0BF080,$00006F,$0BF080 
	dc.l	$00004D,$08F4AB,SSISUCC,$0AF080,$00006D,$0004FA,$60F400,$000100 
	dc.l	$05FFA0,$200013,$2C0100,$218700,$54F400,$00EA60,$4CD800,$08C42F 
	dc.l	$57F400,$001500,$0AAEA7,$000062,$20007C,$0E705A,$08F4AB,SSITIMO 
	dc.l	$0AF080,$00006D,$084F2F,$20004D,$0AF0A2,$000069,$200074,$0E7056 
	dc.l	$00000C,$08F4AB,SSINEQL,$0AF080,$00006D,$000086,$0C006D,$08F4BF 
	dc.l	$002C00,$08F4AC,SSIDELY,$08F4A3,$000000,$08F4A1,$0001FF,$0BAE24 
	dc.l	$08F4AF,$000000,$08F4AD,$003130,$00000C 
;_SYMBOL P
;SineTest             I 00004D
;BadData              I 000069
;DeadLoop             I 00006D
;SetupSSI             I 00006F
;_END 0000
	dc.l	$ffffffff
.endif
*---
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
	dc.l	$57F400,$015000	; was 001500
	dc.l	$0AAEA7,$000062,$20007C,$0E705A,$08F4AB,$000051 
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
dspm:		dc.b	'Testing DSP',eot
DSPL0msg:	dc.b	'Testing DSP SSI Loopback... ',eot
DSPL0err:	dc.b	'DSP0 - DSP Not Executing Program',cr,lf,eot
DSPL1err:	dc.b	'DSP1 - SSI Test Timeout',cr,lf,eot
DSPL2err:	dc.b	'DSP2 - SSI Loopback Timeout',cr,lf,eot
DSPL3err:	dc.b	'DSP3 - SSI Bad Data',cr,lf,eot

DSPR0msg:	dc.b	'Testing DSP SRAM... ',eot
DSPR1err:	dc.b	'DSP4 - SRAM Test Timeout',cr,lf,eot
DSPR2err:	dc.b	'DSP5 - SRAM Fail: ',eot


