/***********************************/
/*  Example application for ACS    */
/*                                 */
/*  "Piano"                        */
/*                                 */
/*  Phase 2                        */
/*                                 */
/*  14.1.92         Stefan Bachert */
/*                                 */
/* (c) MAXON Computer GmbH         */
/***********************************/

#include <tos.h>
#include    <acs.h>
#include    <piano2.h>

/* Place Prototypes */

static void ton (void);
static Awindow *piano_make (void *not_used);

#include    <piano2.ah>


/* Sound generator control */
static char sound [] = {
 0x00, 0x10,    /* Set Generator A Frequency */
 0x01, 0x10,
 0x07, 0xf8,    /* Switch rush off           */
 0x0b, 0x00,    /* Tone length sleeve curve  */
 0x0c, 0x30,
 0x08, 0x17,    /* Volume            */
 0x0d, 0x00,    /* Sleeve curve fade */
 0xff, 0x00     /* stop              */
 };


static void ton (void)
 
 /* carries out tone of the Frequency (userp1) / 1000 sounds */
 
 
{
  AOBJECT *aob;
  long val;

  aob = (AOBJECT *) ev_object + ev_obnr + 1;
  val = 125000000L / (long) aob-> userp1; /* calculate part value */

  sound [1] = (char) val;                 /* lower Byte           */
  sound [3] = (char) (val >> 8) & 0x0f;   /* upper (Half) Byte    */

  Dosound (sound);
  evnt_timer (80, 0);  /*  x Milli Sec wait (visual return message) */
}


static Awindow *piano_make (void *not_used)
    
    /*  Generate Piano Window */
  
{
  Awindow *wi;

  wi = Awi_create (&PIANO);
  if (wi == NULL) return NULL;

  if (application) {
 (wi-> open) (wi);                 /* open similiar */
  };
  return wi;
}

static char oldconterm; /* for original value */

static long off_click (void)
{
  oldconterm = *((char *) 0x484);
  *((char *) 0x484) &= ~3;  /* no click and no key repeat */
  return 0L;
}

static long old_click (void)
{
  *((char *) 0x484) = oldconterm;
  return 0L;
}

void ACSterm (void)
{
  Supexec (old_click);     /* old state */
}

int ACSinit (void)
    
    /*  Double click on NEW produces a new window */
   
{
  Awindow *window;

  Supexec (off_click);     /* switch click off */

  if (application) {
 window = Awi_root ();                 /* root window */

 if (window == NULL) return FAIL;      /* place NEW Icon  */
 (window-> service) (window, AS_NEWCALL, &PIANO. create);

 window = &PIANO;
 (window-> create) (NULL);             /* Generate a Window immediately */
  };

  return OK;
}
