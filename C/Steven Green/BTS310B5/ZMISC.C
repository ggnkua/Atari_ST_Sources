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
/*				   Zmodem routines used by Zsend and Zreceive				*/
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
/*																			*/
/*	This module is based largely on a similar module in OPUS-CBCS V1.03b.	*/
/*	The original work is (C) Copyright 1986, Wynn Wagner III. The original	*/
/*	authors have graciously allowed us to use their code in this work.		*/
/*																			*/
/*--------------------------------------------------------------------------*/

/* Warning! Do NOT detab this file since there are lots of spaces within "" */

#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>
#endif
#include <stdio.h>
#include <ctype.h>
#include <conio.h>

#if defined(__TURBOC__)
#ifndef __TOS__
#include <alloc.h>
#endif
#elif !defined(LATTICE)
#include <malloc.h>
#endif

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "zmodem.h"
#include "com.h"
#include "vfossil.h"
#include "session.h"

/*
 * Data
 */

char Rxhdr[4];                                   /* Received header           */
char Txhdr[4];                                   /* Transmitted header        */

#ifndef GENERIC
long *RXlong = (long *) &Rxhdr[0];
long *TXlong = (long *) &Txhdr[0];

#endif
long Rxpos;                                      /* Received file position    */
int Txfcs32;                                     /* TURE means send binary
                                                  * frames with 32 bit FCS    */
int Crc32t;                                      /* Display flag indicating
                                                  * 32 bit CRC being sent */
int Crc32;                                       /* Display flag indicating
                                                  * 32 bit CRC being received */
int Znulls;                                      /* # of nulls to send at
                                                  * beginning of ZDATA hdr     */

int Rxtimeout;                                   /* Tenths of seconds to wait
                                                  * for something          */
int Rxframeind;                                  /* ZBIN ZBIN32,ZHEX type of
                                                  * frame received */

char *Filename;                                  /* Name of the file being
                                                  * up/downloaded             */



size_t z_size = 0;


static int Rxtype;								 /* Type of header received 				*/

static char hex[] = "0123456789abcdef";

/* Send a byte as two hex digits */
#define Z_PUTHEX(i,c) {i=(c);SENDBYTE(hex[((i)&0xF0)>>4]);SENDBYTE(hex[(i)&0xF]);}

/*--------------------------------------------------------------------------*/
/* Private routines 														*/
/*--------------------------------------------------------------------------*/
static int _Z_GetBinaryHeader (unsigned char *);
static int _Z_32GetBinaryHeader (unsigned char *);
static int _Z_GetHexHeader (unsigned char *);
static int _Z_GetHex (void);
static int _Z_TimedRead (void);
static long _Z_PullLongFromHeader (unsigned char *);

void z_message (s)
byte *s;
{
   if (fullscreen && un_attended)
	  {
	  if (s)
		 {
		 sb_move (filewin, 2, 27);
		 sb_puts (filewin, s);
		 }
      sb_puts (filewin, "              ");
	  sb_show ();
	  }
   else
	  {
	  gotoxy (locate_x + 20, locate_y);
	  if (s)
		 {
		 cputs (s);
		 }
      cputs ("               ");
	  }
}

void z_log (s)
char *s;
{
   word x, y;

   z_message (s);

   x = locate_x;
   y = locate_y;
   status_line (s); 							 /* also does disk file
												  * logging */
   locate_x = x;
   locate_y = y;
}

void show_loc (l, w)
unsigned long l;
unsigned int w;
{
   char j[100];

   if (fullscreen && un_attended)
	  {
	  sb_move (filewin, 2, 37);
      sprintf (j, "Ofs=%ld Retries=%d        ", l, w);
	  sb_puts (filewin, j);
	  sb_show ();
	  }
   else
	  {
	  gotoxy (locate_x + 35, locate_y);
      printf ("Ofs=%ld Retries=%d        ", l, w);
	  }
}

