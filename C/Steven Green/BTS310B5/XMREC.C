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
/*                BinkleyTerm Xmodem Receiver State Machine                 */
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
#include <dos.h>
#endif
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#ifdef LATTICE
#define ultoa(v,s,r) (stcul_d(s,v),s)
#else
#include <io.h>
#endif
#include <ctype.h>
#include <conio.h>

#ifdef __TURBOC__
#include "tc_utime.h"
#ifdef __TOS__
#include <ext.h>
#else
#include <mem.h>
#include <alloc.h>
#endif
#else
#ifdef LATTICE
#include <errno.h>
#include <utime.h>
#else
#include <sys/utime.h>
#include <memory.h>
#include <malloc.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "defines.h"
#include "ascii.h"
#include "vfossil.h"
#include "session.h"
#include "nodeproc.h"

void Find_Char (int);
size_t Header_in_data (unsigned char *);
void Send_ACK (XMARGSP);
void Send_NAK (XMARGSP);
static long Open_Xmodem_File (XMARGSP);

int cdecl XRInit (XMARGSP, int);
int cdecl XREnd (XMARGSP, int);
int cdecl XRRecInit (XMARGSP);
int cdecl XRBrecInit (XMARGSP);
int cdecl XRRecStart (XMARGSP);
int cdecl XRWaitFirst (XMARGSP);
int cdecl XRWaitBlock (XMARGSP);
int cdecl XRRestart (XMARGSP);
int cdecl XRSetOvrdr (XMARGSP);

STATES Xmodem_Receiver[] = {
   { "XRInit",  XRInit },
   { "XREnd",  XREnd },
   { "XR0",  XRRecInit },
   { "XR0B", XRBrecInit },
   { "XR1",  XRRecStart },
   { "XR2",  XRWaitFirst },
   { "XR3",  XRWaitBlock },
   { "XR4",  XRRestart },
   { "XR5",  XRSetOvrdr }
};

static long Open_Xmodem_File (XMARGSP args)
{
   char *s2;
#ifdef __TOS__
	char *path = NULL;
	char thisdir[FMSIZE];
#endif

   if (args->file_pointer == NULL)
      {
      args->temp_name = calloc (1, 80);

      if (args->path != NULL)
         strcpy (args->temp_name, args->path);
      else
      	 args->temp_name[0] = '\0';

#ifdef __TOS__
	  if(args->path)
	  {
		  path = getcwd(thisdir, FMSIZE);		/* Make a temporary file name */
		  chdir(args->path);
	  }
	  s2 = tmpnam(NULL);
	  if(s2)
	  	strcat(args->temp_name, s2);
	  if(path)
	  {
	  	chdir(path);
	  	free(path);
	  }
#else
      strcat (args->temp_name, "BTXXXXXX");
      s2 = mktemp (args->temp_name);
#endif
      if ((s2 == NULL) || ((args->file_pointer = buff_fopen (args->temp_name, write_binary)) == NULL))
      {
         status_line (msgtxt[M_TEMP_NOT_OPEN], args->temp_name);
         return (-1L);
      }
   }
#ifdef XDEBUG
	status_line(">Created temporary file %s", args->temp_name);
#endif


   throughput (0, 0L);
   return (0L);
}

long Set_Up_Restart (args)
XMARGSP args;
{
	char foo[100];
	char foo1[50];
   struct stat st;

   args->sub_results = 0;

   /* Look for file in directory */
	if (args->path != NULL)
		strcpy (foo, args->path);

	if ((args->received_name != NULL) &&
       (strlen (args->received_name) > 0) &&
        args->options.Resync)
		{
		strcat (foo, args->received_name);

      if (stat (foo, &st) == 0)
         {
         if ((st.st_size == args->filelen) && (st.st_atime == args->save_filetime.oneword.timedate))
            {
            if ((args->file_pointer = buff_fopen (foo, read_binary_plus)) != NULL)
               {
	            throughput (0, 0L);
   	         fseek (args->file_pointer, 0L, SEEK_END);
      	      args->sub_results = DID_RESYNC;
         	   args->temp_name = calloc (1, 80);
            	strcpy (args->temp_name, foo);
	            args->prev_bytes = args->filelen;
   	         status_line (msgtxt[M_ALREADY_HAVE], foo);
      	      status_line (msgtxt[M_SYNCHRONIZING_EOF]);
         	   return (args->total_blocks + 1L);
					}
            }
         }

	   /* Look for file in .Z file */
	   if (dexists (Abortlog_name))
			{
     		sprintf (Resume_info, "%ld %lo", args->filelen, args->save_filetime.oneword.timedate);
			if (check_failed (Abortlog_name, args->received_name, Resume_info, foo1))
				{
				foo[0] = '\0';
				/* Here it looks like it was a failed WaZOO session */
				if (args->path != NULL)
					strcpy (foo, args->path);
				strcat (foo, foo1);

            if ((args->file_pointer = buff_fopen (foo, read_binary_plus)) != NULL)
  	            {
					stat (foo, &st);
	            throughput (0, 0L);
     	   	   args->temp_name = calloc (1, 80);
        	   	strcpy (args->temp_name, foo);
         	   args->prev_bytes = (st.st_size / 128L) * 128L;
  	         	fseek (args->file_pointer, args->prev_bytes, SEEK_SET);
			      status_line (msgtxt[M_SYNCHRONIZING_OFFSET], args->prev_bytes);
  	      	   return (args->prev_bytes / 128L + 1L);
					}
				}
			}
      }

	return (Open_Xmodem_File (args));
}

