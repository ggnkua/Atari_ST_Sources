	.extern tstdat
	.globl	rsinit	;used by excep.s
	.globl	init2key	; used by video for now.
	.text
*****************************************************************************
* $Header: $
*****************************************************************************
*    Copyright (c) 1992    Atari Microsystems, Inc.  All Rights Reserved    *
*****************************************************************************
* Revision History
* ----------------
*  7-7-92  mrw Changed all MFP code to Z8530 SCC and deleted all MFP code
*              with features not available on the SCC such as Interrupt
*              controller and general purpose I/O.
*  7-11-92 mrw Changed all references to D7 to a BTST instruction on the SCC
*              register direct since D7 cannot be used as a temp register.
*
*****************************************************************************
*MRW
*          EQUATES FOR SCC
*
*****************************************************************************
* RWS.T sccbase    equ $ff8c80         ; base address for Zilog Z85C30 chip.
scca_base  equ sccbase + $0    ; base address for Channel A
sccb_base  equ sccbase + $4    ; base address for Channel B
;sccvec     equ $180            ; scc vectors $60-6e = 180-1b8

scc_ctrl   equ $0              ; SCC control register offset
scc_data   equ $2              ; SCC data register offset

rr0        equ $0              ; Tx/Rx buffer status & Ext. status
rr1        equ $1              ; Special Rx condition status, error conditions
rr2        equ $2              ; Modified (B only) interrupt vector
*                              ; and unmodified (A only) interrupt vector
rr3        equ $3              ; Interrupt pending bits (A only)
rr8        equ $8              ; Rx buffer (same as scc_data)
rr10       equ $a              ; Misc. Xmtr, Rcvr status parms
rr12       equ $c              ; Low byte of baud rate generator (BRG)
rr13       equ $d              ; High byte of baud rate generator (BRG)
rr15       equ $f              ; External/Status interrupt control info.

wr0        equ $0              ; Command Register & CRC init, resets...
wr1        equ $1              ; Interrupt conditions, Wait/DMA requests
wr2        equ $2              ; Interrupt vector
wr3        equ $3              ; Rx/Control parms, # bit/char, Rx CRC enable
wr4        equ $4              ; Tx/Rx misc. parm, clk rate, # of sync,parity
wr5        equ $5              ; Tx parms, control, # of bits/char, Tx CRC
wr6        equ $6              ; Sync character 1st byte or SDLC flag
wr7        equ $7              ; Sync character 2nd byte or SDLC flag
wr8        equ $8              ; Tx buffer (same as scc_data)
wr9        equ $9              ; Master int. control and reset, reset bits
wr10       equ $a              ; Misc Tx/Rx bits, NRZ,NRZI,FM, CRC reset
wr11       equ $b              ; Clock mode control, source of Rx&Tx clks
wr12       equ $c              ; Low byte of baud rate generator (BRG)
wr13       equ $d              ; High byte of baud rate generator (BRG)
wr14       equ $e              ; Misc Ctrl bits, BRG, PLL, auto echo, Loopback
wr15       equ $f              ; External/Status interrupt control info.
*
*****************************************************************************
*
*  Baud rate generation for SCC
*
*      Time constant for wr12 and wr13 registers
*
*               clock frequency
*      tc = -----------------------  - 2
*            2 * CLKmode * Baudrate  
*
*  Sparrow is 3.672 Mhz, x16 mode.
*
*  NOTE:  The clock frequency choosen does not lend itself to perfect baud
*         rate divisions.
*****************************************************************************

baud19200  equ $4
baud9600   equ $a
baud4800   equ $16
baud2400   equ $2e
baud1200   equ $5e
baud600    equ $bd
baud300    equ $17d
baud150    equ $2fb

*****************************************************************************
*       To access control registers, write the control register of either
*       port with bits 0-2 containing the number of the register to access.
*       The next access to the control port will access that register.
*       Access to the data register can be done either by the above method
*       (specifying register 8) or by addressing the data register (control+2).
.macro  sccwr2   sccreg,sccdat
        move.b  #\sccreg,(a4)
        move.b  \sccdat,(a4)
.endm
.macro  sccrd2  sccreg,sccdat
        move.b  #\sccreg,(a4)
        move.b  (a4),\sccdat
.endm



