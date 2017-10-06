/***********************************************************************

	XFORM_DO.LIB - Demoprogramm
	
	Dieses Programm zeigt die richtige Installation und demonstriert den
	Gebrauch der Routinen der Bibliothek "XFORM_DO.LIB".
	
	Compiler: TURBO-C 2.0
	Bibliothek-Version: TC
	
	(C) by Michael Maier 1991

***********************************************************************/
#include <types.h>
#include <stdio.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>

/*** Prototypen, Strukturen und Konstanten von XFORM_DO.LIB einbinden ***/
#include "xform_do.h"

/*** Objektnummern der Resource-Datei ***/
#include "demo2.h"

/*

	Aufgepaût: Die Bibliothek benutzt eigene AES- und VDI-Parameter-
	blîcke und Felder, da die von TURBO C unbrauchbar sind!

	Deshalb muû die Adresse des Feldes "global" vor Gebrauch irgendeiner
	Funktion in den AES-Parameterblock eingetragen werden!

	Bei der DR-Version B wird angenommen, daû die Felder alle extern
	definiert sind!

*/

typedef struct
{
	WORD	tree;
	WORD	vor;
	WORD	opt;
	WORD	zur;
} OBJS;

#define NIL -1

OBJS baeume[7]=
	{
		{ EINF, VOR1, OPT1, NIL },
		{ HOTKEY1, VOR2, OPT2, ZUR2 },
		{ HOTKEY2, VOR3, OPT3, ZUR3 },
		{ BEISPIE1, VOR4, OPT4, ZUR4 },
		{ DEFAULT2, VOR5, OPT5, ZUR5 },
		{ RBCHK, VOR6, OPT6, ZUR6 },
		{ NOFLY, NIL, NIL, ZUR7 }
	};

/*

	globale Variabeln
	
*/
BOOLEAN	shrgrw = TRUE;
BOOLEAN	center = TRUE;

/*

	TEDINFO-String lîschen

*/
VOID clear(OBJECT *tree, WORD obj)
{
	tree[obj].ob_spec.tedinfo->te_ptext[0] = '\0';
}

VOID einstellung(UWORD x)
{
	OBJECT	*dialog;
	DIAINFO	info;
	WORD	ob;

	rsrc_gaddr(R_TREE, OPTION, &dialog);

	dialog[GRSHR].ob_state = shrgrw;
	dialog[CENTER].ob_state = center;

	dialog[HOTNONE].ob_state &= ~SELECTED;
	dialog[HOTCTRL].ob_state &= ~SELECTED;
	dialog[HOTALT].ob_state &= ~SELECTED;

	switch(aktivkom)
	{
		case 0: ob = HOTNONE; break;
		case K_CTRL: ob = HOTCTRL; break;
		case K_ALT: ob = HOTALT; break;
	}

	dialog[ob].ob_state |= SELECTED;

	if (x & 0x8000)
		dialog[DOPPEL].ob_state &= ~DISABLED;
	else
		dialog[DOPPEL].ob_state |= DISABLED;

	if (center)
		form_center(dialog, &ob, &ob, &ob, &ob);

	if (shrgrw)
		graf_growbox(max_w >> 2, max_h >> 2, gr_cw, gr_ch,
					 dialog->ob_x, dialog->ob_y, dialog->ob_width,
					 dialog->ob_height);

	open_dia(dialog, &info, FALSE);
	ob = xform_do(dialog, &info, 0) & 0x7FFF;
	dialog[ob].ob_state &= ~SELECTED;

	shrgrw = dialog[GRSHR].ob_state & SELECTED;
	center = dialog[CENTER].ob_state & SELECTED;

	if (dialog[HOTNONE].ob_state & SELECTED) aktivkom = 0;
	if (dialog[HOTCTRL].ob_state & SELECTED) aktivkom = K_CTRL;
	if (dialog[HOTALT].ob_state & SELECTED) aktivkom = K_ALT;

	if (shrgrw)
		graf_shrinkbox(max_w >> 2, max_h >> 2, gr_cw, gr_ch,
					 dialog->ob_x, dialog->ob_y, dialog->ob_width,
					 dialog->ob_height);

	clse_dia(dialog, &info);
} /* einstellung() */	

