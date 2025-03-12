/* ---------------------------------------------
   Flexible Alertbox
   =================

   Autor: Dietmar Rabich
   (c) 1992 MAXON Computer
   Entwicklungssystem: Pure-C
--------------------------------------------- */

/* Header */
#include <aes.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <ctype.h>
#include "alert.h"

/* Makros */
#define max(x, y)   (((x) > (y)) ? (x) : (y))

#define NIL         -1

#define BACKBOX     alertref[0]
#define BUTTON      alertref[1]
#define STRING      alertref[2]
#define BITBLOCK    alertref[3]

#define MAXTEXTLINES        18
#define TEXTWIDTH           29
#define TEXTHEIGHT          1
#define BITBLKWIDTH         4
#define BITBLKHEIGHT        2
#define ALERTWIDTH          38
#define BORDERWIDTH         2
#define BUTTONHEIGHT        1
#define INNERBORDERWIDTH    1
#define BORDERHEIGHT        1

/* modullokale Variablen */
static OBJECT alertref[] =
{
  { /* Objekt fr Root (Hintergrund) */
    NIL, 1, 4, G_BOX, NONE, OUTLINED,
    0x21100L, 2,  1,  38, 6
  },
  { /* Objekt fr Button */
    3, NIL, NIL, G_BUTTON, SELECTABLE | EXIT,
    NORMAL, 0L, 27, 4,  9,  1
  },
  { /* Objekt fr Textzeile */
    4, NIL, NIL, G_STRING, NONE,
    NORMAL, 0L, 27, 1,  6,  1
  },
  { /* Objekt fr Bitblock */
    0, NIL, NIL, G_IMAGE, NONE,
    NORMAL, 0L, 2,  1,  4,  2
  }
};

/* Beispielbitblock */
static int highres[] =
{
  0x1FFF, 0xFFE0, 0x7FFF, 0xFFF0, 0x6000,
  0x0038, 0xDFFF, 0xFFD8, 0xDFFF, 0xFFDC,
  0xDFFF, 0xFFDE, 0xDFFF, 0xFFDF, 0xC000,
  0x001F, 0xDF7D, 0xF7DF, 0xD145, 0x145F,
  0xD145, 0x145F, 0xDF7D, 0xF7DF, 0xC000,
  0x001F, 0xDF7D, 0xF7DF, 0xD145, 0x145F,
  0xD145, 0x145F, 0xDF7D, 0xF7DF, 0xC000,
  0x001F, 0xDF7D, 0xF7DF, 0xD145, 0x145F,
  0xD145, 0x145F, 0xDF7D, 0xF7DF, 0xC000,
  0x001F, 0xDF7D, 0xF7DF, 0xD145, 0x145F,
  0xD145, 0x145F, 0xDF7D, 0xF7DF, 0x6000,
  0x003F, 0x7FFF, 0xFFFF, 0x1FFF, 0xFFFE,
  0x07FF, 0xFFFE, 0x03FF, 0xFFF8
};

static BITBLK calc[] =
{
  {highres,   4,  32, 0,  0,  0x0001}
};

/* Prototypen */
static void  sizeandpos(OBJECT*, int, int,
                        BITBLK*, int, int);
static void  build1(OBJECT*, BITBLK*, int*,
                    int*, int*, int, int,
                    char*, char*, int, int*);
static void  build2(OBJECT*, int);
static int   counttokens(char*);
static char* taketoken(char*);
static void  tokens(char*, int);
static int   _do_alert(OBJECT*);

BITBLK* BitblkCalculator(void)
{
  return(calc);
}

/* Tokens z„hlen */
static int counttokens(char *s)
{
  register int    ret;
  char            *c;

  /* Trennstriche z„hlen */
  for(ret = 1, c = s; *c; c++)
    if(*c == '|')
      ret++;

  return(ret);
}

/* n„chstes Token holen */
static char* taketoken(char *s)
{
  static char *c;
  char        *cptr, *c2;

  /* String bergeben? Dann c setzen! */
  if(s)
    c = s;

  /* String am Ende? Dann Schluž! */
  if(!*c)
    return(NULL);

  /* Bis Stringende oder Trennzeichen */
  /* durchlaufen! */
  cptr    = c;
  while(*cptr && (*cptr != '|'))
    cptr++;

  /* Fein! Trennzeichen gefunden! */
  if(*cptr == '|')
  {
    *cptr = 0;      /* Trennung durch 0! */
    c2    = cptr;   /* Stringende merken */
    cptr  = c;      /* cptr auf Stringanfang */
    c     = c2 + 1; /* Weitersuche ab */
                    /* folgendem Stringanfang */
  }

  /* String schon am Ende?! */
  else
  {
    c2   = cptr; /* Stringende merken */
    cptr = c;    /* Stringanfang in cptr */
    c    = c2;   /* Endekennung = 0 */
  }

  /* Pointer auf Teilzeichenkette zurck! */
  return(cptr);
}

