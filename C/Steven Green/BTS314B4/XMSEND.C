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
/*                  This module was written by Bob Hartman                  */
/*                                                                          */
/*                                                                          */
/*                 BinkleyTerm Xmodem Sender State Machine                  */
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
/*--------------------------------------------------------------------------*/

/* #define XDEBUG */

/* System include files */
#ifdef __TOS__
/* #pragma warn -sus */
#else
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif
#include <stdio.h>
#ifdef LATTICE
#define ultoa(v,s,r) (stcul_d(s,v),s)
#else
#include <io.h>
#endif
#include <stdlib.h>
#include <conio.h>
#include <string.h>

#ifdef __TURBOC__
#ifdef __TOS__
#include <ext.h>
#else
#include <mem.h>
#endif
#else
#ifndef LATTICE
#include <memory.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "defines.h"
#include "ascii.h"
#include "vfossil.h"

void Build_Header_Block( XMARGSP args, char type )
{
   struct FILEINFO dta;
	SEADATAP ttmp;

   (void) dfind (&dta, args->filename, 0);
	args->save_header = type;
	ttmp = (SEADATAP) &args->datablock;

	(void) memset (ttmp, 0, sizeof (XMDATA));
	args->header = type;
	ttmp->block_num = 0;
	ttmp->block_num_comp = 0xff;
#ifdef GENERIC
	ttmp->filelength[0] = args->filelen & 0xff;
	ttmp->filelength[1] = (args->filelen >> 8) & 0xff;
	ttmp->filelength[2] = (args->filelen >> 16) & 0xff;
	ttmp->filelength[3] = (args->filelen >> 24) & 0xff;
#else
	ttmp->filelength = args->filelen;
#endif	
   (void) strcpy (ttmp->sendingprog, xfer_id);
	if (type == SYN)
		{
	   (void) memset (ttmp->filename, ' ', 16);
#ifdef GENERIC
	/* NB This is probably a bit ST specific */
		ttmp->date[0] = dta.time & 0xff;
		ttmp->date[1] = (dta.time >> 8) & 0xff;
		ttmp->time[0] = (dta.time >> 16) & 0xff;
		ttmp->time[1] = (dta.time >> 24) & 0xff;
#else
		ttmp->timedate = dta.time;
#endif		
		/* This is the CRC bit in the TeLink header */
		ttmp->Resync = 1;
		}
	else
		{
#ifdef GENERIC		
	/* NB This is probably a bit ST specific */
		ttmp->date[0] = args->save_filetime.twowords.date & 0xff;
		ttmp->date[1] = args->save_filetime.twowords.date & 0xff;
		ttmp->time[0] = (args->save_filetime.twowords.time >> 8) & 0xff;
		ttmp->time[1] = (args->save_filetime.twowords.time >> 8) & 0xff;
#else
		ttmp->timedate = args->save_filetime.oneword.timedate;
#endif		
		ttmp->SLO = (unsigned char) (((cur_baud >= 9600) && !no_overdrive)? 1 : 0);
		ttmp->Resync = (unsigned char) (no_resync ? 0 : 1);
		ttmp->MACFLOW = 1;
		}
	if (args->temp_name != NULL)
		(void) strncpy (ttmp->filename, args->temp_name, strlen (args->temp_name));
	else
		(void) strncpy (ttmp->filename, (char *) (dta.name), strlen (dta.name));
}

void XSSetVars( XMARGSP args );
int cdecl XSInit( XMARGSP args, int start_state );
int cdecl XSEnd( XMARGSP args, int cur_state );
int cdecl XSXmtStart( XMARGSP args );
int cdecl XSXmTeStrt( XMARGSP args );
int cdecl XSCheckACK( XMARGSP args );
int cdecl XSSendBlk( XMARGSP args );
int cdecl XSWaitEnd( XMARGSP args );

