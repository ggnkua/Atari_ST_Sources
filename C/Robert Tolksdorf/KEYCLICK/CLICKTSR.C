/*************************************************
*	CLICKTSR.C
*
*	Residenter Teil von KeyClick
*
*	1991 by Robert Tolksdorf 
*
*	Geschrieben mit TURBO-C V2.0 mit MAS-68K 
*
*************************************************/

/************************************************
 * TOS-Definitionen
 */
#include <tos.h>
#include <stdlib.h>

#include "keyclick.h"

/************************************************
 *	In CLICKHAN.S definiert
 */
extern void my_kbdsys(),
			my_aes(),
			my_gemdos(),
			my_bios(),
			(*aes_save)();
extern void *XB_KBDSYS,
			*XB_AES,
			*XB_GEMDOS,
			*XB_BIOS;

KCC		kc;

/***********************************************
 * Zeiger auf fr uns wichtige Felder des 
 * Iorec-Structure. Damit der Interrupt-Handler
 * m”glichst schnell ist, werden sie
 * direkt vermerkt.
 */
IOREC		*kbiorec;
int			*iotail,
			*iohead,
			*iosize;
char		*iobuf,
			*kbshift;	/* Zeiger auf kb_shift */
char 		c;
SYSHDR		*rom_start;
long		stackcorr;
long		super_stack;

KBDVBASE *kbdvb;


/**********************************************
*
*	handle_ikbd()
*
*	Der eigentliche Interrupt-Handler fr die
*	šberprfung eines Tastendrucks. Wird direkt
*	vom Handler in KEYHANDL.S aufgerufen.
*/

void handle_ikbd(void)
{
	/* Scancode des Tastendrucks am Ende
	   des Puffers auslesen */
	c=iobuf[(*iotail)+1];
	if ((kc.klickon) &&
			/* liegt ein Tastendruck vor ? */
		(*iohead!=*iotail) &&
		 	/* eine Fenstertaste ? */
		(((c>=KEY_LBRACE) && (c<=KEY_ENTER)) ||
		 (c==KEY_PLUS) || (c==KEY_MINUS)) &&
			/* ist Platz im Puffer ? */
		(((kc.windex+1) & (BUFFERSIZE-1)) != kc.rindex) &&
			/* Falls gewnscht auf <Alt> achten */
		((kc.watchalt) ? (*kbshift & 8) : 1 ))
	{
		/* Scancode in Puffer kopieren */
		kc.scans[kc.windex++]=c;
		kc.windex&=BUFFERSIZE-1;
		/* Tastendruck aus Iorec-Puffer nehmen */
		*iotail=(*iotail-4) % *iosize;
	}
}

void init(void)
{
	/* Informationen ber Iorec
	   der Tastatur bernehmen */
	kbiorec=Iorec(1);
	iotail=&kbiorec->ibuftl;
	iohead=&kbiorec->ibufhd;
	iosize=&kbiorec->ibufsiz;
	iobuf =kbiorec->ibuf;
	/* KeyClick in kbdsys() installieren */
	/* Alten Vektor XBRA-konform merken */
	aes_save=my_aes;
	kbdvb=Kbdvbase();
	XB_KBDSYS=kbdvb->kb_kbdsys;
	kbdvb->kb_kbdsys=my_kbdsys;
	XB_GEMDOS=Setexc(33,my_gemdos);
	XB_BIOS  =Setexc(45,my_bios);
	XB_AES   =Setexc(34,my_aes);
	kc.installed=1;
}

/* Cookie-Jar einrichten, Zeiger auf
   ersten Cookie abliefern */
COOKIE *install_cookie_jar(long n)
{
	COOKIE	*cookie;
	
	cookie=Malloc(sizeof(COOKIE)*n);
	Super(0L);
	*(long *)0x5A0L=cookie;
	Super((void *) super_stack);
	cookie->id=0L;
	cookie->val=n;
	return (cookie);
}

/*************************************************
*
*	main()
*
*/

void main()
{
	char	*l1		=	"\r\n\x1Bp        KeyClick-TSR V0        \x1Bq\r\n" \
						"(C) 1991 by Robert Tolksdorf\r\n" \
						"Public Domain -- No warranty\r\n\n";
	char	*l2		=	"Already ";
	char	*l3		=	"Installed\r\n\n";

	SYSHDR		*SysHeader;
	long		jarsize,Stack;
	int			ncookie = 0,i;
	COOKIE		*cookie,*cookieo;
	
	Cconws(l1);
	/* Adress von kbshift ermitteln, in der
	   der Zustand von <Alternate> vermerkt ist;
	    da im Systembereich im Super-Modus */
	Stack=Super(0L);
	SysHeader=*(long *)0x4F2L;
	kbshift=(char *)SysHeader->kbshift;
	cookie=cookieo= *(long *)0x5A0L;
	rom_start=SysHeader->os_base;
	stackcorr = (*(int *)0x59EL) ? 8 : 6 ;
	Super((void *)Stack);
	/* Kein Cookie-Jar vorhanden -> neuen einrichten */
	if (!cookie)
		cookie=install_cookie_jar(8L);
	else
		/* sonst durchsuchen */
		for (;((cookie->id) && (cookie->id!=COOKIEID));
			 cookie++, ncookie++);
	/* cookie zeigt auf Keyclick- oder Null-Cookie */
	if (!cookie->id)	
	{
		/* KEYCLICK noch nicht installiert */
		/* Ist noch Platz ??  */
		if (cookie->val<=ncookie)
		{
			/* nein -> neuen einrichten, alten kopieren */
			cookie=install_cookie_jar(cookie->val+8L);
			for (;cookieo->id!=0L; (*cookie++)=(*cookieo++));
			cookie->id=0L;
			cookie->val=cookieo->val+8L;
		}
		/* Cookie hinterlassen */
		jarsize=cookie->val;
		cookie->id=COOKIEID;
		cookie++->val=&kc;
		cookie->id=0L;
		cookie->val=jarsize;
		kc.init=init;
		kc.windex=
		kc.rindex=
		kc.watchalt=
		kc.installed=
		kc.klickon=0;
		for (i=0; i<WINDOWMAX; kc.id[i++]=-1);
		/* "Installiert"-Meldung */
		Cconws(l3);
		/* Und resident im Speicher bleiben */
		Ptermres(_PgmSize,0);
	}
	else
	{
		/* "Already Installed" melden */
		Cconws(l2);
		Cconws(l3);
		/* Mit Fehlercode enden */
		exit(1);
	}

}
/* Ende von KEYCLICK.C */

