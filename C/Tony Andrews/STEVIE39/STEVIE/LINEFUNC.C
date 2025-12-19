/*
 * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
 */

#include <stdio.h>
#include "stevie.h"

/*
 * nextline(curr)
 *
 * Return a pointer to the beginning of the next line after the
 * 'curr' char.  Return NULL if there is no next line.
 */

char *
nextline(curr)
char *curr;
{
	while ( curr<Fileend ) {
		if ( *curr++ == '\n' )
			break;
	}
	if ( curr >= Fileend )
		return(NULL);
	return(curr);
}

/*
 * prevline(curr)
 *
 * Return a pointer to the beginning of the previous line before the
 * 'curr' char.  Return NULL if there is no previous line.
 */

char *
prevline(curr)
char *curr;
{
	int nnl = 0;

	/* If we are currently positioned on a '\n', */
	/* we are on a blank line.  Adjust accordingly. */
	if ( *curr == '\n' )
		nnl = -1;
	while ( curr>Filemem ) {
		/* look for the 2nd previous newline */
		if ( *curr == '\n' ) {
			nnl++;
			if ( nnl == 2)
				break;
		}
		curr--;
	}
	if ( curr <= Filemem ) {
		/* If we found 1 newline, we found the first line */
		if ( nnl == 1 )
			return(Filemem);
		else
			return(NULL);
	}
	/* return the first char of the previous line */
	return(++curr);
}

/*
 * coladvance(p,col)
 *
 * Try to advance to the specified column, starting at p.
 */

char *
coladvance(p,col)
char *p;
int col;
{
	int c, inc;

	/* If we're on a blank ('\n' only) line, we can't do anything */
	if ( *p == '\n' )
		return(p);
	/* try to advance to the specified column */
	for ( c=0; col-- > 0; c++ ) {
		/* Count a tab for what it's worth */
		if ( *p == '\t' ) {
			inc = (7 - c%8);
			col -= inc;
			c += inc;
		}
		p++;
		/* Don't go past the end of */
		/* the file or the line. */
		if ( p==Fileend || *p=='\n' ) {
			p--;
			break;
		}
	}
	return(p);
}
char *strcpy(), *malloc();

#define NULL 0
  
char *
alloc(size)
unsigned size;
{
	char *p;		/* pointer to new storage space */

	p = malloc(size);
	if ( p == (char *)NULL ) {	/* if there is no more room... */
		message("alloc() is unable to find memory!");
	}
	return(p);
}

char *
strsave(string)
char *string;
{
	return(strcpy(alloc((unsigned)(strlen(string)+1)),string));
}

#define NULL 0

static char *laststr = NULL;
static int lastdir;

char *
ssearch(dir,str)
int dir;	/* FORWARD or BACKWARD */
char *str;
{
	if ( laststr != NULL )
		free(laststr);
	laststr = strsave(str);
	lastdir = dir;
	if ( dir == BACKWARD )
		return(bcksearch(str));
	else
		return(fwdsearch(str));
}

dosearch(dir,str)
int dir;
char *str;
{
	char *p;

	if ( (p=ssearch(dir,str)) == NULL )
		message("Pattern not found");
	else {
		char *savep;

		cursupdate();
		/* if we're backing up, we make sure the line we're on */
		/* is on the screen. */
		Curschar = savep = p;
		/* get to the beginning of the line */
		beginline();
		if ( Curschar < Topchar )
			Topchar = Curschar;
		Curschar = savep;
		cursupdate();
		updatescreen();
	}
}


repsearch()
{
	if ( laststr == NULL )
		beep();
	else {
		dosearch(lastdir,laststr);
	}
}

char *
fwdsearch(str)
char *str;
{
	register char *sofar = str;
	register char *infile = Curschar+1;
	int leng = strlen(str);
	char *stopit;

	/* search forward to the end of the file */
	for ( ; infile < Fileend && *sofar != '\0' ; infile++ ) {
		if ( *infile == *sofar )
			sofar++;
		else
			sofar = str;
	}
	if ( *sofar == '\0' )
		return(infile-strlen(str));
	/* search from the beginning of the file to Curschar */
	infile = Filemem;
	sofar = str;
	stopit = Curschar + leng;
	for ( ; infile <= stopit && *sofar != '\0' ; infile++ ) {
		if ( *infile == *sofar )
			sofar++;
		else
			sofar = str;
	}
	if ( *sofar == '\0' )
		return(infile-leng);
	else
		return(NULL);
}

char *
bcksearch(str)
char *str;
{
	int leng = strlen(str);
	char *infile = Curschar+1;
	char *endofstr, *sofar, *stopit;

	/* make sure str isn't empty before getting pointer to */
	/* its last character. */
	if ( leng == 0 )
		return(NULL);
	endofstr = &str[leng-1];
	sofar = endofstr;
	/* search backward to the beginning of the file */
	for ( ; infile >= Filemem && sofar >= str ; infile-- ) {
		if ( *infile == *sofar )
			sofar--;
		else
			sofar = endofstr;
	}
	if ( sofar < str )
		return(++infile);

	/* search backward from the end of the file */
	sofar = endofstr;
	infile = Fileend-1;
	stopit = Curschar - leng;
	for ( ; infile >= stopit && sofar >= str ; infile-- ) {
		if ( *infile == *sofar )
			sofar--;
		else
			sofar = endofstr;
	}
	if ( sofar < str )
		return(++infile);
	else
		return(NULL);
}
