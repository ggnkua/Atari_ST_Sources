/***********************************************************************\
* MENUKEYS.C - Tastenverarbeitung und MenÅsimulation			*
*									*
* (c) 1990 Marcel Waldvogel, HÑgetstalstr. 37, CH-8610 Uster		*
* Durchsuchen des MenÅbaumes mit freundlicher Hilfe von Urs MÅller.	*
\***********************************************************************/

/*
** - key_upper() verwandelt das Åbergebene Zeichen unter Beachtung der
**   Umlaute in einen Grossbuchstaben.
** - key_search() durchsucht den MenÅbaum nach einem bestimmten String
**   und versendet eine entsprechende MN_SELECTED-Message.
**   Falls der Eintrag gefunden wurde, wird 0 zurÅckgeliefert, sonst
**   der Åbergebene retval.
** - key_decode() wird mit dem von evnt_multi()/evnt_keybd() erhaltenen
**   Tastencode gefÅttert. Das Ergebnis ist ein einfacher zu behandelnder
**   Wert, der von der verwendeten Tastatur unabhÑngig ist.
** - key_text() wandelt einen decodierten Tastencode in einen lesbaren
**   String. Die dort fÅr die Tasten eingesetzten Strings kînnen nach
**   Belieben (Gross-/Kleinschreibung, Landessprache) geÑndert werden.
**
**  Wie ich leider feststellen musste, kann der Messagebuffer
**  durch den Autorepeat der Tasten Åberlaufen, falls sonst
**  noch Messages (z.B. Redraws) versendet werden. Ein solcher
**  öberlauf hat den Programmabsturz zufolge. Deshalb sollten die
**  Messages bei Operationen, die Redraws (oder sonstige Messages an sich
**  selbst) erzeugen und rasch wiederholt werden kînnen nicht mit
**  appl_write() verschickt werden, obwohl diese Methode recht elegant
**  war.
*/

#include <stddef.h>		/* NULL */
#include <string.h>		/* strcpy() */
#include <tos.h>		/* KEYTAB, Keytbl() */
#include <aes.h>		/* OBJECT, menu_tnormal(), appl_write() */

#include "menukeys.h"		/* Globale Definitionen */
#include "mk.h"			/* Lokale Definitionen */

typedef enum{FALSE, TRUE} bool;	/* Wird nur lokal verwendet... */


/***********************************************************************\
* Wandelt nach Grossbuchstaben (beachtet Umlaute)			*
\***********************************************************************/
char key_upper(char c)
{
  static const char uppertab[] =
  {
    'Ä', 'ö', 'ê', 'É', 'é', '∂', 'è', 'Ä',	/* 0200..0207 */
    'à', 'â', 'ä', 'ã', 'å', 'ç', 'é', 'è',	/* 0210..0217 */
    'ê', 'ë', 'í', 'ì', 'ô', 'ï', 'ñ', 'ó',	/* 0220..0227 */
    'ò', 'ô', 'ö', 'õ', 'ú', 'ù', 'û', 'ü',	/* 0230..0237 */
    '†', '°', '¢', '£', '•', '•', '¶', 'ß',	/* 0240..0247 */
    '®', '©', '™', '´', '¨', '≠', 'Æ', 'Ø',	/* 0250..0257 */
    '∑', '∏', '≤', '≤', 'µ', 'µ', '∂', '∑',	/* 0260..0267 */
    '∏', 'π', '∫', 'ª', 'º', 'Ω', 'æ', 'ø',	/* 0270..0271 */
    '¡', '¡'
  };

  if (c >= 'a' && c <= 'z')
    return c - 'a' + 'A';
  if (c >= '\200' && c <= '\271')
    return uppertab[c - '\200'];
  else
    return c;
}


