/* Process & thread functions
 */

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

# include <st-out.h>
# include <string.h>
# include <signal.h>
# include <fcntl.h>
# include <errno.h>
# include <mint/dcntl.h>

# include "dosproto.h"
# include "gemma.h"

# define SMS_JUSTSEND	0
# define SMS_REPLSEND	1
# define SMS_PID2APID	0x8000

extern const long sema_fork;
static const char selfname[] = "u:\\proc\\.-1";
static const char smsname[] = "u:\\pipe\\sms";

typedef struct smsblk SMSBLK;

struct smsblk
{
	unsigned short command;
	short destproc;
	short length;
	short res[5];
	short msg[8];
};

static inline long
smswrite(SMSBLK *smsblk)
{
	long file, r;

	file = r = _open(smsname, O_WRONLY|O_DENYNONE);
	if (r < 0)
		return r;
	r = _write(file, sizeof(SMSBLK), (void *)smsblk);
	_close(file);

	return 0;
}

void
sig_child(void)
{
	long p;
	SMSBLK sms;

	p = _wait3(1, 0L);
	if (p == 0)
		return;
	bzero(&sms, sizeof(SMSBLK));

	sms.command = (unsigned short)(SMS_JUSTSEND|SMS_PID2APID);
	sms.destproc = (short)_sgetpid();
	sms.length = 16;
	sms.msg[0] = CH_EXIT;
	sms.msg[1] = 0;
	sms.msg[2] = 0;
	sms.msg[3] = (short)(p>>16);
	sms.msg[4] = (short)p;
	smswrite(&sms);
}

static inline long
getprgflags(void)
{
	long file, r, flags;

	file = r = _open(selfname, O_RDONLY);
	if (r < 0)
		return (F_FASTLOAD | F_ALTLOAD | F_ALTALLOC);
	r = _cntl(file, &flags, PGETFLAGS);
	_close(file);
	if (r < 0)
		return (F_FASTLOAD | F_ALTLOAD | F_ALTALLOC);

	return flags;
}

/* Find the `file' in `path'. That last
 * is the list of folders to search by.
 */

static void
fsearch(char *path, char *file, char *filespec)
{
	struct xattr xa;
	char *tok;
	long r;

	do {
		tok = filespec;
		*tok = 0;
		while(*path)
		{
			if ((*path == ',') || (*path == ';'))
			{
				*tok = 0;
				path++;
				break;
			}
			*tok++ = *path++;
		}
		strcat(filespec, "/");
		strcat(filespec, file);
		r = _stat(0, filespec, &xa);
	}
	while(r && *path);

	if (r)
		filespec[0] = 0;
}

/* Return the size of the environment pointed to by `env' */

static long
getenvsize(char *env)
{
	long s, size = 0;

	do {
		s = strlen(env);
		s++;			/* trailing NULL */
		size += s;
		env += s;
	} while(*env);

	size++;				/* the additional NULL at the end */

	return size;
}

/* Add string `var' at the end of the environment `env'.
 * Assumes there is enough space there.
 */

static void
setvar(char *env, char *var)
{
	long len;

	env += (getenvsize(env) - 1);

	strcpy(env, var);
	len = strlen(env);
	len++;
	env[len] = 0;
}

/* Special getenv() to search for the old ARGV= string and kill it
 */

static inline char *
getargv(char *env)
{
	do {
		if (strncmp(env, "ARGV=", sizeof("ARGV=")) == 0)
			return env;
		while(*env++);
	} while(*env);

	return 0;
}

/* Like Pexec(), but:
 *
 * - searches through $PATH
 * - runs scripts
 * - accepts command tail as C string of any length (limited by free mem)
 * - constructs ARGV out of it.
 *
 * `flags' is a bitfield:
 * 0 - redirect stdout to /dev/null
 * 1 - redirect stderr to /dev/null
 * 2 - register SIGCHLD handler
 *
 */

