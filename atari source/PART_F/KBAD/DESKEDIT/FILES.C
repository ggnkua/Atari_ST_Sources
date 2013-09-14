/* files.c - file handling functions of desk accessory editor
 * using gemskel.c application skeleton, with textwind.c window manager.
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900129 kbad reviewed
 * 890723 kbad Created
 */

#include <sys\gemskel.h>
#include <stdlib.h> /* malloc,calloc,free */
#include <string.h>
#include <tos.h>	/* Dgetdrv(), Fxxx() */
#include <sys\gemerror.h>
#include <errno.h>
#include <sys\gemerror.h>
#include "deskedit.h"

/* so as not to include the huge aes.h... */
int fsel_input( char *fs_iinpath, char *fs_iinsel, int *fs_iexbutton );
int graf_mouse( int gr_monumber, MFORM *gr_mofaddr );

int
open_file( WX **pwx, int *pvw, int *pvh )
{
	WX		*wx;
	char	file[14], *ppath;
	int		i, ret;
	DTA		mydta, *savedta;
	long	readamt;
	char	*readbuf;

	if( (wx = calloc( 1L, sizeof(WX) )) == NULL ) {
		return (int)ENSMEM;
	}

	wx->name[0] = (char)Dgetdrv() + 'A';
	wx->name[1] = ':';
	Dgetpath( &(wx->name[2]), 0 );
	strcat( wx->name, "\\*.*" );
	file[0] = 0;

	ret = fsel_input( wx->name, file, &i );
	if( ret != 1 )  {
		goto err1;
	} else if( !i ) {
		ret = (int)ERROR;
		goto err1;
	}
	if( (ppath = strrchr( wx->name, '\\' )) == NULL ) ppath = wx->name;
	else ++ppath;
	strcpy( ppath, file );

	savedta = Fgetdta();
	Fsetdta( &mydta );
	Fsfirst( wx->name, 1 );
	Fsetdta( savedta );

	if( (readbuf = (char *)Malloc(mydta.d_length)) <= NULL ) {
		ret = (int)ENSMEM;
		goto err1;
	}

	if( (ret = (int)Fopen(wx->name, 0)) < 0 ) goto err;

	graf_mouse( BUSYBEE, NULL );
	readamt = Fread( ret, mydta.d_length, readbuf );
	graf_mouse( ARROW, NULL );
	Fclose( ret );
	if( readamt != mydta.d_length ) {
		ret = (int)readamt;
err:	Mfree( readbuf );
err1:	free( wx );
		return ret;
	}
	wx->tabs = 4 * form_alert( 1, "[2][ What size tabs? ][ 4 | 8 ]" );

	graf_mouse( BUSYBEE, NULL );
	ret = parse_buf( readbuf, readamt, wx->tabs, &wx->line0, pvw, pvh );
	graf_mouse( ARROW, NULL );
	Mfree( readbuf );
	if( ret != E_OK ) {
		free_tlines( wx->curline );
		goto err1;
	}
	*pwx = wx;
	return ret;
}


int
parse_buf( char *buf, long buflen, int tabsize,
			TLINE **firstline, int *pwidth, int *pheight )
{
	char	*bufpos, *vstart;
	long	bufcount, vslen;
	int		curlen;
	int		wideline = 0;
	int		nline = 0;
	TLINE	*lp;
	TLINE	*lfirst;
	VSTRING *vs;
	int		fx = 0;

	if( (lfirst = calloc(1L,sizeof(TLINE))) == NULL ) return (int)ENSMEM;

/* replace nulls with FF's */
	bufcount = buflen;
	bufpos = buf;
	while( --bufcount )
		if( *bufpos ) ++bufpos;
		else *bufpos++ = '\377';

/* generate LINE and VSTRING structs from buffer */
	bufcount = buflen;
	bufpos = buf;
	lp = lfirst;
#ifdef RANDOM_FX
	srand( 31415 );
#endif
	do {
#ifdef RANDOM_FX
		fx = rand() & 0xf;
#endif
		++nline;
		vstart = bufpos;
		curlen = 0;
		while( *bufpos != '\n' && bufcount > 0 ) {
			switch( *bufpos ) {
			case '\t':
			/* find the length of the line before the tab */
				vslen = bufpos - vstart;
				if( curlen + vslen > MAX_LINE ) {
					vslen = MAX_LINE - curlen;
					curlen = MAX_LINE;
				}
			/* allocate a VSTRING for text before the tab */
				if( vslen ) {
					if( (vs = vs_alloc( fx, (int)vslen, vstart)) == NULL )
						goto merr;
					vs_link( vs, lp, NULL ); /* link to end of line */
				}
				if( curlen < MAX_LINE ) {
				/* allocate a VSTRING for the tab */
					vslen = curlen;
					do { ++curlen; } while( curlen % tabsize );
					vslen = curlen - vslen;
					if( (vs = vs_alloc( fx, (int)vslen, NULL)) == NULL )
						goto merr;
					vs_link( vs, lp, NULL ); /* link to end of line */
				}
				vstart = ++bufpos;
				--bufcount;
				break;
		/* other cases for special effect strings */
			default:
				if( curlen < MAX_LINE) ++curlen;
				++bufpos;
				--bufcount;
			}
		} /* end of line (or buffer) */

	/* find the length of the remainder of the line */
		vslen = bufpos - vstart;
		if( vslen ) {
			if( *(bufpos-1) == '\r' ) {
				--vslen;
				--curlen;
			}
			if( curlen + vslen > MAX_LINE ) {
				form_alert( 1, "[1][ Line truncated! ][ OK ]" );
				vslen = MAX_LINE - curlen;
				curlen = MAX_LINE;
			}
		/* create a VSTRING for the remainder of the line */
			if( vslen ) {
				if( (vs = vs_alloc(fx, (int)vslen, vstart)) == NULL ) {
merr:				free_tlines( lfirst );
					return (int)ENSMEM;
				}
				vs_link( vs, lp, NULL ); /* link to end of line */
			}
			if( curlen > wideline ) wideline = (int)curlen;
			++bufpos; /* pop the \n */
			--bufcount;
		}

		if( bufcount > 0 ) {
			if( (lp->next = calloc(1L,sizeof(TLINE))) == NULL ) goto merr;
			/*if( lp != lfirst )*/ (lp->next)->prev = lp;
			lp = lp->next;
		}

	} while( bufcount > 0 );

	*firstline = lfirst;
	*pwidth = ++wideline; /* leave a space at the end of widest line */
	*pheight = nline;
	return (int)E_OK;
}

