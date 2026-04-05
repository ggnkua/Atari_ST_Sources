#include <stdlib.h>
#include <sys/types.h>

int isatty (int handle);
ssize_t read (int __fd, void *__buf, size_t __nbytes);
ssize_t write (int __fd, __const void *__buf, size_t __n);
int open(const char *filename, int access, ...);
int close(int fd);
int unlink(const char *filename);
off_t lseek(int fd, off_t offset, int whence);
void _exit (int __status) __attribute__ ((__noreturn__));
int chdir(const char *filename);
