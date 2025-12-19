/*
 * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
 */

#include <stdio.h>
#include <ctype.h>
#include "stevie.h"

/*
 * opencmd
 *
 * Add a blank line below the current line.
 */

opencmd()
{
	/* get to the end of the current line */ 
	while ( Curschar<Fileend && (*Curschar) != '\n' )
		Curschar++;
	/* Try to handle a file that doesn't end with a newline */
	if ( Curschar >= Fileend )
		Curschar = Fileend-1;
	/* Add the blank line */
	appchar('\n');
}

issepchar(c)
char c;
{
	if ( strchr(WORDSEP,c) != NULL )
		return(1);
	return(0);
}

cntlines(pbegin,pend)
char *pbegin, *pend;
{
	int lnum = 1;
	char *p;

	for ( p=pbegin; p<pend; ) {
		if ( *p++ == '\n' )
			lnum++;
	}
	return(lnum);
}

fileinfo()
{
	char buff[128];

	sprintf(buff,"\"%s\"%s line %d of %d",
		Filename,
		Changed?" [Modified]":"",
		cntlines(Filemem,Curschar),
		cntlines(Filemem,Fileend)-1);
	message(buff);
}

gotoline(n)
int n;
{
	char *p;

	if ( n == 0 ) {
		if ( (p=prevline(Fileend)) != NULL )
			Curschar = p;
	}
	else {
		/* Start at the top of the file and go down 'n'-1 lines */
		Curschar = Filemem;
		while ( --n > 0 ) {
			if ( (p=nextline(Curschar)) == NULL )
				break;
			Curschar = p;
		}
	}
	Topchar = Curschar;
	for ( n=0; n<Rows/2; n++ ) {
		if ( (p=prevline(Topchar)) == NULL )
			break;
		Topchar = p;
	}
	updatescreen();
}

char *Savedline = NULL;
int Savednum = 0;

/*
 * yankline
 *
 * Save a copy of the current line(s) for later 'p'lacing.
 */

yankline(n)
{
	char *savep, *p, *q;
	int leng, k;

	if ( Savedline != NULL )
		free(Savedline);
	savep = Curschar;
	/* go to the beginning of the current line. */
	beginline();
	/* compute length of line */
	for ( p=Curschar,leng=0; ; p++ ) {
		if ( *p == '\n' ) {
			/* keep going until we've seen 'n' lines */
			if ( --n <= 0 )
				break;
		}
		leng++;
	}
	/* save a copy of it */
	Savedline = malloc((unsigned)(leng+2));
	for ( p=Curschar,q=Savedline,k=0; k<leng; k++ )
		*q++ = *p++;
	/* get the final newline */
	*q++ = *p;
	*q = '\0';
	Curschar = savep;
	Savednum = leng+1;
}

/*
 * putline
 *
 * If there is a currently saved line(s), 'p'ut it.
 * If k==1, 'P'ut the line (i.e. above instead of below.
 */

putline(k)
int k;
{
	char *p;
	int n;

	if ( Savedline == NULL )
		return;
	message("Inserting saved stuff...");
	if ( k == 0 ) {
		/* get to the end of the current line */
		while ( Curschar<Fileend && *Curschar != '\n' )
			Curschar++;
	}
	else
		beginline();
	/* append or insert the characters of the saved line */
	for ( p=Savedline,n=0; n<Savednum; p++,n++ ) {
		if ( k == 0 )
			appchar(*p);
		else
			inschar(*p);
	}
	/* We want to end up at the beginning of the line. */
	while ( n-->1 )
		Curschar--;
	if ( k == 1 )
		Curschar--;
	beginline();
	message("");
	updatescreen();
}

inschar(c)
int c;
{
	register char *p;

	/* Move everything in the file over to make */
	/* room for the new char. */
	if ( ! canincrease(1) )
		return;

	for ( p=Fileend; p>Curschar; p-- ) {
		*p = *(p-1);
	}
	*Curschar++ = c;
	Fileend++;
	CHANGED;
}