STATES Xmodem_Sender[] = {
   { "XSInit", ( void *)XSInit },
   { "XSEnd", ( void *)XSEnd },
   { "XS0", ( void *)XSXmtStart },
   { "XS0T", ( void *)XSXmTeStrt },
   { "XS1", ( void *)XSCheckACK },
   { "XS2", ( void *)XSSendBlk },
   { "XS3", ( void *)XSWaitEnd }
};

int cdecl XSInit( XMARGSP args, int start_state)
{
	struct stat st;
	char junkbuff[100];

	/* Get the file information */
	if (stat (args->filename, &st))
		{
/* Print error message */
		return (OPEN_ERR);
		}

	if ((args->file_pointer = fopen (args->filename, read_binary)) == NULL)
		{
/* Print error message */
		return (OPEN_ERR);
		}

	/* Get important information out of it */
	args->filelen = st.st_size;
	args->LastBlk = (st.st_size + 127) / 128;
	args->save_filetime.oneword.timedate = st.st_atime;
	args->prev_bytes = 0L;
	args->tot_errs = 0;

   (void) sprintf (junkbuff, msgtxt[M_SEND_MSG], args->LastBlk, args->filename, st.st_size);
   if (un_attended && fullscreen)
      {
      clear_filetransfer ();
      sb_move (filewin, 1, 2);
      sb_puts (filewin, (unsigned char *) junkbuff);
      elapse_time ();
      sb_show ();
      }
   else
      {
      status_line ("+%s", junkbuff);
      printf ("\n");
      }

   locate_y = wherey ();
   locate_x = wherex ();

	/* Start the throughput calculations */
	throughput (0, 0L);

   return (start_state);
}

int cdecl XSEnd( XMARGSP args, int cur_state )
{
   args->result = cur_state;

	/* Close file */
	fclose (args->file_pointer);

   if (args->tot_errs > 3)
      status_line (msgtxt[M_CORRECTED_ERRORS], args->tot_errs, args->LastBlk);

	/* Log that we sent it */
   if (cur_state == SUCCESS)
      {
      throughput (1, (unsigned long) (args->filelen - args->prev_bytes));
      status_line ("%s: %s", msgtxt[M_FILE_SENT], args->filename);
      update_files (1);
      }

   return (cur_state);
}

void XSSetVars( XMARGSP args )
{
   if (no_sealink)
      {
      args->options.SLO = 0;
      args->options.Resync = 0;
      }
   else
      {
      args->options.SLO = ((cur_baud >= 9600) && !no_overdrive) ? 1 : 0;
      args->options.Resync = (~no_resync) & 1;
      }

	args->options.SEAlink = 0;
	args->SendBLK = 1;
   args->curr_byte = 0L;
	args->NextBLK = 1;
	args->ACKST = 0;
	args->ACKBLK = -1L;
	args->Window = 1;
	args->ACKsRcvd = 0;
	args->NumNAK = 0;
	args->T1 = timerset (3000);
}

int cdecl XSXmtStart( XMARGSP args )
{
	XSSetVars (args);
	Build_Header_Block (args, SOH);
	return (XS1);
}

int cdecl XSXmTeStrt( XMARGSP args )
{
	XSSetVars (args);
	Build_Header_Block (args, SYN);
	return (XS1);
}

int cdecl XSCheckACK( XMARGSP args )
{
	Check_ACKNAK (args);
	return (XS2);
}

