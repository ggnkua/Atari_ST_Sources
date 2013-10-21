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

#include <prelude.h>
#include <mintbind.h>
#include <string.h>
#include <stdarg.h>
#include "display.h"
#include "xa_types.h"

#if GENERATE_DIAGS
struct debugger D;		/* debugging catagories & data */
#endif

short xa_trace(char *);
extern SHARED S;

#if GENERATE_DIAGS
global
char *D_su = "    Sema %c up\n",
     *D_sd = "    Sema %c down: %ld\n",
     *D_sr = "  ::  %ld\n",
     *D_cl = "CONTROL: %d::%d, %d::%d, %d::%d\n",
     *D_fl = "%s,%d: ",
     *D_flu = "%ld,%d - %s,%d: "
     ;

extern
BUTTON button;

/* Unfortunately close and open doesnt work at all, and I just fail to see what's wrong. */
static
void toggle(void)
{
	if (D.debug_file and D.debug_lines)
	{
		D.bug_line++;
		if (D.bug_line > D.debug_lines)
		{
			display("********************************************************\n");
			display("**** %d %s\n", D.bug_line, D.debug_path);
#if 1
			Fseek(0, 1, 0);				/* reset file pointer. */ 
#else
			Fclose(D.debug_file);			/* We have now at least the last line lines. */
			*(D.debug_path + strlen(D.debug_path) - 1) ^= 1;
			D.debug_file = Fcreate(D.debug_path, 0);	/* Create new primary */
			Fforce(1, D.debug_file);		/* And go on */
#endif
			D.bug_line = 0;
		}
	}
}

global
char *w_owner(XA_WINDOW *w)
{
	static char n[512];
	if (w)
		if (w->owner)
			sdisplay(n,"'%s'(%d)", w->owner->name, w->owner->pid);
		else
			sdisplay(n,"->nil");
	else
		sdisplay(n,"nil");
	return n;
}

global
char *c_owner(XA_CLIENT *c)
{
	static char n[512];
	if (c)
		sdisplay(n,"'%s'(%d)", c->name, c->pid);
	else
		sdisplay(n,"nil");
	return n;
}

global
char *t_owner(XA_TREE *t)
{
	static char n[512];
	if (t)
		if (t->owner)
			sdisplay(n,"'%s'(%d)", t->owner->name, t->owner->pid);
		else
			sdisplay(n,"->nil");
	else
		sdisplay(n,"nil");
	return n;
}

global
void DeBug(debug_item item, XA_CLIENT *client, char *t, ...)
{
	int b,x,y;
	extern COMMON C;
	debug_item *point = client ? client->options.point : D.point;

	if (   D.debug_level eq 4
	    or (
	             (D.debug_level >= 2 and point[item])
	        and !(D.debug_level eq 3 and client eq nil)
	       )
	   )
	{
		int l = 0;
		char line[512];
		va_list argpoint;
		va_start(argpoint,t);
/* HR: xa_trace can by anything, anywhere.
	Making debug a function, made a very primitive variable tracer
	possible. Found some very nasty bugs by pinpointing the
	offence between 2 debug call's.
*/
#if 0
		l += xa_trace(line);
#endif
		if (D.point[D_v])
		{
			vq_mouse(C.P_handle, &b,&x,&y);
			l += sdisplay(line+l,"[B%d]", b);
			if (button.got or button.have)
				l += sdisplay(line+l,"[%c%c]", button.have ? 'H' : ' ', button.got ? 'G' : ' ');
		}
		if (S.mouse_cnt)
			l += sdisplay(line+l,"[M%d/%d]",S.mouse_cnt,S.mouse_lock);
		if (S.update_cnt)
			l += sdisplay(line+l,"[U%d/%d]",S.update_cnt,S.update_lock);
		if (D.debug_lines)
			l += sdisplay(line+l,"%ld - ",clock()-strtclk);
		if (client == nil)
			l += sdisplay(line+l," ~ ");

		l += vsdisplay(line+l,t,argpoint);
		if (line[l-1] == '\n')
			if (line[l-2] != '\r')
			{
				l++;
				line[l-2] = '\r';
				line[l-1] = '\n';
				line[l  ] = 0;
			}
		va_end(argpoint);
		Cconws(line);
		toggle();
	}
}

global
void display_env(char **env, int which)
{
	if (D.debug_level > 2 and D.point[D_shel])
	{
		if (which == 1)
		{
			char *e = *env;
			display("Environment as superstring:\n");
			while (*e)
			{
				display("%lx='%s'\n", e, e);
				e += strlen(e)+1;
			}
		} else
		{
			display("Environment as row of pointers:\n");
			while (*env)
			{
				display("%lx='%s'\n", *env, *env);
				env++;
			}
		}
	}
}

#endif
