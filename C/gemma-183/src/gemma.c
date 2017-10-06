/* Main module */

/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

# include <fcntl.h>
# include <mint/dcntl.h>
# include <errno.h>
# include <string.h>

# include "dosproto.h"
# include "gemma.h"
# include "user.h"

long gemma_init(void);

/* Global variables */

PROC_ARRAY *pidtable[MAX_PID+1];
long users;			/* number of processes using the lib */
short whitebak;

static const char procpath[] = "u:\\proc";
const long sema_fork = (const long)gemma_init;

# ifdef DEBUG
void
debug_print(char *string)
{
	char msg[128], c;
	short x, y = 0;

	for (x = 0; x < 128; x++)
	{
		c = string[x];
		if (c == '\n')
		{
			msg[y] = '\r';
			y++;
		}
		msg[y++] = c;
		if (!c)
			break;
	}
	_conws(msg);
}
# endif

/* Utility routines */

char *
getenv(BASEPAGE *bp, const char *var)
{
	char *env = (char *)bp->p_env;
	long len = strlen(var);

	do {
		if (strncmp(env, var, len) == 0)
		{
			env += len;

			DEBUGMSG("getenv: -> ");
			DEBUGMSG(env);
			DEBUGMSG("\n");

			return env;
		}
		while(*env++);
	} while(*env);

	return 0;
}

static inline long
get_page_size(void)
{
	short drv;
	char d, cwd[512];
	long r, meminfo[4];

	drv = _getdrv();
	d = procpath[0];
	d &= 0x5f;
	d -= 'A';
	_setdrv((short)d);
	r = _getcwd(cwd, 0, sizeof(cwd));
	if (r < 0)
	{
		_setdrv(drv);
		return sflags.pagesize;
	}
	if (!cwd[0])
	{
		cwd[0] = '\\';
		cwd[1] = 0;
	}
	r = _setpath(procpath);
	if (r < 0)
	{
		_setdrv(drv);
		return sflags.pagesize;
	}
	r = _dfree((long *)meminfo, 0);
	_setpath(cwd);
	_setdrv(drv);
	if (r < 0)
		return sflags.pagesize;
	if (meminfo[3] < sflags.minpagesize)
		return sflags.pagesize;

	return meminfo[3];
}

static long
_getpid(BASEPAGE *bp)
{
	return bp->p_undef[0];
}

/* System routines */

long
gemma_init(void)
{
	long r;

	r = sema_create(sema_fork);
	sflags.pagesize = get_page_size();
	if (r < 0)
		return 0;
	return sema_release(sema_fork);
}

void
gemma_exit(void)
{
	long r;

	r = sema_request(sema_fork);
	if (r < 0)
		return;
	sema_destroy(sema_fork);
	return;
}

/* Process intialization and closing */

long
gemma_open(BASEPAGE *bp)
{
	PROC_ARRAY *proc;
	long pid = _sgetpid();

	if (pid > MAX_PID)
	{
		_conws("gemma.slb: cannot service so many processes!!\r\n");
		return -EPROCLIM;
	}

	bp->p_undef[0] = pid;

	proc = (PROC_ARRAY *)_alloc(sizeof(PROC_ARRAY));
	if ((long)proc < 0)
		return (long)proc;
	pidtable[pid] = proc;
	bzero(proc, sizeof(PROC_ARRAY));

	proc->gem.aesparams[0] = (long)proc->gem.control;
	proc->gem.aesparams[1] = (long)proc->gem.global;
	proc->gem.aesparams[2] = (long)proc->gem.int_in;
	proc->gem.aesparams[3] = (long)proc->gem.int_out;
	proc->gem.aesparams[4] = (long)proc->gem.addr_in;
	proc->gem.aesparams[5] = (long)proc->gem.addr_out;

	proc->gem.vdiparams[0] = (long)proc->gem.contrl;
	proc->gem.vdiparams[1] = (long)proc->gem.intin;
	proc->gem.vdiparams[2] = (long)proc->gem.ptsin;
	proc->gem.vdiparams[3] = (long)proc->gem.intout;
	proc->gem.vdiparams[4] = (long)proc->gem.ptsout;

	proc->base = bp;

	users++;

	return 0;		/* uff */
}

void
gemma_close(BASEPAGE *bp)
{
	long pid = _getpid(bp);
	PROC_ARRAY *proc;

	users--;
	proc = pidtable[pid];
	if (!proc)
		return;		/* huuh? */
	pidtable[pid] = 0;
	_free((long)proc);
}

/* Internal utilities */

OBJECT *
obj2addr(PROC_ARRAY *proc, short type, ulong obj)
{
	if (obj > 65536UL)
		return (OBJECT *)obj;

	return (OBJECT *)rsrc_xgaddr(proc->base, 0L, 3, type, (short)obj, proc);
}

PROC_ARRAY *
get_contrl(BASEPAGE *bp)
{
	return pidtable[_getpid(bp)];
}

/* EOF */
