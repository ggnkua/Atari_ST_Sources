/*
 * STEVIE - ST Editor for VI Enthusiasts   ...Tim Thompson...twitch!tjt...
 */

#include <stdio.h>
#include <ctype.h>
#include "stevie.h"

#ifdef ATARI
#include <osbind.h>
#endif

#define NULL 0

int Rows;		/* Number of Rows and Columns */
int Columns;		/* in the current window. */

char *Realscreen;	/* What's currently on the screen, a single */
			/* array of size Rows*Columns. */
char *Nextscreen;	/* What's to be put on the screen. */

char *Filename = NULL;	/* Current file name */

char *Filemem;		/* The contents of the file, as a single array. */

char *Filemax;		/* Pointer to the end of allocated space for */
			/* Filemem. (It points to the first byte AFTER */
			/* the allocated space.) */

char *Fileend;		/* Pointer to the end of the file in Filemem. */
			/* (It points to the byte AFTER the last byte.) */

char *Topchar;		/* Pointer to the byte in Filemem which is */
			/* in the upper left corner of the screen. */

char *Botchar;		/* Pointer to the byte in Filemem which is */
			/* just off the bottom of the screen. */

char *Curschar;		/* Pointer to byte in Filemem at which the */
			/* cursor is currently placed. */

int Cursrow, Curscol;	/* Current position of cursor */

int Cursvcol;		/* Current virtual column, the column number of */
			/* the file's actual line, as opposed to the */
			/* column number we're at on the screen.  This */
			/* makes a difference on lines that span more */
			/* than one screen line. */

int State = NORMAL;	/* This is the current state of the command */
			/* interpreter. */

int Prenum = 0;		/* The (optional) number before a command. */

char *Insstart;		/* This is where the latest insert/append */
			/* mode started. */

int Changed = 0;	/* Set to 1 if something in the file has been */
			/* changed and not written out. */

int Debug = 0;

int Binary = 0;		/* Set to 1 if the file should be read and written */
			/* in binary mode (no cr-lf translation). */

char Redobuff[1024];	/* Each command should stuff characters into this */
			/* buffer that will re-execute itself. */

char Undobuff[1024];	/* Each command should stuff characters into this */
			/* buffer that will undo its effects. */

char Insbuff[1024];	/* Each insertion gets stuffed into this buffer. */

char *Uncurschar = NULL;/* Curschar is restored to this before undoing. */

int Ninsert = 0;	/* Number of characters in the current insertion. */
int Undelchars = 0;	/* Number of characters to delete, when undoing. */
char *Insptr = NULL;

main(argc,argv)
int argc;
char **argv;
{
	int mode = 8;

	while ( argc>1 && argv[1][0] == '-' ) {
		switch (argv[1][1]) {
		case 'x':
			mode = 16;
			break;
		case 'o':
			mode = 8;
			break;
		case 'd':
			Debug = 1;
			break;
		case 'b':
			Binary = 1;
			break;
		}
		argc--;
		argv++;
	}

	if ( argc <= 1 ) {
		fprintf(stderr,"usage: stevie {file}\n");
		exit(1);
	}

	Filename = strsave(argv[1]);

	windinit();

	/* Make sure Rows/Columns are big enough */
	if ( Rows < 3 || Columns < 16 ) {
		fprintf(stderr,"Rows=%d Columns=%d not big enough!\n",
			Rows,Columns);
		windexit(0);
	}

	switch ( mode ) {
	case 8:
		octchars();
		break;
	case 16:
		hexchars();
		break;
	}

	screenalloc();
	filealloc();

	screenclear();

	Fileend = Filemem;
	if ( readfile(Filename,Fileend,0) )
		filemess("[New File]");
	Topchar = Curschar = Filemem;

	updatescreen();
	
	edit();

	windexit(0);
}

/*
 * filetonext()
 *
 * Based on the current value of Topchar, transfer a screenfull of
 * stuff from Filemem to Nextscreen, and update Botchar.
 */

