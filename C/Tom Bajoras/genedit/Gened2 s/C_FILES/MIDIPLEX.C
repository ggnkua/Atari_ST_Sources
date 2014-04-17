/******************************************************************************

			                          GenEdit
                                      by
                                  Tom Bajoras

                       Copyright 1990/1991 Tom Bajoras
								 
	midiplexer routines

	MPoutput, MPinit, MPon, MPoff
	TRena

******************************************************************************/

/* has to be in main overlay */
overlay "main"

/* include header files .....................................................*/

#include "defines.h"			/* program-specific */
#include <gemdefs.h>			/* AES                  */
#include <obdefs.h>			/* more AES  */
#include <osbind.h>			/* GEMDOS, BIOS, XBIOS  */
#include "externs.h"

/* asm entry points .........................................................*/

extern MPoutput(), MPinit(), MPon(), MPoff(),TRena();			/* exported */
extern saveA4(),thru_nts_off(),thru_recv(),track_thru();		/* imported */

/* local globals ............................................................*/

int DMAadr;
int MPflag=0;

/* defines ..................................................................*/

	/* fast access to DMA registers */
#define D2TODATA	dc.w 0x21C2, 0x8604					/* move.l d2,0x8604 */
#define D1TODATA	dc.w 0x21C1, 0x8604					/* move.l d1,0x8604 */
#define D0TODATA	dc.w 0x21C0, 0x8604					/* move.l d0,0x8604 */
#define DATATOD0	dc.w 0x3038, 0x8604					/* move.w 0x8604,d0 */
#define DATATOD2	dc.w 0x3438, 0x8604					/* move.w 0x8604,d2 */
#define TO_DATA(a,b) dc.w 0x21FC, a , b , 0x8604	/* move.l #ab,0x8604 */
#define TO_CTRL(a) dc.w 0x31FC, a ,0x8606				/* move.w #a,0x8606 */
#define MFPGPIO  0xFFFFFA01L     /* .B general purpose I/O, bit #5 = DMA IRQ */
#define FLOCK    0x43EL          /* .W "floppy lock" */
#define UART0D   0x14            /* Uart 0 data */
#define UART0C   0x15            /*     control */
#define UART1D   0x10            /* Uart 1 data */
#define UART1C   0x11            /*     control */
#define UART2D   0x0C            /* Uart 2 data */
#define UART2C   0x0D            /*     control */
#define MPCTRL   0x1C            /* control register */
#define MPSTAT   0x18            /* status register   */

/* wait for floppy to deselect ..............................................*/

flopwait()
{
	do
		;
	while ( *(int*)(FLOCK) ) ;
	do
		;
	while ( (Giaccess(dummy,14)&6) != 6 ) ;
}	/* end flopwait() */

/* rest of module is in assembly language ...................................*/

