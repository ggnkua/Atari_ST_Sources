/*******************************************************************
*
* Dieses Beispielprogramm demonstriert den Gebrauch scrollender
* Eingabefelder in MagiC 3.
*
*******************************************************************/

#include <aes.h>
#include <tos.h>
#include <string.h>
#include <magx.h>
#include "magxlib.h"
#include "edscroll.h"

#define TLEN	30


int  do_dialog    (OBJECT *dialog);

void main()
{
	OBJECT *adr_dialog;
	ULONG crdate;
	int is_scroll;

	XTED xted;
	char tmplt[TLEN+1],txt[TLEN+1];



	/* Feststellen, ob das System Scrolledit kann */
	/* ------------------------------------------ */

	is_scroll = ((0 < get_MagiC_ver(&crdate)) &&
		(crdate >= 0x19950829L));

     /* Applikation beim AES anmelden */
     /* ----------------------------- */

     if   (appl_init() < 0)
          Pterm(1);

     /* Resourcedatei laden */
     /* ------------------- */
     if   (!rsrc_load("edscroll.rsc"))
          {
          form_alert(1, "[3][Kann \"EDSCROLL.RSC\"|nicht finden][Abbruch]");
          goto err;
          }

     rsrc_gaddr(0, EDIT, &adr_dialog);

	/* Scroll-TEDINFO initialisieren */
	/* ----------------------------- */

	init_scrlted(adr_dialog+EDITTXT, is_scroll, &xted,
				txt, tmplt, TLEN);

	strcpy(txt, "Beispiel");

	/* Dialog */
	/* ------ */

     wind_update(BEG_MCTRL);
     graf_mouse(ARROW, 0L);
     do_dialog(adr_dialog);
     wind_update(END_MCTRL);
     rsrc_free();

	err:
     appl_exit();
     Pterm0();
}


/****************************************************************
*
* do_dialog
*
****************************************************************/

int do_dialog(OBJECT *dialog)
{
     int cx, cy, cw, ch;
     int exitbutton;


     form_center(dialog, &cx, &cy, &cw, &ch);
     form_dial(FMD_START, 0,0,0,0, cx, cy, cw, ch);
     objc_draw(dialog, ROOT, MAX_DEPTH, cx, cy, cw, ch);
     exitbutton = 0x7f & form_do(dialog, 0);
     form_dial(FMD_FINISH, 0,0,0,0,cx, cy, cw, ch);
     return(exitbutton);
}
