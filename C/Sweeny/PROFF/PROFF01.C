#include <stdio.h>
#include <ctype.h>
#include "proff.h"
#include "debug.h"

#define brk brrk

/*
 * bold - bold face or overstrike a line
 *
 */
bold(buf,tbuf,size)
char buf[];
char tbuf[];
int  size;
{
	int  i,j;
	dprintf("bold  ");

	j = 0;
	for (i = 0; buf[i] != '\n' && j < size - 2; i++) {
		tbuf[j] = buf[i];
		j++;
		if (buf[i] != ' ' && buf[i] != '\t' &&
		    buf[i] != BACKSPACE ) {
			tbuf[j] = BACKSPACE;
			tbuf[j+1] = tbuf[j-1];
			j += 2;
		}
	}
	tbuf[j] = '\n';
	tbuf[j+1] = '\0';
	strcpy(buf,tbuf);
}

/*
 * brk - end current filled line
 *
 */
brk()
{
	dprintf("brk  ");
	if (outp > 0) {
		outbuf[outp] = '\n';
		outbuf[outp+1] = EOS;
		put(outbuf);
	}
	outp = 0;
	outw = 0;
	outwds = 0;
}

/*
 * center - center a line by setting tival
 *
 */
center(buf)
char buf[];
{
	int	i;

	dprintf("center  ");

	i = (rmval + tival - width(buf)) / 2;
	tival = (i > 0) ? i : 0;
}

/*
 * doroff - format text in file fp
 *
 */
doroff(fp)
FILE *fp;
{
	char inbuf[INSIZE];

	infile[0] = fp;
	for (level = 0; level > -1; level--) {

#ifdef DEBUG
printf("doroff: level %d FileP %ld\n",level, infile[level]);
#endif

		while (ngetln(inbuf, infile[level]) != EOF) {
			if (inbuf[0] == cchar)	/* a command */
				command(inbuf);
			else {
#ifdef rainbow
				if (biosb(2))
					exit(0);
#endif
				text(inbuf);
				p_txtlines++;
			}
		}
#ifdef DEBUG
printf("doroff: Got EOF level %d FileP %ld\n",level, infile[level]);
#endif

		if (level > 0 && infile[level] > 0) {
			fclose(infile[level]);
			if (verbose)
				fprintf(stderr,"       done.\n");
		}
	}
}

/*
 * gettl - copy title from buf to ttl
 *
 * modifies lim
 */
gettl(buf,ttl,lim)
char *buf;
char *ttl;
int lim[];
{
	while (!isspace(*buf))
		buf++;
	while (isspace(*buf))
		buf++;
	strcpy(ttl,buf);
	lim[0] = inval;
	lim[1] = rmval;
}

/*
 * getwrb - get a word INCLUDING the trailing blanks
 *
 */
int
getwrb(in,i,out)
char in[];
char out[];
int *i;
{
	int j,k;
	dprintf("getval  ");
	k = *i;
	j = 0;
	while (in[k] != EOS && in[k] != ' ' &&
	    in[k] != '\t' && in[k] != '\n') {
		out[j] = in[k];
		k++;
		j++;
	}
	while (in[k] == ' ') {
		out[j] = ' ';
		k++;
		j++;
	}
	*i = k;
	out[j] = EOS;
	return(j);
}


/*
 * gfield - get next tab or title field
 *
 */
int
gfield(buf, i, n, temp, delim)
char buf[];
int *i;
int n;
char temp[];
char delim;
{
	int j,k;

	dprintf("gfield  ");
	j = 0;
	k = *i;
	if (n > 0) {
		if (buf[k] == delim)
			k++;
		while (buf[k] != delim && buf[k] != EOS && buf[k] != '\n' &&
		    j <= n) {
			temp[j] = buf[k];
			j++;
			k++;
		}
	}
	temp[j] = EOS;
	while (buf[k] != delim && buf[k] != EOS && buf[k] != '\n')
		k++;
	*i = k;
	return(j);
}

/*
 * jcopy - scopy without copying EOS
 *
 */
jcopy(from, i, to, j)
char from[];
char to[];
int i;
int j;
{
	int k1, k2;
	dprintf("jcopy  ");

	k1 = i;
	k2 = j;
	while (from[k1] != EOS) {
		to[k2] = from[k1];
		k1++;
		k2++;
	}
}