/***********************************************************************\
* Testet, ob der String key ganz hinten in menu vorkommt (Leer-		*
* zeichen dÅrfen noch dahinter stehen). Direkt davor muss noch ein	*
* Leerzeichen stehen. Lokale Funktion.					*
\***********************************************************************/
static bool key_right(const char *entry, const char *key)
{
  const char *entryptr = entry,
             *keyptr   = key;

  while (*entryptr != '\0')
    entryptr++;			/* entryptr an den Schluss des Strings */
  while (*(--entryptr) == ' ');	/* von rechts erstes Zeichen suchen */

  while (*keyptr != '\0')	/* Stringende suchen */
    keyptr++;
  keyptr--;			/* Wieder aufs letzte Zeichen */

  /*
  ** - Sind noch Zeichen zu vergleichen (keyptr >= key)?
  ** - Ist nachher noch mindestens ein Zeichen im MenÅtext,
  **   da davor ein Leerzeichen stehen muss (entryptr > entry)?
  ** - Sind die beiden Zeichen gleich (*keyptr == *entryptr--)?
  **
  ** entryptr wird immer zurÅckgezÑhlt, da es nach Vergleichsende auf
  ** dem Leerzeichen vor dem Tastenstring stehen sollte.
  ** keyptr wird nur zurÅckgezÑhlt, wenn der Vergleich erfolgreich war,
  ** daran ist das erfolgreiche Ende zu erkennen.
  */
  while (keyptr >= key && entryptr > entry && *keyptr == *entryptr--)
    keyptr--;

  /*
  ** Alles ÅberprÅft, und steht vor dem Tastentext im MenÅ noch ein Space?
  */
  if (keyptr < key && *entryptr == ' ')
    return TRUE;
  else
    return FALSE;
}


/***********************************************************************\
* Durchsucht den MenÅbaum tree nach dem String key. key muss in		*
* einem Dropdown-Eintrag ganz rechts stehen (siehe key_right).		*
* Parameter:								*
* - menu:  Zeiger auf den MenÅbaum (NULL => nichts tun)			*
* - key:   String, nach dem gesucht werden soll (NULL => nichts tun)	*
* - title: Hier wird die Nummer des MenÅtitels zurÅckgegeben, falls	*
*	   der Eintrag gefunden wurde (NULL => wird nicht gesetzt)	*
* - item:  Objektnummer des gewÑhlten Eintrages (NULL => nicht setzen)	*
* RÅckgabe:								*
* - TRUE:  Eintrag gefunden, title und item sind gÅltig			*
* - FALSE: Eintrag nicht gefunden, title und item sind ungÅltig		*
*	   und unverÑndert)						*
* Beispielaufruf siehe Dokumentation.					*
\***********************************************************************/
int key_search(OBJECT *menu, char *key, int *title, int *item)
{
  bool desk = TRUE;
  int  menubar, menutitle, dropdown, entry;
  OBJECT *obj;

  if (key == NULL || menu == NULL)		/* Was soll denn das? */
    return FALSE;

  menubar   = menu[menu->ob_head].ob_head; /* Obj: MenÅzeile */
  menutitle = menu[menubar].ob_head;       /* Obj: Titel in MenÅzeile */
  dropdown  = menu[menu->ob_tail].ob_head; /* Obj: Ein Dropdown */
  entry     = menu[dropdown].ob_head;      /* Obj: Eintrag im Dropdown */

  do{					/* FÅr alle Titeln */
    obj = &menu[menutitle];
    if (AVAIL(obj) && entry != -1)	/* Titel ok? Hat es EintrÑge? */
    {
      do{
        obj = &menu[entry];
        if (AVAIL(obj)
            && (obj->ob_type == G_STRING || obj->ob_type == G_BUTTON)
            && key_right(obj->ob_spec.free_string, key))
        {
          /* send_selected(menutitle, entry); */
          if (title != NULL)
            *title = menutitle;
          if (item != NULL)
            *item  = entry;
          return TRUE;		/* Aufgabe erfÅllt */
        }
        entry = obj->ob_next;		/* Zum nÑchsten Eintrag */
        /*
        ** Bis alle EintrÑge durch sind, aber im ersten MenÅ ("DESK")
        ** nur den ersten Eintrag ÅberprÅfen, also ohne ACCs.
        */
      }while (entry != dropdown && !desk);
      desk = FALSE;
      menutitle = menu[menutitle].ob_next;	/* Zum nÑchsten Titel */
      dropdown  = menu[dropdown].ob_next;
      entry     = menu[dropdown].ob_head;
    }
  }while (menutitle != menubar);	/* Alle MenÅtitel getestet? */
  return FALSE;
}


