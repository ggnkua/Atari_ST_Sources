	.extern conout,conin,uconin,constat
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
* Console.s - Console I/O routines (used by DD-ROM)
*
* By Roy Stedman @ Atari 29JAN92
*
*****************************************************************************
        .text

*-------------------------------
* conout - character in d1 output unless part of esc sequence
*       uses : escflag.b, Y1store, d1
conout:
        tst.b   escflag
        bne     .escstuff
        cmpi.b  #esc,d1
        bne     .outchar
        move.b  #$01,escflag
        rts
.outchar:
        bsr     ascii_out
        rts
.escstuff:
        cmpi.b  #$01,escflag
        bne     .escYstuff
        clr.b   escflag
        cmpi.b  #'K',d1
        beq     escK
        cmpi.b  #'p',d1
        beq     escp
        cmpi.b  #'q',d1
        beq     escq
        cmpi.b  #'e',d1
        beq     esces
        cmpi.b  #'E',d1
        beq     clearsc
        cmpi.b  #'j',d1
        beq     escjs
        cmpi.b  #'k',d1
        beq     escks
        cmpi.b  #'D',d1
        beq     escD
        cmpi.b  #'w',d1
        beq     escw
        cmpi.b  #'v',d1
        beq     escv
        cmpi.b  #'Y',d1
        beq     .escY1
        bsr     ascii_out       ; none of the above, echo letter
        rts
.escY1:
        move.b  #$02,escflag
        rts
.escYstuff:     
        cmpi.b  #$02,escflag
        bne     .escYs1
        move.b  d1,Y1store
        move.b  #$03,escflag
        rts
.escYs1:
        move.b  d1,d0           ; put col in right place
        move.b  Y1store,d1      ; row
        clr.b   escflag
        bra     escy


* BELOW FROM MENU.S 29JAN92 : RWS

*-------------------------------
*                                       
*       test keyboard buffer and RS232 status           
*       for data                        
*       Exit: d0=0 if empty             
*             d0=ff if keyboard         

constat:
        moveq   #0,d0           ;got data=false
        bsr     ikbdptr         ;set pointers
        lea     ibufhead(a0),a2 ;pointer to head of queue
        lea     ibuftail(a0),a3 ;pointer to tail of queue
        cmpm.w  (a3)+,(a2)+     ;test for data in queue
        beq.s   conrs           ;br if no data
        moveq   #$ff,d0
        rts

****************************************************************************
* MRW
*       Test RS232 port for data        
*          Exit:   d0=0 if empty           
*                  d0=7f if full           
****************************************************************************
conrs:
       btst    #rsinp,consol   ;loopback installed?
       bne.s   norsin          ;then don't check input
*NO!       lea     sccb_base,a4    ; point to the serial port base address
rsstat:
       move.b  #rr0,sccb_base	; Read Tx/Rx buffer status register
       btst    #0,sccb_base	; ?? Does Rx buffer contain a character
       beq.s   norsin          ; no, branch
;       bne.s   norsin          ; no, branch
       moveq   #$7f,d0         ; yes
       rts
norsin:
       moveq   #0,d0
       rts
*eMRW

*----------------------------------------
*       Get a key from keyboard buffer  
*       or RS232.                       
*       Interrupt fills buffer with     
*       make codes and ascii (keybd).   
*       RS232 is polled.
*       Exit:   d0.b=ascii              
*               d1.b=scan code          
*               d1.b=0 if from rs232    
conin:  movem.l a0-a3,-(a7)
cpoll:  
;;        tst.b is_rtc
 ;;      bne.s .1
  ;;      bsr     dsp_rtc
.1:
        bsr     constat         ; keyboard?
        tst     d0
        beq.s   cpoll   
        bmi.s   cpoll1          ; got key
        btst    #rsinp,consol   ; test rs232 enable
        bne.s   cpoll

****************************************************************************
* MRW
*       Got RS232 input
*
****************************************************************************
       move.b  scc_data+sccb_base,d0     ; Get character from serial port
       clr.b   d1                  ;no scan code
       bra.s   cwi3
*eMRW

