*       test SCC 
*       April 10, 89
*       tests: internal loopback polled (asynch), break (test ext loopback),
*       external loopback polled (asynch), modem control lines, external 
*       loopback interrupt (asynch).


sccvec  equ     $180            ;scc vectors $60-6e = 180-1b8
mfp1    equ     $fffa01
sysim   equ     $ff8e01         ;scu system int mask
vmeim   equ     $ff8e0d         ;VME int mask

*       To access control registers, write the control register of either
*       port with bits 0-2 containing the number of the register to access.
*       The next access to the control port will access that register.
*       Access to the data register can be done either by the above method
*       (specifying register 8) or by addressing the data register (control+2).
.macro  sccwr   sccreg,sccdat
        move.b  #\sccreg,(a0)
        move.b  #\sccdat,(a0)
.endm
.macro  sccrd   sccreg,sccdat
        move.b  #\sccreg,(a0)
        move.b  (a0),\sccdat
.endm

        .text

scctst: movea.l  #sccmsg,a5        ; display sign on
        bsr      dsptst
	bset    #rsinp,consol   ;loopback connected, no RS232 I/O
     
;        bsr     nolan              ; disconnect lan from A port
        lea     sccbase,a0
        bsr     sccreset           ; resets scc chip

	bsr	sccidat	; RWS.TEST
	bsr	sccibrk
	bsr	sccidat

        lea     erflg0,a0
        moveq   #10,d7
clrflg: clr.b   (a0)+
        dbra    d7,clrflg
      
*       init the 8253           ;initialize internal loop back mode
        lea     sccbase,a0
        bsr     sccinit         ;both chns      

        lea     sccbase+4,a0    
        bsr     sccinit         ;init chn B

*       test internal loopback mode channel A
        lea     sccbase,a0
        sccwr   14,$13          ;enable loopback, BRG=PCLK, en BRG
        bsr     sccasn
        sccwr   14,3            ;disable loopback                       
        or.b  d6,erflg0
        beq.s   scb

*       display A internal loopback errors
        lea     scalper,a5
        bsr     dspmsg
        move.b  erflg0,d0
        lea     sccerr,a0
        bsr     dsp_er

*       test internal loopback mode channel B
scb:    lea     sccbase+4,a0
        sccwr   14,$13          ;enable loopback, BRG=PCLK, en BRG
        bsr     sccasn
        sccwr   14,3            ;disable loopback                       
        move.b  d6,erflg1
        beq.s   sccnxt1

*       display B internal loopback errors
        lea     scblper,a5
        bsr     dspmsg
        move.b  erflg1,d0
        lea     sccerr,a0
        bsr     dsp_er

*       test for presence of external loopback connector with break

sccnxt1:
*       test for loopback plug on channel A
;        lea     sccbase,a0
 ;       bsr     sccibrk            ; initialize break mode A channel
  ;      bsr     scclpbk
   ;     move.b  d6,erflg2       ;=1 if timed-out waiting for break
    ;    beq.s   gotlpa
     ;   lea     nosclpa,a5
      ;  bsr     dspmsg

gotlpa:
*       test for loopback plug on channel B
        lea     sccbase+4,a0
        bsr     sccibrk          ; initialize break mode B channel
        bsr     scclpbk
        move.b  d6,erflg3       ;=1 if timed-out waiting for break
        beq.s   sccnxt2
        lea     nosclpb,a5
        bsr     dspmsg

*       test asynch, no interrupts
sccnxt2:

lanck: 
;	bsr     yeslan          ;turn on lan for data loop test
        lea     sccbase,a0      ;chn A asynch
        bsr     sccidat         ; initialize data mode, rts, dsr on
        bsr     sccasn
        or.b  d6,erflg0
        beq.s   lanck1          ;bra on no error
        lea     lanerr,a5       ;display error
        bsr     dspmsg
        bra.s   lanex

lanck1: lea     sccbase,a0
        bsr     sccmcl          ;test lan DTR to DCD
lanex: 
;	bsr     nolan           ;turn off lan; back to rs232 A port data