/*--------------------------------------------------------------------------*/
/* Z GET BYTE																*/
/* Get a byte from the modem;												*/
/* return TIMEOUT if no read within timeout tenths, 						*/
/* return RCDO if carrier lost												*/
/*--------------------------------------------------------------------------*/
int Z_GetByte (tenths)
int tenths;
{
/*	 register int time_val = 0; */
#ifndef ATARIST
   register int i;
#endif   
   long timeout;

   if (PEEKBYTE () >= 0)
	  return (MODEM_IN ());

   timeout = timerset ((long)tenths * 10);

   do
	  {
	  if (PEEKBYTE () >= 0)
		 return MODEM_IN ();

#if defined(ATARIST)
	  if(!CARRIER)
#elif defined(OS_2)
	  if (!((i = MODEM_STATUS) & carrier_mask))
#else
	  if (!((i = MODEM_STATUS ()) & carrier_mask))
#endif
		 return RCDO;

	  if (got_ESC ())
		 return -1;

	  time_release ();
	  }
   while (!timeup (timeout));

   return TIMEOUT;
}

/*--------------------------------------------------------------------------*/
/* Z PUT STRING 															*/
/* Send a string to the modem, processing for \336 (sleep 1 sec)			*/
/* and \335 (break signal, ignored) 										*/
/*--------------------------------------------------------------------------*/
void Z_PutString (s)
register unsigned char *s;
{
   register int c;

   while (*s)
	  {
	  switch (c = *s++)
		 {
		 case '\336':
			big_pause (2);
		 case '\335':
/* Should send a break on this */
			break;
		 default:
			SENDBYTE ((unsigned char) c);
		 }										 /* switch */

	  } 										 /* while */

   Z_UncorkTransmitter ();						 /* Make sure all is well */
}												 /* Z_PutString */

/*--------------------------------------------------------------------------*/
/* Z SEND HEX HEADER														*/
/* Send ZMODEM HEX header hdr of type type									*/
/*--------------------------------------------------------------------------*/
void Z_SendHexHeader (type, hdr)
unsigned int type;
register unsigned char *hdr;
{
   register int n;
   register int i;
   register word crc;

#ifdef ZDEBUG
	if(debugging_log)
   		show_debug_name ("Z_SendHexHeader");
#endif


   Z_UncorkTransmitter ();						 /* Get our transmitter going */

   SENDBYTE (ZPAD);
   SENDBYTE (ZPAD);
   SENDBYTE (ZDLE);
   SENDBYTE (ZHEX);
   Z_PUTHEX (i, type);
#ifdef ZDEBUG
	if(debugging_log)
	    status_line(">Puthex type %02x", type);
#endif

   Crc32t = 0;
   crc = Z_UpdateCRC (type, 0);
   for (n = 4; --n >= 0;)
	  {
	  Z_PUTHEX (i, (*hdr));
	  crc = Z_UpdateCRC (*hdr++, crc);
	  }
   Z_PUTHEX (i, (crc >> 8));
   Z_PUTHEX (i, crc);
#ifdef ZDEBUG
	if(debugging_log)
	    status_line(">Puthex CRC %04x", crc);
#endif


   /* Make it printable on remote machine */
   SENDBYTE ('\r');
   SENDBYTE ('\n');

   /* Uncork the remote in case a fake XOFF has stopped data flow */
   if (type != ZFIN && type != ZACK)
	  SENDBYTE (021);

   if (!CARRIER)
	  CLEAR_OUTBOUND ();

}												 /* Z_SendHexHeader */

/*--------------------------------------------------------------------------*/
/* Z UNCORK TRANSMITTER 													*/
/* Wait a reasonable amount of time for transmitter buffer to clear.		*/
/*	 When it does, or when time runs out, turn XON/XOFF off then on.		*/
/*	 This should release a transmitter stuck by line errors.				*/
/*--------------------------------------------------------------------------*/

void Z_UncorkTransmitter ()
{
   long t;

   if (!OUT_EMPTY ())
	  {
	  t = timerset ((long)5 * Rxtimeout); 			 /* Wait for silence */
	  while (!timeup (t) && !OUT_EMPTY () && CARRIER)
		 time_release ();						 /* Give up slice while
												  * waiting  */
	  }
   XON_DISABLE ();								 /* Uncork the transmitter */
   XON_ENABLE ();
}


