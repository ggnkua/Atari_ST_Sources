/* AV protocol support */

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

# include <errno.h>
# include <string.h>

# include "dosproto.h"
# include "gemma.h"
# include "gemproto.h"
# include "alert.h"

# define AV_PATH_UPDATE	0x4730
# define AV_VIEW	0x4751
# define VA_START	0x4711

static inline void
_mrelease(PROC_ARRAY *proc, long adr)
{
	_evnt_timer(proc, sflags.release_delay);
	_free(adr);
}

static long
get_server(PROC_ARRAY *proc, char *server)
{
	char *av, tmp[64];
	short x;

	av = getenv(proc->base, server);

	if (!av)
		return -ENOENT;

	bzero(tmp, sizeof(tmp));
	strncpy(tmp, av, sizeof(tmp));

	for (x = 0; x < sizeof(tmp); x++)
	{
		if (!tmp[x])
			tmp[x] = 0x20;
	}

	return _appl_find(proc, tmp);
}

long
_send(PROC_ARRAY *proc, short command, short dest, char *buf, long blen)
{
	short *avbuf;
	long r;
	char *msg;

	avbuf = (short *)r = _rdalloc(blen + 16);
	if (r < 0)
		return r;
	bzero(avbuf, sflags.pagesize);

	msg = (char *)(avbuf+8);
	r = (long)msg;

	avbuf[0] = command;
	avbuf[1] = proc->gem.global[2];
	avbuf[3] = (short)(r>>16);
	avbuf[4] = (short)r;

	memcpy(msg, buf, blen);

	r = 0;
	if (!_appl_write(proc, dest, 16, avbuf))
		r = -ESRCH;

	_mrelease(proc, (long)avbuf);

	return r;
}

static long
_va_send(PROC_ARRAY *proc, short command, char *buf, long buflen)
{
	short avpid;

	avpid = get_server(proc, "AVSERVER=");
	if (avpid < 0)
		return (long)avpid;

	return _send(proc, command, avpid, buf, buflen);
}

/* User functions */

long
va_send(BASEPAGE *bp, long fn, short nargs, \
		short command, char *msg, long len, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;

	if (nargs < 3) return -EINVAL;
	if (nargs >= 4) proc = p;
	if ((nargs < 4) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;

	return _va_send(proc, command, msg, len);
}

long
av_dir_update(BASEPAGE *bp, long fn, short nargs, short drive, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	char msg[4];
	long r;

	if (!nargs) return -EINVAL;
	if (nargs >= 2) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;

	msg[0] = (char)drive+'A';
	msg[1] = ':';
	msg[2] = '\\';
	msg[3] = 0;

	r = _va_send(proc, AV_PATH_UPDATE, msg, sizeof(msg));

	if (r < 0)
	{
		short ap[4];

		_appl_getinfo(proc, 4, ap);
		if (ap[2])
		{
			/* ... */
		}
	}

	return r;
}

long
av_view(BASEPAGE *bp, long fn, short nargs, char *pathname, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	char path[1024], *pname;
	long r;

	if (!nargs) return -EINVAL;
	if (nargs >= 2) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;

	pname = pathname;

	if (pname[1] != ':')
	{
		path[0] = 0;
		if ((pname[0] != '/') && (pname[0] != '\\'))
		{
			r = _getdrv();
			if (r < 0)
				return r;
			path[0] = (char)r + 'A';
			path[1] = ':';
			r = _getcwd(&path[2], 0, sizeof(path) - 2);
			if (r < 0)
				return r;
		}
		else
		{
			path[0] = 'U';
			path[1] = ':';
			path[2] = 0;
		}
		strcat(path, "\\");
		strcat(path, pathname);
		pname = path;
	}

	return _va_send(proc, AV_VIEW, pname, strlen(pname) + 1);
}

long
av_help(BASEPAGE *bp, long fn, short nargs, char *pathname, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	short ap[4];
	char *stg, path[1024];
	long r, len = strlen(pathname) + 1;

	if (!nargs) return -EINVAL;
	if (nargs >= 2) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;

	_appl_getinfo(proc, 65, ap);
	if (ap[3])
	{
		if (_shel_help(proc, 0, pathname, 0L))
			return 0;
	}

	if (!_va_send(proc, VA_START, pathname, len))
		return 0;

	r = _appl_find(proc, "ST-GUIDE");
	if (r >= 0)
	{
		strcpy(path, "*:\\");
		strcat(path, pathname);
		if (!_send(proc, VA_START, (short)r, path, len))
			return 0;
	}

	stg = getenv(bp, "STGUIDE=");
	if (stg)
	{
		strcpy(path + 1, pathname);
		r = strlen(pathname);
		if (r > 0x7e)
			r = 0x7e;
		path[0] = (char)r;
		if (_shel_write(proc, SWM_LAUNCH, 0, 1, stg, path))
			return 0;
	}

	_alert(proc, 1, "[1][There is no help system.][ Cancel ]");

	return -ESRCH;
}

const char *services[] =
{
  "ftp:", "http:", "file:", "mail:",
  "telnet:", "news:", "nntp:", "gopher:", 0
};

const char *clients[] =
{
  "GEMFTP=", "GEMWWW=", "GEMWWW=",
  "GEMMAIL=", "GEMTELNET=", "GEMNEWS=",
  "GEMNEWS=", "GEMGOPHER="
};

const char *alt_clients[] =
{
  "FTP_CLIENT=", "BROWSER=", "BROWSER=",
  "MAIL_CLIENT=", "TELNET=", "NEWS_CLIENT=",
  "NEWS_CLIENT=", "GOPHER="
};

long
open_url(BASEPAGE *bp, long fn, short nargs, char *url, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	short astrid, x;
	long len;
	char *cli = 0, cmd[128];

	if (!nargs) return -EINVAL;
	if (nargs >= 2) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;

	/* Attempts to communicate with Stringserver */

	astrid = get_server(proc, "STRINGSERVER=");
	if (astrid < 0)
		astrid = _appl_find(proc, "STRNGSRV");
	if (astrid >= 0)
	{
		len = strlen(url) + 1;
		if (!_send(proc, VA_START, astrid, url, len))
			return 0;
	}

	/* If no Stringserver, do the stuff manually */
	for (x = 0; x < 32767; x++)
	{
		if (!services[x])
			return -EPROTONOSUPPORT;
		len = strlen(services[x]);
		if (!strncmp(url, services[x], len))
		{
			cli = (char *)clients[x];
			break;
		}
	}
	cli = getenv(proc->base, cli);
	if (!cli)
	{
		cli = (char *)alt_clients[x];
		cli = getenv(proc->base, cli);
		if (!cli)
			return -ESRCH;
	}
	strncpy(cmd + 1, url, 127);
	len = strlen(url);
	if (len > 0x7e)
		len = 0x7e;
	cmd[0] = (char)len;
	if (_shel_write(proc, SWM_LAUNCH, 0, 1, cli, cmd))
		return 0;

	return -ENOENT;
}

/* EOF */
