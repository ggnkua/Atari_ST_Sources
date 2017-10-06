/* ------------------------------------------------------------------------- */
/* ----- Let 'em Fly! Library -------------- (c) 1991 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */

#include <tos.h>
#include <aes.h>
#include "ltmf_lib.h"

/* ------------------------------------------------------------------------- */

#define NULL	((void *) 0l);

LTMFLY	*letemfly = NULL;

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

	sav = Super(0l);
	cookiejar = *((COOKJAR **)0x05a0l);
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
	return(0);
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
	return(letemfly && (letemfly->version >= version));
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
		return(0);
}

/* ------------------------------------------------------------------------- */
/* ----- lookup_key -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/*
**	int lookup_key(int key, int kbshift)
**
**	Funktion:	Gibt zu einer Taste das entsprechende Objekt zurck.
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
		return(0);
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
		return(1);
	}
	else
		return(0);
}