void Finish_Xmodem_Receive (args)
XMARGSP args;
{
   struct stat st;
   char new_name[80];
   struct utimbuf times;
	size_t i,j;
	int k;

#ifdef XDEBUG
	status_line(">Finish_Xmodem_Receive");
#endif

   /* Set the file's time and date stamp */
   if ((args->save_header == SOH) || (args->save_header == SYN))
      {
      (void) buff_fclose (args->file_pointer);
      times.modtime = (long) args->save_filetime.oneword.timedate;
      times.actime = (long) args->save_filetime.oneword.timedate;
      (void) utime (args->temp_name, &times);
      }
   else
      {
      (void) strcpy (args->received_name, "");
#if 1
	  if(args->file_pointer)	/* Added SWG!.. problem with aborted sessions */
#endif
	      (void) buff_fclose (args->file_pointer);
      }

   if (args->result == SUCCESS)
      {

#ifdef XDEBUG
	status_line(">temp_name=%s, path=%s", args->temp_name, args->path ? args->path : "NULL");
#endif

      /* Get the file information */
      (void) stat (args->temp_name, &st);

#ifdef XDEBUG
	status_line(">length=%ld", st.st_size);
#endif


      throughput (1, (unsigned long) (st.st_size - args->prev_bytes));

      update_files (0);

      if (args->sub_results & DID_RESYNC)
         {
         status_line ("%s: %s", msgtxt[M_FILE_RECEIVED], args->temp_name);
         }
      else
         {
         new_name[0] = '\0';
         if (args->path != NULL)
            (void) strcpy (new_name, args->path);
         if ((args->filename == NULL) || (strlen (args->filename) == 0))
            {
            if (strlen (args->received_name) > 0)
               (void) strcat (new_name, args->received_name);
            else
               (void) strcat (new_name, "BAD_FILE.000");
            }
         else
            {
            (void) strcat (new_name, args->filename);
            }

         i = strlen (args->temp_name) - 1;
         j = strlen (new_name) - 1;

         if (args->temp_name[i] == '.')
            args->temp_name[i] = '\0';
         if (new_name[j] == '.')
            {
            new_name[j] = '\0';
            --j;
            }

         i = 0;
         k = is_arcmail (new_name, j);
         status_line ("%s: %s", msgtxt[M_FILE_RECEIVED], new_name);
         if ((!overwrite) || k)
            {
            while (rename (args->temp_name, new_name))
               {
               if (isdigit (new_name[j]))
                  new_name[j]++;
               else new_name[j] = '0';
               if (!isdigit (new_name[j]))
                  {
                  return;
                  }
               i = 1;
               }
            CLEAR_IOERR ();
            }
         else
            {
            (void) unlink (new_name);
            while (rename (args->temp_name, new_name))
               {
               if (!i)
                  {
                  status_line (msgtxt[M_ORIGINAL_NAME_BAD], new_name);
                  }
               if (isdigit (new_name[j]))
                  new_name[j]++;
               else new_name[j] = '0';
               if (!isdigit (new_name[j]))
                  {
                  return;
                  }
               i = 1;
               }
            CLEAR_IOERR ();
            }
         if (i)
            {
            if (locate_y && !(fullscreen && un_attended))
               gotoxy (2, locate_y - 1);
            status_line (msgtxt[M_RENAME_MSG], new_name);
            }
         }

		remove_abort (Abortlog_name, args->received_name);
      }
   else
      {
		if ((args->received_name != NULL) && (strlen (args->received_name) > 0) && (args->save_header != 0))
			{
    		sprintf (Resume_info, "%ld %lo", args->filelen, args->save_filetime.oneword.timedate);
			add_abort (Abortlog_name, args->received_name, args->temp_name, args->path, Resume_info);
			}
		else
			{
	      /* File aborted, so remove all traces of it */
   	   if (args->temp_name != NULL)
      	   (void) unlink (args->temp_name);
			}
      }

   if (args->temp_name != NULL)
      free (args->temp_name);
}

