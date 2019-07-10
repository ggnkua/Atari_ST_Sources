/*
 *	uw command bytes
 *
 * Copyright 1985 by John D. Bruner.  All rights reserved.  Permission to
 * copy this program is given provided that the copy is not sold and that
 * this copyright notice is included.
 *
 *
 * Two types of information are exchanged through the 7-bit serial line:
 * ordinary data and command bytes.  Command bytes are preceeded by
 * an IAC byte.  IAC bytes and literal XON/XOFF characters (those which
 * are not used for flow control) are sent by a CB_FN_CTLCH command.
 * Characters with the eighth bit set (the "meta" bit) are prefixed with
 * a CB_FN_META function.
 *
 * The next most-significant bit in the byte specifies the sender and
 * recipient of the command.  If this bit is clear (0), the command byte
 * was sent from the host computer to the Macintosh; if it is set (1)
 * the command byte was sent from the Macintosh to the host computer.
 * This prevents confusion in the event that the host computer
 * (incorrectly) echos a command back to the Macintosh.
 *
 * The remaining six bits are partitioned into two fields.  The low-order
 * three bits specify a window number from 1-7 (window 0 is reserved for
 * other uses) or another type of command-dependent parameter.  The next
 * three bits specify the operation to be performed by the recipient of
 * the command byte.
 *
 * Note that the choice of command bytes prevents the ASCII XON (021) and
 * XOFF (023) characters from being sent as commands.  CB_FN_ISELW commands
 * are only sent by the Macintosh (and thus are tagged with the CB_DIR_MTOH
 * bit).  Since XON and XOFF data characters are handled via CB_FN_CTLCH,
 * this allows them to be used for flow control purposes.
 */
 
#define	IAC		0001		/* interpret as command */
#define	CB_DIR		0100		/* command direction: */
#define	CB_DIR_HTOM	0000		/*	from host to Mac */
#define	CB_DIR_MTOH	0100		/*	from Mac to host */
#define	CB_FN		0070		/* function code: */
#define	CB_FN_NEWW	0000		/*	new window */
#define	CB_FN_KILLW	0010		/*	kill (delete) window */
#define	CB_FN_ISELW	0020		/*	select window for input */
#define	CB_FN_OSELW	0030		/*	select window for output */
#define	CB_FN_META	0050		/*	add meta to next data char */
#define	CB_FN_CTLCH	0060		/*	low 3 bits specify char */
#define	CB_FN_MAINT	0070		/*	maintenance functions */
#define	CB_WINDOW	0007		/* window number mask */
#define	CB_CC		0007		/* control character specifier: */
#define	CB_CC_IAC	1		/*	IAC */
#define	CB_CC_ON	2		/*	XON */
#define	CB_CC_OFF	3		/*	XOFF */
#define	CB_MF		0007		/* maintenance functions: */
#define	CB_MF_ENTRY	0		/*	beginning execution */
#define	CB_MF_EXIT	7		/*	execution terminating */
#define	NWINDOW		7		/* maximum number of windows */

/* CB_CC_XON and CB_CC_XOFF give the same name on the DR C compiler.
 * Changed them to CB_CC_ON and CB_CC_OFF
 * hmm@unido
 */
