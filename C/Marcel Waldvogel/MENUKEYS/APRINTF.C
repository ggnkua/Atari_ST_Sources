/*
** aprintf V1.1, (c) 1990,1991 Marcel Waldvogel
**
** Ermîglicht die bequeme Nutzung von printf-Formatstrings auch in
** GEM-Programmen.
** Sollte ziemlich selbsterklÑrend sein, Details in den Headerkommentaren
** der entsprechenden Funktionen.
**
** Die graf_mouse()-Aufrufe gingen bei mir in eine Funktion
** void mouse_form(int form), die die Mausform nur setzt, wenn die
** neue Mausform != alte Mausform ist (verhindert ein Flackern des
** Mauspfeils).
**
** Bei va_arg() gibt es eine Non-portable-Pointer-conversion-Warning,
** die aber ignoriert werden kann. Die Ursache liegt an der geÑnderten
** Definition von va_arg(), weshalb diese Warnung bei jedem(!) Aufruf von
** va_arg() erzeugt wird.
**
** BUGS:
** ']' und '|' werden auch interpretiert, wenn sie in den Strings
** vorkommen, die in den Formatstring eingesetzt werden sollen.
** Deshalb mÅssen Strings, die '|' und/oder ']' enthalten kînnten,
** zuerst mit aprintf_prepare() behandelt werden.
*/

#include <stdarg.h>
#include <stdio.h>
#include <aes.h>
#include "aprintf.h"



int aprintf(int button, char *format, ...)
/****************************************/
{
  /*
  ** Analog zu printf(), einfach in einen Alert.
  ** format ist ein Alertstring (mit eckigen Klammern und senkrechten
  ** Strichen), kann aber noch zusÑtzlich alle %-Formatanweisungen enthalten.
  **
  ** Beispiel:
  ** button = aprintf(1,
  **            "[1][|Datei %s nicht gefunden!][Nochmals|Abbruch]", file);
  */
  va_list param;
  char buf[APRINTF_BUFSIZE];

  va_start(param, format);
  vsprintf(buf, format, param);
  va_end(param);
  graf_mouse(ARROW, NULL);
  return form_alert(button, buf);
}


int afreeprintf(int button, int freenum, ...)
/*******************************************/
{
  /*
  ** Analog zu printf(), einfach in einen Alert.
  ** frenum ist ein Index in die Alert-/Stringliste der Resource
  ** Falls freenum < 0 ist (z.B. -1), wird der Alertstring nicht aus der
  ** Resource geholt, sondern liegt als erster Parameter auf dem Stack.
  **
  ** Auf aprintf() kann bei der Benutzung von afreeprintf() ganz verzichtet
  ** werden, indem das obige Beispiel wie folgt verÑndert wird:
  **
  ** button = afreeprintf(1, -1,
  **            "[1][|Datei %s nicht gefunden!][Nochmals|Abbruch]", file);
  **
  ** Falls dieser String unter dem Namen NOTFOUND in der Resource vorkommt
  ** (was zur leichten öbersetzbarkeit beitrÑgt), sieht das Beispiel
  ** wie folgt aus:
  **
  ** button = afreeprintf(1, NOTFOUND, file);
  */
  va_list param;
  char buf[APRINTF_BUFSIZE], *alert;

  va_start(param, freenum);
  if (freenum >= 0)	/* GÅltige Objektnummer: Holen */
    rsrc_gaddr(R_STRING, freenum, &alert);
  else	/* -1: NÑchster Parameter ist Zeiger auf den Alertstring */
    alert = va_arg(param, char *);
  vsprintf(buf, alert, param);
  va_end(param);
  graf_mouse(ARROW, NULL);
  return form_alert(button, buf);
}


void aprintf_prepare(char *buf)
/*****************************/
{
  /*
  ** Verdoppelt im String alle '|' und ']'.
  ** VORSICHT: Dadurch wird der String u.U. bis doppelt so lang!
  */
  int count = 0;
  char *ptr = buf;

  /* ZÑhle '|' und ']' */
  while (*ptr != 0)
  {
    if (*ptr == '|' || *ptr == ']')
      count++;
    ptr++;
  }
  
  /*
  ** Sonderzeichen gefunden?
  ** Ja, dann String rÅckwÑrts mit Offset count auf sich selbst kopieren
  ** solange es noch Sonderzeichen hat, wobei diese jeweils verdoppelt
  ** werden.
  */
  while (count > 0)
  {
    /* Ein Zeichen kopieren */
    *(ptr + count) = *ptr;

    /* War es ein Sonderzeichen? Ja, verdoppeln. */
    if (*ptr == '|' || *ptr == ']')
    {
      /* So, ein Sonderzeichen weniger */
      count--;
      *(ptr + count) = *ptr;
    }
    *ptr--;
  }
}
