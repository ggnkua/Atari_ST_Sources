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
/*			  This module was originally written by Bob Hartman 			*/
/*																			*/
/*																			*/
/*						   Outbound Manipulating							*/
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

#include <stdio.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>
#ifndef LATTICE
#include <process.h>
#endif
#include <stdlib.h>
#ifdef __TOS__
/* #pragma warn -sus */
#include <ext.h>
#else
#include <dos.h>
#endif

#ifdef OS_2
#define INCL_DOSPROCESS
#endif

#ifdef __TURBOC__
#ifndef __TOS__
#include <alloc.h>
#endif
#else
#ifndef LATTICE
#include <malloc.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "defines.h"
#include "zmodem.h"		/* For DELETE_AFTER definitions */

static int add_request (char *, char *, char *, char);
static int add_send (char *, char *, char);
static int kill_node (char *);

int Overlay_Do_Get (p, x)
SAVEP p;
int x;
{
	REGIONP r;
	char node[51];
   char file[14];
	char password[9];
	char flavor[2];

	if (p != NULL)
		{
		r = p->region;

		/* First fill it all with blanks */
	   sb_fill (r, ' ', colors.popup);

		/* Now draw the box */
	   sb_box (r, boxtype, colors.popup);

	sb_move (r, 0, 1);
	   sb_puts (r, (unsigned char *) msgtxt[M_GET_FILE]);

		/* Now do the fields */
		sb_move (r, 1,2);
		sb_puts (r, msgtxt[M_ADDRESS_TO_GET_FROM]);
		if (!sb_input_chars (r, 1, 23, node, 36, TRUE) && node[0])
			{
		 OneMore:
			sb_move (r, 2, 2);
			sb_puts (r, msgtxt[M_FILE_TO_RECEIVE]);
		 if (!sb_input_chars (r, 2, 23, file, 13, TRUE) && file[0])
				{
				sb_move (r, 3, 2);
				sb_puts (r, msgtxt[M_PASSWORD_TO_USE]);
				(void) sb_input_chars (r, 3, 23, password, 8, TRUE);
				sb_move (r, 4, 2);
			sb_puts (r, "Crash, Direct, Normal or More requests (C/D/N/M)?");
			(void) sb_input_chars (r, 4, 52, flavor, 1, TRUE);
			x = add_request (node, file, password, (char) ((flavor[0] == 'M') ? 'N' : flavor[0]));
			if ((x == 0) && (flavor[0] == 'M'))
			   goto OneMore;
				}
			}
		}

	/* Return value is never checked, just use x so lint and -W3 don't get mad */
	return (x);
}

int Overlay_Do_Send (p, x)
SAVEP p;
int x;
{
	REGIONP r;
	char node[51];
	char file[51];
	char flavor[2];
    
	if (p != NULL)
	{
		r = p->region;

		/* First fill it all with blanks */
		sb_fill (r, ' ', colors.popup);

		/* Now draw the box */
		sb_box (r, boxtype, colors.popup);

		sb_move (r, 0, 1);
		sb_puts (r, (unsigned char *) msgtxt[M_SEND_FILE]);

		/* Now do the fields */
		sb_move (r, 1,2);
		sb_puts (r, msgtxt[M_ADDRESS_TO_SEND_TO]);
		if (!sb_input_chars (r, 1, 22, node, 47, TRUE) && node[0])
		{
		OneMore:
			sb_move (r, 2, 2);
			sb_puts (r, msgtxt[M_FILE_TO_SEND]);
			if (!sb_input_chars (r, 2, 22, file, 47, TRUE) && file[0])
			{
			    sb_move (r, 3, 2);
			    sb_puts (r, "Crash, Hold, Direct, Normal or More (C/H/D/N/M)?");
			    (void) sb_input_chars (r, 3, 51, flavor, 1, TRUE);
			    x = add_send (node, file, (char) ((flavor[0] == 'M') ? 'N' : flavor[0]));
			    if ((x == 0) && (flavor[0] == 'M')) goto OneMore;
			}
		}
	}

	/* Return value is never checked, just use x so lint and -W3 don't get mad */
	return (x);
}

