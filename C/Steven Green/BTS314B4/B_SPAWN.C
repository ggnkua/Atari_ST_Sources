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
/*            This module was originally written by Bob Hartman             */
/*                                                                          */
/*                                                                          */
/*                        BinkleyTerm "Spawn" module                        */
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

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#ifndef LATTICE
#include <process.h>
#endif	/* LATTICE */
#include <string.h>

#ifdef __TOS__
#include <ext.h>
#else
#include <dos.h>
#endif	/* __TOS__ */

#ifdef OS_2
#define  INCL_DOS
#include <os2.h>
#endif	/* OS_2 */

#if defined(__TURBOC__)
#if !defined(__TOS__)
#include <dir.h>
#include <mem.h>
#endif	/* __TOS__ */

#elif defined(LATTICE)
#include <string.h>
#include <dos.h>

#else	/* !(LATTICE or TURBOC) */
#include <direct.h>
#include <memory.h>
#endif	/* __TURBOC */

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "com.h"
#include "vfossil.h"

#if defined(ATARIST)

#if !defined(__TURBOC__)

	/* This is "borrowed" from the Turbo C include file "TOS.H" */

	typedef struct		/* used by Pexec */
	{
		unsigned char	length;
		char			command_tail[128];
	} COMMAND;

#endif	/* __TURBOC__ */


#if defined(LATTICE)
  #include <basepage.h>
  extern BASEPAGE *_pbase;
  #define environment _pbase->p_env
#elif defined(__TURBOC__)
  #define environment _BasPag->p_env
#endif	/* __TURBOC__ */


#if defined(__PUREC__) || defined(__TURBOC__)

char *CLIcommand = NULL;
BOOLEAN useCLIcommand = FALSE;

/*
 * Replacement system() function to duplicate the Lattice one
 *
 * Now also uses the new configuration option CLIcommand
 */

typedef int cdecl (* fn)(const char *);

#define _shellp ((long *)(0x4f6L))

int system(const char *command)
{
	long ssp;
	fn func;
	char *prog;
	char *extra;
	
	/* See if there is a resident shell */
	ssp = Super(NULL);
	func = (fn)*_shellp;
	Super((void *)ssp);
	if(func)
		return (*func)(command);
	prog = getenv("SHELL");
	if(prog)
		extra = "-c";
	else
	{
		prog = getenv("COMSPEC");
		if(prog)
			extra = "/c";
	}
	if(prog)	
	{
		int result, error;
		char *com;
		size_t len;
		
		if(useCLIcommand)
			extra = CLIcommand;

		len = strlen(command) + 1;
		if(extra)
			len += strlen(extra) + 1;
		com = malloc(len);
		com[0] = 0;
		if(!com)
			return -1;
		if(extra)
		{
			strcpy(com, extra);
			strcat(com, " ");
		}
		strcat(com, command);
			
		error = exec(prog, com, environment, &result);
		free(com);
		if(error)
			return -1;
		else
			return result;
	}
	return -1;
}


#endif	/* __PUREC__ */

/*
 * Execute a shell or program
 */

long b_spawn( char *cmd_str )
{
	/* Some of this is by Enno Borgsteede */
	
   char this_dir[160];
   char *comspec;
   char cmd_line[160];
   COMMAND par;
   char *p, *p1;
   long ret;

   getcwd (this_dir,79);

   if (cmd_str)
   {
		/* If extended is .PRG .TOS .TTP then use Pexec otherwise system() */

		strncpy(cmd_line, cmd_str, 79);
		cmd_line[79] = 0;
		p = strtok(cmd_line, " \t");	/* 1st token is the command name */
		if(p && (p1 = strrchr(p, '.')) != NULL)
		{
			strupr(p);
			if( (strcmp(p1, ".PRG") == 0) ||
				(strcmp(p1, ".TOS") == 0) ||
				(strcmp(p1, ".TTP") == 0) )
			{
				if(strcmp(p1, ".PRG") == 0)		/* Its a GEM program */
					Cconws("\033f");
				p1 = strtok(NULL, "\n");
				if(p1)
				{
					strcpy(par.command_tail, p1);
					par.length = strlen(p1);
				}
				else
				{
					par.command_tail[0] = 0;
					par.length = 0;
				}
#ifdef LATTICE
				ret = Pexec(0, cmd_line, (char *)&par, environment);
#else
				ret = Pexec(0, cmd_line, &par, environment);
#endif
				goto done;
			}
		}
		ret = system(cmd_str);
   }
   else
   {
		if ((( comspec = getenv ("COMSPEC")) != NULL ) || (( comspec = getenv("SHELL"))) != NULL )
			ret = Pexec(0, comspec, "\0", environment);
   }
done:
   chgdsk (*this_dir - 'A');
   chdir (this_dir);
   
   return ret;
}


#else	/* !ATARIST */


