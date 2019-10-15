/*
	FLY-DEAL Version 3.0 fÅr TOS 12.07.1992
	written '92 by Axel SchlÅter

	Globale Strukturen fÅr die FLYdeals
*/

#define ERROR -1
#define ALLES_OK 0

typedef struct			/* Die Hauptvariable zum sichern aller ZustÑnde */
{
	char *old_pointer,
		 string[79];
	unsigned int old_type;
	void *ub_code;				/* frei verwendbare Variable (zB. */
}__saveall;						/* bei den Radios !!)             */

typedef struct			/* Die Infoscreen-Struktur fÅr BIGSCREEN's */ 
{
	long COOKIE,
		 PRODUCT;
	int  VERSION,
		 X,Y,W,H;
}INFOVSCR;

USERBLK flybuttons,		/* Die Userblk's fÅr die Buttons und Objecte */
		flyboxes,
		flytext,
		flymovebutt,
		flyradio,
		newmenu;

extern OBJECT fly_object[];						/* Alle globalen Variablen */
OBJECT *Sdial[MAX_DIALOG],*ALERT,*IMAGES;
int    DEFAULTbutt[MAX_DIALOG],MAXY,YAD=-1,VDI_ID,AES_ID,PLANES,
	   KeyObjecte[MAX_DIALOG][MAX_OBJECT],MOVENUM=0,VERZERRT=0,
 	   SButt[20][11],ENDRadio,NOWRadio,STATERadio,CNTRadio;
long   *LITTLEbuf;
__saveall SaveAll[MAX_DIALOG][MAX_OBJECT];