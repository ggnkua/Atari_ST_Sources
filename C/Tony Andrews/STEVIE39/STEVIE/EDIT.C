/*
 * STevie - ST editor for VI enthusiasts.     ...Tim Thompson...twitch!tjt...
 */

#include <stdio.h>
#include <ctype.h>
#include "stevie.h"

edit()
{
	int c, c1, c2;
	char *p, *q;

	Prenum = 0;

	/* position the display and the cursor at the top of the file. */
	Topchar = Filemem;
	Curschar = Filemem;
	Cursrow = Curscol = 0;

	for ( ;; ) {
	/* Figure out where the cursor is based on Curschar. */
	cursupdate();
	if ( State == INSERT )
		message("Insert Mode");
	/* printf("Curschar=(%d,%d) row/col=(%d,%d)",
		Curschar,*Curschar,Cursrow,Curscol); */
	windgoto(Cursrow,Curscol);
	windrefresh();
	c = vgetc();
	if ( State != INSERT )
		message("");
	switch(State) {
	case NORMAL:
		/* We're in the normal (non-insert) mode. */

		/* Pick up any leading digits and compute 'Prenum' */
		if ( (Prenum>0 && isdigit(c)) || (isdigit(c) && c!='0') ){
			Prenum = Prenum*10 + (c-'0');
			break;
		}
		/* execute the command */
		normal(c);
		Prenum = 0;
		break;
	case INSERT:
		/* We're in insert mode. */
		switch(c){
		case '\033':	/* an ESCape ends input mode */

			/* If we're past the end of the file, (which should */
			/* only happen when we're editing a new file or a */
			/* file that doesn't have a newline at the end of */
			/* the line), add a newline automatically. */
			if ( Curschar >= Fileend ) {
				insertchar('\n');
				Curschar--;
			}

			/* Don't end up on a '\n' if you can help it. */
			if ( Curschar>Filemem && *Curschar=='\n'
				&& *(Curschar-1)!='\n' ) {
				Curschar--;
			}
			State = NORMAL;
			message("");
			Uncurschar = Insstart;
			Undelchars = Ninsert;
			/* Undobuff[0] = '\0'; */
			/* construct the Redo buffer */
			p=Redobuff;
			q=Insbuff;
			while ( q<Insptr )
				*p++ = *q++;
			*p++ = '\033';
			*p = '\0';
			updatescreen();
			break;
		case '\b':
			if ( Curschar <= Insstart )
				beep();
			else {
				int wasnewline = 0;
				if ( *Curschar == '\n' )
					wasnewline=1;
				Curschar--;
				delchar();
				Insptr--;
				Ninsert--;
				if ( wasnewline )
					Curschar++;
				cursupdate();
				updatescreen();
			}
			break;
		case '\030':	/* control-x */ 
			{ int wasnewline = 0; char *p1;
			p1 = Curschar;
			if ( *Curschar == '\n' )
				wasnewline = 1;
			inschar('[');
			inschar('x');
			cursupdate();
			updatescreen();
			c1 = gethexchar();
			inschar(c1);
			cursupdate();
			updatescreen();
			c2 = gethexchar();
			Curschar = p1;
			delchar();
			delchar();
			delchar();
			c = 16*hextoint(c1)+hextoint(c2);
			if(Debug)printf("(c=%d)",c);
			if ( wasnewline )
				Curschar++;
			inschar(c);
			Ninsert++;
			*Insptr++ = c;
			updatescreen();
			break;
			}
		case '\017':
			break;
		case '\r':
			c = '\n';
			/* This is SUPPOSED to fall down into 'default' */
		default:
			insertchar(c);
			break;
		}
		break;
	}
	}
}

insertchar(c)
int c;
{
	char *p;

	if ( ! anyinput() ) {
		inschar(c);
		*Insptr++ = c;
		Ninsert++;
	}
	else {
		/* If there's any pending input, grab */
		/* it all at once. */
		p = Insptr;
		*Insptr++ = c;
		Ninsert++;
		while ( (c=vpeekc()) != '\033' ) {
			c = vgetc();
			*Insptr++ = c;
			Ninsert++;
		}
		*Insptr = '\0';
		insstr(p);
	}
	updatescreen();
}

