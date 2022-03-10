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
/*						Zmodem file reception module						*/
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

/* Do NOT entab this file because there are lots of quoted spaces */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <conio.h>

#ifdef __TOS__
#pragma warn -sus
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>
#endif
#include <time.h>

#ifdef LATTICE
#define ultoa(v,s,r) (stcul_d(s,v),s)
#include <errno.h>
#else
#include <io.h>
#endif

#if defined(__TURBOC__)
#include "tc_utime.h"
#elif defined(LATTICE)
#include <utime.h>
#else
#include <sys/utime.h>
#endif

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "zmodem.h"
#include "com.h"
#include "vfossil.h"
#include "session.h"


/*--------------------------------------------------------------------------*/
/* Local routines															*/
static int RZ_ReceiveData (byte *, int);
static int RZ_32ReceiveData (byte *, int);
static int RZ_InitReceiver (void);
static int RZ_ReceiveBatch (FILE *);
static int RZ_ReceiveFile (FILE *);
static int RZ_GetHeader (void);
static int RZ_SaveToDisk (unsigned long *);
static void RZ_AckBibi (void);

/*--------------------------------------------------------------------------*/
/* Private declarations 													*/
/*--------------------------------------------------------------------------*/
static unsigned long DiskAvail;
static long filetime;
static byte realname[64];

/*--------------------------------------------------------------------------*/
/* Private data 															*/
/*--------------------------------------------------------------------------*/

/* Parameters for ZSINIT frame */
#define ZATTNLEN 32

static char Attn[ZATTNLEN + 1]; 				 /* String rx sends to tx on
												  * err 		   */
static FILE *Outfile;							 /* Handle of file being
												  * received		   */
static int Tryzhdrtype; 						 /* Hdr type to send for Last
												  * rx close	  */
static char isBinary;							 /* Current file is binary
												  * mode			 */
static char EOFseen;							 /* indicates cpm eof (^Z)
												  * was received	 */
static char Zconv;								 /* ZMODEM file conversion
												  * request 		 */
static size_t RxCount;								/* Count of data bytes
												  * received			*/
static byte Upload_path[PATHLEN];				 /* Dest. path of file being
												  * received   */
static long Filestart;							 /* File offset we started
												  * this xfer from	 */
#ifndef __TOS__
extern long filelength( void );						 /* returns length of file
												  * ref'd in stream  */
#endif

/*--------------------------------------------------------------------------*/
/* GET ZMODEM																*/
/* Receive a batch of files.												*/
/* returns TRUE (1) for good xfer, FALSE (0) for bad						*/
/* can be called from f_upload or to get mail from a WaZOO Opus 			*/
/*--------------------------------------------------------------------------*/
int get_Zmodem( char *rcvpath, FILE *xferinfo )
{
   byte namebuf[PATHLEN];
   int i;
   byte *p;
   char *HoldName;
   long t;

#ifdef DEBUG
	if(debugging_log)
		status_line(">get_Zmodem(%s)", rcvpath);
#endif
#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("get_Zmodem");
#endif

   filetime = 0;

#ifndef ATARIST		/* I think the call to RsConf was losing a character */
   _BRK_DISABLE ();
   IN_XON_ENABLE ();
#endif

/*	 Secbuf = NULL;*/
   Outfile = NULL;
   z_size = 0;


   Rxtimeout = 100;
   Tryzhdrtype = ZRINIT;

   strcpy (namebuf, rcvpath);
   Filename = namebuf;

   strcpy (Upload_path, rcvpath);
   p = Upload_path + strlen (Upload_path) - 1;
   while (p >= Upload_path && *p != '\\')
	  --p;
   *(++p) = '\0';

   HoldName = HoldAreaNameMunge(&remote_addr);

#ifdef IOS
	if(iosmode)
	   sprintf (Abortlog_name, "%s%s.Z\0",
			HoldName, Addr36(&remote_addr));
	else
#endif
	   sprintf (Abortlog_name, "%s%s.Z\0",
			HoldName, Hex_Addr_Str (&remote_addr));

   DiskAvail = zfree (Upload_path);

   if (((i = RZ_InitReceiver ()) == ZCOMPL) ||
	   ((i == ZFILE) && ((RZ_ReceiveBatch (xferinfo)) == OK)))
	  {
#ifndef ATARIST
	  XON_DISABLE ();
	  XON_ENABLE ();							 /* Make sure xmitter is
												  * unstuck */
#endif
	  return 1;
	  }

   CLEAR_OUTBOUND ();
#ifndef ATARIST
   XON_DISABLE ();								 /* Make sure xmitter is
												  * unstuck */
#endif
   send_can (); 								 /* transmit at least 10 cans	 */
   t = timerset (200);							 /* wait no more than 2
												  * seconds  */
   while (!timeup (t) && !OUT_EMPTY () && CARRIER)
	  time_release ();							 /* Give up slice while
												  * waiting  */
#ifndef ATARIST
   XON_ENABLE ();								 /* Turn XON/XOFF back on...	 */
#endif

/*
   if (Secbuf)
	  free (Secbuf);
*/
   if (Outfile)
	  fclose (Outfile);

   return 0;
}												 /* get_Zmodem */

