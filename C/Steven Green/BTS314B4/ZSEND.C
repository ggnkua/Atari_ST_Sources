/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*                    Zmodem file transmission module                       */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*                                                                          */
/*  This module is based largely on a similar module in OPUS-CBCS V1.03b.   */
/*  The original work is (C) Copyright 1986, Wynn Wagner III. The original  */
/*  authors have graciously allowed us to use their code in this work.      */
/*                                                                          */
/*--------------------------------------------------------------------------*/


#include <stdio.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>
#endif
#include <ctype.h>
#include <time.h>
#ifdef LATTICE
#define ultoa(v,s,r) (stcul_d(s,v),s)
#include <errno.h>
#else
#include <io.h>
#endif
#include <stdlib.h>
#include <conio.h>
#include <string.h>

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "zmodem.h"
#include "com.h"
#include "vfossil.h"
#include "session.h"
#include "wazoo.h"

/*--------------------------------------------------------------------------*/
/* Private routines                                                         */
/*--------------------------------------------------------------------------*/
static void ZS_SendBinaryHeader (unsigned short, byte *);
static void ZS_32SendBinaryHeader (unsigned short, byte *);
static void ZS_SendData (register byte *, size_t, unsigned short);
static void ZS_32SendData (byte *, size_t, unsigned short);
static void ZS_SendByte (byte);
static int ZS_GetReceiverInfo (void);
static int ZS_SendFile (size_t, int);
static int ZS_SendFileData (int);
static int ZS_SyncWithReceiver (int);
static void ZS_EndSend (void);

/*--------------------------------------------------------------------------*/
/* Private data                                                             */
/*--------------------------------------------------------------------------*/
static FILE *Infile;                             /* Handle of file being sent */
static long Strtpos;                             /* Starting byte position of */

 /* download                 */
static long LastZRpos;                           /* Last error location      */
static long ZRPosCount;                          /* ZRPOS repeat count       */
static long Txpos;                               /* Transmitted file position */
static int Rxbuflen;                             /* Receiver's max buffer    */

 /* length                   */
static int Rxflags;                              /* Receiver's flags         */

