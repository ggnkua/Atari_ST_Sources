#include <stdio.h>
#include <osbind.h>

int isatty(handle)
	register int handle;
	{
	register long status;

	if((status = Fseek(1L, handle, 1)) > 0)
		{
		Fseek(-1L, handle, 1);
		return(FALSE);
		}
	return(status == 0);
	}