;        cmp.b   #1,erflg2       ;connector A? (rs232 loop-back plug)
;        beq.s   sccasnb         ;no, branch
;
 ;       lea     sccbase,a0      ;chn A asynch
  ;      bsr     sccidat         ; initialize data mode, rts, dsr on
   ;     bsr     sccasn
    ;    move.b  d6,erflg4
     ;   beq.s   sccasnb
      ;  lea     asnera,a5       ;display error
       ; bsr     dspmsg
;        lea     sccerr,a0
 ;       move.b  erflg4,d0
  ;      bsr     dsp_er
;
sccasnb:
        cmp.b   #1,erflg3       ;connector B?
        beq.s   sccmod          ;no, branch

        lea     sccbase+4,a0    ;chn B asynch
        bsr     sccidat         ; initialize data mode, rts, dsr on
        bsr     sccasn
        move.b  d6,erflg5
        beq.s   sccmod
        lea     asnerb,a5
        bsr     dspmsg
        move.b  erflg5,d0
        lea     sccerr,a0
        bsr     dsp_er

*       test modem control
sccmod: 
;	cmp.b   #1,erflg2       ;connector A?
 ;       beq.s   sccmcb          ;no branch

;        lea     sccbase,a0
 ;       bsr     sccidat         ; initialize data mode, rts, dsr on
  ;      bsr     sccmc           ;test chn A
   ;     move.b  d6,erflg6
    ;    beq.s   sccmcb
     ;   lea     mcaerr,a5
      ;  bsr     dspmsg
       ; move.b  d6,d0
;        lea     mcerr,a0
 ;       bsr     dsp_er
  ;      bsr     crlf

sccmcb: cmp.b   #1,erflg3       ;connector B?
        beq.s   sccnxt3         ;no branch

        lea     sccbase+4,a0
        bsr     sccidat         ; initialize data mode, rts, dsr on
        bsr     sccmc           ;test chn B
        move.b  d6,erflg7
        beq.s   sccnxt3
        lea     mcberr,a5
        bsr     dspmsg
        move.b  d6,d0
        lea     mcerr,a0
        bsr     dsp_er
        bsr     crlf

*       test interrupts
sccnxt3:
        lea     sccbase,a0
        sccwr   2,$60           ;vector to 180 (plus status)

*       init int vectors: use base address 180 = vector number 60
*       there are 8 interrupts, the status for the interrupt is placed
*       in bits 1-3 of the vector number (offset modulo 8)
        lea     sccvtb,a0
        lea     sccvec,a1
        move    #7,d7           ;8 scc vectors
setsccv:
        move.l  (a0),(a1)
        adda.l  #4,a0
        adda.l  #8,a1
        dbra    d7,setsccv

;        bset.b  #5,vmeim        ;enable scc int @ SCU
        bsr     sccbuf
;        cmp.b   #1,erflg2
 ;       beq.s   sccib           ;bra if no A channel loopback

        lea     sccbase,a0
        bsr     sccidat         ;initialize data mode, rts, dsr on
        bsr     scci            ;test interrupts A
        move.b  d6,erflg8
        move.b  d6,d0
        beq.s   sccib
        lea     sccinm,a5
        bsr     dspmsg
        lea     sccerr,a0
        bsr     dsp_er

sccib:
        cmp.b   #1,erflg3       ;connector?
        beq.s   sccdone         ;bra if no B channel loopback

        lea     sccbase+4,a0
        bsr     sccidat         ;initialize data mode, rts, dsr on
        bsr     scci            ;test interrupts B
        move.b  d6,erflg9
        move.b  d6,d0
        beq.s   sccdone
        lea     sccinm,a5
        bsr     dspmsg
        lea     sccerr,a0
        bsr     dsp_er

sccdone:
          move.b   erflg0,d0
          or.b     erflg1,d0
          or.b     erflg2,d0
          or.b     erflg3,d0
          or.b     erflg4,d0
          or.b     erflg5,d0
          or.b     erflg6,d0
          or.b     erflg7,d0
          or.b     erflg8,d0
          or.b     erflg9,d0
          beq.s     sccnxt4             ;branch if no errors

; ONLY IF NO ERRORS CAN THERE NOT BE A LOOPBACK IN PORT B
; - swiped from menu.s

