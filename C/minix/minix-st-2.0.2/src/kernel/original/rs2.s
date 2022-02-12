#include <minix/config.h>
#if (MACHINE == ATARI)
#if !C_RS232_INT_HANDLERS	/* otherwise don't use anything in this file */
/*==========================================================================*
 * rs232 interrupt handlers for ATARI.                                     *
 * This is a direct translation of the C interrupt handlers in rs232.c      *
 * The code is a little bit rearanged and improved in speed. No attempts    *
 * were made to catch new incoming data while the handlers are in progress. *
 *==========================================================================*/

/* These constants are defined in staddr.h */
#define	AD_SOUND	0x00FF8800	/* YM-2149 */
#define	AD_MFP		0x00FFFA00	/* 68901 */

/* These constants are defined in stsound.h */
YM_IOA		= 14		/* register A of YM */
PA_SRTS		= 0x08
PA_SRTSB	= 3		/* PA_SRTS-bit */
PA_SDTR		= 0x10
PA_SDTRB	= 4		/* PA_SDTR-bit */

/* These constants are defined in stmfp.h */
R_ENA		= 0x01
IO_SDCD		= 0x02
IO_SCTS		= 0x04
T_UE		= 0x40
T_EMPTY		= 0x80

/* offsets into the MFP struct addresses the MFP registers */
MF_GPIP		=  1
MF_AER		=  3
MF_RSR		= 43
MF_TSR		= 45
MF_UDR		= 47

/* These constant is defines in tty.h */
EVENT_THRESHOLD	= 64

/* These constants are defined in rs232.c */
MS_CTS		=  0x04

ODEVREADY	= MS_CTS	/* external device hardware ready (CTS) */
ODEVREADYB	= 2		/* ODEVREADY-bit */
ODONE		= 1		/* output completed (< output enable bits) */
OQUEUED		= 0x20		/* output buffer not empty */
ORAW		= 2		/* raw mode for xoff disable (< enab. bits) */
ORAWB		= 1		/* ORAW-bit */
OSWREADY	= 0x40		/* external device software ready (no xoff) */
OSWREADYB	= 6		/* OSWREADY-bit */
OWAKEUP		= 4		/* tty_wakeup() pending (asm code only) */

/* Offsets into struct rs232_s. They must match rs232.c */
IBUFEND		=  8
IHIGHWATER	= 12
IPTR		= 16
OSTATE		= 20
OXOFF		= 21
OBUFEND		= 22
OPTR		= 26
PAD		= 31
FRAMING_ERRORS	= 32
OVERRUN_ERRORS	= 34
PARITY_ERRORS	= 36
BREAK_INTERRUPTS= 38

/* exported function */
	.define _siaint

	.sect .text;.sect .rom;.sect .data;.sect .bss

/* extern references */
	.extern _rs_lines
	.extern _tty_events
	.extern _tty_wakeup

	.sect .text
/*==========================================================================*
 * siaint schedules the 5 incoming rs232 interrupts.                        *
 * incoming data must be served as fast as possible, so the code would be a *
 * little bit rearanged.                                                    *
 *==========================================================================*/
_siaint:
	link	a6,#-8
	movem.l	d7/a5,-(sp)
	lea	_rs_lines,a5	/* get &rs_lines[0] */
	move.w	sr,d7		/* store old sr for later restore */
	move.w	#0x2700,sr	/* lock the cpu */
	tst.b	9(a6)           
	bne	IB_1		/* interrupt type != 0 ? yes */
	bsr	_in_int
IB_5:
	move.w	d7,sr		/* restore sr to old value */
	movem.l	(sp)+,d7/a5
	unlk	a6
	rts
IB_1:
	cmp.b	#1,9(a6)
	bne	IB_2		/* interrupt type != 1 ? yes */
	bsr	_line_int
	bra	IB_5
IB_2:
	cmp.b	#2,9(a6)
	bne	IB_3		/* interrupt type != 2 ? yes */
	bsr	out_int
	bra	IB_5