long
proc_exec(BASEPAGE *bp, long fn, short nargs, \
		short mode, long flags, char *cmd, char *tail, char *env, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	char *newcmd = tail, *newenv = env;
	char cmdline[128], filespec[2048], temp[2048];
	short load = 0, oldout = 0, newout = -1, olderr = 0;
	long r, newtail = -1, envbuf = -1;

	if (nargs < 5) return -EINVAL;
	if (nargs >= 6) proc = p;
	if ((nargs < 6) || !proc) proc = get_contrl(bp);

/* 0, filename, command tail, env
 * 3, filename, command tail, env
 * 5, unused, command tail, env
 * 7, flags, command tail, env
 * 100, filename, command tail, env
 * 200, filename, command tail, env
 */

	switch(mode)
	{
		case 0:
		case 3:
		case 100:
		case 200:
			load = 1;
		case 5:
		case 7:
			break;
		default:		/* 4, 6, 104, 106, 204, 206, ... */
			goto exec;
	}

	temp[0] = 0;

	if (load)
	{
		long x;
		short handle;
		char *path;
		struct xattr xa;

		if ((*cmd == '/') || (*cmd == '\\'))
		{
			strcpy(temp, "u:");
			strncpy(temp + 2, cmd, sizeof(temp) - 2);
		}
		else
			strncpy(temp, cmd, sizeof(temp));

		for (x = 0; x < sizeof(temp); x++)
		{
			if (temp[x] == '\\')
				temp[x] = '/';
			if (!temp[x])
				break;
		}

		cmd = temp;

		filespec[0] = 0;
		if (!strchr(cmd, '/'))
		{
			if (_stat(0, cmd, &xa) < 0)
			{
				path = getenv(bp, "PATH=");
				if (path)
					fsearch(path, cmd, filespec);
			}
		}
		if (!filespec[0])
			strncpy(filespec, cmd, sizeof(filespec));

		cmd = filespec;
		temp[0] = 0;

		handle = _open(cmd, O_RDONLY);
		if (handle < 0)
			return (long)handle;
		r = _read(handle, sizeof(cmdline), cmdline);
		_close(handle);
		if (r < 2)
			r = -EFTYPE;
		if (r < 0)
			return r;
		if (*(short *)cmdline == 0x2321)	/* `#!' */
		{
			char temp2[2048];		/* > 6k of stack!! :< */

			if (cmd[1] == ':')
				strncpy(temp, cmd + 2, sizeof(temp));
			else
				strncpy(temp, cmd, sizeof(temp));

			*cmd = 0;
			if (cmdline[2] == '/')
				strcpy(cmd, "u:");

			for (x = 0; x < sizeof(cmdline); x++)
			{
				if (cmdline[x] == '\n')
					cmdline[x] = 0;
				if (!cmdline[x])
					break;
			}
			strcat(cmd, cmdline + 2);
			temp2[0] = 0;
			if (!strchr(cmd, '/'))
			{
				if (_stat(0, cmd, &xa) < 0)
				{
					path = getenv(bp, "PATH=");
					if (path)
						fsearch(path, cmd, temp2);
				}
			}
			if (temp2[0])
			{
				x = 0;
				while((x < sizeof(temp2)) && temp2[x])
				{
					if (temp2[x] == '\\')
						temp2[x] = '/';
					x++;
				}
				strncpy(cmd, temp2, sizeof(temp2));
			}
		}
	}

	/* If a script was specified to execute, the `cmd' points to the
	 * shell executable which will run the script. The pathname to
	 * the script itself is held in `temp'. If `temp' is empty, this
	 * means that the `cmd' specifies a binary to launch directly.
	 */

	if (temp[0])
	{
		r = strlen(temp);
		if (tail)
			r += strlen(tail);
		r += 0x1fff;
		r &= ~0x1fff;
		newtail = _alloc(r);
		if (newtail < 0)
			return newtail;
		strcpy((char *)newtail, temp);
		if (tail && strlen(tail))
		{
			strcat((char *)newtail, " ");
			strcat((char *)newtail, tail);
		}
		tail = (char *)newtail;
	}

	newcmd = cmdline;

	if (tail)
	{
		long x, envsize = 0;
		char *t;

		r = strlen(tail);
		if (r)
		{
			strncpy(newcmd + 1, tail, 127);

			if (r > 126)
				newcmd[0] = 127;
			else
				newcmd[0] = (char)r;

			if ((long)env > 0)
				envsize = getenvsize(env);
			if (!env)
				envsize = getenvsize(bp->p_env);
			envsize += DEF_PAGE_SIZE;	/* should be enough for ARGV string */
			envsize = LROUND(envsize);
			envbuf = _alloc(envsize);
			if (envbuf < 0)
			{
				if (newtail != -1)
					_free(newtail);
				return envbuf;
			}
			newenv = (char *)envbuf;
			bzero(newenv, envsize);
			if ((long)env > 0)
				memcpy(newenv, env, getenvsize(env));
			if (!env)
				memcpy(newenv, bp->p_env, getenvsize(bp->p_env));
			t = getargv(newenv);
			if (t)
				*t = 0;
			setvar(newenv, "ARGV=");
			setvar(newenv, cmd);
			x = 0;
			while (tail[x])
			{
				char tmp[512];
				short i;

				while(tail[x] == 0x20)
					x++;
				i = 0;
				if ((tail[x] == '\'') && (tail[x + 1] != '\''))
				{
					x++;
					for(;;)
					{
						char c;

						c = tail[x++];
						if (!c)
							break;		/* broken argument */
						if (c != '\'')
							tmp[i++] = c;
						else
						{
							if (tail[x] == '\'')
							{
								x++;
								tmp[i++] = c;
							}
							else if (tail[x] == 0x20)
								break;
						}
					}
				}
				else
					while(tail[x] && (tail[x] != 0x20))
						tmp[i++] = tail[x++];
				tmp[i] = 0;
				setvar(newenv, tmp);
			}
			r = getenvsize(newenv);
			if (r < envsize)
				_shrink(newenv, r);
		}
	}

exec:
	if (flags & 4)
		_signal(SIGCHLD, sig_child);

	if (flags & 3)
	{
		newout = _open("u:/dev/null", O_WRONLY);
		if (newout >= 0)
		{
			if (flags & 1)
			{
				oldout = _dup(1);
				_force(1, newout);
			}
			if (flags & 2)
			{
				olderr = _dup(2);
				_force(2, newout);
			}
		}
	}

	r = _exec(mode, cmd, newcmd, newenv);

	if ((flags & 3) && (newout >= 0))
	{
		if (flags & 1)
			_force(1, oldout);
		if (flags & 2)
			_force(2, olderr);
		_close(newout);
	}

	if (newtail != -1)
		_free(newtail);
	if (envbuf != -1)
		_free(envbuf);

	return r;
}