;.menu1:  bclr    #rsinp,consol   ;default=RS232 enable
;	move.b	scc_data+sccb_base,d0	; read from SCC
;	move.b  #cr,d0
;	bsr     dsprs           ;send RS232
;	moveq   #40,d0          ;100ms for response
;.wtrs:   bsr     wait            ;wait for char to arrive
;	dbra    d0,.wtrs
;	bsr     rsstat          ;got a char?
;	beq.s   .menu2           ;no, not connected
;	move.b	scc_data+sccb_base,d0	; read from SCC
	bset    #rsinp,consol   ;loopback connected, no RS232 I/O
;.menu2:
          move.w    #red,palette
          move.l    #falmsg,a5
	move.b	#t_LAN,d0
          bsr       dsppf
          bra.s     sccnxt5
sccnxt4:
          movea.l   #pasmsg,a5
	move.b	#t_LAN,d0
          bsr       dsppf
sccnxt5:
        rts

*--------------------------
*       test for loopback connector
*       entry:  a0 = scc base address
*       exit:   d6 = 0 if connector, 1 if no connector
scclpbk:
        clr.b   d6
        moveq   #$ff,d7
wtbrk:  sccrd   0,d0    
        btst    #7,d0           ;break rcv'd?
        bne.s   gotbrk
        dbra    d7,wtbrk
        move.b  #1,d6
gotbrk: rts

*----------------------------------------
*       test async mode on scc channel
*       data = 0-ff
*       entry:  a0 = channel address
*       exit:   d6 = error status, bit:
*        0=TX t-o, 1=RX t-o, 4=parity, 5=overrun, 6=crc/framing,
*        7=cmp data
sccasn:
        moveq   #0,d6
        moveq   #0,d1
        bsr     scrxmt          ;make sure rx FIFO is empty
        sccwr   0,$30           ;error reset

sclpa:  move.b  d1,2(a0)        ;output data
        moveq   #$ff,d7

scst1:  sccrd   0,d0            ;input status
        btst    #2,d0           ;test TX empty
        bne.s   scst2
        dbra    d7,scst1
        ori.b   #1,d6           ;TX timeout
        bra.s   sclpx
scst2:  move.l  #$ffffff,d7
scst2a: move.b  (a0),d0
        btst    #0,d0           ;test RX full
        bne.s   scst3
        dbra    d7,scst2a
        ori.b   #2,d6           ;RX timeout
        bra.s   sclpx
scst3:  sccrd   1,d0            ;read status 1
        andi.b  #$70,d0         ;mask parity, overrun, crc/framing              
        or.b    d0,d6
scdat:  move.b  2(a0),d0        ;read data
        cmp.b   d0,d1
        beq.s   sclpgd
        ori.b   #$80,d6         ;data cmp error
*       bra.s   sclpx
sclpgd: addi.b  #1,d1
        bne     sclpa
sclpx:  sccwr   0,$30           ;error reset cmd
        rts

*---------------------------
*       empty the receiver fifo
*       entry:  a0 = channel base address
scrxmt:
	move.l  d1,-(sp)
	move.w  #$ffff,d1
.scrxm2:
	sccrd   0,d0
	btst    #0,d0           ;rcv full?
	beq.s   scrmtx
	move.b  2(a0),d0        ;make sure receiver is empty
	dbra    d1,.scrxm2
	lea.l   nefifoerr,a5
	bsr     dspmsg
	move.w  #red,palette
* SET ERROR FLAG HERE !!! (UNABLE TO EMPTY FIFO)
scrmtx: 
	move.l  d1,(sp)+
	rts
* old
;scrxmt:
 ;       sccrd   0,d0
  ;      btst    #0,d0           ;rcv full?
   ;     beq.s   scrmtx
    ;    move.b  2(a0),d0        ;make sure receiver is empty
     ;   bra.s   scrxmt
;scrmtx: rts

*------------------------
*       test modem control
*       entry:  a0 = channel
*       exit:   d6 = status: bit 0=error DTR-DCD, bit 1=error DTR-DSR
*               bit 2=error RTS-CTS
sccmc:  moveq   #0,d6
        sccwr   5,$68           ;RTS, DTR inactive
        bsr     sccwait
        sccrd   0,d0
        andi.b  #$38,d0         ;mask CTS,DSR,DCD
        beq.s   scmc1
        or.b    d0,d6           
