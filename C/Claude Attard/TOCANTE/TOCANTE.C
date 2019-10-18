/*  D‚velopper sous GEM
    2ø listing d'exemple
    Programmation d'accessoires
  Claude ATTARD pour ST MAG
        F‚vrier 1994
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>

/* Prototypages : */
void main (void);
void open_work (void);
void acc_loop (void);
int ouvre_fenetre (void);
void redraw (int x, int y, int w, int h);
void red_toc (void);
int rc_intersect (GRECT *p1, GRECT *p2);
void set_clip (int clip_flag, GRECT *area);
void litdatesys (void);
void send_redraw (void);
long timer (void);

  /* Macros Maximum et Minimum */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))
  /* D‚finitions TRUE et FALSE */
#define TRUE 1
#define FALSE 0

  /* Variables globales */
int xb, yb, wb, hb; /* Coordonn‚es du bureau */
int ap_id;          /* Identificateur application */
int handle;         /* handle station de travail VDI */
int buf[8];         /* Buffer d'‚v‚nements */
int xf, yf, wf, hf; /* Coordonn‚es fenˆtre */
int hwind = -1;     /* Largeur et hauteur totales, handle */
int heures, minutes, secondes;  /* Pour l'heure courante */
char titre[] = " Tocante ";   /* Titre fenˆtre */
char accname[] = "  Tocante"; /* Titre accessoire */