/*
 * justfy - justifies string in its tab column
 * */
justfy(in, left, right, type, out)
char in[];
char out[];
int left;
int right;
int type;
{
	int j,k, n;

	dprintf("justfy  ");
	n = width(in);
	if (type == RIGHT)
		jcopy(in, 0, out, right-n);
	else if (type == CENTER) {
		k = (right+left-n) / 2;
		j = (k > left) ? k : left;
		jcopy(in, 0, out, j);
	}
	else
	    jcopy(in, 0, out, left);
}

/*
 * leadbl - delete leading blanks, set tival
 *
 */
leadbl(buf)
char buf[];
{
	int i, j;

	dprintf("leadbl  ");
	brk();
	for (i = 0; buf[i] == ' '; i++)     /* find 1st non-blank */
		;
	if (buf[i] != '\n')
		if (autopar) {
			put("\n");	/* blank line */
			tival = inval + autoprv;
		}
		else
			tival = inval + i;	    /* ??????????? */
	for (j = 0; buf[i] != EOS; j++) {   /* move line to left */
		buf[j] = buf[i];
		i++;
	}
	buf[j] = EOS;
}

/*
 * ngetln - get next line from f into line
 *
 */
int
ngetln(line, f)
char line[];
FILE *f;
{
	int c, i;

#ifdef DEBUG
	printf("ngetln+++: bp %d\n",bp);
#endif

	for (i = 0; (c = (bp >= 0) ? buf[bp--] : getc(f)) != EOF; ) {
		if (i < MAXLINE - 1) {
			line[i++] = (char) c;
#ifdef DEBUG
	printf("ngetln++: i %d c %c %d\n",i,c,c);
#endif
		}
		if (c == '\n' || c == '\r')
			break;
	}
	line[i] = EOS;
	if (i == 0 && c == EOF)
		i = EOF;
#ifdef DEBUG
	printf("ngetln: %s (%d, %d) (line)\n",line,strlen(line),i);
#endif
	return(i);
}

/*
 * pbstr - push string back onto input
 *
 */
pbstr(in)
char in[];
{

	int i;

	dprintf("pbstr  ");
	for (i = strlen(in) - 1; i >= 0; i--)
		putbak(in[i]);
}

/*
 * pfoot - put out page footer
 *
 */
pfoot()
{

	dprintf("pfoot  ");
	skipl(m3val);
	if (m4val > 0) {
		if (curpag % 2 == 1)
			puttl(efoot, eflim, curpag);
		else
			puttl(ofoot, oflim, curpag);
	}
	if (print == YES)		/* flush the page */
	{
		putchar(PAGEJECT);	/* ...		  */
		p_outpages++;
		if (stopx > 0)		/* -s, so flush ^L*/
			putchar('\n');
	}
}

/*
 * phead - put out page header
 *
 */
phead()
{
	dprintf("phead  ");

	curpag = newpag;
	if (curpag >= frstpg && curpag <= lastpg)
		print = YES;
	else
	    print = NO;
	if(stopx > 0 && print == YES)
		prmpt(&stopx);
	newpag++;
	if (m1val > 0) {
		skipl(m1val-1);
		if (curpag % 2 == 0)
			puttl(ehead, ehlim, curpag);
		else
			puttl(ohead, ohlim, curpag);
	}
	skipl(m2val);
	lineno = m1val + m2val + 1;
}

/*
 * prmpt - pause for paper insertion
 * prompt if i == 1; increment i
 *
 */
prmpt(i)
int *i;
{
	int junk,j;
	static char bellst[2] = { BEL, EOS};

	dprintf("prmpt  ");
	j = *i;
	if (j == 1)
#ifdef rainbow
		printf("%s\033[7minsert paper and type return\033[0m ",bellst);
#else
		printf("%sinsert paper and type return ",bellst);
#endif
	else
		printf(bellst);
	junk = getchar();
	*i = ++j;
}

/*
 * Put - put out line with proper spacing and indenting
 *
 */
