/*
	CAPSLOCK - CapsLock-Anzeige
		
	(C) Robert Tolksdorf  K”rtestr. 30  1000 Berlin 61
	
*/

#include <tos.h>
#include <linea.h>

char	*kbshift,	/* Zeiger auf kb_shift */
		*l[4];		/* Zeiger auf Bildschirmspeicher */

/* Die Bitmuster fr das K„stchen */

#define on	30	/* ---XXXX- */
#define off	18	/* ---X--X- */

/* Die VBL-Routine */
void capsvbl()
{
	*l[0] = *l[0] | on;
	*l[1] = (*l[1] & (255-on)) | ((*kbshift & 16) ? on : off);
	*l[2] = (*l[2] & (255-on)) | ((*kbshift & 16) ? on : off);
	*l[3] = *l[3] | on;
}

main()
{
	SYSHDR	*SysHead;
	long	SuperStack;
	long	*vbl;
	int		i;
	char	*mess[3]=	{	"\x1Bp   CAPSLOCK-Display V 1.0   \x1Bq\r\n" \
					 		"(C) 1990 by Robert Tolksdorf\r\n"\
					   		"Public domain -- No warranty\r\n",
							"Installed\r\n\n",
							"Not installed (no free VBL-Slot)\r\n\n"};
	
	/* erstmal melden */
	Cconws(mess[0]);
	/* Bildschirmadressen rechts oben ermitteln */
	linea_init();
	l[0]=Logbase();
	l[0]=l[0]+(long)(Vdiesc->v_rez_hz/8)-1+
	   (long)Vdiesc->bytes_lin;
	for (i=1; i<=3; i++)
		l[i]=l[i-1]+(long)Vdiesc->bytes_lin;
	/* Adresse von kb_shift auslesen */
	SuperStack=Super(0L);
	SysHead=*(long *)0x4F2L;
	kbshift=SysHead->kbshift;
	/* VBL installieren, also NULL-Zeiger suchen */
	i=1;
	for (vbl=*(long *)0x456L, vbl++; (i<(int)0x454L) && (*vbl!=0L);
		 (long)vbl++, i++);
	/* War ein Slot frei ? */
	if (i<(int)0x454L)
	{
		/* VBL installieren */
		*vbl=capsvbl;
		Super((void *)SuperStack);
		Cconws(mess[1]);	/* Installed */
		/* und resident bleiben */
		Ptermres(_PgmSize,0);
	}
	else
	{
		Super((void *)SuperStack);
		/* Fehlermeldung */
		Cconws(mess[2]);	/* Not installed */
		/* terminieren */
		return(1);
	}
}


