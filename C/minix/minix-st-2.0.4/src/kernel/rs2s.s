#include <minix/config.h>
#if (MACHINE == ATARI)
#if !C_RS232_INT_HANDLERS	/* otherwise don't use anything in this file */
/*==========================================================================*
 * rs232 interrupt handlers for ATARI.                                      *
 * This is a direct translation of the C interrupt handlers in rs232.c      *
 * The code is a little bit rearanged and improved in speed. No attempts    *
 * were made to catch new incoming data while the handlers are in progress. *
 *									    *
 * Adapted for Minix-ST 2.0.2 by VS 2005/08/20				    *
 *==========================================================================*/

#define	NO_HANDSHAKE	1

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

/* These constants are defined in rs232.c */
#if (ENABLE_NETWORKING == 1)
RS_IBUFSIZE     = 8192		/* RS232 input buffer size */
RS_OBUFSIZE     = 8192		/* RS232 output buffer size */
#else
RS_IBUFSIZE	= 1024		/* RS232 input buffer size */
RS_OBUFSIZE     = 1024		/* RS232 output buffer size */
#endif /* ENABLE_NETWORKING == 1 */
RS_OLOWWATER	= 1*RS_OBUFSIZE/4
RS_IHIGHWATER	= 3*RS_IBUFSIZE/4

MS_CTS		= 0x10

ODONE		= 1		/* output completed (< output enable bits) */
ORAW		= 2		/* raw mode for xoff disable (< enab. bits) */
ORAWB		= 1		/* ORAW-bit */
OWAKEUP		= 4		/* tty_wakeup() pending (asm code only) */
ODEVREADY	= MS_CTS	/* external device hardware ready (CTS) */
ODEVREADYB	= 4		/* ODEVREADY-bit */
OQUEUED		= 0x20		/* output buffer not empty */
OSWREADY	= 0x40		/* external device software ready (no xoff) */
OSWREADYB	= 6		/* OSWREADY-bit */


/* Offsets into struct rs232_s. They must match rs232.c */
icount		=  4
ihead		=  6
itail		= 10
idevready	= 14
cts		= 15
ostate		= 16
oxoff		= 17
inhibited	= 18
drain		= 19
ocount		= 20
ohead		= 22
otail		= 26
lstatus		= 30
pad		= 31
framing_errors	= 32
overrun_errors	= 34
parity_errors	= 36
break_interrupts= 38
print_count	= 40
rs232_s_sz	= 42

PRINT_LEVEL	= 20

/* exported function */
	.define _siaint
	.define	_out_int		/* C entry point */

	.sect .text;.sect .rom;.sect .data;.sect .bss

/* extern references */
	.extern _rs_lines
	.extern	_tty_timeout
	.extern	_printf

	.sect .text
/*==========================================================================*
 * siaint schedules the 5 incoming rs232 interrupts.                        *
 * incoming data must be served as fast as possible, so the code would be a *
 * little bit rearanged.                                                    *
 *==========================================================================*/
_siaint:
	movem.l	d7/a5,-(sp)
	lea	_rs_lines,a5		/* get &rs_lines[0] */
	move.w	sr,d7			/* store old sr for later restore */
	move.w	#0x2700,sr		/* lock the cpu*/
	tst.b	13(sp)			/* type. Offset = d7+a5+rts+1	*/
	bne	IB_1			/* interrupt type != 0 ? yes */
	bsr	in_int
IB_5:
	move.w	d7,sr			/* restore sr to old value */
	movem.l	(sp)+,d7/a5
	rts
IB_1:
	cmp.b	#1,13(sp)
	bne	IB_2			/* interrupt type != 1 ? yes */
	bsr	line_int
	bra	IB_5
IB_2:
	cmp.b	#2,13(sp)
	bne	IB_3			/* interrupt type != 2 ? yes */
	bsr	out_int
	bra	IB_5
