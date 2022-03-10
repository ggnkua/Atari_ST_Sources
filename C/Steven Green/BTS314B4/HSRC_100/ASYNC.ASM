;==============================================================================
;
;                             HydraCom Version 1.00
;
;                        A sample implementation of the
;                  HYDRA Bi-Directional File Transfer Protocol
;
;                            HydraCom was written by
;                  Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT
;                 COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED
;
;                      The HYDRA protocol was designed by
;                Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT and
;                            Joaquim H. Homrighausen
;                 COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED
;
;
; Revision history:
; 06 Sep 1991 - (AGL) First tryout
; .. ... .... - Internal development
; 11 Jan 1993 - HydraCom version 1.00, Hydra revision 001 (01 Dec 1992)
;
;
; For complete details of the Hydra and HydraCom licensing restrictions,
; please refer to the license agreements which are published in their entirety
; in HYDRACOM.C and LICENSE.DOC, and also contained in the documentation file
; HYDRACOM.DOC
;
; Use of this file is subject to the restrictions contained in the Hydra and
; HydraCom licensing agreements. If you do not find the text of this agreement
; in any of the aforementioned files, or if you do not have these files, you
; should immediately contact LENTZ SOFTWARE-DEVELOPMENT and/or Joaquim
; Homrighausen at one of the addresses listed below. In no event should you
; proceed to use this file without having accepted the terms of the Hydra and
; HydraCom licensing agreements, or such other agreement as you are able to
; reach with LENTZ SOFTWARE-DEVELOMENT and Joaquim Homrighausen.
;
;
; Hydra protocol design and HydraCom driver:         Hydra protocol design:
; Arjen G. Lentz                                     Joaquim H. Homrighausen
; LENTZ SOFTWARE-DEVELOPMENT                         389, route d'Arlon
; Langegracht 7B                                     L-8011 Strassen
; 3811 BT  Amersfoort                                Luxembourg
; The Netherlands
; FidoNet 2:283/512, AINEX-BBS +31-33-633916         FidoNet 2:270/17
; arjen_lentz@f512.n283.z2.fidonet.org               joho@ae.lu
;
; Please feel free to contact us at any time to share your comments about our
; software and/or licensing policies.
;
;==============================================================================


          IDEAL

IFDEF MODL
          MODEL MODL
ELSEIFDEF _SMALL
          MODEL SMALL
ELSEIFDEF _LARGE
          MODEL LARGE
ENDIF


EOI             equ     020h                    ; 8259 end-of-interupt
Ctrl8259_0      equ     020h                    ; 8259 port
Ctrl8259_1      equ     021h                    ; 8259 port (Masks)
BufSize         equ     4100                    ; Buffer Size




        DATASEG

; Various things to be set upon AsyncInit()
VectorNum       db      ?                       ; Vector Number
EnableIRQ       db      ?                       ; Mask to enable 8259 IRQ
DisableIRQ      db      ?                       ; Mask to disable 8259 IRQ
VectorSeg       dw      ?                       ; Old Vector Segment
VectorOfs       dw      ?                       ; Old Vector Offset

Fifo            db      ?                       ; Nonzero if 16550 FIFO enabled
CTShand         dw      ?                       ; Nonzero if CTS handshaking ok

; Register Addresses for the 8250 UART
Port            dw      ?                       ; Port Base Address
LABEL RegStart word
THR             dw      ?                       ; Transmitter Holding Register
RDR             dw      ?                       ; Receiver Data Register
BRDL            dw      ?                       ; Baud Rate Divisor, Low byte
BRDH            dw      ?                       ; Baud Rate Divisor, High Byte
IER             dw      ?                       ; Interupt Enable Register
IIR             dw      ?                       ; Interupt Identification Reg
FCR             dw      ?                       ; FIFO Control Register
LCR             dw      ?                       ; Line Control Register
MCR             dw      ?                       ; Modem Control Register
LSR             dw      ?                       ; Line Status Register
MSR             dw      ?                       ; Modem Status Register
; Register Offsets for the UART
RegOffsets      dw      0, 0, 0, 1, 1, 2, 2, 3, 4, 5, 6