put(buf)
char buf[];
{
	register int i;
	dprintf("put  ");
	if (lineno == 0 || lineno > bottom)
		phead();

	if ( print == YES ) {
		if (buf[0] == '\n') {	/* empty line.. */
			putchar('\n');
			p_outlines++;
		}
		else {
			for ( i = 1 ; i <= offset ; i++ ) /* page offset */
				putchar(' ');
			for ( i = 1 ; i <= tival ; i++ )  /* indenting   */
				putchar(' ');

			while (*buf != '\0') {
				putchar(*buf);
				buf++;
			}
			p_outlines++;
		}
	}

	tival = inval;
	skipl(((lsval-1 < bottom-lineno) ? lsval-1 : bottom-lineno));
	lineno += lsval;

	if (lineno > bottom)
		pfoot();

}

/*
 * putbak - push character back onto input
 *
 */
putbak(c)
char c;
{
	dprintf("putbak  ");

	bp++;
	if (bp > BUFSIZE)
		error("too many characters pushed back.\n");
	buf[bp] = c;
}


/*
 * puttl - put out title line with optional page number & date
 *
 */
puttl(buf, lim, pageno)
char buf[];
int lim[];
int pageno;
{
	char chars[9],cdate[27];
	char rmstr[MAXTOK];
	char delim;
	char *tp;
	int j;
	int nc, n, i, left, right, ncd;

	dprintf("puttl  ");
	if (print == NO)
		return;
	left = lim[0];	/* no more +1 here */
	right = lim[1]; /* no more +1 here */
	nc = itoc(pageno, chars, MAXCHARS);
	if (roman) {
		nc = cvtroman(chars,rmstr);
		strcpy(chars,rmstr);
	}
	getnow(cdate);
	ncd = strlen(cdate);
	i = 0;
	delim = buf[i];
	for (j = 0; j < right; j++)
		ttl[j] = ' ';
	n = 0;
	do {
		if (gfield(buf, &i, right-left, tbuf1, delim) > 0) {
			subst(tbuf1, PAGENUM, tbuf2, chars, nc);
			subst(tbuf2, CURRENTDATE, tbuf1, cdate, ncd);
			justfy(tbuf1, left, right, tjust[n], ttl);
		}
		n++;		/* update title counter */
	}
	while (buf[i] != EOS && buf[i] != '\n' && n != 3);

	for( ; right >= 1 ; right--)
		if( ttl[right-1] != ' ' )
			break;
	ttl[right] = '\n';
	ttl[right+1] = EOS;
	for (i = 1; i <= offset; i++)
		putchar(' ');  			/* offset */
	tp = ttl;
	while (*tp != '\0') {
		putchar(*tp);
		tp++;
	}
	p_outlines++;
}

/*
 * set - set parameter and check range
 *
 */
set(param, val, argtyp, defval, minval, maxval)
int *param;
int val;
int argtyp;
int defval;
int minval;
int maxval;
{
	int i;
	dprintf("set  ");
	i = *param;
	if (argtyp == '\n')      		/* defaulted */
		i = defval;
	else if (argtyp == '+')		      	/* relative +*/
		i += val;
	else if (argtyp == '-')   		/* relative -*/
		i -= val;
	else               			/* absolute  */
	i = val;
	i = (i < maxval) ? i : maxval; 		/* min 	     */
	i = (i > minval) ? i : minval; 		/* max 	     */
	*param = i;
}

/*
* skipl - output  n  blank lines
*
*/
skipl(n)
register int n;
{
	register int i;

	dprintf("skip  ");
	if (print == YES)
		for (i = 1; i <= n; i++) {
			putchar('\n');
			p_outlines++;
		}
}

/*
 * space - space  n  lines or to bottom of page
 *
 */
space(n)
int n;
{

	dprintf("space  ");
	brk();
	if (lineno > bottom)
		return;
	if (lineno == 0)
		phead();
	skipl(((n < bottom+1-lineno) ? n : bottom+1-lineno));
	lineno += n;
	if (lineno > bottom)
		pfoot();
}

/*
 * spread - spread words to justify right margin
 *
 */