long
thread_fork(BASEPAGE *bp, long fn, short nargs, \
		void *startup, void *address, char *proctitle, long stacksize, long opt, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	BASEPAGE *new;
	long mode = 0, flags, size, oldsig = 0, pid;
	short execmode;

	if (nargs < 3) return -EINVAL;
	if (nargs >= 5) mode = opt;
	if (nargs >= 6) proc = p;
	if ((nargs < 6) || !proc) proc = get_contrl(bp);

	if (fn == 13)
		execmode = 104;		/* just go, sharing mode */
	else
		execmode = 204;		/* overlay, then go */

	flags = getprgflags();

	sema_request(sema_fork);

	new = (BASEPAGE *)_exec(7, (void *)flags, "", 0);
	if ((long)new < 0)
		new = (BASEPAGE *)_exec(5, 0, "", 0);
	if ((long)new <= 0)
	{
		sema_release(sema_fork);
		if (!(long)new)
			return -ENOMEM;
		return (long)new;
	}
	if (nargs >= 4)
		size = stacksize;
	else
		size = 0x00001f00L;
	size += 0x00000100L;
	_shrink(new, size);

	sema_release(sema_fork);

	new->p_tbase = startup;
	new->p_dbase = address;

	if (mode & 1)
		oldsig = _signal(SIGCHLD, sig_child);

	pid = _exec(execmode, proctitle, new, 0);

	_free((long)new->p_env);
	_free((long)new);

	if (oldsig && (pid < 0))
		_signal(SIGCHLD, (void *)oldsig);

	return pid;
}

/* EOF */
