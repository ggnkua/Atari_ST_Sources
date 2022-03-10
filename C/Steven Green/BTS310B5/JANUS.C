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
/*					BinkleyTerm Janus revision 0.31, 11- 2-89				*/
/*					 Full-duplex WaZOO file transfer protocol				*/
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

/* Do NOT entab this file since it contains quoted spaces */

/*
 * NB, Several uninitialised auto variable warnings occur in this file
 * I will assume it is nothing to worry about
 * - STeVeN 2:255/355 [Atari ST port]
 */

#ifdef __TOS__
/* #pragma warn -def */
/* #pragma warn -rch */
#endif

#define  WAZOO_SECTION
#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>
#endif
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#ifndef LATTICE
#include <io.h>
#endif
#include <conio.h>
#include <stdlib.h>

#ifdef __TURBOC__
#include "tc_utime.h"
#ifndef __TOS__
#include <alloc.h>
#endif
#else
#ifdef LATTICE
#include <errno.h>
#include <utime.h>
#else
#include <sys/utime.h>
#include <malloc.h>
#endif
#endif

#ifndef IBM_C
extern int _fmode;
#endif

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "vfossil.h"
#include "janus.h"
#include "zmodem.h"
#include "wazoo.h"
#include "defines.h"
#include "session.h"
#include "password.h"

/* #undef DEBUG */

/* Private routines */
static void getfname(word);
static void sendpkt(register byte *,size_t,int);
static void sendpkt32(register byte *,register size_t,int);
static void txbyte(register byte);
static long procfname(void);
static byte rcvpkt(void);
static void rxclose(word);
static void endbatch(void);
static void j_message(word,char *,...);
static void j_status(char *,...);
static int j_error(byte *,byte *);
static void update_y(void);
static void long_set_timer(long *,word);
static int long_time_gone(long *);
static int rcvrawbyte(void);
static int rxbyte(void);
static void xfer_summary(char *,char *,long *,int);
static void update_status(long *,long *,long,int *,int);
static void through(long *,long *);
static int get_filereq(byte);
static int record_reqfile(char *);
static byte get_reqname(byte);
static void mark_done(char *);



/* Private data. I know, proper software design says you shouldn't make data */
/* global unless you really need to.  In this case speed and code size make  */
/* it more important to avoid constantly pushing & popping arguments.		 */
 /* [don't worry about it, at least you've made them static! - STeVeN] */

static byte *GenericError = "!%s";
static byte *ReqTmp = "JANUSREQ.TMP";
#ifdef OS_2
static byte Upload_path[PATHLEN];	/* Dest. path of file being
									 * received   */
#endif
static byte *Rxbuf; 	  /* Address of packet reception buffer 			 */
static char *Txfname;	  /* Full path of file we're sending				 */
static char *Rxfname;	  /* Full path of file we're receiving				 */
static byte *Rxbufptr;	  /* Current position within packet reception buffer */
static byte *Rxbufmax;	  /* Upper bound of packet reception buffer 		 */
static byte Do_after;	  /* What to do with file being sent when we're done */
static byte WaitFlag;	  /* Tells rcvrawbyte() whether or not to wait		 */
static byte SharedCap;	  /* Capability bits both sides have in common		 */
static int Txfile;		  /* File handle of file we're sending				 */
static int Rxfile;		  /* File handle of file we're receiving			 */
static int ReqRecorded;   /* Number of files obtained by this request		 */
static word TimeoutSecs;  /* How long to wait for various things			 */
static size_t Rxblklen;	  /* Length of data in last data block packet recvd  */
static word Next_y; 	  /* Number of next available line on screen		 */
static word Tx_y;		  /* Line number of file transmission status display */
static word Rx_y;		  /* Line number of file reception status display	 */
static long Txlen;		  /* Total length of file we're sending 			 */
static long Rxlen;		  /* Total length of file we're receiving			 */
static long Rxfiletime;   /* Timestamp of file we're receiving				 */
static long Diskavail;	  /* Bytes available in upload directory			 */
static long TotalBytes;   /* Total bytes xferred in this session			 */
static long Txsttime;	  /* Time at which we started sending current file	 */
static long Rxsttime;	  /* Time at which we started receiving current file */

static ADDR_LIST *ad_list;

char ext_HC[] = "HC";
char ext_HCD[] = "HCD";
char ext_OHCD[] = "OHCD";

/*****************************************************************************/
/* Super-duper neato-whizbang full-duplex streaming ACKless batch file		 */
/* transfer protocol for use in WaZOO mail sessions 						 */
/*****************************************************************************/