IB_3:
	cmp.b	#3,13(sp)
	bne	IB_4			/* interrupt type != 3 ? yes */
	clr.w	d0
	move.l	#AD_MFP, a1
	move.b	MF_TSR(a1),d0		/* get MFP->mf_tsr */
	move.w	d0,d1
	and.w	#0xff3e,d1		/* ~(T_ENA | T_UE | T_EMPTY) */
	beq	IB_5			/* No error found */
	move.w	d0,-(sp)		/* push argument */
	pea	tx_err			/* push controlstring */
	jsr	_printf
	add.l	#6,sp			/* clear sp */
	bra	IB_5
IB_4:
	bsr	modem_int
	bra	IB_5

/*==========================================================================*
 * C entry for out_int							    *
 * No lock() / restore() needed						    *
 *==========================================================================*/
_out_int:
	move.l	a5,-(sp)		/* save a5			*/
	move.l	8(sp),a5		/* get &rs_lines[0]		*/
	jsr	out_int
	move.l	(sp)+,a5		/* restore a5			*/
	rts

/*==========================================================================*
 * in_int reads the data which just arrived and does a little processing.   *
 * assumes that *rs is already in a5.                                       *
 *==========================================================================*/
in_int:
	move.b	AD_MFP+MF_UDR,d0	/* MFP->mf_udr */
	btst	#ORAWB,ostate(a5)
	bne	IC_4			/* rs->ostate & ORAW ? yes */
	cmp.b	oxoff(a5),d0
	bne	IC_6			/* *rs->iptr == rs->oxoff ? no */
	bclr	#OSWREADYB,ostate(a5)	/* rs->ostate &= ~OSWREADY */
	bra	IC_4
IC_6:
	bset	#OSWREADYB,ostate(a5)	/* rs->ostate & OSWREADY ? */
	bne	IC_4			/* !(rs->ostate & OSWREADY) ? no */
/* rs->ostate |= OSWREADY done by bset */
/*	or.b	#OSWREADY,ostate(a5)*/
					/* if (txready(rs))		*/
	move.b	AD_MFP+MF_TSR,d1	/* MFP->mf_tsr			*/
	and.b	#T_EMPTY+T_UE,d1	/* MFP->mf_tsr & (T_EMPTY | T_UE) */
	beq	IC_4		/* MFP->mf_tsr & (T_EMPTY | T_UE) ? no	*/
	bsr	out_int			/* does not destroy d0		*/
IC_4:
	cmp.w	#RS_IBUFSIZE,icount(a5)	/* rs->icount == buflen(rs->ibuf)? */
	beq	L104			/* ? yes			*/
	add.w	#1,icount(a5)		/* if (++rs->icount == RS_IHIGHWATER? */
	cmp.w	#RS_IHIGHWATER,icount(a5)
	bne	L101
	tst.b	idevready(a5)		/* 		&& rs->idevready)? */
	beq	L101
	
	move.l	#AD_SOUND,a1
	move.b	#YM_IOA,(a1)		/* SOUND->sd_selr = YM_IOA	*/
	move.b	(a1),d2			/* SOUND->sd_rdat		*/
	bclr	#PA_SDTRB,d2		/* SOUND->sd_rdat & ~PA_SDTR	*/
	bset	#PA_SRTSB,d2	/* SOUND->sd_rdat & ~PA_SDTR | PA_SRTS	*/
	move.b	d2,2(a1)	/* SOUND->sd_wdat = SOUND->sd_rdat & ~PA_SDTR | PA_SRTS */
	clr.b	idevready(a5)		/* rs->idevready = FALSE	*/
L101:
	move.l	ihead(a5),a0
	move.b	d0,(a0)+		/* *rs->ihead = c; rs->ihead++	*/
	move.l	a0,ihead(a5)
	lea	rs232_s_sz+RS_IBUFSIZE(a5),a1
	cmp.l	a0,a1			/* if (rs->ihead == bufend(rs->ibuf)) */
	bne	L102			/* b: no 			*/
	lea	rs232_s_sz(a5),a1	/* rs->ihead = rs->ibuf 	*/
	move.l	a1,ihead(a5)