int cdecl XSSendBlk( XMARGSP args )
{
	if (!CARRIER)
		return (CARRIER_ERR);

   if (got_ESC ())
      {
      status_line (msgtxt[M_KBD_MSG]);
		return (KBD_ERR);
      }

	if ((args->NumNAK > 4) && (args->SendBLK == 0))
		{
		if (args->save_header == SOH)
			return (XS0T);
		else
			{
			args->NumNAK = 0;
			++(args->ACKBLK);
			++(args->SendBLK);
			return (XS2);
			}
		}

	if (args->NumNAK > 10)
		{
/* Too Many Errors */
		return (SEND_RETRY_ERR);
		}

	if (timeup (args->T1))
		{
/* Fatal Timeout */
		return (SEND_TIMEOUT);
		}

	if (args->SendBLK > (args->LastBlk + 1))
		return (XS3);

	if (args->SendBLK > (args->ACKBLK + args->Window))
		{
		time_release ();
		return (XS1);
		}

	if (args->SendBLK == (args->LastBlk + 1))
		{
		SENDBYTE (EOT);
		++(args->SendBLK);
		args->T1 = timerset (3000);
		show_sending_blocks (args);
		time_release ();
		return (XS1);
		}

	/*
		Increment the block count before sending because we read the next
		block immediately after sending this block.  On error free connects
		we have a big net win because we never do a seek, and while we are
		sending one block, we read the next.  If we do get errors, then we
		have to seek back to the previous block, and that will be a bother.
		With today's phone lines and modems, we'll assume error free is more
		often than not, and take our chances.
	*/
	if (args->options.SLO && args->options.SEAlink)
		{
		args->ACKBLK = args->SendBLK;
		}

	++(args->SendBLK);
   args->curr_byte += 128L;
	Send_Block (args);
	args->T1 = timerset (6000);
	return (XS1);
}

int cdecl XSWaitEnd( XMARGSP args )
{
	show_sending_blocks (args);

	if (args->ACKBLK < (args->LastBlk + 1))
		{
		time_release ();
		return (XS1);
		}

	if (!CARRIER)
		return (CARRIER_ERR);

	return (SUCCESS);
}

int SEAlink_Send_File( char *filename, char *sendname )
{
   XMARGS xm;

	xm.filename = filename;
	xm.temp_name = sendname;
   return (state_machine (Xmodem_Sender, &xm, XS0));
}

int Xmodem_Send_File( char *filename, char *sendname )
{
	return (SEAlink_Send_File (filename, sendname));
}

int Telink_Send_File( char *filename, char *sendname )
{
   XMARGS xm;

	xm.filename = filename;
	xm.temp_name = sendname;
   return (state_machine (Xmodem_Sender, &xm, XS0T));
}

void Get_Block( XMARGSP args )
{
	XMDATAP xtmp;

	if (args->SendBLK == 0)
		{
		Build_Header_Block (args, args->save_header);
		args->NextBLK = -1L;
		return;
		}

	xtmp = (XMDATAP) &args->datablock;

	/* Set up buffer as all ^Zs for EOF */
	(void) memset (xtmp, SUB, sizeof (XMDATA));

	/* Now set up the header stuff */
	args->header = SOH;
	xtmp->block_num = (unsigned char) (args->SendBLK & 0xff);
	xtmp->block_num_comp = ~xtmp->block_num;

	if (args->NextBLK != args->SendBLK)
		{
	   (void) fseek (args->file_pointer, (args->SendBLK - 1) * 128, SEEK_SET);
		}

	args->NextBLK = args->SendBLK + 1;

	/* Can we read any data? */
	if (fread ((char *) xtmp->data_bytes, 1, 128, args->file_pointer) <= 0)
		return;

	/* Looks good */
	return;
	}

void Send_Block( XMARGSP args )
{

#if 0
	if (args->datablock.header == SYN)
		{
	   Data_Check ((XMDATAP) &args->datablock, CHECKSUM);
		}
	else
		{
	   Data_Check ((XMDATAP) &args->datablock, args->options.do_CRC ? CRC : CHECKSUM);
		}

	if ((!(args->options.do_CRC)) || (args->datablock.header == SYN))
		{
      SENDCHARS ((char *) &args->datablock, sizeof (XMDATA) - 1, 1);
		}
	else
		{
      SENDCHARS ((char *) &args->datablock, sizeof (XMDATA), 1);
		}
#else
	if ((!(args->options.do_CRC)) || (args->header == SYN))
	{
	   Data_Check ((XMDATAP) &args->datablock, CHECKSUM);
#ifdef XDEBUG
		status_line(">sendblock: header=%02x, block=%02x|%02x, check=%02x",
			args->header, args->datablock.block_num, args->datablock.block_num_comp,
			args->datablock.data_check[0]);

#endif
	   SENDBYTE(args->header);
       SENDCHARS ((char *) &args->datablock, sizeof (XMDATA) - 1, 1);
	}
	else
	{
	   Data_Check ((XMDATAP) &args->datablock, CRC);
#ifdef XDEBUG
		status_line(">sendblock: header=%02x, block=%02x, check=%02x %02x",
			args->header, args->datablock.block_num,
			args->datablock.data_check[0],
			args->datablock.data_check[1]);
#endif
	   SENDBYTE(args->header);
       SENDCHARS ((char *) &args->datablock, sizeof (XMDATA), 1);
	}
#endif

   UNBUFFER_BYTES ();

	show_sending_blocks (args);

	Get_Block (args);
}

