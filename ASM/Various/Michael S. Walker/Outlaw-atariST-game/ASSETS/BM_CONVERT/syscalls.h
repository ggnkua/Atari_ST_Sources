/*	BitRip Copyleft !(c) 2019, Michael S. Walker <sigmatau@heapsmash.com>
 *	All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef BMP_RIP_SYSCALLS_H
#define BMP_RIP_SYSCALLS_H

#include <sys/types.h> /* for mode_t, size_t and ssize_t */

#define PRINT_ERR(format, ...) fprintf(stderr, "-> error in %s() line %d\n"format"\n", __func__, __LINE__, ##__VA_ARGS__);
#define PRINT_ERRNO(format, ...) fprintf(stderr, "-> error in %s() line %d\n"format": %s\n", __func__, __LINE__, ##__VA_ARGS__, strerror(errno));

#define PRINT_ERRNO_AND_RETURN(format, ...) PRINT_ERRNO(format, ##__VA_ARGS__) \
        return(EXIT_FAILURE);
#define PRINT_ERRNO_AND_EXIT(format, ...) PRINT_ERRNO(format, ##__VA_ARGS__) \
        exit(EXIT_FAILURE);
#define PRINT_ERR_AND_RETURN(format, ...) PRINT_ERR(format, ##__VA_ARGS__) \
        return(EXIT_FAILURE);
#define PRINT_ERR_AND_EXIT(format, ...) PRINT_ERR(format, ##__VA_ARGS__) \
        exit(EXIT_FAILURE);

#if defined(__linux__) && defined(__x86_64__)
	#define SYSCALL(n, ...) X86SysCall(n, ##__VA_ARGS__)
#else
	#define SYSCALL(n, ...) syscall(n, ##__VA_ARGS__)
#endif //defined(__linux__) && defined(__x86_64__)

int Open(const char *file_name, mode_t arg_flags, ...);
void Print(int file_handle, const char *fmt, ...);
ssize_t IoRead(int fd, void *usrbuf, size_t n);
ssize_t Read(int fd, void *buf, size_t count);
off_t Lseek(int fd, off_t offset, int whence);
long X86SysCall(long number, ...);
long SetErrno(int err);
void Close(int fd);

#endif //BMP_RIP_SYSCALLS_H
