/* Wohldesignte Alertbox. Nicht so ein TOS-Schund. */
/*****************************************************************************
*
*                                   7UP
*                              Modul: FALERT.C
*                        (c) by Geiû & TheoSoft '92
*
*****************************************************************************/
#define RSRC_CREATE
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <tos.h>

static OBJECT *alert_tree;

#include "falert3d.h"
#include "falert3d.rh"
#include "falert3d.rsh"

/****** DEFINES **************************************************************/

#define MAX_HEIGHT    10
#define NUM_SEP       5                 /* Anzahl Separatoren */
#define SEP_OPEN      '['               /* Zeichen fÅr Separator offen */
#define SEP_CLOSE     ']'               /* Zeichen fÅr Separator geschlossen */
#define SEP_LINE      '|'               /* Zeichen fÅr Zeilentrenner */
#define MINBUT        7                 /* Mindestens 6 Buchstaben fÅr Buttons */
#define FLAGS15 0x8000
/*****************************************************************************/

int form_exhndl(OBJECT *tree, int start, int mode);
int form_fix(OBJECT *tree, int mode);

static void fix_tree(int n_tree)
{
  register int tree,     /* index for trees */
               object;   /* index for objects */
  OBJECT       *pobject;

  for (tree = 0; tree < n_tree; tree++) /* fix trees */
  {
    object  = 0;
    pobject = rs_trindex [tree];
    do
    {
      rsrc_obfix(pobject,object);
    }
    while (! (pobject [object++].ob_flags & LASTOB));
  } /* for */
} /* fix_tree */

#undef RSRC_CREATE
/*****************************************************************************/

