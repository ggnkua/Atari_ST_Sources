/* lines.c - line/vstring functions of desk accessory editor
 * using gemskel.c application skeleton, with textwind.c window manager.
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900129 kbad reviewed
 * 890723 kbad Created
 */

#include <sys\gemskel.h>
#include <stdlib.h>
#include <string.h>
#include "deskedit.h"

void
vs_draw( int x, int y, VSTRING *vs, int wchar,
		int startcol, int maxcol, int rightcol )
{
	int 	c, col = 0;
	char	savech = 0;
	int 	fx;

/* find the VSTRING corresponding to the start column */
	while( vs && col+vs->len < startcol ) {
		col += vs->len;
		vs = vs->next;
	}
/* if line extends into redraw area */
	if( vs ) {
	/* optimize for column 0 case */
		if( startcol != 0 ) {
			c = startcol - col; /* offset into first string */
		/* splat the first string (or tab over) */
			if( (vs->s)[c] ) {
				if( startcol + vs->len > rightcol ) {
					savech = vs->s[ c + rightcol - startcol ];
					vs->s[ c + rightcol - startcol ] = 0;
				}
				vst_effects( vhandle, vs->fx );
				v_gtext( vhandle, x, y, &((vs->s)[c]) );
				if( savech ) {
					vs->s[ c + rightcol - startcol ] = savech;
					savech = 0;
				}
			}
			x += ((vs->len - c) * wchar);
			col += vs->len;
			vs = vs->next;
		}
	/* now draw the rest of the line */
		while( vs && col < maxcol ) {
			fx = vs->fx;
			vst_effects( vhandle, fx );
			c = vs->len;
			if( vs->s[0] ) {
			/* don't draw partial chars on the right */
				if( col + c > rightcol ) {
					savech = vs->s[ rightcol - col ];
					vs->s[ rightcol - col ] = 0;
				}
				if( vs->fx != fx ) {
					fx = vs->fx;
					vst_effects( vhandle, fx );
				}
				v_gtext( vhandle, x, y, vs->s );
				if( savech ) {
					vs->s[ rightcol - col ] = savech;
					savech = 0;
				}
			}
			x += c * wchar;
			col += c;
			vs = vs->next;
		}
	}
}

TLINE *
vy_2line( const WINFO *w, int vy )
{
	TLINE	*tl = WXline0(w);
	int 	y;

/* SLOW NEAR EOF WITH BIG FILES! */
	for( y = 0; y < vy; ++y, tl = tl->next );
	return tl;
}

VSTRING *
vs_alloc( int fx, int len, char *s )
{
	VSTRING *vs;

/* This wastes `len' bytes for vstrings without strings, but
 * that fact is used by vs_draw().
 */
	if( (vs = calloc(1L, sizeof(VSTRING) + len)) == NULL ) goto ret;
	vs->fx = fx;
	vs->len = len;
	if( s ) strncpy( vs->s, s, len ); /* null s means tab VSTRING */
ret:
	return vs;
}

void
vs_link( VSTRING *new, TLINE *l, VSTRING *prev )
{
	VSTRING *vp, *vq;

	if( (vp = l->vs) == NULL ) { /* first VSTRING */
		l->vs = new;
	} else if( vp == prev ) { /* link before first string */
		l->vs = new;
		new->next = prev;
	} else { /* find `prev' to link before */
		while( vp != prev ) vp = (vq=vp)->next;
		vq->next = new;
		new->next = vp;
	}
}


int
tlen( TLINE *l )
{
	int 	len;
	VSTRING	*vs;

	for( vs = l->vs, len = 0; vs; len += vs->len, vs = vs->next );
	return len;
}

void
free_tlines( TLINE *l )
{
	TLINE	*lp, *lq;
	VSTRING *vp, *vq;

	lp = l;
	while( lp ) {
		vp = lp->vs;
		while( vp ) {
			vp = (vq=vp)->next;
			free( vq );
		}
		lp = (lq=lp)->next;
		free( lq );
	}
}
