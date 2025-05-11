
/* fopen */

#include <file.h>
#include <errno.h>
#include "std-guts.h"

struct file * fopen (name, mode)
char * name;
char * mode;
{
  int handle;
  struct file * f;
  int open_flags;

  open_flags = _parse_open_options(mode);
  handle = open (name, open_flags, 0);		/* try to open it */
  if (handle <= 0)
	{
	errno = handle;
	return(NULL);				/* couldn't open */
	}
    else
	{
	f = (struct file * )malloc(sizeof (struct file));
	f->handle = handle;
	f->open_p = 1;
	f->eof_p = 0;
	f->last_file_error = 0;
	f->mode = open_flags;
	f->buf_index = 0;		/* so far... */
	f->buf_max = 0;			/* nothing in buf yet */
	f->file_position = 0;		/* nothing read yet */
/* zzz should really check for file length here, for cases when we're
   appending... */
	return(f);
	}

}

int _parse_open_options(options)
char * options;
{
  int open_flags;
/* this isn't quite right... */
  switch (*options)
	{
	case 'w': 
		{
		if (options[1] != '+')		/* normal output open */
			open_flags = O_WRONLY | O_CREAT | O_TRUNC;
		    else
			open_flags = O_RDWR | O_CREAT;
		break;
		}
	case 'r':
		{
		if (options[1] != '+')
			open_flags = O_RDONLY;
		    else
			open_flags = O_RDWR;
		break;
		}
	case 'a': { open_flags = O_WRONLY | O_APPEND | O_CREAT; break; }
	case '+': { open_flags = O_RDWR; break; }
	}
  return(open_flags);
}
