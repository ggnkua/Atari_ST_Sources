*------------------------------------------------
* Sysctrl.s - display & change sparrow controls
*	By Roy Stedman @ Atari : 16JAN92
*------------------------------------------------
* V 1.1 : 18MAY92 : RWS : MCUG & Powerfail bit removed

	.include hardware
	.include defs

	.text

	.globl	clearsc,dspinv,dspmsg,uconin,SysControl

SysControl:
 	bsr	clearsc		; Clear Screen, Setup & etc..
	lea	scTemplMsg,a5	; Draw template
	bsr	dspinv

* display current settings
	move.b	SPControl,d0
	andi.w	#$00FF,d0	; get low byte

* ADDRESS BUS ERROR
	lea	scABEEnMsg,a5
	bsr	dspinv
	btst	#5,d0
	bsr	scDispAble
* BLITTER CLOCK
	lea	scBltClkMsg,a5
	bsr	dspinv
	btst	#2,d0
	bsr	scDispClk2
* CPU CLOCK
	lea	scSysClkMsg,a5
	bsr	dspinv
	btst	#0,d0
	bsr	scDispClk
* BLITTER
	lea	scBltEnMsg,a5
	bsr	dspinv
	btst	#3,d0
	bsr	scDispAble
* MCUG
;	lea	scMCUEnMsg,a5
;	bsr	dspinv
;	btst	#4,d0
;	bsr	scDispAble
* POWERFAIL
;	lea	scPWFMsg,a5
;	bsr	dspinv
;	move.b	d0,-(sp)
;	ror.b	#6,d0
;	bsr	Dbit		; in switches.s
;	move.b	(sp)+,d0
;	bsr	crlf
* TIMEOUT
	lea	scBETimMsg,a5
	bsr	dspinv
	btst	#7,d0
	bsr	scDispTime

* - Get Key -
	lea	scTogMsg,a5
	bsr	dspmsg
        bsr     uconin		; Wait for upcase char

* get key to change or exit
	cmpi.b	#'A',d0
	bne	.sck2
	bchg.b		#5,SPControl
.sck2:	cmpi.b	#'B',d0
	bne	.sck3
	bchg.b		#2,SPControl
.sck3:	cmpi.b	#'C',d0
	bne	.sck4
	bchg.b		#0,SPControl
.sck4:	cmpi.b	#'E',d0
	bne	.sck5
	bchg.b		#3,SPControl
.sck5:
;	cmpi.b	#'M',d0
;	bne	.sck6
;	bchg.b		#4,SPControl
;.sck6:	cmpi.b	#'P',d0
;	bne	.sck7
;	bchg.b		#6,SPControl
.sck7:	cmpi.b	#'T',d0
	bne	.sck8	
	bchg.b		#7,SPControl
.sck8:
        cmpi.b  #esc,d0		; if esc, exit, else redraw 
        bne	SysControl   
	rts

*-------------------------------------
scDispAble:
	bne	.scDEnable
	lea	scDisMsg,a5	; 0
	bsr	dspmsg
	rts
.scDEnable:
	lea	scEnMsg,a5	; 1
	bsr	dspmsg
	rts
*-------------------------------------
scDispTime:
	beq	.scT16
	lea	sc32usMsg,a5	; 1
	bsr	dspmsg
	rts
.scT16:
	lea	sc16usMsg,a5	; 0
	bsr	dspmsg
	rts
*-------------------------------------
scDispClk:
	bne	scDClk
scDispClk2:
	bne	scDClk2		
	lea	sc8MHzMsg,a5	; 0
	bsr	dspmsg
	rts
scDClk:
	lea	sc16MHzMsg,a5	; 1
	bsr	dspmsg
	rts
scDClk2:
	lea	scCPUMHzMsg,a5	; Blitter 1
	bsr	dspmsg
	rts     
*-------------------------------------
*-------------------------------------
	.data	
	.even

scTemplMsg:	dc.b	cr,lf,invtog
		dc.b	'System Control Adjustments',invtog
		dc.b	cr,lf,cr,lf
		dc.b	'Current Settings:',cr,lf,cr,lf
		dc.b	eot
scTogMsg:	dc.b	cr,lf,cr,lf,'Press letter to toggle setting (ESC to exit)',eot
scABEEnMsg:	dc.b	iv,'A Address Bus Errors ',eot		; disabled/enabled
scBltClkMsg:	dc.b	iv,'B Blitter Clock: ',eot	; 8Mhz / CPU clock
scSysClkMsg:	dc.b	iv,'C CPU Clock: ',eot		; 8Mhz / 16 MHz
scBltEnMsg:	dc.b	iv,'E Blitter ',eot			; disabled/enabled
;scMCUEnMsg:	dc.b	iv,'M MCUG ',eot				; disabled/enabled (only if COMBO test pin high)
;scPWFMsg:	dc.b	iv,'P Powerfail (reset by POR) =',eot	; 1/0 (only reset by POR)
scBETimMsg:	dc.b	iv,'T Bus Error Timeout: ',eot		; 16us / 32us

sc8MHzMsg:	dc.b	'8 MHz',cr,lf,eot
sc16MHzMsg:	dc.b	'16 MHz',cr,lf,eot                
scCPUMHzMsg:	dc.b	'CPU Clock',cr,lf,eot
scEnMsg:	dc.b	'Enabled',cr,lf,eot
scDisMsg:	dc.b	'Disabled',cr,lf,eot
sc16usMsg:	dc.b	'16us',cr,lf,eot
sc32usMsg:	dc.b	'32us',cr,lf,eot