L102:
	cmp.w	#1,icount(a5)		/* if (rs->icount == 1) {	*/
	bne	L103			/* b: no			*/
	move.l	(a5),a0
	move.w	#1,(a0)			/*   rs->tty->tty_events = 1	*/
	clr.l	_tty_timeout		/*   force_timeout()		*/
L103:
	rts
L104:
	move.l	#ibuf_msg,-(sp)
	jsr	_printf
	add.l	#4,sp
	bra	L103

/*==========================================================================*
 * line_int checks for and records errors.                                  *
 * assumes that *rs is already in a5.                                       *
 *==========================================================================*/
line_int:
	move.l	#AD_MFP,a1
	move.b	MF_RSR(a1),d2		/* MFP->mf_rsr			*/
	move.b	d2,lstatus(a5)		/* rs->lstatus = MFP->mf_rsr	*/

	and.b	#R_ENA,MF_RSR(a1)	/* MFP->mf_rsr &= R_ENA, clr stat */
	move.b	MF_UDR(a1),pad(a5)	/* rs->pad = MFP->mf_udr	*/

	lea	empty_msg,a1		/* empty string */
	btst	#4,d2
	beq	ID_2			/* rs->lstatus & LS_FRAMING_ERR ? no */
	add.w	#1,framing_errors(a5)	/* ++rs->framing_errors		*/
	lea	frame_msg,a0
	bra	ID_3
ID_2:
	move.l	a1,a0			/* empty message		*/
ID_3:
	move.l	a0,-(sp)		/* push message string		*/
	btst	#6,d2
	beq	ID_5			/* rs->lstatus & LS_OVERRUN_ERR ? no */
	add.w	#1,overrun_errors(a5)	/* ++rs->overrun_errors		*/
	lea	overrun_msg,a0
	bra	ID_6
ID_5:
	move.l	a1,a0			/* empty message		*/
ID_6:
	move.l	a0,-(sp)		/* push message string		*/
	btst	#5,d2
	beq	ID_8			/* rs->lstatus & LS_PARITY_ERR ? no */
	add.w	#1,parity_errors(a5)	/* ++rs->parity_errors		*/
	lea	parity_msg,a0
	bra	ID_9
ID_8:
	move.l	a1,a0			/* empty message		*/
ID_9:
	move.l	a0,-(sp)		/* push message string		*/
	btst	#3,d2
	beq	ID_B			/* rs->lstatus & LS_BREAK_INTERRUPT ? no */
	add.w	#1,break_interrupts(a5)	/* ++rs->break_interrupts	*/
	lea	break_msg,a0
	bra	ID_C
ID_B:
	move.l	a1,a0			/* empty message		*/
ID_C:
	sub.w	#1,print_count(a5)
	bgt	ID_D
	move.w	#PRINT_LEVEL,print_count(a5)
	move.l	a0,-(sp)
	move.l	#0,d0
	move.b	lstatus(a5),d0
	move.w	d0,-(sp)
	pea	status_msg
	jsr	_printf
	lea	22(sp),sp
	rts
ID_D:
	lea	12(sp),sp
	rts

/*==========================================================================*
 * modem_int looks for a possible new device status.                        *
 * assumes that *rs is already in a5.                                       *
 *==========================================================================*/
modem_int:
  /* Set active edge interrupt so that next change causes a new interrupt */
	move.l	#AD_MFP, a1
	move.b	MF_GPIP(a1),d2
	and.b	#IO_SCTS+IO_SDCD,d2	/* MFP->mf_gpip & (IO_SCTS|IO_SDCD) */
	move.b	MF_AER(a1),d1
	or.b	#IO_SCTS+IO_SDCD,d1	/* MFP->mf_aer | (IO_SCTS|IO_SDCD) */
	eor.b	d1,d2		/* (MFP->mf_aer  | (IO_SCTS|IO_SDCD)) ^
				   (MFP->mf_gpip & (IO_SCTS|IO_SDCD))	*/
	move.b	d2,MF_AER(a1)		/* MFP->mf_aer = ...		*/

	move.b	MF_GPIP(a1),d2		/* devready(rs)			*/
	not.b	d2			/* ~MFP->mf_gpip		*/