/*--------------------------------------------------------------------------*/
/* RZ RECEIVE DATA															*/
/* Receive array buf of max length with ending ZDLE sequence				*/
/* and CRC.  Returns the ending character or error code.					*/
/*--------------------------------------------------------------------------*/
static int RZ_ReceiveData( register byte *buf, register int length )
{
   register int c;
   register word crc;
   char *endpos;
   int d;


#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("RZ_ReceiveData");
#endif

   if (Rxframeind == ZBIN32)
	  return RZ_32ReceiveData (buf, length);

   crc = 0;
   RxCount = 0;
   buf[0] = buf[1] = 0;
   endpos = buf + length;

   while (buf <= endpos)
	  {
	  if ((c = Z_GetZDL ()) & ~0xFF)
		 {
   CRCfoo:
		 switch (c)
			{
			case GOTCRCE:
			case GOTCRCG:
			case GOTCRCQ:
			case GOTCRCW:
			   /*-----------------------------------*/
			   /* C R C s							*/
			   /*-----------------------------------*/
			   crc = Z_UpdateCRC (((d = c) & 0xFF), crc);
			   if ((c = Z_GetZDL ()) & ~0xFF)
				  goto CRCfoo;

			   crc = Z_UpdateCRC (c, crc);
			   if ((c = Z_GetZDL ()) & ~0xFF)
				  goto CRCfoo;

			   crc = Z_UpdateCRC (c, crc);
			   if (crc & 0xFFFF)
				  {
				  z_message (msgtxt[M_CRC_MSG]);
				  return ERROR;
				  }

			   RxCount = length - (endpos - buf);
			   return d;

			case GOTCAN:
			   /*-----------------------------------*/
			   /* Cancel							*/
			   /*-----------------------------------*/
			   z_log (msgtxt[M_CAN_MSG]);
			   return ZCAN;

			case TIMEOUT:
			   /*-----------------------------------*/
			   /* Timeout							*/
			   /*-----------------------------------*/
			   z_message (msgtxt[M_TIMEOUT]);
			   return c;

			case RCDO:
			   /*-----------------------------------*/
			   /* No carrier						*/
			   /*-----------------------------------*/
			   z_log (msgtxt[M_NO_CARRIER]);
			   CLEAR_INBOUND ();
			   return c;

			default:
			   /*-----------------------------------*/
			   /* Something bizarre 				*/
			   /*-----------------------------------*/
			   z_message (msgtxt[M_DEBRIS]);
			   CLEAR_INBOUND ();
			   return c;
			}									 /* switch */
		 }										 /* if */

	  *buf++ = (unsigned char) c;
	  crc = Z_UpdateCRC (c, crc);
	  } 										 /* while(1) */

   z_message (msgtxt[M_LONG_PACKET]);
   return ERROR;
}												 /* RZ_ReceiveData */