void Get_Telink_Info (args)
XMARGSP args;
{
   char *p1;
   char junkbuff[100];
   TLDATAP t;
#ifndef GENERIC
	unsigned int i, j;
#endif	

   /* Figure out how many blocks we will get */
   t = (TLDATAP) &args->datablock;
#ifdef GENERIC
   args->total_blocks = (long)
   		  (127 +
   		   t->filelength[0] +
   		  ((long)t->filelength[1] << 8) +
   		  ((long)t->filelength[2] << 16) +
   		  ((long)t->filelength[3] << 24)) / 128;
#else
   args->total_blocks = (t->filelength + 127)/ 128;
#endif
   t->nullbyte = '\0';
   p1 = strchr (t->filename, ' ');
   if (p1 != NULL)
      *p1 = '\0';
   strcpy (args->received_name, t->filename);
   args->save_header = args->header;
   if (args->save_header == SYN)
      {
#ifdef GENERIC
	/* May need some fiddling!!! */
	  args->save_filetime.twowords.time = t->time[0] + (t->time[1] << 8);
	  args->save_filetime.twowords.date = t->date[0] + (t->date[1] << 8);
#else
      i = t->filetime.twowords.time;
      j = t->filetime.twowords.date;
      args->save_filetime.oneword.timedate = _dtoxtime (j >> 9, (j >> 5) & 0x0f,
         j & 0x1f, i >> 11, (i >> 5) & 0x3f, i & 0x1f);
#endif
      }
   else
      {
#ifdef GENERIC
	/* I dont understand the difference here..! No doubt Ill find out */
	/* when it doesnt work :-( */
	  args->save_filetime.twowords.time = t->time[0] + (t->time[1] << 8);
	  args->save_filetime.twowords.date = t->date[0] + (t->date[1] << 8);
#else
      args->save_filetime.oneword.timedate = t->filetime.oneword.timedate;
#endif
      }
#ifdef GENERIC
   args->filelen = (long)
   				   t->filelength[0] +
   				  ((long)t->filelength[1] << 8) +
   				  ((long)t->filelength[2] << 16) +
   				  ((long)t->filelength[3] << 24);	
#else
   args->filelen = t->filelength;
#endif   

#ifdef NEW	/* SWG: 9th July 1991 */
   (void) sprintf (junkbuff, msgtxt[M_RECEIVE_MSG],
      args->total_blocks, t->filename, t->sendingprog, args->filelen);
#else
   (void) sprintf (junkbuff, msgtxt[M_RECEIVE_MSG],
      args->total_blocks, t->filename, t->sendingprog, t->filelength);
#endif
	strcpy (sending_program, t->sendingprog);
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
      locate_y = wherey ();
      locate_x = wherex ();
      }
   }

