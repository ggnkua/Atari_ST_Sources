/*
    Beispielapplikation fÅr ACS

    "Piano"

    14.1.92         Stefan Bachert

		(c) 1992 MAXON Computer GmbH
*/

#include	<tos.h>
#include    <acs.h>
#include    <piano.h>

/* Prototypen anlegen */

static void ton (void);
static void start (void);
static void play (void);
static Awindow *piano_make (void *not_used);
static int piano_service (Awindow *window, int task, void *in_out);

#include    <piano.ah>

#define MAXSOUND 200

typedef struct {
	int key;
	long time;
	} single;
typedef struct {
	int next;
	single field [MAXSOUND];
	} tape;

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

static long timer_200Hz (void)
{
  return *((long *) 0x4BA);		/* holt 200Hz Timer */
}

static void ton (void)
	/*
	 *	lÑût ton der Frequenz (userp1) / 1000 ertînen
	 *	
	 */
{
  AOBJECT *aob;
  int next;
  long val, timer;
  tape *user;

  aob = (AOBJECT *) ev_object + ev_obnr + 1;
  val = 125000000L / (long) aob-> userp1;	/* berechne Teilerwert */

  sound [1] = (char) val;				/* unteres Byte */
  sound [3] = (char) (val >> 8) & 0x0f; /* oberes (Halb) Byte */

  timer = Supexec (timer_200Hz);		/* merke Zeitpunkt */
  Dosound (sound);
  evnt_timer (80, 0);		/*  x Milli Sec warten (visuelle RÅckmeldung) */

/*	aufzeichnen */
  user = ev_window-> user;
  next = user-> next ++;
  if (next >= MAXSOUND) return;	/* tape voll */
  user-> field [next]. key = ev_obnr;
  user-> field [next]. time= timer;
}

static void start (void)
	/*
	 *	Beginnt am Anfang mit dem Aufzeichnen, Lîschen !
	 */
{
  tape *user;

  user = ev_window-> user;
  user-> next = 0;
}


static void play (void)
	/*
	 *	Spielt Band ab
	 */
{ 
  Awindow *window;
  OBJECT *work;
  AOBJECT *aob;
  tape *user;
  long st_time, nxt_time, val;
  int act, key;
  int t, button;

  window = ev_window;
  work = ev_object;

  user = window-> user;

  st_time = Supexec (timer_200Hz) - user-> field-> time;	/* erste Zeit Åberspringen */

  for (act = 0; act < user-> next; act ++) {
	nxt_time = st_time + user-> field [act]. time;
	while (Supexec (timer_200Hz) < nxt_time) {
	  graf_mkstate (&t, &t, &button, &t);	/* abbruch Maustaste */
	  if (button != 0) break;	
	};	/* warte */

	key = user-> field [act]. key;
	aob = (AOBJECT *) work + key + 1;
	val = 125000000L / (long) aob-> userp1;	/* berechne Teilerwert */
	sound [1] = (char) val	;				/* unteres Byte */
	sound [3] = (char) (val >> 8) & 0x0f; /* oberes (Halb) Byte */

	(window-> obchange) (window, key, work [key]. ob_state | SELECTED);
	Dosound (sound);
	evnt_timer (80, 0);		/*  x Milli Sec warten (visuelle RÅckmeldung) */
	(window-> obchange) (window, key, work [key]. ob_state & ~SELECTED);

	graf_mkstate (&t, &t, &button, &t);	/* abbruch Maustaste*/
	if (button != 0) break;	
  };
}


static Awindow *piano_make (void *not_used)
    /*
     *  Erzeuge Piano Fenster
     */
{
  Awindow *wi;
  tape *user;

  wi = Awi_create (&PIANO);
  if (wi == NULL) return NULL;

  user =
  wi-> user = Ax_malloc (sizeof (tape));	/* Datenstruktur anlegen */
  if (user == NULL) return NULL;			/* Fehler passiert */

  user-> next = 0;						 	/* Initialisieren */

  if (application) {
	(wi-> open) (wi);						/* îffne gleich */
  };
  return wi;
}


static int piano_service (Awindow *window, int task, void *in_out)
{
  switch (task) {
	case AS_TERM:					/* Fenster freigeben */
	  Ax_free (window-> user);		/* Struktur freigeben */
	  Awi_delete (window); break;
	default:
	  return FAIL;
  };
  return TRUE;
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