scmc1:  sccwr   5,$e8           ;DTR active
        bsr     sccwait
        sccrd   0,d0
        andi.b  #$38,d0
        eor.b   #$18,d0         ;DSR and DCD?
        or.b    d0,d6
scmc2:  sccwr   5,$6a           ;RTS active
        bsr     sccwait
        sccrd   0,d0
        andi.b  #$38,d0
        eor.b   #$20,d0         ;CTS?
        or.b    d0,d6
scmc3:  lsr.b   #3,d6           ;shift into bits 0-2
        rts

sccwait:
        move    #$ffff,d7
wt1lp:  dbra    d7,wt1lp
        rts

*-------------------------------
*       test scc lan DTR to DCD loop-back
*       entry:  a0 = channel

sccmcl: moveq   #0,d6
        sccwr   5,$68           ;RTS, DTR inactive
        bsr     sccwait
        sccrd   0,d0
        andi.b  #$8,d0          ;mask for DCD
        beq.s   scmcl1          ;bra if no error
        or.b  d0,erflg0       ;flag red pal
        lea     landcd,a5       ;DCD on but we have RTS off
        bsr     dspmsg
           
scmcl1: sccwr   5,$e8           ;DTR activated
        bsr     sccwait
        sccrd   0,d0
        andi.b  #$8,d0          ;mask for DCD
        bne.s   scmcl2          ;bra if no error
        ori.b   #$1,erflg0      ;flag red pal
        lea     landcdn,a5      ;DCD not active but we turned on RTS
        bsr     dspmsg

scmcl2:  rts

*--------------------------------
*       test scc interrupts
*       entry:  a0 = sccbase (A or B)
*       exit:   d6 = error status:
*               bit 0 = tx timeout, bit 1 = rx timeout
*               bit 4 = parity, bit 5 = overrun, bit 6 = crc/framing,
*               bit 7 = data compare 
scci:
        moveq   #0,d6           ;error flag
        move.b  d6,txiflg       ;tx int flg
        move.b  d6,rxiflg       ;rx int flg
        bsr     scrxmt          ;clear rx fifo
        
*       init ptrs for int routines
        move.l  #txbuf+1,txptr  ;init ptr to tx buffer
        move.l  #rxbuf,rxptr    ;init ptr to rx buffer
        clr.b   rxstat

*       enable interrupts
        sccwr   15,0
        sccwr   0,$10
        sccwr   0,$10
        sccwr   1,$13           ;IE: TX, RX on all, master ext
        sccwr   9,9             ;master IE, vector + status (bits 1-3)

*       start transmitter
        lea     txbuf,a1
        move.b  (a1)+,2(a0)
        
*       wait for completion
txwt1:  move.l  txptr,templ     ;save buffer ptr
        bsr     sccwait         ;wait for a char
        move.l  templ,d0
        cmp.l   txptr,d0        ;still the same?
        bne.s   txwt1           ;no, still getting chars
        cmp.l   #txbufe,templ   ;yes, at end?
        beq.s   txdone
        move.b  #1,d6           ;tx t-o
        cmp.b   #0,rxstat       ;rx error?
        beq.s   txdone
        move.b  rxstat,d6       ;disregard tx t-o, it is receiver error

txdone: sccwr   9,1             ;disable interrupts
        tst.b   d6
        bne.s   sccix

*       check for full rx buffer
        move.l  rxptr,d0
        cmp.l   #rxbufe,d0      ;rx complete?
        beq.s   sccdcmp
        or.b    #2,d6
        bra.s   sccix

*       compare read and write data
sccdcmp:
        lea     txbuf,a1
        lea     rxbuf,a2
        move    txbufe-txbuf,d7
sccdat: cmp.b   (a1)+,(a2)+
        beq.s   sccdok
        move.b  #$80,d6
sccdok: dbra    d7,sccdat

sccix:  cmpi.b  #0,txiflg
        bne.s   sccix2
        lea     notxi,a5
        bsr     dspmsg
sccix2: cmpi.b  #0,rxiflg
        bne.s   sccix3
        lea     norxi,a5
        bsr     dspmsg
sccix3:
        rts

*--------------------------------------------
*       fill transmit buffer with test pattern
sccbuf: lea     txbuf,a0
        move    #$ff,d0
filltx: move.b  d0,(a0)+        ;init tx buffer with data ff-0
        dbra    d0,filltx       
        move    #$ff,d0
        move.b  #$e5,d1
