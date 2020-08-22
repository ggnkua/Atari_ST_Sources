/****************************************************************************
 *																			*
 * 	CHK_SIGN.C																*
 *																			*
 *	Copyright 1991: Oliver Spornitz und Detlev Nolte						*
 *																			*
 *	Funktion: Die Cookie Jar Liste wird nach den Eintrag PIWOid durchsucht,	*
 *			  um festzustellen ob der PixelWonder Treiber installiert ist.	*
 *																			*
 ****************************************************************************/

#define PIWOid	0x5049574fL

typedef struct
{
	long id, val;
}
COOKIE;


/*
 * Function _checkinstall()
 *	Wird durch die Funktionen 'getres' und 'setres' (siehe PIWOBIND.S)
 *	aufgerufen.
 *	In der Cookie Jar Liste wird der Eintrag PIWOid gesucht.
 *	Return: -2 Treiber nicht installiert bzw. Cookie Jar Liste nicht vorhanden
 *			0  Treiber installiert
 */
long _checkinstall()
{
	COOKIE *cookie;
	int ncookie = 0;
	
	cookie = *(long *)0x5a0L;
	if(!cookie)
	{
		return(-2);
	}
	else
		/* sonst durchsuchen*/
		for(;((cookie->id) && (cookie->id != PIWOid));cookie++, ncookie++);
	
	/* Cookie zeigt auf PIWO-Cookie oder auf Null-Cookie */
	if(!cookie->id)	/* PIWO noch nicht installiert */
		return(-2);
	else 
		return(0);
}
	
