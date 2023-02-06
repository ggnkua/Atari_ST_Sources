/*	BitRip Copyleft !(c) 2019, Michael S. Walker <sigmatau@heapsmash.com>
 *	All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#pragma clang diagnostic push
#pragma ide diagnostic ignored "hicpp-signed-bitwise"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include <fcntl.h>
#include <stdarg.h>
#include <unistd.h>
#include "syscalls.h"


int Open(const char *file_name, mode_t arg_flags, ...)
{
	va_list ap;
	mode_t mode = 0;
	int fd;

#ifdef __OPEN_NEEDS_MODE
	if ((__OPEN_NEEDS_MODE(arg_flags)) != 0) {
#else
	if ((arg_flags & O_CREAT) != 0) {
#endif //__OPEN_NEEDS_MODE
		va_start(ap, arg_flags);
		mode = va_arg(ap, mode_t);
		va_end(ap);
	}

	fd = (int) SYSCALL(SYS_open, file_name, arg_flags, mode);
	if (fd < 0) {
		PRINT_ERRNO("open error")
	}

	return fd;
}


ssize_t IoRead(int fd, void *usrbuf, size_t n)
{
	size_t nleft = n;
	ssize_t nread;
	char *bufp = usrbuf;

	while (nleft > 0) {
		if ((nread = Read(fd, bufp, nleft)) < 0) {
			if (nread == -1) /* Interrupted by sig handler return and call Read() again */
				nread = 0;
		} else if (nread == 0)
			break;
		nleft -= nread;
		bufp += nread;
	}
	return (n - nleft);
}


ssize_t Read(int fd, void *buf, size_t count)
{
	ssize_t n_read = SYSCALL(SYS_read, fd, buf, count);

	if (n_read >= 0)
		return n_read;

	if (errno == EINTR) /* Interrupted by sig handler return */
		return -1;

	PRINT_ERRNO("Read error") /* errno set by Read() */
}


off_t Lseek(int fd, off_t offset, int whence)
{
	off_t result_offset = SYSCALL(SYS_lseek, fd, offset, whence);
	if (offset < 0) {
		PRINT_ERRNO("lseek error")
	}

	return result_offset;
}


void Close(int fd)
{
	if ((int) SYSCALL(SYS_close, fd) < 0) {
		PRINT_ERRNO("close error")
	}
}


void Print(int file_handle, const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vdprintf(file_handle, fmt, ap);
	va_end(ap);
}

long SetErrno(int err)
{
	errno = err;
	return -1;
}

#pragma clang diagnostic pop
