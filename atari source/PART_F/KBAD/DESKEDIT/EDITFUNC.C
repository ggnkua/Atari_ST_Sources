/* editfunc.c - editing functions of desk accessory editor
 * using gemskel.c application skeleton, with textwind.c window manager.
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900125 kbad Cleaned up a bit, added control key handling
 * 890723 kbad Created
 */

#include <sys\gemskel.h>
#include <stdlib.h>		/* free() */
#include <string.h>
#include "deskedit.h"

void
insert_char( int key, WINFO *w )
{
	TLINE	*tl;
	VSTRING	*new, *vs, *vp;
	int		x=0, curx, cury;
	char	s[2];
	GRECT	clip, rs, rd, edit;

/* if user has paged window, snap back to edit coordinates */
	edit.g_x = w->vir.g_x;
	edit.g_y = w->vir.g_y;
	edit.g_w = w->phy.g_w;
	edit.g_h = w->phy.g_h;
	if( !xy_inrect( WXedx(w), WXedy(w), &edit ) ) {
		w->vir.g_x = WXedx(w);
		w->vir.g_y = WXedy(w);
		wind_sliders( YES, YES, w );
		rs = w->work;
		wind_adjust( w, &rs );
		redraw( w, &rs );
	}

/* find the TLINE and VSTRING in the window */
	curx = w->vir.g_x + w->phy.g_x;
	cury = w->vir.g_y + w->phy.g_y;
	tl = vy_2line( w, cury );
	for( x = 0, vs = tl->vs;
		 vs && x + vs->len < curx;
		 x += vs->len, vs = vs->next );

/* if the current position is a tab, link in a new vstring */
	if( !vs->s[0] ) {
		s[0] = (char)key;
		new = vs_alloc( 0, 1, s );
	/* fix the tab */
		if( --(vs->len) == 0 ) vs->len = WXtabs(w);
		vs_link( new, tl, vs );
	} else {
/* otherwise, copy the vstring, add the new character, and re-link */
	/* fix up 1st tab following this vstring */
		for( vp = vs->next; vp && vp->s[0]; vp = vp->next );
		if( vp && --(vp->len) == 0 ) vp->len = WXtabs(w);
	/* copy this vstring */
		new = vs_alloc( vs->fx, vs->len + 1, NULL );
	/* insert new character */
		strncpy( new->s, vs->s, curx - x );
		new->s[curx - x] = (char)key;
		strcat( new->s, &(vs->s[curx - x]));
	/* link new vstring */
		vs_link( new, tl, vs );
		new->next = vs->next;
		free( vs );
	}
/* adjust virtual width if needed */
	if( tlen(tl) > w->vir.g_w )
		w->vir.g_w++;

/* arrow the window if we're near the right border */
	if( w->phy.g_x == w->phy.g_w - 2 ) {
		wind_arrowed( WA_RTLINE, w );
		--w->phy.g_x;
	}

/* redraw to the end of the line */
	clip = w->work;
	wind_adjust( w, &clip );
	draw_cursor( w, &clip ); /* undraw */
	clip.g_x += w->phy.g_x * w->wchar;
	clip.g_y += w->phy.g_y * w->hchar;
	clip.g_w = (w->phy.g_w - w->phy.g_x) * w->wchar;
	clip.g_h = w->hchar;
	rs = rd = clip;
	rd.g_w = (rs.g_w -= w->wchar);
	rd.g_x += w->wchar;
	screenblit( &clip, &rs, &rd );
	erase_right( w );
/* redraw the cursor at the new coordinates */
	draw_cursor( w, &clip );
	
/* and finally, draw the typed character */
	w->phy.g_x++;
	WXedx(w)++;
	clip.g_w = w->wchar;
	redraw( w, &clip );
/* and update the rects */
	wind_sliders( NO, YES, w );

}

