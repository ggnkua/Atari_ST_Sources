/*********************************************************************

					IOS - string manipulate routines
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	Manipulate strings or check on space.
***********************************************************************/

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>
#include	<ext.h>
#include	<time.h>

#include	"portab.h"
#include	"defs.h"
#include	"ioslib.h"
#include	"lang.h"
#include	"vars.h"

BYTE *skip_after_blanks(BYTE *string)
{
	BYTE	*q = &string[strlen(string)-1];
	
	while (isspace(*q)) q--;
	
	*++q = EOS;
	
	return(string);
}

BYTE *skip_blanks(BYTE *string)
{
	while (*string && isspace(*string)) string++;
	return(string);
}

BYTE *skip_to_blank(BYTE *string)
{
	while (*string && !isspace(*string)) string++;
	return(string);
}

BYTE *skip_to_token(BYTE *string, BYTE token)
{
	while (*string && *string != token) string++;
	
	if (*string) return(++string);
	return(string);
}

BYTE *ctl_string(BYTE *string)
{
	BYTE	*p = skip_blanks(string),
			*d = (BYTE *) malloc(strlen(p)+1);
	
	if (d == NULL)
	{
		log_line(6,Logmessage[M__MEMORY_ERROR]);
#if defined DEBUG
		log_line(6,"?String allocation failed.");
#endif
		return("");
	}
	
	p = skip_after_blanks(p);
	strcpy(d, p);
	
	return(d);
}

BYTE *ctl_path(BYTE *string)
{
	BYTE	*p = skip_blanks(string),
			*d = skip_to_blank(string),
			db[80];
	
	*d = EOS;
	
	if (strlen(p) > 78)
	{
		log_line(6,Logmessage[M__DIR_TO_BIG], p);
		return("");
	}
	
	strcpy(db, p);
	if (db[strlen(db)-1] != '\\') strcat(db, "\\");
	
	return(ctl_string(db));
}

BYTE *ctl_file(BYTE *str)
{
	BYTE	*q;
	
	str = skip_blanks(str);
	for (q = str; *q && !isspace(*q); q++);
	*q = EOS;
	
	return(ctl_string(str));
}