IB_3:
	cmp.b	#3,9(a6)
	bne	IB_4		/* interrupt type != 3 ? yes */
	clr.w	d2
	move.l	#AD_MFP, a1
	move.b	MF_TSR(a1),d2	/* get MFP->mf_tsr */
	move.w	d2,d1
	and.w	#0xff3e,d1	/* ~(T_ENA | T_UE | T_EMPTY) */
	beq	IB_5		/* No error found */
	move.w	d2,-(sp)	/* push argument */
	pea	_tr_err		/* push controlstring */
	jsr	_printk
	add.l	#6,sp		/* clear sp */
	bra	IB_5
IB_4:
	bsr	_modem_int
	bra	IB_5

/*==========================================================================*
 * in_int reads the data which just arrived and does a little processing.   *
 * assumes that *rs is already in a5.                                       *
 *==========================================================================*/
_in_int:
	move.b	AD_MFP+MF_UDR,d2/* MFP->mf_udr */
	move.l	IPTR(a5),a0	/* rs->iptr */
	move.b	d2,(a0)		/* *rs->iptr = MFP->mf_udr */
	btst	#ORAWB,OSTATE(a5)
	bne	IC_4		/* rs->ostate & ORAW ? yes */
	cmp.b	OXOFF(a5),d2
	bne	IC_6		/* *rs->iptr == rs->oxoff ? no */
	bclr	#OSWREADYB,OSTATE(a5)	/* rs->ostate &= ~OSWREADY */
	bra	IC_4
IC_6:
	bset	#OSWREADYB,OSTATE(a5)	/* rs->ostate & OSWREADY ? */
	bne	IC_4		/* !(rs->ostate & OSWREADY) ? no */
				/* rs->ostate |= OSWREADY done by bset ! */
	or.b	#OSWREADY,OSTATE(a5)
	move.b	AD_MFP+MF_TSR,d1/* MFP->mf_tsr */
	and.b	#T_EMPTY+T_UE,d1/* MFP->mf_tsr & (T_EMPTY | T_UE) */
	beq	IC_4		/* MFP->mf_tsr & (T_EMPTY | T_UE) ? no */
	bsr	out_int
IC_4:
	cmp.l	IBUFEND(a5),a0
	bcc	IC_F		/* rs->iptr < rs->ibufend ? no */
	add.w	#1,_tty_events	/* ++tty_events */
	add.l	#1,a0		/* ++rs->iptr */
	move.l	a0,IPTR(a5)	/* store rs->iptr */
	cmp.l	IHIGHWATER(a5),a0
	bne	IC_F		/* rs->iptr == rs->ihighwater ? no */
	move.l	#AD_SOUND,a1
	move.b	#YM_IOA,(a1)	/* SOUND->sd_selr = YM_IOA */
	move.b	(a1),d2		/* SOUND->sd_rdat */
	bclr	#PA_SDTRB,d2	/* SOUND->sd_rdat & ~PA_SDTR */
	bset	#PA_SRTSB,d2	/* SOUND->sd_rdat & ~PA_SDTR | PA_SRTS */
	move.b	d2,2(a1)	/* SOUND->sd_wdat = SOUND->sd_rdat & ~PA_SDTR | PA_SRTS */
	clr.b	2(a5)		/* rs->idevready = FLASE */
IC_F:
	rts

/*==========================================================================*
 * line_int checks for and records errors.                                  *
 * assumes that *rs is already in a5.                                       *
 *==========================================================================*/
_line_int:
	move.l	#AD_MFP,a1
	move.b	MF_RSR(a1),d2	/* MFP->mf_rsr */
	move.b	d2,30(a5)	/* rs->lstatus = MFP->mf_rsr */
	and.b	#R_ENA,MF_RSR(a1)	/* MFP->mf_rsr &= R_ENA */
	move.b	MF_UDR(a1),PAD(a5)	/* rs->pad = MFP->mf_udr */
	btst	#4,d2
	beq	ID_3		/* rs->lstatus & LS_FRAMING_ERR ? no */
	add.w	#1,FRAMING_ERRORS(a5)	/* ++rs->framing_errors */
ID_3:
	btst	#6,d2
	beq	ID_6		/* rs->lstatus & LS_OVERRUN_ERR ? no */
	add.w	#1,OVERRUN_ERRORS(a5)	/* ++rs->overrun_errors */