/*--------------------------------------------------------------------------*/
/* SEND ZMODEM (send a file)                                                */
/*   returns TRUE (1) for good xfer, FALSE (0) for bad                      */
/*   sends one file per call; 'fsent' flags start and end of batch          */
/*--------------------------------------------------------------------------*/
int Send_Zmodem (char *fname, char *alias, int fsent, int wazoo)
        {       register byte *p;
                register byte *q;
                struct stat f;
                int i;
        int rc = TRUE;
        char j[100];

#ifdef ZDEBUG
                if(debugging_log)
                        show_debug_name ("send_Zmodem");
#endif
#ifdef DEBUG
                if(debugging_log)
                status_line(">send_Zmodem(%s,%s,%d,%d)",
                        fname ? fname : "NULL",
                        alias ? alias : "NULL",
                        fsent, wazoo);
#endif

/*                _BRK_DISABLE ();    Like PC*/
        IN_XON_ENABLE ();

        z_size = 0;
        Infile = NULL;
/*        rc = TRUE;   Like PC */


        if (fname && !(fullscreen && un_attended))
      /*set_xy ("")*/;
        switch (fsent)
                        {  
/*     case 0: Z_PutString ("rz\r");  Like PC */
            case 0: Z_PutString ((byte *)"rz\r");

#ifdef NEW
                          case EMPTY_BATCH:
#endif
                                        Z_PutLongIntoHeader (0L);
/*                                   Z_SendHexHeader (ZRQINIT, Txhdr);  Like PC */
                                   Z_SendHexHeader (ZRQINIT, (byte *)Txhdr);

                                  /* Fall through */

        case NOTHING_TO_DO:
                                        Rxtimeout = 200;
                                        if (ZS_GetReceiverInfo () == ERROR)
                                                {       XON_DISABLE ();
                                            XON_ENABLE ();
#ifdef DEBUG
                                                                                if(debugging_log)
                                                                                        status_line(">GetReceiver returned ERROR");
#endif
                                        return FALSE;
                                          }
#ifdef NEW
                                                                CLEAR_OUTBOUND();
                                                                CLEAR_INBOUND();
#endif
            
            }

                Rxtimeout = (int) (614400L / (long) cur_baud);

        if (Rxtimeout < 100)
      Rxtimeout = 100;

        if (fname == NULL)
      goto Done;

   /*--------------------------------------------------------------------*/
   /* Prepare the file for transmission.  Just ignore file open errors   */
   /* because there may be other files that can be sent.                 */
   /*--------------------------------------------------------------------*/
        Filename = fname;
        CLEAR_IOERR ();
        if ((Infile = fopen (Filename, read_binary)) == NULL)
      { (void) got_error (msgtxt[M_OPEN_MSG], Filename);
        XON_DISABLE ();
        XON_ENABLE ();
        return OK;
      }
                if (isatty (fileno (Infile)))
      { errno = 1;
        (void) got_error (msgtxt[M_DEVICE_MSG], Filename);
        fclose (Infile);
        XON_DISABLE ();
        XON_ENABLE ();
              return OK;
      }

   /*--------------------------------------------------------------------*/
   /* Send the file                                                      */
   /*--------------------------------------------------------------------*/
                rc = TRUE;

   /*--------------------------------------------------------------------*/
   /* Display outbound filename, size, and ETA for sysop                 */
   /*--------------------------------------------------------------------*/

#ifdef ATARIST
        stat(Filename, &f);
#else
        fstat (fileno (Infile), &f);
#endif   

        i = (int) (f.st_size * 10 / cur_baud + 53) / 54;
#ifdef NEW
                if(alias)
                        sprintf (j, "Z-Send %s (%s), %ldb, %d min.", Filename, alias, f.st_size, i);
                else
#endif
                sprintf (j, "Z-Send %s, %ldb, %d min.", Filename, f.st_size, i);
        file_length = f.st_size;

        if (un_attended && fullscreen)
      { clear_filetransfer ();
        sb_move (filewin, 1, 2);
        sb_puts (filewin, j);
              elapse_time ();
            sb_move (filewin, 2, 69);
          sprintf (j, "%3d min", i);
        sb_puts (filewin, j);
              sb_show ();
      }
        else
      { printf ("%s", j);
        set_xy (NULL);
              locate_x += 2;
      }

   /*--------------------------------------------------------------------*/
   /* Get outgoing file name; no directory path, lower case              */
   /*--------------------------------------------------------------------*/
        for (p = (alias != NULL) ? alias : Filename, q = Txbuf; *p;)
      { if ((*p == '/') || (*p == '\\') || (*p == ':'))
                q = Txbuf;
              else *q++ = tolower (*p);
        p++;
      }

        *q++ = '\0';
        p = q;

   /*--------------------------------------------------------------------*/
   /* Zero out remainder of file header packet                           */
   /*--------------------------------------------------------------------*/
        while (q < (Txbuf + KSIZE))
      *q++ = '\0';

   /*--------------------------------------------------------------------*/
   /* Store filesize, time last modified, and file mode in header packet */
   /*--------------------------------------------------------------------*/
        sprintf (p, "%lu %lo %ho", f.st_size, f.st_mtime, f.st_mode);

   /*--------------------------------------------------------------------*/
   /* Transmit the filename block and the download                 */
   /*--------------------------------------------------------------------*/
        throughput (0, 0L);

   /*--------------------------------------------------------------------*/
   /* Check the results                                                  */
   /*--------------------------------------------------------------------*/
        switch (ZS_SendFile (1 + strlen (p) + (p - Txbuf), wazoo))
      { case ERROR:
         /*--------------------------------------------------*/
         /* Something tragic happened                        */
         /*--------------------------------------------------*/
#ifdef DEBUG
                                                                                status_line("#Unknown Zmodem error");
#endif
                                                         goto Err_Out;

              case OK:
         /*--------------------------------------------------*/
         /* File was sent                                    */
         /*--------------------------------------------------*/
                                                        CLEAR_IOERR ();
                                                        fclose (Infile);
                                                        Infile = NULL;

                                                        status_line ("%s-Z%s %s", msgtxt[M_FILE_SENT], Crc32t ? "/32" : "", Filename);

                                                        update_files (1);
                                                  goto Done;

        case ZSKIP:
                                                        status_line (msgtxt[M_REMOTE_REFUSED], Filename);
                                                        rc = SPEC_COND;
                                                        goto Done;

              default:
         /*--------------------------------------------------*/
         /* Ignore the problem, get next file, trust other   */
         /* error handling mechanisms to deal with problems  */
         /*--------------------------------------------------*/
#ifdef DEBUG
                                                                                if(debugging_log)
                                                                                        status_line(">Default Zmodem error");
#endif
                                                        goto Done;
                        }   /* switch */

Err_Out:
        rc = FALSE;

Done:
        if (Infile)
      fclose (Infile);

        if (fsent < 0)
      ZS_EndSend ();

        XON_DISABLE ();
        XON_ENABLE ();
        return rc;
        }                                                /* send_Zmodem */

