/********************************************
	file: events.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1996: C. Moreau: 
	comments: 
*********************************************/

/********************************************
	includes
*********************************************/
#ifdef __PUREC__ 
#include <aes.h>
#include <compend.h>
#else
#include <aesbind.h>
#endif

#include "button.h"	
#include "cursor.h"
#include "events.h"
#include "keys.h"
#include "main.h"
#include "menu.h"
#include "onepage.h"	
#include "slider.h"
#include "wind.h"

/********************************************
	defines
*********************************************/

/********************************************
	locals vars declarations & definitions
*********************************************/
static int edit, pos_edit;

/********************************************
	globals vars declarations
*********************************************/
int message[8];			/* AES message array */
int objet;

/********************************************
	locals functions declarations
*********************************************/
static int xform_do (int *,int *,int *,int *,int *,int *,int *,int *);
static int parent (OBJECT *adr, int object);
static int prev (OBJECT *adr);
static int next (OBJECT *adr);

/********************************************
	globals functions definitions
*********************************************/
/*
	name: TaskMaster
	utility: Handle Application Events.
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void TaskMaster(void)
{
	int event;			/* The event code.					*/
	int	mousex, mousey;	/* The current mouse position.		*/
	int mousebutton;	/* The state of the mouse button    */
	int keymods;		/*  The state of the keyboard modifiers.
							(shift, ctrl, etc). */
	int clicks;			/*	The number of mouse clicks that occurred in the 
							given time. */
	int button = TRUE;	/* desired Button state				*/

	for (;;) 
	{
		putcur();	/* cursor on	*/

		event = xform_do(
 			&button,		/* desired key state						*/
			message,		/* The message buffer 						*/
			&mousex,		/* The x-coordinate of the mouse at event.  */
			&mousey,		/* The y-coordinate of the mouse at event.  */
			&mousebutton,	/* The state of the mouse buttons at event. */
			&keymods,		/* The state of the keyboard modifiers.     */
			&keycode,		/* The key code for the key pressed.        */
			&clicks			/* The number of times the event occurred	*/
		);
		
		putcur();	/* cursor off	*/

		if (event & MU_MESAG) 
		{
			switch (message[0]) 
			{
				/*
					Window Support
				*/
				case WM_REDRAW:
				case WM_TOPPED:
				case WM_FULLED:
				case WM_ARROWED:
				case WM_HSLID:
				case WM_VSLID:
				case WM_SIZED:
				case WM_MOVED:
				case WM_NEWTOP:
				case WM_CLOSED:
				case WM_BOTTOM:
				case WM_ICONIFY:
				case WM_UNICONIFY:
					window_do(message);
					break;

				/*
					Menu Support
				*/
				case MN_SELECTED:
					do_menu(message[3], message[4]);
					button ^= TRUE;	
					break;

				/*
					Desk Accessory Support
				*/
				case AC_OPEN:
				case AC_CLOSE:		break;

				/*
					System Shut down Support
				*/
				case AP_TERM:
					shutdown(0);
			}
		}
		else if (event & MU_KEYBD)
		{
			do_kbd(keycode, keymods);
		}	
		else if (event & MU_BUTTON)
		{
			if(button && thefrontwin)
				do_button(mousex, mousey);
			button ^= TRUE;
		}
	}
}