filtx1: move.b  d1,(a0)+        ;fill with E5
        dbra    d0,filtx1
        rts

*------------------------
*       zero rx buffer
sccclr: lea     rxbuf,a0
        clr     d0
        move    #$ff,d7
scccl1: move    d0,(a0)+
        dbra    d7,scccl1
        rts

*------------------------
*       set baud rate (using PCLK)
*       entry:  a0 = base address
*               d1 = tc low
*               d2 = tc high
sccbaud:
        sccwr   14,2            ;disable BRG
        move.b  #12,(a0)
        move.b  d1,(a0)         ;time constant low
        move.b  #13,(a0)
        move.b  d2,(a0)         ;time constant high
        sccwr   14,3            ;source = PCLK
        rts
                                
*------------------------
*       display error msg
*       entry:  a0 = table of messages
*               d0 = bit map
dsp_er: 
        moveq   #0,d1           ;bit test
        moveq   #0,d2           ;msg ptr index
sccbit: btst    d1,d0
        bne.s   sccer1
sccer2: addq    #4,d2
        addq    #1,d1
        cmp.b   #8,d1
        bne.s   sccbit
        rts
sccer1: move.l  0(a0,d2),a5     ;get msg
        move.l  a0,-(sp)
        bsr     dspmsg
        move.l  (sp)+,a0
        bra.s   sccer2

*-------------------------
*       SCC A transmitter empty interrupt
scctxa:
        movem.l d0/a0-a1,-(sp)
sccta:  lea     sccbase,a0
        bra.s   scctxe

*       SCC B transmitter empty interrupt
scctxb:
        movem.l d0/a0-a1,-(sp)
scctb:  lea     sccbase+4,a0

scctxe: move.b  #1,txiflg       ;flag occurence
        move.l  txptr,a1
        cmpa.l  #txbufe,a1      ;all chars sent?
        bne.s   scctxnx
        sccwr   0,$28           ;reset Tx pending
        bra.s   sccidn
scctxnx:
        move.b  (a1)+,2(a0)     ;next char
        move.l  a1,txptr

*       finish int service
sccidn: sccwr   0,$38           ;reset highest IUS
*       check for more interrupts
        move.b  #3,sccbase
        move.b  sccbase,d0      ;read int pending
        btst    #5,d0
        bne.s   sccra                   
        btst    #2,d0
        bne.s   sccrb
        btst    #4,d0
        bne.s   sccta
        btst    #1,d0
        bne.s   scctb
        movem.l (sp)+,d0/a0-a1
        rte
        
*-------------------------------
*       SCC receiver full interrupt
sccrxa:         
        movem.l d0/a0-a1,-(sp)
sccra:  lea     sccbase,a0      ;channel A
        bra.s   sccrxf

sccrxb: movem.l d0/a0-a1,-(sp)
sccrb:  lea     sccbase+4,a0    ;channel B

sccrxf: move.b  #1,rxiflg       ;flag occurrence
        sccrd   1,d0            ;get status
        andi.b  #$70,d0         ;mask crc/framing, overrun, parity              
        beq.s   sccrxd          ;any error?
        or.b    d0,rxstat
        sccwr   0,$30           ;reset error
sccrxd: move.l  rxptr,a1
        sccrd   8,d0            ;get data
        move.b  d0,(a1)+
        move.l  a1,rxptr
        bra     sccidn

*-------------------------------
*       external status interrupts
sccsta: move.l  a0,-(sp)
        lea     sccbase,a0      ;channel A
        bra.s   sccsti
sccstb: move.l  a0,-(sp)
        lea     sccbase+4,a0    ;channel B

sccsti: move.b  #1,exiflg
        sccwr   0,$10           ;reset ext/status int
        sccwr   0,$38           ;reset highest IUS
        move.l  (sp)+,a0
        rte

*--------------------------------
*       special character interrupt
sccspa: move.l  a0,-(sp)
        lea     sccbase,a0      ;channel A
        bra.s   sccsti
sccspb: move.l  a0,-(sp)
        lea     sccbase+4,a0    ;channel B
        sccrd   8,d0            ;read data
        move.b  d0,special      
        sccrd   1,d0            ;read status
        sccwr   0,$30           ;error reset to unlock FIFO
        sccwr   0,$38           ;reset highest IUS
        move.l  (sp)+,a0
        rte
        
