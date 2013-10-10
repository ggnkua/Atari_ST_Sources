/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.
								 
	module:	MIDIPLEX -- midiplexer routines

******************************************************************************/

overlay "main"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "externs.h"

/* asm entry points .........................................................*/

extern int MPoutput();
extern int MPinit(), MPon(), MPoff();
extern int saveA4();
extern int flopwait();

/* Hardware dependant equates */

#define DMACONTRL 0xFFFF8606L    /* .W control word address */
#define DMADATA   0xFFFF8604L    /* .W data word address */
#define MFPGPIO   0xFFFFA01L     /* .B general purpose I/O, bit #5 = DMA IRQ */

/* system variables */

#define _Flock   0x43EL          /* .W "floppy lock" */
#define Hz_200   0x4BAL          /* .L 200 hz counter */

/* MidiPlexer */

#define Uart0d   0x14            /* Uart 0 data */
#define Uart0c   0x15            /*     control */
#define Uart1d   0x10            /* Uart 1 data */
#define Uart1c   0x11            /*     control */
#define Uart2d   0x0C            /* Uart 2 data */
#define Uart2c   0x0D            /*     control */
#define MPcont   0x1C            /* control register */
#define MPstat   0x18            /* status reister   */

/* entire module is in assembly language */

asm {

/* output a byte (d0.b= byte, d1.w= port) ...................................*/

MPoutput:
		  movem.l	d0-d2/a0,-(a7)
        tst.w   d1              ; B?
        beq     OutB
        cmpi    #1,d1           ; C?
        beq     OutC
        bra     OutD            ; D

OutB:   move.l  MPtrBhead(a4),a0        ; buf pointer
        addq.l  #1,a0           ; advance and check for buf wrap
        cmpa.l  MPtrBlim(a4),a0
        bne     OB2
        move.l  MPtrBbuf(a4),a0

OB2:    cmpa.l  MPtrBtail(a4),a0        ; buffer overrun?
        beq     OB2             ; wait for a byte to finish

        move.l  a0,MPtrBhead(a4)
        move.b  d0,(a0)
        move    #Uart0c,d0      ; Uart 0 control addr
        move    #1,d1           ; re-enable transmit, no receive
        bra     TRena

OutC:   move.l  MPtrChead(a4),a0        ; buf pointer
        addq.l  #1,a0           ; advance and check for buf wrap
        cmpa.l  MPtrClim(a4),a0
        bne     OC2
        move.l  MPtrCbuf(a4),a0

OC2:    cmpa.l  MPtrCtail(a4),a0        ; buffer overrun?
        beq     OC2             ; wait for a byte to finish

        move.l  a0,MPtrChead(a4)
        move.b  d0,(a0)
        move    #Uart1c,d0      ; Uart 1 control addr
        move    #1,d1           ; re-enable transmit
        bra     TRena

OutD:   move.l  MPtrDhead(a4),a0        ; buf pointer
        addq.l  #1,a0           ; advance and check for buf wrap
        cmpa.l  MPtrDlim(a4),a0
        bne     OD2
        move.l  MPtrDbuf(a4),a0

OD2:    cmpa.l  MPtrDtail(a4),a0        ; buffer overrun?
        beq     OD2             ; wait for a byte to finish

        move.l  a0,MPtrDhead(a4)
        move.b  d0,(a0)
        move    #Uart2c,d0      ; Uart 2 control addr
        move    #1,d1           ; re-enable transmit

TRena:  move    DMAadr(a4),d2
        or      d2,d0     		     ; d0=uart addr
        move    #0,DMADATA         ; disable interupts
        move    #0x88,DMACONTRL
        move    d0,DMADATA
        move    #0x8A,DMACONTRL
        move    d1,DMADATA         ; command byte
        move    #0x88,DMACONTRL
        ori     #MPcont,d2
        move    d2,DMADATA
        move    #0x8A,DMACONTRL
        move    #0x0F,DMADATA       ; re-enable interupts

		  movem.l	(a7)+,d0-d2/a0
        rts

/* initialize MidiPlexer ....................................................*/
/* returns d0.w = DMA device # (0-7) or -1 for error */

MPinit:
		bsr		findMP
		tst.w		d0
      beq      ginit           ; good init
      moveq    #-1,d0
      rts                      ; no unit found, return error
        
ginit:  move    DMAadr(a4),d0
        ror.w   #5,d0           ; correct addr to 0-7
        rts
        
findMP:
		  st      _Flock
        move    #0,d3           ; start with device #0
dmb_1:  bsr     dmaread
        beq     dmb_2           ; "valid" device, try again

        move    #Uart0c,d1      ; first Uart
        move    #0x10,d2         ; command (clr flags)
        bsr     uinit           ; initialize uart
        move    DMADATA,d0      ; status read
        cmpi.b  #0x85,d0         ; uart there?
        bne     dmb_2           ; no

        move    d3,DMAadr(a4)       ; save address
        
        move    #Uart1c,d1      ; init second uart
        bsr     uinit
        move    #Uart2c,d1      ; and third
        bsr     uinit
        move    #0,d0
        bra     dmb_r
        
dmb_2:  add.b   #0x20,d3         ; next device
        bne     dmb_1
        move    #-1,d0      ; error flag
dmb_r:
        move    #0x80,DMACONTRL    ; "floppy" buss
        clr     _Flock
        rts
        
dmaread:
        move    #0x88,DMACONTRL    ;HD command ("addr") buss
        move    d3,d0           ;write device
        bsr     wcbyte
        bne     dmr_q           ;timeout error
        move    #0x8A,DMACONTRL    ;HD sub command ("data") buss
        moveq   #4,d2           ;write '0' 5 times
        clr     d0
dmr_lp: bsr     wcbyte
        bne     dmr_q           ;trap timeouts
        dbmi    d2,dmr_lp
        move    DMADATA,d0         ;read status
        rts
dmr_q:  moveq   #-1,d0
        rts

wcbyte: move.w  d0,DMADATA         ;write data
        move.l  #10,d1          ;wait .05 seconds
        add.l   Hz_200,d1

ww_1:   btst.b  #5,MFPGPIO         ;wait for iorq
        beq     ww_w
        cmp.l   Hz_200,d1
        bne     ww_1
        moveq   #-1,d1          ;timeout error
ww_w:   rts

; init uart     called with: d1=uart, d2=command byte

uinit:  move.w  d3,d0
        add.w   d1,d0
        move.w  #0x88,DMACONTRL    ;"addr" buss
        move.w  d0,DMADATA
        move.w  #0x8A,DMACONTRL
        clr.w   d0              ;reset 8251A
        move.w  d0,DMADATA
        nop
        move.w  d0,DMADATA
        nop
        move.w  d0,DMADATA
        nop
        move.w  #0x40,DMADATA
        nop
        nop
        move.w  #0x4E,DMADATA       ;mode byte (1 stop, 8 data, no par)
        nop
        nop
        move.w  d2,DMADATA         ;command byte
        nop
        nop
        rts

/* Turn MidiPlexer ON .......................................................*/

MPon:
		bsr		flopwait
      bsr		 uartON   ; turn the uarts ON
        
		  pea		 Int_Hand		  ; install interupt routine
        move    #7,-(sp)        ; MFP interupt #7
        move    #13,-(sp)       ; MFPint
        trap    #14
        addq.l  #8,sp
		  st		 plexer_on(a4)

        rts

uartON: st      _Flock
        move    #0x88,DMACONTRL    ; "addr" buss
        move    DMAadr(a4),d1
        addi    #Uart0c,d1      ; calculate Uart 0 control addr
        move    d1,DMADATA
        move    #0x8A,DMACONTRL    ; "data" buss
        move    #0x10,DMADATA       ; command (clr flgs, no rcv)

        andi    #0xE0,d1         ; clear out last addr
        addi    #MPcont,d1      ; leave addressed to Cont reg
        move    #0x88,DMACONTRL
        move    d1,DMADATA
        move    #0x8A,DMACONTRL
        move    #0x0F,DMADATA       ; enable interupts
        rts

/* Turn MidiPlexer off ......................................................*/

MPoff:
   move.l  MPtrBtail(a4),a0		; wait til all transmit buffers empty
   cmpa.l  MPtrBhead(a4),a0
	bne	  MPoff
   move.l  MPtrCtail(a4),a0
   cmpa.l  MPtrChead(a4),a0
	bne	  MPoff
   move.l  MPtrDtail(a4),a0
   cmpa.l  MPtrDhead(a4),a0
	bne	  MPoff

	move    #0,DMADATA         	; 0 to control reg (all ints off)
   move    #0x88,DMACONTRL    	; "addr" buss
   move    DMAadr(a4),DMADATA		; dummy addr
   move    #0x80,DMACONTRL    	; floppy addr
   clr.w   _Flock

   move    #7,-(sp)					; MFP interupt #7
   move    #26,-(sp)    		   ; jdisint
   trap    #14
   addq.l  #4,sp

	clr.b	  plexer_on(a4)
   rts

;===========================================================
; Interupt Routines
;===========================================================

Int_Hand:
        movem.l d0-d2/a0-a4,-(sp)
        move.l  #DMACONTRL,a0     ; DMA control addr
        move.l  #DMADATA,a1        ; DMA data addr

        move    #0,(a1)         ; disable interupts at MP

			lea	saveA4,a4
			move.l	(a4),a4		 ; restore Megamax's global data pointer
        move    DMAadr(a4),d1

ISloop: andi    #0xE0,d1         ; clear addr bits
        ori     #MPstat,d1      ; status reg addr
        move    #0x88,(a0)       ; read status reg
        move    d1,(a1)
        move    #0x8A,(a0)
        move    (a1),d2
        andi    #0x0F,d2         ; mask unused bits
        beq     IRet            ; all done

		  lsr.w   #1,d2           ; tran port B?
        btst    #0,d2
        beq     tstC
        bsr     ItranB

tstC:   lsr.w   #1,d2           ; tran port C?
        btst    #0,d2
        beq     tstD
        bsr     ItranC

tstD:   lsr.w   #1,d2           ; tran port D?
        btst    #0,d2
        beq     ISloop
        bsr     ItranD
        bra     ISloop

IRet:   andi    #0xE0,d1         ; set back to cont reg
        ori     #MPcont,d1
        move    #0x88,(a0)
        move    d1,(a1)
        move    #0x8A,(a0)
        
        bclr    #7,0x0FFFFFA11L  ; clear MFP in service bit

        move    #0x0F,(a1)       ; re-enable interupts at MP

        movem.l (sp)+,d0-d2/a0-a4
        rte

ItranB: andi    #0xE0,d1         ; clear dma addr pointer
        move.l  MPtrBtail(a4),a2        ; head pointer
        cmpa.l  MPtrBhead(a4),a2        ; empty buffer?  
        beq     IdisB           ; disable Transmitter

        addq.l  #1,a2
        cmpa.l  MPtrBlim(a4),a2       ; wrap?
        bne     nobwrp
        move.l  MPtrBbuf(a4),a2       ; wrap to begining

nobwrp: move.l  a2,MPtrBtail(a4)
        clr.w   d0
        move.b  (a2),d0         ; get byte

        move    #0x88,(a0)
        ori     #Uart0d,d1      ; uart 0 data
        move    d1,(a1)
        move    #0x8A,(a0)
        move    d0,(a1)         ; transmit byte
        rts

IdisB:  move    #0x88,(a0)
        ori     #Uart0c,d1      ; uart 0 control
        move    d1,(a1)
        move    #0x8A,(a0)
        move    #0x10,(a1)       ; command (clr flgs, no rcv)
        rts

ItranC: andi    #0xE0,d1         ; clear dma addr pointer
        move.l  MPtrCtail(a4),a2        ; head pointer
        cmpa.l  MPtrChead(a4),a2        ; empty buffer?  
        beq     IdisC           ; disable Transmitter

        addq.l  #1,a2
        cmpa.l  MPtrClim(a4),a2       ; wrap?
        bne     nocwrp
        move.l  MPtrCbuf(a4),a2       ; wrap to begining

nocwrp: move.l  a2,MPtrCtail(a4)
        clr.w   d0
        move.b  (a2),d0         ; get byte

        move    #0x88,(a0)
        ori     #Uart1d,d1      ; uart 1 data
        move    d1,(a1)
        move    #0x8A,(a0)
        move    d0,(a1)         ; transmit byte
        rts

IdisC:  move    #0x88,(a0)
        ori     #Uart1c,d1      ; uart 1 control
        move    d1,(a1)
        move    #0x8A,(a0)
        move    #0x10,(a1)       ; command (clr flgs)
        rts

ItranD: andi    #0xE0,d1         ; clear dma addr pointer
        move.l  MPtrDtail(a4),a2        ; head pointer
        cmpa.l  MPtrDhead(a4),a2        ; empty buffer?  
        beq     IdisD           ; disable Transmitter

        addq.l  #1,a2
        cmpa.l  MPtrDlim(a4),a2       ; wrap?
        bne     nodwrp
        move.l  MPtrDbuf(a4),a2       ; wrap to begining

nodwrp: move.l  a2,MPtrDtail(a4)
        clr.w   d0
        move.b  (a2),d0         ; get byte

        move    #0x88,(a0)
        ori     #Uart2d,d1      ; uart 2 data
        move    d1,(a1)
        move    #0x8A,(a0)
        move    d0,(a1)         ; transmit byte
        rts

IdisD:  move    #0x88,(a0)
        ori     #Uart2c,d1      ; uart 2 control
        move    d1,(a1)
        move    #0x8A,(a0)
        move    #0x10,(a1)       ; command (clr flgs)
        rts

}	/* end asm */

flopwait()
{
	do
		;
	while (Giaccess(dummy,14)&6 != 6);
}	/* end flopwait() */

/* EOF: Midiplex */