int Read_Block (args)
XMARGSP args;
{
   unsigned char *p; /* Pointers to XMODEM data */
   size_t i;            /* Counter */
   size_t j;            /* Counter start */
   unsigned char c;  /* character being processed */
   int in_char;
   char junkbuff[128];
   long head_timer;

   if (got_ESC ())
      {
      status_line (msgtxt[M_KBD_MSG]);
      return (KBD_ERR);
      }

   /* Set up to point into the XMODEM data structure */
   p = (unsigned char *) &args->datablock;

   /* Get the first character that is waiting */
#if 0
   *p = (unsigned char) TIMED_READ (8);
#else
   args->header = TIMED_READ(8);
#endif

#ifdef XDEBUG
	status_line(">Read_Block: header=%02x", *p);
#endif

   head_timer = timerset (6000);
   j = 0;
   while (!timeup (head_timer))
      {
      /* Now key off of the header character */
      switch (args->header)
         {
         case EOT:   /* End of file */
            /* Is this a valid EOT */
            if (args->total_blocks <= args->WriteBLK)
               {
               return (EOT_BLOCK);
               }
            else
               {
               status_line (msgtxt[M_UNEXPECTED_EOF], args->total_blocks);
               return (BAD_BLOCK);
               }

         case SYN:   /* Telink block */
#ifdef XDEBUG
			status_line(">Read_Block: Telink");
#endif
            /* For Telink, read all of the data except the checksum */
            for (i = 0; i < sizeof (TLDATA) - 2; i++)
               {
               /* If we go more than 5 second, then we have a short block */
               if ((in_char = TIMED_READ (5)) < 0)
               {
                  return (BAD_BLOCK);
               }
               *p++ = (unsigned char) (in_char & 0xff);
            }
#ifdef XDEBUG
			status_line(">Read_Block, block=%02x, com=%02x",
				args->datablock.block_num, args->datablock.block_num_comp);
#endif

            /* if the block number or its complement are wrong, return error */
            if ((args->datablock.block_num != 0) || (args->datablock.block_num_comp != 0xff))
               {
               return (BAD_BLOCK);
               }

            /* Now calculate the checksum - Telink block always checksum mode */
            Data_Check (&args->datablock, CHECKSUM);

            /* See if we can receive the checksum byte */
            if ((in_char = TIMED_READ (10)) < 0)
               {
               Xmodem_Error (msgtxt[M_TIMEOUT], 0L);
               return (BAD_BLOCK);
               }

            /* Was it right */
            c = (unsigned char) (in_char & 0xff);
#ifdef XDEBUG
		  status_line(">Received block: header=%02x, block=%02x, check=%02x %02x",
		  	args->header, args->datablock.block_num,
		  	args->datablock.data_check[0],
		  	args->datablock.data_check[1]);
		  status_line(">c=%02x, size=%d, %02x %02x %02x %02x ... %02x %02x",
		  	c, (int)sizeof(TLDATA)-2,
		  	args->datablock.data_bytes[0],
		  	args->datablock.data_bytes[1],
		  	args->datablock.data_bytes[2],
		  	args->datablock.data_bytes[3],
		  	args->datablock.data_bytes[126],
		  	args->datablock.data_bytes[127]);
#endif
            if (c != args->datablock.data_check[0])
               {
#ifdef XDEBUG
				  status_line(">Checksum c=%02x  data=%02x", c, args->datablock.data_check[0]);
#endif
               Xmodem_Error (msgtxt[M_CHECKSUM], 0L);
               return (BAD_BLOCK);
               }
            /* Everything looks good, it must be a legal TELINK block */

            Get_Telink_Info (args);
            return (TELINK_BLOCK);

         case SOH:   /* Normal data block */
            args->datalen = 128;
            /* Read in all of the data for an XMODEM block except the checksum */
            p += j;
            for (i = j; i < sizeof (XMDATA) - 2; i++)
            {
               /* If we go more than 5 seconds, then it is a short block */
               if ((in_char = TIMED_READ (5)) < 0)
               {
                  return (BAD_BLOCK);
               }
               *p++ = (unsigned char) (in_char & 0xff);
            }

            /* The block number is 0 to 255 inclusive */
            c = (unsigned char) (args->blocknum & 0xff);

            /* Properly calculate the CRC or checksum */
            Data_Check (&args->datablock, args->options.do_CRC ? CRC : CHECKSUM);

            /* Can we get the checksum byte */
            if ((in_char = TIMED_READ (10)) < 0)
               {
               Xmodem_Error (msgtxt[M_TIMEOUT], args->WriteBLK);
               return (BAD_BLOCK);
               }

            /* Is it the right value */
            c = (unsigned char) (in_char & 0xff);
            if (c != args->datablock.data_check[0])
               {
               status_line (">Xmodem Receive: Bad %s", (args->options.do_CRC)?"CRC":"checksum");
               Xmodem_Error (msgtxt[M_CRC_MSG], args->WriteBLK);
               if (args->options.do_CRC)
                  (void) TIMED_READ (5);
               return (BAD_BLOCK);
               }

            /* If we are in CRC mode, do the second byte */
            if (args->options.do_CRC)
               {
               /* Can we get the character */
               if ((in_char = TIMED_READ (10)) < 0)
                  {
                  status_line (">Xmodem Receive: Timeout waiting for CRC byte 2");
                  Xmodem_Error (msgtxt[M_TIMEOUT], args->WriteBLK);
                  return (BAD_BLOCK);
                  }
               /* Is it right */
               c = (unsigned char) (in_char & 0xff);
               if (c != args->datablock.data_check[1])
                  {
#ifdef DEBUG
				  status_line(">CRC c=%02x  data=%02x", c, args->datablock.data_check[1]);
#endif
                  Xmodem_Error (msgtxt[M_CRC_MSG], args->WriteBLK);
                  return (BAD_BLOCK);
                  }
               }

            /* Do we have a valid data block */
            if (args->datablock.block_num_comp != ((~(args->datablock.block_num)) & 0xff))
               {
               if (!(args->options.SEAlink))
                  {
                  Xmodem_Error (msgtxt[M_JUNK_BLOCK], args->WriteBLK);
                  return (BAD_BLOCK);
                  }

               p = (unsigned char *) &args->datablock;
               j = Header_in_data (p);
               if (j)
                  {
                  j--;
                  continue;
                  }

               j = 0;
               Find_Char (SOH);
               args->header = (unsigned char) TIMED_READ (0);
               }

            if ((args->WriteBLK == 1) && (args->header == SOH) && (args->datablock.block_num == 0))
               {
               Get_Telink_Info (args);
               return (SEALINK_BLOCK);
               }

            if (first_block)
               {
               struct _pkthdr *packet;

               packet = (struct _pkthdr *) args->datablock.data_bytes;
               if (!remote_capabilities)
                  {
                  remote_addr.Zone = GETPWORD(packet->orig_zone.w);
                  remote_addr.Net = GETPWORD(packet->orig_net.w);
                  remote_addr.Node = GETPWORD(packet->orig_node.w);
                  if (GETPWORD(packet->rate.w) == 2)
                     {
                     /* This is a special type 2.2 packet! */
                     remote_addr.Point = (unsigned) GETPWORD(packet->year.w);

                     packet->B_fill3 = 0L;
                     packet->B_fill2[8] = '\0';
                     remote_addr.Domain = find_domain (packet->B_fill2);
#ifdef MULTIPOINT
#if 0
					/*
					 * If it is the boss convert to fakenet
					 * else set node to silly value
					 * Not sure this is neccessary!
					 */
					{
						/* This wont work anyway.. we would have to search
						 * through the alias list for a match, because
						 * assumed hasnt been calculated yet
						 */
						
						ADDRESS *ad = &alias[assumed];
						
						if((ad->fakenet >= 0) &&
						   ((remote_addr.Zone == ad->ad.Zone) || !remote_addr.Zone) &&
						   (remote_addr.Net == ad->ad.Net) &&
						   (remote_addr.Node == ad->ad.Node) &&
						   (remote_addr.Point > 0))
						{
							remote_addr.Net = ad->fakenet;
							remote_addr.Node = remote_addr.Point;
							remote_addr.Point = 0;
						}
						else if(remote_addr.Point > 0)	/* Its a point unknown to us! */
						{
							remote_addr.Point = 0;
							remote_addr.Node = -1;
						}
					}
					
#endif
#else
                     if ((pvtnet >= 0) &&
                         ((remote_addr.Zone == alias[assumed].ad.Zone) || (remote_addr.Zone == 0)) &&
                         (remote_addr.Net == boss_addr.ad.Net) && (remote_addr.Node == boss_addr.ad.Node) &&
                         (remote_addr.Point > 0))
                        {
                        remote_addr.Net = pvtnet;
                        remote_addr.Node = remote_addr.Point;
                        remote_addr.Point = 0;
                        }
                     else if (remote_addr.Point > 0)
                        {
                        remote_addr.Point = 0;
                        remote_addr.Node = -1;
                        }
#endif
                     }
                  else
                     {
#ifdef MULTIPOINT
					/* Convert 2D to 4D if in one of our fakenets */
					
					{
						ADDRESS *ad = alias;
						int i = 0;
						
						while(i < num_addrs)
						{
							if(remote_addr.Net == ad->fakenet)
							{
								remote_addr.Point = remote_addr.Node;
								remote_addr.Node = ad->ad.Node;
								remote_addr.Net = ad->ad.Net;
								assumed = i;
								break;
							}
							ad++;
							i++;
						}
					}
#else
                     remote_addr.Point = 0;
                     remote_addr.Domain = NULL;
#endif
                     }
                  }
               if (who_is_he)
                  {
                  if (!remote_addr.Zone && !remote_addr.Net && !remote_addr.Node)
                     {
#ifdef NEW /* FASTMODEM  10.09.1989 */
                     hang_up ();
#else
                     DTR_OFF ();                   /* Bad trip, cut it off */
                     timer (2);                    /* Wait two secs        */
#endif
                     return(CARRIER_ERR);          /* Get out of here!     */
                     }

                  if (nodefind (&remote_addr, 1))
                     {
                     if (!remote_addr.Zone)
                        remote_addr.Zone = found_zone;

                     (void) sprintf (junkbuff, "%s: %s (%s)",
                              msgtxt[M_REMOTE_SYSTEM],
                              newnodedes.SystemName,
                              Pretty_Addr_Str (&remote_addr));
                     }
                  else
                     {
                     (void) sprintf (junkbuff, "%s: %s (%s)",
                              msgtxt[M_REMOTE_SYSTEM],
                              msgtxt[M_UNKNOWN_MAILER],
                              Pretty_Addr_Str (&remote_addr));
                     }

                  last_type (2, &remote_addr);
                  status_line (junkbuff);
                  }
					if (sending_program[0] != '\0')
						{
			         status_line ("%s %s", msgtxt[M_REMOTE_USES], sending_program);
						}
					else
						{
                  log_product (packet->product, 0, GETPWORD(packet->serial));
						}
               who_is_he = 0;
               first_block = 0;
               }

            if (args->WriteBLK == args->total_blocks)
               {
               args->datalen = (size_t) (args->filelen - ((args->WriteBLK - 1) * 128));
               }

            /* If we got this far, it is a valid data block */
            args->recblock = args->datablock.block_num;
            return (XMODEM_BLOCK);

         default:    /* Bad block */
            if ((args->blocknum <= 1) || (PEEKBYTE () < 0))
               return (BAD_BLOCK);

            /* Garbage header, return bad */
            *p = (unsigned char) TIMED_READ (0);
         }
      }
   return (BAD_BLOCK);
}

