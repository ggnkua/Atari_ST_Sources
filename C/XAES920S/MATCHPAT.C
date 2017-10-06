/* HR: isolated completely from the XaAES & dirs environment.
 *
 *	Pattern matching
 *	- If you want better filtering of files, put the code here...
 *	
 *	Valid patterns are:
 *		?      Any single char
 *		*      A string of any char
 *		!X     Any char except for X
 *		[abcd] One of (any one of a,b,c or d)
 *	Examples:
 *		*      All files in dir
 *		a*     All files begining with 'a'
 *		*.c*   All files with a extension starting with c
 *		*.o    All '.o' files
 *		*.!o   All files not ending in '.o' 
 *		!z*.?  All files not starting with 'z', and having a single character extension
 *		*.[co] All '.o' and '.c' files
 *		*.[ch]* All files with a extension starting with c or h
 */

#include "prelude.h"
#include "ctype.h"			/* We use the version without macros!! */

global
bool match_pattern(char *t, char *pat)
{
	bool valid = true;
	
	while(    valid
	      and (   ( *t and *pat)
	           or (!*t and *pat == '*')	/* HR: catch empty that should be OK */
	         )
	      )
	{
		switch(*pat)
		{
		case '?':			/* Any character */
			t++;
			pat++;
			break;
		case '*':			/* String of any character */
			pat++;
			while(*t and (toupper(*t) != toupper(*pat)))
				t++;
			break;
		case '!':			/* !X means any character but X */
			if (toupper(*t) != toupper(pat[1]))
			{
				t++;
				pat += 2;
			} else
				valid = false;
			break;
		case '[':			/* [<chars>] means any one of <chars> */
			while((*(++pat) != ']') and (toupper(*t) != toupper(*pat)));
			if (*pat == ']')
				valid = false;
			else
				while(*++pat != ']');
			pat++;
			t++;			/* HR: yeah, this one was missing */
			break;
		default:
			if (toupper(*t++) != toupper(*pat++))
				valid = false;
			break;
		}
	}
	
	return valid and toupper(*t) == toupper(*pat);
}