/*--------------------------------------------------------------------------*/
/* ZS SEND BINARY HEADER                                                    */
/* Send ZMODEM binary header hdr of type type                               */
/*--------------------------------------------------------------------------*/
static void ZS_SendBinaryHeader (unsigned short type,register byte *hdr)
{  register unsigned short crc;
   int n;

#ifdef ZDEBUG
        if(debugging_log)
                show_debug_name ("ZS_SendBinaryHeader");
#endif

   BUFFER_BYTE (ZPAD);
   BUFFER_BYTE (ZDLE);

   if (Crc32t = Txfcs32)
      ZS_32SendBinaryHeader (type, hdr);
   else
      {
      BUFFER_BYTE (ZBIN);
      ZS_SendByte ((byte) type);

      crc = Z_UpdateCRC (type, 0);

      for (n = 4; n-- ;)
         {
         ZS_SendByte (*hdr);
         crc = Z_UpdateCRC (*hdr++, crc);
         }
      ZS_SendByte ((byte) (crc >> 8));
      ZS_SendByte ((byte) crc);

      UNBUFFER_BYTES ();
      }

   if (type != ZDATA)
      {
      while (CARRIER && !OUT_EMPTY ())
         time_release ();
      if (!CARRIER)
         CLEAR_OUTBOUND ();
      }
}                                                /* ZS_SendBinaryHeader */

/*--------------------------------------------------------------------------*/
/* ZS SEND BINARY HEADER                                                    */
/* Send ZMODEM binary header hdr of type type                               */
/*--------------------------------------------------------------------------*/
static void ZS_32SendBinaryHeader (unsigned short type,register byte *hdr)
{  unsigned long crc;
   int n;

#ifdef ZDEBUG
   if(debugging_log)
                show_debug_name ("ZS_32SendBinaryHeader");
#endif

   BUFFER_BYTE (ZBIN32);
   ZS_SendByte ((byte) type);

   crc = 0xFFFFFFFF;
   crc = Z_32UpdateCRC (type, crc);

   for (n = 4; n--;)
      {
      ZS_SendByte (*hdr);
      crc = Z_32UpdateCRC (((unsigned short) (*hdr++)), crc);
      }

   crc = ~crc;
   for (n = 4; n--;)
      {
      ZS_SendByte ((byte) crc);
      crc >>= 8;
      }

   UNBUFFER_BYTES ();
}                                                /* ZS_SendBinaryHeader */

/*--------------------------------------------------------------------------*/
/* ZS SEND DATA                                                             */
/* Send binary array buf with ending ZDLE sequence frameend                 */
/*--------------------------------------------------------------------------*/
static void ZS_SendData (register byte *buf, size_t length, unsigned short frameend)
{       register unsigned short crc;

#ifdef ZDEBUG
   if(debugging_log)
                show_debug_name ("ZS_SendData");
#endif

   if (Crc32t)
      ZS_32SendData (buf, length, frameend);
   else
      {
      crc = 0;
      for (; length--;)
         {
         ZS_SendByte (*buf);
         crc = Z_UpdateCRC (*buf++, crc);
         }

      BUFFER_BYTE (ZDLE);
      BUFFER_BYTE ((unsigned char) frameend);
      crc = Z_UpdateCRC (frameend, crc);
      ZS_SendByte ((byte) (crc >> 8));
      ZS_SendByte ((byte) crc);

      UNBUFFER_BYTES ();

      }

   if (frameend == ZCRCW)
      {
      SENDBYTE (XON);
      while (CARRIER && !OUT_EMPTY ())
         time_release ();
      if (!CARRIER)
         CLEAR_OUTBOUND ();
      }
}                                                /* ZS_SendData */