int cdecl XRInit (XMARGSP args, int start_state)
{
	char *HoldName;

   args->tries = 0;
   args->goodfile = 1;
   XON_DISABLE ();
   HoldName = HoldAreaNameMunge(&called_addr);
#ifdef IOS
	if(iosmode)
	   sprintf (Abortlog_name, "%s%s.Z\0", HoldName, Addr36(&remote_addr));
	else
#endif
	   sprintf (Abortlog_name, "%s%s.Z\0", HoldName, Hex_Addr_Str (&remote_addr));
	sending_program[0] = '\0';
   return (start_state);
}

int cdecl XREnd (XMARGSP args, int cur_state)
{
   args->result = cur_state;

   Finish_Xmodem_Receive (args);

   return (cur_state);
}

int cdecl XRRecInit (XMARGSP args)
{
   args->options.SEAlink = 0;
   args->options.SLO = 0;
   args->options.Resync = 0;
   args->options.MacFlow = 0;
   args->options.do_CRC = 1;
   args->blocknum = 0;
   args->WriteBLK = 1;
   args->curr_byte = 0L;
   args->tries = 0;
   return (XR1);
}

int cdecl XRBrecInit (XMARGSP args)
{
   args->options.SEAlink = 0;
   args->options.SLO = 0;
   args->options.Resync = 0;
   args->options.MacFlow = 0;
   args->options.do_CRC = 1;
   args->blocknum = 0;
   args->WriteBLK = 1;
   args->curr_byte = 0L;
   args->tries = 0;
   return (XR2);
}