void show_num ( XMARGSP args, long b )
{
	if (b > args->LastBlk)
		{
		if (fullscreen && un_attended)
			sb_puts (filewin, "EOT");
		else
			cputs ("EOT");
		}
	else if (b >= 0L)
		{
		if (fullscreen && un_attended)
	      sb_puts (filewin, (unsigned char *) ultoa (((unsigned long) b), e_input, 10));
		else
	      (void) cputs (ultoa (((unsigned long) b), e_input, 10));
		}
}

void show_sending_blocks( XMARGSP args )
{
   char j[100];
   int i;
   long k;

   k = args->filelen - args->curr_byte;
   if (k < 0L)
      k = 0L;

   i = (int) ((k * 10 / cur_baud * 100 /
      ((args->save_header == SOH) ? 94 : 70) + 59) / 60);
   sprintf (j, "%3d min", i);

	if (args->options.SLO)
		{
		if ((!((args->SendBLK - 1) & 0x1f)) || ((args->SendBLK - 1) > args->LastBlk))
			{
		   if (fullscreen && un_attended)
   		   {
			   elapse_time();
      		sb_move (filewin, 2, 2);
				show_num (args, args->SendBLK - 1);
				(void) sb_putc (filewin, ':');
				show_num (args, args->ACKBLK);
	   	   (void) sb_puts (filewin, " *Overdrive*  ");
            sb_move (filewin, 2, 69);
            sb_puts (filewin, j);
   	   	sb_show ();
	      	}
		   else
   		   {
      		gotoxy (locate_x, locate_y);
				show_num (args, args->SendBLK - 1);
				cputs (":");
				show_num (args, args->ACKBLK);
   		   (void) cputs (" *Overdrive*  ");
	   	   }
			}
		}
	else
		{
	   if (fullscreen && un_attended)
   	   {
		   elapse_time();
      	sb_move (filewin, 2, 2);
			show_num (args, args->SendBLK - 1);
   	   (void) sb_putc (filewin, ':');
			show_num (args, args->ACKBLK);
	      sb_puts (filewin, (unsigned char *) "              ");
         sb_move (filewin, 2, 69);
         sb_puts (filewin, j);
   	   sb_show ();
      	}
	   else
   	   {
      	gotoxy (locate_x, locate_y);
			show_num (args, args->SendBLK - 1);
   	   (void) cputs (":");
			show_num (args, args->ACKBLK);
	      (void) cputs ("              ");
   	   }
	}
}

int cdecl ACInit (XMARGSP, int);
int cdecl ACEnd (XMARGSP, int);
int cdecl ACChkRcvd (XMARGSP);
int cdecl ACSLCheck (XMARGSP);
int cdecl ACSLVerify (XMARGSP);
int cdecl ACSLACKNAK (XMARGSP);
int cdecl ACXMCheck (XMARGSP);
int cdecl ACSLOCheck (XMARGSP);
int cdecl ACSL1Check (XMARGSP);
int cdecl ACACKNAK (XMARGSP);
int cdecl ACXMACK (XMARGSP);
int cdecl ACXMNAK (XMARGSP);
int cdecl ACRESYNC (XMARGSP);

