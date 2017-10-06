/* Prototypes for dosproto.c
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

# define sema_create(s) _semaphore(0, s, 0L)
# define sema_destroy(s) _semaphore(1, s, 0L)
# define sema_request(s) _semaphore(2, s, -1L)
# define sema_release(s) _semaphore(3, s, 0L)

long _getexc(long vec);
short _getrez(void);

short _open(const char *name, short mode);
long _read(short file, long len, void *buf);
long _write(short file, long len, void *buf);
void _close(short file);
long _cntl(short file, void *arg, short cmd);
long _stat(short flag, const char *name, void *out);

long _wait3(short flag, long *rus);

long _sgetpid(void);
long _sgetppid(void);
long _semaphore(short mode, long sema, long time);
long _signal(short sig, void *hnd);

void _conws(char *str);
short _dup(short file);
void _force(short f1, short f2);

long _alloc(long size);
long _rdalloc(long size);
void _shrink(void *base, long newsize);
void _free(long adr);

void _domain(short d);
void _yield(void);

long _getdrv(void);
void _setdrv(short drv);
long _dfree(long *m, short d);
long _getpath(void *p, short drv);
long _setpath(const char *p);
long _getcwd(void *p, short drv, short len);

long _exec(short mode, void *cmd, void *tail, void *env);

long _size(const char *name);

/* EOF */