/* String tokenisieren */
static void tokens(char *s, int len)
{
  register int ret = 0;
  char         *c, *stc, *memc;

  /* Leerer String? Dann ist eine */
  /* Untersuchung wohl unsinnig! */
  if(!s[0])
    return;

  /* String untersuchen */
  for(c = s; *c; c++)
  {
    ret++;

    /* erstes Zeichen oder Leerzeichen? */
    if(ret == 1)
      memc = stc = c;

    if(isspace(*c))
      memc    = c;

    /* Trennungszeichen? Harter Umbruch? */
    /* Dann Z„hlung neu beginnen und */
    /* weiter...  */
    if(*c == '|')
    {
      ret = 0;
      continue;
    }

    /* Kritische L„nge erreicht? */
    if(ret > len)
    {
      c   = memc;

      /* Kein Leerzeichen? */
      /* Dann Wort unterbrechen! */
      if(!isspace(*memc))
      {
        char    *c2;

        c   += len;
        c2  = strdup(c);
        if(c2)
        {
          strcpy(c + 1, c2);
          free(c2);
        }
      }

      /* An die Fundstelle geh”rt */
      /* ein Trennungszeichen! */
      ret = 0;
      *c  = '|';
    }
  }

  /* šberflssige Trennzeichen */
  /* am Ende entfernen! */
  c = strrchr(s, 0) - 1;
  while((*c == '|') && (c >= s))
    *(c--) = 0;

  /* šberflssige Trennzeichen */
  /* am Anfang entfernen! */
  c = s + strspn(s, "|");
  stc = strdup(c);
  if(stc)
  {
    strcpy(s, stc);
    free(stc);
  }
}

/* Ausgabe der Alertbox */
static int _do_alert(OBJECT *tree)
{
  int ret, x, y, w, h;

  wind_update(BEG_UPDATE);
  wind_update(BEG_MCTRL);
  graf_mouse(ARROW, NULL);
  form_center(tree, &x, &y, &w, &h);
  form_dial(FMD_START, x, y, w, h, x, y, w, h);
  objc_draw(tree, ROOT, MAX_DEPTH, x, y, w, h);
  ret = form_do(tree, ROOT) & 0x7FFF;
  form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
  wind_update(END_MCTRL);
  wind_update(END_UPDATE);

  return(ret);
}

/* Gr”že und Position festlegen */
static void sizeandpos(OBJECT *tree,
                       int    maxtext,
                       int    maxbutton,
                       BITBLK *bitblk,
                       int    cnttext,
                       int    cntbutton)
{
  int     xpos, i;
  OBJECT  *obj;

  obj = tree;

  /* Hintergrund */
  {
    int max1, max2;

    max1 = BORDERWIDTH + maxtext +
           (bitblk ? (INNERBORDERWIDTH +
           BITBLKWIDTH) : 0);
    max2 = cntbutton *
           (maxbutton + BORDERWIDTH);
    obj->ob_width      = BORDERWIDTH +
                         max(max1, max2);
    (obj++)->ob_height = (3 * BORDERHEIGHT +
                        BUTTONHEIGHT) + cnttext;
  }

  /* ggf. Bitblock */
  if(bitblk)
  {
    obj->ob_x          = BORDERWIDTH;
    obj->ob_y          = BORDERHEIGHT;
    obj->ob_width      = BITBLKWIDTH;
    (obj++)->ob_height = BITBLKHEIGHT;
  }

  /* Texte */
  i = 1;
  for(;;)
  {
    if(obj->ob_type != G_STRING)
      break;
    obj->ob_x = BORDERWIDTH + (bitblk ?
                (BITBLKWIDTH +
                INNERBORDERWIDTH) : 0);
    obj->ob_y = i++;
    obj->ob_width = maxtext;
    (obj++)->ob_height  = TEXTHEIGHT;
  }
  i++;

  /* Buttons */
  xpos = tree[0].ob_width - cntbutton *
         (maxbutton + BORDERWIDTH);
  for(;;)
  {
    obj->ob_x       = xpos;
    obj->ob_y       = i;
    obj->ob_width   = maxbutton;
    obj->ob_height  = BUTTONHEIGHT;
    if(obj->ob_flags & LASTOB)
      break;
    obj++;
    xpos    += maxbutton + BORDERWIDTH;
  }
}