/*--------------------------------------------------------------------------*/
/* RZ RECEIVE DATA with 32 bit CRC											*/
/* Receive array buf of max length with ending ZDLE sequence				*/
/* and CRC.  Returns the ending character or error code.					*/
/*--------------------------------------------------------------------------*/
static int RZ_32ReceiveData( register byte *buf, register int length )
{
   register int c;
   unsigned long crc;
   char *endpos;
   int d;


#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("RZ_32ReceiveData");
#endif

   crc = 0xFFFFFFFFUL;
   RxCount = 0;
   buf[0] = buf[1] = 0;
   endpos = buf + length;

   while (buf <= endpos)
	  {
	  if ((c = Z_GetZDL ()) & ~0xFF)
		 {
   CRCfoo:
		 switch (c)
			{
			case GOTCRCE:
			case GOTCRCG:
			case GOTCRCQ:
			case GOTCRCW:
			   /*-----------------------------------*/
			   /* C R C s							*/
			   /*-----------------------------------*/
			   d = c;
			   c &= 0377;
			   crc = Z_32UpdateCRC (c, crc);
			   if ((c = Z_GetZDL ()) & ~0xFF)
				  goto CRCfoo;

			   crc = Z_32UpdateCRC (c, crc);
			   if ((c = Z_GetZDL ()) & ~0xFF)
				  goto CRCfoo;

			   crc = Z_32UpdateCRC (c, crc);
			   if ((c = Z_GetZDL ()) & ~0xFF)
				  goto CRCfoo;

			   crc = Z_32UpdateCRC (c, crc);
			   if ((c = Z_GetZDL ()) & ~0xFF)
				  goto CRCfoo;

			   crc = Z_32UpdateCRC (c, crc);
			   if (crc != 0xDEBB20E3UL)
				  {
				  z_message (msgtxt[M_CRC_MSG]);
				  return ERROR;
				  }

			   RxCount = length - (endpos - buf);
			   return d;

			case GOTCAN:
			   /*-----------------------------------*/
			   /* Cancel							*/
			   /*-----------------------------------*/
			   z_log (msgtxt[M_CAN_MSG]);
			   return ZCAN;

			case TIMEOUT:
			   /*-----------------------------------*/
			   /* Timeout							*/
			   /*-----------------------------------*/
			   z_message (msgtxt[M_TIMEOUT]);
			   return c;

			case RCDO:
			   /*-----------------------------------*/
			   /* No carrier						*/
			   /*-----------------------------------*/
			   z_log (msgtxt[M_NO_CARRIER]);
			   CLEAR_INBOUND ();
			   return c;

			default:
			   /*-----------------------------------*/
			   /* Something bizarre 				*/
			   /*-----------------------------------*/
			   z_message (msgtxt[M_DEBRIS]);
			   CLEAR_INBOUND ();
			   return c;
			}									 /* switch */
		 }										 /* if */

	  *buf++ = (unsigned char) c;
	  crc = Z_32UpdateCRC (c, crc);
	  } 										 /* while(1) */

   z_message (msgtxt[M_LONG_PACKET]);
   return ERROR;
}												 /* RZ_ReceiveData */

