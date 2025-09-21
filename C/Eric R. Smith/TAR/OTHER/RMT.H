/*

	Copyright (C) 1988 Free Software Foundation

GNU tar is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY.  No author or distributor accepts responsibility to anyone
for the consequences of using it or for whether it serves any
particular purpose or works at all, unless he says so in writing.
Refer to the GNU tar General Public License for full details.

Everyone is granted permission to copy, modify and redistribute GNU tar,
but only under the conditions described in the GNU tar General Public
License.  A copy of this license is supposed to have been given to you
along with GNU tar so you can know your rights and responsibilities.  It
should be in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.

In other words, go ahead and share GNU tar, but don't try to stop
anyone else from sharing it farther.  Help stamp out software hoarding!
*/

#ifdef NO_REMOTE
#define rmtopen		open
#define rmtaccess	access
#define rmtstat		stat
#define rmtcreat	creat
#define rmtlstat	lstat
#define rmtread		read
#define rmtwrite	write
#define rmtlseek	lseek
#define rmtclose	close
#define rmtioctl	ioctl
#define rmtdup		dup
#define rmtfstat	fstat
#define rmtfcntl	fcntl
#define rmtisatty	isatty

#else
#ifndef USG
#define strchr index
#endif

#define __REM_BIAS	128
#define RMTIOCTL

#ifndef O_CREAT
#define O_CREAT	01000
#endif
extern char *__rmt_path;
extern char *strchr();

#define _remdev(path)	((__rmt_path=strchr(path, ':')) && strncmp(__rmt_path, ":/dev/", 6)==0)
#define _isrmt(fd)		((fd) >= __REM_BIAS)

#define rmtopen(path,oflag,mode) (_remdev(path) ? __rmt_open(path, oflag, mode, __REM_BIAS) : open(path, oflag, mode))
#define rmtaccess(path, amode)	(_remdev(path) ? 0 : access(path, amode))
#define rmtstat(path, buf)	(_remdev(path) ? (errno = EOPNOTSUPP), -1 : stat(path, buf))
#define rmtcreat(path, mode)	(_remdev(path) ? __rmt_open (path, 1 | O_CREAT, mode, __REM_BIAS) : creat(path, mode))
#define rmtlstat(path,buf)	(_remdev(path) ? (errno = EOPNOTSUPP), -1 : lstat(path,buf))

#define rmtread(fd, buf, n)	(_isrmt(fd) ? __rmt_read(fd - __REM_BIAS, buf, n) : read(fd, buf, n))
#define rmtwrite(fd, buf, n)	(_isrmt(fd) ? __rmt_write(fd - __REM_BIAS, buf, n) : write(fd, buf, n))
#define rmtlseek(fd, off, wh)	(_isrmt(fd) ? __rmt_lseek(fd - __REM_BIAS, off, wh) : lseek(fd, off, wh))
#define rmtclose(fd)		(_isrmt(fd) ? __rmt_close(fd - __REM_BIAS) : close(fd))
#ifdef RMTIOCTL
#define rmtioctl(fd,req,arg)	(_isrmt(fd) ? __rmt_ioctl(fd - __REM_BIAS, req, arg) : ioctl(fd, req, arg))
#else
#define rmtioctl(fd,req,arg)	(_isrmt(fd) ? (errno = EOPNOTSUPP), -1 : ioctl(fd, req, arg))
#endif
#define rmtdup(fd)		(_isrmt(fd) ? (errno = EOPNOTSUPP), -1 : dup(fd))
#define rmtfstat(fd, buf)	(_isrmt(fd) ? (errno = EOPNOTSUPP), -1 : fstat(fd, buf))
#define rmtfcntl(fd,cmd,arg)	(_isrmt(fd) ? (errno = EOPNOTSUPP), -1 : fcntl (fd, cmd, arg))
#define rmtisatty(fd)		(_isrmt(fd) ? 0 : isatty(fd))

#undef RMTIOCTL
#endif