/********************************************
	locals functions definitions
*********************************************/
/*
	name: xform_do
	utility: Replace form_do of GEM
	comment: 
	parameters:
	return:
	date: january 1994
	author: C. Attard
	modifications:
		1995: C.Moreau: Addapted to XXed
		11 may 96: C.Moreau: Changed order of cursor init when clic on editable
*/
static int xform_do (int *button, int *message,
		 int *mousex, int *mousey, int *mousebutton,
		 int *keymods, int *keycode, int *clicks)
{   
	int evnt;               /* Type d'‚v‚nement */
	int dummy,i;    	    /* Divers */
	int champ;              /* Champ de saisie ‚ditable */

	objet = 0;    /* Mise … z‚ro avant de commencer */

	for (;;)
	{
		evnt = evnt_multi (MU_MESAG | MU_BUTTON | MU_KEYBD, 1, 1, *button,
	                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	                      message, 10, 0, mousex, mousey,
	                      mousebutton, keymods, keycode, clicks);
	
		if (evnt & MU_MESAG)
			return evnt;
			
		if (evnt & MU_KEYBD)    /* Si ‚v‚nement clavier */
		{		/* Si la fenˆtre formulaire est au 1ø plan : */
			if (thefrontwin && thefrontwin->form)
			{
				OBJECT *adr = thefrontwin->form;  /* Adresse formulaire sur lequel on travaille */
				
				if ((*keycode == 0x720D) || (*keycode == 0x1C0D)) /* Si <Return> ou <Enter> */
				{     /* Chercher bouton DEFAULT s'il y en a */
					i = 0;  /* En partant de la racine */
					do    /* Pour chaque objet */
					{
						if (adr[i].ob_flags & DEFAULT)  /* Si objet d‚faut */
						{
							objc_change(adr, i, 0, adr->ob_x, adr->ob_y,
										adr->ob_width, adr->ob_height, SELECTED, REDRAW);
							evnt = MU_BUTTON; /* Modifier type d'‚v‚nement */
							objet = i;        /* Enregistrer l'objet */
							return (evnt);    /* Retourner l'‚v‚nement */
						}
					} while (! (adr[i++].ob_flags & LASTOB)); /* Jusqu'au dernier objet */
				}
				else if (edit)      /* S'il y a un champ ‚ditable */
				{
					if (*keycode == 0x5000)      /* Si flŠche vers le bas */
					{
						champ = next (adr); /* Chercher champ suivant */
						if (champ > -1) /* S'il y en a un */
						{
							objc_edit (adr, edit, 0, &pos_edit, ED_END);   /* D‚sactiver */
							edit = champ;   /* Nouvel ‚ditable */
							objc_edit (adr, edit, 0, &pos_edit, ED_INIT);  /* R‚activer */
						}
					}
					else if (*keycode == 0x4800) /* Si flŠche vers le haut */
					{
						champ = prev (adr); /* Chercher champ pr‚c‚dent */
						if (champ > -1) /* S'il y en a un */
						{
							objc_edit (adr, edit, 0, &pos_edit, ED_END);   /* D‚sactiver */
							edit = champ;   /* Nouvel ‚ditable */
							objc_edit (adr, edit, 0, &pos_edit, ED_INIT);  /* R‚activer */
						}
					}
					else                    /* Si autre touche */
					{   /* Le GEM s'occupe de tout */
						objc_edit (adr, edit, *keycode, &pos_edit, ED_CHAR);
					}
				}
		 	}
		 	else
		 		return evnt;
		}
	
		if (evnt & MU_BUTTON)   /* Si ‚v‚nement clic souris */
		{
			const int whandle = wind_find (*mousex, *mousey);  /* Handle fenˆtre cliqu‚e */

			if (whandle) 	 /* A t-on cliqu‚ sur une fenˆtre ? */
			{ 
				windowptr thewin = findwindowptr(whandle);

				if ( (thewin == thefrontwin) && thewin->form)   /* Si on a cliqu‚ la fenˆtre formulaire de 1ø plan */
				{
					OBJECT *adr = thewin->form;  /* Adresse formulaire sur lequel on travaille */

					objet = objc_find(adr, 0, MAX_DEPTH, *mousex, *mousey); /* Objet cliqu‚ */
					if (objet > -1)     /* Si on a cliqu‚ sur un objet */
					{
						if (adr[objet].ob_state & DISABLED)         /* Si l'objet est d‚sactiv‚ */
							return 0;

						if (! (adr[objet].ob_flags & TOUCHEXIT) )    /* Si ce n'est pas un TOUCHEXIT */
						{
							while (*mousebutton)  /* Attendre bouton souris relach‚ */
								graf_mkstate (&dummy, &dummy, mousebutton, &dummy);
						}
						
						if (adr[objet].ob_flags & SELECTABLE)
						{
							if ( !(adr[objet].ob_flags & RBUTTON) )   /* Si s‚lectable simple */
							{
								adr[objet].ob_state ^= SELECTED;    /* Inverser l'‚tat de l'objet */
								objc_draw (adr, objet, MAX_DEPTH,   /* Redessiner l'objet */
											adr->ob_x, adr->ob_y,
											adr->ob_width, adr->ob_height);
							}
							else if ( !(adr[objet].ob_state & SELECTED) )   /* Si s‚lectable simple */
							{
								int j = objet;                      /* Partir de cet objet */
		
								objc_change(adr, objet, 0, adr->ob_x, adr->ob_y,
											adr->ob_width, adr->ob_height, SELECTED, REDRAW);  /* Le s‚lectionner */
								i = parent (adr, j);        /* Chercher le pŠre */
								j = adr[i].ob_head;         /* Partir du 1ø enfant... */
								i = adr[i].ob_tail;         /* jusqu'au dernier. */
								do
								{
									if ((adr[j].ob_flags & RBUTTON) && (j != objet) &&
										(adr[j].ob_state & SELECTED))
									{   /* Les mettre en normal si RBUTTON sauf l'objet cliqu‚. */
										objc_change(adr, j, 0, adr->ob_x, adr->ob_y,
											 		adr->ob_width, adr->ob_height, NORMAL, REDRAW);
									}
									j = adr[j].ob_next;                       /* Au suivant... */
								} while ((j <= i) && (j > adr[i].ob_next)); /* jusqu'au dernier. */
							}
						}
		
						if (adr[objet].ob_flags & EDITABLE)         /* Si ‚ditable */
						{
							objc_edit (adr, edit, 0, &pos_edit, ED_INIT);  /* R‚activer curseur */
							edit = objet;                     /* Nouvel ‚ditable courant */
							objc_edit (adr, edit, 0, &pos_edit, ED_END);   /* D‚sactiver curseur */
						}
					}
				}
			}
			return evnt;
		}
	}
}