int Overlay_Do_Kill (p, x)
SAVEP p;
int x;
{
	REGIONP r;
	char node[51];
	char sure[2];

	if (p != NULL)
		{
		r = p->region;

		/* First fill it all with blanks */
	   sb_fill (r, ' ', colors.popup);

		/* Now draw the box */
	   sb_box (r, boxtype, colors.popup);

	sb_move (r, 0, 1);
	   sb_puts (r, (unsigned char *) msgtxt[M_KILL_MAIL]);

		/* Now do the fields */
		sb_move (r, 1,2);
		sb_puts (r, msgtxt[M_ADDRESS_TO_KILL]);
		if (!sb_input_chars (r, 1, 19, node, 50, TRUE) && node[0])
			{
			sb_move (r, 2, 2);
			sb_puts (r, msgtxt[M_KILL_ALL_MAIL]);
		 sb_puts (r, msgtxt[M_ARE_YOU_SURE]);
			(void) sb_input_chars (r, 2, 38, sure, 1, TRUE);
			if(p)					/* Remove window */
				sb_restore(p);
			if (sure[0] == toupper (msgtxt[M_YES][0]))
				x = kill_node (node);
			}
		}

	/* Return value is never checked, just use x so lint and -W3 don't get mad */
	return (x);
}

/*
 * Delete/truncate files within a FLO file
 */

void delete_flo(char *fname)
{
	char buffer[80];
	FILE *fd;
	
	fd = fopen(fname, "rb");
	if(fd != NULL)
	{
		while(!feof(fd))
		{
			if(fgets(buffer, 79, fd) != NULL)
			{
				char *s = buffer;		/* Find end of filename */
				while(*s && !isspace(*s))
					s++;
				*s = 0;
				if((buffer[0] == SHOW_DELETE_AFTER) ||
				   (buffer[0] == DELETE_AFTER) )
				{
	                status_line (msgtxt[M_UNLINKING_MSG], &buffer[1]);
					unlink(&buffer[1]);
				}
				else if(buffer[0] == TRUNC_AFTER)
				{
					FILE *fd1;

  					status_line (msgtxt[M_TRUNC_MSG], &buffer[1]);

					fd1 = fopen (&buffer[1], "wb");
					if(fd1 != NULL)
                  		fclose(fd1);
				}
			}
		}
		fclose(fd);
	}
}



int kill_node (node)
char *node;
{
	ADDR addr;
	char *HoldName;
	char *p;
	char fname[100];
#ifdef OS_2
	struct FILEINFO fileinfo;
#else
#ifdef ATARIST
	struct FILEINFO fileinfo;
#else
	struct find_t fileinfo;
#endif
#endif

	if (find_address (node, &addr))
	{
		if (flag_file (TEST_AND_SET, &addr, 0))
		{
			return (-1);
		}

		HoldName = HoldAreaNameMunge(&addr);

		sprintf (fname, "%s%s.*", HoldName, Hex_Addr_Str (&addr));
#if defined(OS_2)
		if (!dir_findfirst (fname, 0, &fileinfo))
#elif defined(ATARIST)
		if (!dfind(&fileinfo, fname, 0))
#else
		if (!_dos_findfirst (fname, 0, &fileinfo))
#endif
		{
			do
			{
				if ((p = strchr (fileinfo.name, '.')) != NULL)
				{
					/* Don't delete the .bsy flags yet */
					if (strcmp (p, ".BSY") == 0)
						continue;
#ifdef IOS	/* Dont delete IOS's files which encode the address differently */
#ifdef NEW
					if((p[2] != 'U') && (p[3] == 'T'))
#else
					if((p[2] == 'A') && (p[3] == 'T'))
#endif
						continue;
#endif
				}
				sprintf (fname, "%s%s", HoldName, fileinfo.name);
                status_line (msgtxt[M_UNLINKING_MSG], fname);

				/* Kill files listed in flo file! */
				
				if(p && (p[2] == 'L') && (p[3] == 'O'))
					delete_flo(fname);
				unlink (fname);
#if defined(OS_2)
			} while (!dir_findnext (&fileinfo));
#elif defined(ATARIST)
			} while (!dnext(&fileinfo));
#else
			} while (!_dos_findnext (&fileinfo));
#endif
		}