*****************************************************************************
*eMRW
* START OF NEW STUFF : RWS  
*********************************
*       bus error handler
be_tst: move.l  #excep2,8
        moveq   #$ff,d7
        move.l  a6,$2(a7)       ;address of where to return to
        move.w  $a(sp),d0       ;get ssw
        and.w   #$ceff,d0       ;clear df, rc, and rb bits
        move.w  d0,$a(sp)       ;save modified ssw on stack
        rte

* OLD STE HANDLER *
obe_tst: moveq   #$ff,d7
         addq.l   #8,sp
         rte

* SHORT SP HANDLER *
sbe_tst:
	moveq	#$ff,d7
        move.l  a6,$2(a7)  ;new address (w/r routine)
        move.w  $a(sp),d0       ;get ssw
        and.w   #$ceff,d0       ;clear df, rc, and rb bits
        move.w  d0,$a(sp)       ;save modified ssw on stack
	rte

*********************************
*                               *
*       FATAL ERROR HANDLING    *
*                               *
*********************************       

*       Error occurred in system RAM or stack; we cannot continue
*       On entry, d0=data written, (a0)=data

*       Error during tstblk routine.
*       Failed to find good place to put the stack,
*       But temp stack is ok, display might be ok
fatal4:
        move.b  #2,consol       ;enable RS232 display out
        moveq   #rs96,d0
        bsr     setbps          ;init. RS232
        bsr     chkstk          ;display normal RAM error, screen and RS232
        bra     tstdat          ;repeat test
        
*       Failed during data line check
*       d0=data written, d1=data read
fatal0:
        movea.l #datlin,a5
        bra.s   fatal
        
*       Failed low memory 0 check
*       d0=0, d1=data read      
fatal1: 
        movea.l #unique,a5
        bra.s   fatal
        
*       Failed low memory address check
*       d0=data written, d1=data read
fatal2:
        move.l  #addchk,a5
****************************************************************************
*       Handle a fatal error
*       Print out RS232; assume no RAM.
*       Clear screen and turn red. Then repeat the test(s).
*       d0=data written, d1=data read, a0=address, a5=message ptr
****************************************************************************
* MRW
*
****************************************************************************

fatal:
       move.l  a0,d5           ;save address in d5   ????? why

       lea     sccb_base,a4    ; point to the serial port base address
	move.b	#$0,(a4)
       sccwr2   wr9, #$c0       ; Force hardware reset
       sccwr2   wr4, #$4c       ; x16 clock, 2 stop bits, no parity
       sccwr2   wr3, #$c0       ; Rx 8 bits/char, Rx disabled
       sccwr2   wr5, #$60       ; Tx 8 bits/char, DTR, RTS, Tx off
       sccwr2   wr9, #$00       ; Int. disabled
       sccwr2   wr10,#$00       ; NRZ encoding
       sccwr2   wr11,#$56       ; Tx & Rx = BRG out, TxC = BRG out
       sccwr2   wr12,#baud9600  ; Baud Rate Generator LOW
       sccwr2   wr13,#$00       ; Baud Rate Generator HIGH
       sccwr2   wr14,#$00       ; BRG in = RxC, BRG off, loopback
* enable this puppy
       sccwr2   wr14,#$01       ; BRG enable
       sccwr2   wr3, #$c1       ; Rx enable
       sccwr2   wr5, #$68       ; Tx enable
*eMRW
       move.l  #2000,d7
wtinit:
       dbra    d7,wtinit           ;wait for port to sync


*       Display error message
        lea     ptwdat,a0
        bra     ptmsg

*       Display data written
ptwdat: cmp.w   d0,d1           ;if equal, don't display
        beq.s   fdsp    

*       Print data written (binary) out RS232
        lea     ptcr0,a0
        bra     ptdat

*       Print space
ptcr0:  lea     ptrdat,a2
        moveq   #$20,d3
        bra     pout

*       Print data read out RS232
ptrdat: move.w  d1,d0
        lea     ptcr1,a0
        bra     ptdat

*       Print space
ptcr1:  lea     ptadd,a2
        moveq   #$20,d3
        bra     pout


*       Print address (hex) out RS232
ptadd:  move.l  d5,d1           ;move address
        beq.s   fdsp            ;skip if 0
        swap    d2
        lea     pa1,a1          ;ret add
        bra     pbyt            ;print ms byte (d2)
pa1:    lea     fdsp,a0         ;ret addr
        bra     pwrd            ;print low word (d1)