/*--------------------------------------------------------------------------*/
/* ZS SEND DATA with 32 bit CRC                                             */
/* Send binary array buf with ending ZDLE sequence frameend                 */
/*--------------------------------------------------------------------------*/
static void ZS_32SendData (byte *buf, size_t length, unsigned short frameend)
{       unsigned long crc;

#ifdef ZDEBUG
   if(debugging_log)
                show_debug_name ("ZS_32SendData");
#endif

   crc = 0xFFFFFFFF;
   for (; length--; ++buf)
      {
      ZS_SendByte (*buf);
      crc = Z_32UpdateCRC (*buf, crc);
      }

   BUFFER_BYTE (ZDLE);
   BUFFER_BYTE ((unsigned char) frameend);
   crc = Z_32UpdateCRC (frameend, crc);

   crc = ~crc;
   for (length = 4; length--;)
      {
      ZS_SendByte ((byte) crc);
      crc >>= 8;
      }

   UNBUFFER_BYTES ();
}                                                /* ZS_SendData */

/*--------------------------------------------------------------------------*/
/* ZS SEND BYTE                                                             */
/* Send character c with ZMODEM escape sequence encoding.                   */
/* Escape XON, XOFF. Escape CR following @ (Telenet net escape)             */
/*--------------------------------------------------------------------------*/
static void ZS_SendByte (register byte c)
{  static byte lastsent;

   switch (c)
      {
      case 015:
      case 0215:
         if ((lastsent & 0x7F) != '@')
            goto SendIt;
      case 020:
      case 021:
      case 023:
      case 0220:
      case 0221:
      case 0223:
      case ZDLE:
         /*--------------------------------------------------*/
         /* Quoted characters                                */
         /*--------------------------------------------------*/
         BUFFER_BYTE (ZDLE);
         c ^= 0x40;

      default:
         /*--------------------------------------------------*/
         /* Normal character output                          */
         /*--------------------------------------------------*/
   SendIt:
         BUFFER_BYTE (lastsent = c);

      }                                          /* switch */
}                                                /* ZS_SendByte */

/*--------------------------------------------------------------------------*/
/* ZS GET RECEIVER INFO                                                     */
/* Get the receiver's init parameters                                       */
/*--------------------------------------------------------------------------*/
static int ZS_GetReceiverInfo ()
{  int n;
#ifdef ZDEBUG
   if(debugging_log)
                show_debug_name ("ZS_GetReceiverInfo");
#endif

   for (n = 10; n--;)
      {
/*      switch (Z_GetHeader (Rxhdr))  Like PC */
          switch (Z_GetHeader ((byte *)Rxhdr))
         {
         case ZCHALLENGE:
            /*--------------------------------------*/
            /* Echo receiver's challenge number     */
            /*--------------------------------------*/
            Z_PutLongIntoHeader (Rxpos);
/*             Z_SendHexHeader (ZACK, Txhdr);  Like PC */
            Z_SendHexHeader (ZACK, (byte *)Txhdr);
            continue;

         case ZCOMMAND:
            /*--------------------------------------*/
            /* They didn't see our ZRQINIT          */
            /*--------------------------------------*/
            Z_PutLongIntoHeader (0L);
/*            Z_SendHexHeader (ZRQINIT, Txhdr);   Like PC */
            Z_SendHexHeader (ZRQINIT, (byte *)Txhdr);
            continue;

         case ZRINIT:
            /*--------------------------------------*/
            /* */
            /*--------------------------------------*/
            Rxflags = 0377 & Rxhdr[ZF0];
            Rxbuflen = ((word) Rxhdr[ZP1] << 8) | Rxhdr[ZP0];
            Txfcs32 = Rxflags & CANFC32;
            return OK;

         case ZCAN:
         case RCDO:
         case TIMEOUT:
            return ERROR;

         case ZRQINIT:
            if (Rxhdr[ZF0] == ZCOMMAND)
               continue;

         default:
/*            Z_SendHexHeader (ZNAK, Txhdr);  Like PC */
            Z_SendHexHeader (ZNAK, (byte *)Txhdr);
            continue;
         }                                       /* switch */
      }                                          /* for */

   return ERROR;
}                                                /* ZS_GetReceiverInfo */