/*--------------------------------------------------------------------------*/
/* RZ INIT RECEIVER 														*/
/* Initialize for Zmodem receive attempt, try to activate Zmodem sender 	*/
/* Handles ZSINIT, ZFREECNT, and ZCOMMAND frames							*/
/*																			*/
/* Return codes:															*/
/*	  ZFILE .... Zmodem filename received									*/
/*	  ZCOMPL ... transaction finished										*/
/*	  ERROR .... any other condition										*/
/*--------------------------------------------------------------------------*/
static int RZ_InitReceiver( void )
{
   register int n;
   int errors = 0;
   char *sptr;


#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("RZ_InitReceiver");
#endif

   for (n = 12; --n >= 0;)
	  {
	  /*--------------------------------------------------------------*/
	  /* Set buffer length (0=unlimited, don't wait).				  */
	  /* Also set capability flags									  */
	  /*--------------------------------------------------------------*/
	  Z_PutLongIntoHeader (0L);
	  Txhdr[ZF0] = CANFC32 | CANFDX | CANOVIO;
	  Z_SendHexHeader (Tryzhdrtype, Txhdr);
	  if (Tryzhdrtype == ZSKIP)
		 Tryzhdrtype = ZRINIT;

AGAIN:

	  switch (Z_GetHeader (Rxhdr))
		 {
		 case ZFILE:
			Zconv = Rxhdr[ZF0];
			Tryzhdrtype = ZRINIT;
			if (RZ_ReceiveData (Secbuf, WAZOOMAX) == GOTCRCW)
			   return ZFILE;
			Z_SendHexHeader (ZNAK, Txhdr);
			if (--n < 0)
			   {
			   sptr = "ZFILE";
			   goto Err;
			   }
			goto AGAIN;

		 case ZSINIT:
			if (RZ_ReceiveData (Attn, ZATTNLEN) == GOTCRCW)
			   {
			   Z_PutLongIntoHeader (1L);
			   Z_SendHexHeader (ZACK, Txhdr);
			   }
			else Z_SendHexHeader (ZNAK, Txhdr);
			if (--n < 0)
			   {
			   sptr = "ZSINIT";
			   goto Err;
			   }
			goto AGAIN;

		 case ZFREECNT:
			Z_PutLongIntoHeader (DiskAvail);
			Z_SendHexHeader (ZACK, Txhdr);
			goto AGAIN;

		 case ZCOMMAND:
			/*-----------------------------------------*/
			/* Paranoia is good for you...			   */
			/* Ignore command from remote, but lie and */
			/* say we did the command ok.			   */
			/*-----------------------------------------*/
			if (RZ_ReceiveData (Secbuf, WAZOOMAX) == GOTCRCW)
			   {
			   status_line (msgtxt[M_Z_IGNORING], Secbuf);
			   Z_PutLongIntoHeader (0L);
			   do
				  {
				  Z_SendHexHeader (ZCOMPL, Txhdr);
				  }
			   while (++errors < 10 && Z_GetHeader (Rxhdr) != ZFIN);
			   RZ_AckBibi ();
			   return ZCOMPL;
			   }
			else Z_SendHexHeader (ZNAK, Txhdr);
			if (--n < 0)
			   {
			   sptr = "CMD";
			   goto Err;
			   }
			goto AGAIN;

		 case ZCOMPL:
			if (--n < 0)
			   {
			   sptr = "COMPL";
			   goto Err;
			   }
			goto AGAIN;

		 case ZFIN:
			RZ_AckBibi ();
			return ZCOMPL;

		 case ZCAN:
			sptr = msgtxt[M_CAN_MSG];
			goto Err;

		 case RCDO:
			sptr = &(msgtxt[M_NO_CARRIER][1]);
			CLEAR_INBOUND ();
			goto Err;
		 }										 /* switch */
	  } 										 /* for */

   sptr = msgtxt[M_TIMEOUT];

Err:
   sprintf (e_input, msgtxt[M_Z_INITRECV], sptr);
   z_log (e_input);

   return ERROR;
}												 /* RZ_InitReceiver */

/*--------------------------------------------------------------------------*/
/* RZFILES																	*/
/* Receive a batch of files using ZMODEM protocol							*/
/*--------------------------------------------------------------------------*/
static int RZ_ReceiveBatch( FILE *xferinfo )
{
   register int c;
   byte namebuf[PATHLEN];


#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("RZ_ReceiveBatch");
#endif

   while (1)
	  {
	  switch (c = RZ_ReceiveFile (xferinfo))
		 {
		 case ZEOF:
			if (Resume_WaZOO)
			   {
					remove_abort (Abortlog_name, Resume_name);
			   strcpy (namebuf, Upload_path);
			   strcat (namebuf, Resume_name);
			   unique_name (namebuf);
			   rename (Filename, namebuf);
			   }
			/* fallthrough */
		 case ZSKIP:
			switch (RZ_InitReceiver ())
			   {
			   case ZCOMPL:
				  return OK;
			   default:
				  return ERROR;
			   case ZFILE:
				  break;
			   }								 /* switch */
			break;

		 default:
			fclose (Outfile);
			Outfile = NULL;
			if (remote_capabilities)
			   {
			   if (!Resume_WaZOO)
				  {
						add_abort (Abortlog_name, Resume_name, Filename, Upload_path, Resume_info);
				  }
			   }
			else unlink (Filename);
			return c;
		 }										 /* switch */
	  } 										 /* while */
}												 /* RZ_ReceiveBatch */