/*--------------------------------------------------------------------------*/
/* Z GET HEADER 															*/
/* Read a ZMODEM header to hdr, either binary or hex.						*/
/*	 On success, set Zmodem to 1 and return type of header. 				*/
/*	 Otherwise return negative on error 									*/
/*--------------------------------------------------------------------------*/
int Z_GetHeader (byte *hdr)
{

   register int c;
   register long n;		/* 38400 baud is bigger than 0x8000!!!! */
   int cancount;

#ifdef ZDEBUG
	if(debugging_log)
   		show_debug_name ("Z_GetHeader");
#endif

   n = cur_baud;								 /* Max characters before
												  * start of frame */
   cancount = 5;

Again:

   if (got_ESC ())
	  {
	  send_can ();
	  z_log (msgtxt[M_KBD_MSG]);
	  return ZCAN;
	  }

   Rxframeind = Rxtype = 0;

   switch (c = _Z_TimedRead ())
	  {
	  case ZPAD:
	  case ZPAD | 0200:
		 /*-----------------------------------------------*/
		 /* This is what we want.						  */
		 /*-----------------------------------------------*/
		 break;

	  case RCDO:
	  case TIMEOUT:
		 goto Done;

	  case CAN:

   GotCan:

		 if (--cancount <= 0)
			{
			c = ZCAN;
			goto Done;
			}
		 switch (c = Z_GetByte (1))
			{
			case TIMEOUT:
			   goto Again;

			case ZCRCW:
			   c = ERROR;
			   /* fallthrough... */

			case RCDO:
			   goto Done;

			case CAN:
			   if (--cancount <= 0)
				  {
				  c = ZCAN;
				  goto Done;
				  }
			   goto Again;
			}
		 /* fallthrough... */

	  default:

   Agn2:

		 if (--n <= 0)
			{
			z_log (msgtxt[M_FUBAR_MSG]);
			return ERROR;
			}

		 if (c != CAN)
			cancount = 5;
		 goto Again;

	  } 										 /* switch */

   cancount = 5;

Splat:

   switch (c = _Z_TimedRead ())
	  {
	  case ZDLE:
		 /*-----------------------------------------------*/
		 /* This is what we want.						  */
		 /*-----------------------------------------------*/
		 break;

	  case ZPAD:
		 goto Splat;

	  case RCDO:
	  case TIMEOUT:
		 goto Done;

	  default:
		 goto Agn2;

	  } 										 /* switch */


   switch (c = _Z_TimedRead ())
	  {

	  case ZBIN:
		 Rxframeind = ZBIN;
		 Crc32 = 0;
		 c = _Z_GetBinaryHeader (hdr);
		 break;

	  case ZBIN32:
		 Crc32 = Rxframeind = ZBIN32;
		 c = _Z_32GetBinaryHeader (hdr);
		 break;

	  case ZHEX:
		 Rxframeind = ZHEX;
		 Crc32 = 0;
		 c = _Z_GetHexHeader (hdr);
		 break;

	  case CAN:
		 goto GotCan;

	  case RCDO:
	  case TIMEOUT:
		 goto Done;

	  default:
		 goto Agn2;

	  } 										 /* switch */

   Rxpos = _Z_PullLongFromHeader (hdr);

Done:

#ifdef ZDEBUG
	if(debugging_log)
		status_line(">Z_GetHeader returning %d", c);
#endif

   return c;
}												 /* Z_GetHeader */