*------------------------
*       init scc channel
*       entry:  a0 = channel base address
sccinit:
        movem.l d0-d1,-(sp)

*       reset appropriate channel
        cmp.w   #$8c81,a0
        beq.s   sccares
        sccwr   9,$40           ;reset chn B
        bra.s   scini1
sccares:
        sccwr   9,$80           ;reset chn A

scini1: lea     scctbl,a1
        move    #scctbe-1,d0
sccina: move.b  (a1)+,d1
        move.b  d1,(a0)
        dbra    d0,sccina
        movem.l (sp)+,d0-d1
        rts

*------------------------
*       init scc channel for break mode
*       entry:  a0 = channel base address
sccibrk:
        movem.l d0-d1,-(sp)
        bsr     sccreset         ; reset both channels

scini2: lea     scctbl1,a1
        move    #scctbe1-1,d0
sccina1: move.b  (a1)+,d1
        move.b  d1,(a0)
        dbra    d0,sccina1
        movem.l (sp)+,d0-d1
        rts

*------------------------
*       init scc channel for data mode, rts, dtr on 
*       entry:  a0 = channel base address
sccidat:
        movem.l d0-d1,-(sp)
        bsr     sccreset         ;reset both channels

scini3: lea     scctbl2,a1
        move    #scctbe2-1,d0
sccina2: move.b  (a1)+,d1
        move.b  d1,(a0)
        dbra    d0,sccina2
        movem.l (sp)+,d0-d1
        rts

***********************************************************************
;scc hard reset
;a0 points to scc base

sccreset:
        sccwr   9,$c0           ;reset
        move    #$ffff,d2       ;wait after reset
sciwt:
	nop			;RWS.TPES First attempt at better scc reset
	dbra    d2,sciwt        ;wait after reset
        rts

nolan:
;	move.b  #14,$ffff8800
 ;       move.b  $ffff8800,d0       ; disconnect lan from port "A
  ;      bset    #7,d0        
   ;     move.b  #14,$ffff8800
    ;    move.b  d0,$ffff8802
        rts

yeslan:
;	move.b  #14,$ffff8800      
 ;       move.b  $ffff8800,d0       ; connect lan to port "A
  ;      bclr    #7,d0              
   ;     move.b  #14,$ffff8800
    ;    move.b  d0,$ffff8802
        rts

        .data

*       scc interrupt vector table
sccvtb: dc.l    scctxb          ;tx empty
        dc.l    sccstb          ;tx status
        dc.l    sccrxb          ;rx full
        dc.l    sccspb          ;rx special char
        dc.l    scctxa
        dc.l    sccsta
        dc.l    sccrxa
        dc.l    sccspb

*       error message tables
sccerr:
        dc.l    scctxto
        dc.l    sccrxto
        dc.l    prgerr
        dc.l    prgerr
        dc.l    sccpar
        dc.l    sccovr
        dc.l    sccfrm
        dc.l    scccmp
mcerr:  
        dc.l    dtrdcd
        dc.l    dtrdsr
        dc.l    rtscts
        dc.l    prgerr
        dc.l    prgerr
        dc.l    prgerr
        dc.l    prgerr
        dc.l    prgerr
sccdmam:
        dc.l    scctxto
        dc.l    sccrxto
        dc.l    scdmacnt
        dc.l    sccbe
        dc.l    sccpar
        dc.l    sccovr
        dc.l    sccfrm
        dc.l    scccmp

sccmsg: dc.b    'Testing SCC',cr,lf,eot
dmatxm: dc.b    'SCC DMA output:',cr,lf,eot
dmarxm: dc.b    'SCC DMA input:',cr,lf,eot
scdmacnt: dc.b  'Non-zero DMA count',cr,lf,eot
sccbe:  dc.b    'DMA Bus Error',cr,lf,eot

