/******************************************************************************/
/* Programmname        : wo_call                                              */
/* Copyright           : ST Computer & D. Rabich                              */
/* Datum               : 10. Juni 1989                                        */
/* letztes Edier-Datum :  9. Oktober 1989                                     */
/* Version             : 1.00a                                                */
/* Entwicklungssystem  : Turbo C 1.1                                          */
/******************************************************************************/

/* Include-Dateien */
/* fÅr Turbo C */
# ifdef __TURBOC__
# include <aes.h>

/* fÅr Megamax Laser C */
# else
# include <gembind.h>
# define  void
# endif

# include <string.h>

# define FOREIGN_CALL   0x4001  /* Aufruf von Mercur  */
# define FOREIGN_ANSWER 0x4002  /* Antwort von Mercur */

/* Alert-Strings */
char time_out[]   = "[0][Time - Out!][ OK ]";
char antwort[]    = "[0][Wodan|antwortet!][ OK ]";
char no_wodan[]   = "[0][Wodan antwortet|nicht korrekt.][ OK ]";
char not_loaded[] = "[0][Wodan ist|nicht prÑsent.][ OK ]";

/* Name von Wodan */
char wodan[]   = "WODAN   ";

/* Struktur der Wodan-Parameter */
typedef struct
{
  int   aktiv;
  int   position;
  void* strings;
} L_PARA;

/* spezielle Message zur Kommunikation mit Wodan */
typedef struct
{
  unsigned int msg_type;
  unsigned int msg_id;
  unsigned int msg_over;
  L_PARA*      msg_sadr;
  unsigned int msg_sp_id;
  long     int msg_free;
} MERCUR_MSG;


void main (void)

{
  int        apl_id,       /* Programm-ID       */
             wodan_id,     /* Wodan-ID          */
             mx, my,       /* fÅr evnt_multi... */
             mbutton,
             mstate,
             keycode,
             mclicks,
             event;
  MERCUR_MSG message;      /* Message             */
  L_PARA*    parameter;    /* Parameter           */
  long       alt_strings;  /* Adresse der Strings */

  apl_id = appl_init ();   /* eigene ID */
  if (apl_id != -1)        /* alles OK? */
  {
    wodan_id = appl_find (wodan);              /* ID von Wodan       */

    if (wodan_id != -1)                        /* Wodan gefunden?    */
    {
      message.msg_type = FOREIGN_CALL;         /* Nachricht aufbauen */
      message.msg_id   = apl_id;
      message.msg_over = 0;

      appl_write (wodan_id, 16, &message);     /* senden           */

      event = evnt_multi (MU_MESAG | MU_TIMER, /* Antwort abwarten */
                          1, 1, 1,
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          (int*) &message,
                          1000, 0,
                          &mx, &my, &mbutton, &mstate,
                          &keycode, &mclicks);

      if (event & MU_TIMER)                /* keine Antwort? */
	      form_alert (1, time_out);

	    else if (event & MU_MESAG)           /* Antwort!       */
	    {
	      if (message.msg_sp_id == 10089)    /* spezielle ID OK?    */
	      {
	        parameter = message.msg_sadr;    /* Adresse der Strings */
	        alt_strings = (long) parameter->strings;
	        strcpy ( (char*) alt_strings,         "Hallo");
	        strcpy ( (char*) (alt_strings + 80L), "Welt!");

	        form_alert (1, antwort);
	      }
	      else
	        form_alert (1, no_wodan);
	    }
    }
    else
      form_alert (1, not_loaded);

  appl_exit (); /* Auf Wiedersehen! */
  }
}