#ifdef IOS	/* And kill the IOS packets too! */
#ifdef NEW	/* More complete IOS 4D naming */
		sprintf(fname, "%s%s.??T", HoldName, Addr36(&addr));
		if(!dfind(&fileinfo, fname, 0))
			do
			{
				if ((p = strchr (fileinfo.name, '.')) != NULL)
				{
					if(p[2] == 'U')	/* Old 2D OUT packet */
						continue;
					sprintf(fname, "%s%s", HoldName, fileinfo.name);
                	status_line (msgtxt[M_UNLINKING_MSG], fname);
					if(p[2] == 'F')	/* Flo file */
						delete_flo(fname);
					unlink(fname);
				}
			}			
			while(!dnext(&fileinfo));
			
#else	/* OLD IOS */
		sprintf(fname, "%s%s.?AT", HoldName, Addr36(&addr));
		if(!dfind(&fileinfo, fname, 0))
			do
			{
				sprintf(fname, "%s%s", HoldName, fileinfo.name);
                status_line (msgtxt[M_UNLINKING_MSG], fname);
				unlink(fname);
			} while(!dnext(&fileinfo));
#endif	/* NEW */
#endif

		flag_file (CLEAR_FLAG, &addr, 0);
		return (0);
	}
	else
	{
		return (-1);
	}
}

int add_request (char *node, char *file, char *password, char flavor)
{
	ADDR addr;
	char *HoldName;
	char fname[100];
	FILE *f;

	if (find_address (node, &addr))
	{
	   	HoldName = HoldAreaNameMunge(&addr);

		/* Now see if we should send anything back to him */

#ifdef IOS
		if(iosmode)
		   	sprintf (fname, "%s%s.%cRT", HoldName, Addr36(&addr), flavor == 'N' ? 'O' : flavor);
		else
#endif
		   	sprintf (fname, "%s%s.REQ", HoldName, Hex_Addr_Str (&addr));
		if ((f = fopen (fname, append_binary)) == NULL)
			return (-2);

#ifndef NEW /* NOCOMMENT  07/17/90 06:42am */
	  /* So ein Scheiss!  Er tut was rein, was er nachher
	   * gar nicht verstehen kann!
	   */
	  sprintf (fname, "%s", Pretty_Addr_Str &alias[0].ad);
	  fprintf (f, ";GET generated by node %s using %s\r\n", fname, ANNOUNCE);
#endif
		fprintf (f, "%s", file);
		if (password[0] != '\0')
			fprintf (f, " !%s", password);
		fprintf (f, "\r\n");

		fclose (f);

	    if (flavor != 'N')
#ifdef IOS
		if (!iosmode)
#endif
	    add_send (node, "", flavor);

		return (0);
	}
	else
		return (-1);
}

int add_send (char *node, char *file, char flavor)
{
	ADDR addr;
	char *HoldName;
	char fname[100];
	FILE *f;

	if ((flavor != 'C') && (flavor != 'H') && (flavor != 'N') && (flavor != 'D'))
		return (-3);

	if (flavor == 'N')
		flavor = 'F';

	if (find_address (node, &addr))
	{
	   HoldName = HoldAreaNameMunge(&addr);

#ifdef IOS
		if(iosmode)
		{
			if(flavor == 'F')
				flavor = 'O';
			sprintf (fname, "%s%s.%cFT", HoldName, Addr36(&addr), flavor);
		}
		else
#endif
			sprintf (fname, "%s%s.%cLO", HoldName, Hex_Addr_Str (&addr), flavor);

		if ((f = fopen (fname, append_binary)) == NULL)
			return (-2);
		else
		{
			if (file[0] != '\0')
			{
#ifndef NEW /* NOCOMMENT  07/17/90 06:42am */
			/* So ein Scheiss!	Er tut was rein, was er nachher
			 * gar nicht verstehen kann!
			 */
				sprintf (fname, "%s", Pretty_Addr_Str &alias[0].ad);
				fprintf (f, ";SEND generated by node %s using %s\r\n", fname, ANNOUNCE);
#endif
				fprintf (f, "%s\r\n", file);
			}
			fclose (f);
		}
	}
	else
		return (-1);

	return 0;
}
/* ---------------------------------------------------------------- */
/*
 * This code is from Roland Bohn
 *
 * It lets you change the flavour of outbound mail
 */

