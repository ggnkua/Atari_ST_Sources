/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <np_aes.h>			/* HR 151102: modern */
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>
#include <library.h>
#include <mint.h>
#include <xdialog.h>

#include "desk.h"
#include "environm.h"
#include "error.h"
#include "events.h"
#include "resource.h"
#include "xfilesys.h"
#include "file.h"
#include "icon.h"
#include "screen.h"
#include "startprg.h"
#include "window.h"

#define MAXTPATH	128
/* #define PATHSIZE	132 */ /* HR 240203 */

typedef struct
{
	const char *name;
	LNAME path;				/* HR 240203 */
	COMMAND cml;
	const char *envp;
	int appl_type;
	boolean new;
} PRG_INFO;

int cdecl(*old_critic) (int error);
PRG_INFO pinfo;

#ifdef DUMMY

 Not used.

static boolean _make_path(char *fname, char *path, char *name)
{
	if ((strlen(path) + strlen(name) + 1) > MAXTPATH)
		return FALSE;
	else
	{
		make_path(fname, path, name);
		return TRUE;
	}
}

static boolean findenv(char *file, char *npath)
{
	LNAME path;				/* HR 240203 */
	char *env, *fname;
	int i;

	if (strlen(file) > MAXTPATH)
		return FALSE;

	fname = strrchr(file, '\\');/* zoek begin van naam */

	if (fname == NULL)
		fname = strchr(file, ':');

	if (fname != NULL)
	{
		fname++;
		if (x_exist(file, EX_FILE) != FALSE)
			return TRUE;		/* file heeft zelf pad */
	}
	else
		fname = file;

	if ((npath != NULL) && (_make_path(path, npath, fname) != FALSE) &&
		(x_exist(path, EX_FILE) != FALSE))	/* Controleer alternatieve directory */
	{
		strcpy(file, path);
		return TRUE;
	}
	else
	{
		getroot(path);			/* Controleer huidige directory */
		Dgetpath(&path[2], 0);

		if ((_make_path(path, path, fname) != FALSE) && (x_exist(path, EX_FILE) != FALSE))
		{
			strcpy(file, path);
			return TRUE;
		}
		else
		{
			getroot(path);		/* Controleer root directory */

			if ((_make_path(path, path, fname) != FALSE) && (x_exist(path, EX_FILE) != FALSE))
			{
				strcpy(file, path);
				return TRUE;
			}
			else
			{
				if ((env = getenv("PATH")) == NULL)	/* Controleer environment */
					return FALSE;

				while (*env)
				{
					i = 0;

					while (*env && (*env != ';'))
					{
						if (i <= MAXTPATH)
							path[i++] = *env++;
					}

					path[i] = 0;

					if (*env)
						env++;

					if ((_make_path(path, path, fname) != FALSE) && (x_exist(path, EX_FILE) != FALSE))
					{
						strcpy(file, path);
						return TRUE;
					}
				}
			}
		}
	}

	return FALSE;
}
#endif

/*
 * Display an title with the program name in the top of the
 * screen.
 */

static void set_title(char *title)
{
	OBJECT dsktitle;
	TEDINFO ttd;

	dsktitle.ob_next = -1;
	dsktitle.ob_head = -1;
	dsktitle.ob_tail = -1;
	dsktitle.ob_type = G_BOXTEXT;
	dsktitle.ob_flags = LASTOB;
	dsktitle.ob_state = 0;
	dsktitle.ob_spec.tedinfo = &ttd;
	dsktitle.r.x = 0;
	dsktitle.r.y = 0;
	dsktitle.r.w = screen_info.dsk.w;
	dsktitle.r.h = screen_info.fnt_h + 2;

	ttd.te_ptext = title;
	ttd.te_font = 3;
	ttd.te_just = 2;
	ttd.te_color = 0x1F0;
	ttd.te_thickness = 0;
	ttd.te_txtlen = screen_info.dsk.w / screen_info.fnt_w;
	objc_draw(&dsktitle, ROOT, MAX_DEPTH, dsktitle.r.x, dsktitle.r.y, dsktitle.r.w, dsktitle.r.h);
}

/*
 * Trick to restore the mouse after some programs, which hide the
 * mouse. Does not work always.
 */

static void clean_up(void)
{
	v_hide_c(vdi_handle);
	v_show_c(vdi_handle, 0);
}

static int cdecl new_critic(int error /*,int drive*/ )
{
	return error;
}

static void install_critic(void)
{
	old_critic = (int cdecl(*)(int error)) Setexc(0x101, (void (*)()) new_critic);
}

static void remove_critic(void)
{
	Setexc(0x101, (void (*)()) old_critic);
}

/*
 * Copy an command line.
 */

static void copy_cmd(COMMAND *d, COMMAND *s)
{
	int i, m;
	char *s1, *s2;

	d->length = s->length;

	m = (int) (sizeof(d->command_tail) / sizeof(char));

	s1 = s->command_tail;
	s2 = d->command_tail;

	for (i = 0; i < m; i++)
		*s2++ = *s1++;
}

