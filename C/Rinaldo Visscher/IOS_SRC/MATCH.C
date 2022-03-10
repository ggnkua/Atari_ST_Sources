/*********************************************************************

					IOS - pattern matcher
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	Check pattern on 2 string and compare them on byte for byte.
**********************************************************************/


#include	<stdio.h>
#include	<string.h>
#include	"portab.h"
#include	"defs.h"
#include	"ioslib.h"


MLOCAL WORD addrmatch(BYTE *first, BYTE *second)
{
	if (!*second) return(!*first);
	
	if (*second == '.')
	{
		while (*first && *first != '.') first++;
		
		if (*first)
			return(addrmatch(++first, ++second));
		else
			return(FALSE);
	}
	
	if (*second == '*')
	{
		if (!*++second) return(TRUE);
		
		do
		{
			if ((*first == *second || *second == '?') &&
				addrmatch(first+1, second+1))
				return(TRUE);
		} while (*first++);
	}
	else
		if (*first && (*second == '?' || *second == *first))
			return(addrmatch(++first, ++second));
	
	return(FALSE);
}

BOOLEAN newmatch(BYTE *str, BYTE *pattern)
{
	BYTE		c,
				*cp;
	BOOLEAN		done = FALSE,
				ret_code,
				ok;
	
	while (*pattern != EOS && !done && ((*str == EOS &&
			(*pattern == '{' || *pattern == '*')) || *str != EOS))
	{
		switch (*pattern)
		{
			case '\\':
				
				pattern++;
				if (*pattern) pattern++;
				break;
				
			case '*':
				
				pattern++;
				ret_code = FALSE;
				while (*str && (ret_code = newmatch(str++, pattern)) == FALSE);
				if (ret_code)
				{
					while (*str) str++;
					while (*pattern) pattern++;
				}
				break;
				
			case '[':
				
				pattern++;
				
				repeat:
				
				if (*pattern == EOS || *pattern == ']')
				{
					done = TRUE;
					break;
				}
				
				if (*pattern == '\\')
				{
					pattern++;
					if (*pattern == EOS)
					{
						done = TRUE;
						break;
					}
				}
				
				if (*(pattern+1) == '-')
				{
					c = *pattern;
					pattern += 2;
					if (*pattern == ']')
					{
						done = TRUE;
						break;
					}
					if (*pattern == '\\')
					{
						pattern++;
						if (*pattern == EOS)
						{
							done = TRUE;
							break;
						}
					}
					if (*str < c || *str > *pattern)
					{
						pattern++;
						goto repeat;
					}
				}
				else if (*pattern != *str)
				{
					pattern++;
					goto repeat;
				}
				
				pattern++;
				
				while (*pattern && *pattern != ']')
				{
					if (*pattern == '\\' && *(pattern+1)) pattern++;
					pattern++;
				}
				
				if (*pattern)
				{
					pattern++;
					str++;
				}
				
				break;
				
			case '?':
				
				pattern++;
				str++;
				break;
				
			case '{':
				
				pattern++;
				
				while (*pattern != '{' && *pattern)
				{
					cp = str;
					ok = TRUE;
					
					while (ok && *cp && *pattern && *pattern != ',' && *pattern != '}')
					{
						if (*pattern == '\\') pattern++;
						ok = (*pattern == *cp);
						cp++;
						pattern++;
					}
					
					if (*pattern == EOS)
					{
						ok = FALSE;
						done = TRUE;
						break;
					}
					else if (ok)
					{
						str = cp;
						
						while (*pattern != '}' && *pattern)
						{
							pattern++;
							if (*pattern == '\\')
							{
								pattern++;
								if (*pattern == '}') pattern++;
							}
						}
					}
					else
					{
						while (*pattern != '}' && *pattern != ',' && *pattern)
						{
							pattern++;
							if (*pattern == '\\')
							{
								pattern++;
								if (*pattern == '}' || *pattern == ',') pattern++;
							}
						}
					}
					
					if (*pattern) pattern++;
				}
				
				break;
				
			default:
				
				if (*str == *pattern)
				{
					str++;
					pattern++;
				}
				else
					done = TRUE;
		}
	}
	
	while (*pattern == '*') pattern++;
	
	return(*str == EOS && *pattern == EOS);
}

WORD match(BYTE *first, BYTE *second)
{
	BYTE	f[128],
			s[128];
	
	strcpy(f, expand(first));
	strcpy(s, expand(second));
	
	return(newmatch(f, s));
}