spread(buf, outp, nextra, outwds)
char buf[];
int outp;
int nextra;
int outwds;
{
	int dir = 0;

	register int i, j;
	int nb, ne, nholes;

	dprintf("spread  ");
	if (nextra <= 0 || outwds <= 1)
		return;
	dir = 1 - dir;   /* reverse previous direction */
	ne = nextra;
	nholes = outwds - 1;
	if (tival != inval && nholes > 1)
		nholes--;
	i = outp - 1;
	j = (MAXOUT-2 < i+ne) ? MAXOUT-2 : i+ne; /* leave room for '\n', EOS */
	while (i < j) {
		buf[j] = buf[i];
		if (buf[i] == ' ' && buf[i-1] != ' ') {
			if (dir == 0)
				nb = (ne-1) / nholes + 1;
			else
				nb = ne / nholes;
			ne -= nb;
			nholes--;
			for ( ; nb > 0; nb--) {
				j--;
				buf[j] = ' ';
			}
		}
		i--;
		j--;
	}
}

/*
 * subst - substitutes a string for a specified character
 *
 */
subst(in, chr, out, subara, n)
char in[];
char chr;
char out[];
char subara[];
int n;
{
	register int i, j, k;

	dprintf("subst  ");
	j = 0;
	for (i = 0; in[i] != EOS; i++)
		if (in[i] == chr)
			for (k = 0; k < n; k++) {
				out[j] = subara[k];
				j++;
			}
		else {
			out[j] = in[i];
			j++;
		}
	out[j] = EOS;
}

/*
 * Text	process text lines
 *
 */

text(inbuf)
char inbuf[];
{
	int	i;
	register int j;
	char	wrdbuf[INSIZE];

	dovar(wrdbuf,inbuf);		/*  expand variables */
	strcpy(inbuf,wrdbuf);
	doesc(inbuf, wrdbuf, INSIZE);	/*  expand escapes   */
	dotabs(inbuf, wrdbuf, INSIZE);  /*  expand tabs      */

	if(inbuf[0] == ' ' || inbuf[0] == '\n')
		leadbl(inbuf); 		/* move left, set tival */
	if(ulval > 0 || ULon) 		/* word underlining */
	{
		underl(inbuf, wrdbuf, INSIZE);
		ulval--;
	}
	if(boval > 0 || BDon) 		/* boldfacing */
	{
		bold( inbuf, wrdbuf, INSIZE);
		boval--;
	}
	if(ceval > 0 || CEon) 		/* centering */
	{
		center(inbuf);
		put(inbuf);
		ceval--;
	}
	else if( inbuf[0] == '\n' ) 	/* all blank line */
		put(inbuf);
	else if( fill == NO ) 		/* unfilled text */
		put(inbuf);
	else 				/* filled text */
	{
		i = strlen(inbuf) - 1;
		inbuf[i] = ' ';
		if( inbuf[i-1] == '.' )
		{
			i++;
			inbuf[i] = ' ';
		}
		inbuf[i+1] = EOS;
		for( i = 0 ; getwrb(inbuf, &i, wrdbuf) > 0 ; )
			putwrd(wrdbuf);
	}
}

/*
 * Underl	underline words in a line
 *
 */
underl(buf, tbuf, size)
char buf[];
char tbuf[];
int size;
{
	int i, j;

	j = 0;
	for(i = 0 ; buf[i] != '\n' && j < size - 2; i++) {
		if( buf[i] != ' ' && buf[i] != BACKSPACE && buf[i] != '_' ) {
			tbuf[j++] = '_';
			tbuf[j++] = BACKSPACE;
		}
		if( buf[i] == BLANK )
			tbuf[j++] = ulblnk;
		else
			tbuf[j++] = buf[i];
	}

	tbuf[j] = '\n';
	tbuf[j+1] = '\0';
	strcpy(buf, tbuf);
}

/*
 * width - compute width of character string
 *
 */
int
width(buf)
char buf[];
{
	int k,i;

	dprintf("width  ");
	k = 0;
	for (i = 0; buf[i] != EOS; i++)
		if (buf[i] == BACKSPACE)
			k--;
		else if (buf[i] >= ' ' && buf[i] <= '~')
			k++;
	return(k);
}
/*
 * getnow - get the date from command line if present.
 *          if not specified, prompt user for it.
 *
 * (stub)
 */
getnow(date)
char date[];
{
	dprintf("getnow  ");
	strcpy(date,"00-xxx-1900 00:00:00");
}