/*--------------------------------------------------------------------------*/
/* Z GET BINARY HEADER														*/
/* Receive a binary style header (type and position)						*/
/*--------------------------------------------------------------------------*/
static int _Z_GetBinaryHeader (hdr)
register unsigned char *hdr;
{
   register int c;
   register unsigned int crc;
   register int n;

#ifdef ZDEBUG
	if(debugging_log)
   		show_debug_name ("Z_GetBinaryHeader");
#endif

   if ((c = Z_GetZDL ()) & ~0xFF)
	  return c;
   Rxtype = c;
   crc = Z_UpdateCRC (c, 0);

   for (n = 4; --n >= 0;)
	  {
	  if ((c = Z_GetZDL ()) & ~0xFF)
		 return c;
	  crc = Z_UpdateCRC (c, crc);
	  *hdr++ = (unsigned char) (c & 0xff);
	  }
   if ((c = Z_GetZDL ()) & ~0xFF)
	  return c;

   crc = Z_UpdateCRC (c, crc);
   if ((c = Z_GetZDL ()) & ~0xFF)
	  return c;

   crc = Z_UpdateCRC (c, crc);
   if (crc & 0xFFFF)
	  {
	  z_message (msgtxt[M_CRC_MSG]);
	  return ERROR;
	  }

   return Rxtype;
}												 /* _Z_GetBinaryHeader */


/*--------------------------------------------------------------------------*/
/* Z GET BINARY HEADER with 32 bit CRC										*/
/* Receive a binary style header (type and position)						*/
/*--------------------------------------------------------------------------*/
static int _Z_32GetBinaryHeader (hdr)
register unsigned char *hdr;
{
   register int c;
   register unsigned long crc;
   register int n;

#ifdef ZDEBUG
	if(debugging_log)
	   show_debug_name ("Z_32GetBinaryHeader");
#endif

   if ((c = Z_GetZDL ()) & ~0xFF)
	  return c;
   Rxtype = c;
   crc = 0xFFFFFFFF;
   crc = Z_32UpdateCRC (c, crc);

   for (n = 4; --n >= 0;)
	  {
	  if ((c = Z_GetZDL ()) & ~0xFF)
		 return c;
	  crc = Z_32UpdateCRC (c, crc);
	  *hdr++ = (unsigned char) (c & 0xff);
	  }

   for (n = 4; --n >= 0;)
	  {
	  if ((c = Z_GetZDL ()) & ~0xFF)
		 return c;

	  crc = Z_32UpdateCRC (c, crc);
	  }

   if (crc != 0xDEBB20E3)
	  {
	  z_message (msgtxt[M_CRC_MSG]);
	  return ERROR;
	  }

   return Rxtype;
}												 /* _Z_32GetBinaryHeader */

/*--------------------------------------------------------------------------*/
/* Z GET HEX HEADER 														*/
/* Receive a hex style header (type and position)							*/
/*--------------------------------------------------------------------------*/
static int _Z_GetHexHeader (hdr)
register unsigned char *hdr;
{
   register int c;
   register unsigned int crc;
   register int n;

#ifdef ZDEBUG
	if(debugging_log)
	   show_debug_name ("Z_GetHexHeader");
#endif

   if ((c = _Z_GetHex ()) < 0)
	  return c;
   Rxtype = c;
   crc = Z_UpdateCRC (c, 0);

   for (n = 4; --n >= 0;)
	  {
	  if ((c = _Z_GetHex ()) < 0)
		 return c;
	  crc = Z_UpdateCRC (c, crc);
	  *hdr++ = (unsigned char) c;
	  }

   if ((c = _Z_GetHex ()) < 0)
	  return c;
   crc = Z_UpdateCRC (c, crc);
   if ((c = _Z_GetHex ()) < 0)
	  return c;
   crc = Z_UpdateCRC (c, crc);
   if (crc & 0xFFFF)
	  {
	  z_message (msgtxt[M_CRC_MSG]);
	  return ERROR;
	  }
   if (Z_GetByte (1) == '\r')
	  Z_GetByte (1);							 /* Throw away possible cr/lf */

   return Rxtype;
}

