#include		"cookie.h"
/*
** Function to return what the value is of the passed cookie entry
*/
long	in_cookie(long value)
{
	long	*cookiejar=__jar;

	if	(cookiejar){
		while	(*cookiejar && *cookiejar != value) cookiejar +=2;}
	
	return	(*cookiejar==value?cookiejar[1]:0);
}	
	   