/* Aufbau Teil 1 */
static void build1(OBJECT *tree,
                   BITBLK *bitblk,
                   int    *treecnt,
                   int    *maxtext,
                   int    *maxbutton,
                   int    cnttext,
                   int    cntbutton,
                   char   *text,
                   char   *buttons,
                   int    bdefault,
                   int    *firstbutton)
{
  OBJECT *obj;
  int    i;
  char   *c;
  size_t l;

  *treecnt = 0;

  /* Hintergrund setzen */
  tree[(*treecnt)++]  = BACKBOX;

  /* ggf. Bitblock setzen */
  if(bitblk)
  {
    tree[(*treecnt)] = BITBLOCK;
    tree[(*treecnt)++].ob_spec.bitblk = bitblk;
  }

  /* alle Texte setzen */
  obj = tree + *treecnt;
  for(i = 0; i < cnttext; i++)
    tree[(*treecnt)++]  = STRING;
  *maxtext = 0;
  c        = taketoken(text);
  for(;;)
  {
    if(!c)
      break;
    l = strlen(c);
    if((*maxtext) < (int)l)
      *maxtext = (int)l;
    (obj++)->ob_spec.free_string = c;
    c   = taketoken(NULL);
  }

  /* alle Buttons setzen */
  obj          = tree + *treecnt;
  *firstbutton = *treecnt;

  for(i = 0; i < cntbutton; i++)
    tree[(*treecnt)++]  = BUTTON;

  /* Defaultbutton */
  if(bdefault >= 0)
    obj[bdefault].ob_flags |= DEFAULT;

  *maxbutton = 0;
  c          = taketoken(buttons);
  for(;;)
  {
    if(!c)
      break;
    l   = strlen(c);
    if((*maxbutton) < (int)l)
      *maxbutton  = (int)l;
    (obj++)->ob_spec.free_string = c;
    c   = taketoken(NULL);
  }
}

/* Aufbau Teil 2 */
static void build2(OBJECT *tree, int treecnt)
{
  int i;

  /* Verkettung */
  tree[0].ob_next = NIL;
  tree[0].ob_head = 1;
  tree[0].ob_tail = treecnt - 1;
  for(i = 1; i < treecnt; i++)
  {
    tree[i].ob_next = i + 1;
    tree[i].ob_head =
    tree[i].ob_tail = NIL;
  }
  tree[treecnt - 1].ob_flags |= LASTOB;
  tree[treecnt - 1].ob_next  = ROOT;
}

/* Hauptalertroutine */
int do_alert(BITBLK     *bitblk,
             const char *otext,
             const char *obuttons,
             int        bdefault)
{
  OBJECT *tree;
  char   *text, *buttons;
  int    cnttext, cntbutton, objused, treecnt,
         firstbutton, maxtext, maxbutton, ret;

  /* Kopien anlegen */
  text    = strdup(otext);
  if(!text)
    return(-1);
  buttons = strdup(obuttons);
  if(!buttons)
  {
    free(text);
    return(-1);
  }

  /* Teilstcke z„hlen */
  tokens(text,
         TEXTWIDTH + (bitblk ? 0 :
         (INNERBORDERWIDTH + BITBLKWIDTH)));
  cnttext     = counttokens(text);
  cntbutton   = counttokens(buttons);

  if(cnttext >= MAXTEXTLINES)
  {
    free(text);
    free(buttons);
    return(-2);
  }

  /* Anzahl der Objekte */
  objused = cnttext + cntbutton +
            (bitblk ? 2 : 1);

  /* Speicher fr Objektbaum */
  tree = malloc(((long) objused) *
                 sizeof(OBJECT));
  if(!tree)
  {
    free(text);
    free(buttons);
    return(-1);
  }

  /* Objecttree aufbauen */
  build1(tree, bitblk, &treecnt, &maxtext,
         &maxbutton, cnttext, cntbutton, text,
         buttons, bdefault, &firstbutton);

  if(((maxbutton + BORDERWIDTH) * cntbutton +
      BORDERWIDTH) > ALERTWIDTH)
  {
    free(tree);
    free(text);
    free(buttons);
    return(-3);
  }

  /* Verkettung */
  build2(tree, treecnt);

  /* Gr”žen */
  sizeandpos(tree, maxtext, maxbutton, bitblk,
             cnttext, cntbutton);

  {
    int i;
    for(i = 0; i < treecnt;
        rsrc_obfix(tree, i++));
  }

  ret = _do_alert(tree);
  if(ret >= 0)
    ret -= firstbutton;

  free(tree);
  free(buttons);
  free(text);

  return(ret);
}