/*--------------------------------------------------------------------------*/
/* Z GET HEX																*/
/* Decode two lower case hex digits into an 8 bit byte value				*/
/*--------------------------------------------------------------------------*/
static int _Z_GetHex ()
{
   register int c, n;

#ifdef ZDEBUG
	if(debugging_log)
   		show_debug_name ("Z_GetHex");
#endif

   if ((n = _Z_TimedRead ()) < 0)
	  return n;
   n -= '0';
   if (n > 9)
	  n -= ('a' - ':');
   if (n & ~0xF)
	  return ERROR;

   if ((c = _Z_TimedRead ()) < 0)
	  return c;
   c -= '0';
   if (c > 9)
	  c -= ('a' - ':');
   if (c & ~0xF)
	  return ERROR;

#ifdef ZDEBUG
	if(debugging_log)
	   status_line(">Z_GotHex %x%x", n, c);
#endif
   return ((n << 4) | c);
}

/*--------------------------------------------------------------------------*/
/* Z GET ZDL																*/
/* Read a byte, checking for ZMODEM escape encoding 						*/
/* including CAN*5 which represents a quick abort							*/
/*--------------------------------------------------------------------------*/
int Z_GetZDL ()
{
   register int c;

   if ((c = Z_GetByte (Rxtimeout)) != ZDLE)
	  return c;

   switch (c = Z_GetByte (Rxtimeout))
	  {
	  case CAN:
		 return ((c = Z_GetByte (Rxtimeout)) < 0) ? c :
			((c == CAN) && ((c = Z_GetByte (Rxtimeout)) < 0)) ? c :
			((c == CAN) && ((c = Z_GetByte (Rxtimeout)) < 0)) ? c : (GOTCAN);

	  case ZCRCE:
	  case ZCRCG:
	  case ZCRCQ:
	  case ZCRCW:
		 return (c | GOTOR);

	  case ZRUB0:
		 return 0x7F;

	  case ZRUB1:
		 return 0xFF;

	  default:
		 return (c < 0) ? c :
			((c & 0x60) == 0x40) ? (c ^ 0x40) : ERROR;

	  } 										 /* switch */
}												 /* Z_GetZDL */

/*--------------------------------------------------------------------------*/
/* Z TIMED READ 															*/
/* Read a character from the modem line with timeout.						*/
/*	Eat parity, XON and XOFF characters.									*/
/*--------------------------------------------------------------------------*/
static int _Z_TimedRead ()
{
   register int c;

#ifdef ZDEBUG
	if(debugging_log)
   		show_debug_name ("Z_TimedRead");
#endif

   for (;;)
	  {
	  if ((c = Z_GetByte (Rxtimeout)) < 0)
		 return c;

	  switch (c &= 0x7F)
		 {
		 case XON:
		 case XOFF:
			continue;

		 default:
			if (!(c & 0x60))
			   continue;

		 case '\r':
		 case '\n':
		 case ZDLE:
			return c;
		 }										 /* switch */

	  } 										 /* for */
}												 /* _Z_TimedRead */

/*--------------------------------------------------------------------------*/
/* Z LONG TO HEADER 														*/
/* Store long integer pos in Txhdr											*/
/*--------------------------------------------------------------------------*/
void Z_PutLongIntoHeader (pos)
long pos;
{
#ifndef GENERIC
   *((long *) Txhdr) = pos;
#else
   Txhdr[ZP0] = pos;
   Txhdr[ZP1] = pos >> 8;
   Txhdr[ZP2] = pos >> 16;
   Txhdr[ZP3] = pos >> 24;
#endif
}												 /* Z_PutLongIntoHeader */

/*--------------------------------------------------------------------------*/
/* Z PULL LONG FROM HEADER													*/
/* Recover a long integer from a header 									*/
/*--------------------------------------------------------------------------*/
static long _Z_PullLongFromHeader (hdr)
unsigned char *hdr;
{
#ifndef GENERIC
   return (*((long *) Rxhdr)); /*PLF Fri  05-05-1989  06:42:41 */
   /* hdr; */					/*PLF Fri	05-05-1989	06:42:59 ; Trick to
								 * keep /W3 happy */
#else
   long l;

   l = hdr[ZP3];
   l = (l << 8) | hdr[ZP2];
   l = (l << 8) | hdr[ZP1];
   l = (l << 8) | hdr[ZP0];
   return l;
#endif
}												 /* _Z_PullLongFromHeader */

/* END OF FILE: zmisc.c */
