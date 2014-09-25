;************************************************************
; file:intioevb.asm                                         *
;                                                           *
; SSI Interrupt handler example for the DSP56ADC16 EVB        *
;                                                           *
;************************************************************
; Written by C.D.T.     10/31/88        Rev. 1.0 11/1/88
                
        page 132

; Program start address
       
        org     p:$40

; Initialize IPR to allow interrupts to occur

        movep #$3000,x:$FFFF    ;allow all interrupts

; Set up ADS board in case of force break instead of force reset

        movep #0,x:$FFFE        ;set bcr to zero
        movec #1,sp             ;init stack pointer
        movec #0,sr             ;clear loop flag/interrupt mask bits

; Set up the SSI for operation with the DSP56ADC16EVB
; The following code sets port C to function as SCI/SSI

        move #$0,a0             ;zero PCC to cycle it
        movep a0,x:$FFE1
                
        move #$0001ff,a0
        movep a0,x:$FFE1        ;write PCC
                
; The following code sets the SSI CRA and CRB control registers for external
; cont. synchronous clock, normal mode.

        move #$004000,a0        ;CRA pattern for word length=16 bits
        movep a0,x:$FFEC

        move #$00B200,a0    ;CRB pattern for cont. ck,sych,normal mode
        movep a0,x:$FFED    ;word long frame sync, RX interrupts enab.,
                                        ;external clock and frame sync

; Sample rate is controlled by DSP56ADC16 board.   

self    jmp self                        ;looping waiting for interrupt


;********************************************
; Interrupt Routine- Read A/D and write D/A *
;********************************************

; The following code reads the A/D data from the SSI RX register
; and writes the data to the SSI TX register. Since SSI TX and RX
; operate synchronously the TX empty flag need not be checked.  TX 
; is guaranteed to be empty due to reception of new A/D word.
; The user may wish to substitute custom I/O routines such as FIFO buffer
; service routines etc.

rdwrite movep x:$FFEF,a         ;read SSI RX reg. for A/D data
                movep a,x:$FFEF         ;write to SSI TX reg. for D/A
                rti

;***************************************************************
; Interrupt exception handlers for SSI RX-TX overrun/underrun  *
;***************************************************************

; The following clears the exception flag for the SSI transmitter and returns

txcept  movep X:$FFEE,A0        ;read status
                movep a1,X:$FFEF        ;send something         
                nop                     ;place a BREAKPOINT here
                rti                     ; for debugging exceptions

; The following clears the exception flag for the SSI receiver and returns

rxcept  movep X:$FFEE,A0        ;read status
                movep X:$FFEF,a1        ;receive something
                nop                     ;place a BREAKPOINT here
                rti                     ;for debugging exceptions

;**************************************************************
; Set up JSR's at the interrupt addresses for SSI interrupts  *
;**************************************************************

        org p:$000C     ;SSI handler address
        jsr rdwrite     ;go handle SSI I/O

        org p:$000e     ;SSI exception vector-receive
        jsr rxcept              

        org p:$0012     ;SSI exception vector-transmit
        jsr txcept      

        end