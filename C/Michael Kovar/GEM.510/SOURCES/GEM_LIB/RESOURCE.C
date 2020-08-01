/* Resourcedatei-Routinen zur praktikablen Handhabung von Dialogboxen */
/* Erstellt in Mark Williams C Version 3.09 */
/* Letzte Bearbeitung am 04.02.1991 */
/* Resource Version 2.0 */

#include <obdefs.h>
#include <aesbind.h>
#include <gemdefs.h>
#include <vdibind.h>

#define ED_MERKER 0x200
#define DESK 0

extern char     *strcpy();


void set_flag(adr, objc, bit) /* Objekt-Flag setzen */
OBJECT *adr;
int     objc;
unsigned int bit;
{
	register OBJECT *ob;

        ob = (OBJECT *) (&adr[objc]);
        ob->ob_flags |= bit;
}

unsigned int is_flag(adr, objc, bit) /* Ist ein Objekt-Flag gesetzt? */
OBJECT *adr;
int     objc;
unsigned int bit;
{
	register OBJECT *ob;

        ob = (OBJECT *) (&adr[objc]);
        return(ob->ob_flags & bit);
}

void del_flag(adr, objc, bit) /* Lîscht ein Objekt-Flag */
OBJECT *adr;
int     objc;
unsigned int bit;
{
	register OBJECT *ob;

        ob = (OBJECT *) (&adr[objc]);
        ob->ob_flags &= (~bit);
}

void objc_position(tree, objc, a) /* ermittelt die Ausmaûe eines Objektes */
OBJECT	*tree;
int     objc;
Rect    *a;
{
	register OBJECT  *obj;

        objc_offset(tree, objc, &a->x, &a->y);
        obj = (OBJECT *) (&tree[objc]);
        a->w = obj->ob_width;
        a->h = obj->ob_height; 
        
}

void objc_update(adr, objc) /* Neuzeichnen eines (Teil)-Objektes */
OBJECT	*adr;
int     objc;
{
        Rect    r;

        objc_position(adr, objc, &r); /* Ausmaûe der Box ermitteln */
        objc_draw(adr, objc, MAX_DEPTH, r.x, r.y, r.w, r.h);
}

void hide(adr, objc) /* Objekt verstecken (auch editierbare) */
OBJECT	*adr;
int     objc;
{
        set_flag(adr, objc, HIDETREE);
        if(is_flag(adr, objc, EDITABLE))
        {
                set_flag(adr, objc, ED_MERKER);
                del_flag(adr, objc, EDITABLE);
        }
}

void unhide(adr, objc) /* Objekte sichtbar machen (auch editierbare) */
OBJECT	*adr;
int     objc;
{
        del_flag(adr, objc, HIDETREE);
        if(is_flag(adr, objc, ED_MERKER))
        {
                set_flag(adr, objc, EDITABLE);
                del_flag(adr, objc, ED_MERKER);
        }
}

unsigned int is_objc(tree, objekt, bit) /* Objektstatus abfragen */
OBJECT	*tree;
int     objekt;
unsigned int bit;
{
        register OBJECT  *obj;

        obj = (OBJECT *) (&tree[objekt]);

        return(obj->ob_state & bit);
}

void put_dialogtext(tree, objekt, inhalt) /* Editierbares Objekt beschreiben */
OBJECT	*tree;
int     objekt;
char    *inhalt;
{
        register OBJECT  *obj;
        register TEDINFO *ted;

        obj = (OBJECT *) (&tree[objekt]);
        ted = (TEDINFO *) (obj->ob_spec); /* Zeiger auf TEDINFO */

        strcpy(ted->te_ptext, inhalt); /* Eingabe kopieren */

}

void get_dialogtext(tree, objekt, inhalt) /* Editierbares Objekt auslesen */
OBJECT	*tree;
int     objekt;
char    *inhalt;
{
        register OBJECT  *obj;
        register TEDINFO *ted;

        obj = (OBJECT *) (&tree[objekt]);
        ted = (TEDINFO *) (obj->ob_spec); /* Zeiger auf TEDINFO */

        strcpy(inhalt, ted->te_ptext); /* Eingabe kopieren */

}

void delete_dialogtext(tree, objekt) /* Lîscht ein editierbares Objekt */
OBJECT	*tree;
int     objekt;
{
        register TEDINFO *ted;
        register OBJECT  *obj;
        register char    *zeichen;

        /* Zeiger auf Objektblock */

        obj = (OBJECT *) (&tree[objekt]);
        ted = (TEDINFO *) (obj->ob_spec); /* Zeiger auf TEDINFO */

        zeichen = (char *) (ted->te_ptext); /* Zeiger auf Text */
        *zeichen++ = '@'; /* Zeichenfeld lîschen */
        *zeichen = '\0';
}

void box_draw(tree, x, y, w, h) /* Zeichnet eine Dialogbox mittig auf Monitor */
OBJECT	*tree;
int     x, y, w, h;
{
        int     xdial, ydial, wdial, hdial;

        wind_update(BEG_UPDATE);
        form_center(tree, &xdial, &ydial, &wdial, &hdial);
        form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
        form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
        objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);
}

void box_undraw(tree, x, y, w, h) /* Lîscht eine Dialogbox vom Monitor */
OBJECT	*tree;
int     x, y, w, h;
{
        int     xdial, ydial, wdial, hdial;
        
        form_center(tree, &xdial, &ydial, &wdial, &hdial);
        form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);
        form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
        wind_update(END_UPDATE);
}

