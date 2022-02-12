/* perror(s) print the current error message. */

#include <lib.h>
#include <string.h>
#include <unistd.h>

char *sys_errlist[] = {
	"Error 0",
	"Not owner",
	"No such file or directory",
	"No such process",
	"Interrupted system call",
	"I/O error",
	"No such device or address",
	"Arg list too long",
	"Exec format error",
	"Bad file number",
	"No children",
	"No more processes",
	"Not enough core",
	"Permission denied",
	"Bad address",
	"Block device required",
	"Mount device busy",
	"File exists",
	"Cross-device link",
	"No such device",
	"Not a directory",
	"Is a directory",
	"Invalid argument",
	"File table overflow",
	"Too many open files",
	"Not a typewriter",
	"Text file busy",
	"File too large",
	"No space left on device",
	"Illegal seek",
	"Read-only file system",
	"Too many links",
	"Broken pipe",
	"Math argument",
	"Result too large",
	"Resource deadlock avoided",
	"Filename too long",
	"No locks available",
	"Function not implemented",
	"Directory not empty"
};

int sys_nerr = sizeof(sys_errlist) / sizeof(char *);

void perror(s)
_CONST char *s;
{
  if (errno < 0 || errno >= sizeof(sys_errlist) / sizeof(char *)) {
	write(2, "Invalid errno\n", 14);
  } else {
	write(2, (char *) s, strlen(s));
	write(2, ": ", 2);
	write(2, sys_errlist[errno], strlen(sys_errlist[errno]));
	write(2, "\n", 1);
  }
}
