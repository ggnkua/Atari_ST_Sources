          page   132,65,3,3
;         opt       CC
;********************************************************
;*    Motorola Austin DSP Operation  10 April 1991      *
;*                                                      *
;*  COPYRIGHT (C) BY MOTOROLA INC, ALL RIGHTS RESERVED  *
;*                                                      *
;*      ALTHOUGH THE INFORMATION CONTAINED HEREIN,      *
;*      AS WELL AS ANY INFORMATION PROVIDED RELATIVE    *
;*      THERETO, HAS BEEN CAREFULLY REVIEWED AND IS     *
;*      BELIEVED ACCURATE, MOTOROLA ASSUMES NO          *
;*      LIABILITY ARISING OUT OF ITS APPLICATION OR     *
;*      USE, NEITHER DOES IT CONVEY ANY LICENSE UNDER   *
;*      ITS PATENT RIGHTS NOR THE RIGHTS OF OTHERS.     *
;*                                                      *
;********************************************************

;****************************************************************************
;   master2.asm  - demo code for DSP96002 multi-device simulation
;
;   9 April 91: Roman Robles - polish for 4 dev. sim.
;
;   relavant topology for this simulation:
;
;                       B       A          B       A
;             ----------+       +----------+       +-----------
;              Upstream |       |  Master  |       |   Slave   
;              DSP96002 |=====> | DSP96002 |=====> |  DSP96002 
;             __________|(PIO)  |__________| (DMA) |___________
;
;****************************************************************************
; Equates Section
;****************************************************************************

RESET   equ     $00000000               ; reset isr
DMA0    equ     $00000010               ; DMA channel 0 isr
MAIN    equ     $00000200               ; main routine

IPR     equ     $FFFFFFFF               ; interrupt priority reg
BCRA    equ     $FFFFFFFE               ; port a bus control reg
BCRB    equ     $FFFFFFFD               ; port b bus control reg
PSR     equ     $FFFFFFFC               ; port select reg

;****************************************************************************
; Addresses of Host's DMA Channel 0 Registers
;****************************************************************************

DMA0SAR equ     $FFFFFFDE               ; DMA ch 0 source address reg
DMA0SOR equ     $FFFFFFDD               ; DMA ch 0 source offset reg
DMA0CR  equ     $FFFFFFDC               ; DMA ch 0 counter reg
DMA0DAR equ     $FFFFFFDA               ; DMA ch 0 destination address reg
DMA0CSR equ     $FFFFFFD8               ; DMA ch 0 control/status reg

;****************************************************************************
; Addresses of Slave's Port A Host Interface Registers
;****************************************************************************

SLAVEADDR equ   $FFFFFFC0               ; base address of slave host port reg
XMR       equ   SLAVEADDR+$C            ; direct address X memory read
HICSR     equ   SLAVEADDR+$20           ; slave host int control/status reg
RX        equ   SLAVEADDR+$28           ; receive reg
TX        equ   SLAVEADDR+$28           ; transmit reg
CVR       equ   SLAVEADDR+$34           ; command vector reg


;****************************************************************************
; Addresses of Upstream DSP's Port B Host Interface Registers
;****************************************************************************

UpstrADDR equ   $20000000               ; base address of upstr host port reg
UHICSR    equ   UpstrADDR+$20           ; Upstr host int control/status reg
URX       equ   UpstrADDR+$28           ; receive reg


RXDF    equ   0                         ; receiver data full bit 0 in
                                        ;   interrupt control/status reg
TRDY    equ   2                         ; transmitter ready bit
                                        ;   2 in interrupt control/status reg
INIT    equ   6                         ; initialize bit 6 in the interrupt
                                        ;   control/status reg
HMRC    equ   15                        ; host memory read command bit 15
                                        ;   in interrupt control/status reg
HC      equ   15                        ; host command bit 15 in the command
                                        ;   vector register
DE      equ   31                        ; DMA channel enable control bit 
                                        ;   31 in DMA control/status reg