/********************************************************************\
* Parameter: Keycode (Highbyte: Scan, Lowbyte: ASCII)		     *
*	     (wie z.B. von evnt_multi()/evnt_keybd() zu erhalten)    *
*								     *
* RÅckgabe:							     *
* -1:	  "Unvorhergesehener Fall", sollte nicht passieren, ausser   *
*	  es wurde eine vîllig neuartige Tastenkombination gedrÅckt. *
* 0..255: ASCII-Code						     *
* >=256:  Falls KEY_SCAN gesetzt ist, steht im Lowbyte der Scancode  *
*         der Taste, zusÑtzlich sind noch (wenn nîtig) die Werte von *
*	  KEY_CTRL, KEY_ALT und/oder KEY_SHIFT hineinge-    *
*	  ODERt.						     *
*	  Falls KEY_SCAN nicht gesetzt ist, ist mindestens eines von *
*	  KEY_CTRL, KEY_ALT oder KEY_SHIFT gesetzt, und im  *
*	  Lowbyte befindet sich der ASCII-Code.			     *
\********************************************************************/
int key_decode(unsigned int scanascii)
{
#if GLOBKEYTAB
  extern KEYTAB *keytab;
#else
  KEYTAB *keytab;
#endif
  unsigned char unshift, shift, capslock, upunshift, c;
  unsigned int  scan  = scanascii >> 8;
  unsigned char ascii = scanascii & 0xff;

#if SET_NUMERIC
  int numeric;

  if (ISNUMERIC(scan))
    numeric = KEY_NUM;
  else
    numeric = 0;
#define NUMERIC numeric
#else
#define NUMERIC 0
#endif

  /*
  ** Falls Scancode == 0 (z.B. durch Makrorekorder oder
  ** Alt-Zehnerblock), dann ASCII-Code zurÅckgeben (der in diesem
  ** Fall mit dem keycode identisch ist). KEY_NUM kann nie gesetzt sein.
  */
#if SET_NOSCAN
  if (scan == 0)
    return ascii | KEY_NOSCAN;
#else
  if (scan == 0)
    return ascii;
#endif

  /*
  ** Einige weiteren Åblichen Tasten
  */
  switch (scan)
  {
#if WANDLECONTROL
  case CTRLHOME:
  		if (ascii == 0)
  		  return CLRHOME | KEY_SCAN | KEY_CTRL;
  		else
  		  return CLRHOME | KEY_SCAN | KEY_CTRL | KEY_SHIFT;
  case CTRLLINKS:
  		if (ascii == 0)
  		  return LINKS | KEY_SCAN | KEY_CTRL;
  		else
  		  return LINKS | KEY_SCAN | KEY_CTRL | KEY_SHIFT;
  case CTRLRECHTS:
  		if (ascii == 0)
  		  return RECHTS | KEY_SCAN | KEY_CTRL;
  		else
  		  return RECHTS | KEY_SCAN | KEY_CTRL | KEY_SHIFT;
#else /* !WANDLECONTROL */
  case CTRLHOME:
  case CTRLLINKS:
  case CTRLRECHTS:
#endif
  case HELP:
  case UNDO:
  case INSERT:
  case CLRHOME:
  case AUF:
  case LINKS:
  case RECHTS:
  case AB:	if (ascii == 0)
		  return scan | KEY_SCAN;
		if (ascii > ' ')
		  return scan | KEY_SCAN | KEY_SHIFT;
		else
		  return scan | KEY_SCAN | KEY_SHIFT | KEY_CTRL;
  case BACKSPACE:
  case ESC:
  case TAB:
  		return scan | KEY_SCAN;
  case DELETE:	if (ascii == DEL)
  		  return scan | KEY_SCAN;
  		else
  		  return scan | KEY_SCAN | KEY_CTRL;
  case RETURN:
  case ENTER:	if (ascii == CR)
  		  return scan | KEY_SCAN;
  		else
  		  return scan | KEY_SCAN | KEY_CTRL;
  }

  /*
  ** Funktionstasten und Shift-Funktionstasten.
  */
  if (scan >= SF1 && scan <= SF10)
    return (scan - SF1 + F1) | KEY_SCAN | KEY_SHIFT;
  if (scan >= F1 && scan <= F10)
    return scan | KEY_SCAN;

  /*
  ** So, ab jetzt brauchen wir auch noch die ASCII-Codes
  */
#if !GLOBKEYTAB
  keytab   = Keytbl((char *)-1L, (char *)-1L, (char *)-1L);
#endif
  unshift  = keytab->unshift[scan];
  shift    = keytab->shift[scan];
  capslock = keytab->capslock[scan];

  /*
  ** Oberste Reihe des Alphablockes mit Alternate:
  ** [Alt-1] bis [Alt-9], [Alt-0], [Alt-û], [Alt-']
  ** (Die Tasten kînnen auf anderen Tastaturen anders benannt sein)
  ** Der Scancode von ALTAPOSTROPH ist grîsser als 128!
  */
  if (scan >= ALT1 && scan <= ALTAPOSTROPH)
    return key_upper(keytab->unshift[scan - ALT1 + 2]) | KEY_ALT;

  /*
  ** Sonstige Taste/Tastenkombination:
  ** - mit Alt
  ** - mit Ctrl
  ** - mit Ctrl-Shift (nicht bei A-Z)
  ** - ganz normal (auch Tasten mit Spezialzeichen < ' ', wie LED-Ziffern)
  */
  if (ascii >= ' ')			/* Trivialer Fall */
    return ascii | NUMERIC;		/* Zeichen Åbernehmen */
  if (scan >= 128)			/* Index out of Range */
    return -1;				/* Keine Ahnung... */

#if KOMISCH
  /*
  ** Ctrl-2, Ctrl-6 und Ctrl-- werden komisch zurÅckgegeben.
  ** Hier wird das wieder auszubÅgeln versucht.
  */
  if (ascii == 0 && (unshift == '2' || shift == '2' || capslock == '2'))
    return '2' | KEY_CTRL | NUMERIC;
  if (ascii == 0x1e && (unshift == '6' || shift == '6' || capslock == '6'))
    return '6' | KEY_CTRL | NUMERIC;
  if (ascii == 0x1f && (unshift == '-' || shift == '-' || capslock == '-'))
    return '-' | KEY_CTRL | NUMERIC;
#endif

  upunshift = key_upper(unshift);

  if (ascii != '\0' && (unshift == ascii || shift == ascii || capslock == ascii))
    return ascii | NUMERIC;		/* Spezialzeichen auf Tastatur */
  if (unshift == 0)			/* Irgendwas komisches */
    return -1;
  if (ascii == (unshift & 0x1f))	/* ^unshift? */
    return upunshift | KEY_CTRL | NUMERIC;
  if (ascii == (shift & 0x1f))		/* ^shift? */
  {
    /*
    ** Es dÅrfte Shift-Control-ShiftZeichen sein.
    ** Kînnte es aber auch Control zusammen mit einem nach gross gewandelten
    ** Unshiftbuchstaben sein? (Hat bei Ctrl-A..Z keine Auswirkungen, aber
    ** bei Ctrl-Sonderzeichen, speziell bei Umlauten)
    */
    c = key_upper(shift);
    if (((c ^ upunshift) & 0x1f) != 0)	/* c&0x1f == buf[2]&0x1f? */
      return c | KEY_CTRL | NUMERIC;
    else
      return upunshift | KEY_SHIFT | KEY_CTRL | NUMERIC;
  }
  if (ascii == (capslock & 0x1f))	/* ^capslock? */
    return capslock | KEY_CTRL | NUMERIC;

  /*
  ** Was jetzt noch Åbrigbleibt, sind ALT-Tasten und spezielle
  ** CTRL-Kombinationen.
  */
  if (ascii == 0)
    return upunshift | KEY_ALT | NUMERIC;
  else
    return ('@' + ascii) | KEY_CTRL | NUMERIC;
}