gethexchar()
{
	int c;

	for ( ;; ) {
		windgoto(Cursrow,Curscol);
		windrefresh();
		c = vgetc();
		if ( hextoint(c) >= 0 )
			break;
		message("Expecting a hexidecimal character (0-9 or a-f)");
		beep();
		sleep(1);
	}
	return(c);
}

getout()
{
	windgoto(Rows-1,0);
	windrefresh();
	putchar('\r');
	putchar('\n');
	windexit(0);
}

cursupdate()
{
	char *p;
	int inc, c, nlines;

	/* special case: file is completely empty */
	if ( Fileend == Filemem ) {
		Topchar = Curschar = Filemem;
	}
	else if ( Curschar < Topchar ) {
		nlines = cntlines(Curschar,Topchar);
		/* if the cursor is above the top of */
		/* the screen, put it at the top of the screen.. */
		Topchar = Curschar;
		/* ... and, if we weren't very close to begin with, */
		/* we scroll so that the line is close to the middle. */
		if ( nlines > Rows/3 )
			scrolldown(Rows/3);
		else {
			/* make sure we have the current line completely */
			/* on the screen, by setting Topchar to the */
			/* beginning of the current line (in a strange way). */
			if ( (p=prevline(Topchar))!=NULL &&
				(p=nextline(p))!=NULL ) {
				Topchar = p;
			}
		}
		updatescreen();
	}
	else if ( Curschar >= Botchar && Curschar < Fileend ) {
		nlines = cntlines(Botchar,Curschar);
		/* If the cursor is off the bottom of the screen, */
		/* put it at the top of the screen.. */
		Topchar = Curschar;
		/* ... and back up */
		if ( nlines > Rows/3 )
			scrolldown((2*Rows)/3);
		else
			scrolldown(Rows-2);
		updatescreen();
	}

	Cursrow = Curscol = Cursvcol = 0;
	for ( p=Topchar; p<Curschar; p++ ) {
		c = *p;
		if ( c == '\n' ) {
			Cursrow++;
			Curscol = Cursvcol = 0;
			continue;
		}
		/* A tab gets expanded, depending on the current column */
		if ( c == '\t' )
			inc = (8 - (Curscol)%8);
		else
			inc = chars[(unsigned)(c & 0xff)].ch_size;
		Curscol += inc;
		Cursvcol += inc;
		if ( Curscol >= Columns ) {
			Curscol -= Columns;
			Cursrow++;
		}
	}
}

scrolldown(nlines)
int nlines;
{
	int n;
	char *p;

	/* Scroll up 'nlines' lines. */
	for ( n=nlines; n>0; n-- ) {
		if ( (p=prevline(Topchar)) == NULL )
			break;
		Topchar = p;
	}
}

/*
 * oneright
 * oneleft
 * onedown
 * oneup
 *
 * Move one char {right,left,down,up}.  Return 1 when
 * sucessful, 0 when we hit a boundary (of a line, or the file).
 */

oneright()
{
	char *p;

	p = Curschar;
	if ( (*p++)=='\n' || p>=Fileend || *p == '\n' )
		return(0);
	Curschar++;
	return(1);
}

oneleft()
{
	char *p;

	p = Curschar;
	if ( *p=='\n' || p==Filemem || *(p-1) == '\n' )
		return(0);
	Curschar--;
	return(1);
}

beginline()
{
	while ( oneleft() )
		;
}

oneup(n)
{
	char *p, *np;
	int savevcol, k;

	savevcol = Cursvcol;
	p = Curschar;
	for ( k=0; k<n; k++ ) {
		/* Look for the previous line */
		if ( (np=prevline(p)) == NULL ) {
			/* If we've at least backed up a little .. */
			if ( k > 0 )
				break;	/* to update the cursor, etc. */
			else
				return(0);
		}
		p = np;
	}
	Curschar = p;
	/* This makes sure Topchar gets updated so the complete line */
	/* is one the screen. */
	cursupdate();
	/* try to advance to the same (virtual) column */
	/* that we were at before. */
	Curschar = coladvance(p,savevcol);
	return(1);
}

onedown(n)
{
	char *p, *np;
	int k;

	p = Curschar;
	for ( k=0; k<n; k++ ) {
		/* Look for the next line */
		if ( (np=nextline(p)) == NULL ) {
			if ( k > 0 )
				break;
			else
				return(0);
		}
		p = np;
	}
	/* try to advance to the same (virtual) column */
	/* that we were at before. */
	Curschar = coladvance(p,Cursvcol);
	return(1);
}