STATES ACKNAK_Check[] = {
   { "ACInit", ( void *)ACInit },
   { "ACEnd",  ( void *)ACEnd },
   { "AC0",    ( void *)ACChkRcvd },
   { "AC1",    ( void *)ACSLCheck },
   { "AC2",    ( void *)ACSLVerify },
   { "AC3",    ( void *)ACSLACKNAK },
   { "AC4",    ( void *)ACXMCheck },
   { "AC5",    ( void *)ACSLOCheck },
   { "AC6",    ( void *)ACSL1Check },
   { "AC7",    ( void *)ACACKNAK },
   { "AC8",    ( void *)ACXMACK },
   { "AC9",    ( void *)ACXMNAK },
   { "AC10",   ( void *)ACRESYNC }
};

int cdecl ACInit( XMARGSP args, int start_state )
{
	args->result = 0;
   return (start_state);
}

int cdecl ACEnd( XMARGSP args, int cur_state )

{
   args->result = cur_state;
   return (cur_state);
}

int cdecl ACChkRcvd( XMARGSP args )
{
   if (PEEKBYTE () >= 0)
      {
      args->CHR = TIMED_READ (0);
		return (AC1);
      }

	return (SUCCESS);
}

int cdecl ACSLCheck( XMARGSP args )
{
	if (args->ACKST > 2)
		return (AC2);

	return (AC6);
}

int cdecl ACSLVerify( XMARGSP args )
{
   if (args->ARBLK8 == (unsigned char) ((~args->CHR) & 0xff))
      {
		args->ARBLK = args->SendBLK - ((args->SendBLK - args->ARBLK8) & 0xff);
		return (AC3);
      }

	args->options.SEAlink = 0;
	args->Window = 1;
	args->ACKST = 0;
	return (AC6);
}

int cdecl ACSLACKNAK( XMARGSP args )
{
   if ((args->ARBLK < 0) ||
       (args->ARBLK > args->SendBLK) ||
       (args->ARBLK <= (args->SendBLK - 128)))
      {
		return (AC0);
      }

   if (args->ACKST == 3)
      {
		args->options.SEAlink = (~no_sealink) & 1;
		args->Window = calc_window ();
		args->ACKBLK = args->ARBLK;
		++(args->ACKsRcvd);
		args->ACKST = 0;
		return (AC5);
      }

	args->SendBLK = args->ARBLK;
   args->curr_byte = (args->SendBLK - 1) * 128L;
   if (args->curr_byte < 0L)
      args->curr_byte = 0L;

	if (args->SendBLK > 0)
		++(args->tot_errs);

	Get_Block (args);
	args->ACKST = 0;

/* This stuff was in 2.38 why?
   CLEAR_OUTBOUND ();
   if (*SLO)
      *sealink = 0;
*/
	return (AC4);
}

int cdecl ACXMCheck( XMARGSP args )
{
   if (args->NumNAK < 4)
      {
		args->options.SEAlink = (~no_sealink) & 1;
		args->Window = calc_window ();
		}
	else
		{
	   args->options.SEAlink = 0;
		args->Window = 1;
		}
	return (SUCCESS);
}

int cdecl ACSLOCheck( XMARGSP args )
{
	if ((args->options.SLO == 0) || (args->ACKsRcvd < 10))
		return (SUCCESS);

	args->options.SLO = 0;
	return (SUCCESS);
}

int cdecl ACSL1Check( XMARGSP args )
{
	if ((args->ACKST == 1) || (args->ACKST == 2))
		{
		args->ARBLK8 = (unsigned char) args->CHR;
		args->ACKST += 2;
		return (AC6);
		}

	if ((args->options.SEAlink == 0) || (args->ACKST == 0))
		return (AC7);

	return (AC0);
}