int move_flow(char *origflow, char *newflow)
{
	FILE *oldfp, *newfp;
	int w_err;
	byte tmp[512];
	
	w_err=0;
	oldfp=fopen(origflow,"r");
	
	if (oldfp!=NULL)
	{
		newfp=fopen(newflow,"a");
		if(newfp!=NULL)
		{
			fseek(newfp,0,SEEK_END);
			while (fgets(tmp,500,oldfp)!=NULL)
			{
				if (*tmp!='\0')
				{
					w_err=fputs(tmp,newfp);
					if (w_err==EOF)
						break;
				}
			}
			fclose(newfp);
		}
		fclose(oldfp);
		
		if (w_err!=EOF)
		{
			remove(origflow);
			return(TRUE);
		}
	}
	return(FALSE);
}

int change_flow(char *node, char *from, char *to)
{
	ADDR addr;
	char *HoldName;
	char fname[100];
	char tname[100];
	
	if (*from == *to)
		return(-3);
	if (*from!='C' && *from!='H' && *from!='D' && *from!='N')
		return(-3);
	if (*to!='C' && *to!='H' && *to!='D' && *to!='N')
		return(-3);
	
	if (find_address(node, &addr))
	{
		if (*from=='N')
			*from='F';
		if (*to=='N')
			*to='F';
		HoldName = HoldAreaNameMunge(&addr);
		sprintf (fname, "%s%s.%sLO", HoldName, Hex_Addr_Str (&addr), from);
		sprintf (tname, "%s%s.%sLO", HoldName, Hex_Addr_Str (&addr), to);
		move_flow(fname,tname);
		
		if (*from=='F')
			*from='O';
		sprintf (fname, "%s%s.%sUT", HoldName, Hex_Addr_Str (&addr), from);
		
		if (*to=='F')
			*to='O';
		sprintf (tname, "%s%s.%sUT", HoldName, Hex_Addr_Str (&addr), to);
		
		rename(fname,tname);	/* if tname already exists it will */
		                        /* only return an error */
#ifdef IOS
		{
			char *s = "APFR";
			while(*s)
			{
				sprintf(fname, "%s%s.%c%cT", HoldName, Addr36(&addr), *from, *s);
				sprintf(tname, "%s%s.%c%cT", HoldName, Addr36(&addr), *to, *s);
				if(*s == 'F')
					move_flow(fname, tname);
				else
					rename(fname,tname);
				s++;
			}
		}
#endif

	}
	else
		return(-1);
	
	return(0);
}

int Do_Change (SAVEP p, int x)
{
	REGIONP r;
	char node[51];
	char from[2];
	char to[2];
	char sure[2];
		
	x=0;
	*sure='\0';
	
	if (p != NULL)
	{
		r = p->region;
		
		while ((sure[0]=='\0' || sure[0]=='M') && x==0)
		{
			*node='\0';
			*from='\0';
			*to='\0';
			sure[0]=toupper(msgtxt[M_NO][0]);
			
			/* First fill it all with blanks */
			sb_fill (r, ' ', colors.popup);
			
			/* Now draw the box */
			sb_box (r, boxtype, colors.popup);
			
			sb_move (r, 0, 1);
			sb_puts (r, (unsigned char *) msgtxt[M_DO_CHANGE]);
			
			/* Now do the fields */
			sb_move (r, 1, 2);
			sb_puts (r, msgtxt[M_ADDRESS_TO_CHANGE]);
			if (!sb_input_chars (r, 1, (int)strlen(msgtxt[M_ADDRESS_TO_CHANGE])+2, node, 33, TRUE) && node[0])
			{
				sb_move (r, 2, 2);
				sb_puts (r, msgtxt[M_CHANGE_FROM]);
				if (!sb_input_chars (r, 2, (int)strlen(msgtxt[M_CHANGE_FROM])+2, from, 1, TRUE) && from[0])
				{
					sb_move (r, 3, 2);
					sb_puts (r, msgtxt[M_CHANGE_TO]);
					if (!sb_input_chars (r, 3, (int)strlen(msgtxt[M_CHANGE_TO])+2, to, 1, TRUE) && to[0])
					{
						sb_move (r, 4, 2);
						sb_puts (r, msgtxt[M_ARE_YOU_SURE]);
						sb_input_chars (r, 4, (int)strlen(msgtxt[M_ARE_YOU_SURE])+2, sure, 1, TRUE);
						if (sure[0] == toupper (msgtxt[M_YES][0]) || sure[0] == 'M')
							x = change_flow (node, from, to);
					}
				}
			}
		}
	}
		
	/* Return value is never checked, just use x so lint and -W3 don't get mad */
	return (x);
}