filetonext()
{
	int row, col;
	char *screenp = Nextscreen;
	char *memp = Topchar;
	char *endscreen;
	char *nextrow;
	char extra[16];
	int nextra = 0;
	int c;
	int n;

	/* The number of rows shown is Rows-1. */
	/* The last line is the status/command line. */
	endscreen = &screenp[(Rows-1)*Columns];

	row = col = 0;
	while ( screenp < endscreen && memp < Fileend ) {

		/* Get the next character to put on the screen. */

		/* The 'extra' array contains the extra stuff that is */
		/* inserted to represent special characters (tabs, and */
		/* other non-printable stuff.  The order in the 'extra' */
		/* array is reversed. */

		if ( nextra > 0 )
			c = extra[--nextra];
		else {
			c = (unsigned)(0xff & (*memp++));
			/* when getting a character from the file, we */
			/* may have to turn it into something else on */
			/* the way to putting it into 'Nextscreen'. */
			if ( c == '\t' ) {
				strcpy(extra,"        ");
				/* tab amount depends on current column */
				nextra = (7 - col%8);
				c = ' ';
			}
			else if ( (n=chars[c].ch_size) > 1 ) {
				char *p;
				nextra = 0;
				p = chars[c].ch_str;
				/* copy 'ch-str'ing into 'extra' in reverse */
				while ( n > 1 )
					extra[nextra++] = p[--n];
				c = p[0];
			}
		}

		if ( c == '\n' ) {
			row++;
			/* get pointer to start of next row */
			nextrow = &Nextscreen[row*Columns];
			/* blank out the rest of this row */
			while ( screenp != nextrow )
				*screenp++ = ' ';
			col = 0;
			continue;
		}
		/* store the character in Nextscreen */
		if ( col >= Columns ) {
			row++;
			col = 0;
		}
		*screenp++ = c;
		col++;
	}
	/* make sure the rest of the screen is blank */
	while ( screenp < endscreen )
		*screenp++ = ' ';
	/* put '~'s on rows that aren't part of the file. */
	if ( col != 0 )
		row++;
	while ( row < Rows ) {
		Nextscreen[row*Columns] = '~';
		row++;
	}
	Botchar = memp;
}

/*
 * nexttoscreen
 *
 * Transfer the contents of Nextscreen to the screen, using Realscreen
 * to avoid unnecessary output.
 */

nexttoscreen()
{
	char *np = Nextscreen;
	char *rp = Realscreen;
	char *endscreen;
	char nc;
	int row = 0, col = 0;
	int gorow = -1, gocol = -1;

	endscreen = &np[(Rows-1)*Columns];

	for ( ; np < endscreen ; np++,rp++ ) {
		/* If desired screen (contents of Nextscreen) does not */
		/* match what's really there, put it there. */
		if ( (nc=(*np)) != (*rp) ) {
			*rp = nc;
			/* if we are positioned at the right place, */
			/* we don't have to use windgoto(). */
			if ( ! (gorow == row && gocol == col) )
				windgoto(gorow=row,gocol=col);
			windputc(nc);
			gocol++;
		}
		if ( ++col >= Columns ) {
			col = 0;
			row++;
		}
	}
	windrefresh();
}

updatescreen()
{
	filetonext();
	nexttoscreen();
}

screenclear()
{
	int n;

	windclear();
	/* blank out the stored screens */
	for ( n=Rows*Columns-1; n>=0; n-- ) {
		Realscreen[n] = ' ';
		Nextscreen[n] = ' ';
	}
}

filealloc()
{
	if ( (Filemem=malloc((unsigned)FILELENG)) == NULL ) {
		fprintf(stderr,"Unable to allocate %d bytes for file memory!\n",
			FILELENG);
		exit(1);
	}
	Filemax = Filemem + FILELENG;
}

