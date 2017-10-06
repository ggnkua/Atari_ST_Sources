/* Environment functions
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

# include <string.h>
# include <errno.h>

# include "gemma.h"

long
env_getargc(BASEPAGE *bp, long fn, short nargs, PROC_ARRAY *p)
{
	char *argv;
	long r = 0;

	UNUSED(p);

	argv = getenv(bp, "ARGV=");

	if (argv)
	{
		for(;;)
		{
			while(*argv++);
			if (*argv)
				r++;
			else
				break;
		}
	}

	return r;
}

long
env_getargv(BASEPAGE *bp, long fn, short nargs, long count, PROC_ARRAY *p)
{
	long max, r = 0;
	char *argv;

	UNUSED(p);

	if (!nargs) return -EINVAL;

	max = env_getargc(bp, fn, 0, 0);
	if (!max)
		return 0;
	if (count >= max)
		return 0;

	argv = getenv(bp, "ARGV=");

	if (argv)
	{
		for(;;)
		{
			while(*argv++);
			if (r == count)
				return (long)argv;
			if (*argv)
				r++;
		}
		
	}

	return 0;
}


long
env_get(BASEPAGE *bp, long fn, ushort nargs, char *var, PROC_ARRAY *p)
{
	UNUSED(p); UNUSED(fn);

	if (nargs)
		return (long)getenv(bp, var);
	else
		return -EINVAL;
}

long
env_eval(BASEPAGE *bp, long fn, short nargs, \
		char *var, char *outbuf, long maxlen, PROC_ARRAY *p)
{
	PROC_ARRAY *proc;
	char e, *env, *out = outbuf;

	if (nargs < 2) return -EINVAL;
	if (nargs >= 3) proc = p;
	else if ((nargs < 3) || !proc) proc = get_contrl(bp);

	if (maxlen <= 0)
		return -ERANGE;
	if (proc->env_refs > 63)
		return -E2BIG;

	env = getenv(bp, var);
	if (!env)
		return 0;

	proc->env_refs++;		/* counter for recursions */

	do {
		char tmp[64], *ti;
		short x;

		e = *env++;
		if ((e == '$') && *env && (*env != '$'))
		{
			strncpy(tmp, env, sizeof(tmp));
			for (x = 0; x < (sizeof(tmp)-1); x++)
			{
				if ((tmp[x] >= '0') || (tmp[x] <= '9') || \
						tmp[x] == '_')
					continue;
				if ((tmp[x] < '@') || (tmp[x] >= 'Z'))
				{
					tmp[x] = '=';
					tmp[x+1] = 0;
					break;
				}
			}
			ti = (char *)env_eval(bp, fn, 4, tmp, outbuf, maxlen, proc);
			if ((long)ti > 0)
			{
				long len = strlen(ti);

				maxlen -= len;
				outbuf += len;
			}
			else
			{
				proc->env_refs--;
				return (long)ti;
			}
		}
		else
		{
			*outbuf++ = e;
			maxlen--;
		}
	} while(e && (maxlen > 0));

	proc->env_refs--;

	if (e)
		return -ERANGE;

	return (long)out;
}

/* EOF */
