/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<types2b.h>
#include	<mt_aes.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include "rect.h"

/*----------------------------------------------------------------------------------------*/
/* defines																											*/
/*----------------------------------------------------------------------------------------*/

#ifndef	NIL
#define	NIL	-1
#endif
#ifndef	NULL
#define	NULL	-1
#endif
enum BOOL {false,true};
/*----------------------------------------------------------------------------------------*/
/* Popupfunktion fr alle TOS/MagiC/N.AES-Versionen (ben”tigt MT_AES.LIB/MT_AES.H)			*/
/* Funktionsergebnis:	Objektnummer des selektierten Objekts bzw. -1							*/
/*	ptree:					Zeiger auf den Objektbaum des Popups										*/
/*	obj:						Objektnummer des Popupwurzelobjekts											*/
/*	x_off,y_off:			Gewnschte Koordinaten der oberen linken Ecke des Popups	(werden	*/
/*								automatisch angepasst, damit das Popup ganz angezeigt wird)			*/
/*----------------------------------------------------------------------------------------*/
int16	icn_popup( int16 ptree, int16 obj, int16 x_off, int16 y_off )
{
	OBJECT	*tree;
	GRECT		rect, desk, rect1, rect2;
	GRECT		kl_rect = {0,0,0,0};
	int16		item, founditem, olditem;
	int16		first_child, last_child;
	int16		event, ret;
	UWORD		uret;
	int16		bclicks, bmask, bstate;
	int		leave, found;
	EVNTDATA ev;

	rsrc_gaddr(R_TREE, ptree, &tree);

	first_child = (tree[obj].ob_head);
	last_child  = (tree[obj].ob_tail);

	olditem = -1;

	while(last_child != -1)
	{
		olditem = last_child;
		last_child = (tree[last_child].ob_tail);
	}

	last_child = olditem;

	tree[R_TREE].ob_x = 0;			/* Anpassen des Parent-Objekts */
	tree[R_TREE].ob_y = 0;

	tree[obj].ob_x = x_off;			/* Anpassen der Popup-Box */
	tree[obj].ob_y = y_off;

	wind_get(0,WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);

	/* Das POPUP darf nicht ausserhalb des Bildschirms erscheinen) */
	if( (tree[obj].ob_x + tree[obj].ob_width) > (desk.g_x + desk.g_w) )
		tree[obj].ob_x = (desk.g_x + desk.g_w - tree[obj].ob_width);

	if( (tree[obj].ob_y + tree[obj].ob_height) > (desk.g_y + desk.g_h) )
		tree[obj].ob_y = (desk.g_y + desk.g_h - tree[obj].ob_height);

	if(tree[obj].ob_x < 0) tree[obj].ob_x = desk.g_x;
	if(tree[obj].ob_y < 0) tree[obj].ob_y = desk.g_y;

	rect.g_x = tree[obj].ob_x - 8;
	rect.g_y = tree[obj].ob_y - 8;
	rect.g_w = tree[obj].ob_width  + 16;
	rect.g_h = tree[obj].ob_height + 16;

	form_dial(FMD_START, &kl_rect, &rect);

	graf_mkstate( &ev );

	olditem   = NIL;
	founditem = item = objc_find(tree, obj, 1, ev.x, ev.y);	/* In Men ? */

	if (item != NIL)
		if ((tree[item].ob_state & DISABLED) || !(tree[item].ob_flags & SELECTABLE))
			item = NIL;

	if (item != NIL) tree[item].ob_state |= SELECTED;

	objc_draw(tree, obj, MAX_DEPTH, &rect);

	wind_update(BEG_MCTRL);								/* Ich will die Kontrolle */

	do
	{
		if (founditem != NIL)							/* In Meneintrag */
		{
			leave = TRUE;
			objc_rect (tree, founditem, &rect1);
		}
		else													/* Aužerhalb Pop-Up-Men */
		{
			leave = FALSE;
			objc_rect (tree, obj, &rect1);
		}

		graf_mkstate( &ev );

		if( !((ev.bstate) & 3) )
			bclicks = 258;
		else
			bclicks = 0;

		bmask = 3;
		bstate = 0;

		event = evnt_multi (	MU_KEYBD | MU_BUTTON | MU_M1,
									bclicks, bmask, bstate,
									leave, &rect1, 0, &kl_rect,
									NULL, 0, &ev, (int16 *)&uret, (int16 *)&ret);

		olditem   = item;

		if(!(event & MU_KEYBD))
		{
			founditem = item = objc_find (tree, obj, 1, ev.x, ev.y);

			if (item != NIL)
			{
			   if ((tree[item].ob_state & DISABLED) || !(tree[item].ob_flags & SELECTABLE))
			   	item = NIL;
			}
		}
		else
		{
			if((uret >> 8) == 80) /* Pfeil runter */
			{
				found = FALSE;
				while(!found)
				{
					item++;

					if((item < first_child) || (item > last_child))
					{
						item = first_child;
					}
				   if ((tree[item].ob_flags & SELECTABLE))
				   {
				   	if( tree[item].ob_state & DISABLED )
				   		found = FALSE;
				   	else
				   		found = TRUE;
				   }
				}
			}

			if((uret >> 8) == 72) /* Pfeil rauf */
			{
				found = FALSE;
				while(!found)
				{
					item--;

					if((item < first_child) || (item > last_child))
					{
						item = last_child;
					}
				   if ((tree[item].ob_flags & SELECTABLE))
				   {
				   	if( tree[item].ob_state & DISABLED )
				   		found = FALSE;
				   	else
				   		found = TRUE;
				   }
				}
			}
			if(((uret >> 8) == 28)||((uret >> 8) == 114))	/* Enter/Return */
				event = MU_BUTTON;

			if(((uret >> 8) == 01)||((uret >> 8) == 97))		/* Esc/UNDO */
			{
				item = NIL;
				event = MU_BUTTON;
			}
		}

		if (olditem != item)
		{
			if (olditem != NIL)
			{
				if(tree[olditem].ob_state & SELECTED)
					tree[olditem].ob_state &= ~SELECTED;
				else
					tree[olditem].ob_state |= SELECTED;
				objc_rect(tree, olditem, &rect2);
				objc_draw(tree, obj, MAX_DEPTH, &rect2);
			}

			if (item != NIL)
			{
				if(tree[item].ob_state & SELECTED)
					tree[item].ob_state &= ~SELECTED;
				else
					tree[item].ob_state |= SELECTED;
				objc_rect(tree, item, &rect2);
				objc_draw(tree, obj, MAX_DEPTH, &rect2);
			}
		}
	}	while (! (event & MU_BUTTON));

	wind_update(END_MCTRL);

	form_dial(FMD_FINISH, &kl_rect, &rect);

	if (item != NIL) tree[item].ob_state &= ~SELECTED;

	graf_mkstate( &ev );

	bclicks = 0;

	if (~ev.bstate & bmask)
		evnt_button (bclicks, bmask, 0x00, &ev);		/* Warte auf Mausknopf */

	return(item);
}
