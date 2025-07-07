/* ------------------------------------------------------------------------- */
/* ----- Let 'em Fly! Library -------------- (c) 1991 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */

#include <tos.h>
/* #include <aes.h> */
#include <vdi.h>
#include "ltmf_lib.h"

/* ------------------------------------------------------------------------- */

int cdecl draw_fly(PARMBLK *pblock);

/* ------------------------------------------------------------------------- */

#define NULL	((void *) 0l);
#define FALSE	0
#define TRUE	(!FALSE)

LTMFLY	*letemfly = NULL;

USERBLK	fly_button = {	draw_fly,
			0l };

int	wk_handle;

/* ----- Cookie Jar -------------------------------------------------------- */

typedef struct {
		long	id,
			*ptr;
		} COOKJAR;

/* ------------------------------------------------------------------------- */
/* ----- get_cookie -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

long *get_cookie(long cookie)
{
	long	sav;
	COOKJAR	*cookiejar;
	int	i = 0;

	sav = Super((void *)1L);
	if(sav == 0L)
		sav = Super(0L);
	cookiejar = *((COOKJAR **)0x05a0l);
	if(sav != -1L)
		Super((void *)sav);
	if(cookiejar)
	{
		while(cookiejar[i].id)
		{
			if(cookiejar[i].id == cookie)
				return(cookiejar[i].ptr);
			i++;
		}
	}
	return(0l);
}

/* ------------------------------------------------------------------------- */
/* ----- ltmf_check -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int ltmf_check(unsigned int version)
**
**	Funktion:	Checkt, ob Let 'em Fly! installiert ist und ob es
**			die Mindest-Versionsnummer besitzt.
**
**	Parameter:	version	Enh„lt die zu prfende Versionsnummer
**				(es wird ein '>='-Test gemacht!!)
**
**	Return:		TRUE	Let 'em Fly! ist installiert und
**				die Versionsnummer ist ok.
**			FALSE	Entweder nicht installiert oder zu
**				niedrige Versionsnummer.
**
** ------------------------------------------------------------------------- */