; Buffer Data
RecBuffer       db      BufSize DUP (?)         ; Receive Buffer
RecHead         dw      ?                       ; Buffer Head Pointer
RecTail         dw      ?                       ; Buffer Tail Pointer
TransBuffer     db      BufSize DUP (?)         ; Transmit Buffer
TransHead       dw      ?                       ; Buffer Head Pointer
TransTail       dw      ?                       ; Buffer Tail Pointer


        CODESEG

        PUBLIC  _AsyncInit,     _AsyncDump,     _AsyncPurge,    _AsyncStop
        PUBLIC  _AsyncIn,       _AsyncOut,      _AsyncSet
        PUBLIC  _AsyncHand,     _AsyncStat,     _AsyncInStat
        PUBLIC  _AsyncOutStat,  _AsyncCTS,      _AsyncFifo


;-----------------------------------------------------------------------------
; AsyncDump                                          Empty the transmit buffer
;-----------------------------------------------------------------------------
; void  AsyncDump (void);
;
;
;-----------------------------------------------------------------------------
PROC    _AsyncDump
        cli
        push    ax
        mov     ax, offset TransBuffer
        mov     [TransHead], ax
        mov     [TransTail], ax
        pop     ax
        sti
        ret
ENDP    _AsyncDump



;-----------------------------------------------------------------------------
; AsyncPurge                                          Empty the receive buffer
;-----------------------------------------------------------------------------
; void  AsyncPurge (void);
;
;
;-----------------------------------------------------------------------------
PROC    _AsyncPurge
        cli
        push    ax
        mov     ax, offset RecBuffer
        mov     [RecHead], ax
        mov     [RecTail], ax
        pop     ax
        sti
        ret
ENDP    _AsyncPurge



;-----------------------------------------------------------------------------
; AsyncInit                              Initalize Serial Port and install ISR
;-----------------------------------------------------------------------------
;       void    AsyncInit( int port)
;
;       Where Port is
;               0  =  COM1
;               1  =  COM2
;               2  =  COM3
;               3  =  COM4
;
;-----------------------------------------------------------------------------
PROC    _AsyncInit
        ARG     CommPort:word

        push    bp
        mov     bp, sp

;---- Set various things according to com port number
        mov     ax, [CommPort]

;----- COM1
        cmp     ax, 0
        jne     @@1
        mov     [Port], 03F8h
        mov     [VectorNum], 0Ch
        mov     [EnableIRQ], 0EFh
        mov     [DisableIRQ], 10h
        jmp     short @@Done
@@1:
;----- COM2
        cmp     ax, 1
        jne     @@2
        mov     [Port], 02F8h
        mov     [VectorNum], 0Bh
        mov     [EnableIRQ], 0F7h
        mov     [DisableIRQ], 08h
        jmp     short @@Done
@@2:
;----- COM3
        cmp     ax, 2                           ; 2
        jne     @@3
        mov     [Port], 03E8h                   ; 03E8
        mov     [VectorNum], 0Ch                ; 0C
        mov     [EnableIRQ], 0EFh               ; EF
        mov     [DisableIRQ], 10h               ; 10
        jmp     short @@Done
@@3:
;----- COM4
        mov     [Port], 02E8h                   ; 02E8
        mov     [VectorNum], 0Bh                ; 0B
        mov     [EnableIRQ], 0F7h               ; F7
        mov     [DisableIRQ], 08h               ; 08
@@Done:

;---- Compute Register locations
        mov     cx, 11
        mov     bx, offset RegOffsets
        push    di
        mov     di, offset RegStart
@@4:
        mov     ax, [bx]
        add     ax, [Port]
        mov     [di], ax
        add     bx, 2
        add     di, 2
        loop    @@4

        pop     di


;----- Initalize Buffers
        call    _AsyncDump
        call    _AsyncPurge

;--- Save and reassign interrupt vector
        push    ds                      ; Save Old Vector
        mov     al,[VectorNum]
        mov     ah,35h
        int     21h
        mov     [VectorSeg], es
        mov     [VectorOfs], bx

        mov     al, [VectorNum]
        push    cs                      ; Set New Vector
        pop     ds
        mov     dx, offset AsyncISR
        mov     ah, 25h
        int     21h
        pop     ds

;----- Enable 8259 interrupt (IRQ) line for this async adapter
        in      al, Ctrl8259_1
        and     al, [EnableIRQ]
        out     Ctrl8259_1, al

;----- Enable 8250 Interrupt-on-data-ready
        mov     dx, [LCR]               ; Read Line control register and clear
        in      al, dx                  ; bit 7, the Divisor Latch Address
        and     al, 07Fh
        out     dx, al

        mov     dx, [IER]
        mov     al, 0                   ; we're gonna test the UART first
        out     dx, al
        in      al, dx                  ; if this isn't 0, there's no UART
        cmp     al, 0
        jnz     @@222

        mov     al, 3
        out     dx, al