int cdecl XRRecStart (XMARGSP args)
{
   Send_NAK (args);
   return (XR2);
}

int cdecl XRWaitFirst (XMARGSP args)
{
   long XR2Timer;

   XR2Timer = timerset (800);
   if (args->tries >= 10)
      {
      args->goodfile = 0;
      return (TIME_ERR);
      }
   if (args->tries == 5)
      {
      args->options.do_CRC = 0;
      ++(args->tries);
      return (XR1);
      }

   while (CARRIER)
      {
      switch (Read_Block (args))
         {
         case EOT_BLOCK:
#ifdef XDEBUG
			status_line(">XRWaitFirst() => EOT_BLOCK");
#endif
				args->WriteBLK = 0;
            Send_ACK (args);
            return (SUCCESS_EOT);

         case TELINK_BLOCK:
#ifdef XDEBUG
			status_line(">XRWaitFirst() => TELINK_BLOCK");
#endif
            if (Open_Xmodem_File (args) == -1L)
               return (OPEN_ERR);
            Send_ACK (args);
            args->tries = 0;
            return (XR3);

         case SEALINK_BLOCK:
#ifdef XDEBUG
			status_line(">XRWaitFirst() => SEALINK_BLOCK");
#endif
            args->options.SEAlink = no_sealink ? 0 : 1;
            if (args->options.SEAlink && !no_resync)
               args->options.Resync = (((SEADATAP) (&args->datablock))->Resync) != 0;
            return (XR4);

         case XMODEM_BLOCK:
#ifdef XDEBUG
			status_line(">XRWaitFirst() => XMODEM_BLOCK");
#endif
            if (args->recblock == 1)
               {
               if (Open_Xmodem_File (args) == -1L)
                  return (OPEN_ERR);
               (void) buff_fwrite (args->datablock.data_bytes, sizeof (unsigned char), args->datalen, args->file_pointer);
               ++(args->WriteBLK);
               args->curr_byte = 128L;
               ++(args->blocknum);
               Send_ACK (args);
               args->tries = 0;
               return (XR3);
               }

            /* Fallthrough on wrong block */

         case BAD_BLOCK:
#ifdef XDEBUG
			status_line(">XRWaitFirst() => BAD_BLOCK");
#endif
            ++(args->tries);
            return (XR1);

         case CARRIER_ERR:
         case KBD_ERR:
            return (CARRIER_ERR);
         }

      if (timeup (XR2Timer))
         {
         ++(args->tries);
         return (XR1);
         }
      }

   return (CARRIER_ERR);
}

int cdecl XRWaitBlock (XMARGSP args)
{
   if (args->tries >= 10)
      {
      args->goodfile = 0;
      return (TIME_ERR);
      }

   while (CARRIER)
      {
      switch (Read_Block (args))
         {
         case EOT_BLOCK:
            args->options.SLO = 0;
            Send_ACK (args);
            return (SUCCESS);

         case XMODEM_BLOCK:
            if (args->recblock == (unsigned char) ((args->blocknum - 1) & 0xff))
               {
               --(args->blocknum);
               Send_ACK (args);
               return (XR3);
               }

            if (args->recblock == args->blocknum)
               {
               (void) buff_fwrite (args->datablock.data_bytes, sizeof (unsigned char), args->datalen, args->file_pointer);
               ++(args->WriteBLK);
               args->curr_byte += 128L;
               Send_ACK (args);
               args->tries = 0;
               return (XR3);
               }

            if (args->recblock < args->blocknum)
               {
               args->recblock += 256;
               }

            if ((args->recblock > (unsigned) args->blocknum) && (args->recblock <= ((unsigned) (((unsigned) args->blocknum) + 127))))
               {
					if (args->tries != 0)
						{
						/* We have sent at least one nak, now only send them
							every so often to allow buffers to drain */
						if ((args->recblock - (unsigned) args->blocknum) % 16)
							return (XR3);

						/* If it is a multiple of 16, then check that it is
							higher than 32 */
						if ((args->recblock - (unsigned) args->blocknum) / 16 < 2)
							return (XR3);
						}
               }

            /* fallthrough on bad block */

         case BAD_BLOCK:
            Send_NAK (args);
            ++(args->tries);
            return (XR3);

         case CARRIER_ERR:
         case KBD_ERR:
            return (CARRIER_ERR);
         }
      }

   return (CARRIER_ERR);
}

