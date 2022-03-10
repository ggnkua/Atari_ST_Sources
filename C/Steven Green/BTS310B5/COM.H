#ifndef H_COM
#define H_COM
/*--------------------------------------------------------------------------*/
/*																			*/
/*																			*/
/*		------------		 Bit-Bucket Software, Co.						*/
/*		\ 10001101 /		 Writers and Distributors of					*/
/*		 \ 011110 / 		 Freely Available<tm> Software. 				*/
/*		  \ 1011 /															*/
/*		   ------															*/
/*																			*/
/*	(C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*																			*/
/*																			*/
/*				  Communications definitions for BinkleyTerm				*/
/*																			*/
/*																			*/
/*	  For complete	details  of the licensing restrictions, please refer	*/
/*	  to the License  agreement,  which  is published in its entirety in	*/
/*	  the MAKEFILE and BT.C, and also contained in the file LICENSE.240.	*/
/*																			*/
/*	  USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE	*/
/*	  BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF	*/
/*	  THIS	AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,	OR IF YOU DO	*/
/*	  NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET	*/
/*	  SOFTWARE CO.	AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT	*/
/*	  SHOULD YOU  PROCEED TO USE THIS FILE	WITHOUT HAVING	ACCEPTED THE	*/
/*	  TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER	*/
/*	  AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.		*/
/*																			*/
/*																			*/
/* You can contact Bit Bucket Software Co. at any one of the following		*/
/* addresses:																*/
/*																			*/
/* Bit Bucket Software Co.		  FidoNet  1:104/501, 1:132/491, 1:141/491	*/
/* P.O. Box 460398				  AlterNet 7:491/0							*/
/* Aurora, CO 80046 			  BBS-Net  86:2030/1						*/
/*								  Internet f491.n132.z1.fidonet.org 		*/
/*																			*/
/* Please feel free to contact us at any time to share your comments about	*/
/* our software and/or licensing policies.									*/
/*																			*/
/*--------------------------------------------------------------------------*/

#if defined(ATARIST)

#include "com_st.h"

#else

/* This is PC specific!!!!!!!!!! */

#define BITS_7			0x02
#define BITS_8			0x03
#define STOP_1			 0x00
#define STOP_2			 0x04
#define ODD_PARITY		0x08
#define EVEN_PARITY 	0x18
#define NO_PARITY		0x00

#ifdef OS_2
#define BAUD_300		300
#define BAUD_1200		1200
#define BAUD_2400		2400
#define BAUD_4800		4800
#define BAUD_9600		9600
#define BAUD_19200		19200
#define BAUD_38400		38400
#else
#define BAUD_300		0x040
#define BAUD_1200		0x080
#define BAUD_2400		0x0A0
#define BAUD_4800		0x0C0
#define BAUD_9600		0x0E0
#define BAUD_19200		0x000
#define BAUD_38400		0x020
#endif

/* Bit definitions for the Line Status Register */

#define DATA_READY		0x0100
#define OVERRUN_ERR		0x0200
#define PARITY_ERR		0x0400
#define FRAMING_ERR		0x0800
#define BREAK_INT		0x1000
#define TX_HOLD_EMPTY	0x2000
#define TX_SHIFT_EMPTY	0x4000

/* Bit definitions for the driver flags */

#define USE_XON			0x01
#define USE_CTS			0x02
#define USE_DSR			0x04
#define OTHER_XON			0x08

#define BRK 			0x01
#define MDM 			0x02

#if defined(OS_2)
#include "com_os2.h"
#else  /* OS_2 */
#include "com_dos.h"
#endif /* OS_2 */

#endif /* ATARIST */

/* A few odd defines */

#define CLEAR_IOERR() errno = 0

#define wait_for_clear() while (!OUT_EMPTY())
#define TIMED_READ(a) (int) com_getc(a)


#endif	/* H_COM */
/* END OF FILE: com.h */

