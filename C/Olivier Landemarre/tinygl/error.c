#include <stdarg.h>
#include "zgl.h"
__EXTERN void (*error_except)(long);
int gl_exception_error(long num_error) /* retourne 1 si l'exception est sinon 0 */
{
	if(error_except!=NULL)
	{
		error_except(num_error);
		return 1;
	}
	return 0;
}
void gl_fatal_error(char *format, ...)
{
  va_list ap;
  va_start(ap,format);
 /* fprintf(stderr,"TinyGL: fatal error: ");*/
  vfprintf(stderr,format,ap);
  fprintf(stderr,"\n");
  exit(1);
  va_end(ap);
}