;****************************************************************************
; fast interrupt service routines
;****************************************************************************

        org     p:RESET                 ; reset isr
        jmp     MAIN

        org     p:DMA0                  ; block DMA transfer finished
        nop                             ; for test purposes, stop here when 
        nop                             ; done

;*****************************************************************************
;  DMA setup for DMA transfers between DSP96000 master and DSP96000 slave
;  (without semaphore control) using interrupts.
;  configure system to include:
;  1) 
;  2) all P,X,Y,I/O external acesses from port B with no wait states
;  3)      except Y:$20000000-$3FFFFFFF which is upstream DSP's aHI
;*****************************************************************************

        org     p:MAIN
        movep   #$00030000,x:IPR        ; DMA channel 0 int priority level = 2
        movep   #$0,x:BCRA              ; no wait states for portb P,X,Y,I/O
        movep   #$0,x:BCRB              ; ...don't care about page fault
        movep   #$00FFFDFF,x:PSR        ; all external fetches will be from
                                        ; port B except Y:$20000000-3FFFFFFF
        ori     #$8,omr                 ; enable the internal data ROMs
        andi    #$CF,mr                 ; unmask all enabled interrupts

;*****************************************************************************
;  The master verifies that the slave DMA channel 0 is free by reading
;    the DMA channel 0 control/status register.  This can be done using
;    the X memory read procedure.  If the DMA channel is dedicated to this
;    transfer, this step may be bypassed.
;*****************************************************************************

wait1   
        jclr    #TRDY,y:HICSR,wait1     ; wait for TX and HRX regs to clear
        movep   #DMA0CSR,y:XMR          ; read contents of slave's
                                        ;   ch 0 control/status reg
wait2
        jset    #HMRC,y:HICSR,wait2     ; wait for contents of slave's ch 0 
                                        ;   csr to be transferred to the RX reg
        jset    #DE,y:RX,wait1          ; continue to wait if slave's
                                        ;   DMA ch 0 is enabled

;*****************************************************************************
;  The master initializes the slave's DMA channel using Host Command
;*****************************************************************************

wait3
        jset    #HC,y:CVR,wait3         ; continue to wait if slave is
                                        ;   processing a command vector
        movep   #$800E,y:CVR            ; use the default host cmd. vector
                                        ;   at location $1C, also set
                                        ;   HC (host command) bit
wait4
        jset    #HC,y:CVR,wait4         ; continue to wait if slave is
                                        ;   still processing DMA init
                                        ;   command vector
; additional nops may be necessary
         
;*****************************************************************************
;  The master initializes its own DMA channel.
;    In this example, the contents of the 512 Y data ROM are transferred
;    to the the slave address X:$1000-$13FF
;*****************************************************************************

        movep   #$400,x:DMA0SAR         ; init DMA ch 0 source address reg to
                                        ;   point to beginning of Y data ROM
        movep   #1,x:DMA0SOR            ; init DMA ch 0 source offset reg to
                                        ;   increment by 1 through ROM
        movep   #TX,x:DMA0DAR           ; init DMA ch 0 dest address reg
                                        ;   to point to slave's HI TX
        movep   #512,x:DMA0CR           ; transfer all 512 words from the data 
                                        ;   ROM
        movep   #$C4000117,x:DMA0CSR    ; enable DMA and DMA interrupt
                                        ; core and channel 0 have priority
                                        ; irqa is DMA request
                                        ; internal Y data is source
                                        ; external Y I/O is dest

;*****************************************************************************
;  The master initializes the slave's host interface for DMA
;*****************************************************************************

        movep   #$1050,y:HICSR          ;   DMAE=1,INIT=1,TREQ=1

;*****************************************************************************
;  main routine would go here
;*****************************************************************************

        move       #UHICSR,r4           ;load a pointer to the upstream HI
        nop
_l1     jclr       #RXDF,y:(r4),_l2     ;loop until Upstream guy has said
                                        ;   something to us...
        move       y:URX,D0.l           ;then save the word...
_l2     jmp        _l1                  ;and do it again...

        end