*       Print crlf
        lea     fdsp,a0
        bra.s   ptcrlf
                
*       Set up display 
fdsp:   move.w  #red,palette    
        move.b  #scrmemh,v_bas_h        ;direct hardware to screen memory
        clr.b   v_bas_m
        lea     scrmem,a0
        moveq   #0,d0
fdsp1:  move.w  d0,(a0)+
        cmpa.l  #scrmem+$8000,a0
        bne.s   fdsp1

        lsl     #1,d6           ;shift bit 0-15
        bra     tstd6           ;repeat the RAM tests endlessly


*************************************************
*                                               *
*       SUBROUTINES FOR INIT SECTION            *
*                                               *
*************************************************


*       Pseudo subroutines for fatal condition--do not use stack

****************************************************************************
* MRW
*       Print message out RS232
*       Entry:  a5=msg ptr
*               a0=ret addr
*               a4=SCC base address
****************************************************************************
ptmsg:
       move.b  (a5)+,d2
       cmpi.b  #eot,d2
       beq.s   ptmsg1
       move.b  #rr0,(a4)           ; Read Tx/Rx buffer status register
ptmsg2:
       btst    #2,(a4)             ; ?? Is Tx buffer empty
       beq.s   ptmsg2              ; no, keep trying infinitely
       move.b  d2,scc_data(a4)     ; Transmit next character in message
       bra.s   ptmsg
ptmsg1:
       jmp     (a0)

*eMRW
****************************************************************************
* MRW
*       Print  crlf
*       Entry:  a0=ret addr
*               a4=SCC base address
****************************************************************************
ptcrlf:
       btst    #2,(a4)             ; ?? Is Tx buffer empty
       beq.s   ptcrlf              ; no, keep trying infinitely
       move.b  #cr,scc_data(a4)    ; Transmit a <CR>
ptcrlf1:
       btst    #2,(a4)             ; ?? Is Tx buffer empty
       beq.s   ptcrlf1             ; no, keep trying infinitely
       move.b  #lf,scc_data(a4)    ; Transmit a <LF>
       jmp     (a0)
*eMRW

****************************************************************************
* MRW
*       Print binary data to RS232
*       Entry:  d0=data
*               a0=ret addr
*               a4=SCC base address
****************************************************************************

ptdat:
       andi.b  #$fe,ccr        ;clear carry
       moveq   #15,d2          ;for 16 bits
ptdat1:
       move.b  #rr0,(a4)           ; Read Tx/Rx buffer status register
       btst    #2,(a4)             ; ?? Is Tx buffer empty
       beq.s   ptdat1              ; no, keep trying infinitely
       lsl.w   #1,d0
       bcc.s   ptdat2
       move.b  #'1',scc_data(a4)   ; Transmit an ASCII '1' 
       bra.s   ptdat3
ptdat2:
       move.b  #'0',scc_data(a4)   ; Transmit an ASCII '0' 
ptdat3:
       dbra    d2,ptdat1
       jmp     (a0)
*eMRW

*------------------------------
*       Print word to RS232
*       Entry:  d1=word
*               a0=return address
*       Uses:   d2,d3,a11<
pwrd:   move.w  d1,d2
        lsr     #8,d2   ;hi byte->lo
        lea     pw1,a1
        bra.s   pbyt    ;print hi (d2)
pw1:    move.w  d1,d2
        lea     pw2,a1
        bra.s   pbyt    ;print lo (d2)
pw2:    jmp     (a0)    ;return

                
*       Print byte to RS232
*       Entry:  d2=byte
*               a1=return address
*       Uses:   d3,a2
pbyt:   move.b  d2,d3
        lsr.b   #4,d3
        lea     pw3,a2
        bra.s   pasc    ;hi nib
pw3:    move.b  d2,d3
        lea     pw4,a2
        bra.s   pasc    ;low nib
pw4:    jmp     (a1)    ;return

*-------------------------------
*       Convert nibble ascii and print to RS232
*       Entry:  d3=nibble
*               a2=return address               
pasc:   andi.b  #$f,d3
        cmp.b   #9,d3   ;0-9=>30-39
        bls.s   pdecml
        and     #7,d3
        subq    #1,d3
        ori.b   #$40,d3 ;A-F=>41-47

