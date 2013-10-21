/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <mintbind.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h" 
#include "xa_clnt.h"
#include "xa_shel.h"

XA_CLIENT * xa_fork_exec(G_i x_mode, XSHELW *xsh, char *fname, char *tail)
{
	XSHELW x_shell = *xsh;
	XA_CLIENT *new;
	Path defdir,shelldir;				/* HR 060901; xshell defdir */
	int defdrive = -1;
	int child = 0;

	IFDIAG(Path havedir; int drv;)
	
#if FIX_PC and !__AHCC__
	void  Pvfork1(void) 0x3F3C;
	void  Pvfork2(void) 0x0113;
	void  Pvfork3(void) 0x4E41;
	G_i   Pvfork4(void) 0x544F;			/* inline Pvfork */
#endif

#if GENERATE_DIAGS
	{
		char ppp[128];
		*ppp = 0;
		if (x_mode & SW_PSETLIMIT)		/* Limit child's memory? */
			strcat(ppp,"SW_PSETLIMIT,");
		if (x_mode & SW_UID)				/* XaAES extension - set user id */
			strcat(ppp, "SW_UID,");
		if (x_mode & SW_GID)				/* XaAES extension - set group id */
			strcat(ppp, "SW_GID,");
		if (x_mode & SW_PRENICE)		/* Was the child spawned as 'nice'? */
			strcat(ppp, "SW_PRENICE,");
		if (x_mode & SW_ENVIRON)
			strcat(ppp, "SW_ENVIRON");
		if (x_mode & SW_PDEFDIR)		/* Was the a default dir passed? */
			strcat(ppp, "SW_PDEFDIR");
		DIAG((D_shel,nil,"Extended shell_write bits: %s\n",ppp));
		if (x_mode & SW_PDEFDIR)		/* Was the a default dir passed? */
			DIAG((D_shel,nil,"def dir: '%s'\n", x_shell.defdir));
	}

	if ((x_mode & SW_ENVIRON))
		display_env(&x_shell.env, 1);

#endif

	if (x_mode & SW_PDEFDIR)
		strcpy(shelldir, x_shell.defdir);		/* HR 201101: Make it local (for memory protection) */
	else
		*shelldir = 0;

#if MOUSE_KLUDGE
	if (C.MOUSE_dev)
		Fclose(C.MOUSE_dev);		/* Kludge to get round a bug in MiNT (or moose?) */
#endif

	DIAG((D_shel,nil,"Pexec(200) '%s', tail: %ld(%lx) %d '%s'\n",
									fname,      tail, tail, *tail, tail + 1));
	DIAGS(("Normal Pexec\n"));
	IFDIAG (display_env(C.strings, 1);)

#if FIX_PC
	Pvfork1();
	Pvfork2();
	Pvfork3();
	child = Pvfork4();
#elif __AHCC__
	child = __VFORK__;
#else
	child = Pvfork();	/* Fork off a new process */
#endif

	if (!child)
	{						/* In child here */
		long rep;

      /*  debug_file is not a handle of the child ? */
		IFDIAG (if (D.debug_file > 0)
			        Fforce(1, D.debug_file);)			/* Redirect console output */

#if GENERATE_DIAGS
		DIAG((D_shel,nil,"*****   in Fork for '%s' *****\n", fname));
		drv = Dgetdrv();
		Dgetpath(havedir, 0);
		DIAG((D_shel,nil,"havedir(0) '%s'\n", havedir));
		Dgetpath(havedir, drv + 1);
		DIAG((D_shel,nil,"havedir(%d) '%s'\n", drv, havedir));
		DIAG((D_shel,nil,"Parent = %d\n", Pgetppid()));
#endif

		if (x_mode)
		{
			if (x_mode & SW_PSETLIMIT)		/* Limit child's memory? */
				Psetlimit(2, x_shell.psetlimit);

			if (x_mode & SW_UID)				/* XaAES extension - set user id */
				Psetuid(x_shell.uid);

			if (x_mode & SW_GID)				/* XaAES extension - set group id */
				Psetgid(x_shell.gid);

			if ((x_mode & SW_PRENICE) and x_shell.prenice)		/* Was the child spawned as 'nice'? */
				Pnice(x_shell.prenice);

			if ((x_mode & SW_PDEFDIR) and *shelldir)
			{
/*													            no name, set  */
				defdrive = drive_and_path(shelldir, defdir, nil, false, true);

				DIAG((D_shel,nil,"x_mode drive: %d\n", defdrive));
				DIAG((D_shel,nil,"       path: '%s'\n", defdir));
			}
		}

		/* It took me a few hours to realize that C.strings must be dereferenced,
			to get to the original type of string (which I call a 'superstring' */

		rep = Pexec(200, fname, tail,
				   (x_mode & SW_ENVIRON)
				                 ? x_shell.env
				                 : *C.strings);	/* Run the new client */

		DIAG((D_shel,nil,"Pexec replied %ld(%lx)\n", rep, rep));
		
		Pterm(rep);
		/* If we Pterm, we've failed to execute */
		/* HR: this approach passes the Pexec reply to the SIGCHILD code in signal.c */
	}
	
	new = NewClient(child);

	if (new)
		if ((x_mode & SW_PDEFDIR) and *shelldir)		/* Was the a default dir passed? */
		{
			new->xdrive = defdrive;
			strcpy(new->xpath, defdir);
		}

	return new;
}

