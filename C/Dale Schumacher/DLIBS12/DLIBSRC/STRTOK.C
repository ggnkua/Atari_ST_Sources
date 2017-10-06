#include <stddef.h>

static	char	*_strtok = NULL;	/* local token pointer */

char *strtok(string, delim)
	register char *string, *delim;
	{
	register char *p;
	char *strchr();

	if(string == NULL)
		string = _strtok;
	while(*string && strchr(delim, *string))
		++string;
	if(*string == '\0')		/* no more tokens */
		return(NULL);
	p = string;
	while(*string && !strchr(delim, *string))
		++string;
	if(*string != '\0')
		*string++ = '\0';
	_strtok = string;
	return(p);
	}