crlfm:  dc.b    cr,lf,eot
prgerr: dc.b    'bad index--programming error',cr,lf,eot
scalper: dc.b   'SCC A internal loopback: ',cr,lf,eot
scblper: dc.b   'SCC B internal loopback: ',cr,lf,eot
asnera: dc.b    'Port A async mode: ',cr,lf,eot
asnerb: dc.b    'Port B async mode: ',cr,lf,eot
scctxto: dc.b   'Transmitter time-out',cr,lf,eot
sccrxto: dc.b   'Receiver time-out',cr,lf,eot
sccovr: dc.b    'Overrun',cr,lf,eot
sccfrm:  dc.b   'Framing error',cr,lf,eot
sccpar: dc.b    'Parity error',cr,lf,eot
scccmp: dc.b    'Data compare error',cr,lf,eot
mcaerr: dc.b    'Port A modem control error: ',eot
mcberr: dc.b    'Port B modem control error: ',eot
sccinm: dc.b    'SCC interrupt error:',cr,lf,eot
dtrdcd: dc.b    'DTR-DCD ',eot
dtrdsr: dc.b    'DTR-DSR ',eot
rtscts: dc.b    'RTS-CTS ',eot
nosclpa: dc.b   'Port A has no loopback connector',cr,lf,eot
nosclpb: dc.b   'Port B has no loopback connector',cr,lf,eot
lanerr:  dc.b   'LAN has no loopback connector',cr,lf,eot
sccdnm: dc.b    'SCC test done',cr,lf,eot
notxi:  dc.b    'No Tx interrupt',cr,lf,eot
norxi:  dc.b    'No Rx interrupt',cr,lf,eot
landcd: dc.b    'LAN ERROR: DCD IS ACTIVE WITHOUT RTS ON',cr,lf,eot
landcdn: dc.b   'LAN ERROR: RTS IS ACTIVE BUT DCD IS NOT RESPONDING',cr,lf,eot
nefifoerr: dc.b	'UNABLE TO EMPTY RECIEVER FIFO'

*       SCC initialization 
scctbl:
        dc.b    4,$44           ;x16, 1 stop, no parity
        dc.b    3,$c0           ;rx 8 bit, no crc, rx disabled
        dc.b    5,$60           ;tx 8 bit, no crc, tx disabled
        dc.b    9,0             ;status low
        dc.b    10,0            ;NRZ
        dc.b    11,$50          ;tx & rx clk = brg, trxc=in
        dc.b    12,24           ;clock divisor for 9600 (pclk)
        dc.b    13,0            ;divisor high
        dc.b    14,2            ;BRG = PCLK
        dc.b    14,3            ;enable BRG
        dc.b    3,$c1           ;enable Rx, 8 bits
        dc.b    5,$68           ;enable Tx, 8 bits
        dc.b    15,0            ;ex/status ints off
scctbe  equ     $-scctbl

scctbl1:
        dc.b    4,$44           ;x16, 1 stop, no parity
        dc.b    3,$c0           ;rx 8 bit, no crc, rx disabled
        dc.b    5,$70           ;tx 8 bit, no crc, tx disabled, break
        dc.b    9,0             ;status low
        dc.b    10,0            ;NRZ
        dc.b    11,$50          ;tx & rx clk = brg, trxc=in
        dc.b    12,24           ;clock divisor for 9600 (pclk)
        dc.b    13,0            ;divisor high
        dc.b    14,2            ;BRG = PCLK
        dc.b    14,3            ;enable BRG
        dc.b    3,$c1           ;enable Rx, 8 bits
        dc.b    5,$78           ;enable Tx, 8 bits
        dc.b    15,0            ;ex/status ints off
scctbe1 equ     $-scctbl1

scctbl2:
        dc.b    4,$44           ;x16, 1 stop, no parity
        dc.b    3,$c0           ;rx 8 bit, no crc, rx disabled
        dc.b    5,$e2           ;tx 8 bit, no crc, tx disabled, rts,dtr on
        dc.b    9,0             ;status low
        dc.b    10,0            ;NRZ
        dc.b    11,$50          ;tx & rx clk = brg, trxc=in
        dc.b    12,24           ;clock divisor for 9600 (pclk)
        dc.b    13,0            ;divisor high
        dc.b    14,2            ;BRG = PCLK
        dc.b    14,3            ;enable BRG
        dc.b    3,$c1           ;enable Rx, 8 bits
        dc.b    5,$ea           ;enable Tx, 8 bits, rts, dtr on
        dc.b    15,0            ;ex/status ints off
scctbe2 equ     $-scctbl2