/*--------------------------------------------------------------------------*/
/* ZS SEND FILE                                                             */
/* Send ZFILE frame and begin sending ZDATA frame                           */
/*--------------------------------------------------------------------------*/
static int ZS_SendFile (size_t blen, int wazoo)
{
        register int c;
        long t;
int szmdm;
/*,filepos,sendcrc;
        int fileread;
BS Don't need this now */
#ifdef ZDEBUG
        if(debugging_log)
                show_debug_name ("ZS_SendFile");
#endif

        for(;;)
        {
                if (got_ESC ())
                {
                        CLEAR_OUTBOUND ();
                        XON_DISABLE ();                         /* Make sure xmitter is unstuck */
                        send_can ();                            /* transmit at least 10 cans    */
                        t = timerset (200);                     /* wait no more than 3 seconds  */
                        while (!timeup (t) && !OUT_EMPTY () && CARRIER)
                        time_release ();                                                /* Give up slice while waiting  */
                        XON_ENABLE ();                          /* Turn XON/XOFF back on...     */
                        z_log (msgtxt[M_KBD_MSG]);
                        return ERROR;
                }
                else if (!CARRIER)
                        return ERROR;

                Txhdr[ZF0] = LZCONV;             /* Default file conversion */
                Txhdr[ZF1] = LZMANAG;            /* Default file management */
                Txhdr[ZF2] = LZTRANS;            /* Default file transport      */
                Txhdr[ZF3] = 0;
 
/*                ZS_SendBinaryHeader (ZFILE, Txhdr);  Like PC */
                ZS_SendBinaryHeader (ZFILE, (byte *)Txhdr);
                ZS_SendData (Txbuf, blen, ZCRCW);

Again:
                szmdm = 1;
                if (szmdm)
                SENDBYTE (021);
                switch (c = Z_GetHeader(Rxhdr) )
                {       
                
                        /*
                        **      Maybe this can fix problems with FD. The break only
                        **  fixes the FD problem but causes a Resend on the first
                        **  DATA block. The second (original) code doesn't have
                        **  Resend problems but probably the ESC problem again.
                        **  I set the timeout in the loop from 0,5sec to 2sec.
                        **  Maybe this fixes the FD problem also.
                        **
                        
                        case ZRINIT:
                                if (FDBugfix)
                                        break;
                                else
                                {
                                                while ((c = Z_GetByte (200)) > 0)
                                                if (c == ZPAD)
                                                        goto Again;
                                } BS now make it look like this*/

           case ZRINIT:
            status_line ("!case is ZRINIT", c);
            if (FDBugfix)
                    break;
/*              else
              {  */
              while ((c = Z_GetByte (50)) > 0)
              if (c == ZPAD)
            goto Again;
/*               } */
            status_line ("!Test C = %d", c);
    
/* BS do this  */
            default :
             status_line ("!Default C = %d", c);
               continue;
                                
                        case ZCAN:
                        case RCDO:
                        case TIMEOUT:
                        case ZFIN:
                        case ZABORT:
                                return ERROR;

/*                      case ZCRC: 
                                filepos = ftell(Infile);
                                status_line ("!Zmodem: Calculating CRC");
                                rewind(Infile);
                                sendcrc = 0xffffffffL;
                                while ( (fileread=getc(Infile))!=EOF )
                                        Z_32UpdateCRC (fileread,sendcrc);
                                sendcrc = ~sendcrc;
                                Z_PutLongIntoHeader(sendcrc);
                                Z_SendHexHeader(ZCRC, Txhdr);
                                fseek(Infile,filepos,SEEK_SET);
                                status_line ("!Zmodem: CRC is sent");
                                goto Again;
BS try taking this out... */                                                                  
                        case ZSKIP:
                                return c;
                                
                        case ZRPOS:
                                fseek (Infile, Rxpos, SEEK_SET);
                                if (Rxpos != 0L)
                                {
                                        status_line (msgtxt[M_SYNCHRONIZING_OFFSET], Rxpos);
                                        CLEAR_OUTBOUND ();                /* Get rid of queued data */
                                        XON_DISABLE ();                   /* End XON/XOFF restraint */
                                        SENDBYTE (XON);                   /* Send XON to remote     */
                                        XON_ENABLE ();                    /* Start XON/XOFF again   */
                                }
                                LastZRpos = Strtpos = Txpos = Rxpos;
                                ZRPosCount = 10;
                                CLEAR_INBOUND ();
                                return ZS_SendFileData (wazoo);
/*                              
                        default:
                                status_line ("!Zmodem: Unknown Header error %u",c);
BS did this earlier. */                              
                }                                                                               /* switch */
        }                                                                                       /* for */
}                                                                                               /* ZS_SendFile */