VOID automat(VOID)
{
	OBJECT	*dialog;
	DIAINFO	info1;
	WORD	x;
	WORD	ob;
	WORD	baum;
	WORD	xplanes = planes;
	BOOLEAN	wechsel = TRUE;
	BOOLEAN	ok = TRUE;

/* Nachricht ausgeben */
	rsrc_gaddr(R_TREE, RCSMSG, &dialog);
	form_center(dialog, &x, &x, &x, &x);
	open_dia(dialog, &info1, FALSE);
	xform_do(dialog, &info1, 0);
	clse_dia(dialog, &info1);

	baum = 0;
	while (ok)
	{
		if(wechsel)
		{
			rsrc_gaddr(R_TREE, baeume[baum].tree, &dialog);

			if (center)
				form_center(dialog, &x, &x, &x, &x);

			if (shrgrw)
				graf_growbox(max_w >> 2, max_h >> 2, gr_cw, gr_ch,
							 dialog->ob_x, dialog->ob_y, dialog->ob_width,
							 dialog->ob_height);

			if (baeume[baum].tree == NOFLY)
				planes = 1000;
			else
				planes = xplanes;

			open_dia(dialog, &info1, FALSE);
			
		}

		wechsel = TRUE;
		x = xform_do(dialog, &info1, 0);
		ob = x & 0x7FFF;
		dialog[ob].ob_state &= ~SELECTED;

		if (baeume[baum].tree == BEISPIE1)
			if (ob == SUCHE)
			{
				wechsel = FALSE;
				continue;
			}

		if (ob == baeume[baum].zur)
		{
			if (baum > 0)
				baum--;
		} else
		if (ob == baeume[baum].opt)
		{
			einstellung(x);
			objc_draw(dialog, ob, 1, 0, 0, max_w, max_h);
			wechsel = FALSE;
		} else
		if (ob == baeume[baum].vor)
		{
			if (baum < 7)
				baum++;
		} else
		if (baeume[baum].tree == NOFLY)
			ok = FALSE;

		if (wechsel)
		{
			if (shrgrw)
				graf_shrinkbox(max_w >> 2, max_h >> 2, gr_cw, gr_ch,
						 dialog->ob_x, dialog->ob_y, dialog->ob_width,
						 dialog->ob_height);

			clse_dia(dialog, &info1);
		}
	} /* while */
	   
} /* automat */

VOID do_center(OBJECT *tree, WORD ibox)
{
	tree[ibox].ob_y = (tree[tree[ibox].ob_next].ob_height - tree[ibox].ob_height) >> 1;
}

VOID main(VOID)
{
	OBJECT	*dialog;
	WORD	t;
	WORD	x;
	
	/* Applikation anmelden. Dabei wird das "global"-Feld gefÅllt! */
	appl_init();

	/* Wichtige Initialisierung, sonst klappt nix!
	   Dies gilt nur speziell fÅr TURBO C! Sind bei anderen Compilern die
	   Felder global definiert, so brauchen Sie nichts machen! */

	aes_pb[1] = _GemParBlk.global;
	
	if (open_res("DEMO2.RSC"))
	{
		if ( (max_w+1) / gr_cw < 80)
		{
			form_alert(1, "[3][| Programm lÑuft nicht in|    dieser Auflîsung!    | ][ Ok ]");
			clse_res();
			appl_exit();
			return;
		}

		aktivkom = K_ALT;
		half_on();

		for( t = EINF; t <= NOFLY; t++)
		{
			rsrc_gaddr(R_TREE, t, &dialog);
			fix_objs(dialog);
			form_center(dialog, &x, &x, &x, &x);
			switch(t)
			{
				case BEISPIE1:
					 clear(dialog, CLR1);
					 break;
				case HOTKEY1:
					 do_center(dialog, IBOX1);
					 break;
				case HOTKEY2:
					 do_center(dialog, IBOX2);
					 break;
			}
		}

		automat();

		clse_res();

	}

	appl_exit();
}