int cdecl ACACKNAK( XMARGSP args )
{
	long mac_timer;

	switch (args->CHR)
		{
		case ACK:
			args->ACKST = 1;
			args->NumNAK = 0;
			return (AC8);

		case WANTCRC:
			args->options.do_CRC = 1;
			/* Fallthrough */

		case NAK:
         args->ACKST = 2;
			++(args->NumNAK);
			CLEAR_OUTBOUND ();
			timer (6);
			return (AC9);

		case SYN:
			CLEAR_OUTBOUND ();
         if (!no_resync)
            {
   			args->result = Receive_Resync (&(args->resync_block));
	   		args->ACKST = 0;
		   	return (AC10);
            }
         else
            {
            return (AC0);
            }

		case DC3: /* ^S */
			if (args->options.SEAlink && (args->ACKST == 0))
				{
				mac_timer = timerset (1000);
				while (CARRIER && !timeup (mac_timer))
					{
					if (TIMED_READ (0) == DC1)
						break;

					time_release ();
					}
				return (AC0);
				}

			/* Otherwise, fallthrough */

		default:
			return (AC0);
		}
}

int cdecl ACXMACK( XMARGSP args )
{
	if (!args->options.SEAlink)
		++(args->ACKBLK);

	return (AC0);
}

int cdecl ACXMNAK( XMARGSP args )
{
	if (!args->options.SEAlink)
		{
		args->SendBLK = args->ACKBLK + 1;
      args->curr_byte = (args->SendBLK - 1) * 128L;
      if (args->curr_byte < 0L)
         args->curr_byte = 0L;

		if (args->SendBLK > 0)
			++(args->tot_errs);

		Get_Block (args);
		}

	return (AC0);
}

int cdecl ACRESYNC( XMARGSP args )
{
   CLEAR_OUTBOUND ();
	if (args->result != SUCCESS)
		{
		SENDBYTE (NAK);
		return (SUCCESS);
		}

	if (args->SendBLK == 1)
		{
		args->prev_bytes = (args->resync_block - 1) * 128;
		if (args->prev_bytes > args->filelen)
			args->prev_bytes = args->filelen;
      status_line (msgtxt[M_SYNCHRONIZING], args->prev_bytes);
		}
	else
		{
		++(args->tot_errs);
		}

	args->options.SEAlink = 1;
	args->Window = calc_window ();
	args->SendBLK = args->resync_block;
   args->curr_byte = (args->SendBLK - 1) * 128L;
   if (args->curr_byte < 0L)
      args->curr_byte = 0L;

	Get_Block (args);
	args->ACKBLK = args->SendBLK - 1;
	SENDBYTE (ACK);
	return (SUCCESS);
}


void Check_ACKNAK( XMARGSP args )
{
	state_machine (ACKNAK_Check, args, AC0);
}

int Receive_Resync( long *resync_block )
{
   unsigned char resyncit[30];
   unsigned char *p;
   unsigned char a, b;
   unsigned int nak_crc, his_crc;

   p = resyncit;

   while ((*p = (unsigned char) TIMED_READ(1)) != ETX)
      {
      if ((*p < '0') || (*p > '9'))
         {
         status_line (">SEAlink Send: Resync bad byte '%02x'", *p);
         return (RESYNC_ERR);
         }
      ++p;
      }
   *p = '\0';
   nak_crc = crc_block ((unsigned char *) resyncit, strlen ((char *) resyncit));
   a = (unsigned char) TIMED_READ (1);
   b = (unsigned char) TIMED_READ (1);
   his_crc = (b << 8) | a;

   if (nak_crc != his_crc)
      {
      status_line (">SEAlink Send: Resync bad crc %04x/%04x", nak_crc, his_crc);
      return (CRC_ERR);
      }

   *resync_block = atol ((char *) resyncit);

   status_line (">SEAlink Send: Resync to %ld", *resync_block);
   return (SUCCESS);
}

int calc_window( void )
{
   int window;

   window = (int) (cur_baud / 400);
   if (window <= 0)
      window = 2;
   if (small_window)
      window = (window > 6) ? 6 : window;

   return (window);
}