****************************************************************************
* MRW
*       Print byte
*
*       Entry:  d3=data
*               a2=ret addr
*               a4=SCC base address
*
****************************************************************************
pout:
       move.b  #rr0,(a4)           ; Read Tx/Rx buffer status register
       btst    #2,(a4)             ; ?? Is Tx buffer empty
       beq.s   pout                ; no, keep trying infinitely

       move.b  d3,scc_data(a4)     ; Transmit an byte to serial port
       jmp     (a2)                ;return
*eMRW

pdecml: ori.b   #$30,d3
        bra.s   pout



*********************************
*       Set time-out timer 
*       d0=timer control register
*       d1=timer data
setout:
	lea     mfp,a0
	move.b  #0,tacr(a0)
	move.b  d1,tadr(a0)
	move.b  d0,tacr(a0)
	move.b  #1,timout
	rts

*************************************************************************
*       Set start address of display memory into video register,        *
*       set resolution, and set colors of text and background           *
*       Uses:   d0,a0,a1,a2

setdsp:
        movea.l #$ffff8200,a2
        move.b  #scrmemh,1(a2)  ;direct hardware to screen memory
        clr.b   3(a2)           ;v_bas
wtvb:   cmpi.b  #scrmemh,5(a2)  ;wait for blank
        bne     wtvb
wtvb1:  cmpi.b  #scrmemm,7(a2)
        bne     wtvb1
wtvb2:  cmpi.b  #0,9(a2)
        bne     wtvb2

        move    #$fff,d0
        lea     palette,a1
        move    #$1e,d1
wrtpal: move    d0,0(a1,d1)     ;write all palettes
        sub     #2,d1
        bpl.s   wrtpal

*       Test monochrome monitor input
*        lea     mfp,a0
*        btst    #7,gpip(a0)
*        bne.s   setdsp1

*       Set monochrome mode
*        move.b  #2,$60(a2)      ;v_shf_mod
*        bra.s   setdsp2

*       Set color (med. res.) mode
setdsp1:
        move.b  #1,$60(a2)      ;v_shf_mod
        move.w  #$666,6(a1)     ;text color
setdsp2:
        move.w  #bgrnd,(a1)     ;background

*       Init. RS232 as a terminal
rsinit: move    rsrate,d0       ;get bps

