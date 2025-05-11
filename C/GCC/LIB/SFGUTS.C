
/* zzz fix these... */
/* scanf routines */

#include <stdio.h>

fscanf(f, fmt, args) FILE *f; char *fmt; int *args; {
	extern char *_sfcp;
	extern FILE *_sffp;
	_sffp = f;
	_sfcp = NULL;
	return _dosf(fmt, &args);
}

scanf(fmt, args) char *fmt; int *args; {
	extern char *_sfcp;
	extern FILE *_sffp;
	_sffp = stdin;
	_sfcp = NULL;
	return _dosf(fmt, &args);
}

sscanf(s, fmt, args) char *s; char *fmt; int *args; {
	extern char *_sfcp;
	extern FILE *_sffp;
	_sffp = NULL;
	_sfcp = s;
	return _dosf(fmt, &args);
}
		
_dosf(fmt, args) char *fmt; int **args; {
	int assigned, wid, lng, skip, *ip, f, c, m, base;
	long n, *lp;
	char *cp;
	assigned = 0;
	c = _sfget();
	while ((f = *fmt++) && c != EOF) {
		if (f <= ' ') { /* skip spaces */
			while (c <= ' ' && c != EOF)
				c = _sfget();
		}
		else if (f != '%') { /* match character */
			if (c != f) 
				return assigned;
		}
		else	{
			wid = lng = skip = 0;
			if ((f = *fmt++) == '*') { /* skip assignment */
				skip++;
				f = *fmt++;
			}
			while (f >= '0' && f <= '9') { /* width of value */
				wid = wid * 10 + f - '0';
				f = *fmt++;
			}
			if (f == 'l') { /* long */
				lng++;
				f = *fmt++;
			}
			else if (f == 'h') { /* short */
				f = *fmt++;
			}
			switch (f) { /* conversion spec */
			case '%':
				if (c != '%') return assigned;
				c = _sfget();
				break;
			case 'c':
				if (wid == 0) {
					cp = (char * )*args++;
					if (!skip) {
						*cp = c;
						assigned++;
					}
					c = _sfget();
					break;
				}
			case 's':
				cp = (char * )*args++;
				while (c <= ' ' && c != EOF)
					c = _sfget();
				while (c > ' ' && c != EOF) {
					if (!skip) *cp++ = c;
					c = _sfget();
					if (--wid == 0) break;
				}
				*cp = 0;
				if (!skip) assigned++;
				break;
			case 'D': case 'X': case 'O':
				lng = 1;
				f = f - 'A' + 'a';
			case 'd': case 'x': case 'o':
				base = (f == 'x' ? 16 : f == 'o' ? 8 : 10);
				n = 0L;
				while (c != EOF && c <= ' ')
					c = _sfget();
				if ((m = _sfnum(c, base)) < 0)
					return assigned;
				do	{
					n = n * base + m;
					c = _sfget();
					m = _sfnum(c, base);
					if (--wid == 0) break;
				} while (m >= 0);
				if (!skip) {
					if (lng) {
						lp = (long * )*args++;
						*lp = n;
					}
					else	{
						ip = *args++;
						*ip = n;
					}
					assigned++;
				}
				break;
			case 'e': case 'f': case 'E': case 'F':
				/* no floats implemented */
				return -2;
			default:
				return assigned;
			}
		}
	}
	return f == 0 ? assigned : EOF;
}


_sfnum(c, base) {
	if (c >= '0' && c <= '9')
		return c - '0';
	else if (base == 16 && c >= 'a' && c <= 'f')
		return c - 'a' + 10;
	else if (base == 16 && c >= 'A' && c <= 'F')
		return c - 'A' + 10;
	else 	return -1;
}

_sfget() {
	extern char *_sfcp;
	extern FILE *_sffp;
	if (_sffp) return getc(_sffp);
	if (_sfcp && *_sfcp) return *_sfcp++;
	return EOF;
}

char *_sfcp;	/* char pointer for scanf input string */
FILE *_sffp;	/* FILE pointer for scanf input stream */