/***** Fonction main */
void main (void)
{
int flacc = FALSE;  /* Flag d'accessoire actif ou non */
int evnt;           /* Pour les ‚v‚nements */
int quit = FALSE;   /* Pour quitter en mode programme */
long time, old_time;  /* Gestion du temps */
int dummy;

  ap_id = appl_init (); /* D‚clarer l'application au GEM */
  if (! _app)
    menu_register (ap_id, accname); /* D‚clarer et installer l'accessoire */
  wind_get (0, WF_WORKXYWH, &xb, &yb, &wb, &hb);  /* Coordonn‚es du bureau */
  open_work ();         /* Ouvrir station de travail */
  old_time = timer ();

  if (_app)                   /* Si on tourne en mode programme */
  {
    if (! ouvre_fenetre ())   /* Ouvrir la fenˆtre */
    {
      appl_exit (); /* Si fenˆtre pas ouverte, on quitte */
      exit (0);
    }
    graf_mouse (ARROW, 0);  /* Souris en forme de flŠche */
  }

  do    /* BOUCLE PRINCIPALE (SANS FIN EN MODE ACCESSOIRE) */
  {
    if ((! _app)&& (! flacc))  /* Si mode accessoire et inactif */
    {
      acc_loop ();    /* Attendre qu'on l'appelle */
      flacc = TRUE;   /* Accessoire actif */
    }
    else
    {   /* On attend les ‚v‚nements */
      evnt = evnt_multi ((MU_MESAG | MU_TIMER), 2, 1, 1,
                         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                         buf, 10, 0,
                         &dummy, &dummy, &dummy, &dummy, &dummy, &dummy);
      if (evnt & MU_MESAG)      /* Si ‚v‚nement message */
      {
        switch (buf[0])   /* Selon le type de message */
        {
        case WM_REDRAW :    /* Redraw */
          redraw (buf[4], buf[5], buf[6], buf[7]);
          break;
        case AC_OPEN :      /* Ouverture d'accessoire d‚j… ouvert */
        case WM_TOPPED :    /* Fenˆtre au premier plan */
          wind_set (hwind, WF_TOP); /* Mettre la fenˆtre au 1ø plan */
          break;
        case WM_CLOSED :    /* Fenˆtre ferm‚e */
          wind_close (buf[3]);    /* Fermer la fenˆtre */
          wind_delete (buf[3]);   /* D‚truire la fenˆtre */
        case AC_CLOSE :     /* Accessoire ferm‚ par une intervention ext‚rieure */
          hwind = 0;
          if (_app)         /* Si mode programme */
            quit = TRUE;    /* On peut quitter */
          else if (! _app)  /* Si mode accessoire */
            flacc = FALSE;  /* On redevient inactif */
          break;
            /* Nouvelles coordonn‚es : */
        case WM_MOVED :     /* D‚placement fenˆtre */
            /* Nouvelles coordonn‚es : */
          wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
          xf = buf[4];  /* Enregistrer coordonn‚es fenˆtre */
          yf = buf[5];
          wf = buf[6];
          hf = buf[7];
          break;
        }
      }
      else if (evnt == MU_TIMER)  /* Si ‚v‚nement Timer */
      {
        time = timer ();
        if ((time - old_time) > 400)  /* S'il s'est pass‚ 2 secondes */
        {
          litdatesys ();    /* Lire l'heure */
          send_redraw ();   /* redessiner */
          old_time = time;
        }
      }
    }
  } while (! quit);
  appl_exit ();
  exit (0);
}
/*****/
void open_work (void)
{
int i, a, b;

    /* Remplir le tableau intin[] */
  for (i = 0 ; i < 10 ; _VDIParBlk.intin[i++] = 1);
    /* L'identificateur physique d‚pend de la r‚solution */
  _VDIParBlk.intin[0] = Getrez() + 2;
    /* SystŠme de coordonn‚es RC */
  _VDIParBlk.intin[10] = 2;
    /* Handle de la station que l'AES ouvre automatiquement */
  handle = graf_handle (&a, &b, &i, &i);
    /* Ouverture station de travail virtuelle */
  v_opnvwk (_VDIParBlk.intin, &handle, _VDIParBlk.intout);
}
/*****/
void acc_loop (void)
{
int accrun = FALSE;   /* Flag de sortie de boucle */

  do  /* Boucle d'attente d'appel de l'accessoire */
  {
    evnt_mesag (buf); /* Attend un message */
    if (buf[0] == AC_OPEN)  /* Si c'est l'appel de notre accessoire */
      if (ouvre_fenetre ())
        accrun = TRUE;
  } while (! accrun);
}
/*****/
int ouvre_fenetre (void)
{
int w_cell, h_cell, dummy;
int attr = (NAME | CLOSER | MOVER);
int old_hwind;  /* Pour mettre de cot‚ le handle */

  if (hwind == -1)  /* Si la fenˆtre n'a jamais ‚t‚ ouverte */
  {
      /* Taille cellules de caractŠres */
    vst_height (handle, 30, &dummy, &dummy, &w_cell, &h_cell);
    xf = xb + 10; /* Position de d‚part de la fenˆtre */
    yf = yb + 10;
    wf = 10 * w_cell;
    hf = 2 * h_cell;
  }

  old_hwind = hwind;  /* Metteons de cot‚ le handle actuel */
  hwind = wind_create (attr, xf, yf, wf, hf);  /* Cr‚er la fenˆtre */
  if (hwind > 0)   /* Si la fenˆtre a pu ˆtre cr‚e */
  {
    wind_set (hwind, WF_NAME, titre);   /* Titre fenˆtre */
    wind_open (hwind, xf, yf, wf, hf);  /* Ouverture fenˆtre */
    litdatesys ();  /* Lire l'heure systŠme */
    return TRUE;
  }
  else    /* Si la fenˆtre n'a pu ˆtre cr‚e */
  {       /* Pr‚venir l'utilisateur */
    hwind = old_hwind;  /* Restitution de la valeur de hwind */
    form_alert (1, "[3][ Il n'y a plus de fenˆtre| disponible. | Fermez-en S.V.P.][ Suite ]");
    return FALSE;
  }
}
/*****/
void redraw (int x, int y, int w, int h)
{   /* Gestion des redraws */
GRECT r, rd;

  rd.g_x = x;   /* Coordonn‚es rectangle … redessiner */
  rd.g_y = y;
  rd.g_w = w;
  rd.g_h = h;

  v_hide_c (handle);  /* Virer la souris */
  wind_update (BEG_UPDATE);   /* Bloquer les fonctions de la souris */

    /* Demande les coord. et dimensions du 1ø rectangle de la liste */
  wind_get (buf[3], WF_FIRSTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
  while (r.g_w && r.g_h)      /* Tant qu'il y a largeur ou hauteur... */
  {
    if (rc_intersect (&rd, &r)) /* Si intersection des 2 zones */
    {
      set_clip (1, &r);  /* Clipping ON */
      red_toc ();
      set_clip (0, &r);  /* Clipping OFF */
    }
      /* Rectangle suivant */
    wind_get (buf[3], WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
  }
  wind_update (END_UPDATE);   /* D‚bloquer les fonctions de la souris */
  v_show_c (handle, 1);       /* Rappeler la souris */
}
/*****/
void red_toc (void)
{   /* Redraw fenˆtre */
char heure[] = "::", hr[3], mn[3], se[3];
int pxy[4], xw, yw, ww, hw, x, y, wcell, hcell, dummy;

    /* Taille cellules de caractŠres : */
  vst_height (handle, 30, &dummy, &dummy, &wcell, &hcell);
    /* Coordonn‚es zone de travail fenˆtre : */
  wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);

  pxy[0] = xw;                /* Pr‚parer effacement fenˆtre */
  pxy[1] = yw;
  pxy[2] = xw + ww - 1;
  pxy[3] = yw + hw - 1;
  vswr_mode (handle, MD_REPLACE);   /* Dessin en mode Remplacement */
  vsf_color (handle, 0);            /* Couleur blanche */
  v_bar (handle, pxy);              /* "Vider" la fenˆtre */

  y = yw + ((hw - hcell) / 2); /* Positionner l'affichage de la ligne */
  x = xw + ((ww - (8 * wcell)) / 2);
  vst_alignment (handle, 0, 5, &dummy, &dummy); /* Texte en haut … gauche */

  itoa (heures, hr, 10);    /* Conversion des heures en chaŒne */
  if (heures < 10)
    heure[1] = (hr[0] &= ~0x20);
  else
  {
    heure[0] = (hr[0] &= ~0x20);
    heure[1] = (hr[1] &= ~0x20);
  }
  itoa (minutes, mn, 10);   /* Conversion des minutes en chaŒne */
  if (minutes < 10)
    heure[4] = (mn[0] &= ~0x20);
  else
  {
    heure[3] = (mn[0] &= ~0x20);
    heure[4] = (mn[1] &= ~0x20);
  }
  itoa (secondes, se, 10);  /* Conversion des heures secondes en chaŒne */
  if (secondes < 10)
    heure[7] = (se[0] &= ~0x20);
  else
  {
    heure[6] = (se[0] &= ~0x20);
    heure[7] = (se[1] &= ~0x20);
  }

  v_gtext (handle, x, y, heure);
}
/*****/
int rc_intersect (GRECT *p1, GRECT *p2)
{   /* Calcule l'intersection de 2 rectangles */
int tx, ty, tw, th;

  tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
  th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
  tx = max(p2->g_x, p1->g_x);
  ty = max(p2->g_y, p1->g_y);
  p2->g_x = tx;
  p2->g_y = ty;
  p2->g_w = tw - tx;
  p2->g_h = th - ty;
  return ((tw > tx) && (th > ty));
}
/*****/
void set_clip (int clip_flag, GRECT *area)
{   /* Active ou d‚sactive le clipping d'une zone */
int pxy[4];

  pxy[0] = area->g_x;
  pxy[1] = area->g_y;
  pxy[2] = area->g_w + area->g_x - 1;
  pxy[3] = area->g_h + area->g_y - 1;
  vs_clip (handle, clip_flag, pxy);
}
/*****/
void litdatesys ()
{
int time;

  time = Tgettime ();
  secondes = (time & 0x1f) * 2;
  minutes = (time >> 5) & 0x3f;
  heures = (time >> 11) & 0x1f;
}
/*****/
void send_redraw ()
{
int xw, yw, ww, hw;

    /* Coordonn‚es zone de travail fenˆtre : */
  wind_get (hwind, WF_WORKXYWH, &xw, &yw, &ww, &hw);
  buf[0] = WM_REDRAW;
  buf[1] = 0;
  buf[2] = 0;
  buf[3] = hwind;
  buf[4] = xw;
  buf[5] = yw;
  buf[6] = ww;
  buf[7] = hw;
  appl_write (ap_id, 16, buf);
}
/*****/
long timer (void)
{
long save_ssp, time;
  
  save_ssp = Super (0L);
  time = *(long *)0x4BA;
  Super ((void *)save_ssp);
  
  return (time);
}