static void close_windows(void)
{
	int handle;

	if (tos1_4())
		wind_new();
	else
	{
		wind_get(0, WF_TOP, &handle);

		while (handle > 0)
		{
			wind_close(handle);
			wind_delete(handle);
			wind_get(0, WF_TOP, &handle);
		}
	}
}

static int exec_com(const char *name, COMMAND * cml, const char *envp,
					int appl_type)
{
	int error, *colors, stdout_handle, ostderr_handle;

	/* If save color option is set, save the current colors. */

	if ((options.cprefs & SAVE_COLORS) && ((colors = get_colors()) == NULL))
		return ENSMEM;

	/* If use file handle 2 as standard error option is set, redirect
	   file handle 2 to file handle 1. */

	if (options.cprefs & TOS_STDERR)
	{
		if ((stdout_handle = Fdup(1)) < 0)	/* Get a copy of stdout for Fforce. */
		{
			free(colors);
			return stdout_handle;
		}

		if ((ostderr_handle = Fdup(2)) < 0)	/* Duplicate old stderr. */
		{
			Fclose(stdout_handle);
			free(colors);
			return ostderr_handle;
		}

		Fforce(2,stdout_handle);
	}

	graf_mouse(HOURGLASS, NULL);

	if (wd_tmpcls() == FALSE)
	{
		menu_bar(menu, 0);

		pinfo.name = name;
		copy_cmd(&pinfo.cml, cml);
		pinfo.envp = envp;
		pinfo.appl_type = appl_type;
		pinfo.new = TRUE;

		while (pinfo.new == TRUE)
		{
			int appl_type;

			appl_type = pinfo.appl_type;
			pinfo.new = FALSE;

			shel_write(1, appl_type, 0, (char *)pinfo.name, (char *)&pinfo.cml);

			graf_mouse(HOURGLASS, NULL);
			wind_set(0, WF_NEWDESK, NULL, 0);

			{
				LNAME pname;		/* HR 240203 */

				split_path(pinfo.path, pname, pinfo.name);
				set_title(pname);
			}

			appl_exit();
			appl_init();
			close_windows();

			if (appl_type == 0)
			{
				graf_mouse(M_OFF, NULL);
				v_enter_cur(vdi_handle);
				install_critic();
			}
			else
				dsk_draw();

			error = (int) x_exec(0, pinfo.name, &pinfo.cml, pinfo.envp);

			if (appl_type == 0)
			{
				remove_critic();

				if ((options.cprefs & TOS_KEY) != 0)
				{
					int d, mbs;
					char *s;

					rsrc_gaddr(R_STRING, MKEYCONT, &s);

					v_curtext(vdi_handle, s);

					while (Bconstat(2))
						Bconin(2);

					while (!Bconstat(2) &&
						   (vq_mouse(vdi_handle, &mbs, &d, &d), mbs == 0));
				}

				v_exit_cur(vdi_handle);
				graf_mouse(M_ON, NULL);
			}
			else
				close_windows();

			{
				LNAME cmd;				/* HR 240203 */
				char tail[128];

				shel_read(cmd, tail);

				if (strcmp(cmd, pinfo.name) && cmd[0])
				{
					static LNAME name;		/* HR 240203 */

					pinfo.new = TRUE;
					strcpy(name, cmd);
					pinfo.name = name;
					copy_cmd(&pinfo.cml, (COMMAND *)tail);
					pinfo.envp = NULL;
					pinfo.appl_type = 1;	/* Moet verbeterd worden. */
				}
			}

			if (pinfo.new == TRUE)
			{
				char *h;

				if ((h = x_fullname(pinfo.name, &error)) != NULL)
				{
					if (strlen(h) <= MAXTPATH)
						strcpy((char *) pinfo.name, h);
					else
					{
						error = EPTHTL;
						pinfo.new = FALSE;
					}
					free(h);
				}
				else
					pinfo.new = FALSE;
			}

			clean_up();
		}

		shel_write(0, 1, 0, "", "\0\0");

		wind_set(0, WF_NEWDESK, desktop, 0);
		dsk_draw();
		menu_bar(menu, 1);
		wd_reopen();
	}

	clr_key_buf();
	graf_mouse(ARROW, NULL);

	/* Restore handle 2 to old handle. */

	if (options.cprefs & TOS_STDERR)
	{
		Fforce(2,ostderr_handle);
		Fclose(ostderr_handle);
		Fclose(stdout_handle);
	}

	/* Restore old colors. */

	if (options.cprefs & SAVE_COLORS)
	{
		set_colors(colors);
		free(colors);
	}

	return error;
}

/*
 * Description: Build an environment with an ARGV variable.
 *
 * Result: pointer to environment or NULL if an error occured.
 */