screenalloc()
{
	Realscreen = malloc((unsigned)(Rows*Columns));
	Nextscreen = malloc((unsigned)(Rows*Columns));
}

readfile(fname,fromp,nochangename)
char *fname;
char *fromp;
int nochangename;	/* if 1, don't change the Filename */
{
#ifdef ATARI
	static char currdisk = 0;
	char fbuff[128];
	int c1, c2;
#endif
	FILE *f;
	char buff[128];
	char *p;
	int c, n;
	int unprint = 0;

#ifdef ATARI
	if ( currdisk == 0 )
		currdisk = 'a' + Dgetdrv();

	/* If a drive is specified, it is used from then */
	/* on as the default drive. */
	c1 = tolower(*fname);
	c2 = *(fname+1);
	if ( c2 == ':' && c1>='a' && c1<='z' )
		currdisk = c1;
	else {
		/* if no drive is specified, use the default one. */
		sprintf(fbuff,"%c:\\%s",toupper(currdisk),fname);
		fname = fbuff;
	}
#endif
	if ( ! nochangename )
		Filename = strsave(fname);

#ifdef ATARI
	if ( (f=fopen(fname,Binary?"br":"r")) == NULL ) {
#else
	if ( (f=fopen(fname,"r")) == NULL ) {
#endif
		Fileend = Filemem;
		return(1);
	}

	for ( n=0; (c=getc(f)) != EOF; n++ ) {
		if ( ! (isprint(c)||isspace(c)) )
			unprint++;
		if ( fromp >= Filemax ) {
			fprintf(stderr,"File too long (limit is %d)!\n",FILELENG);
			exit(1);
		}
		/* Insert the char at the current point by shifting
		/* everything down. */
		for ( p=Fileend; p>fromp; p-- )
			*p = *(p-1);
		*fromp++ = c;
		if ( Fileend < fromp )
			Fileend = fromp;
	}
	if ( ! Binary && unprint > 0 ) {
		sprintf(buff,"%d unprintable chars!  Perhaps binary mode (-b) should be used?",unprint);
		message(buff);
		sleep(2);
	}
	if ( unprint > 0 )
		p = "\"%s\" %d characters (%d un-printable)  (Press 'H' for help)";
	else
		p = "\"%s\" %d characters  (Press 'H' for help)";
	sprintf(buff,p,fname,n,unprint);
	message(buff);
	fclose(f);
	return(0);
}

static char getcbuff[1024];
static char *getcnext = NULL;

stuffin(s)
char *s;
{
	if ( getcnext == NULL ) {
		strcpy(getcbuff,s);
		getcnext = getcbuff;
	}
	else
		strcat(getcbuff,s);
}

addtobuff(s,c1,c2,c3,c4,c5,c6)
char *s;
char c1, c2, c3, c4, c5, c6;
{
	char *p = s;
	if ( (*p++ = c1) == '\0' )
		return;
	if ( (*p++ = c2) == '\0' )
		return;
	if ( (*p++ = c3) == '\0' )
		return;
	if ( (*p++ = c4) == '\0' )
		return;
	if ( (*p++ = c5) == '\0' )
		return;
	if ( (*p++ = c6) == '\0' )
		return;
}

vgetc()
{
	if ( getcnext != NULL ) {
		int nextc = *getcnext++;
		if ( *getcnext == '\0' ) {
			*getcbuff = '\0';
			getcnext = NULL;
		}
		return(nextc);
	}
	return(windgetc());
}

vpeekc()
{
	if ( getcnext != NULL )
		return(*getcnext);
	return(-1);
}

/*
 * anyinput
 *
 * Return non-zero if input is pending.
 */

anyinput()
{
	if ( getcnext != NULL )
		return(1);
	return(0);
}

#ifdef ATARI
sleep(n)
int n;
{
	int k;

	k = Tgettime();
	while ( Tgettime() <= k+n )
		;
}
#endif
