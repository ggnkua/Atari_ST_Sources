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
#include "demo3.h"

/*

	Aufgepaût: Die Bibliothek benutzt eigene AES- und VDI-Parameter-
	blîcke und Felder, da die von TURBO C unbrauchbar sind!

	Deshalb muû die Adresse des Feldes "global" vor Gebrauch irgendeiner
	Funktion in den AES-Parameterblock eingetragen werden!

	Bei der DR-Version B wird angenommen, daû die Felder alle extern
	definiert sind!

*/

VOID fill(OBJECT *tree, WORD obj, BYTE *format, WORD pos, WORD value)
{
	sprintf(&tree[obj].ob_spec.tedinfo->te_ptext[pos], format, value);
}

VOID main(VOID)
{
	OBJECT	*dialog;
	WORD	x;
	DIAINFO	info;
	
	/* Applikation anmelden. Dabei wird das "global"-Feld gefÅllt! */
	appl_init();

	/* Wichtige Initialisierung, sonst klappt nix!
	   Dies gilt nur speziell fÅr TURBO C! Sind bei anderen Compilern die
	   Felder global definiert, so brauchen Sie nichts machen! */

	aes_pb[1] = _GemParBlk.global;
	
	if (open_res("DEMO3.RSC"))
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

		rsrc_gaddr(R_TREE, AUSGABE, &dialog);
		fix_objs(dialog);
		form_center(dialog, &x, &x, &x, &x);

		fill(dialog, VHANDLE, "%2d", 9, vhandle);
		fill(dialog, GRRES, "%2d", 8, gr_res);
		fill(dialog, PLANES, "%2d", 8, planes);
		fill(dialog, GRCW, "%2d", 9, gr_cw);
		fill(dialog, GRBW, "%2d", 9, gr_bw);
		fill(dialog, AKTIV, "%4X", 10, aktivkom);
		fill(dialog, GRCH, "%2d", 8, gr_ch);
		fill(dialog, GRBH, "%2d", 8, gr_bh);
		fill(dialog, MAXH, "%4d", 7, max_h);
		fill(dialog, MAXW, "%4d", 7, max_w);

		open_dia(dialog, &info, FALSE);
		xform_do(dialog, &info, 0);
		clse_dia(dialog, &info);

		clse_res();

	}

	appl_exit();
}