GLOBAL WORD form_alert (int def, const char *alertmsg)
{
	static int first=TRUE;

	WORD    ret, i, x, w, w1, w2, xdiff;
	WORD    image, bell=FALSE, gl_wbox, gl_hbox;
	WORD    maxstr, num_str, maxbut, num_buttons, lenbut;
	BYTE    *p, *s;
	char    str[51];
	
	graf_handle(&gl_wbox,&gl_hbox,&ret,&ret);
	
	if(first)
	{
		fix_tree(NUM_TREE);
		alert_tree =(OBJECT *)rs_trindex[ROOT];
		form_fix(alert_tree,TRUE);
		first=FALSE;
	}
	alert_tree->ob_x=alert_tree->ob_y=0;

	w       = alert_tree [ASTRING0].ob_width / gl_wbox;
	
	p = strchr (alertmsg, SEP_OPEN) + 1;
	sscanf (p, "%d", &image);                             /* Image einlesen */
	if(image == 3) bell=TRUE;

   for(i=IMAGE0M; i<=IMAGE3D; i++)
		alert_tree[i].ob_flags|=HIDETREE;
   
	alert_tree[IMAGE0D+2*image].ob_flags&=~HIDETREE;
	alert_tree[IMAGE0M+2*image].ob_flags&=~HIDETREE;

	if(mindestens_16_Farben()) /* Hintergrundfarben setzen */
	{
		if(image == 0 || image == 3)
		   alert_tree[IMAGE0M+2*image].ob_spec.bitblk->bi_color=WHITE;
		if(image == 1 || image == 2)
		   alert_tree[IMAGE0M+2*image].ob_spec.bitblk->bi_color=BLACK;
   }
   else
	   alert_tree[IMAGE0M+2*image].ob_spec.bitblk->bi_color=WHITE;
   
	alert_tree[IMAGE0M+2*image].ob_y=alert_tree[IMAGE0M].ob_y; /* positionieren */
	alert_tree[IMAGE0D+2*image].ob_y=alert_tree[IMAGE0D].ob_y; /* positionieren */
	
	maxstr = 0;
	p      = strchr (p, SEP_OPEN) + 1;
	i      = ASTRING0;
	num_str= 0;

	while (*p != SEP_CLOSE)                       /* Strings verarbeiten */
	{
		s = str;

		alert_tree[i].ob_flags&=~HIDETREE;

		while (((*p != SEP_CLOSE) || (p [1] != SEP_OPEN)) && (*p != SEP_LINE)) *s++ = *p++;
		
		*s      = EOS;
		str [w] = EOS;
		strcpy ((BYTE *)alert_tree [i].ob_spec.index, str);
		maxstr = max (maxstr, strlen (str));
		i++;
		num_str++;
		if (*p != SEP_CLOSE) p++;
	} /* while */

	maxstr+=2; /* zwei Zeichen dazu, wg. Rand rechts */
	
	while (alert_tree [i].ob_type == G_STRING) 
		alert_tree[i++].ob_flags|=HIDETREE;

	p = strchr (p, SEP_OPEN) + 1;
	i = BUTTON0;
	
	do                                            /* Buttons verstecken */
	{
		alert_tree[i].ob_flags|=(HIDETREE|EXIT);
		alert_tree[i].ob_flags&=~DEFAULT;
		alert_tree[i].ob_state&=~DISABLED;
	} while (! (alert_tree[i++].ob_flags & LASTOB));

	maxbut      = 0;
	i           = BUTTON0;
	num_buttons = 0;

	while (*p != SEP_CLOSE)                       /* Buttons verarbeiten */
	{
		s = (char *)((TEDINFO *)alert_tree[i].ob_spec.userblk->ub_parm)->te_ptext;

		alert_tree[i].ob_flags&=~HIDETREE;

		while ((*p != SEP_CLOSE) && (*p != SEP_LINE)) *s++ = *p++;
		
		*s     = EOS;
		
		lenbut=
			(int)((TEDINFO *)alert_tree[i].ob_spec.userblk->ub_parm)->te_txtlen=
			strlen((char *)((TEDINFO *)alert_tree[i].ob_spec.userblk->ub_parm)->te_ptext);
		
		if(strchr((char *)((TEDINFO *)alert_tree[i].ob_spec.userblk->ub_parm)->te_ptext,'_'))
			lenbut--;
		maxbut = max (maxbut, lenbut);
		i++;
		num_buttons++;
		if (*p != SEP_CLOSE) p++;
	} /* while */

	if (def != 0)
	{
		def += BUTTON0 - 1;
		alert_tree[def].ob_flags|=DEFAULT;
	} /* if */
	
	maxbut = max (maxbut, MINBUT);               /* Minimale Breite der Knîpfe */

	for (i = BUTTON0, x = 2*gl_wbox, maxbut += 2; i - BUTTON0 < num_buttons; i++)
	{
		alert_tree [i].ob_x     = x;
		alert_tree [i].ob_width = maxbut * gl_wbox;
		x += (maxbut + 1) * gl_wbox;
	} /* for */
	
	alert_tree->ob_height= MAX_HEIGHT*gl_hbox - (NUM_SEP-max(3,num_str))*gl_hbox;
	w1                   = alert_tree [ASTRING0].ob_x + maxstr * gl_wbox;
	w2                   = alert_tree [BUTTON0 + num_buttons - 1].ob_x + maxbut * gl_wbox + gl_wbox;
	alert_tree->ob_width = gl_wbox + max (w1, w2);
	alert_tree[ROOT+1].ob_x=alert_tree->ob_width-gl_hbox-3; /* Eselsohr */
	
	if(gl_hbox<=8)
	alert_tree[ROOT+1].ob_x-=gl_hbox;
	
	for (i = BUTTON0; i - BUTTON0 < num_buttons; i++)
		alert_tree [i].ob_y  = alert_tree->ob_height - (2*gl_hbox+4) - 1;
	
	if (w1 > w2)             /* Buttons zentrieren */
	for (i = BUTTON0; i - BUTTON0 < num_buttons; i++)
		alert_tree [i].ob_x += (w1 - w2) / 2;

	i=BUTTON0+num_buttons-1; /* Buttons rechtsbÅndig... */
	xdiff= alert_tree->ob_width -
		(alert_tree[i].ob_x + alert_tree[i].ob_width) - (3*gl_wbox-4);
	if(xdiff>0) 
		for (i = BUTTON0; i - BUTTON0 < num_buttons; i++)
			alert_tree [i].ob_x += xdiff;

	form_center (alert_tree, &ret, &ret, &ret, &ret);
	
	alert_tree->ob_flags|=FLAGS15; /* kein Windial!!!, weil kein Handle mehr frei*/
	  
	if(bell) Bconout(2,7);
	graf_mouse(ARROW,NULL);
	return((form_exhndl(alert_tree,0,0)&0x7FFF)-BUTTON0+1);
} /* open_alert */