int cdecl XRRestart (XMARGSP args)
{
   long c;

   c = Set_Up_Restart (args);
   if (c == -1L)
      return (OPEN_ERR);

   if ((!c) || (!(args->options.Resync)))
      {
      Send_ACK (args);
      args->tries = 0;
      }
   else
      {
      args->WriteBLK = c;
      args->curr_byte = (c - 1) * 128L;
      args->blocknum = (unsigned char) ((args->WriteBLK) & 0xff);
      Send_NAK (args);
      }

   return (XR5);
}

int cdecl XRSetOvrdr (XMARGSP args)
{
   if (!no_overdrive)
      args->options.SLO = (((SEADATAP) (&args->datablock))->SLO) != 0;

	if (args->options.SLO)
		show_block ((long) (args->WriteBLK - 1), " *Overdrive*", args);

   return (XR3);
}

int Xmodem_Receive_File (path, filename)
char *path;
char *filename;
{
   XMARGS xmfile;
   int res;

   locate_y = wherey ();
   locate_x = wherex ();
   memset (&xmfile, 0, sizeof (XMARGS));
   xmfile.path = path;
   xmfile.filename = filename;
   xmfile.total_blocks = -1L;
   xmfile.sent_ACK = 0;
   res = state_machine (Xmodem_Receiver, &xmfile, XR0);
   return (res);
}

int Batch_Xmodem_Receive_File (path, filename)
char *path;
char *filename;
{
   XMARGS xmfile;
   int res;

   locate_y = wherey ();
   locate_x = wherex ();
   memset (&xmfile, 0, sizeof (XMARGS));
   xmfile.path = path;
   xmfile.filename = filename;
   xmfile.total_blocks = -1L;
   xmfile.sent_ACK = 0;
   res = state_machine (Xmodem_Receiver, &xmfile, XR0B);
   return (res);
}

int cdecl SAInit (XMARGSP, int);
int cdecl SAEnd (XMARGSP, int);
int cdecl SAClearLine (XMARGSP);
int cdecl SASendACK (XMARGSP);
int cdecl SASEAlink (XMARGSP);
int cdecl SAIncBlk (XMARGSP);

STATES ACK_States[] = {
   { "SAInit",  SAInit },
   { "SAEnd",  SAEnd },
   { "SA0",  SAClearLine },
   { "SA1",  SASendACK },
   { "SA2",  SASEAlink },
   { "SA3",  SAIncBlk }
};

int cdecl SAInit (args, start_state)
XMARGSP args;
int start_state;
{
   return (start_state);
   /* args; */
}

int cdecl SAEnd (args, cur_state)
XMARGSP args;
int cur_state;
{
   return (cur_state);
   /* args; */
}

int cdecl SAClearLine (XMARGSP args)
{
   long SA0Timer;

   SA0Timer = timerset (3000);
   if (args->options.SLO)
      return (SA3);

   if (args->options.SEAlink)
      return (SA1);

   while (CARRIER && !timeup (SA0Timer))
      {
      if (PEEKBYTE () >= 0)
         {
         (void) TIMED_READ (0);
         time_release ();
         continue;
         }

      return (SA1);
      }

   return (TIME_ERR);
}

int cdecl SASendACK (XMARGSP args)
{
   SENDBYTE (ACK);
   args->sent_ACK = 1;
   return (SA2);
}

int cdecl SASEAlink (XMARGSP args)
{
   if (!(args->options.SEAlink))
      return (SA3);

   SENDBYTE (args->blocknum);
   SENDBYTE ((unsigned char)~args->blocknum);
   return (SA3);
}

void show_block (b, c, args)
long b;
char *c;
XMARGSP args;
{
   char j[100];
   int i;
   long k;

   if (fullscreen && un_attended)
      {
	   elapse_time();
      sb_move (filewin, 2, 2);
      sb_puts (filewin, (unsigned char *) ultoa (((unsigned long) b), e_input, 10));
		if (c)
	      (void) sb_puts (filewin, c);

      k = args->filelen - args->curr_byte;
      if (k < 0L)
         k = 0L;

      i = (int) ((k * 10 / cur_baud * 100 /
         ((args->save_header == SOH) ? 94 : 70) + 59) / 60);
      sprintf (j, "%3d min", i);

      sb_move (filewin, 2, 69);
      sb_puts (filewin, j);
      sb_show ();
      }
   else
      {
      gotoxy (locate_x, locate_y);
      (void) printf ("%s", ultoa (((unsigned long) b), e_input, 10));
		if (c)
			(void) printf ("%s", c);
      }
}

int cdecl SAIncBlk (XMARGSP args)
{
   ++(args->blocknum);
   if ((args->options.SLO) &&
		(((args->WriteBLK > 0) && (!((args->WriteBLK - 1) & 0x001F)) && (args->WriteBLK < args->total_blocks)) ||
      (args->WriteBLK >= args->total_blocks)))
      {
		show_block ((long) (args->WriteBLK - 1), " *Overdrive*", args);
      }
	else if ((!(args->options.SLO)) && (args->WriteBLK > 0))
      {
		show_block ((long) (args->WriteBLK - 1), NULL, args);
      }

   return (SUCCESS);
}

