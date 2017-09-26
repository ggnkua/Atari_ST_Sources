/* Lowlevel-Ausgabe auf den jeweils ge”ffneten Port */
#define iodebug

#include <stdio.h>
#include <tos.h>
#include <atarierr.h>
#include <sockerr.h>
#include "network.h"

extern	int	port_handle;

extern default_values defaults;

long	low_ready(void)
{
	if(port_handle < 0) return(ENETDOWN);
	
	return(E_OK);
}

long	low_read(long count, void *buf)
{
	long ret;
	if(port_handle < 0) return(ENETDOWN);
	
	ret=Fread(port_handle, count, buf);
	if(ret > 0) defaults.bytes_rcvd+=ret;
	return(ret);
}

long	low_write(long count, void *buf)
{
	long	ret;
	if(port_handle < 0) return(ENETDOWN);
	
	ret=Fwrite(port_handle, count, buf);
	if(ret > 0) defaults.bytes_sent+=ret;
	return(ret);
}