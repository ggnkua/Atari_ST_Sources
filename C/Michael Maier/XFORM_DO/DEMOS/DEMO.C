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

/*** Prototypen, Strukturen und Konstanten von XFORM_DO.LIB einbinden ***/
#include "xform_do.h"

/*** Objektnummern der Resource-Datei ***/
#include "demo.h"

/*

	Aufgepažt: Die Bibliothek benutzt eigene AES- und VDI-Parameter-
	bl”cke und Felder, da die von TURBO C unbrauchbar sind!

	Deshalb muž die Adresse des Feldes "global" vor Gebrauch irgendeiner
	Funktion in den AES-Parameterblock eingetragen werden!

	Bei der DR-Version B wird angenommen, daž die Felder alle extern
	definiert sind!

*/

VOID dial_alt(WORD t)
{
	WORD	x;
	DIAINFO	info;
	OBJECT	*tree;

	rsrc_gaddr(R_TREE, t, &tree);

	form_center(tree, &x, &x, &x, &x);

	open_dia(tree, &info, FALSE);
	xform_do(tree, &info, 0);
	clse_dia(tree, &info);

} /* dial_alt() */

VOID dial_neu(WORD t)
{
	DIAINFO	info;
	OBJECT	*tree;

	rsrc_gaddr(R_TREE, t, &tree);

	open_dia(tree, &info, TRUE);
	xform_do(tree, &info, 0);
	clse_dia(tree, &info);

} /* dial_neu() */

VOID clear(OBJECT *tree, WORD obj)
{
	tree[obj].ob_spec.tedinfo->te_ptext[0] = '\0';
}

/***

	Farbe des HOTKEYs „ndern!

***/
VOID hotkeyfarbe(WORD farbe)
{
	LONG	x;
	x = hotkeybl.ub_parm & 0xFFFF0FFFL;
	x |= ((LONG)farbe) << 12;
	hotkeybl.ub_parm = x;
} /* hotkeyfarbe() */

/***

	Farbe des CHECK-Schalters „ndern!

***/
VOID checkfarbe(WORD farbekreuz, WORD farberahmen)
{
	LONG	x;

	x = hotkeybl.ub_parm & 0xFFFF00FFL;
	x |= (((LONG)farberahmen) << 12) | (((LONG)farbekreuz) << 8);
	checkblk.ub_parm = x;
} /* checkfarbe() */


VOID main(VOID)
{
	OBJECT	*dialog;
	WORD	t;
	WORD	dhires;
	
	/* Applikation anmelden. Dabei wird das "global"-Feld gefllt! */
	appl_init();

	/* Wichtige Initialisierung, sonst klappt nix!
	   Dies gilt nur speziell fr TURBO C! Sind bei anderen Compilern die
	   Felder global definiert, so brauchen Sie nichts machen! */

	aes_pb[1] = _GemParBlk.global;
	
	if (open_res("DEMO.RSC"))
	{
		if ( (max_w+1) / gr_cw < 80)
		{
			form_alert(1, "[3][| Programm l„uft nicht in|    dieser Aufl”sung!    | ][ Ok ]");
			clse_res();
			appl_exit();
			return;
		}

		for (t = TEXT1; t <= HOTKEY1; t++)
		{
			rsrc_gaddr(R_TREE, t, &dialog);
			if (t == GRAFIK2)
			{
				dhires = gr_res;
				gr_res  = FALSE;
				half_on();
				fix_objs(dialog);
				gr_res = dhires;
				half_off();
				continue;
			}

			fix_objs(dialog);
			switch(t)
			{
				case TEXT2: clear(dialog, CLR1); break;
				case TEXT3: clear(dialog, CLR2); break;
				case HOTKEY2: clear(dialog, CLR3); break;
				case ALL: clear(dialog, CLR4);
						  clear(dialog, CLR5); break;
				case ALL2:
					 if (planes != 1)
					 {
					 	dialog[FARBE1].ob_flags |= HIDETREE;
					 	dialog[FARBE2].ob_flags |= HIDETREE;
					 }
					 break;
			} /* of switch */
		} /* of for */

		aktivkom = 0;
		half_on();

		hotkeyfarbe(1);
		dial_alt(GRAFIK1);
		hotkeyfarbe(2);
		dial_alt(GRAFIK2);

		hotkeyfarbe(3);
		dial_alt(TEXT1);
		hotkeyfarbe(1);
		dial_alt(TEXT2);
		hotkeyfarbe(2);
		dial_alt(TEXT3);

		hotkeyfarbe(3);
		dial_neu(FLY);

		hotkeyfarbe(1);
		dial_neu(HOTKEY1); aktivkom = K_ALT;
		hotkeyfarbe(2);
		dial_neu(HOTKEY2);

		hotkeyfarbe(3);
		dial_neu(ALL);
		hotkeyfarbe(2);
		dial_neu(ALL2);

		hotkeyfarbe(3);
		dial_neu(ENDE);

		clse_res();

	}

	appl_exit();
}