const char *make_env(const char *program, const char *cmdline)
{
	long envl, argvl;
	char h, *d, *envp;
	const char *s;
	boolean q = FALSE;

	envl = envlen();
	argvl = envl + strlen(cmdline) + sizeof("ARGV=") + strlen(program) + 3;

	if ((envp = malloc(argvl)) != NULL)
	{
		d = envp;

		/* Copy current environment. */

		s = _BasPag->p_env;
		do
		{
			while (*s)
				*d++ = *s++;
			*d++ = *s++;
		}
		while (*s);

		/* Add ARGV variable. */

		s = "ARGV=";
		while (*s)
			*d++ = *s++;
		*d++ = 0;

		/* Add program name. */

		s = program;
		while (*s)
			*d++ = *s++;
		*d++ = 0;

		/* Add command line. */

		s = cmdline;
		while ((h = *s++) != 0)
		{
			if ((h == ' ') && (q == FALSE))
			{
				*d++ = 0;
				while (*s == ' ')
					s++;
			}
			else if (h == '"')
			{
				if (*s == '"')
					*d++ = *s++;
				else
					q = (q) ? FALSE : TRUE;
			}
			else
				*d++ = h;
		}

		*d++ = 0;
		*d = 0;
	}
	else
		xform_error(ENSMEM);

	return envp;
}

/*
 * Description: Start a program. If 'path' is not NULL, 'path' is
 * used as current directory. If 'path' is NULL, the directory of
 * the program is used as current directory.
 *
 * Parameters:
 *
 * fname		- filename of program
 * cl			- command line (first byte is length)
 * path			- current directory
 * prg			- application type
 * argv			- use argv protocol
 * kstate		- state of SHIFT, CONTROL and ALTERNATE keys
 */

#pragma warn -par

void start_prg(const char *fname, const char *cmdline,
			   const char *path, ApplType prg, boolean argv,
			   int kstate)
{
#if _MINT_
	if (   _GemParBlk.glob.count != -1
	    && magx == 0		/* HR 151102 */
	   )
#endif
	{
		/* AES is not multitasking, use Pexec() to start program. */

		COMMAND cl;
		char *prgpath, *olddir;
		const char *envp;
		int error = 0, appl_type;
#if _MINT_
		boolean background = (kstate & 4) ? TRUE : FALSE;
#endif

		/* Make a copy of cmdline. */

		memset(cl.command_tail, 0, sizeof(cl.command_tail));
		strsncpy(cl.command_tail, cmdline + 1, 126);		/* HR 120203: secure cpy */
		cl.length = *cmdline;

		if (prg == PACC)				/* HR 101202: Dont start acc in single tos */
		{
			alert_printf(1, MCANTACC);
			return;
		}

		appl_type = ((prg == PGEM) || (prg == PGTP)) ? 1 : 0;

#if _MINT_
		if (mint)				/* HR 151102 */
			if ((appl_type == 1) && (background == TRUE))
			{
				alert_printf(1, MGEMBACK);
				return;
			}
#endif

		if (argv)
		{
			if ((envp = make_env(fname, cmdline + 1)) == NULL)
				return;
			if (cl.length != 0)
				cl.length = 127;
		}
		else
			envp = NULL;

		if ((prgpath = fn_get_path(fname)) != NULL)
		{
			if ((olddir = getdir(&error)) != NULL)
			{
				graf_mouse(HOURGLASS, NULL);
				error = chdir((path == NULL) ? prgpath : path);
				graf_mouse(ARROW, NULL);

				if (error == 0)
				{
#if _MINT_
					if (mint && background == TRUE)			/* HR 151102 */
						error = (int) x_exec(100, fname, &cl, envp);
					else
#endif
						error = exec_com(fname, &cl, envp, appl_type);
				}

				graf_mouse(HOURGLASS, NULL);
				chdir(olddir);
				graf_mouse(ARROW, NULL);

				free(olddir);
			}

			free(prgpath);
		}

		if (envp)
			free(envp);

		if (error < 0)
			xform_error(error);
	}
#if _MINT_
	else
	{
		/* AES is multitasking, use shel_write() to start program. */

		if (prg == PACC)			/* HR 101202 */
			shel_write(3, 0, 100, (char *)fname, "\0");
		else
		{
			int appl_type, mode;
			void *p[5];
			char prgpath[256], *h;
	
			appl_type = ((prg == PGEM) || (prg == PGTP)) ? 1 : 0;
			mode = 0x400 | 1;				/* HR 151102: always use 1 */
	
			if (path == NULL)
			{
				strcpy(prgpath, fname);
				if ((h = strrchr(prgpath, '\\')) != NULL)
					h[1] = 0;
			}
			else
			{
				strcpy(prgpath, path);
				strcat(prgpath,"\\");		/* Necessary for Geneva. */
			}
	
			if (argv)
				*(char *)cmdline = 127;
	
			p[0] = fname;
			p[1] = NULL;
			p[2] = NULL;
			p[3] = prgpath;
			p[4] = NULL;
	
	/* HR 151102: SHW_PARALLEL(100) for MagiC */
			shel_write(mode, appl_type, magx ? 100 : (int) argv,
			                 (char *) p, (char *) cmdline);
		}
	}
#endif
}

#pragma .par
