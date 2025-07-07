#include <stdio.h>
/*
 * note: <ctype.h> is explicitly NOT #include'd so that the FUNCTION
 *	 version of toupper() will be loaded instead of the macro.
 *	 This is to prevent "side-effect" problems.
 */

extern	char	_numstr[];		/* string of hexadecimal digits */

char *ctlcnv(string)
	char *string;
	{
	register char *p, *q, c;
	register int i, n;

	p = q = string;
	while(*q)
		{
		if(*q == '\\')
			{
			switch(*++q)
				{
				case 'n':	/* newline or linefeed */
					*p++ = '\n';
					break;
				case 'r':	/* carriage return */
					*p++ = '\r';
					break;
				case 'b':	/* backspace */
					*p++ = '\b';
					break;
				case 't':	/* horizontal tab */
					*p++ = '\t';
					break;
				case 'v':	/* vertical tab */
					*p++ = '\013';
					break;
				case 'f':	/* form feed */
					*p++ = '\f';
					break;
				case 'a':	/* alarm (bell) */
					*p++ = '\007';
					break;
				case '0':	/* octal constant */
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
					c = (*q - '0');
					i = 0;
					n = 3;
					do
						{
						i = (i<<3) + c;
						c = (*++q - '0');
						}
						while((--n)
						   && (c >= 0) 
						   && (c < 8));
					*p++ = i;
					--q;
					break;
				case 'x':	/* hexadecimal constant */
					i = 0;
					n = 2;
					while((n--)
					   && ((c = strpos(_numstr,
					   		toupper(*++q))) >= 0))
						i = (i << 4) + c;
					*p++ = i;
					--q;
					break;
				case '\n':	/* "folded" line */
					break;
				default:
					*p++ = *q;
				}
			}
		else
			*p++ = *q;
		++q;
		}
	*p = '\0';
	return(string);
	}
