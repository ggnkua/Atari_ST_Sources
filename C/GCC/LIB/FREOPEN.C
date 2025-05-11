

/* freopen */

/* another kludge.  sigh */

#include <file.h>
#include "std-guts.h"

struct file * freopen(pathname, mode, f)
char * pathname;
char * mode;
struct file * f;
{
/* don't know quite how this should work.  For now, close the handle, if
   it's a real file, and then do an fopen equivalent on the file struct.
   From looking at code that uses this, it looks like it's supposed
   to return the file struct it was passed if it wins, NULL else.  What
   a crock!
*/

  int new_modes, new_handle;
  
  if (f->open_p && (((f->mode & 0x03) == O_WRONLY) || 
		    ((f->mode & 0x03) == O_RDWR)))
	fflush(f);

  if (!isatty(f->handle))
	close(f->handle);
  f->open_p = 0;

  new_modes = _parse_open_options(mode);
  new_handle = open(pathname, new_modes, 0);
  if (new_handle < 0)
	return(0);

/* ok the new file is there.  go ahead and do the rest of fopen */
  f->mode = new_modes;
  f->handle = new_handle;
  f->open_p = 1;
  f->last_file_error = 0;

/* more??? */
  return(f);
}
