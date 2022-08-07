
overlay "find"

#include	"..\\include\\lists.h"
#include	"..\\include\\io.h"
#include	"..\\include\\color.h"
#include	"..\\include\\poly.h"

extern WORD glow_on;

/******************************************************************************
 *										  *
 *	await_anydn								  *
 *										  *
 *				FUNCTION DESCRIPTION				  *
 *										  *
 *	This function is responsible for waiting for a button 1 just down,	*
 *	or a keypress or a cancel button in the input.  A spacebar is mapped  *
 *	to a cancel in the virtual input structure.				  *
 *										  *
 *	ENTRY: this routines is passed no parameters				  *
 *										  *
 *	EXIT: this routine returns a pointer to a virtual input structure,	*
 *		reflecting a button just down, a keypress, or a cancel.	   *
 *										  *
 ******************************************************************************/

VIRTUAL_INPUT *
await_anydn()
{

	register	VIRTUAL_INPUT	*vis;
	char				c;

#ifdef DEBUG2
lprintf("await_anydn()\n");
#endif DEBUG2
	for (;;)
	{
		vis = await_input(USE_CURSOR);	/* wait for new x,y,z */


		if (pjstdn(vis))	/* if button 1 just hit then exit */
			break;

		if (cancel(vis))	/* if cancel button hit */
			break;

		if ((c = (char)(keydata(vis))) != (char)NOTASCII)
		{
			if (c == ' ')
			{
				vis->result &= ~KEYPRESS;
				vis->result |= CANCEL;
				vis->data = 0;
			}
			break;
		}

	}
	return(vis);
}


	/******************************************************************************
	 *										  *
	 *	await_keydn								  *
	 *										  *
	 *				FUNCTION DESCRIPTION				  *
	 *										  *
	 *	This function is responsible for waiting for a button 1 just down,	*
	 *	or a keypress or a cancel button in the input.				  *
	 *										  *
	 *	ENTRY: this routines is passed no parameters				  *
	 *										  *
	 *	EXIT: this routine returns a pointer to a virtual input structure,	*
	 *		reflecting a button just down, a keypress, or a cancel.	   *
	 *										  *
	 ******************************************************************************/

VIRTUAL_INPUT *
await_keydn()
{

	register	VIRTUAL_INPUT	*vis;

#ifdef DEBUG2
lprintf("await_keydn()\n");
#endif DEBUG2
	for (;;)
	{
		vis = await_input(NO_CURSOR);	/* wait for new x,y,z */

		if (keypress(vis))	/* if keypressed then exit */
			break;

		if (pjstdn(vis))	/* if button 1 just hit then exit */
			break;

		if (cancel(vis))	/* if cancel button hit then exit */
			break;

	}
	return(vis);
}

visible_mouse()
{
WORD mouse_color;
struct color_def far_color;
struct virtual_input *vis;

vis = getcurvis();

mouse_color = getdot(vis->curx, vis->cury);
if (glow_on && mouse_color != cycle_color)
	mouse_color = cycle_color;
else
	{
	copy_structure(usr_cmap+mouse_color, &far_color, sizeof(far_color) );
	far_color.red ^= 0x80;
	far_color.green ^= 0x80;
	far_color.blue ^= 0x80;
	mouse_color = closest_color(usr_cmap, MAXCOL, &far_color, mouse_color);
	}
set_cursor_color(mouse_color);
}


/******************************************************************************
 *										  *
 *	await_input								  *
 *										  *
 *				FUNCTION DESCRIPTION				  *
 *										  *
 *	This routine is responsible for waiting for any new input at all.	 *
 *	This includes any mouse movement, any keypress, or a change in state  *
 *	of any button.  This routine is also responsible for updating the	 *
 *	the cursor on the screen.						  *
 *										  *
 *	ENTRY: this routine is passed the following parameter:			  *
 *		use_cursor: flag saying whether or not to update cursor	   *
 *										  *
 *	EXIT: this routine returns a pointer to a virtual input structure,	*
 *		which always contains new input of some kind.			  *
 *										  *
 ******************************************************************************/
VIRTUAL_INPUT *
quick_input(use_cursor)
WORD use_cursor;
{
register VIRTUAL_INPUT *vis;

#ifdef ATARI
	visible_mouse();
	show_mouse();
#endif ATARI
	vis = getinput();		/* get new vis */
#ifdef ATARI
	hide_mouse();
#endif ATARI
	return(vis);
}


VIRTUAL_INPUT	*
await_input()
{
register VIRTUAL_INPUT	*vis, *ovp;
register int		used_cursor;
VIRTUAL_INPUT		ovis, *get_input();
#ifdef AMIGA
extern struct RastPort *cur_pix;
#endif AMIGA

#ifdef ATARI
visible_mouse();
show_mouse();
#endif ATARI

vis = getinput();

#ifdef SUN
curson(vis);			/* display the cursor */
color_cycle(cycle_color);
#endif SUN

if ( (vis->result & CANCEL)
	|| (vis->result & KEYPRESS)
	|| (vis->result & MENUPICKED)
	|| (vis->result == JUST_DN)
	|| (vis->result == JUST_UP)	)
	{
#ifdef SUN
	cursoff();				/* exit with cursor off */
#endif SUN
#ifdef ATARI
	hide_mouse();
#endif ATARI
	return(vis);
	}

ovp = &ovis;
copy_structure(vis, ovp, sizeof(VIRTUAL_INPUT) );
for (;;)
	{
	vis = getinput();		/* get new vis */
	if (vis->result != ovp->result || vis->curx != ovp->curx
	 || vis->cury   != ovp->cury   || vis->curz != ovp->curz)
		break;
#ifdef SUN
	color_cycle(cycle_color);
#endif SUN
	waits();
	}
#ifdef ATARI
	hide_mouse();
#endif ATARI
#ifdef SUN
cursoff();				/* exit with cursor off */
#endif SUN
return(vis);
}


await_penup()
{
for (;;)
	{
	if ( !pdn(&virtual) )
		break;
	getinput();
	}
}