/*--------------------------------------------------------------------------*/
/* RZ RECEIVE FILE															*/
/* Receive one file; assumes file name frame is preloaded in Secbuf 		*/
/*--------------------------------------------------------------------------*/
static int RZ_ReceiveFile( FILE *xferinfo )
{
   register int c;
   int n;
   long rxbytes;
   char *sptr;
   struct utimbuf utimes;
   char j[50];


#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("RZ_ReceiveFile");
#endif

   EOFseen = FALSE;
   c = RZ_GetHeader ();
   if (c == ERROR || c == ZSKIP)
	  return (Tryzhdrtype = ZSKIP);

   n = 10;
   rxbytes = Filestart;

   while (1)
	  {
	  Z_PutLongIntoHeader (rxbytes);
	  Z_SendHexHeader (ZRPOS, Txhdr);
NxtHdr:
	  switch (c = Z_GetHeader (Rxhdr))
		 {
		 case ZDATA:
			/*-----------------------------------------*/
			/* Data Packet							   */
			/*-----------------------------------------*/
			if (Rxpos != rxbytes)
			   {
			   if (--n < 0)
				  {
				  sptr = msgtxt[M_FUBAR_MSG];
				  goto Err;
				  }
			   sprintf (j, "%s; %ld/%ld", msgtxt[M_BAD_POS], rxbytes, Rxpos);
			   z_message (j);
			   Z_PutString (Attn);
			   continue;
			   }
	  MoreData:
			switch (c = RZ_ReceiveData (Secbuf, WAZOOMAX))
			   {
			   case ZCAN:
				  sptr = msgtxt[M_CAN_MSG];
				  goto Err;

			   case RCDO:
				  sptr = &(msgtxt[M_NO_CARRIER][1]);
				  CLEAR_INBOUND ();
				  goto Err;

			   case ERROR:
				  /*-----------------------*/
				  /* CRC error			   */
				  /*-----------------------*/
				  if (--n < 0)
					 {
					 sptr = msgtxt[M_FUBAR_MSG];
					 goto Err;
					 }
				  show_loc (rxbytes, n);
				  Z_PutString (Attn);
				  continue;

			   case TIMEOUT:
				  if (--n < 0)
					 {
					 sptr = msgtxt[M_TIMEOUT];
					 goto Err;
					 }
				  show_loc (rxbytes, n);
				  continue;

			   case GOTCRCW:
				  /*---------------------*/
				  /* End of frame		   */
				  /*-----------------------*/
				  n = 10;
				  if (RZ_SaveToDisk (&rxbytes) == ERROR)
					 return ERROR;
				  Z_PutLongIntoHeader (rxbytes);
				  Z_SendHexHeader (ZACK, Txhdr);
				  goto NxtHdr;

			   case GOTCRCQ:
				  /*---------------------*/
				  /* Zack expected		   */
				  /*-----------------------*/
				  n = 10;
				  if (RZ_SaveToDisk (&rxbytes) == ERROR)
					 return ERROR;
				  Z_PutLongIntoHeader (rxbytes);
				  Z_SendHexHeader (ZACK, Txhdr);
				  goto MoreData;

			   case GOTCRCG:
				  /*---------------------*/
				  /* Non-stop			   */
				  /*-----------------------*/
				  n = 10;
				  if (RZ_SaveToDisk (&rxbytes) == ERROR)
					 return ERROR;
				  goto MoreData;

			   case GOTCRCE:
				  /*---------------------*/
				  /* Header to follow	   */
				  /*-----------------------*/
				  n = 10;
				  if (RZ_SaveToDisk (&rxbytes) == ERROR)
					 return ERROR;
				  goto NxtHdr;
			   }								 /* switch */

		 case ZNAK:
		 case TIMEOUT:
			/*-----------------------------------------*/
			/* Packet was probably garbled			   */
			/*-----------------------------------------*/
			if (--n < 0)
			   {
			   sptr = msgtxt[M_JUNK_BLOCK];
			   goto Err;
			   }
			show_loc (rxbytes, n);
			continue;

		 case ZFILE:
			/*-----------------------------------------*/
			/* Sender didn't see our ZRPOS yet		   */
			/*-----------------------------------------*/
			RZ_ReceiveData (Secbuf, WAZOOMAX);
			continue;

		 case ZEOF:
			/*-----------------------------------------*/
			/* End of the file						   */
			/* Ignore EOF if it's at wrong place; force */
			/* a timeout because the eof might have    */
			/* gone out before we sent our ZRPOS	   */
			/*-----------------------------------------*/
			if (locate_y && !(fullscreen && un_attended))
			   gotoxy (2, (byte) locate_y - 1);
			if (Rxpos != rxbytes)
			   goto NxtHdr;

			throughput (2, rxbytes - Filestart);

			fclose (Outfile);

			status_line ("%s-Z%s %s", msgtxt[M_FILE_RECEIVED], Crc32 ? "/32" : "", realname);

			update_files (0);

			if (filetime)
			   {
			   utimes.actime = filetime;
			   utimes.modtime = filetime;
			   utime (Filename, &utimes);
			   }

			Outfile = NULL;
			if (xferinfo != NULL)
			   {
			   fprintf (xferinfo, "%s\n", Filename);
			   }
			return c;

		 case ERROR:
			/*-----------------------------------------*/
			/* Too much garbage in header search error */
			/*-----------------------------------------*/
			if (--n < 0)
			   {
			   sptr = msgtxt[M_JUNK_BLOCK];
			   goto Err;
			   }
			show_loc (rxbytes, n);
			Z_PutString (Attn);
			continue;

		 case ZSKIP:
			return c;

		 default:
			sptr = IDUNNO_msg;
			CLEAR_INBOUND ();
			goto Err;
		 }										 /* switch */
	  } 										 /* while */

Err:sprintf (e_input, msgtxt[M_Z_RZ], sptr);
   z_log (e_input);
   return ERROR;
}												 /* RZ_ReceiveFile */