asm {

/* output a byte (d0.b= byte, d1.b= port 1/2/3) .............................*/

MPoutput:
	movem.l d0-d1/a0,-(a7)

	cmpi.b  #3,d1
	beq     OutD
	cmpi.b  #2,d1
	beq     OutC

OutB:
	move.b  MP_bhead+3(a4),d1
	subq.b  #1,d1
OB2:
	cmp.b   MP_btail+3(a4),d1
	beq     OB2
	move.l  MP_bhead(a4),a0
	addq.b  #1,MP_bhead+3(a4)
	move.b  d0,(a0)
	moveq   #0,d0
	move.w  SR,-(a7)
	ori.w   #0x700,SR
	bsr     TRena
	move.w  (a7)+,SR
	movem.l (a7)+,d0-d1/a0
	rts

OutC:
	move.b  MP_chead+3(a4),d1
	subq.b  #1,d1
OC2:
	cmp.b   MP_ctail+3(a4),d1
	beq     OC2
	move.l  MP_chead(a4),a0
	addq.b  #1,MP_chead+3(a4)
	move.b  d0,(a0)
	moveq   #1,d0
	move.w  SR,-(a7)
	ori.w   #0x700,SR
	bsr     TRena
	move.w  (a7)+,SR
	movem.l (a7)+,d0-d1/a0
	rts

OutD:
	move.b  MP_dhead+3(a4),d1
	subq.b  #1,d1
OD2:
	cmp.b   MP_dtail+3(a4),d1
	beq     OD2
	move.l  MP_dhead(a4),a0
	addq.b  #1,MP_dhead+3(a4)
	move.b  d0,(a0)
	moveq   #2,d0
	move.w  SR,-(a7)
	ori.w   #0x700,SR
	bsr     TRena
	move.w  (a7)+,SR
	movem.l (a7)+,d0-d1/a0
	rts

/* enable transmit interrupt:  d0 0=B, 1=C, 2=D .............................*/
/* uses d0,d1 */
TRena:
	lsl.b   #2,d0                ; 0=B, 4=C, 8=D
	moveq   #UART0C,d1
	sub.w   d0,d1
	or.w    DMAadr(a4),d1
	TO_CTRL(0x88)
	swap    d1
	move.w  #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	tst.b   d0
	bne     TRenaC
	TO_DATA(0x15,0x8A)
	rts
TRenaC:
	TO_DATA(0x11,0x8A)
	rts

/* initialize MidiPlexer ....................................................*/
/* returns -1= midiplexer found, 0= not found */

MPinit:
	bsr		findMP
	tst.w		d0
	beq      ginit
	clr.w		d0					; not found
	rts
ginit:
	moveq		#-1,d0			; found
	rts

findMP:
	st			FLOCK
	move.w	#0,d3           ; start with device #0
dmb_1:
	bsr		dmaread
	beq		dmb_2           ; "valid" device, try again

	move.w	#UART0C,d1      ; first Uart
	moveq		#0x14,d2
	bsr		uinit           ; initialize uart
	DATATOD0
	cmpi.b	#0x85,d0         ; uart there?
	bne		dmb_2           ; no

	move.w	d3,DMAadr(a4)       ; save address
		
	move.w	#UART1C,d1      ; init second uart
	moveq		#0x10,d2
	bsr		uinit
	move.w	#UART2C,d1      ; and third
	moveq		#0x10,d2
	bsr		uinit
	move.w	#0,d0
	bra		dmb_r
		
dmb_2:
	add.b		#0x20,d3         ; next device
	bne		dmb_1
	move.w	#-1,d0      ; error flag
dmb_r:
	TO_CTRL(0x80)
	clr.w   FLOCK
	rts
		
dmaread:
	TO_CTRL(0x88)
	move.w	d3,d0           ;write device
	swap		d0
	move.w	#0x88,d0
	bsr		wcbyte
	bne		dmr_q           ;timeout error
	TO_CTRL(0x8A)
	move.l	#0x8A,d0
	moveq		#4,d2           ;write '0' 5 times
dmr_lp:
	bsr		wcbyte
	bne		dmr_q           ;trap timeouts
	dbmi		d2,dmr_lp
	DATATOD0						; read but ignore result
	clr.w		d0
	rts
dmr_q:
	moveq		#-1,d0
	rts

wcbyte:
	D0TODATA
	moveq		#10,d1          ;wait .05 seconds
	add.l		HZ200,d1

ww_1:
	btst.b	#5,MFPGPIO         ;wait for iorq
	beq		ww_w
	cmp.l		HZ200,d1
	bne		ww_1
	moveq		#-1,d1          ;timeout error
ww_w:
	rts

; init uart     called with: d1=uart, d2.l=cmd, d3.w= DMAadr

uinit:
	move.w	d3,d0
	or.w		d1,d0
	TO_CTRL(0x88)
	swap		d0
	move.w	#0x88,d0
	D0TODATA
	TO_CTRL(0x8A)
	move.l	#0x8A,d0
	D0TODATA
	nop	nop	nop
	D0TODATA
	nop	nop	nop
	D0TODATA
	nop	nop	nop
	TO_DATA(0x40,0x8A)
	nop	nop	nop
	nop	nop	nop
	TO_DATA(0x4E,0x8A)
	nop	nop	nop
	nop	nop	nop
	swap  d2
	move.w #0x8A,d2
	D2TODATA
	nop	nop	nop
	nop	nop	nop
	rts

/* Turn MidiPlexer ON .......................................................*/
/* returns previous state (1 on, 0 off) */

MPon:
	tst.w		MPflag(a4)
	bne		on_already

	bsr	  flopwait
	st      FLOCK

	TO_CTRL(0x88)
	move.w  DMAadr(a4),d1
	ori.w   #MPCTRL,d1         ; leave addressed to Cont reg
	swap    d1
	move.w  #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	TO_DATA(0x00,0x8A)

	pea     Int_Hand		   ; install interupt routine
	move.w  #7,-(sp)        ; MFP interupt #7
	move.w  #13,-(sp)       ; MFPint
	trap    #14
	addq.w  #8,sp

	move.w  DMAadr(a4),d3
	move.w  #UART0C,d1
	moveq   #0x14,d2
	bsr     uinit
	move.w  #UART1C,d1
	moveq   #0x10,d2
	bsr     uinit
	move.w  #UART2C,d1
	moveq   #0x10,d2
	bsr     uinit

	TO_CTRL(0x88)
	move.w  DMAadr(a4),d1
	ori.w   #MPCTRL,d1
	swap    d1
	move.w  #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	TO_DATA(0x0F,0x8A)

on_already:
	move.w	MPflag(a4),d0
	move.w	#1,MPflag(a4)
	rts

/* Turn MidiPlexer off ......................................................*/
/* returns previous state (1 on, 0 off) */

MPoff:
	tst.w		MPflag(a4)
	beq		off_already

	tst.b   midithru(a4)			; if thru to or from midiplexer, turn off notes
	beq	  _MPoff
	move.b  thru_tport(a4),d0
	or.b    thru_rport(a4),d0
	beq     _MPoff
	jsr     thru_nts_off
_MPoff:
	move.l  MP_btail(a4),a0		; wait til all transmit buffers empty
	cmpa.l  MP_bhead(a4),a0
	bne	  _MPoff
	move.l  MP_ctail(a4),a0
	cmpa.l  MP_chead(a4),a0
	bne	  _MPoff
	move.l  MP_dtail(a4),a0
	cmpa.l  MP_dhead(a4),a0
	bne	  _MPoff

	move.w	SR,-(a7)
	ori.w		#0x700,SR
	TO_CTRL(0x88)
	move.w	DMAadr(a4),d0
	ori.w		#MPCTRL,d0
	swap     d0
	move.w   #0x88,d0
	D0TODATA
	TO_CTRL(0x8A)
	TO_DATA(0x00,0x8A)
	move.w	(a7)+,SR

	move.w  #7,-(sp)					; MFP interupt #7
	move.w  #26,-(sp)    		   ; jdisint
	trap    #14
	addq.w  #4,sp

	TO_CTRL(0x88)						; Joe-recommended weirdness
	move.w	DMAadr(a4),d0
	swap     d0
	move.w   #0x88,d0
	D0TODATA

	TO_CTRL(0x80)						; DMA back to floppy
	clr.w   FLOCK

off_already:
	move.w	MPflag(a4),d0
	move.w	#0,MPflag(a4)
	rts

/* DMA interrupt handler ....................................................*/

Int_Hand:
	movem.l d0-d2/a0-a4,-(a7)

	lea     saveA4,a4			; restore Megamax's global data pointer
	move.l  (a4),a4
	move.w	DMAadr(a4),d2	; midiplexer DMA device number

	move.w	d2,d1				; disable interrupts on midiplexer (why?)
	ori.w		#MPCTRL,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	TO_DATA(0x00,0x8A)

	move.w	d2,d1				; get interrupt bits
	ori.w		#MPSTAT,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	DATATOD0

	btst		#0,d0					; check for receive interrupt
	beq		tstB
	move.w	d2,d1
	ori.w		#UART0D,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	DATATOD0
	move.b	midithru(a4),d1	; thru from input B?
	and.b		thru_rport(a4),d1
	beq		skip_thru
	jsr		thru_recv
skip_thru:
	move.b	midi_rport(a4),d1	; receive from input B?
	beq		Iret
	movea.l	recv_tail(a4),a2	; put byte into receive buffer
	move.b	d0,(a2)+
	cmpa.l	recv_end(a4),a2
	blt		no_wrap
	movea.l	recv_start(a4),a2
no_wrap:
	move.l	a2,recv_tail(a4)
	cmpa.l	recv_head(a4),a2
	seq		d0
	or.b		d0,midiovfl(a4)
	bra		Iret

tstB:
	btst    #1,d0					; check for transmit B interrupt
	beq		tstC
	cmpi.b  #1,thru_tport(a4)
	bne     no_thruB
	move.b  thru_tail+3(a4),d0
	cmp.b   thru_head+3(a4),d0
	beq     no_thruB
	move.l  thru_head(a4),a2
	addq.b  #1,thru_head+3(a4)
	clr.w   d0
	move.b  (a2),d0
	jsr		track_thru
	bra     ItranB
no_thruB:
	move.b  MP_btail+3(a4),d0
	cmp.b   MP_bhead+3(a4),d0
	beq     IdisB
	move.l  MP_btail(a4),a2
	addq.b  #1,MP_btail+3(a4)
	clr.w   d0
	move.b  (a2),d0
ItranB:
	move.w	d2,d1
	ori.w		#UART0D,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	swap     d0
	move.w   #0x8A,d0
	D0TODATA
	bra		Iret
IdisB:
	move.w	d2,d1
	ori.w		#UART0C,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	TO_DATA(0x14,0x8A)
	bra		Iret

tstC:
	btst    #2,d0							; check for transmit C interrupt
	beq		tstD
	cmpi.b  #2,thru_tport(a4)
	bne     no_thruC
	move.b  thru_tail+3(a4),d0
	cmp.b   thru_head+3(a4),d0
	beq     no_thruC
	move.l  thru_head(a4),a2
	addq.b  #1,thru_head+3(a4)
	clr.w   d0
	move.b  (a2),d0
	jsr		track_thru
	bra     ItranC
no_thruC:
	move.b  MP_ctail+3(a4),d0
	cmp.b   MP_chead+3(a4),d0
	beq     IdisC
	move.l  MP_ctail(a4),a2
	addq.b  #1,MP_ctail+3(a4)
	clr.w   d0
	move.b  (a2),d0
ItranC:
	move.w	d2,d1
	ori.w		#UART1D,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	swap     d0
	move.w   #0x8A,d0
	D0TODATA
	bra		Iret
IdisC:
	move.w	d2,d1
	ori.w		#UART1C,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	TO_DATA(0x10,0x8A)
	bra		Iret

tstD:
	btst		#3,d0							; check for transmit D interrupt
	beq		Iret
	cmpi.b  #3,thru_tport(a4)
	bne     no_thruD
	move.b  thru_tail+3(a4),d0
	cmp.b   thru_head+3(a4),d0
	beq     no_thruD
	move.l  thru_head(a4),a2
	addq.b  #1,thru_head+3(a4)
	clr.w   d0
	move.b  (a2),d0
	jsr		track_thru
	bra     ItranD
no_thruD:
	move.b  MP_dtail+3(a4),d0
	cmp.b   MP_dhead+3(a4),d0
	beq     IdisD
	move.l  MP_dtail(a4),a2
	addq.b  #1,MP_dtail+3(a4)
	clr.w   d0
	move.b  (a2),d0         ; get byte
ItranD:
	move.w	d2,d1
	ori.w		#UART2D,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	swap     d0
	move.w   #0x8A,d0
	D0TODATA
	bra		Iret
IdisD:
	move.w	d2,d1
	ori.w		#UART2C,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	TO_DATA(0x10,0x8A)

Iret:
	move.w	d2,d1				; re-enable interrupts on midiplexer (why?)
	ori.w		#MPCTRL,d1
	TO_CTRL(0x88)
	swap     d1
	move.w   #0x88,d1
	D1TODATA
	TO_CTRL(0x8A)
	TO_DATA(0x0F,0x8A)
	bclr    #7,0xFFFFFA11L  ; clear MFP in service bit
	movem.l (sp)+,d0-d2/a0-a4
	rte

}	/* end asm */

/* EOF */