ID_6:
	btst	#5,d2
	beq	ID_9		/* rs->lstatus & LS_PARITY_ERR ? no */
	add.w	#1,PARITY_ERRORS(a5)	/* ++rs->parity_errors */
ID_9:
	btst	#3,d2
	beq	ID_C		/* rs->lstatus & LS_BREAK_INTERRUPT ? no */
	add.w	#1,BREAK_INTERRUPTS(a5)	/* ++rs->break_interrupts */
ID_C:
	rts

/*==========================================================================*
 * modem_int looks for a possible new device status.                        *
 * assumes that *rs is already in a5.                                       *
 *==========================================================================*/
_modem_int:
	move.l	#AD_MFP, a1
	move.b	MF_GPIP(a1),d2
	and.b	#IO_SCTS+IO_SDCD,d2	/* MFP->mf_gpip & (IO_SCTS|IO_SDCD) */
	move.b	MF_AER(a1),d1
	or.b	#IO_SCTS+IO_SDCD,d1	/* MFP->mf_aer | (IO_SCTS|IO_SDCD) */
	eor.b	d1,d2		/* (MFP->mf_aer | (IO_SCTS|IO_SDCD)) ^
				   (MFP->mf_gpip & (IO_SCTS|IO_SDCD)) */
	move.b	d2,MF_AER(a1)	/* MFP->mf_aer = (MFP->mf_aer|(IO_SCTS|IO_SDCD))
				   ^ (MFP->mf_gpip & (IO_SCTS|IO_SDCD)) */
#if (NO_HANDSHAKE == 0)
	move.b	MF_GPIP(a1),d2	/* MFP->mf_gpip */
	not.b	d2		/* ~MFP->mf_gpip */
	and.b	#MS_CTS,d2	/* ~MFP->mf_gpip & MS_CTS */
	bne	IE_3		/* ! ~MFP->mf_gpip & MS_CTS */
	bclr	#ODEVREADYB,OSTATE(a5)	/* rs->ostate &= ~ODEVREADY */
	bra	IE_4
IE_3:
#endif
	bset	#ODEVREADYB,OSTATE(a5)	/* rs->ostate & ODEVREADY ? */
	bne	IE_4		/* !(rs->ostate & ODEVREADY) ? no */
				/* rs->ostate |= ODEVREADY done by bset ! */
	or.b	#ODEVREADY,OSTATE(a5)
	move.b	MF_TSR(a1),d1	/* MFP->mf_tsr */
	and.b	#T_EMPTY+T_UE,d1/* MFP->mf_tsr & (T_EMPTY | T_UE) */
	beq	IE_4		/* MFP->mf_tsr & (T_EMPTY | T_UE) ? no */
	bsr	out_int
IE_4:
	rts

/*==========================================================================*
 * out_int outputs data if there is one and everything is ready.            *
 * assumes that *rs is already in a5.                                       *
 *==========================================================================*/
out_int:
	move.b	OSTATE(a5),d2	/* rs->ostate */
	cmp.b	#ODEVREADY+OQUEUED+OSWREADY,d2
	bcs	IF_3		/* rs->ostate >= (ODEVREADY|OQUEUED|OSWREADY) ? no */
	move.l	OPTR(a5),a1	/* rs->optr */
	move.b	(a1)+,AD_MFP+MF_UDR	/* MFP->mf_udr = *rs->optr */
	move.l	a1,OPTR(a5)	/* store ++rs->optr */
	cmp.l	OBUFEND(a5),a1
	bcs	IF_3		/* ++rs->optr >= rs->obufend ? no */
	add.w	#EVENT_THRESHOLD,_tty_events	/* tty_events += EVENT_THRESHOLD */
	eor.b	#ODONE+OQUEUED,OSTATE(a5)	/* rs->ostate ^= (ODONE | OQUEUED) */
	/* KUB noted that this is not save, for unknown reasons.
	 * So i also avoid to enclose jsr _tty_wakeup with
	 * move.w 0x2300,sr ; move.w 0x2700,sr
	 */
	jsr	_tty_wakeup
IF_3:
	rts

	.sect .data
_tr_err:
	.asciz	'sia: transmit error: status=%x\r\n'
#endif
#endif

