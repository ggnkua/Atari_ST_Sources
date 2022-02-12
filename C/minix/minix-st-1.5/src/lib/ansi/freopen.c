/* new freopen.c for minix/st
   hacked together: 11/11/88 by F. Meulenbroeks.
   Disclaimer: almost all of this code is extracted from fopen.c and
               fclose.c. Use at own risk.

  The problem with the original freopen was that it did not
  use the same FILE struct to store its values.
  This results in problems when using code like
  FILE *yyin = stdin; 
  which occurs in flex.

  Also freopen should return the original value of stream.
  This is not the case in the minix/st freopen.

  The original freopen does not neccesarily return the same entry in _io_table
  if another file is closed before. This causes problems when reopening
  stderr after closing stdin or stdout (I think).

  I decided the when doing an freopen, one uses the same buffer and
  buffering method. ANSI C does not explicitly specify this.
*/

#include <lib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

#define  PMODE    0666

FILE *freopen(name, mode,fp)
_CONST char *name , *mode;
FILE *fp;
{
	register int i;
	int fd, flags;

	for (i=0; i<NFILES; i++)
		if (fp == _io_table[i]) {
			break;
		}
	if (i >= NFILES)
		return((FILE *)EOF);
	flags = fp->_flags;
	flags = flags & !WRITEMODE & !READMODE;
	fflush(fp);
	close(fp->_fd);

	switch(*mode){

	case 'w':
		flags |= WRITEMODE;
		if (( fd = creat (name,PMODE)) < 0)
			return((FILE *)NULL);
		break;

	case 'a': 
		flags |= WRITEMODE;
		if (( fd = open(name,1)) < 0 )
			return((FILE *)NULL);
		lseek(fd,0L,2);
		break;         

	case 'r':
		flags |= READMODE;	
		if (( fd = open (name,0)) < 0 )
			return((FILE *)NULL);
		break;

	default:
		return((FILE *)NULL);
	}

	fp->_count = 0;
	fp->_fd = fd;
	fp->_flags = flags;
	fp->_ptr = fp->_buf;
	return(fp);
}
