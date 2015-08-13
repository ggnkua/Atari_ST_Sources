/************************************************************************/
/*																		*/
/*	Generic NEx000 driver for any BUS interface and STinG and MagicNet	*/
/*	and MINTNet															*/
/*	Copyright 2002 Dr. Thomas Redelberger								*/
/*	Use it under the terms of the GNU General Public License			*/
/*	(See file COPYING.TXT)												*/
/*																		*/
/* Software interface file												*/
/*																		*/
/* Credits:																*/
/* Part of this source code is based on the source module netdevice.h	*/
/* of Linux originally due to the authors Donald Becker, ...			*/
/*																		*/
/* Tabsize 4, developed with Turbo-C ST 2.0								*/
/*																		*/
/************************************************************************/
/*
$Id: ne.h 1.3 2002/06/08 16:08:36 Thomas Exp Thomas $
 */


/**** entry points in NE.S ****/

extern	long			ei_probe1(void);	/* fills dev_dev_addr */

extern	long			ei_open(void);

extern	long			ei_close(void);

extern	long			ei_start_xmit(
	uint8 *PktFrstPortion, uint16 lenFrst, uint8 *PktScndPortion, uint16 lenScnd);

extern	void	cdecl	ei_interrupt(void);

extern	void*			get_stats(void);	/* access to driver statistics (experimental) */


	
/**** the (single) device hosted by NE.S ****/

struct netDevice {
/* this is only a small subset of struct dev from Linux' netdevice.h */
	uint8	dev_start;			/* device is active when <>0 */
	uint8	dev_interrupt;		/* interrupt arrived */
	uint8	dev_tbusy;			/* transmitter busy */
	uint8	filler1;			/* word align */
	uint32	dev_trans_start;	/* Time (in jiffies) of last Tx */
	uint16	dev_flags;			/* interface flags (a la BSD) */
	uint8	dev_dev_addr[6];	/* MAC address */
	void*	dev_mc_list;		/* pointer to Multicast MAC addresses (who fills this?) */

/* this is only a small subset of struct ei_device from Linux' 8390.h */
	char*	lcl_name;			/* points to device name string */
	uint8	lcl_irqlock;		/* lock out 8390 interrupts when <>0 */
	uint8	filler2;			/* word align */
};


extern struct netDevice DVS;	/* defined in NE.S */