void do_objc(tree, which, bit) /* Setzt Objekt-Status */
OBJECT	*tree;
int     which;
unsigned int bit;
{
        register OBJECT *zeiger;

        /* Adresse des Objektes im Baum errechnen */
        zeiger = (OBJECT*) (&tree[which]);
        zeiger->ob_state |= bit;
}


void undo_objc(tree, which, bit) /* Lîscht Objekt-Status */
OBJECT	*tree;
int     which;
unsigned int bit;
{
        register OBJECT *zeiger;

        /* Adresse des Objektes im Baum errechnen */
        zeiger = (OBJECT*) (&tree[which]);
        zeiger->ob_state &= (~bit);
}

/* ####################################################################
 * Objekt ausgeben
 * Aufgabe: Objekt unter BerÅcksichtigung der Rechteckliste ausgeben
 * #################################################################### */

void	draw_deskobjc(tree,child)
int	child;
OBJECT	*tree;
{
	GRECT	a;

	/* Fenster einfrieren
	 * ------------------ */
	wind_update(BEG_UPDATE);

	/* Rechteckliste abarbeiten
	 * ------------------------ */
	wind_get(DESK,WF_FIRSTXYWH,&a.g_x,&a.g_y,&a.g_w,&a.g_h);
	while (a.g_w && a.g_h)
	{
		/* Objekt ausgeben
		 * --------------- */
		objc_draw(tree,child,MAX_DEPTH,a.g_x,a.g_y,a.g_w,a.g_h);
		
		/* NÑchstes Rechteck
		 * ----------------- */
		wind_get(DESK,WF_NEXTXYWH,&a.g_x,&a.g_y,&a.g_w,&a.g_h);
	}

	/* Fenster freigeben
	 * ----------------- */
	wind_update(END_UPDATE);

} /* ENDE: draw_deskobjc() */


/* ####################################################################
 * Objekt bewegen
 * Aufgabe: Objekt bewegen und Bereiche restaurieren
 * #################################################################### */

void	move_deskobjc(tree,child)
int		child;
OBJECT	*tree;
{
	int	x, y;
	GRECT	alt, neu, a;

	/* Objekt invertieren und ausgeben
	 * ------------------------------- */
	tree[child].ob_state |= SELECTED;
	draw_deskobjc(tree,child);

	/* Positon des Objektes und des Desktops bestimmen
	 * ----------------------------------------------- */
	objc_offset(tree,ROOT,&x,&y);		/* Offset berechnen		*/
	objc_offset(tree,child,&alt.g_x,&alt.g_y);
	wind_update(BEG_UPDATE);			/* Fenstererneuerung	*/
	wind_update(BEG_MCTRL);			/* Mauskontrolle		*/
	graf_mouse(FLAT_HAND,0L);		/* Maus auf flache Hand	*/

	/* Grîûe des Objektes merken
	 * ------------------------- */
	alt.g_w = tree[child].ob_width;
	alt.g_h = tree[child].ob_height;
	neu.g_w = alt.g_w;
	neu.g_h = alt.g_h;

	/* Objekt child innerhalb des Objekts ROOT bewegen
	 * ----------------------------------------------- */
	graf_dragbox(tree[child].ob_width,tree[child].ob_height,
			   alt.g_x,alt.g_y,x,y,
			   tree[ROOT].ob_width,tree[ROOT].ob_height,
			   &neu.g_x,&neu.g_y);

	/* Ende des Verschiebens
	 * --------------------- */
	graf_mouse(ARROW,0L);				/* Maus wieder Pfeil	*/
	wind_update(END_MCTRL);				/* keine Mauskontrolle	*/
	wind_update(END_UPDATE);				/* Ende Fenstererneuerung*/
	
	/* Objekt an alter Position lîschen
	 * -------------------------------- */
	tree[child].ob_flags |= HIDETREE;
/*	draw_deskobjc(tree, ROOT); */


	/* Fenster einfrieren
	 * ------------------ */
	wind_update(BEG_UPDATE);

	/* Rechteckliste abarbeiten
	 * ------------------------ */
	wind_get(DESK,WF_FIRSTXYWH,&a.g_x,&a.g_y,&a.g_w,&a.g_h);
	while (a.g_w && a.g_h)
	{
		/* Objekt ausgeben
		 * --------------- */
		if(rc_intersect(&alt, &a))
			objc_draw(tree,ROOT,MAX_DEPTH,a.g_x,a.g_y,a.g_w,a.g_h);
		
		/* NÑchstes Rechteck
		 * ----------------- */
		wind_get(DESK,WF_NEXTXYWH,&a.g_x,&a.g_y,&a.g_w,&a.g_h);
	}

	/* Fenster freigeben
	 * ----------------- */
	wind_update(END_UPDATE);

	
	/* Objekt an neuer Position darstellen
	 * ----------------------------------- */
	tree[child].ob_x += neu.g_x - alt.g_x;	/* Neue Position	*/
	tree[child].ob_y += neu.g_y - alt.g_y;
	tree[child].ob_flags &= ~HIDETREE; 
	undo_objc(tree, child, SELECTED);
	draw_deskobjc(tree,child);

} /* ENDE: move_deskobjc() */

