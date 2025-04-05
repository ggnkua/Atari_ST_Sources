#include <stdio.h>
#include <math.h>
#include <ctype.h>

/* translation table for control chars */

char c_ctrl[] = {
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9,
		10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
		23, 25, 26, 27, 28, 29, 30, 31, 0,  1,  2,  3,  4,  5,
		6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
		20, 21, 22, 23, 24, 25, 26, 0,  0,  0,  0,  0
		};

/*
 * getval - evaluate optional numeric argument
 *
 * increments i
 */
int
getval(buf,i,argtyp)
char buf[];
int *i;
int *argtyp;
{
	int j,k;

	j = *i;
	k = *argtyp;

	skipbl(buf, &j);
	k = buf[j];
	if (k == '+' || k == '-')
		j++;
	*i = j;
	*argtyp = k;
	return(ctoi(buf,i));
}

/*
 * getarg - get the next argument from the buffer
 *
 * return values:      -1 - no argument
 *			n - number of chars in argument
 *
 * also handles quoted ("..") strings. If a quote is wanted
 * in the string, use "" or \". quotes are stripped.
 *
 * argument delimiters: blank, tab or comma (,).
 *
 * increments i
 *
 */
int
getarg(buf,i,arg)
char buf[];
int *i;
char arg[];
{
	int j,k;
	register char ch;

	j = *i;

	k = -1;
	skipbl(buf,&j);
	if (buf[j] != '\0') {
		k = 0;
		if (buf[j] == '\"') {
			j++;
			while (buf[j] != '\0') {
				if (buf[j] == '\"') {
					if (buf[j+1] == '\"') {
						arg[k++] = '\"';
						j += 2;
					}
					else
						break;
				}
				arg[k++] = buf[j++];
			}
			arg[k] = '\0';
			j++;			/* skip the quote */
			/* peek next char */
			if (isalnum(buf[j]))
				error("improper argument list.");
			j++;			/* skip the delimeter */
		}
		else {
			ch = buf[j];
			while (ch != ' '&&
			    ch != '\t' 	&&
			    ch != ',' 	&&
			    ch != '\r' 	&&
			    ch != '\n' 	&&
			    ch != '\0') {
				arg[k++] = buf[j++];
				ch = buf[j];
			}
			arg[k] = '\0';
			if (ch != '\0')	/* if non-null delimiter, skip */
				j++;
		}
		*i = j;
	}
	return(k);
}

/*
 * getpstr - get a special string to print out
 *
 */
getpstr(buf,out)
register char *buf;
register char *out;
{
	register int i;
	register char c, cc;
	register char *num;
	char numbuf[9];

	while(*buf != '\n' && *buf != '\0') {
		c = *buf;
		switch(c) {
		case ' ':
		case '\t':
			while (*buf == ' ' || *buf == '\t')
				buf++;	/* skip blanks */
			break;
		case '\\':
			if (*(buf+1) != '\0') {
				*out++ = *(buf+1);
				buf += 2;
			}
			else
				buf++;
			break;
		case '^':
			if ((cc = c_ctrl[*(buf+1)]) != 0)
				*out++ = cc;
			buf += 2;
			break;
		case '\"':
			buf++;	/* skip the quote */
			while (*buf != '\0') {
				if (*buf != '\"')
					*out++ = *buf++;
				else if (*(buf+1) == '\"') {
						*out++ = '\"';
						buf += 2;
				}
				else
					break;
			}
			buf++;	/* skip the quote */
			break;
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			num = numbuf;
			while (isdigit(*buf))
				*num++ = *buf++;
			*num = '\0';
			if ((i = atoi(numbuf)) > 256)
				error("non-ascii char value in write string.");
			else if (i > 0)		/* do not output null */
				*out++ = (char) i;
			break;
		default:
			*out++ = *buf++;
		}
	}
	*out = '\0';
}
