#include <stdio.h>
#include <sfcntl.h>
#include <atarierr.h>
#include <sockerr.h>

#include "network.h"
#include "socksys.h"

long cdecl sfcntl(int FileDescriptor, long Command, long Argument)
{
	sock_dscr	*sd;
	long			ret;
	
	while(!set_flag(SOCK_SEM));
	sd=find_sock(FileDescriptor);
	if(sd == NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}
	
	if(Command == F_GETFL)
	{
		ret=sd->file_status_flags;
		clear_flag(SOCK_SEM);
		return(ret);
	}
	
	if(Command == F_SETFL)
	{
		sd->file_status_flags=Argument;
		clear_flag(SOCK_SEM);
		return(E_OK);
	}

	clear_flag(SOCK_SEM);
	return(EINVAL);
}
