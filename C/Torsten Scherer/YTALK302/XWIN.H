/* xwin.h -- X Windows interface (xwin.c) */

/*			   NOTICE
 *
 * Copyright (c) 1990,1992,1993 Britt Yenne.  All rights reserved.
 * 
 * This software is provided AS-IS.  The author gives no warranty,
 * real or assumed, and takes no responsibility whatsoever for any 
 * use or misuse of this software, or any damage created by its use
 * or misuse.
 * 
 * This software may be freely copied and distributed provided that
 * no part of this NOTICE is deleted or edited in any manner.
 * 
 */

/* Mail comments or questions to ytalk@austin.eds.com */

#ifdef USE_X11

extern void	init_xwin	();
extern void	end_xwin	();
extern int	open_xwin	( /* yuser, title */ );
extern void	close_xwin	( /* yuser */ );
extern void	addch_xwin	( /* yuser, char */ );
extern void	move_xwin	( /* yuser, y, x */ );
extern void	clreol_xwin	( /* yuser */ );
extern void	clreos_xwin	( /* yuser */ );
extern void	scroll_xwin	( /* yuser */ );
extern void	rev_scroll_xwin	( /* yuser */ );
extern void	flush_xwin	( /* yuser */ );

#endif

/* EOF */
