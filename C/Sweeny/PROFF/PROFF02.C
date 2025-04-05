#include <stdio.h>
#include <ctype.h>
#include "defs.h"
#include "debug.h"

/*
 * addset - put c in array[i], if it fits, increment i
 *
 */
int
addset(c,array,i,maxsize)
char c;
char array[];
int *i;
int maxsize;
{
	int n,status = NO;
	dprintf("addset  ");
	n = *i;
	if (n <= maxsize - 1) {
		array[n++] = c;
		status = YES;
	}
	*i = n;
	return(status);
}

/*
 * addstr - add string s to str[i] if it fits, increment i
 *
 */
int
addstr(s,str,i,maxsize)
char s[];
char str[];
int *i;
int maxsize;
{
	int k,j,status = NO;

	dprintf("addstr  ");
	j = *i;
	if (j + strlen(s) <= maxsize - 1) {
		for (k = 0; s[k] != EOS; k++)
			str[j++] = s[k];
		status = YES;
	}
	*i = j;
	return(status);
}

/*
 * ctoi - convert string at in[i] to integer, increment i
 *
 */
int
ctoi(in,i)
char in[];
int *i;
{
	int j,n,sign;

	dprintf("ctoi  ");
	n = 0;
	for (j = *i; in[j] == ' ' || in[j] == '\t'; j++)
		;         /* skip leading garbage */
	sign = 1;
	if (in[j] == '+' || in[j] == '-') /* sign */
		sign = (in[j++] == '+') ? 1 : -1;
	for (n = 0; in[j] >= '0' && in[j] <= '9'; j++)
		n = 10 * n + in[j] - '0';
	*i = j;
	return(sign * n);
}

/*
 * error - print message and terminate
 *
 */
error(s)
char s[];
{
	fprintf(stderr,"%s\n",s);
	exit(1);
}

/*
 * getwrd - get non-blank word from in[i] into out, increment i
 *
 */
int
getwrd(in,i,out)
char in[];
int *i;
char out[];
{
	int j,size = 0;

	for (j = *i; in[j] == '\t' || in[j] == ' '; j++)
		;         /* skip leading garbage */
	while (in[j] != ' ' && in[j] != '\t' &&
	    in[j] != EOS && in[j] != '\n')
		out[size++] = in[j++];
	out[size++] = EOS;
	*i = j;
#ifdef DEBUG
	printf("getwrd: %s\n",out);
#endif
	return(size);
}
/*
 * skipbl - skip blanks, tabs at str[i], increment i
 *
 */
skipbl(str,i)
char str[];
int *i;
{
	int n;
	dprintf("skipbl  ");
	n = *i;
	while (str[n] == ' ' || str[n] == '\t')
		n++;
	*i = n;
}

/*
 * itoc - special version of itoa
 *
 */
int
itoc(n,str,size)
int n;
char str[];
int size;
{

	int i,j,k,sign;
	char c;

	dprintf("itoc  ");
	if ((sign = n) < 0)
		n = -n;
	i = 0;
	do {
		str[i++] = n % 10 + '0';
	}
	while ((n /= 10) > 0 && i < size-2);
	if (sign < 0 && i < size-1)
		str[i++] = '-';
	str[i] = EOS;
	/*
		 * reverse the string and plug it back in
		 *
 */
	for (j = 0, k = strlen(str) - 1; j < k; j++, k--) {
		c = str[j];
		str[j] = str[k];
		str[k] = c;
	}
	return(i);
}

/*
 * usage - obvious..
 *
 */
usage()
{
#ifdef rainbow
	fprintf(stderr,"%s %s",
	"usage: proff \033[7m[+n] [-n] [-v] [-ifile] [-s] [-pon]\033[0m",
	"\033[1minfile\033[0m \033[7m[outfile]\033[0m\n");
#else
	fprintf(stderr,
	"usage: proff [+n] [-n] [-v] [-ifile] [-s] [-pon] infile [outfile]\n");
#endif
	exit(0);
}