int ltmf_check(unsigned int version)
{
	if(!letemfly)
		letemfly = (LTMFLY *)get_cookie('LTMF');
	if(letemfly && (letemfly->version >= version))
		return(TRUE);
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- di_fly ------------------------------------------------------------ */
/* ------------------------------------------------------------------------- */
/*
**	int di_fly(OBJECT *tree)
**
**	Funktion:	L„žt Dialoge fliegen ...
**
**	Parameter:	*tree	Enth„lt die Adresse des Objekt-Baums
**				der fliegen soll.
**
**	Return:		TRUE	Let 'em Fly! ist installiert.
**			FALSE	Let 'em Fly! ist NICHT installiert.
**
** ------------------------------------------------------------------------- */

int di_fly(OBJECT *tree)
{
	if(ltmf_check(0x0100))
		letemfly->di_fly(tree);
	return(letemfly != 0l);
}

/* ------------------------------------------------------------------------- */
/* ----- obj_clsize -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int obj_clsize(OBJECT *tree, int obj, int *x, int *y, int *w, int *h)
**
**	Funktion:	Berechnet die ECHTEN Ausmaže eines Objekts, d.h.
**			auch SHADOWED-Objekte werden korrekt behandelt.
**
**	Parameter:	*tree	Enth„lt die Adresse des Objekt-Baums ...
**			obj	und hier die entsprechende Objekt-Nr.
**			*x, *y,	In diesen Variablen steht dann das Ergebnis.
**			*w, *h
**
**	Return:		siehe di_fly()
**
** ------------------------------------------------------------------------- */

int obj_clsize(OBJECT *tree, int obj, int *x, int *y, int *w, int *h)
{
	if(ltmf_check(0x0110))
		letemfly->obj_clsize(tree, obj, x, y, w, h);
	return(letemfly != 0l);
}

/* ------------------------------------------------------------------------- */
/* ----- init_keys --------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int init_keys(OBJECT *tree)
**
**	Funktion:	Weist den Objekten ein Tastenkrzel zu (initialisert
**			also die interne Tabelle) und malt den Strich. Die
**			Funktion wird durch den Schalter 'Key Dials' und die
**			ExObTypes beeinflužt!
**
**	Parameter:	*tree	Enth„lt die Adresse des entsprechenden
**				Object-Baums.
**
**	Return:		TRUE	Key Dials aktiv, k”nnen also angesprochen
**				werden.
**			FALSE	Key Dials inaktiv.
**
** ------------------------------------------------------------------------- */

int init_keys(OBJECT *tree)
{
	if(ltmf_check(0x0113))
		return(letemfly->init_keys(tree));
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- lookup_key -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int lookup_key(int key, int kbshift)
**
**	Funktion:	Gibt zu einer Taste das entsprechende Objekt zurck.
**			Darf nur benutzt werden, wenn init_keys() TRUE
**			zurckgeliefert hat.
**
**	Parameter:	key	Enth„lt den ASCII/Scancode der Taste. Ist
**				identisch mit dem von evnt_keybd().
**			kbshift	Enth„lt den Shift-Status (siehe evnt_button()).
**
**	Return:		Objekt-Nr. bzw. 0 falls kein Objekt zugewiesen werden
**			konnte.
**
** ------------------------------------------------------------------------- */

int lookup_key(int key, int kbshift)
{
	if(ltmf_check(0x0113))
		return(letemfly->lookup_key(key, kbshift));
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- set_do_key -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int set_do_key(void (*key_handler)())
**
**	Funktion:	Installiert einen zus„tzlichen Key-Handler
**			fr form_do().
**
**	Parameter:	key_handler	Enth„lt die Adresse der Funktion des
**					Key-handlers.
**
**	Return:		TRUE	Handler konnte installiert werden.
**			FALSE	Handler konnte nicht installiert werden.
**
** ------------------------------------------------------------------------- */

int set_do_key(int cdecl (*key_handler)())
{
	if(ltmf_check(0x0112))
	{
		letemfly->do_key = key_handler;
		return(TRUE);
	}
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- di_moveto --------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int di_moveto(OBJECT *tree, int x, int y)
**
**	Funktion:	Bewegt eine Dialogbox zu einer bestimmten Position.
**
**	Parameter:	*tree	Der Objektbaum
**			x, y	Die Zielkoordinaten. Wird fr x -1 bergeben,
**				so wird nur geprft, ob der Dialog flugf„hig
**				ist. Bei x = -2 wird gesagt, ob ein Redraw
**				gesendet wird oder nicht.
**
**	Return:		0	Box kann bzw. konnte nicht fliegen.
**			1	Box ist uneingeschr„nkt flugf„hig.
**			2	Box fliegt nur im Sparmodus.
**
** ------------------------------------------------------------------------- */

int di_moveto(OBJECT *tree, int x, int y)
{
	if(ltmf_check(0x0115))
		return(letemfly->di_moveto(tree, x, y));
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- di_center --------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int di_center(OBJECT *tree)
**
**	Funktion:	Zentriert einen auf dem Bildschirm befindlichen
**			Dialog („hnlich di_moveto(), jedoch mit ausgerechneten
**			Werten).
**
**	Parameter:	*tree	Der zu zentrierende Objektbaum bzw. Dialog
**
**	Return:		siehe di_moveto()
**
** ------------------------------------------------------------------------- */

int di_center(OBJECT *tree)
{
	if(ltmf_check(0x0117))
		return(letemfly->di_center(tree));
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- ins_spcchar ------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int ins_spcchar(void)
**
**	Funktion:	Bearbeitet eine Auswahlbox fr die blen Zeichen.
**
**	Parameter:	keine
**
**	Return:		Das ausgew„hlte Zeichen (0 fr keine Auswahl)
**
** ------------------------------------------------------------------------- */

int ins_spcchar(void)
{
	if(ltmf_check(0x0115))
		return(letemfly->ins_spcchar());
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- hist_insert ------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int hist_insert(char *string)
**
**	Funktion:	Fgt einen String in die History ein.
**
**	Parameter:	string	Der einzufgende String.
**
**	Return:		TRUE	String wurde eingefgt.
**			FALSE	String wurde nicht eingefgt.
**
** ------------------------------------------------------------------------- */

int hist_insert(char *string)
{
	if(ltmf_check(0x0116))
		return(letemfly->hist_insert(string));
	else
		return(FALSE);
}

/* ------------------------------------------------------------------------- */
/* ----- init_flyobj ------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int init_flyobj(OBJECT *tree)
**
**	Funktion:	Initialisiert das Flug-Objekt. Es wird dann durch
**			eine Verschiebeecke ersetzt. Der Objektbaum muž
**			mindestens zwei Objekte (ROOT + 1) enthalten.
**			Die Flugecke wird nur bei installiertem Let 'em Fly!
**			initialisiert. Zu beachten ist, daž ein Flugobjekt
**			erst ab Version 1.15 explizit untersttzt wird.
**
**	Parameter:	Objektbaum, in dem das Flugobjekt enthalten ist.
**
**	Return:		TRUE	Es existiert ein Flugobjekt.
**			FALSE	Es existiert kein Flugobjekt.
**
** ------------------------------------------------------------------------- */

int init_flyobj(OBJECT *tree)
{
	OBJECT	*tr;
	int	obj;
	int	d;

	ltmf_check(0x0100);	/* init 'letemfly' */
	if((tree[ROOT].ob_type & 0xff00) == 0x8900)	/* Magic? */
	{
		obj = 1;	/* ROOT Objekt geht nicht */
		do
		{
			tr = &tree[obj];
			if(tr->ob_type & 0x4000)	/* Flug-Objekt? */
			{
				tr->ob_type &= 0xff00;
				tr->ob_type |= G_USERDEF;
				tr->ob_spec.userblk = &fly_button;
				wk_handle = graf_handle(&d, &d, &d, &d);
				return(TRUE);
			}
		}
		while(!(tree[obj++].ob_flags & LASTOB));
	}
	return(FALSE);
}


int cdecl draw_fly(PARMBLK *pblock)
{
	int	attrib[8],
		pxy[8];
	int	off;

	/* an dieser Stelle u.U. Register sichern */

	if(letemfly && !letemfly->config.bypass && letemfly->config.fly)
	{
		vql_attributes(wk_handle, attrib);	/* Attribute sichern */

		vswr_mode(wk_handle, MD_REPLACE);
		pxy[0] = pblock->pb_xc;			/* Clipping einstellen */
		pxy[1] = pblock->pb_yc;
		pxy[2] = pblock->pb_xc + pblock->pb_wc - 1;
		pxy[3] = pblock->pb_yc + pblock->pb_hc - 1;
		vs_clip(wk_handle, 1, pxy);

		off = (pblock->pb_tree[pblock->pb_obj].ob_state & OUTLINED) ? 3 : 0;

		vsl_color(wk_handle, 0);
		vsl_width(wk_handle, 3);
		vsl_type(wk_handle, 1);
		pxy[0] = pxy[2] = pblock->pb_x - off + 1;
		pxy[1] = pblock->pb_y;
		pxy[3] = pxy[5] = pblock->pb_y + pblock->pb_h + off - 2;
		pxy[4] = pblock->pb_x + pblock->pb_w - 1;
		v_pline(wk_handle, 3, pxy);

/*		vsl_color(wk_handle, pblock->pb_tree[pblock->pb_obj].ob_spec.obspec.framecol);
*/		vsl_color(wk_handle, 1);
		vsl_width(wk_handle, 1);

		pxy[0] = pxy[2] = pblock->pb_x + 3 - off;
		pxy[1] = pblock->pb_y;
		pxy[3] = pxy[5] = pblock->pb_y + pblock->pb_h - 4 + off;
		pxy[4] = pblock->pb_x + pblock->pb_w - 1;
		v_pline(wk_handle, 3, pxy);

		pxy[0] = pxy[2] = pblock->pb_x - off;
		pxy[1] = pblock->pb_y - off;
		pxy[3] = pxy[5] = pblock->pb_y + pblock->pb_h + off - 1;
		pxy[4] = pblock->pb_x + pblock->pb_w - 1 + off;
		v_pline(wk_handle, 3, pxy);

		pxy[0] = pblock->pb_x - off;
		pxy[1] = pblock->pb_y - off;
		pxy[2] = pblock->pb_x + pblock->pb_w + off - 1;
		pxy[3] = pblock->pb_y + pblock->pb_h + off - 1;
		v_pline(wk_handle, 2, pxy);

		vsl_type(wk_handle, attrib[0]);
		vsl_color(wk_handle, attrib[1]);
		vsl_width(wk_handle, attrib[3]);
		vswr_mode(wk_handle, attrib[2]);
	}
	/* an dieser Stelle die Register u.U. wieder herstellen */
	return(NONE);		/* nix mehr malen */
}