long b_spawn (cmd_str)
char *cmd_str;
{

#if defined(OS_2)

   char this_dir[80];
   char *comspec;
   
   getcwd (this_dir,79);
   if (cmd_str)
      system (cmd_str);
   else
      {
      if (comspec = getenv ("COMSPEC"))
         spawnlp (P_WAIT, comspec, comspec, NULL);
      }
   DosSelectDisk (*this_dir - 'A' + 1);
   chdir (this_dir);

#elif defined(ATARIST)

   char this_dir[80];
   char *comspec;
#ifdef PEXEC
   char cmd_line[80];
   COMMAND par;
   char *p;
#endif
   
   getcwd (this_dir,79);
   if (cmd_str) {
#ifdef PEXEC
		strcpy( cmd_line, cmd_str);
		strtok( cmd_line, " \t");
		strupr( cmd_line);
		if (strstr( cmd_line, ".PRG")) Cconws( "\033f");
		p = strtok( NULL, "\n");
		if (p) {
			strcpy( par.command_tail, p);
			par.length = strlen( p);
		} else {
			par.command_tail[0] = 0;
			par.length = 0;
		}
		Pexec( 0, cmd_line, &par, _BasPag->p_env);
#else	/* !PEXEC */
      system (cmd_str);
#endif
   } else {
      if (comspec = getenv ("COMSPEC"))
         Pexec(0, comspec, "\0", NULL);
      }
   chgdsk (*this_dir - 'A');
   chdir (this_dir);

#else	/* Not ATARIST or OS2 */

   char *p, *p1;
   char **envp, *env, *save, **vp;
   char this_dir[80];
   int ecount;
   /* unsigned j; */

   /* Save where we are */
   (void) fflush (status_log);
   (void) real_flush (fileno (status_log));
   need_update = 0;

   (void) getcwd (this_dir, 79);

   if ((p = getenv ("COMSPEC")) == NULL)
      p = "COMMAND.COM";

   if (swapdir == NULL)
      {
      if (cmd_str != NULL)
         (void) system (cmd_str);
      else
         (void) spawnlp (P_WAIT, p, p, NULL);
      }
   else
      {
      /*
       * The following lines are really wierd.  Basically, we need to
       * pass a valid environment to DOS when we do the spawn.  Unfortunately,
       * it is very likely that we have changed the environment (like when
       * we alter the prompt), and therefore we have to make yet another
       * copy of it, and make sure it can be paragraph aligned.  We pass the
       * offset in paragraph format so it can just be added to the DS in
       * order to get the actual paragraph location.
       */
      ecount = 0;
      envp = environ;

      /* Count the chars in the environment */
      for (vp = envp; *vp; ecount += (int) strlen (*vp++) + 1)
         ;

      /* Add some fudge for nulls, etc */
      ecount += 5;

      /* Allocate space for a copy of the environment to be para aligned */
      save = env = malloc ((size_t) (ecount + 15));

      /* Align on a paragraph boundary - yucky, but it works */
      *((unsigned int *)&env) = (*((unsigned int *)&env)+0xf) & (~0xf);

      p1 = env;

      /* Copy old environment to the new */
      for (vp = envp; *vp; vp++)
         p1 = strchr(strcpy(p1, *vp), '\0') + 1;
      *p1++ = '\0';
      *p1++ = '\0';

      /* Now actually call our code that does the swapping */
      swapper (p, swapdir, (int) strlen (cmd_str), cmd_str, ((unsigned) (env)) >> 4);

      /* Free the stuff we allocated */
      free (save);
      }

   /* Go back to the proper directory */
#ifdef __TURBOC__
   setdisk ((unsigned) (this_dir[0] - 'A'));
#else /* __TURBOC__ */
   _dos_setdrive ((unsigned) ((int) this_dir[0] - 'A' + 1), &j);
#endif
   (void) chdir (this_dir);

#endif /* OS_2 */

	return 0;
}

#endif	/* ATARIST */



/*
 * popup window to execute command directly
 *
 * x=0 : from mailer
 * x=1 : from terminal
 */

do_shell(SAVEP p, int x)
{
	REGIONP r;
	char cmd[80];
	
	if ( x )
	{
	}
	
	if(p)
	{
		r = p->region;


		sb_fill (r, ' ', colors.popup);

		/* Now draw the box */

	   	sb_box (r, boxtype, colors.popup);
	   	sb_move (r, 0, 1);
	   	sb_puts (r, (unsigned char *) msgtxt[M_DO_SHELL]);

		/* Now do the fields */

		if (!sb_input_chars (r, 1, 2, cmd, 70, FALSE))
		{
#ifdef NEW
			if(p)				/* Remove popup box */
				sb_restore(p);
#endif
#ifdef NEW
			status_line ("%s '%s'", msgtxt[M_SHELLING], cmd);
#endif
			set_prior(4);
			mdm_init (modem_busy);
			exit_DTR ();
			set_prior(2);
			if (fullscreen)
				screen_clear ();
			vfossil_cursor (1);
			close_up ();
			change_prompt ();

			if(cmd[0])
			{
				b_spawn (cmd);
				cputs(msgtxt[M_ANYKEY]);
				READKB();
			}
			else
			{
			shellout:
				cputs (msgtxt[M_TYPE_EXIT]);
				b_spawn(NULL);
			}

			come_back ();
			set_up_outbound ();
			set_prior(4);					                     /* Always High */
			DTR_ON ();
			mdm_init (modem_init);
			reinit_ctr = reinit_time;
#ifdef NEW
			status_line (msgtxt[M_BINKLEY_BACK]);
#endif
			set_prior(2);					                     /* Regular */
			return 1;
		}
	}
	else
		goto shellout;
	return 0;
}