#if 0
	or.b	cts(a5),d2
	and.b	#MS_CTS,d2	/* (~MFP->mf_gpip|rs->cts) & MS_CTS	*/
#else
	and.b	#IO_SCTS,d2
	rol.w	#8,d2
	move.b	cts(a5),d2
	and.b	#MS_CTS,d2
	tst.w	d2
#endif
	bne	IE_3			/* ! ~MFP->mf_gpip & MS_CTS	*/
	bclr	#ODEVREADYB,ostate(a5)	/* rs->ostate &= ~ODEVREADY	*/
	bra	IE_4

IE_3:
	bset	#ODEVREADYB,ostate(a5)	/* rs->ostate & ODEVREADY ?	*/
	bne	IE_4			/* !(rs->ostate & ODEVREADY) ? no */
/* rs->ostate |= ODEVREADY done by bset */
/*	or.b	#ODEVREADY,ostate(a5)	*/
	move.b	MF_TSR(a1),d1		/* MFP->mf_tsr */
	and.b	#T_EMPTY+T_UE,d1	/* MFP->mf_tsr & (T_EMPTY | T_UE) */
	beq	IE_4		/* MFP->mf_tsr & (T_EMPTY | T_UE) ? no	*/
	bsr	out_int
IE_4:
	rts

/*==========================================================================*
 * out_int outputs data if there is one and everything is ready.            *
 * assumes that *rs is already in a5.                                       *
 *==========================================================================*/
out_int:
	cmp.b	#ODEVREADY+OQUEUED+OSWREADY,ostate(a5)	/* rs->ostate	*/
	bcs	L134		/* rs->ostate >= (ODEVREADY|OQUEUED|OSWREADY) ? no */
	move.l	otail(a5),a1		/* rs->otail			*/
	move.b	(a1)+,AD_MFP+MF_UDR	/* MFP->mf_udr = *rs->optr	*/
	move.l	a1,otail(a5)		/* store ++rs->optr		*/
	lea	rs232_s_sz+RS_IBUFSIZE+RS_OBUFSIZE(a5),a0
	cmp.l	a0,a1			/* if (rs->otail ==bufend(rs->obuf)) */
	bne	IF_3
	lea	rs232_s_sz+RS_IBUFSIZE(a5),a0
	move.l	a0,otail(a5)		/* rs->otail = rs->obuf		*/
IF_3:
	sub.w	#1,ocount(a5)		/* rs->ocount --		*/
	bne	L137
	eor.b	#ODONE+OQUEUED,ostate(a5) /* rs->ostate ^= (ODONE | OQUEUED) */
L138:
	move.l	(a5),a0			/* rs->tty->tty_events = 1	*/
	move.w	#1,(a0)
	clr.l	_tty_timeout		/* force_timeout()		*/
L134:
	rts
L137:
	cmp.w	#RS_OLOWWATER,ocount(a5)
	bne	L134
	bra	L138

	.sect .data
tx_err:
	.asciz	'sia: transmit error: status=%x\r\n'
ibuf_msg:
	.asciz	'sia: input buffer overflow\r\n'
frame_msg:
	.asciz	'frame error'
overrun_msg:
	.asciz	'overrun'
parity_msg:
	.asciz	'parity error'
break_msg:
	.asciz	'break'
empty_msg:
	.data1	0
status_msg:
	.asciz	'line_int, status=%x, %s/%s/%s/%s\r\n'
#endif /* !C_RS232_INT_HANDLERS */
#endif /* MACHINE == ATARI */