/*--------------------------------------------------------------------------*/
/* ZS SEND FILE DATA                                                        */
/* Send the data in the file                                                */
/*--------------------------------------------------------------------------*/
static int ZS_SendFileData (int wazoo)
{  register int c, e;
   size_t tsize;
   int i;
   char j[100];
   word goodblks = 0, goodneeded = 1;
   size_t newcnt, maxblklen;    
#ifndef NEW
        size_t blklen;
#endif

   long t;

#ifdef ZDEBUG
   if(debugging_log)
                show_debug_name ("ZS_SendFileData");
#endif

  maxblklen = ((cur_baud >= 0) && (cur_baud < 300)) ? 128 : cur_baud / 300 * 256;

   if (maxblklen > WAZOOMAX)
      maxblklen = WAZOOMAX;
   if (!wazoo && maxblklen > KSIZE)
      maxblklen = KSIZE;
   if (Rxbuflen && maxblklen > Rxbuflen)
      maxblklen = Rxbuflen;

   if (wazoo && (remote_capabilities & ZED_ZIPPER))
      maxblklen = KSIZE;

#ifdef NEW /* ZMODEMBLOCKLEN */
   if (!blklen)
      {
      if (small_window && (mdm_reliable[0]=='\0'))
         {
         blklen     = ((maxblklen >> 3) > 64) ? maxblklen >> 3 : 64;
         goodneeded = 6;
         }
      else
        {
/*           blklen = maxblklen;   JS */
           blklen = KSIZE;
           goodneeded = 1;
         }
      }
#else
   blklen = maxblklen;
#endif

SomeMore:
   if (CHAR_AVAIL ())
      {
WaitAck:
      switch (c = ZS_SyncWithReceiver (1))
         {
         case ZSKIP:
            /*-----------------------------------------*/
            /* Skip this file                          */
            /*-----------------------------------------*/
            return c;

         case ZACK:
            break;

         case ZRPOS:
            /*-----------------------------------------*/
            /* Resume at this position                 */
            /*-----------------------------------------*/
            blklen = ((blklen >> 2) > 64) ? blklen >> 2 : 64;
            goodblks = 0;
            goodneeded = ((goodneeded << 1) > 16) ? 16 : goodneeded << 1;
            break;

         case ZRINIT:
            /*-----------------------------------------*/
            /* Receive init                            */
            /*-----------------------------------------*/
            if (locate_y && !(fullscreen && un_attended))
               gotoxy (2, (byte) locate_y - 1);
            throughput (1, Txpos - Strtpos);
            return OK;

         case TIMEOUT:
            /*-----------------------------------------*/
            /* Timed out on message from other side    */
            /*-----------------------------------------*/
            break;

         default:
            z_log (msgtxt[M_CAN_MSG]);
            fclose (Infile);
            return ERROR;
         }                                       /* switch */

      /*
       * Noise probably got us here. Odds of surviving are not good. But we
       * have to get unstuck in any event. 
       *
       */

      Z_UncorkTransmitter ();
      SENDBYTE (XON);

      while (CHAR_AVAIL ())
         {
         switch (MODEM_IN ())
            {
            case CAN:
            case RCDO:
            case ZPAD:
               goto WaitAck;
            }                                    /* switch */
         }                                       /* while */
      }                                          /* while */

   newcnt = Rxbuflen;
   Z_PutLongIntoHeader (Txpos);
   ZS_SendBinaryHeader (ZDATA, Txhdr);

   do
      {
      if (got_ESC ())
         {
         CLEAR_OUTBOUND ();
         XON_DISABLE ();                         /* Make sure xmitter is
                                                  * unstuck */
         send_can ();                            /* transmit at least 10 cans    */
         t = timerset (200);                     /* wait no more than 2
                                                  * seconds  */
         while (!timeup (t) && !OUT_EMPTY () && CARRIER)
            time_release ();                     /* Give up slice while
                                                  * waiting  */
         XON_ENABLE ();                          /* Turn XON/XOFF back on...     */
         z_log (msgtxt[M_KBD_MSG]);
         goto oops;
         }
                        else if (!CARRIER)
                                goto oops;              /* ssl - St.Slabihoud */

      if ((tsize = fread (Txbuf, 1, (size_t) blklen, Infile)) != z_size)
         {
         if (fullscreen && un_attended)
            {
            sb_move (filewin, 2, 12);
            sb_puts (filewin, ultoa (((unsigned long) (z_size = tsize)), e_input, 10));
            sb_puts (filewin, "    ");
            elapse_time ();
            sb_show ();
            }
         else
            {
            gotoxy (locate_x + 10, locate_y);
            cputs (ultoa (((unsigned long) (z_size = tsize)), e_input, 10));
            putch (' ');
            }
         }

      if (tsize < blklen)
         e = ZCRCE;
      else if (Rxbuflen && (newcnt -= tsize) <= 0)
         e = ZCRCW;
      else e = ZCRCG;

      ZS_SendData (Txbuf, tsize, e);

      i = (int) ((file_length - Txpos) * 10 / cur_baud + 53) / 54;
      sprintf (j, "%3d min", i);

      if (fullscreen && un_attended)
         {
         sb_move (filewin, 2, 2);
         sb_puts (filewin, ultoa (((unsigned long) Txpos), e_input, 10));
         sb_puts (filewin, "  ");
         sb_move (filewin, 2, 69);
         sb_puts (filewin, j);
         elapse_time ();
         sb_show ();
         }
      else
         {
         gotoxy (locate_x, locate_y);
         cputs (ultoa (((unsigned long) Txpos), e_input, 10));
         putch (' ');
         putch (' ');
         gotoxy (locate_x + 20, locate_y);
         printf ("%s", j);
         putch (' ');
         }

      Txpos += tsize;
      if (blklen < maxblklen && ++goodblks > goodneeded)
         {
         blklen = ((blklen << 1) < maxblklen) ? blklen << 1 : maxblklen;
         goodblks = 0;
         }

      if (e == ZCRCW)
         goto WaitAck;

      while (CHAR_AVAIL ())
         {
         switch (MODEM_IN ())
            {
            case CAN:
            case RCDO:
            case ZPAD:
               /*--------------------------------------*/
               /* Interruption detected;               */
               /* stop sending and process complaint   */
               /*--------------------------------------*/
               z_message (msgtxt[M_TROUBLE]);
               CLEAR_OUTBOUND ();
               ZS_SendData (Txbuf, 0, ZCRCE);
               goto WaitAck;
            }                                    /* switch */
         }                                       /* while */

      }                                          /* do */
   while (e == ZCRCG);

   while (1)
      {
      Z_PutLongIntoHeader (Txpos);
      ZS_SendBinaryHeader (ZEOF, Txhdr);

      switch (c = ZS_SyncWithReceiver (7))
         {
         case ZACK:
            continue;
         case ZRPOS:
            /*-----------------------------------------*/
            /* Resume at this position...              */
            /*-----------------------------------------*/
            goto SomeMore;
         case ZRINIT:
            /*-----------------------------------------*/
            /* Receive init                            */
            /*-----------------------------------------*/
            if (locate_y && !(fullscreen && un_attended))
               gotoxy (2, (byte) locate_y - 1);
            throughput (1, Txpos - Strtpos);
            return OK;
         case ZSKIP:
            /*-----------------------------------------*/
            /* Request to skip the current file        */
            /*-----------------------------------------*/
            z_log (msgtxt[M_SKIP_MSG]);
            CLEAR_IOERR ();
            fclose (Infile);
            return c;
         default:
      oops:
            z_log (msgtxt[M_CAN_MSG]);
            fclose (Infile);
            return ERROR;
         }                                       /* switch */
      }                                          /* while */
}                                                /* ZS_SendFileData */