;----- Try to enable 16550 FIFOs
        mov     dx, [FCR]               ; FIFO Control Register
        mov     al, 0C7h                ; bits 76210 (trigger14,clearIO,enable)
        out     dx, al                  ; Write
        mov     dx, [IIR]
        in      al, dx
        and     al, 0C0h                ; 8250/16450 sets none of the 2 bits
        cmp     al, 0C0h                ; faulty 16550 sets 1 of the 2 bits
        je      okfifo
        mov     dx, [FCR]               ; didn't work, turn off case faulty 550
        xor     al, al                  ; set to zero = no FIFO
        out     dx, al
okfifo: mov     [Fifo], al              ; store 16550 FIFO situation

;----- Reset CTS handshaking flag
        mov     [CTShand], 0            ; Disable CTS handshaking

;----- Clear 8250 Status and data registers
@@10:
        mov     dx, [RDR]               ; Clear RDR by reading port
        in      al, dx
        mov     dx, [LSR]               ; Clear LSR
        in      al, dx
        mov     dx, [MSR]               ; Clear MSR
        in      al, dx
        mov     dx, [IIR]               ; Clear IIR
        in      al, dx
        test    al, 1
        jz      @@10

;----- Set Bit 3 of MCR -- Enable interupts, also raise DTR and RTS
        mov     dx, [MCR]
        in      al, dx
        or      al, 0Bh
        out     dx, al

;----- Clear Buffers Just in case
        call    _AsyncDump
        call    _AsyncPurge

;----- Return
        xor     ax, ax
@@222:
        pop     bp
        ret
ENDP    _AsyncInit



;-----------------------------------------------------------------------------
;  AsyncStop                                                     Uninstall ISR
;-----------------------------------------------------------------------------
;       void  AsyncStop( void)
;-----------------------------------------------------------------------------
PROC    _AsyncStop
        push    bp
        mov     bp, sp

;----- Mask (disable) 8259 IRQ Interrupt
        in      al, Ctrl8259_1
        or      al, [DisableIRQ]
        out     Ctrl8259_1, al

;----- Disable 8250 interrupt
        mov     dx, [LCR]
        in      al, dx
        and     al, 07Fh
        out     dx, al
        mov     dx, [IER]
        xor     al, al
        out     dx, al

;----- Set bit 3 in MCR to 0
        mov     dx, [MCR]
        in      al, dx
        and     al, 0F7h
        out     dx, al

;----- Disable 16550 FIFOs
        mov     dx, [FCR]               ; FIFO Control Register
        xor     al, al                  ; set to 0
        out     dx, al                  ; Write

;----- Interrupts are disables.  Restore saved interrupt vector.
        push    ds
        mov     al, [VectorNum]
        mov     ah, 25h
        mov     dx, [VectorOfs]
        mov     ds, [VectorSeg]
        int     21h
        pop     ds

;----- Return
        pop     bp
        ret
ENDP    _AsyncStop



;-----------------------------------------------------------------------------
; AsyncISR                                     Async Interrupt Service Routine
;-----------------------------------------------------------------------------
;       To be called only as an interrupt.
;-----------------------------------------------------------------------------
PROC    AsyncISR
        sti

        push    ax                      ; Save Registers
        push    bx
        push    cx
        push    ds
        push    dx

        mov     ax, @data               ; Address local data with ds
        mov     ds, ax

@@isr:  mov     dx, [IIR]               ; Check if data actually received
        in      al, dx
        and     al, 07h
        test    al, 1
        jnz     @@end
        cmp     al, 04h                 ; Receive interrupt
        je      @@receive
        cmp     al, 02h
        je      @@transmit              ; Transmit interrupt
        cmp     al, 0
        je      @@modem                 ; Modem Status interrupt

@@end:  cli

        mov     al, EOI                 ; Signal end of interrupt
        out     Ctrl8259_0, al

        ; Disable and re-enable interrupts so that there
        ; is an interrupt edge.

;       mov     dx,[IER]                ; Point to Interrupt Enable Register.
;       in      al,dx                   ; Read the current value.
;       push    ax                      ; Save it.
;       mov     al,0                    ; Disable the interrupts.
;       out     dx,al
;       pop     ax                      ; Restore original mask.
;       out     dx,al                   ; Re-enable interrupts.

        pop     dx                      ; Restore saved registers.
        pop     ds
        pop     cx
        pop     bx
        pop     ax

        iret