/*--------------------------------------------------------------------------*/
/* RZ GET HEADER															*/
/* Process incoming file information header 								*/
/*--------------------------------------------------------------------------*/
static int RZ_GetHeader( void )
{
   register byte *p;
   struct stat f;
   size_t i;
   byte *ourname;
   byte *theirname;
   unsigned long filesize;
   byte *fileinfo;
   char j[80];


#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("RZ_GetHeader");
#endif

   /*--------------------------------------------------------------------*/
   /* Setup the transfer mode											 */
   /*--------------------------------------------------------------------*/
   isBinary = (char) ((!RXBINARY && Zconv == ZCNL) ? 0 : 1);
   Resume_WaZOO = 0;

   /*--------------------------------------------------------------------*/
   /* Extract and verify filesize, if given.							 */
   /* Reject file if not at least 10K free								 */
   /*--------------------------------------------------------------------*/
   filesize = 0L;
   filetime = 0L;
   fileinfo = Secbuf + 1 + strlen (Secbuf);
   if (*fileinfo)
	  sscanf (fileinfo, "%ld %lo", &filesize, &filetime);
   if (filesize + 10240 > DiskAvail)
	  {
	  status_line (msgtxt[M_OUT_OF_DISK_SPACE]);
	  return ERROR;
	  }

   /*--------------------------------------------------------------------*/
   /* Get and/or fix filename for uploaded file 						 */
   /*--------------------------------------------------------------------*/
   p = Filename + strlen (Filename) - 1;		 /* Find end of upload path */
   while (p >= Filename && *p != '\\')
	  p--;
   ourname = ++p;

   p = Secbuf + strlen (Secbuf) - 1;			 /* Find transmitted simple
												  * filename */
   while (p >= Secbuf && *p != '\\' && *p != '/' && *p != ':')
	  p--;
   theirname = ++p;

   strcpy (ourname, theirname); 				 /* Start w/ our path & their
												  * name */
   strcpy (realname, Filename);

   /*--------------------------------------------------------------------*/
   /* Save info on WaZOO transfer in case of abort						 */
   /*--------------------------------------------------------------------*/
   if (remote_capabilities)
	  {
	  strcpy (Resume_name, theirname);
	  sprintf (Resume_info, "%ld %lo", filesize, filetime);
	  }

   /*--------------------------------------------------------------------*/
   /* Check if this is a failed WaZOO transfer which should be resumed	 */
   /*--------------------------------------------------------------------*/
   if (remote_capabilities && dexists (Abortlog_name))
	  {
		Resume_WaZOO = (byte) check_failed (Abortlog_name, theirname, Resume_info, ourname);
	  }

   /*--------------------------------------------------------------------*/
   /* Open either the old or a new file, as appropriate 				 */
   /*--------------------------------------------------------------------*/
   if (Resume_WaZOO)
	  {
	  if (dexists (Filename))
		 p = "r+b";
	  else p = write_binary;
	  }
   else
	  {
	  strcpy (ourname, theirname);
	  /*--------------------------------------------------------------------*/
	  /* If the file already exists:										*/
	  /* 1) And the new file has the same time and size, return ZSKIP	 */
	  /* 2) And OVERWRITE is turned on, delete the old copy 			 */
	  /* 3) Else create a unique file name in which to store new data	 */
	  /*--------------------------------------------------------------------*/
	  if (dexists (Filename))
		 {										 /* If file already exists...	   */
		 if ((Outfile = fopen (Filename, read_binary)) == NULL)
			{
			(void) got_error (msgtxt[M_OPEN_MSG], Filename);
			return ERROR;
			}
#ifdef ATARIST
		 stat(Filename, &f);
#else		 
		 fstat (fileno (Outfile), &f);
#endif
		 fclose (Outfile);
		 if (filesize == f.st_size && filetime == f.st_mtime)
			{
			status_line (msgtxt[M_ALREADY_HAVE], Filename);
			return ZSKIP;
			}
		 i = strlen (Filename) - 1;

		/* DONTRENAMEREQ  09.09.1990 */
         if ((Filename[i-2] == 'R') && (Filename[i-1] == 'E') && (Filename[i] == 'Q'))
            {
            unlink (Filename);
            }
         else
		 if ((!overwrite) || (is_arcmail (Filename, i)))
			{
			unique_name (Filename);
			}
		 else
			{
			unlink (Filename);
			}
		 }										 /* if exist */

	  if (strcmp (ourname, theirname))
		 {
		 status_line (msgtxt[M_RENAME_MSG], ourname);
		 }
	  p = write_binary;
	  }
   if ((Outfile = fopen (Filename, p)) == NULL)
	  {
	  (void) got_error (msgtxt[M_OPEN_MSG], Filename);
	  return ERROR;
	  }
   if (isatty (fileno (Outfile)))
	  {
	  errno = 1;
	  (void) got_error (msgtxt[M_DEVICE_MSG], Filename);
	  fclose (Outfile);
	  return (ERROR);
	  }

   Filestart = (Resume_WaZOO) ? filelength (fileno (Outfile)) : 0L;
   if (Resume_WaZOO)
	  status_line (msgtxt[M_SYNCHRONIZING_OFFSET], Filestart);
   fseek (Outfile, Filestart, SEEK_SET);

   if (remote_capabilities)
		p = check_netfile(theirname);
   else p = NULL;

   sprintf (j, "%s %s; %s%ldb, %d min.",
			(p) ? p : msgtxt[M_RECEIVING],
			realname,
			(isBinary) ? "" : "ASCII ",
			filesize,
			(int) ((filesize - Filestart) * 10 / cur_baud + 53) / 54);

   file_length = filesize;

   if (un_attended && fullscreen)
	  {
	  clear_filetransfer ();
	  sb_move (filewin, 1, 2);
	  sb_puts (filewin, j);
	  elapse_time ();
	  sb_move (filewin, 2, 69);
	  sprintf(j, "%3d min", (int) (filesize * 10 / cur_baud + 53) / 54);
	  sb_puts (filewin, j);
	  sb_show ();
	  }
   else
	  {
	  set_xy (j);
	  set_xy (NULL);
	  locate_x += 2;
	  }

   throughput (0, 0L);

   return OK;
}												 /* RZ_GetHeader */

