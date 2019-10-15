/* VBLqueue-Handler fÅr Turbo-C
   von Martin Backschat */

#include "tos.h"
#include <string.h>

#define	TRUE 1
#define FALSE 0
#define NULL 0l
#define	VBI_INSERT 0	/* Makros sagen mehr! */
#define	VBI_DELETE 1

void main(void);
void demo_vbi(void);
int vbi_queue(void (*function)(), int mode);

void main()
{
	if (vbi_queue(demo_vbi,VBI_INSERT)) {
		Cconws("\nFehler beim Einklinken!");
		return;
	}
	Crawcin();
	vbi_queue(demo_vbi,VBI_DELETE);
}


/* unsere Demonstrations-VBL-Routine */
void demo_vbi()
{
	*((int *)0xff8240l) += 1;	/* Hintergrundfarbe erhîhen */
}


/* Routine zum Ein- und Ausklinken in den VBL-Queue */
/* IN -> function, mode */
/* OUT -> error (TRUE,FALSE) */
int vbi_queue(function,mode)
  void (*function)();
  int mode;
{
  static unsigned int *nvbls = (unsigned int *)0x454l;
  static void (***vblqueue)() = (void (***)()) 0x456l;
  int error,entries,i;
  long spvi;

	error = FALSE;
	spvi = Super(NULL);	/* in Supervisor-Modus wechseln */
	entries = *nvbls;	/* Anzahl der verfÅgbaren EintrÑge */

	if (!mode) {	/* Routine in Queue einklinken */
		for (i = 0; i < entries; i++)
			if (!((*vblqueue)[i]))	/* Eintrag frei? */
				break;
		if (i == entries)	/* kein Eintrag frei gewesen */
			error = TRUE;
		else
			(*vblqueue)[i] = function;	/* Eintrag setzen */
	}
	else {	/* Routine aus Queue ausklinken */
		for (i = 0; i < entries; i++)
			if ((*vblqueue)[i] == function)
				break;	/* Eintrag suchen */
		if (i == entries)
			error = TRUE;	/* function nicht gefunden */
		else
			(*vblqueue)[i] = NULL;	/* Eintrag lîschen */
	}

	Super((long *)spvi);
	return error;
}