;----- Receive a byte
@@receive:
        mov     dx, [RDR]               ; Get Byte
        in      al, dx
        mov     bx, [RecHead]           ; Store Byte in buffer
        mov     [byte ptr bx], al
        inc     bx                      ; Update RecHead
        cmp     bx, offset RecBuffer + BufSize
        jb      @@10
        mov     bx, offset RecBuffer
@@10:
        cmp     bx, [RecTail]
        jne     @@20
        mov     bx, [RecHead]           ; Cancel Pointer advance on overflow
@@20:
        mov     [RecHead], bx           ; Store new pointer

        mov     dx, [LSR]               ; Read Line Status Register
        in      al, dx
        test    al, 01h                 ; Check for more Data Ready
        jnz     @@receive               ; Will mostly happen in FIFO mode
        jmp     short @@isr

;----- Modem Status Interrupt - for CTS handshake handling
@@modem:
        mov     dx, [MSR]               ; Modem Status Register
        in      al, dx
        test    al, 010h                ; Clear To Send went high?
        jz      @@isr                   ; Nope, some other line went somewhere

        mov     dx, [IER]               ; Point to Interrupt Enable Register.
        mov     al, 03h                 ; RD was on, TD now on, MS now off.
        out     dx, al
; fallthrough modem to transmit, CTS went high and THR must have been empty

;----- Transmit A byte
@@transmit:
        mov     cx, 1                   ; Assume no FIFO, xmit one char
        mov     al, [Fifo]
        or      al, al
        jz      @@xtop                  ; Not FIFO mode
        mov     cx, 16                  ; FIFO, can transmit max 16 chars

@@xtop:
        mov     bx, [TransTail]
        cmp     bx, [TransHead]
        jne     @@1

        mov     dx, [IER]               ; Buffer empty
        mov     al, 1
        out     dx, al                  ; Disable THR empty interrupt
        jmp     @@isr

@@1:
        mov     ax, [CTShand]
        or      ax, ax
        jz      @@xmit                  ; No handshaking, so ignore CTS

        mov     dx, [MSR]               ; Point to Modem Status Register.
        in      al, dx                  ; Read the current value.
        and     al, 010h                ; Check if CTS line high
        jnz     @@xmit                  ; Yeo, so can transmit

        mov     dx, [IER]               ; No CTS, ask for irq on Modem Status
        mov     al, 09h                 ; RD was on, TD now off, MS now on
        out     dx, al
        jmp     @@isr

@@xmit: mov     al, [byte ptr bx]       ; Get Byte
        inc     [TransTail]             ; Update buffer pointer
        cmp     [word ptr TransTail], offset TransBuffer + BufSize
        jb      @@2
        mov     [TransTail], offset TransBuffer
@@2:
        mov     dx, [THR]
        out     dx, al
        loopnz  @@xtop
        jmp     @@isr

ENDP    AsyncISR



;-----------------------------------------------------------------------------
;       AsyncIn                              Gets a byte from the input buffer
;-----------------------------------------------------------------------------
;       int     AsyncIn( void)
;-----------------------------------------------------------------------------
PROC    _AsyncIn
        push    bp
        mov     bp, sp

        xor     ax, ax                          ; Pre-Set result to 0
        mov     bx, [RecTail]
        cmp     bx, [RecHead]
        je      @@return
        mov     al, [byte ptr bx]
        inc     [RecTail]
        cmp     [word ptr RecTail], offset RecBuffer + BufSize
        jb      @@return
        mov     [RecTail], offset RecBuffer

@@return:
        pop     bp
        ret
ENDP    _AsyncIn



;-----------------------------------------------------------------------------
;       AsyncOut                                Output a byte
;-----------------------------------------------------------------------------
;       void    AsyncOut( int c)
;-----------------------------------------------------------------------------
PROC    _AsyncOut
        ARG     CharOut:word

        push    bp
        mov     bp, sp

        mov     ax, [CharOut]

        mov     bx, [TransHead]
        mov     cx, bx
        inc     cx                              ; Compute NEW buffer position
        cmp     cx, offset TransBuffer + BufSize
        jb      @@1
        mov     cx, offset TransBuffer
@@1:
        cmp     cx, [TransTail]                 ; Wait for space in buffer
        je      @@1

        mov     [byte ptr bx], al               ; Add byte to buffer
        mov     [TransHead], cx                 ; Update pointer

        mov     dx, [IER]                       ; Enable THR empty interrupt
        mov     al, 3
        out     dx, al

        pop     bp
        ret
