
/* console IO stuff.  Abstracted out here cause I'm having so much trouble
   getting Bconout and Cconout to work */

#include <osbind.h>

long console_read_byte(handle)
int handle;
{
  return(Bconin(2) & 0xFF);
}

console_write_byte(handle, c)
int handle;
char c;
{
  Fwrite(handle, 1, &c);
}
