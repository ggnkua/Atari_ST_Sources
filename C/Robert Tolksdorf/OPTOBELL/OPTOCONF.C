/* OPTOCONF.C
 *
 * Accessory zum Konfigurieren von OptoBell
 *
 * Geschrieben mit TC 2.0 und MAS
 *
 * 1991 by Robert Tolksdorf
 * (C) ST-Computer
 */

/************************************************
 * TOS-, AES-Definitionen
 */
#include <aes.h>
#include <tos.h>

/************************************************
 * Die Definitionen zur Kommunikation
 */
#include "optobell.h"

/* Texte fÅr MenÅ und Alert	*/
#define MENUTITLE	"  OptoConv"
#define CONFALERT	"[2][Welche OptoBell-Einstellung?]" \
					"[Blink|Blink+Bell|Bell]"

long	super_stack;
int		*OptoConf;

void main(void)
{
	COOKIE	*cookie;
	int		applid,
			message[8],
			defbtn;
		
	applid=appl_init();
	/* Systemvariablen lesen */
	super_stack=Super(0L);
	cookie= *(long *)0x5A0L;
	Super((void *) super_stack);
	/* Kein Cookie-Jar vorhanden -> neuen einrichten */
	if (cookie)
	{
		/* durchsuchen */
		for (;((cookie->id) && (cookie->id!=OPTOID));cookie++);
		/* cookie zeigt auf RTOB-Cookie oder Null-Cookie */
		if (cookie->id)	/* OptoBell installiert */
		{
			OptoConf=cookie->val;
			menu_register(applid, MENUTITLE);
			/* Hauptschleife, wartet auf Aufruf 
			   und stellt Konfigurations-Dialog dar */ 
			do
			{
				/* Aktuelle Einstellung als
				   Default-Button */
				switch (*OptoConf)
				{
					case O_BLINK:
						defbtn=1;
						break;
					case O_BLINKBELL:
						defbtn=2;
						break;
					case O_BELL:
						defbtn=3;
						break;
				}
				/* Auf AC_OPEN-Mitteilung warten */
				evnt_mesag(message);
				if (message[0]==AC_OPEN)
					/* Kleinen Dialog mit Alert-Box durchfÅhren */
					switch (form_alert(defbtn,CONFALERT))
					{
						/* Button Blink */
						case 1:	*OptoConf=O_BLINK;
								break;
						/* Button Blink+Bell */
						case 2:	*OptoConf=O_BLINKBELL;
								break;
						/* Button Bell */
						case 3:	*OptoConf=O_BELL;
								break;
					}
			} while(1);
			/* Old Accessories never die -
			   they just loop again */
		}
	}
	/* Kommt nur dann hierher, wenn kein Cookie-Jar
	   oder kein OptoBell							*/
	form_alert(1,"[3][Ohne den residenten|"\
					"Teil in OPTOBELL.PRG|"\
					"kann OptoConv nicht|"\
					"arbeiten][Abbruch]");
	do
		evnt_mesag(message);
	while(1);
}
/* Ende von OPTOCONF.C */