ENDP    _AsyncOut



;-----------------------------------------------------------------------------
;       AsyncSet                                  Set communication paramaters
;-----------------------------------------------------------------------------
;       void    AsyncSet( word Baud, int Control)
;
;       Baud = 150, 300, 600, 1200, 2400, 4800, 9600, 19200, 28800, 38400, 57600
;       Control = The valure to place in the LCR
;-----------------------------------------------------------------------------
PROC    _AsyncSet
        ARG     Baud:word, Control:word

        push    bp
        mov     bp, sp

        mov     bx, [Baud]
        cmp     bx, 0
        je      @@abort

        mov     ax, 0C200h              ; Baud rate divisor = 115200 / Baud
        mov     dx, 0001h                       ; 115200 = 0001C200h
        div     bx
        mov     cx, ax

        cli
        mov     dx, [LCR]               ; Set Port Toggle to BRDL/BRDH regs
        mov     al, 0ffh
        out     dx, al

        mov     dx, [BRDL]              ; Set Baud Rate
        mov     al, cl
        out     dx, al
        mov     dx, [BRDH]
        mov     al, ch
        out     dx, al

        mov     dx, [LCR]                       ; Set LCR and Port Toggle
        mov     ax, [Control]
        and     al, 07Fh
        out     dx, al

        sti
@@abort:
        pop     bp
        ret
ENDP    _AsyncSet



;-----------------------------------------------------------------------------
;       AsyncInStat                      Returns the # of characters in buffer
;-----------------------------------------------------------------------------
;       int     AsyncInStat( void)
;-----------------------------------------------------------------------------
PROC    _AsyncInStat
        push    bp
        mov     bp, sp

        mov     ax,[RecHead]
        sub     ax, [RecTail]
        jge     @@10
        add     ax, BufSize
@@10:

        pop     bp
        ret
ENDP    _AsyncInStat



;-----------------------------------------------------------------------------
;       AsyncOutStat                     Returns the # of characters in buffer
;-----------------------------------------------------------------------------
;       int     AsyncOutStat( void)
;-----------------------------------------------------------------------------
PROC    _AsyncOutStat
        push    bp
        mov     bp, sp

        mov     ax,[TransHead]
        sub     ax, [TransTail]
        jge     @@10
        add     ax, BufSize
@@10:

        pop     bp
        ret
ENDP    _AsyncOutStat



;-----------------------------------------------------------------------------
;       AsyncHand                               Sets various handshaking lines
;-----------------------------------------------------------------------------
;       void    AsyncHand( int Hand)
;-----------------------------------------------------------------------------
PROC    _AsyncHand
        ARG     Hand:word
        push    bp
        mov     bp, sp

        mov     dx, [MCR]
        mov     ax, [Hand]
        or      al, 08h                         ; Keep interrupt enable ON
        out     dx, al

        pop     bp
        ret
ENDP    _AsyncHand



;-----------------------------------------------------------------------------
;       AsyncStat                                   Returns Async/Modem status
;-----------------------------------------------------------------------------
;       unsigned        AsyncStat (void)
;
;       MSR is returned in the high byte, LSR in the low byte
;-----------------------------------------------------------------------------
PROC    _AsyncStat
        push    bp
        mov     bp, sp

        mov     dx, [MSR]
        in      al, dx
        mov     cl, al
        mov     dx, [LSR]
        in      al, dx                  ; LSR in low byte
        mov     ah, cl                  ; MSR in high byte

        pop     bp
        ret
ENDP    _AsyncStat


;-----------------------------------------------------------------------------
;       AsyncCTS                                Enable/disable CTS handshaking
;-----------------------------------------------------------------------------
;       void    AsyncCTS( int enable)
;-----------------------------------------------------------------------------
PROC    _AsyncCTS
        ARG     enable:word
        push    bp
        mov     bp, sp

        mov     ax, [enable]
        mov     [CTShand], ax

        pop     bp
        ret
ENDP    _AsyncCTS



;-----------------------------------------------------------------------------
;       AsyncFifo                      Returns nonzero if 16550 (FIFO enabled)
;-----------------------------------------------------------------------------
;       unsigned        AsyncFifo (void)
;-----------------------------------------------------------------------------
PROC    _AsyncFifo
        push    bp
        mov     bp, sp

        xor     ah, ah
        mov     al, [Fifo]

        pop     bp
        ret
ENDP    _AsyncFifo


        END

; end of async.asm