static char *strappend(char *dest, char *source)
/**********************************************/
{
  /* strcpy() */
  while ((*dest++ = *source++) != '\0');

  /* Gib Zeiger auf '\0' zurÅck */
  return dest-1;
}


void key_text(int mode, int keycode, char *buf)
/*********************************************/
{
  /* Mindestgrîsse des Buffers: siehe MENUKEYS.H */
  char *str = NULL;

  /* 0 und -1 kînnen nicht umgesetzt werden */
  if (keycode == -1 || (char) keycode == 0)
    str = "???";
  else
  {
    switch (mode)
    {
    case KT_SYMBOL:	/* Als Symbol, wie in den MenÅs */
      if (keycode & KEY_SHIFT) *buf++ = SHIFTCHAR;
      if (keycode & KEY_CTRL)  *buf++ = CTRLCHAR;
      if (keycode & KEY_ALT)   *buf++ = ALTCHAR;
      /* Ich kenne kein gescheites Symbol fÅr NUM, also lasse ich es */
      break;
    case KT_SHORT:	/* Kurzform, wie z.B. bei Emacs */
      if (keycode & KEY_SHIFT) buf = strappend(buf, SHORTSHIFTSTR);
      if (keycode & KEY_CTRL)  buf = strappend(buf, SHORTCTRLSTR);
      if (keycode & KEY_ALT)   buf = strappend(buf, SHORTALTSTR);
      if (keycode & KEY_NUM)   buf = strappend(buf, SHORTNUMSTR);
      break;
    case KT_LONG:	/* Lange Form mit vollen Texten */
      if (keycode & KEY_SHIFT) buf = strappend(buf, LONGSHIFTSTR);
      if (keycode & KEY_CTRL)  buf = strappend(buf, LONGCTRLSTR);
      if (keycode & KEY_ALT)   buf = strappend(buf, LONGALTSTR);
      if (keycode & KEY_NUM)   buf = strappend(buf, LONGNUMSTR);
      break;
    }
    if (keycode & KEY_SCAN)	/* Spezialtasten? */
    {
      switch ((char) keycode)
      {
      case ESC:		str = "ESC"; break;
      case BACKSPACE:	str = "BS"; break;
      case TAB:		str = "TAB"; break;
      case RETURN:	str = "RETURN"; break;
      case CLRHOME:	str = "HOME"; break;
      case AUF:		str = "UP"; break;
      case LINKS:	str = "LEFT"; break;
      case RECHTS:	str = "RIGHT"; break;
      case AB:		str = "DOWN"; break;
      case INSERT:	str = "INS"; break;
      case DELETE:	str = "DEL"; break;
      case UNDO:	str = "UNDO"; break;
      case HELP:	str = "HELP"; break;
      case ENTER:	str = "ENTER"; break;
#if !WANDLECONTROL	/* Hier wird nicht auf "Ctrl-" erweitert */
      case CTRLLINKS:
        switch (mode)
        {
        case KT_SYMBOL:	str = CTRLSTR "LEFT"; break;
        case KT_SHORT:	str = SHORTCTRLSTR "LEFT"; break;
        case KT_LONG:	str = LONGCTRLSTR "LEFT"; break;
        }
        break;
      case CTRLRECHTS:
        switch (mode)
        {
        case KT_SYMBOL:	str = CTRLSTR "RIGHT"; break;
        case KT_SHORT:	str = SHORTCTRLSTR "RIGHT"; break;
        case KT_LONG:	str = LONGCTRLSTR "RIGHT"; break;
        }
        break;
      case CTRLHOME:
        switch (mode)
        {
        case KT_SYMBOL:	str = CTRLSTR "HOME"; break;
        case KT_SHORT:	str = SHORTCTRLSTR "HOME"; break;
        case KT_LONG:	str = LONGCTRLSTR "HOME"; break;
        }
        break;
#endif
      case F1:
      case F2:
      case F3:
      case F4:
      case F5:
      case F6:
      case F7:
      case F8:
      case F9:	*buf++ = 'F';
      	        *buf++ = (char) keycode - F1 + '1';
                break;
      case F10:	str = "F10"; break;
      }
    }
    else	/* !KEY_SCAN */
    {
      if (keycode == ' ')
        str = "SPACE";
      else
        *buf++ = (char) keycode;
    }
  }

  if (str == NULL)
    *buf++ = '\0';	/* String abschliessen */
  else
    strcpy(buf, str);	/* Rest anhÑngen und abschliessen */
}