/*
	name: parent
	utility: Cherche le pŠre d'un objet
	comment: 
	parameters:
	return:
	date: january 1994
	author: C. Attard
	modifications:
*/
static int parent (OBJECT *adr, int object)
{   /* Retourne l'objet pŠre d'un objet */
	register int i = object;                     /* Partir de cet objet */

  do
  {
    i = adr[i].ob_next;           /* Passer au suivant... */
  } while (i > object);           /* Jusqu'… revenir au pŠre. */

  return i;                       /* Retourner le pŠre */
}

/*
	name: next
	utility: Chercher l'‚ditable suivant
	comment: 
	parameters:
	return:
	date: january 1994
	author: C. Attard
	modifications:
*/
static int next (OBJECT *adr)
{	 
	int pere, vu = 1, ob = edit;

		/* Tant qu'on n'est pas au dernier objet */
	while ( !(adr[ob++].ob_flags & LASTOB) )
	{   
		pere = parent (adr, ob);  /* Chercher son pŠre */
			/* Si ce n'est pas la racine et pas HIDETREE */
		while ( (pere > 0) && (vu) )
		{   	/* Si le pŠre est HIDETREE */
			if (adr[pere].ob_flags & HIDETREE)
				vu = 0;   /* l'objet n'est pas visible */
			pere = parent (adr, pere);  /* PŠre suivant */
		}
		if (vu) /* Si l'objet est visible */
			if ( (adr[ob].ob_flags & EDITABLE) && 
				 ( !(adr[ob].ob_flags & HIDETREE) ) &&
				 ( !(adr[ob].ob_state & DISABLED) ) )  /* Si ‚ditable actif */
				return ob;  /* Retourner son num‚ro */
  }
  return -1;  /* Sinon, -1 */
}

/*
	name: prev
	utility: Chercher l'‚ditable pr‚c‚dent
	comment: 
	parameters:
	return:
	date: january 1994
	author: C. Attard
	modifications:
*/
static int prev (OBJECT *adr)
{  
int pere, vu = 1, ob = edit;

  while (ob-- > 0)    /* En arriŠre jusqu'… la racine */
  {
    pere = parent (adr, ob);    /* PŠre de l'objet */
      /* Si ce n'est pas la racine et pas HIDETREE */
    while ((pere > 0) && (vu))
    {   /* Si le pŠre est HIDETREE */
      if (adr[pere].ob_flags & HIDETREE)
        vu = 0;   /* L'objet n'est pas visible */
      pere = parent (adr, pere);  /* PŠre suivant */
    }
    if (vu) /* Si l'objet est visible */
      if ((adr[ob].ob_flags & EDITABLE) &&
          (! (adr[ob].ob_flags & HIDETREE)) &&
          (! (adr[ob].ob_state & DISABLED)))  /* Si ‚ditable actif */
        return ob;  /* Retourner son num‚ro */
  }
  return -1;  /* Sinon, -1 */
}