/*--------------------------------------------------------------------------*/
/* RZ SAVE TO DISK															*/
/* Writes the received file data to the output file.						*/
/* If in ASCII mode, stops writing at first ^Z, and converts all			*/
/*	 solo CR's or LF's to CR/LF pairs.										*/
/*--------------------------------------------------------------------------*/
static int RZ_SaveToDisk( unsigned long *rxbytes )
{
   static byte lastsent;

   register byte *p;
   register size_t count;
   int i;
   char j[100];

#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("RZ_SaveToDisk");
#endif

   count = RxCount;

   if (got_ESC ())
	  {
	  send_can ();								 /* Cancel file */
	  while ((i = Z_GetByte (20)) != TIMEOUT && i != RCDO)		/* Wait for line to
																 * clear */
		 CLEAR_INBOUND ();
	  send_can ();								 /* and Cancel Batch */
	  z_log (msgtxt[M_KBD_MSG]);
	  return ERROR;
	  }

   if (count != z_size)
	  {
	  if (fullscreen && un_attended)
		 {
		 sb_move (filewin, 2, 12);
		 sb_puts (filewin, ultoa (((unsigned long) (z_size = count)), e_input, 10));
         sb_puts (filewin, "    ");
		 elapse_time ();
		 sb_show ();
		 }
	  else
		 {
		 gotoxy (locate_x + 10, locate_y);
		 cputs (ultoa (((unsigned long) (z_size = count)), e_input, 10));
		 putch (' ');
		 }
	  }

   if (isBinary)
	  {
	  if (fwrite (Secbuf, 1, count, Outfile) != count)
		 goto oops;
	  }
   else
	  {
	  if (EOFseen)
		 return OK;
	  for (p = Secbuf; count--; ++p)
		 {
		 if (*p == CPMEOF)
			{
			EOFseen = TRUE;
			return OK;
			}
		 if (*p == '\n')
			{
			if (lastsent != '\r' && putc ('\r', Outfile) == EOF)
			   goto oops;
			}
		 else
			{
			if (lastsent == '\r' && putc ('\n', Outfile) == EOF)
			   goto oops;
			}
		 if (putc ((lastsent = *p), Outfile) == EOF)
			goto oops;
		 }
	  }

   *rxbytes += RxCount;
   i = (int) ((file_length - *rxbytes)* 10 / cur_baud + 53) / 54;
   sprintf (j, "%3d min", i);


   if (fullscreen && un_attended)
	  {
	  elapse_time();
	  sb_move (filewin, 2, 2);
	  sb_puts (filewin, ultoa (((unsigned long) (*rxbytes)), e_input, 10));
	  sb_move (filewin, 2, 69);
	  sb_puts (filewin, j);
	  elapse_time ();
	  sb_show ();
	  }
   else
	  {
	  gotoxy (locate_x, locate_y);
	  cputs (ultoa (((unsigned long) (*rxbytes)), e_input, 10));
	  gotoxy (locate_x + 20, locate_y);
	  printf ("%s", j);
	  putch (' ');
	  }
   return OK;

oops:
   got_error (msgtxt[M_WRITE_MSG], Filename);
   return ERROR;

}												 /* RZ_SaveToDisk */

/*--------------------------------------------------------------------------*/
/* RZ ACK BIBI																*/
/* Ack a ZFIN packet, let byegones be byegones								*/
/*--------------------------------------------------------------------------*/
static void RZ_AckBibi( void )
{
   register int n;


#ifdef ZDEBUG
   if(debugging_log)
   		show_debug_name ("RZ_AckBiBi");
#endif
	CLEAR_OUTBOUND();
	CLEAR_INBOUND();

   Z_PutLongIntoHeader (0L);
   for (n = 4; --n;)
	  {
	  Z_SendHexHeader (ZFIN, Txhdr);
	  switch (Z_GetByte (100))
		 {
		 case 'O':
			Z_GetByte (1);						 /* Discard 2nd 'O' */

		 case TIMEOUT:
		 case RCDO:
			return;
		 }										 /* switch */
	  } 										 /* for */
}												 /* RZ_AckBibi */