insstr(s)
char *s;
{
	register char *p;
	int k, n = strlen(s);

	/* Move everything in the file over to make */
	/* room for the new string. */
	if ( ! canincrease(n) )
		return;

	for ( p=Fileend-1+n; p>Curschar; p-- ) {
		*p = *(p-n);
	}
	for ( k=0; k<n; k++ )
		*Curschar++ = *s++;
	Fileend += n;
	CHANGED;
}

appchar(c)
int c;
{
	char *p, *endp;

	/* Move everything in the file over to make */
	/* room for the new char. */
	if ( ! canincrease(1) )
		return;

	endp = Curschar+1;
	for ( p=Fileend; p>endp; p-- ) {
		*p = *(p-1);
	}
	*(++Curschar) = c;
	Fileend++;
	CHANGED;
}

canincrease(n)
int n;
{
	if ( (Fileend+n) >= Filemax ) {
		message("Can't add anything, file is too big!");
		State = NORMAL;
		return(0);
	}
	return(1);
}

#define NULL 0

delchar()
{
	char *p;

	/* Check for degenerate case; there's nothing in the file. */
	if ( Filemem == Fileend )
		return;
	/* Delete the character at Curschar by shifting everything */
	/* in the file down. */
	for ( p=Curschar+1; p<Fileend; p++ )
		*(p-1) = *p;
	/* If we just took off the last character of a non-blank line, */
	/* we don't want to end up positioned at the newline. */
	if ( *Curschar=='\n' && Curschar>Filemem && *(Curschar-1)!='\n' )
		Curschar--;
	Fileend--;
	CHANGED;
}

delword(deltrailing)
int deltrailing;	/* 1 if trailing white space should be removed. */
{
	int c = *Curschar;
	char *p = Undobuff;

	/* The Undo string is an 'i'nsert of the word we're deleting. */
	*p++ = 'i';
	/* If we're positioned on a word separator... */
	if ( issepchar(c) && ! isspace(c) ) {
		/* If we're on a non-space separator, remove */
		/* the separators and any following space. */
		while ( issepchar(c) && ! isspace(c) ) {
			/* Add the deleted character to the Undobuff */
			*p++ = *Curschar;
			delchar();
			c = *Curschar;
		}
	}
	else {	/* we're positioned in the middle of a word */
		int endofline = 0;
		while ( ! issepchar(*Curschar) && *Curschar != '\n' ) {
			/* If the next char is a newline, we note */
			/* that fact here, because delchar() won't */
			/* position us there afterword. */
			if ( *(Curschar+1) == '\n' )
				endofline = 1;
			/* Add the deleted character to the Undobuff */
			*p++ = *Curschar;
			delchar();
			if ( endofline )
				break;
		}
	}
	if ( deltrailing ) {
		/* remove any trailing white space */
		while ( isspace(*Curschar) && *Curschar != '\n' ) {
			/* Add the deleted character to the Undobuff */
			*p++ = *Curschar;
			delchar();
		}
	}
	*p++ = '\033';
	*p = '\0';
}

delline(nlines)
{
	int nchars;
	char *p, *q;

	/* If we're not at the beginning of the line, get there. */
	if ( *Curschar != '\n' ) {
		/* back up to the previous newline (or the beginning */
		/* of the file. */
		while ( Curschar > Filemem ) {
			if ( *Curschar == '\n' ) {
				Curschar++;
				break;
			}
			Curschar--;
		}
	}
	message("Deleting...");
	while ( nlines-- > 0 ) {
		/* Count the characters in the line */
		for ( nchars=1,p=Curschar; p<Fileend&&*p!='\n'; p++,nchars++ )
			;
		/* Delete the characters of the line */
		/* by moving everything else in the file down. */
		q = Curschar;
		p = Curschar+nchars;
		while ( p<Fileend )
			*q++ = *p++;
		Fileend -= nchars;
		CHANGED;

		/* If we delete the last line in the file, back up */
		if ( Curschar >= Fileend ) {
			if ( (Curschar=prevline(Curschar)) == NULL )
				Curschar = Filemem;
			/* and don't try to delete any more lines */
			break;
		}
	}
	message("");
}

char *strchr(s,c)
char *s;
int c;
{
	do {
		if ( *s == c )
			return(s);
	} while (*s++);
	return(NULL);
}
