/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include "prelude.h"
#include "debug.h"
#include <mintbind.h>
#include <string.h>
#include <stdarg.h>
#include "display.h"

#if GENERATE_DIAGS
struct debugger D;		/* debugging catagories & data */
#endif

short xa_trace(char *);

#if GENERATE_DIAGS
global
char *D_su = "    Sema %c up\n",
     *D_sd = "    Sema %c down: %ld\n",
     *D_sr = "  ::  %ld\n",
     *D_cl = "CONTROL: %d::%d, %d::%d, %d::%d\n",
     *D_fl = "%s,%d: ",
     *D_flu = "%ld,%d - %s,%d: "
     ;

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
void DeBug(debug_item item, short pid, char *t, ...)
{
    /* D.all.point == 1  only the DIAGS macro's which do not arrive here */
/*	if (   (     D.all.point == 3
		     and (   !item.point
		         or D.all.pid == pid
		        )
		   )
		or (    D.all.point == 2
		    and  item.point
		    and  (   item.pid == 0	/* plain point specified = all */
			     or  pid < 0
			     or (pid > 0 and pid == item.pid)
			    )
		   )
		)
	{
*/
	if (   (D.all.point == 3 and !item.point)  /* 'all' and points specified means "All but these points" :-) */
		or (D.all.point == 2 and  item.point)
		)
	{
		if (   item.pid == 0	/* plain point specified = all */
			or  pid < 0
			or (pid > 0 and pid == item.pid)
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
			if (D.debug_lines)
				l += sdisplay(line+l,"%ld - ",clock()-strtclk);

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
}

global
void display_env(char **env, int which)
{
	if (   (D.all.point == 3 and !D.shel.point)  /* 'all' and points specified means "All but these points" :-) */
		or (D.all.point == 2 and  D.shel.point)
		)
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
		} /* else */
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