/*--------------------------------------------------------------------------*/
/* ZS SYNC WITH RECEIVER                                                    */
/* Respond to receiver's complaint, get back in sync with receiver          */
/*--------------------------------------------------------------------------*/
static int ZS_SyncWithReceiver (int num_errs)
{  register int c;
   char j[50];

#ifdef ZDEBUG
   if(debugging_log)
                show_debug_name ("ZS_SyncWithReceiver");
#endif

   while (1)
      {
      c = Z_GetHeader (Rxhdr);
      CLEAR_INBOUND ();
      switch (c)
         {
         case TIMEOUT:
            z_message (msgtxt[M_TIMEOUT]);
            if ((num_errs--) >= 0)
               break;

         case ZCAN:
         case ZABORT:
         case ZFIN:
         case RCDO:
            z_log (msgtxt[M_ERROR]);
            return ERROR;

         case ZRPOS:
            if (Rxpos == LastZRpos)              /* Same as last time?    */
               {
               if (!(--ZRPosCount))              /* Yup, 10 times yet?    */
                  return ERROR;                  /* Too many, get out     */
               }
            else ZRPosCount = 10;                /* Reset repeat count    */
            LastZRpos = Rxpos;                   /* Keep track of this    */

            rewind (Infile);                     /* In case file EOF seen */
            fseek (Infile, Rxpos, SEEK_SET);
            Txpos = Rxpos;
            sprintf (j, msgtxt[M_RESENDING_FROM],
                     ultoa (((unsigned long) (Txpos)), e_input, 10));
            z_message (j);
            return c;

         case ZSKIP:
            z_log (msgtxt[M_SKIP_MSG]);

         case ZRINIT:
            CLEAR_IOERR ();
            fclose (Infile);
            return c;

         case ZACK:
            z_message (NULL);
            return c;

         default:
            z_message (IDUNNO_msg);
            ZS_SendBinaryHeader (ZNAK, Txhdr);
            continue;
         }                                       /* switch */
      }                                          /* while */
}                                                /* ZS_SyncWithReceiver */




/*--------------------------------------------------------------------------*/
/* ZS END SEND                                                              */
/* Say BIBI to the receiver, try to do it cleanly                           */
/*--------------------------------------------------------------------------*/
static void ZS_EndSend ()
{
#ifdef ZDEBUG
    if(debugging_log)
        show_debug_name ("ZS_EndSend");
#endif

   while (1)
   {
#ifdef NEW
           CLEAR_OUTBOUND();
        CLEAR_INBOUND();
#endif
      Z_PutLongIntoHeader (0L);
      ZS_SendBinaryHeader (ZFIN, Txhdr);

      switch (Z_GetHeader (Rxhdr))
      {
      case ZFIN:
         SENDBYTE ('O');
         SENDBYTE ('O');
         while (CARRIER && !OUT_EMPTY ())
            time_release ();
         if (!CARRIER)
            CLEAR_OUTBOUND ();
         /* fallthrough... */
      case ZCAN:
      case RCDO:
      case TIMEOUT:
         return;
      }                                       /* switch */
#ifdef ZDEBUG
                if(debugging_log)
                        show_debug_name("ZS_EndSend... looping");
#endif
   }                                          /* while */
}                                             /* ZS_EndSend */