****************************************************************************
* MRW
*      Set baudrate.  Entry to set bps from fatal (don't use RAM variable)
*
*       Entry:  d0.b = 1,2,4,...64 for 19200,9600,...300 bps
*              NOTE:  function uses a4 for base address of SCC
*
*              The entry 'coded' baudrate must be converted to SCC
*              The conversion is not exact for all baudrates
*              new = ( old * 3 ) - 2
*
****************************************************************************
setbps:
;       lea     sccb_base,a4    ; point to the serial port base address
 ;      sccwr2   wr14,#$00       ; BRG disenable
  ;     andi.w  #$00ff,d0       ; Strip upper bits
   ;    mulu.w  #$3,d0          ; convert from old baudrate divisor
    ;   subq.w  #$2,d0          ; ... to new divisor
;       sccwr2   wr12,d0         ; Baud Rate Generator LOW
 ;      lsr.w   #$8,d0          ; shift upper byte to lower byte
  ;     sccwr2   wr13,#$00       ; Baud Rate Generator HIGH
   ;    sccwr2   wr14,#$01       ; BRG enable
    ;   bsr     wait            ; let 68901 sync
     ;  rts
*eMRW
       lea     sccb_base,a4    ; point to the serial port base address
	move.b	#$0,(a4)
       sccwr2   wr9, #$c0       ; Force hardware reset
	move.w	#$ffff,d0	; wait for reset
.lp:	nop
	dbra	d0,.lp
       sccwr2   wr4, #$4c       ; x16 clock, 2 stop bits, no parity
       sccwr2   wr3, #$c0       ; Rx 8 bits/char, Rx disabled
       sccwr2   wr5, #$60       ; Tx 8 bits/char, DTR, RTS, Tx off
       sccwr2   wr9, #$00       ; Int. disabled
       sccwr2   wr10,#$00       ; NRZ encoding
       sccwr2   wr11,#$56       ; Tx & Rx = BRG out, TxC = BRG out
       sccwr2   wr12,#baud9600  ; Baud Rate Generator LOW
       sccwr2   wr13,#$00       ; Baud Rate Generator HIGH
       sccwr2   wr14,#$00       ; BRG in = RxC, BRG off, loopback 0ff
* enable this puppy
       sccwr2   wr14,#$01       ; BRG enable
       sccwr2   wr3, #$c1       ; Rx enable
       sccwr2   wr5, #$68       ; Tx enable
*eMRW
       move.l  #2000,d7
.wtinit:
       dbra    d7,.wtinit           ;wait for port to sync

****************************************************************************
* MRW KILLED THESE AND WASN'T SUPPOSED TO : RWS
*       Routine to set up the general interrupt port registers          *
*
*       Uses:   power-up sequence                                       *
*
****************************************************************************
initmfp:
	movea.l #mfp,a0         ;init mfp address pointer
	move.b  #$48,d0         ; vector to $100, sw EOI : ADDED : 24JAN92 : RWS
intmfp:
	clr.b   imra(a0)        ;turn off all interrupt mask bits
	clr.b   imrb(a0)        ;...
	clr.b   iera(a0)        ;...and the enable bits
	clr.b   ierb(a0)        ;...
	clr.b   ipra(a0)        ;...and the pending bits
	clr.b   iprb(a0)        ;...
	clr.b   isra(a0)        ;...and the in-service bits
	clr.b   isrb(a0)        ;...
	clr.b   aer(a0)         ;active edge = rising
	clr.b   ddr(a0)         ;data direction = inputs
	clr.b   gpip(a0)
	move.b  d0,vr(a0)     ;set mfp autovector and s-bit : CHGD : 24JAN92 : RWS
genrts: rts


*************************************************
*       Initialize keyboard hard/soft-ware      *
*       perform this routine once as part of    *
*       power-up sequence                       *

initkey:
        clr.b   consol          ;set flag = enable all
*                               bit0=RS232 output disable
*                               bit1=RS232 input disable
*                               bit2=keyboard disable
*       zero keyboard variables
        clr.b   kbshift         ;shift key
        clr.w   kbctrl          ;ADDED 29JAN92 : RWS
        clr.b   kstate          ;state=normal key mode
        clr.b   kindex

*       initialize the ikbd buffer record structure
        movea.l #kbufrec,a0
        movea.l #kinit,a1
        moveq   #kssize,d0
        bsr     lbmove          ;do block move and return
        move.l  #brkbufh,brkptrh        ;init break key buffer
        move.l  #brkbufh,brkptrt

init2key:
        move.l  #aciaexit,vkbderr.w     ;init keyboard error handler address

*       init the acia next
        bsr     midiptr
        move.b  #rsetacia,comstat(a1)   ;reset MIDI acia

        bsr     ikbdptr                 ;init address registers for ikbd
        move.b  #rsetacia,comstat(a1)   ;init the acia via master reset

*       init the KEYBOARD acia to /64 clock, 8 bit dat, 1 stop bit,
*       no parity, rts low, tx interrupt disabled, rx interrupt enabled

        move.b  #div64+protocol+rtsld+intron,comstat(a1)
        
*       enable MFP interrupt for keyboard

        moveq   #6,d0           ;interrupt 6=keybd,midi
        movea.l #midikey,a2     ;address of int routine
        bsr     initint
        rts

*************************************************
*       Table of initial keyboard buffer values *
kinit:
        dc.l    kibuffer
        dc.w    kinsize
        dc.w    0
        dc.w    0
        dc.w    kinsize/4
        dc.w    kinsize*3/4

        dc.l    kobuffer
        dc.w    koutsize
        dc.w    0
        dc.w    0
        dc.w    koutsize/4
        dc.w    koutsize*3/4
        dc.w    0
kssize  equ     *-kinit-1

***********************************************8
* print 'OK' after testing messages
pOKmsg:
        move.l  a5,-(sp)
        lea.l   okmsg,a5
        bsr     dspmsg
        move.l  (sp)+,a5
        rts

*************************************************************************
*                                                                       *
*       routine to init an mfp associated interrupt vector              *
*                                                                       *
*       algorithm                                                       *
*                                                                       *
*       1. block the interrupt via it's mask bit;                       *
*       2. disable the interrupt's enable and pending bits;             *
*       3. check the interrupt's in-service register and loop till      *
*          clear;                                                       *
*       4. init the interrupt's associated vector;                      *
*       5. set the interrupt's enable bit;                              *
*       6. set the interrupt's mask bit;                                *
*                                                                       *
*       entry                                                           *
*               d0 - contains interrupt # to affect                     *
*               a2 - contains new vector address                        *
*************************************************************************
* MRW KILLED AGAIN : RWS
initint:
	movem.l d0-d2/a0-a3,-(a7)       ;save affected registers
	bsr     disint          ;disable the interrupts
	move.l  d0,d2           ;get a copy so as to determine where to...
	asl     #2,d2           ;place the a2 address into the int. vector
	addi.l  #$100,d2        ;interrupt vector addr = (4 * int) + $000100
	move.l  d2,a3           ;transfer the calculated address to a register
	move.l  a2,(a3)         ;...that can act upon it thus!<--vector init'ed
	bsr     enabint         ;enable interrupts
	movem.l (a7)+,d0-d2/a0-a3       ;restore affected registers
	rts


*************************************************************************
*               interrupt disable routine                               *
*************************************************************************
disint:
	movem.l d0-d1/a0-a1,-(a7)       ;save affected registers
	movea.l #mfp,a0         ;set mfp chip address pointer : MOVED : RWS
disint0:
	move    sr,-(sp)
	move    #$2700,sr
	lea     imra(a0),a1     ;set a1 for the mskoff routine
	bsr     bselect         ;generate the appropriate bit to clear
	bclr    d1,(a1)         ;and clear the bit...
	lea     iera(a0),a1     ;set a1 for another mskoff call
	bsr     bselect
	bclr    d1,(a1)         ;and clear the bit...
	lea     ipra(a0),a1     ;yet again...
	bsr     bselect
	bclr    d1,(a1)         ;and clear the bit...
	lea     isra(a0),a1     ;now set up to check for interrupts in progress
	bsr     bselect         ;get proper a/b version...
	bclr    d1,(a1)
	move    (sp)+,sr
	movem.l (a7)+,d0-d1/a0-a1       ;restore affected registers
	rts

*************************************************************************
*               enable interrupt routine                                *
*************************************************************************
enabint:
	movem.l d0-d1/a0-a1,-(a7)       ;save affected registers
	movea.l #mfp,a0         ;set mfp chip address pointer : MOVED : RWS
enabin0:
	move    sr,-(sp)
	move    #$2700,sr
	lea     iera(a0),a1     ;set up to enable the interrupt enable bit
	bsr     bselect
	bset    d1,(a1)         ;and set the bit...
	lea     imra(a0),a1     ;set up to enable the interrupt enable bit
	bsr     bselect
	bset    d1,(a1)         ;and set the bit...
	move    (sp)+,sr
	movem.l (a7)+,d0-d1/a0-a1       ;restore affected registers
	rts

*************************************************************************
*                                                                       *
*       the following routine generates the appropriate bset/bclr #     *
*       for the interrupt # specified in d0.  valid interrupt #'s are   *
*       0 --> 15 as shown in the 68901 chip specification.  it also     *
*       selects between the ixra and the ixrb version of the register   *
*       as is appropriate.                                              *
*                                                                       *
*       entry   d0 - contains the interrupt number                      *
*               a1 - contains the pointer to the "ixra" version of      *
*                       the interrupt byte to mask                      *
*       exit    d0 - same as upon entry                                 *
*               d1 - contains the number of the bit t                   *
*************************************************************************

bselect:
	move.b  d0,d1           ;copy d0 to d1 for scratch work
	cmp.b   #$8,d0          ;see if desired int # >= 8...
	blt.s   skip0           ;...and branch if it ain't...
	subq    #$8,d1          ;adjust for using ixrb instead
skip0:  cmp.b   #$8,d0          ;see if desired int # >= 8...
	bge.s   skip1           ;...and branch if it is...
	addq    #$2,a1          ;adjust for using ixrb instead
skip1:  rts

*********************************
*       Wait a while (2.5 ms ?) *
*********************************
* MOVED TO WAIT.S : 09APR92 : RWS
;* TRY TO GET THIS AS CLOSE AS POSSIBLE TO 2.5ms for those things
;* that need it.
;
;wait:  bclr.b  #0,SPControl    ; 8MHz, cache off too   
;       move.l  d0,-(a7)
;       move.l  #1500,d0                
;wait1:  
;       nop
;       subq.l  #1,d0
;        bne.s   wait1
;        move.l  (a7)+,d0
;        rts     


*****************************************************************
*       Block move d0 bytes from (a1) to (a0)                   *
lbmove: move.b  (a1)+,(a0)+
        dbra    d0,lbmove
        rts                     ;and return home

