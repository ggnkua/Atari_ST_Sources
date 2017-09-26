/* Library utilities to avoid typecasts into bytestream */
#include <netdb.h>	/* Containes unsigned defs */

int	get_int(uchar *c)
{
	int i;
	
	i=*c++; i<<=8; i+=*c;
	return(i);
}

uint get_uint(uchar *c)
{
	uint i;
	
	i=*c++; i<<=8; i+=*c;
	return(i);
}

ulong get_ulong(uchar *c)
{
	ulong l;
	
	l=*c++; l<<=8;
	l=*c++; l<<=8;
	l=*c++; l<<=8;
	l=*c;
	return(l);
}

void set_int(char *p, int i)
{
	*p++=(char)(i>>8);
	*p++=(char)(i & 255);
}

void uset_int(uchar *p, int i)
{
	*p++=(char)(i>>8);
	*p++=(char)(i & 255);
}