*       Got Keyboard input
cpoll1: movea.l #kbufrec,a0     ;point to ikbd buffer record
        move    sr,-(a7)        ;protect this upcoming test
        ori     #$700,sr
        move.w  ibufhead(a0),d1 ;get current head pointer offset from buffer
        cmp.w   ibuftail(a0),d1 ;head=tail?
        beq.s   cwi2            ;yes

*       check for wrap of pointer

        addq.w  #2,d1           ;i=h+2
        cmp.w   ibufsiz(a0),d1  ;? i>= current bufsiz?
        bcs.s   cwi1            ;no...
        moveq   #$0,d1          ;wrap pointer
cwi1:   move.l  ibufptr(a0),a1  ;get base address of buffer
        move.w  0(a1,d1),d0     ;get character
        move.w  d1,ibufhead(a0) ;store new head pointer to buffer record
cwi2:   move    (a7)+,sr
        move.w  d0,d1
        and.w   #$007f,d0       ;clear all but low 7 bits
        lsr.w   #8,d1           ;leave scan code in low byte
cwi3:   cmpi.b  #$61,d0         ;convert lower case letter to upper case
        blt.s   cwi4
        cmpi.b  #$7a,d0
        bgt.s   cwi4
        andi.b  #$df,d0         
cwi4:   movem.l (a7)+,a0-a3
        rts

*----------------------------------------
*       Get a key from keyboard buffer  
*       or RS232. NO UPPER CASE CONV. SHIFT WORKS!                      
*       Interrupt fills buffer with     
*       make codes and ascii (keybd).   
*       RS232 is polled.
*       Exit:   d0.b=ascii              
*               d1.b=scan code          
*               d1.b=0 if from rs232    
*
* NOTE : SHIFT AND CTRL DO NOT COME THROUGH AS KEYS
* Their results do (unlike conin)

cconin: movem.l a0-a3,-(a7)
.cpoll: bsr     constat         ; keyboard?
        tst     d0
        beq.s   .cpoll   
        bmi.s   .cpoll1         ; - = got key,  + = rs232 char
        btst    #rsinp,consol   ; test rs232 enable
        bne.s   .cpoll

****************************************************************************
* MRW
*       Got RS232 input
*
****************************************************************************
       move.b  scc_data+sccb_base,d0     ; Get character from serial port
       clr.b   d1                  	;no scan code
       bra.s   .cwi3
*eMRW

*       Got Keyboard input
.cpoll1: 
        movea.l #kbufrec,a0     ;point to ikbd buffer record
        move    sr,-(a7)        ;protect this upcoming test
        ori     #$700,sr
        move.w  ibufhead(a0),d1 ;get current head pointer offset from buffer
        cmp.w   ibuftail(a0),d1 ;head=tail?
        beq.s   .cwi2           ;yes

*       check for wrap of pointer
        addq.w  #2,d1           ;i=h+2
        cmp.w   ibufsiz(a0),d1  ;? i>= current bufsiz?
        bcs.s   .cwi1           ;no...
        moveq   #$0,d1          ;wrap pointer
.cwi1:  move.l  ibufptr(a0),a1  ;get base address of buffer
        move.w  0(a1,d1),d0     ;get character
        move.w  d1,ibufhead(a0) ;store new head pointer to buffer record
.cwi2:  move    (a7)+,sr
        move.w  d0,d1
        and.w   #$007f,d0       ;clear all but low 7 bits
        lsr.w   #8,d1           ;leave scan code in low byte
.cwi3:
*       * NO FORCE UPPER CASE
        cmpi.b  #$2a,d1         ; scan lshift   
        beq     .cpoll
        cmpi.b  #$36,d1         ; scan rshift
        beq     .cpoll
        cmpi.b  #$1d,d1         ; scan ctrl
        beq     .cpoll
.cwi4:  movem.l (a7)+,a0-a3
        rts


*--------------------------------------
* uconin - upper case output of cconin
* 29JAN92
uconin:
        bsr     cconin
        cmpi.b  #$61,d0         ;convert lower case letter to upper case
        blt.s   .uc1
        cmpi.b  #$7a,d0
        bgt.s   .uc1
        andi.b  #$df,d0         
.uc1:
        rts

*--------------------------------------

c_conin:
;        bsr     dsp_rtc       ;display rtc update on every return to menu
        bsr     conin
        rts

