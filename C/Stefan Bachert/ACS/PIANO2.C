/*
    Beispielapplikation fÅr ACS

    "Piano"

  	Phase 2

    14.1.92         Stefan Bachert

		(c) MAXON Computer GmbH
*/

#include	<tos.h>
#include    <acs.h>
#include    <piano2.h>

/* Prototypen anlegen */

static void ton (void);
static Awindow *piano_make (void *not_used);

#include    <piano2.ah>


/* Soundgenerator ansteuern */
static char sound [] = {
	0x00, 0x10,				/* Generator A Frequenz einstellen */
	0x01, 0x10,
	0x07, 0xf8,				/* Rauschen ausschalten */
	0x0b, 0x00,				/* TonlÑnge HÅllkurve */
	0x0c, 0x30,
	0x08, 0x17,				/* LautstÑrke */
	0x0d, 0x00,				/* HÅllkurve abklingend */
	0xff, 0x00				/* stop */
	};


static void ton (void)
	/*
	 *	lÑût ton der Frequenz (userp1) / 1000 ertînen
	 *	
	 */
{
  AOBJECT *aob;
  long val;

  aob = (AOBJECT *) ev_object + ev_obnr + 1;
  val = 125000000L / (long) aob-> userp1;	/* berechne Teilerwert */

  sound [1] = (char) val;				/* unteres Byte */
  sound [3] = (char) (val >> 8) & 0x0f; /* oberes (Halb) Byte */

  Dosound (sound);
  evnt_timer (80, 0);		/*  x Milli Sec warten (visuelle RÅckmeldung) */
}


static Awindow *piano_make (void *not_used)
    /*
     *  Erzeuge Piano Fenster
     */
{
  Awindow *wi;

  wi = Awi_create (&PIANO);
  if (wi == NULL) return NULL;

  if (application) {
	(wi-> open) (wi);                 /* îffne gleich */
  };
  return wi;
}

static char oldconterm;	/* fÅr ursprÅnglichen Wert */

static long off_click (void)
{
  oldconterm = *((char *) 0x484);
  *((char *) 0x484) &= ~3;		/* kein click und keine Tastenwiederholung */
  return 0L;
}

static long old_click (void)
{
  *((char *) 0x484) = oldconterm;
  return 0L;
}

void ACSterm (void)
{
  Supexec (old_click);					/* alter Zustand */
}

int ACSinit (void)
    /*
     *  Doppelklick auf NEU erzeugt ein neues Fenster
     */
{
  Awindow *window;

  Supexec (off_click);					/* click ausschalten */

  if (application) {
	window = Awi_root ();                 /* root window */

	if (window == NULL) return FAIL;      /* lege NEU Icon an */
	(window-> service) (window, AS_NEWCALL, &PIANO. create);

	window = &PIANO;
	(window-> create) (NULL);             /* sofort ein Fenster erzeugen */
  };

  return OK;
}