void Send_ACK (XMARGSP args)
{
   state_machine (ACK_States, args, SA0);
}

void Send_Resync_Packet (XMARGSP);

int cdecl SNInit (XMARGSP, int);
int cdecl SNEnd (XMARGSP, int);
int cdecl SNClearLine (XMARGSP);
int cdecl SNSendNAK (XMARGSP);
int cdecl SNSEAlink (XMARGSP);
int cdecl SNAckResync (XMARGSP);

STATES NAK_States[] = {
   { "SNInit",  SNInit },
   { "SNEnd",  SNEnd },
   { "SN0",  SNClearLine },
   { "SN1",  SNSendNAK },
   { "SN2",  SNSEAlink },
   { "SN3",  SNAckResync }
};

int cdecl SNInit (args, start_state)
XMARGSP args;
int start_state;
{
   return (start_state);
   /* args; */
}

int cdecl SNEnd (args, cur_state)
XMARGSP args;
int cur_state;
{
   return (cur_state);
   /* args; */
}

int cdecl SNClearLine (XMARGSP args)
{
   long SN0Timer;

   SN0Timer = timerset (3000);
   if (args->options.Resync)
      {
      Send_Resync_Packet (args);
      return (SN3);
      }

   if (args->options.SEAlink)
      return (SN1);

   while (CARRIER && !timeup (SN0Timer))
      {
      if (PEEKBYTE () >= 0)
         {
         (void) TIMED_READ (0);
         time_release ();
         continue;
         }

      return (SN1);
      }

   return (TIME_ERR);
}

int cdecl SNSendNAK (XMARGSP args)
{
   if (args->options.do_CRC && (args->sent_ACK == 0))
      SENDBYTE (WANTCRC);
   else
      SENDBYTE (NAK);
   return (SN2);
}

int cdecl SNSEAlink (XMARGSP args)
{
   if (!(args->options.SEAlink))
      return (SUCCESS);

   SENDBYTE (args->blocknum);
   SENDBYTE ((unsigned char)~(args->blocknum));
   return (SUCCESS);
}

int cdecl SNAckResync (XMARGSP args)
{
   long SN3Timer;
   int c;

   SN3Timer = timerset (3000);

   while (CARRIER && !timeup (SN3Timer))
      {
      if ((c = TIMED_READ (10)) == 0xffff)
         {
         Send_Resync_Packet (args);
         continue;
         }

      if (c == ACK)
			{
			big_pause (1);
			c = PEEKBYTE();
			if ((c == SOH) || (c == EOT))
	         return (SUCCESS);
			}
      }

   if (!CARRIER)
      return (CARRIER_ERR);
   else
      return (TIME_ERR);
}

void Send_NAK (XMARGSP args)
{
   state_machine (NAK_States, args, SN0);
}

void Send_Resync_Packet (XMARGSP args)
{
   unsigned char resyncit[30];
   unsigned int nak_crc;

   SENDBYTE (SYN);
   (void) sprintf ((char *) resyncit, "%ld", args->WriteBLK);
   SENDCHARS ((char *) resyncit, strlen ((char *) resyncit), 1);
   nak_crc = crc_block ((unsigned char *) resyncit, strlen ((char *) resyncit));
   SENDBYTE (ETX);
   SENDBYTE ((unsigned char) (nak_crc & 0xff));
   CLEAR_INBOUND ();
   SENDBYTE ((unsigned char) (nak_crc >> 8));
}

void Xmodem_Error (s, block_number)
char *s;
long block_number;
{
   char j[50];
   char k[50];

   (void) sprintf (j, "%s %s %ld", s, msgtxt[M_ON_BLOCK], block_number);
   (void) sprintf (k, "%-49.49s", j);

   status_line (">Xmodem Error: %s", k);
   if (fullscreen && un_attended)
      {
      sb_move (filewin, 2, 20);
      sb_puts (filewin, (unsigned char *) k);
      sb_show ();
      }
   else
      {
      gotoxy (locate_x + 20, locate_y);
      (void) cputs (k);
      }
}

void Find_Char (c)
int c;
{
   long t1;
   long t2;

   t1 = timerset (3000);
   t2 = timerset (100);
   while (!timeup (t1) && !timeup (t2))
      {
      if (!CARRIER)
         break;

      if (PEEKBYTE () == (c & 0xff))
         break;
      else if (PEEKBYTE () >= 0)
         {
         (void) TIMED_READ (0);
         t2 = timerset (100);
         }
      }
}

size_t Header_in_data (p)
unsigned char *p;
{
   size_t i;
   size_t j;
   char *p1;

   p1 = (char *) p;
   /* ++p1; */
   j = sizeof (XMDATA) - 2;
   for (i = 0; i < j; i++)
   {
      if (*p1++ == SOH)
      {
         memcpy (p, p1, j-i-1);
         return (j - i);
      }
   }

   return (0);
}