void Janus(void)
{
   byte xstate; 		  /* Current file transmission state				 */
   byte rstate; 		  /* Current file reception state					 */
   byte pkttype;		  /* Type of packet last received					 */
   byte tx_inhibit; 	  /* Flag to wait and send after done receiving 	 */
   byte *holdname;		  /* Name of hold area								 */
#ifdef OS_2
   byte *p; 			  /* Temporary pointer								 */
#endif
   byte fsent;			  /* Did we manage to send anything this session?	 */
   byte sending_req;	  /* Are we currently sending requested files?		 */
   byte attempting_req;   /* Are we waiting for the sender to start our req? */
   byte req_started;	  /* Has the sender started servicing our request?	 */
   int txoldeta;		  /* Last transmission ETA displayed				 */
   int rxoldeta;		  /* Last reception ETA displayed					 */
   size_t blklen;		  /* Length of last data block sent 				 */
   size_t txblklen;		  /* Size of data block to try to send this time	 */
   size_t txblkmax;		  /* Max size of data block to send at this speed	 */
   size_t goodneeded;	  /* # good bytes to send before upping txblklen	 */
   size_t goodbytes;	  /* Number of good bytes sent at this block size	 */
   word rpos_count; 	  /* Number of RPOS packets sent at this position	 */
   long xmit_retry; 	  /* Time to retransmit lost FNAMEPKT or EOF packet  */
   long txpos = 0;		  /* Current position within file we're sending 	 */
   long lasttx = 0L;	  /* Position within file of last data block we sent */
   long starttime;		  /* Time at which we started this Janus session	 */
   long txstpos;		  /* Initial data position of file we're sending	 */
   long rxstpos = 0L;	  /* Initial data position of file we're receiving	 */
   long txoldpos;		  /* Last transmission file position displayed		 */
   long rxoldpos;		  /* Last reception file position displayed 		 */
   long rpos_retry; 	  /* Time at which to retry RPOS packet 			 */
   long brain_dead; 	  /* Time at which to give up on other computer 	 */
   long rpos_sttime;	  /* Time at which we started current RPOS sequence  */
   long last_rpostime;	  /* Timetag of last RPOS which we performed		 */
   long last_blkpos = 0L; /* File position of last out-of-sequence BLKPKT	 */
   FILE *reqfile;		  /* File handle for .REQ file						 */


   set_prior(3);		  /* Time Critical									 */
   XON_DISABLE();
   if (un_attended && fullscreen)
   {
	  clear_filetransfer();
	  sb_show();
   }
   else
   {
	  set_xy(NULL);
	  Next_y = locate_y;
   }
   Tx_y = Rx_y = 0;
   SharedCap = 0;
   TotalBytes = 0;
   time(&starttime);

   /*------------------------------------------------------------------------*/
   /* Allocate memory														 */
   /*------------------------------------------------------------------------*/
   Rxbuf = Txbuf + 4096 + 8;
   Txfname = Rxfname = NULL;
   if (!(Txfname = malloc(PATHLEN)) || !(Rxfname = malloc(PATHLEN)))
   {
	  status_line(msgtxt[M_MEM_ERROR]);
	  mdm_hangup();
	  goto freemem;
   }
   Rxbufmax = Rxbuf + BUFMAX + 8;

   /*------------------------------------------------------------------------*/
   /* Initialize file transmission variables								 */
   /*------------------------------------------------------------------------*/

   doing_janus = TRUE;
   tx_inhibit = FALSE;
   last_rpostime = xmit_retry = 0L;
   TimeoutSecs = (unsigned int)(40960 / cur_baud);
   if (TimeoutSecs < 10)
	  TimeoutSecs = 10;
   long_set_timer(&brain_dead,120);
   txblkmax = cur_baud/300 * 128;
   if (txblkmax > BUFMAX)
	  txblkmax = BUFMAX;
   txblklen = txblkmax;
   goodbytes = goodneeded = 0;
   Txfile = -1;
   sending_req = fsent = FALSE;
   xstate = XSENDFNAME;
   getfname(INITIAL_XFER);

   /*------------------------------------------------------------------------*/
   /* Initialize file reception variables									 */
   /*------------------------------------------------------------------------*/


   holdname = HoldAreaNameMunge(&called_addr);
#ifdef IOS
	if(iosmode)
	   sprintf(Abortlog_name,"%s%s.Z\0", holdname, Addr36(&called_addr));
	else
#endif
	   sprintf(Abortlog_name,"%s%s.Z\0",holdname,Hex_Addr_Str(&called_addr));

/* Sorry, this don't cut in OS/2's zfree */
#ifdef OS_2
   p = strchr(strcpy (Upload_path, CurrentNetFiles),'\0') - 1;
   while (p >= Upload_path && *p != '\\')
	  --p;
   *(++p) = '\0';
   if ((Diskavail = zfree(Upload_path)) <= 0L)
	  Diskavail = 0x7FFFFFF;
#else
   Diskavail = (CurrentNetFiles[1] == ':') ? zfree(CurrentNetFiles) : 0x7FFFFFFF;
#endif
   Rxbufptr = NULL;
   rpos_retry = rpos_count = 0;
   attempting_req = req_started = FALSE;
   rstate = RRCVFNAME;

   /*------------------------------------------------------------------------*/
   /* Send and/or receive stuff until we're done with both					 */
   /*------------------------------------------------------------------------*/
   do { 										 /* while (xstate || rstate) */

#ifdef DEBUG
		j_status(">@mainloop rxpos=%ld txpos=%ld", Rxpos, txpos);
#endif

	  /*---------------------------------------------------------------------*/
	  /* If nothing useful (i.e. sending or receiving good data block) has	 */
	  /* happened within the last 2 minutes, give up in disgust 			 */
	  /*---------------------------------------------------------------------*/
	  if (long_time_gone(&brain_dead)) {
		 j_status(msgtxt[M_OTHER_DIED]);		   /* "He's dead, Jim." */
		 goto giveup;
	  }

	  /*---------------------------------------------------------------------*/
	  /* If we're tired of waiting for an ACK, try again					 */
	  /*---------------------------------------------------------------------*/
	  if (xmit_retry) {
#ifdef DEBUG
		 j_status(">?xmit_retry, xstate=%d", xstate);
#endif
		 if (long_time_gone(&xmit_retry)) {
			j_message(Tx_y,msgtxt[M_TIMEOUT]);
			xmit_retry = 0L;

			switch (xstate) {
			   case XRCVFNACK:
				  xstate = XSENDFNAME;
				  break;
			   case XRCVFRNAKACK:
				  xstate = XSENDFREQNAK;
				  break;
			   case XRCVEOFACK:
				  errno = 0;
				  lseek(Txfile, txpos=lasttx, SEEK_SET);
				  if (j_error(msgtxt[M_SEEK_MSG],Txfname))
					 goto giveup;
				  xstate = XSENDBLK;
				  break;
			}
		 }
	  }

	  /*---------------------------------------------------------------------*/
	  /* Transmit next part of file, if any 								 */
	  /*---------------------------------------------------------------------*/
	  /* Only do this when the buffer is empty */
#ifdef ATARIST
	  if(!slowjanus || OUT_EMPTY())
#endif
#ifdef DEBUG
		j_status(">#txloop: state=%d txpos=%ld lasttx=%ld", xstate, txpos, lasttx);
#endif
		switch (xstate) {
		 case XSENDBLK:
			if (tx_inhibit)
			   break;
#ifdef GENERIC
			lasttx = txpos;
			Txbuf[0] = txpos & 0xff;
			Txbuf[1] = (txpos >> 8) & 0xff;
			Txbuf[2] = (txpos >> 16) & 0xff;
			Txbuf[3] = (txpos >> 24) & 0xff;
#else
			*((long *)Txbuf) = lasttx = txpos;
#endif			
			errno = 0;
			blklen = read(Txfile, Txbuf+sizeof(txpos), txblklen);
			if (j_error(msgtxt[M_READ_MSG],Txfname))
			   goto giveup;
			txpos += blklen;
			sendpkt(Txbuf, sizeof(txpos)+blklen, BLKPKT);
			update_status(&txpos,&txoldpos,Txlen-txpos,&txoldeta,Tx_y);
			fsent = TRUE;
			if (txpos >= Txlen || blklen < txblklen) {
			   long_set_timer(&xmit_retry,TimeoutSecs);
			   xstate = XRCVEOFACK;
			} else
			   long_set_timer(&brain_dead,120);

			if (txblklen < txblkmax && (goodbytes+=txblklen) >= goodneeded) {
			   txblklen <<= 1;
			   goodbytes = 0;
			}
			break;

		 case XSENDFNAME:
			blklen = strchr( strchr(Txbuf,'\0')+1, '\0') - Txbuf + 1;
			Txbuf[blklen++] = OURCAP;
			sendpkt(Txbuf,blklen,FNAMEPKT);
			txoldpos = txoldeta = -1;
			long_set_timer(&xmit_retry,TimeoutSecs);
			xstate = XRCVFNACK;
			break;

		 case XSENDFREQNAK:
			sendpkt(NULL,0,FREQNAKPKT);
			long_set_timer(&xmit_retry,TimeoutSecs);
			xstate = XRCVFRNAKACK;
			break;
	  }

	  /*---------------------------------------------------------------------*/
	  /* Catch up on our reading; receive and handle all outstanding packets */
	  /*---------------------------------------------------------------------*/
	  while (pkttype = rcvpkt()) {
#ifdef DEBUG
		j_status(">~Rxloop: pkttype=%d last=%ld Rxpos=%ld", pkttype, last_blkpos, Rxpos);
#endif
		 if (pkttype != BADPKT)
			long_set_timer(&brain_dead,120);
		 switch (pkttype) {

			/*---------------------------------------------------------------*/
			/* File data block or munged block								 */
			/*---------------------------------------------------------------*/
			case BADPKT:
			case BLKPKT:
			   if (rstate == RRCVBLK) {
				  long t;
#ifdef GENERIC
				  t = (long)Rxbuf[0] + ((long)Rxbuf[1] << 8) + ((long)Rxbuf[2] << 16) + ((long)Rxbuf[3] << 24);
#else
				  t = *(long *)Rxbuf;
#endif
				  if((pkttype == BADPKT) || (t != Rxpos)) {
					 if (pkttype == BLKPKT) {
						if (t < last_blkpos)
						   rpos_retry = rpos_count = 0;
						last_blkpos = t;
					 }
					 if (long_time_gone(&rpos_retry)) {
						/* If we're the called machine, and we're trying
						   to send stuff, and it seems to be screwing up
						   our ability to receive stuff, maybe this
						   connection just can't hack full-duplex.	Try
						   waiting till the sending system finishes before
						   sending our stuff to it */
						if (rpos_count > 4) {
						   if (xstate && !isOriginator && !tx_inhibit) {
							  tx_inhibit = TRUE;
							  j_status(msgtxt[M_GOING_ONE_WAY]);
						   }
						   rpos_count = 0;
						}
						if (++rpos_count == 1)
						   time(&rpos_sttime);
						j_message(Rx_y,msgtxt[M_J_BAD_PACKET],Rxpos);

#ifdef GENERIC
						Rxbuf[0] = Rxpos & 0xff;
						Rxbuf[1] = (Rxpos >> 8) & 0xff;
						Rxbuf[2] = (Rxpos >> 16) & 0xff;
						Rxbuf[3] = (Rxpos >> 24) & 0xff;
						Rxbuf[4] = rpos_sttime & 0xff;
						Rxbuf[5] = (rpos_sttime >> 8) & 0xff;
						Rxbuf[6] = (rpos_sttime >> 16) & 0xff;
						Rxbuf[7] = (rpos_sttime >> 24) & 0xff;
#else
						*((long *)Rxbuf) = Rxpos;
						*((long *)(Rxbuf + sizeof(Rxpos))) = rpos_sttime;
#endif
						sendpkt(Rxbuf, sizeof(Rxpos)+sizeof(rpos_sttime), RPOSPKT);
						long_set_timer(&rpos_retry,TimeoutSecs/2);
					 }
				  } else {
					 last_blkpos = Rxpos;
					 rpos_retry = rpos_count = 0;
					 errno = 0;
					 write(Rxfile, Rxbuf+sizeof(Rxpos), Rxblklen -= sizeof(Rxpos));
					 if (j_error(msgtxt[M_WRITE_MSG],Rxfname))
						goto giveup;
					 Diskavail -= Rxblklen;
					 Rxpos += Rxblklen;
					 update_status(&Rxpos,&rxoldpos,Rxlen-Rxpos,&rxoldeta,Rx_y);
					 if (Rxpos >= Rxlen) {
						rxclose(GOOD_XFER);
						Rxlen -= rxstpos;
						through(&Rxlen,&Rxsttime);
						j_status("%s-J%s %s",msgtxt[M_FILE_RECEIVED], (SharedCap&CANCRC32)?"/32":" ",Rxfname);
						update_files(0);
						rstate = RRCVFNAME;
					 }
				  }
			   }
			   if (rstate == RRCVFNAME)
				  sendpkt(NULL,0,EOFACKPKT);
			   break;

			/*---------------------------------------------------------------*/
			/* Name and other data for next file to receive 				 */
			/*---------------------------------------------------------------*/
			case FNAMEPKT:
			   if (rstate == RRCVFNAME)
				  Rxpos = rxstpos = procfname();
			   if (!Rxfname[0] && get_filereq(req_started)) {
				  sendpkt(Rxbuf,strlen(Rxbuf)+2,FREQPKT);
				  attempting_req = TRUE;
				  req_started = FALSE;
			   } else {
				  if (attempting_req) {
					 attempting_req = FALSE;
					 req_started = TRUE;
				  }
#ifdef GENERIC
				  Rxbuf[0] = Rxpos & 0xff;
				  Rxbuf[1] = (Rxpos >> 8) & 0xff;
				  Rxbuf[2] = (Rxpos >> 16) & 0xff;
				  Rxbuf[3] = (Rxpos >> 24) & 0xff;
				  Rxbuf[4] = SharedCap;
#else
				  *((long *)Rxbuf) = Rxpos;
				  Rxbuf[sizeof(Rxpos)] = SharedCap;
#endif				  
				  sendpkt(Rxbuf,sizeof(Rxpos)+1,FNACKPKT);
				  rxoldpos = rxoldeta = -1;
				  if (Rxpos > -1)
					 rstate = (byte)((Rxfname[0]) ? RRCVBLK : RDONE);
				  else
					 j_status(msgtxt[M_REFUSING],Rxfname);
				  if (!rstate)
					 tx_inhibit = FALSE;
				  if (!(xstate || rstate))
					 goto breakout;
			   }
			   break;

			/*---------------------------------------------------------------*/
			/* ACK to filename packet we just sent							 */
			/*---------------------------------------------------------------*/
			case FNACKPKT:
			   if (xstate == XRCVFNACK) {
				  xmit_retry = 0L;
				  if (Txfname[0]) {
#ifdef GENERIC
					 SharedCap = (Rxblklen > sizeof(long)) ? Rxbuf[4] : 0;
					 txpos = (long)Rxbuf[0] + ((long)Rxbuf[1] << 8) + ((long)Rxbuf[2] << 16) + ((long)Rxbuf[3] << 24);
					 if(txpos > -1L) {
#else
					 SharedCap = (Rxblklen > sizeof(long)) ? Rxbuf[sizeof(long)] : 0;
					 if ((txpos = *((long *)Rxbuf)) > -1L) {
#endif
						if (txpos)
						   status_line(msgtxt[M_SYNCHRONIZING],txpos);
						errno = 0;
						lseek(Txfile, txstpos = txpos, SEEK_SET);
						if (j_error(msgtxt[M_SEEK_MSG],Txfname))
						   goto giveup;
						xstate = XSENDBLK;
					 } else {
						j_status(msgtxt[M_REMOTE_REFUSED],Txfname);
						if (sending_req) {
						   if (!(sending_req = get_reqname(FALSE)))
							  getfname(GOOD_XFER);
						} else {
						   Do_after = NOTHING_AFTER;
						   getfname(GOOD_XFER);
						}
						xstate = XSENDFNAME;
					 }
				  } else {
					 sent_mail = 1;
					 xstate = XDONE;
				  }
			   }
			   if (!(xstate || rstate))
				  goto breakout;
			   break;

			/*---------------------------------------------------------------*/
			/* Request to send more stuff rather than end batch just yet	 */
			/*---------------------------------------------------------------*/
			case FREQPKT:
			   if (xstate == XRCVFNACK) {
				  xmit_retry = 0L;
				  SharedCap = *(strchr(Rxbuf,'\0')+1);
				  if (CurrentReqLim > 0) {
					 sprintf(Txbuf,request_template,CurrentNetFiles,
						Hex_Addr_Str(&alias[0].ad));
					 errno = 0;
					 reqfile = fopen(Txbuf,write_ascii);
#if defined(LATTICEBUG)	/* grr... stupid Lattice bug! */
					 if(reqfile) errno = 0;
#endif
					 j_error(msgtxt[M_OPEN_MSG],Txbuf);
					 fputs(Rxbuf,reqfile);
					 fputs("\n",reqfile);
					 fclose(reqfile);
					 unlink(ReqTmp);
					 ReqRecorded = 0;  /* counted by record_reqfile */
					 respond_to_file_requests(0,record_reqfile);
					 CurrentReqLim -= ReqRecorded;
					 if (sending_req = get_reqname(TRUE))
						xstate = XSENDFNAME;
					 else
						xstate = XSENDFREQNAK;
				  } else
					 xstate = XSENDFREQNAK;
			   }
			   break;

			/*---------------------------------------------------------------*/
			/* Our last file request didn't match anything; move on to next  */
			/*---------------------------------------------------------------*/
			case FREQNAKPKT:
			   attempting_req = FALSE;
			   req_started = TRUE;
			   sendpkt(NULL,0,FRNAKACKPKT);
			   break;

			/*---------------------------------------------------------------*/
			/* ACK to no matching files for request error; try to end again  */
			/*---------------------------------------------------------------*/
			case FRNAKACKPKT:
			   if (xstate == XRCVFRNAKACK) {
				  xmit_retry = 0L;
				  getfname(GOOD_XFER);
				  xstate = XSENDFNAME;
			   }
			   break;

			/*---------------------------------------------------------------*/
			/* ACK to last data block in file								 */
			/*---------------------------------------------------------------*/
			case EOFACKPKT:
			   if (xstate == XRCVEOFACK || xstate == XRCVFNACK) {
				  xmit_retry = 0L;
				  if (xstate == XRCVEOFACK) {
					 Txlen -= txstpos;
					 through(&Txlen,&Txsttime);
					 j_status("%s-J%s %s",msgtxt[M_FILE_SENT],(SharedCap&CANCRC32)?"/32":" ",Txfname);
					 update_files(1);
					 if (sending_req) {
						if (!(sending_req = get_reqname(FALSE)))
						   getfname(GOOD_XFER);
					 } else
						getfname(GOOD_XFER);
				  }
				  xstate = XSENDFNAME;
			   }
			   break;

			/*---------------------------------------------------------------*/
			/* Receiver says "let's try that again."						 */
			/*---------------------------------------------------------------*/
			case RPOSPKT:
			   if (xstate == XSENDBLK || xstate == XRCVEOFACK) {
#ifdef GENERIC
				  long t;
				  t = (long)Rxbuf[4] + ((long)Rxbuf[5] << 8) + ((long)Rxbuf[6] << 16) + ((long)Rxbuf[7] << 24);
				   if (t != last_rpostime) {
					 last_rpostime = t;
					 xmit_retry = 0L;
					 CLEAR_OUTBOUND();
					 errno = 0;
					 lasttx = (long)Rxbuf[0] + ((long)Rxbuf[1] << 8) + ((long)Rxbuf[2] << 16) + ((long)Rxbuf[3] << 24);
					 lseek(Txfile, txpos = lasttx, SEEK_SET);
#else
				  if (*((long *)(Rxbuf+sizeof(txpos))) != last_rpostime) {
					 last_rpostime = *((long *)(Rxbuf+sizeof(txpos)));
					 xmit_retry = 0L;
					 CLEAR_OUTBOUND();
					 errno = 0;
					 lseek(Txfile, txpos = lasttx = *((long *)Rxbuf), SEEK_SET);
#endif
					 if (j_error(msgtxt[M_SEEK_MSG],Txfname))
						goto giveup;
					 j_status(msgtxt[M_SYNCHRONIZING],txpos);
					 txblklen >>= 2;
					 if (txblklen < 64)
						txblklen = 64;
					 goodbytes = 0;
					 goodneeded += 1024;
					 if (goodneeded > 8192)
						goodneeded = 8192;
					 xstate = XSENDBLK;
				  }
			   }
			   break;

			/*---------------------------------------------------------------*/
			/* Debris from end of previous Janus session; ignore it 		 */
			/*---------------------------------------------------------------*/
			case HALTACKPKT:
			   break;

			/*---------------------------------------------------------------*/
			/* Abort the transfer and quit									 */
			/*---------------------------------------------------------------*/
			default:
			   j_status(msgtxt[M_UNKNOWN_PACKET],pkttype);
			   /* fallthrough */
			case HALTPKT:
giveup: 	   j_status(msgtxt[M_SESSION_ABORT]);
			   if (Txfname[0])
				  getfname(ABORT_XFER);
			   if (rstate == RRCVBLK) {
				  TotalBytes += (Rxpos-rxstpos);
				  rxclose(FAILED_XFER);
			   }
			   goto abortxfer;

		 }									  /* switch (pkttype)  */
	  } 									  /* while (pkttype)  */
   } while (xstate || rstate);

   /*------------------------------------------------------------------------*/
   /* All done; make sure other end is also finished (one way or another)	 */
   /*------------------------------------------------------------------------*/
breakout:
   if (!fsent) j_status(msgtxt[M_NOTHING_TO_SEND], Pretty_Addr_Str (&called_addr));
abortxfer:
   through(&TotalBytes,&starttime);
   endbatch();

   /*------------------------------------------------------------------------*/
   /* Release allocated memory												 */
   /*------------------------------------------------------------------------*/
freemem:
   if (Txfname)
	  free(Txfname);
   if (Rxfname)
	  free(Rxfname);

   doing_janus = FALSE;

   set_prior(4);		  /* Always High									 */
}



/*****************************************************************************/
/* Get name and info for next file to be transmitted, if any, and build 	 */
/* FNAMEPKT.  Packet contents as per ZModem filename info packet, to allow	 */
/* use of same method of aborted-transfer recovery.  If there are no more	 */
/* files to be sent, build FNAMEPKT with null filename.  Also open file and  */
/* set up for transmission.  Set Txfname, Txfile, Txlen.  Txbuf must not be  */
/* modified until FNACKPKT is received. 									 */
/*****************************************************************************/

static void getfname(word xfer_flag)
{
	static char outboundname[PATHLEN];

	static enum {
		SEND_OUT,
		SEND_FLO,
#ifdef IOS
		SEND_OPT,
		SEND_OAT,
		SEND_OFT,
#endif
		SEND_END		/* Finished */
	} phase;
	static BOOLEAN floflag;		/* Doing flow file */
	static BOOLEAN bad_xfers;
	static char *extptr;

	static long floname_pos;
	static FILE *flofile;
	static int have_lock;
	char *holdname;

	register char *p;
#if 0
	size_t i;
#endif
	long curr_pos;
	struct stat f;

	static ADDR *lastad;


#ifdef IOS
	status_line(">getfname(%d) '%s'", xfer_flag, outboundname);
#endif



	/*------------------------------------------------------------------------*/
	/* Initialize static variables on first call of the batch				  */
	/*------------------------------------------------------------------------*/

	if (xfer_flag == INITIAL_XFER)
	{
		ad_list = remote_ads.next;
		if(ad_list)
		{
			lastad = &ad_list->ad;
			ad_list = ad_list->next;
		}
		else
			lastad = &called_addr;
try_again:
		outboundname[0] = '\0';

		phase = SEND_OUT;
		flofile = NULL;
		floflag = FALSE;
		have_lock = flag_file (TEST_AND_SET, lastad, 1);

#ifdef IOS
		status_line(msgtxt[M_SENDING_FOR], Pretty_Addr_Str(lastad));
#endif

	}

	/*------------------------------------------------------------------------*/
	/* If we were already sending a file, close it and clean up				  */
	/*------------------------------------------------------------------------*/

	else if (Txfile != -1)
	{
		errno = 0;
		close(Txfile);
		j_error(msgtxt[M_CLOSE_MSG],Txfname);
		Txfile = -1;

		/*---------------------------------------------------------------------*/
		/* If xfer completed, do post-xfer cleanup							   */
		/*---------------------------------------------------------------------*/

		if (xfer_flag == GOOD_XFER)
		{
			/*------------------------------------------------------------------*/
			/* Perform post-xfer file massaging if neccessary					*/
			/*------------------------------------------------------------------*/

			switch (Do_after)
			{
			case DELETE_AFTER:
			case SHOW_DELETE_AFTER:
			   j_status(msgtxt[M_UNLINKING_MSG],Txfname);
			   unlink(Txfname);
			   j_error(msgtxt[M_UNLINK_MSG],Txfname);
			   break;
			case TRUNC_AFTER:
			   j_status(msgtxt[M_TRUNC_MSG],Txfname);
			   Txfile = open(Txfname,O_CREAT|O_TRUNC|O_WRONLY,DEFAULT_MODE);
			   if (Txfile != -1)
				  errno = 0;
			   j_error(msgtxt[M_TRUNC_MSG],Txfname);
			   close(Txfile);
			   Txfile = -1;
			}

			/*------------------------------------------------------------------*/
			/* If processing .?LO file, flag filename as sent (name[0] = '~')	*/
			/*------------------------------------------------------------------*/
skipname:
			if(floflag)
			{
				curr_pos = ftell(flofile);
				j_error(msgtxt[M_SEEK_MSG],outboundname);
				fseek(flofile,floname_pos,SEEK_SET);
				j_error(msgtxt[M_SEEK_MSG],outboundname);
				fputc(Txfname[0] = '~',flofile);
				j_error(msgtxt[M_WRITE_MSG],outboundname);
				fseek(flofile,curr_pos,SEEK_SET);
				j_error(msgtxt[M_SEEK_MSG],outboundname);
			}
		}
		else
		{
abort:
			bad_xfers = TRUE;
		}
	}

	/*------------------------------------------------------------------------*/
	/* Find next file to be sent and build FNAMEPKT.  If reading .FLO-type	  */
	/* file get next entry from it; otherwise check for next .OUT/.FLO file	  */
	/*------------------------------------------------------------------------*/

	if (have_lock)
		goto end_send;

	holdname = HoldAreaNameMunge(lastad);
	if (!floflag)
	{
		/*---------------------------------------------------------------------*/
		/* If first getfname() for this batch, init filename to .OUT		   */
		/*---------------------------------------------------------------------*/

		if (!outboundname[0])
		{
			sprintf(outboundname,"%s%s.OUT",holdname,Hex_Addr_Str(lastad));
			extptr = ext_HCD;	/* O is already there */
		}

		/*---------------------------------------------------------------------*/
		/* Increment outbound filename until match found or all checked		   */
		/* .OUT->.DUT->.CUT->.HUT->.FLO->.DLO->.CLO->.HLO->null name		   */
		/*---------------------------------------------------------------------*/

		else
		{
nxtout:
			while(*extptr)
			{
				if (!isOriginator || (*extptr != 'H') || check_holdonus(lastad, (char**)NULL))
					break;
				extptr++;
			}

			p = strchr(outboundname,'\0') - 3;
			if(*extptr)
				*p = *extptr++;

			/*---------------------------------------------------------------*/
			/* Finished ?,D,C,H sequence; go to next phase					 */
			/*---------------------------------------------------------------*/

			else
			{
#ifdef DEBUG
			if(debugging_log)
				status_line(">JANUS: incrementing phase from %d", phase);
#endif
				switch(++phase)
				{
				case SEND_FLO:
					floflag = TRUE;
					*p++ = 'F';
					*p++ = 'L';
					*p++ = 'O';
					extptr = ext_HCD;	/* F is already there */
					break;
#ifdef IOS
				case SEND_OPT:
					sprintf(outboundname, "%s%s.OAT", holdname, Addr36(lastad));
					floflag = FALSE;
					*p++ = 'O';
					*p++ = 'P';
					*p++ = 'T';
					extptr = ext_HCD;
					break;
				case SEND_OAT:
					*p++ = 'O';
					*p++ = 'A';
					*p++ = 'T';
					extptr = ext_HCD;
					break;
				case SEND_OFT:
					floflag = TRUE;
					*p++ = 'O';
					*p++ = 'F';
					*p++ = 'T';
					extptr = ext_HCD;
					break;
#endif
				default:
end_send:
					/* Try for next address */
			
#ifdef DEBUG
			if(debugging_log)
				status_line(">JANUS: Next address");
#endif

					flag_file (CLEAR_FLAG, lastad, 1);

					bad_call(lastad, BAD_REMOVE);		/* Clear $$ files */

					while(ad_list)
					{
						lastad = &ad_list->ad;
						ad_list = ad_list->next;

						if(!isKnownDomain(lastad))
							continue;

						/* Check the password for every aka */
	
						if(session_password)
						{
							char *nf = CurrentNetFiles;	/* remember the inbound directory we are in! */
							BOOLEAN flag = n_password(lastad, session_password, FALSE);
							CurrentNetFiles = nf;		/* Restore inbound folder */

							if(flag)
							{
								status_line(msgtxt[M_NOPASSWORD], Pretty_Addr_Str(lastad));
								continue;
							}
						}
						goto try_again;
					}

					outboundname[0] = Txfname[0] = Txbuf[0] = Txbuf[1] = '\0';
					floflag = FALSE;
					phase = SEND_OUT;
					break;
				}
			}
		}
		
		/*----------------------------------------------------------------------*/
		/* Check potential outbound name; if file doesn't exist keep looking	*/
		/*----------------------------------------------------------------------*/

		if (outboundname[0])
		{
#ifdef DEBUG
			if(debugging_log)
				status_line(">JANUS: outbound= '%s'", outboundname);
#endif
			if (!dexists(outboundname))
				goto nxtout;
			if (floflag)
				goto rdflo;
			strcpy(Txfname,outboundname);

			/*------------------------------------------------------------------*/
			/* Start FNAMEPKT using .PKT alias									*/
			/*------------------------------------------------------------------*/

			switch(phase)
			{
			case SEND_OUT:
			case SEND_OPT:
				invent_pkt_name(Txbuf);
				break;
#ifdef IOS
			case SEND_OAT:
				make_dummy_arcmail(Txbuf, &alias[assumed].ad, lastad);
				break;
#endif
			}
			Do_after = DELETE_AFTER;
		}

	}

	/*------------------------------------------------------------------------*/
	/* Read and process next entry from .?LO-type file						  */
	/*------------------------------------------------------------------------*/

	else
	{
rdflo:
		/*---------------------------------------------------------------------*/
		/* Open .?LO file for processing if neccessary						 */
		/*---------------------------------------------------------------------*/
		if (!flofile)
		{
			bad_xfers = FALSE;
			errno = 0;
			flofile = fopen(outboundname,read_binary_plus);
			if (j_error(msgtxt[M_OPEN_MSG],outboundname))
				goto nxtout;
		}
		errno = 0;
		floname_pos = ftell(flofile);
		j_error(msgtxt[M_SEEK_MSG],outboundname);

		if (fgets(p = Txfname, PATHLEN, flofile))
		{
			/*------------------------------------------------------------------*/
			/* Got an attached file name; check for handling flags, fix up name */
			/*------------------------------------------------------------------*/

			while (*p > ' ')
				++p;
			*p = '\0';
			switch (Txfname[0])
			{
				case '\0':
				case '~':
				case ';':
					goto rdflo;
				case TRUNC_AFTER:
				case DELETE_AFTER:
				case SHOW_DELETE_AFTER:
					Do_after = Txfname[0];
					strcpy(Txfname,Txfname+1);
					break;
				default:
					Do_after = NOTHING_AFTER;
				break;
			}

			/*------------------------------------------------------------------*/
			/* Start FNAMEPKT with simple filename								*/
			/*------------------------------------------------------------------*/

			while (p >= Txfname && *p != '\\' && *p != ':')
				--p;
			strcpy(Txbuf,++p);
		}
		else
		{
			/*------------------------------------------------------------------*/
			/* Finished reading this .?LO file; clean up and look for another	*/
			/*------------------------------------------------------------------*/

			errno = 0;
			fclose(flofile);
			j_error(msgtxt[M_CLOSE_MSG],outboundname);
			flofile = NULL;
			if (!bad_xfers)
			{
				unlink(outboundname);
				j_error(msgtxt[M_UNLINK_MSG],outboundname);
			}
			goto nxtout;
		}
   }

	/*------------------------------------------------------------------------*/
	/* If we managed to find a valid file to transmit, open it, finish		  */
	/* FNAMEPKT, and print nice message for the sysop.						  */
	/*------------------------------------------------------------------------*/

	if (Txfname[0])
	{
		if (xfer_flag == ABORT_XFER)
			goto abort;
		j_status(msgtxt[M_SENDING],Txfname);
		errno = 0;
		Txfile = open(Txfname,O_RDONLY|O_BINARY);
		if (Txfile != -1)
			errno = 0;
		if (j_error(msgtxt[M_OPEN_MSG],Txfname))
			goto skipname;

		stat(Txfname,&f);
		sprintf(strchr(Txbuf,'\0')+1,"%lu %lo %o",Txlen = f.st_size,f.st_mtime,f.st_mode);

		p = strchr(Txfname,'\0');
		while (p >= Txfname && *p != ':' && *p != '\\')
			--p;
		if (!un_attended || !fullscreen)
			Tx_y = Next_y;
		else
			Tx_y = 1;
		xfer_summary(msgtxt[M_SEND],++p,&Txlen,Tx_y);

		time(&Txsttime);
	}
}


/*****************************************************************************/
/* Build and send a packet of any type. 									 */
/* Packet structure is: PKTSTRT,contents,packet_type,PKTEND,crc 			 */
/* CRC is computed from contents and packet_type only; if PKTSTRT or PKTEND  */
/* get munged we'll never even find the CRC.								 */
/*****************************************************************************/
static void sendpkt(register byte *buf,size_t len,int type) {
   register word crc;

   if ((SharedCap & CANCRC32) && type != FNAMEPKT)
	  sendpkt32(buf,len,type);
   else {
	  BUFFER_BYTE(DLE);
	  BUFFER_BYTE(PKTSTRTCHR ^ 0x40);

	  crc = 0;
	  while (len--) {
		 txbyte(*buf);
		 crc = xcrc(crc, *buf++);
	  }

	  BUFFER_BYTE((byte)type);
	  crc = xcrc(crc,type);

	  BUFFER_BYTE(DLE);
	  BUFFER_BYTE(PKTENDCHR ^ 0x40);

	  txbyte((byte)(crc >> 8));
	  txbyte((byte)(crc & 0xFF));

	  UNBUFFER_BYTES();
   }
}


/*****************************************************************************/
/* Build and send a packet using 32-bit CRC; same as sendpkt in other ways	 */
/*****************************************************************************/
static void sendpkt32(register byte *buf,register size_t len,int type) {
   unsigned long crc32;

   BUFFER_BYTE(DLE);
   BUFFER_BYTE(PKTSTRTCHR32 ^ 0x40);

   crc32 = 0xFFFFFFFF;
   while (len--) {
	  txbyte(*buf);
	  crc32 = Z_32UpdateCRC(((word)*buf),crc32);
	  ++buf;
   }

   BUFFER_BYTE((byte)type);
   crc32 = Z_32UpdateCRC(type,crc32);

   BUFFER_BYTE(DLE);
   BUFFER_BYTE(PKTENDCHR ^ 0x40);

   txbyte((byte)(crc32 >> 24));
   txbyte((byte)((crc32 >> 16) & 0xFF));
   txbyte((byte)((crc32 >> 8) & 0xFF));
   txbyte((byte)(crc32 & 0xFF));

   UNBUFFER_BYTES();
}



/*****************************************************************************/
/* Transmit cooked escaped byte(s) corresponding to raw input byte.  Escape  */
/* DLE, XON, and XOFF using DLE prefix byte and ^ 0x40. Also escape 		 */
/* CR-after-'@' to avoid Telenet/PC-Pursuit problems.						 */
/*****************************************************************************/
static void txbyte(register byte c) {
   static byte lastsent;

   switch (c) {
	  case CR:
		 if (lastsent != '@')
			goto sendit;
		 /* fallthrough */
	  case DLE:
	  case XON:
	  case XOFF:
		 BUFFER_BYTE(DLE);
		 c ^= 0x40;
		 /* fallthrough */
	  default:
sendit:  BUFFER_BYTE(lastsent = c);
   }
}


/*****************************************************************************/
/* Process FNAMEPKT of file to be received.  Check for aborted-transfer 	 */
/* recovery and solve filename collisions.	  Check for enough disk space.	 */
/* Return initial file data position to start receiving at, or -1 if error	 */
/* detected to abort file reception.  Set Rxfname, Rxlen, Rxfile.			 */
/*****************************************************************************/
static long procfname(void) {
   register byte *p;
   char linebuf[128], *fileinfo, *badfname;
   long filestart, bytes;
   FILE *abortlog;
   struct stat f;

   /*------------------------------------------------------------------------*/
   /* Initialize for file reception 										 */
   /*------------------------------------------------------------------------*/
   Rxfname[0] = Resume_WaZOO = 0;

   /*------------------------------------------------------------------------*/
   /* Save info on WaZOO transfer in case of abort							 */
   /*------------------------------------------------------------------------*/
   strcpy(Resume_name,fancy_str(Rxbuf));
   fileinfo = strchr(Rxbuf,'\0') + 1;
   p = strchr(fileinfo,'\0') + 1;
   SharedCap = (Rxblklen > p-Rxbuf) ? *p & OURCAP : 0;

   /*------------------------------------------------------------------------*/
   /* If this is a null FNAMEPKT, return OK immediately 					 */
   /*------------------------------------------------------------------------*/
   if (!Rxbuf[0])
	  return 0L;

   strcpy(linebuf,Rxbuf);
   strlwr(linebuf);
   p = check_netfile(linebuf);
   j_status("#%s %s %s",msgtxt[M_RECEIVING],(p) ? p : " ",Rxbuf);

   /*------------------------------------------------------------------------*/
   /* Extract and validate filesize 										 */
   /*------------------------------------------------------------------------*/
   Rxlen = -1;
   Rxfiletime = 0;
   if (sscanf(fileinfo,"%ld %lo",&Rxlen,&Rxfiletime) < 1 || Rxlen < 0) {
	  j_status(msgtxt[M_NO_LENGTH]);
	  return -1L;
   }
   sprintf(Resume_info,"%ld %lo",Rxlen,Rxfiletime);

   /*------------------------------------------------------------------------*/
   /* Check if this is a failed WaZOO transfer which should be resumed		 */
   /*------------------------------------------------------------------------*/
   if (dexists(Abortlog_name)) {
	  errno = 0;
	  abortlog = fopen(Abortlog_name,read_ascii);
	  if (!j_error(msgtxt[M_OPEN_MSG],Abortlog_name)) {
		 while (!feof(abortlog)) {
			linebuf[0] = '\0';
			if (!fgets(p = linebuf,(int)sizeof(linebuf),abortlog))
			   break;
			while (*p >= ' ')
			   ++p;
			*p = '\0';
			p = strchr(linebuf,' ');
			*p = '\0';
			if (!stricmp(linebuf,Resume_name)) {
			   p = strchr( (badfname = ++p), ' ');
			   *p = '\0';
			   if (!stricmp(++p,Resume_info)) {
				  ++Resume_WaZOO;
				  break;
			   }
			}
		 }
		 errno = 0;
		 fclose(abortlog);
		 j_error(msgtxt[M_CLOSE_MSG],Abortlog_name);
	  }
   }

   /*------------------------------------------------------------------------*/
   /* Open either the old or a new file, as appropriate 					 */
   /*------------------------------------------------------------------------*/
   p = strchr(strcpy(Rxfname,CurrentNetFiles),'\0');
   errno = 0;
   if (Resume_WaZOO) {
	  strcpy(p,badfname);
	  Rxfile = open(Rxfname,O_CREAT|O_RDWR|O_BINARY,DEFAULT_MODE);
   } else {
	  strcpy(p,Rxbuf);
	  /*---------------------------------------------------------------------*/
	  /* If the file already exists:										 */
	  /* 1) And the new file has the same time and size, skip it			 */
	  /* 2) And OVERWRITE is turned on, delete the old copy 				 */
	  /* 3) Else create a unique file name in which to store new data		 */
	  /*---------------------------------------------------------------------*/
	  if (dexists(Rxfname)) {
		 size_t i;

		 stat(Rxfname,&f);
		 if (Rxlen == f.st_size && Rxfiletime == f.st_mtime) {
			j_status(msgtxt[M_ALREADY_HAVE],Rxfname);
			return -1L;
		 }

		 i = strlen(Rxfname) -1;
		/* DONTRENAMEREQ  09.09.1990 */
		 if ((Rxfname[i-2] == 'R') && (Rxfname[i-1] == 'E') && (Rxfname[i] == 'Q'))
		 {
			unlink (Rxfname);
		 }
		 else
		 if ((!overwrite) || (is_arcmail(Rxfname, i))) {
			unique_name(Rxfname);
			j_status(msgtxt[M_RENAME_MSG],Rxfname);
		 } else {
			unlink(Rxfname);
			j_error(msgtxt[M_UNLINK_MSG],Rxfname);
		 }
	  }
	  Rxfile = open(Rxfname,O_CREAT|O_EXCL|O_RDWR|O_BINARY,DEFAULT_MODE);
   }
   if (Rxfile != -1)
	  errno = 0;
   if (j_error(msgtxt[M_OPEN_MSG],Rxfname))
	  return -1L;

   /*------------------------------------------------------------------------*/
   /* Determine initial file data position									 */
   /*------------------------------------------------------------------------*/
   if (Resume_WaZOO) {
	  stat(Rxfname,&f);
	  j_status(msgtxt[M_SYNCHRONIZING_OFFSET],filestart = f.st_size);
	  p = Rxbuf;
	  errno = 0;
	  lseek(Rxfile,filestart,SEEK_SET);
	  if (j_error(msgtxt[M_SEEK_MSG],Rxfname)) {
		 close(Rxfile);
		 return -1L;
	  }
   } else
	  filestart = 0L;

   /*------------------------------------------------------------------------*/
   /* Check for enough disk space											 */
   /*------------------------------------------------------------------------*/
   bytes = Rxlen - filestart + 10240;
   if (bytes > Diskavail) {
	  j_status(msgtxt[M_OUT_OF_DISK_SPACE]);
	  close(Rxfile);
	  return -1L;
   }

   /*------------------------------------------------------------------------*/
   /* Print status message for the sysop									 */
   /*------------------------------------------------------------------------*/
   if (!un_attended || !fullscreen)
	  Rx_y = Next_y;
   else
	  Rx_y = 2;
   xfer_summary(msgtxt[M_RECV],p,&Rxlen,Rx_y);

   time(&Rxsttime);

   return filestart;
}


/*****************************************************************************/
/* Receive, validate, and extract a packet if available.  If a complete 	 */
/* packet hasn't been received yet, receive and store as much of the next	 */
/* packet as possible.	  Each call to rcvpkt() will continue accumulating a */
/* packet until a complete packet has been received or an error is detected. */
/* Rxbuf must not be modified between calls to rcvpkt() if NOPKT is returned.*/
/* Returns type of packet received, NOPKT, or BADPKT.  Sets Rxblklen.		 */
/*****************************************************************************/
static byte rcvpkt() {
   static byte rxcrc32;
   static word crc;
   static unsigned long crc32;
   register byte *p;
   register int c;
   int i;
   unsigned long pktcrc;

   /*------------------------------------------------------------------------*/
   /* Abort transfer if operator pressed ESC								 */
   /*------------------------------------------------------------------------*/

   if (got_ESC()) {
	  j_status(GenericError,msgtxt[M_KBD_MSG]);
	  return HALTPKT;
   }

   /*------------------------------------------------------------------------*/
   /* If not accumulating packet yet, find start of next packet 			 */
   /*------------------------------------------------------------------------*/
   WaitFlag = FALSE;
   if (!(p = Rxbufptr)) {
	  do
		 c = rxbyte();
	  while (c >= 0 || c == PKTEND);

#ifdef DEBUG
		j_status(">.rcvbyte packet header: %d", c);
#endif

	  switch (c) {
		 case PKTSTRT:
			rxcrc32 = FALSE;
			p = Rxbuf;
			crc = 0;
			break;
		 case PKTSTRT32:
			rxcrc32 = TRUE;
			p = Rxbuf;
			crc32 = 0xFFFFFFFF;
			break;
		 case NOCARRIER:
			j_status(GenericError,&(msgtxt[M_NO_CARRIER][1]));
			return HALTPKT;
		 default:
			return NOPKT;
	  }
   }

   /*------------------------------------------------------------------------*/
   /* Accumulate packet data until we empty buffer or find packet delimiter  */
   /*------------------------------------------------------------------------*/
   if (rxcrc32) {
	  while ((c = rxbyte()) >= 0 && p < Rxbufmax) {
		 *p++ = (byte)c;
		 crc32 = Z_32UpdateCRC(c,crc32);
	  }
   } else {
	  while ((c = rxbyte()) >= 0 && p < Rxbufmax) {
		 *p++ = (byte)c;
		 crc = xcrc(crc,c);
	  }
   }


#ifdef DEBUG
	j_status(">.rcvbyte packet end = %d p=%ld", c, (long)(p-Rxbuf)-1);
#endif

   /*------------------------------------------------------------------------*/
   /* Handle whichever end-of-packet condition occurred 					 */
   /*------------------------------------------------------------------------*/
   switch (c) {
	  /*---------------------------------------------------------------------*/
	  /* PKTEND found; verify valid CRC 									 */
	  /*---------------------------------------------------------------------*/
	  case PKTEND:
		 WaitFlag = TRUE;
		 pktcrc = 0;
		 for (i = (rxcrc32) ? 4 : 2; i; --i) {
			if ((c = rxbyte()) < 0)
			   break;
			pktcrc = (pktcrc << 8) | c;
		 }
		 if (!i) {
			if ((rxcrc32 && pktcrc == crc32) || pktcrc == crc) {
			   /*------------------------------------------------------------*/
			   /* Good packet verified; compute packet data length and		 */
			   /* return packet type										 */
			   /*------------------------------------------------------------*/
			   Rxbufptr = NULL;
			   Rxblklen = --p - Rxbuf;
			   return *p;
			}
		 }
		 /* fallthrough */

	  /*---------------------------------------------------------------------*/
	  /* Bad CRC, carrier lost, or buffer overflow from munged PKTEND		 */
	  /*---------------------------------------------------------------------*/
	  default:
		 if (c == NOCARRIER) {
			j_status(GenericError,&(msgtxt[M_NO_CARRIER][1]));
			return HALTPKT;
		 } else {
			Rxbufptr = NULL;
			return BADPKT;
		 }

	  /*---------------------------------------------------------------------*/
	  /* Emptied buffer; save partial packet and let sender do something	 */
	  /*---------------------------------------------------------------------*/
	  case BUFEMPTY:
		 Rxbufptr = p;
		 return NOPKT;

	  /*---------------------------------------------------------------------*/
	  /* PKTEND was trashed; discard partial packet and prep for next one	 */
	  /*---------------------------------------------------------------------*/
	  case PKTSTRT:
		 rxcrc32 = FALSE;
		 Rxbufptr = Rxbuf;
		 crc = 0;
		 return BADPKT;

	  case PKTSTRT32:
		 rxcrc32 = TRUE;
		 Rxbufptr = Rxbuf;
		 crc32 = 0xFFFFFFFF;
		 return BADPKT;
   }
}



/*****************************************************************************/
/* Close file being received and perform post-reception aborted-transfer	 */
/* recovery cleanup if neccessary.											 */
/*****************************************************************************/
static void rxclose(word xfer_flag) {
   register byte *p;
   byte namebuf[PATHLEN], linebuf[128], c;
   FILE *abortlog, *newlog;
   struct utimbuf utimes;

   /*------------------------------------------------------------------------*/
   /* Close file we've been receiving										 */
   /*------------------------------------------------------------------------*/
   errno = 0;
   close(Rxfile);
   j_error(msgtxt[M_CLOSE_MSG],Rxfname);
   if (Rxfiletime) {
	  utimes.actime = Rxfiletime;
	  utimes.modtime = Rxfiletime;
	  utime(Rxfname,&utimes);
   }

   /*------------------------------------------------------------------------*/
   /* If we completed a previously-aborted transfer, kill log entry & rename */
   /*------------------------------------------------------------------------*/
   if (xfer_flag == GOOD_XFER && Resume_WaZOO) {
	  abortlog = fopen(Abortlog_name,read_ascii);
	  if (!j_error(msgtxt[M_OPEN_MSG],Abortlog_name)) {
		 c = 0;
		 strcpy(strchr(strcpy(namebuf,Abortlog_name),'\0')-1,"TMP");
		 newlog = fopen(namebuf,write_ascii);
#if defined(LATTICEBUG)	/* grr... stupid Lattice bug! */
		 if(newlog) errno = 0;
#endif
		 if (!j_error(msgtxt[M_OPEN_MSG],namebuf)) {
			while (!feof(abortlog)) {
			   linebuf[0] = '\0';
			   if (!fgets(p = linebuf,(int)sizeof(linebuf),abortlog))
				  break;
			   while (*p > ' ')
				  ++p;
			   *p = '\0';
			   if (stricmp(linebuf,Resume_name)) {
				  *p = ' ';
				  fputs(linebuf,newlog);
				  if (j_error(msgtxt[M_WRITE_MSG],namebuf))
					 break;
				  ++c;
			   }
			}
			errno = 0;
			fclose(abortlog);
			j_error(msgtxt[M_CLOSE_MSG],Abortlog_name);
			fclose(newlog);
			j_error(msgtxt[M_CLOSE_MSG],namebuf);
			unlink(Abortlog_name);
			j_error(msgtxt[M_UNLINK_MSG],Abortlog_name);
			if (c) {
			   if (!rename(namebuf,Abortlog_name))
				  errno = 0;
			   j_error(msgtxt[M_RENAME_MSG],namebuf);
			} else {
			   unlink(namebuf);
			   j_error(msgtxt[M_UNLINK_MSG],namebuf);
			}
		 } else {
			fclose(abortlog);
			j_error(msgtxt[M_CLOSE_MSG],Abortlog_name);
		 }
	  }
	  j_status(msgtxt[M_FINISHED_PART],Resume_name);
	  unique_name(strcat(strcpy(namebuf,CurrentNetFiles),Resume_name));
	  if (!rename(Rxfname,namebuf)) {
		 errno = 0;
		 strcpy(Rxfname,namebuf);
	  } else
		 j_error(msgtxt[M_RENAME_MSG],Rxfname);
   /*------------------------------------------------------------------------*/
   /* If transfer failed and was not an attempted resumption, log for later  */
   /*------------------------------------------------------------------------*/
   } else if (xfer_flag == FAILED_XFER && !Resume_WaZOO) {
	  j_status(msgtxt[M_SAVING_PART],Rxfname);
	  unique_name(strcat(strcpy(namebuf,CurrentNetFiles),"BadWaZOO.001"));
	  if (!rename(Rxfname,namebuf))
		 errno = 0;
	  j_error(msgtxt[M_RENAME_MSG],Rxfname);

	  abortlog = fopen(Abortlog_name,append_ascii);
#if defined(LATTICEBUG)	/* grr... stupid Lattice bug! */
	 if(abortlog) errno = 0;
#endif
	  if (!j_error(msgtxt[M_OPEN_MSG],Abortlog_name)) {
		 fprintf(abortlog,"%s %s %s\n",Resume_name,namebuf+strlen(CurrentNetFiles),Resume_info);
		 j_error(msgtxt[M_WRITE_MSG],Abortlog_name);
		 fclose(abortlog);
		 j_error(msgtxt[M_CLOSE_MSG],Abortlog_name);
	  } else {
		 unlink(namebuf);
		 j_error(msgtxt[M_UNLINK_MSG],namebuf);
	  }
   }
}


/*****************************************************************************/
/* Try REAL HARD to disengage batch session cleanly 						 */
/*****************************************************************************/
static void endbatch(void)
	{	register int done, timeouts;
		long timeval, brain_dead;

   /*------------------------------------------------------------------------*/
   /* Tell the other end to halt if it hasn't already						 */
   /*------------------------------------------------------------------------*/
		done = timeouts = 0;
		long_set_timer(&brain_dead,180);		/* von 120 auf 180 gesetzt */


/* Achtung! Code ist wieder aktiv! Ich hoffe, daž das ESC-Problem */
/* Zum teil hier lag.			St.Slabihoud 1993												*/
/*		goto reject; */


   /*------------------------------------------------------------------------*/
   /* Wait for the other end to acknowledge that it's halting				 */
   /*------------------------------------------------------------------------*/
		while (!done)
			{	if (long_time_gone(&brain_dead))
					break;

	  		switch (rcvpkt())
	  			{	case NOPKT	:
						case BADPKT	:	if (long_time_gone(&timeval))
														{	if (++timeouts > 2)
															  ++done;
														  else
															  goto reject;
														}
													break;
		 				case HALTPKT:
						case HALTACKPKT:	++done;	break;
						default			:	timeouts = 0;
reject: 									sendpkt(NULL,0,HALTPKT);
													long_set_timer(&timeval,TimeoutSecs);
													break;
			  	}
			}

   /*------------------------------------------------------------------------*/
   /* Announce quite insistently that we're done now						 */
   /*------------------------------------------------------------------------*/
		for (done = 0; done < 10; ++done)
			sendpkt(NULL,0,HALTACKPKT);
		wait_for_clear();
	}


/*****************************************************************************/
/* Print a message in the message field of a transfer status line			 */
/*****************************************************************************/
static void j_message(word pos,char *va_alist,...)
{
   va_list arg_ptr;
   int y, l;

   char buf[128];
   y = pos;
   va_start(arg_ptr, va_alist);

   if (!un_attended || !fullscreen)
	  gotoxy(MSG_X,y);
   else
	  sb_move(filewin,y,MSG_X);


   (void) vsprintf(buf,va_alist,arg_ptr);

   for (l = 25-(int)strlen(buf); l > 0; --l)
	  strcat(buf," ");

   if (!un_attended || !fullscreen) {
	  cputs(buf);
   } else {
	  sb_puts(filewin,buf);
	  sb_show();
   }

   va_end(arg_ptr);
}


/*****************************************************************************/
/* Print & log status message without messing up display					 */
/*****************************************************************************/
static void j_status(char *va_alist,...)
{
   va_list arg_ptr;

   char buf[128];
   va_start(arg_ptr, va_alist);

   if (!un_attended || !fullscreen)
	  gotoxy(1,Next_y-1);

   (void) vsprintf(buf,va_alist,arg_ptr);

   status_line(buf);

   if (!un_attended || !fullscreen)
	  update_y();

   va_end(arg_ptr);
}


/*****************************************************************************/
/* Print & log error message without messing up display 					 */
/*****************************************************************************/
static int j_error(byte *msg,byte *fname) {
   register int e;

   if (e = errno) {
	  if (!un_attended || !fullscreen)
		 gotoxy(1,Next_y-1);

	  got_error(msg,fname);

	  if (!un_attended || !fullscreen)
		 update_y();
   }
   return e;
}


/*****************************************************************************/
/* Update screen position variables after printing a message				 */
/*****************************************************************************/
static void update_y() {
   set_xy(NULL);			   /* Bump cursor to next line after printing	 */
   if (locate_y == Next_y) {   /* If we didn't go anywhere, screen scrolled; */
	  if (Tx_y > 1) 		   /* so decrement status line numbers			 */
		 --Tx_y;
	  if (Rx_y > 1)
		 --Rx_y;
   } else Next_y = locate_y;
}


/*****************************************************************************/
/* Compute future timehack for later reference								 */
/*****************************************************************************/
static void long_set_timer(long *Buffer,word Duration) {
   time(Buffer);
   *Buffer += (long)Duration;
}


/*****************************************************************************/
/* Return TRUE if timehack has been passed, FALSE if not					 */
/*****************************************************************************/
static int long_time_gone(long *TimePtr) {
   return (time(NULL) > *TimePtr);
}


/*****************************************************************************/
/* Receive cooked escaped byte translated to avoid various problems.		 */
/* Returns raw byte, BUFEMPTY, PKTSTRT, PKTEND, or NOCARRIER.				 */
/*****************************************************************************/
static int rxbyte(void) {
   register int c, w;

   if ((c = rcvrawbyte()) == DLE) {
	  w = WaitFlag++;
	  if ((c = rcvrawbyte()) >= 0) {
#ifdef DEBUG
	 j_status(">--- DLE char %d", c);
#endif
		 switch (c ^= 0x40) {
			case PKTSTRTCHR:
			   c = PKTSTRT;
			   break;
			case PKTSTRTCHR32:
			   c = PKTSTRT32;
			   break;
			case PKTENDCHR:
			   c = PKTEND;
			   break;
		 }
	  }
	  WaitFlag = (byte)w;
#ifdef DEBUG
	 j_status(">--- DLE result %d", c);
#endif
   }
   return c;
}


/*****************************************************************************/
/* Receive raw non-escaped byte.  Returns byte, BUFEMPTY, or NOCARRIER. 	 */
/* If waitflag is true, will wait for a byte for Timeoutsecs; otherwise 	 */
/* will return BUFEMPTY if a byte isn't ready and waiting in inbound buffer. */
/*****************************************************************************/
static int rcvrawbyte(void)
{
   long timeval;

   if ((PEEKBYTE()) >= 0)
	  return MODEM_IN();

   if (!CARRIER)
	  return NOCARRIER;
   if (!WaitFlag)
	  return BUFEMPTY;

   timeval = time(NULL) + TimeoutSecs;

   while (PEEKBYTE() < 0) {
	  if (!CARRIER)
		 return NOCARRIER;
	  if (time(NULL) > timeval)
		 return BUFEMPTY;
	  time_release();
   }

   return MODEM_IN();
}


/*****************************************************************************/
/* Display start-of-transfer summary info									 */
/*****************************************************************************/
static void xfer_summary(char *xfertype,char *fname,long *len,int y) {
   char buf[128];

   if (!un_attended || !fullscreen)
	  gotoxy(2,y);
   else
	  sb_move(filewin,y,2);

	/* !!! Watch out for TABS here! */
	
   sprintf(buf,"%s %12.12s;        0/%8ldb,%4d min.                       ",
	  xfertype, fname, *len, (int)((*len*10/cur_baud*100/JANUS_EFFICIENCY+59)/60));

   if (!un_attended || !fullscreen) {
	  cputs(buf);
	  cputs(local_CEOL);
	  update_y();
   } else {
	  sb_puts(filewin,buf);
	  sb_show();
   }
}


/*****************************************************************************/
/* Update any status line values which have changed 						 */
/*****************************************************************************/
static void update_status(long *pos,long *oldpos,long left,int *oldeta,int y) {
  char buf[16];
  register int eta;

  elapse_time();

  if (*pos != *oldpos) {
	 sprintf(buf,"%8ld",*oldpos = *pos);
	 if (!un_attended || !fullscreen) {
		gotoxy(POS_X,y);
		cputs(buf);
	 } else {
		sb_move(filewin,y,POS_X);
		sb_puts(filewin,buf);
	 }
  }

  eta = (int)((left*10/cur_baud*100/JANUS_EFFICIENCY+59)/60);
  if (eta != *oldeta) {
	 sprintf(buf,"%4d",*oldeta = eta);
	 if (!un_attended || !fullscreen) {
		gotoxy(ETA_X,y);
		cputs(buf);
	 } else {
		sb_move(filewin,y,ETA_X);
		sb_puts(filewin,buf);
	 }
  }

  if (un_attended && fullscreen)
	 sb_show();
}

/*****************************************************************************/
/* Compute and print throughput 											 */
/*****************************************************************************/
static void through(long *bytes,long *started) {
   static byte *scrn = "+CPS: %u (%lu bytes)  Efficiency: %lu%%%%";
   unsigned long elapsed;
   register word cps;

   elapsed = time(NULL) - *started;
   cps = (elapsed) ? (word)(*bytes/elapsed) : 0;
   j_status(scrn, cps, *bytes, cps*1000L/cur_baud);
   TotalBytes += *bytes;
}


/*****************************************************************************/
/* Get next file to request, if any 										 */
/*****************************************************************************/

static int get_filereq(byte req_started)
{
    byte reqname[PATHLEN], linebuf[128];
    register byte *p;
    BOOLEAN gotone = FALSE;
    FILE *reqfile;

	static ADDR_LIST *ad_list = NULL;
	static ADDR *lastad = NULL;
	static enum { REQ_REQ, REQ_IOS, REQ_DONE } phase;
	static char *ext;


#ifdef DEBUG
	if(debugging_log)
		status_line(">JANUSREQ: get_filereq(%d)", req_started);
#endif

	if(!req_started)
	{
		ad_list = remote_ads.next;				/* Start wth top address */
		if(ad_list)
		{
			lastad = &ad_list->ad;
			ad_list = ad_list->next;
		}
		else
			lastad = &called_addr;

		phase = REQ_REQ;

		if(flag_file(TEST_AND_SET, lastad, 1))
			goto nextad;
	}

	for(;;)
	{
		switch(phase)
		{
		case REQ_REQ:	/* old style 2D */
			sprintf (reqname, request_template, HoldAreaNameMunge(lastad), Hex_Addr_Str(lastad));
			break;
			
		case REQ_IOS:
			sprintf(reqname, "%s%s.%cRT", HoldAreaNameMunge(lastad), Addr36(lastad), *ext);
			break;

		}
			
#ifdef DEBUG
		if(debugging_log)
			status_line(">JANUSREQ: reqname='%s'", reqname);
#endif

		if(req_started)				/* Mark last file as processed */
			mark_done(reqname);

	   	if (dexists(reqname))
   		{
			if (!(remote_capabilities & WZ_FREQ))
			{
				j_status(msgtxt[M_FREQ_DECLINED]);
				return 0;
			}
		  	else if (!(SharedCap & CANFREQ))
		  	{
				j_status(msgtxt[M_REMOTE_CANT_FREQ]);
				return 0;
			}
		  	else
		  	{
			 	errno = 0;

		 		if(!req_started)
					status_line ("%s [%s]", msgtxt[M_OUT_REQUESTS], Pretty_Addr_Str(lastad));

			 	reqfile = fopen(reqname,read_ascii);
		 		if (!j_error(msgtxt[M_OPEN_MSG],reqname))
			 	{
					while (!feof(reqfile))
					{
				   		linebuf[0] = '\0';
				   		if (!fgets(p = linebuf, (int) sizeof(linebuf), reqfile))
					  		break;
				   		while (*p >= ' ')
					  		++p;
				   		*p = '\0';
				   		if (linebuf[0] != ';')
				   		{
					  		strcpy(Rxbuf,linebuf);
					  		*(strchr(Rxbuf,'\0')+1) = SharedCap;
					  		gotone = TRUE;
					  		break;
				   		}
					}
					fclose(reqfile);
					j_error(msgtxt[M_CLOSE_MSG],reqname);
					if(gotone)
						return TRUE;
					else
					{
				   		unlink(reqname);
				   		j_error(msgtxt[M_UNLINK_MSG],reqname);
					}
			 	}
		  	}
   		}

		/* No file to request, lets try next in sequence */
		
#ifdef DEBUG
		if(debugging_log)
			status_line(">JANUSREQ: nextphase %d", phase);
#endif

		req_started = FALSE;
		switch(phase)
		{
		case REQ_REQ:
			ext = ext_OHCD;
			phase++;
			break;
		
		default:
		
			ext++;			/* Next extension */
			if (isOriginator && (*ext == 'H') && check_holdonus(lastad, (char**)NULL))
				ext++;
			if(*ext)
				break;
		
			/* Next address */

nextad:
			phase = REQ_REQ;		/* Restart sequence */
			
			flag_file (CLEAR_FLAG, lastad, 1);

#ifdef DEBUG
		if(debugging_log)
			status_line(">JANUSREQ: Next address");
#endif

			gotone = FALSE;
			while(ad_list)
			{
				lastad = &ad_list->ad;
				ad_list = ad_list->next;

				if(!isKnownDomain(lastad))
					continue;

				/* Check the password for every aka */
	
				if(session_password)
				{
					char *nf = CurrentNetFiles;	/* remember the inbound directory we are in! */
					BOOLEAN flag = n_password(lastad, session_password, FALSE);
					CurrentNetFiles = nf;		/* Restore inbound folder */

					if(flag)
					{
						status_line(msgtxt[M_NOPASSWORD], Pretty_Addr_Str(lastad));
						continue;
					}
				}
				if(flag_file(TEST_AND_SET, lastad, 1) == 0)
				{
					gotone = TRUE;
					break;
				}
			}
			if(!gotone)
				return 0;	/* No addresses left! */
		}
	}
}


/*****************************************************************************/
/* Record names of files to send in response to file request; callback		 */
/* routine for respond_to_file_requests()									 */
/*****************************************************************************/
static int record_reqfile(char *fname) {
   FILE *tmpfile;

   errno = 0;
   tmpfile = fopen(ReqTmp,append_ascii);
#if defined(LATTICEBUG)	/* grr... stupid Lattice bug! */
   if(tmpfile) errno = 0;
#endif
   if (!j_error(msgtxt[M_OPEN_MSG],ReqTmp)) {
	  fputs(fname,tmpfile);
	  j_error(msgtxt[M_WRITE_MSG],ReqTmp);
	  fputs("\n",tmpfile);
	  j_error(msgtxt[M_WRITE_MSG],ReqTmp);
	  fclose(tmpfile);
	  j_error(msgtxt[M_CLOSE_MSG],ReqTmp);
	  ++ReqRecorded;
	  return TRUE;
   }
   return FALSE;
}


/*****************************************************************************/
/* Get next file which was requested, if any								 */
/*****************************************************************************/
static byte get_reqname(byte first_req)
{
   register byte *p;
   byte gotone = FALSE;
   FILE *tmpfile;
   struct stat f;

   if (!first_req)
   {
	  	errno = 0;
	  	close(Txfile);
	  	j_error(msgtxt[M_CLOSE_MSG],Txfname);
	  	Txfile = -1;
	  	mark_done(ReqTmp);

		if (Do_after == DELETE_AFTER)
		{  
		   	j_status(msgtxt[M_UNLINKING_MSG],Txfname);
		   	unlink(Txfname);
		   	j_error(msgtxt[M_UNLINK_MSG],Txfname);
		}
   }

   if (dexists(ReqTmp)) {
	  errno = 0;
	  tmpfile = fopen(ReqTmp,read_ascii);
	  if (!j_error(msgtxt[M_OPEN_MSG],ReqTmp)) {
		 while (!feof(tmpfile))
		 {
			Txfname[0] = '\0';
			if (!fgets(p = Txfname,PATHLEN,tmpfile))
			   break;
			while (*p >= ' ')
			   ++p;
			*p = '\0';
			if (Txfname[0] != ';')
			{

				/* SWG: If 1st letter is ^ then delete after sending */
				if(Txfname[0] == DELETE_AFTER)
				{
					Do_after = DELETE_AFTER;
					strcpy(Txfname, Txfname+1);
				}
				else
					Do_after = NOTHING_AFTER;

			   j_status(msgtxt[M_SENDING],Txfname);
			   errno = 0;
			   Txfile = open(Txfname,O_RDONLY|O_BINARY);
			   if (Txfile != -1)
				  errno = 0;
			   if (j_error(msgtxt[M_OPEN_MSG],Txfname))
				  continue;
			   while (p >= Txfname && *p != '\\' && *p != ':')
				  --p;
			   strcpy(Txbuf,++p);
			   stat(Txfname,&f);
			   sprintf(strchr(Txbuf,'\0')+1,"%lu %lo %o",Txlen = f.st_size,f.st_mtime,f.st_mode);
			   if (!un_attended || !fullscreen)
				  Tx_y = Next_y;
			   else
				  Tx_y = 1;
			   xfer_summary(msgtxt[M_SEND],p,&Txlen,Tx_y);
			   time(&Txsttime);
			   gotone = TRUE;
			   break;
			}
		 }
		 fclose(tmpfile);
		 j_error(msgtxt[M_CLOSE_MSG],ReqTmp);
		 if (!gotone)
		 {
			unlink(ReqTmp);
			j_error(msgtxt[M_UNLINK_MSG],ReqTmp);
		 }
	  }
   }

   return gotone;
}


/*****************************************************************************/
/* Mark first unmarked line of file as done (comment it out)				 */
/*****************************************************************************/

static void mark_done(char *fname)
{
   byte linebuf[128];
   FILE *fh;
   long pos;

   if (dexists(fname))
   {
	  errno = 0;
	  fh = fopen(fname,read_binary_plus);
	  if (!j_error(msgtxt[M_OPEN_MSG],fname))
	  {
		 while (!feof(fh))
		 {
			pos = ftell(fh);
			j_error(msgtxt[M_SEEK_MSG],fname);
			if (!fgets(linebuf,(int)sizeof(linebuf),fh))
			   break;
			if (linebuf[0] != ';')
			{
			   fseek(fh,pos,SEEK_SET);
			   j_error(msgtxt[M_SEEK_MSG],fname);
			   fputc(';',fh);
			   j_error(msgtxt[M_WRITE_MSG],fname);
			   break;
			}
		 }
		 fclose(fh);
		 j_error(msgtxt[M_CLOSE_MSG],fname);
	  }
   }
}
