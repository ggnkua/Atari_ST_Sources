#ifndef H_COM_ST
#define H_COM_ST
/*
 * com_st.h
 *
 * Atari ST version of com_dos.h and com_os2.h
 *
 * This emulates some of the Fossil functions
 * Refer to FSC-0015.CHT and FSC-0015.DOC
 *
 */

#ifndef _PORTAB_H
#include <portab.h>
#endif

#ifdef LATTICE
#ifndef _OSBIND_H
#include <osbind.h>
#endif
#endif

#ifdef __TOS__
#include "tos.h"
#ifndef TRUE
typedef int BOOLEAN;
#define FALSE 0
#define TRUE 1
#endif
#endif

extern unsigned int comm_bits;
extern unsigned int parity;
extern unsigned int stop_bits;


#define BITS_7			0x20
#define BITS_8			0x00

#define STOP_1			 0x08
#define STOP_2			 0x18

#define ODD_PARITY		0x06
#define EVEN_PARITY 	0x04
#define NO_PARITY		0x00


#define BAUD_300		300			/* These are the Rsconf parameters */
#define BAUD_1200       1200
#define BAUD_2400		2400
#define BAUD_4800		4800
#define BAUD_9600		9600
#define BAUD_19200		19200
#define BAUD_38400		38400		/* ST cant do 38400 baud yet! */

#define USE_XON			0x01		/* OR these for both */
#define USE_CTS			0x02

#define BRK 			0x01
#define MDM 			0x02


#define PSG_RTS 0x08
#define PSG_DTR 0x10

#define DTR_BITS (PSG_DTR+PSG_RTS)

/* Status return values */

#define DATA_READY		0x0100
#define OVERRUN_ERR		0x0200
#define PARITY_ERR		0x0400
#define FRAMING_ERR		0x0800
#define BREAK_INT		0x1000
#define TX_HOLD_EMPTY	0x2000
#define TX_SHIFT_EMPTY	0x4000




#define GENERIC			/* Keep Zmodem happy with 68000 ordering */



/* The fossil routines */

                           /*-----------------------------------------------*/
                           /* Service 0: SET BAUD(etc)                      */
                           /*-----------------------------------------------*/


void MDM_ENABLE(unsigned baud);

                           /*-----------------------------------------------*/
                           /* Service 1: SEND CHAR (wait)                   */
                           /*-----------------------------------------------*/
extern BOOLEAN HardCTS;
long get_cts(void);
#define CTS ((BOOLEAN)Supexec(get_cts))
void SENDBYTE(unsigned char);
                           /*-----------------------------------------------*/
                           /* Service 2: GET CHAR (wait)                    */
                           /*-----------------------------------------------*/
int MODEM_IN(void);
                           /*-----------------------------------------------*/
                           /* Service 3: GET STATUS                         */
                           /*-----------------------------------------------*/
long get_dcd(void);
#define CARRIER 		((BOOLEAN)Supexec(get_dcd))
long CHAR_AVAIL(void);
long OUT_FULL(void);
BOOLEAN OUT_EMPTY(void);
                           /*-----------------------------------------------*/
                           /* Service 4: INIT/INSTALL                       */
                           /*-----------------------------------------------*/
int Cominit(int);
                           /*-----------------------------------------------*/
                           /* Service 5: UNINSTALL                          */
                           /*-----------------------------------------------*/
void MDM_DISABLE(void);
                           /*-----------------------------------------------*/
                           /* Service 6: SET DTR                            */
                           /*-----------------------------------------------*/
long dtr_on(void);
#define DTR_ON()	 		Supexec(dtr_on)
long dtr_off(void);
#define DTR_OFF() 		Supexec(dtr_off)
                           /*-----------------------------------------------*/
                           /* Service 7: GET TIMER TICK PARMS               */
                           /*-----------------------------------------------*/

                           /*-----------------------------------------------*/
                           /* Service 8: FLUSH OUTBOUND RING-BUFFER         */
                           /*-----------------------------------------------*/

                           /*-----------------------------------------------*/
                           /* Service 9: NUKE OUTBOUND RING-BUFFER          */
                           /*-----------------------------------------------*/
void CLEAR_OUTBOUND(void);
                           /*-----------------------------------------------*/
                           /* Service a: NUKE INBOUND RING-BUFFER           */
                           /*-----------------------------------------------*/
void CLEAR_INBOUND(void);
                           /*-----------------------------------------------*/
                           /* Service b: SEND CHAR (no wait)                */
                           /*-----------------------------------------------*/
BOOLEAN Com_Tx_NW(char);
                           /*-----------------------------------------------*/
                           /* Service c: GET CHAR (no wait)                 */
                           /*-----------------------------------------------*/
int PEEKBYTE(void);
                           /*-----------------------------------------------*/
                           /* Service d: GET KEYBOARD STATUS                */
                           /*-----------------------------------------------*/

/*
 * I seem to be losing a lot of characters when calling Bios, I suspect
 * GemDos is grabbing them into its own internal buffer
 *
 * Try using GEMDOS instead
 */
#define KEYPRESS()		Cconis()

                           /*-----------------------------------------------*/
                           /* Service e: GET KEYBOARD CHARACTER (wait)      */
                           /*-----------------------------------------------*/
int getkey(void);
#define READKB()	getkey()
#define FOSSIL_CHAR()   getkey()
                           /*-----------------------------------------------*/
                           /* Service f: SET/GET FLOW CONTROL STATUS        */
                           /*-----------------------------------------------*/

#ifdef OLDXON

#define XON_ENABLE()	Rsconf(-1, /* xonflow| */ ctsflow        ,-1,-1,-1,-1)
#define XON_DISABLE()   Rsconf(-1, ctsflow,-1,-1,-1,-1)
#define IN_XON_ENABLE()	Rsconf(-1, /* xonflow| */ ctsflow        ,-1,-1,-1,-1)

#else	/* NULL Functions */

#define XON_ENABLE()
#define XON_DISABLE()
#define IN_XON_ENABLE()

#endif

                           /*-----------------------------------------------*/
                           /* Service 10: SET/GET CTL-BREAK CONTROLS        */
                           /*             Note that the "break" here refers */
                           /*             to ^C and ^K rather than the      */
                           /*             tradition modem BREAK.            */
                           /*-----------------------------------------------*/

#define _BRK_ENABLE()   ((void)0)	/* Null function */
#define _BRK_DISABLE()  ((void)0)	/* Null function */
#define RECVD_BREAK()	0

                           /*-----------------------------------------------*/
                           /* Service 11: SET LOCAL VIDEO CURSOR POSITION   */
                           /*-----------------------------------------------*/

                           /*-----------------------------------------------*/
                           /* Service 12: GET LOCAL VIDEO CURSOR POSITION   */
                           /*-----------------------------------------------*/

                           /*-----------------------------------------------*/
                           /* Service 13: WRITE LOCAL ANSI CHARACTER        */
                           /*-----------------------------------------------*/

#ifdef BIOSDISPLAY
#define WRITE_ANSI(c)   (BIOSdisplay ? Bconout(2, c) : Cconout(c))
#else
#define WRITE_ANSI(c)   Cconout(c)
#endif
                           /*-----------------------------------------------*/
                           /* Service 14: WATCHDOG on/off                   */
                           /*-----------------------------------------------*/

                           /*-----------------------------------------------*/
                           /* Service 15: BIOS write to screen              */
                           /*-----------------------------------------------*/


/*
 * Other miscellaneous Comms functions
 */
 
int real_flush (int);		/* Flush the file */

void do_break (int);		/* Send break signal */

/*
 * Send a block of data to modem
 * if carcheck is non zero then abort if no carrier
 *
 * Will NOT wait for buffer space.
 */

void SENDCHARS(char *buf, size_t size, BOOLEAN carcheck);

void BUFFER_BYTE (unsigned char);
void UNBUFFER_BYTES (void);

extern BOOLEAN ikbdclock;
extern BOOLEAN hard_38400;
extern BOOLEAN rsve_board;

void update_time(void);
extern int ctsflow;			/* Mask for CTS flow enabling */
/* extern int xonflow; */			/* Xon/Xoff flow mask */
extern unsigned int st_lock_baud;

extern size_t tBufSize;			/* New size of buffers */
extern size_t rBufSize;


#endif	/* H_COM_ST */
