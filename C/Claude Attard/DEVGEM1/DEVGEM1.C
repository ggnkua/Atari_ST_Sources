/*  D‚velopper sous GEM
    1ø listing d'exemple
    Gestion par xform_do()
  Claude ATTARD pour ST MAG
        Janvier 1994
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "devgem1.h"

/* #[ Prototypage :                             */
void main (void);
void open_work (void);
void afficher_alerte (int index);
void formulaire (void);
void wind_form (void);
void afficher_dessin (void);
void afficher_texte (void);
void redraw (int x, int y, int w, int h);
void red_dessin (void);
void red_texte (void);
int rc_intersect (GRECT *p1, GRECT *p2);
void set_clip (int clip_flag, GRECT *area);
void fulled (void);
void arrow (void);
void hslider (void);
void vslider (void);
void sliders (void);

int xform_do (int flags, OBJECT *address);
int parent (OBJECT *adr, int object);
int next (OBJECT *adr);
int prev (OBJECT *adr);
void stdkey (unsigned char *k);
char *trim (char *str);
int m_title (OBJECT *adresse, int option);
/* #] Prototypage :                             */ 
/* #[ D‚finitions et globales :                 */
  /* Macros Maximum et Minimum */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))

  /* Variables globales */
int xb, yb, wb, hb; /* Coordonn‚es du bureau */
int ap_id;          /* Identificateur application */
int handle;         /* handle station de travail VDI */
int buf[8];         /* Buffer d'‚v‚nements */
int mx, my, mk, kbd, key, clik; /* Gestion des formulaires */
int edit = 0, pos;      /* Champ ‚ditable, position curseur */
int objet;          /* Objet cliqu‚ */
char *titre[] = {" Titre de la fenˆtre Dessin ",
                 " Titre de la fenˆtre Texte ",
                 " Formulaire en fenˆtre "};
char *infos[] = {" Infos de la fenˆtre Dessin ",
                 " Infos de la fenˆtre Texte "};
int lin = 0, col = 0;   /* 1ø ligne et colonne fenˆtres texte */
int ful[2] = {0, 0};    /* Flag pour le traitement du "plein ‚cran" */
int lt, ht, hwind[3] = {0, 0, 0}; /* Largeur et hauteur totales, handles */
  /* Dans ces tableaux, l'index 0 correspond … la fenˆtre Dessin,
                        l'index 1 correspond … la fenˆtre Texte et
                        l'index 2 correspond … la fenˆtre formulaire.
  */
int cont_dessin = 1;    /* Pour la fenˆtre dessin */
int cont_texte = 7;     /* Pour la fenˆtre texte */

OBJECT *adr_menu;     /* Adresse du menu */
OBJECT *adr_desk;     /* Adresse du bureau */
OBJECT *adr_formwin;  /* Adresse formulaire en fenˆtre */
/* #] D‚finitions et globales :                 */ 

/* #[ Main :                                                          */
void main (void)
{
int x, y, w, h;     /* Pour centrer le formulaire en fenˆtre */
int xw, yw, ww, hw; /* Coordonn‚es zone de travail fenˆtre */
int quit = 0;       /* Flag pour quitter */
int event, i;       /* Type d'‚v‚nement, index de boucle */

  ap_id = appl_init (); /* D‚clarer l'application au GEM */
  open_work ();         /* Ouvrir station de travail */
  rsrc_load ("DEVGEM1.RSC");        /* Charger le ressource */
  rsrc_gaddr (0, BUREAU, &adr_desk);  /* Demander adresse bureau */
  wind_get (0, WF_WORKXYWH, &xb, &yb, &wb, &hb);  /* Coordonn‚es du bureau */
  adr_desk->ob_x = xb;        /* Mettre le bureau aux bonnes dimensions */
  adr_desk->ob_y = yb;
  adr_desk->ob_width = wb;
  adr_desk->ob_height = hb;
  wind_set (0, WF_NEWDESK, adr_desk, 0);  /* Fixer le nouveau bureau */
  form_dial (FMD_FINISH, 0, 0, 0, 0, xb, yb, wb, hb); /* et l'afficher */

  rsrc_gaddr (0, MENU, &adr_menu);  /* Demander adresse menu */
  menu_bar (adr_menu, 1);           /* Afficher le menu */
  graf_mouse (ARROW, 0);            /* Souris : forme de flŠche */

  rsrc_gaddr (0, FORMWIND, &adr_formwin); /* Adresse formulaire en fenˆtre */
  form_center (adr_formwin, &x, &y, &w, &h);  /* Centrer le formulaire */

  do    /* BOUCLE PRINCIPALE DU PROGRAMME */
  {   /* Appel fonction xform_do() qui gŠre le bureau */
    event = xform_do ((MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER), adr_desk);
    if (event & MU_MESAG)         /* SI EVENEMENT DE MESSAGE */
    {
      if (buf[0] == MN_SELECTED)    /* Si message de menu */
      { /* Nous inversons le titre de menu en cas d'appel par le clavier */
        menu_tnormal (adr_menu, buf[3], 0);
        switch (buf[4])   /* Selon l'option de menu cliqu‚e */
        {
        case INFORMATIONS : /* Si c'est "Infos", afficher une alerte */
          afficher_alerte (INFOS);
          break;
        case FORMN :        /* Si c'est "Formulaire normal" */
          formulaire ();  /* Afficher un formulaire */
          break;
        case FORMW :        /* Si c'est "Formulaire fenˆtre" */
          wind_form ();
          break;
        case FENETRED :     /* Si c'est "Fenˆtre dessin" */
          afficher_dessin ();
          break;
        case FENETRET :     /* Si c'est "Fenˆtre texte" */
          afficher_texte ();
          break;
        case QUITTER :      /* Si c'est "Quitter" */
          quit = 1;
          break;
        }
        menu_tnormal (adr_menu, buf[3], 1); /* R‚inverser le titre de menu */
      }
      else if (buf[0] == WM_REDRAW)   /* Si message de redraw */
      {
        redraw (buf[4], buf[5], buf[6], buf[7]);
      }
      else if (buf[0] == WM_TOPPED)   /* Si message de Top */
      {
        wind_set (buf[3], WF_TOP);  /* Mettre la fenˆtre au 1ø plan */
      }
      else if (buf[0] == WM_CLOSED)   /* Si message de close */
      {
        wind_close (buf[3]);    /* Fermer la fenˆtre */
        wind_delete (buf[3]);   /* D‚truire la fenˆtre */
        if (buf[3] == hwind[0])   /* Selon la fenˆtre concern‚e */
        {
          hwind[0] = 0;   /* Noter que la fenˆtre a ‚t‚ ferm‚e */
        }
        else if (buf[3] == hwind[1])
        {
          hwind[1] = 0;
        }
        else if (buf[3] == hwind[2])
        {
          hwind[2] = 0;
        }
      }
      else if (buf[0] == WM_FULLED)   /* Si message de full */
      {
        fulled ();
      }
      else if (buf[0] == WM_ARROWED)  /* Si message d'ascenseur */
      {
        arrow ();
      }
      else if (buf[0] == WM_HSLID)    /* Si message de slider H */
      {
        hslider ();
      }
      else if (buf[0] == WM_VSLID)    /* Si message de slider V */
      {
        vslider ();
      }
      else if (buf[0] == WM_SIZED)    /* Si message de size */
      {
          /* Nouvelles coordonn‚es : */
        wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
        if (buf[3] == hwind[0])   /* Selon la fenˆtre concern‚e */
        {
          ful[0] = 0;             /* Annuler le flag de pleine ouverture */
        }
        else if (buf[3] == hwind[1])
        {
          ful[1] = 0;
          sliders ();
        }
      }
      else if (buf[0] == WM_MOVED)    /* Si message de move */
      {
          /* Nouvelles coordonn‚es : */
        wind_set (buf[3], WF_CURRXYWH, buf[4], buf[5], buf[6], buf[7]);
        if (buf[3] == hwind[0])   /* Selon la fenˆtre concern‚e */
        {
          ful[0] = 0;             /* Annuler le flag de pleine ouverture */
        }
        else if (buf[3] == hwind[1])
        {
          ful[1] = 0;
        }
        else if (buf[3] == hwind[2])  /* Si fenˆtre formulaire */
        {   /* Coordonn‚es zone de travail */
          wind_get (hwind[2], WF_WORKXYWH, &xw, &yw, &ww, &hw);
          adr_formwin->ob_x = xw; /* Nelles coordonn‚es du formulaire */
          adr_formwin->ob_y = yw;
        }
      }
    }
    else if (event & MU_BUTTON)   /* SI EVENEMENT DE CLIC SOURIS */
    {
      if (objet == FW_OK)
      {   /* Si on a confirm‚ dans le formulaire en fenˆtre */
        for (i = T1 ; i <= T3 ; i++)  /* Noter la trame choisie */
        {
          if (adr_formwin[i].ob_state & SELECTED)
            cont_dessin = i - T1 + 1; /* Nø de la trame */
        }
        cont_texte = 0;   /* Noter les options de texte s‚lectionn‚es */
          /* Masque de bit : */
        if (adr_formwin[NFEN].ob_state & SELECTED)
          cont_texte |= 0x01; /* Bit 0 : Handle fenˆtre */
        if (adr_formwin[NLIG].ob_state & SELECTED)
          cont_texte |= 0x02; /* Bit 1 : Nø ligne */
        if (adr_formwin[REMP].ob_state & SELECTED)
          cont_texte |= 0x04; /* Bit 2 : Remplissage */

        for (i = 0 ; i < 2 ; i++) /* Pour les deux fenˆtres */
        {
          if (hwind[i] > 0)     /* Si la fenˆtre est ouverte */
          {   /* On s'envoie … soi-mˆme un message de redraw */
            buf[0] = WM_REDRAW;   /* Num‚ro du message */
            buf[1] = ap_id; /* Indentificateur exp‚diteur du message */
            buf[2] = 0;     /* Pas d'exc‚dent au message */
            buf[3] = hwind[i];  /* Handle fenˆtre concern‚e */
            buf[4] = xb;    /* Cordonn‚e zone redraw (bureau) */
            buf[5] = yb;
            buf[6] = wb;
            buf[7] = hb;
            appl_write (ap_id, 16, buf);  /* Envoi du message */
          }
        }
          /* R‚inverser le bouton */
        objc_change (adr_formwin, FW_OK, 0, xb, yb, wb, hb, 0, 1);
      }
    }
  } while (quit == 0);

    /* Avant de quitter l'application : */
  for (i = 0 ; i < 3 ; i++) /* Pour chaque fenˆtre */
  {
    if (hwind[i] > 0) /* Si la fenˆtre est encore ouverte */
    {
      wind_close (hwind[i]);    /* La fermer */
      wind_delete (hwind[i]);   /* La d‚truire */
    }
  }
  menu_bar (adr_menu, 0);         /* Virer la barre de menu */
  wind_set (0, WF_NEWDESK, 0, 0); /* Rendre le bureau */
  rsrc_free ();                   /* Lib‚rer le ressource */
  appl_exit ();                   /* Quitter */
}
/* #] Main :                                                          */ 
/* #[ Open_work :                                                     */
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
/* #] Open_work :                                                     */ 
/* #[ Afficher alerte :                                               */
void afficher_alerte (int index)
{
char *alrt;

  rsrc_gaddr (R_FRSTR, index, &alrt); /* Adr chaŒne pointeur sur pointeur */
  alrt = *((char **)alrt);            /* Pointeur sur le texte */
  form_alert (1, alrt);               /* Afficher l'alerte */
}
/* #] Afficher alerte :                                               */ 
/* #[ formulaire normal :                                             */
void formulaire (void)
{     /* Gestion du "Formulaire normal" */
int i, sel, retour, x, y, w, h, fin = 0, valeur;
OBJECT *adr;
char txt1[11], txt2[11], alrt[200], *resultat, nbre[4];

  rsrc_gaddr (0, FORMULAIRE, &adr);   /* Demander adresse formulaire */
  strcpy (adr[EDIT1].ob_spec.tedinfo->te_ptext, "");  /* Vider ‚ditables */
  strcpy (adr[EDIT2].ob_spec.tedinfo->te_ptext, "");
  form_center (adr, &x, &y, &w, &h);  /* Centrer le formulaire */
  wind_update (BEG_MCTRL);                /* Bloquer menu */
  form_dial (FMD_START, 0, 0, 0, 0, x, y, w, h);  /* Pr‚parer l'affichage */
  objc_draw (adr, 0, MAX_DEPTH, x, y, w, h);      /* Affichage par le GEM */
  edit = EDIT1;         /* Num‚ro d'objet de l'‚ditable courant */
  objc_edit (adr, edit, 0, &pos, ED_INIT);  /* Afficher curseur texte */

  do
  {   /* Appel … la fonction xform_do() : */
    retour = xform_do ((MU_KEYBD|MU_BUTTON|MU_TIMER), adr);
    if ((retour & MU_BUTTON) && ((objet == OK) || (objet == ANNULE)))
      fin = 1;  /* Fin si on a cliqu‚ un bouton de sortie */
    else if (retour & MU_BUTTON)
    {
      strcpy (nbre, adr[NBRE].ob_spec.tedinfo->te_ptext);
      valeur = atoi (nbre);
      if (objet == FLG)
      {
        valeur--;
        if (valeur < 0)
          valeur = 999;
      }
      else if (objet == FLD)
      {
        valeur++;
        if (valeur > 999)
          valeur = 0;
      }
      itoa (valeur, nbre, 10);
      strcpy (adr[NBRE].ob_spec.tedinfo->te_ptext, nbre);
      objc_draw (adr, NBRE, MAX_DEPTH, x, y, w, h);
    }
  } while (fin == 0);

  form_dial (FMD_FINISH, 0, 0, 0, 0, x, y, w, h); /* Effacer formulaire */
  objc_change (adr, objet, 0, x, y, w, h, 0, 0);  /* R‚inverser bouton */
  edit = 0;   /* Il n'y a plus d'‚ditable courant */
  wind_update (END_MCTRL);                /* D‚bloquer menu */

  if (objet == OK)    /* Si on est sorti avec "Confirmer" */
  {
    rsrc_gaddr (R_FRSTR, RESULT, &resultat);  /* Adr alerte ptr sur ptr */
    resultat = *((char **)resultat);          /* Pointeur sur le texte */
    for (i = RB1 ; i <= RB3 ; i++)  /* Tester les radios-boutons */
      if (adr[i].ob_state & SELECTED)
        sel = i;  /* Nø du bouton s‚lectionn‚ */
    strcpy (txt1, adr[EDIT1].ob_spec.tedinfo->te_ptext);  /* Lire textes */
    strcpy (txt2, adr[EDIT2].ob_spec.tedinfo->te_ptext);
    strcpy (nbre, adr[NBRE].ob_spec.tedinfo->te_ptext);
    if (adr[BS].ob_state & SELECTED)  /* Tester ‚tat bouton s‚lectable */
      sprintf (alrt, resultat, sel, txt1, txt2, nbre, "Oui"); /* Texte alerte */
    else
      sprintf (alrt, resultat, sel, txt1, txt2, nbre, "Non");
    /* Alerte qui indique ce qui a ‚t‚ fait dans le formulaire : */
    form_alert (1, alrt);
  }
}
/* #] formulaire normal :                                             */ 
/* #[ Ouvrir fenˆtre formulaire :                                     */
void wind_form (void)
{   /* Ouverture fenˆtre formulaire */
int x, y, w, h;       /* Coordonn‚es du formulaire */
int xf, yf, wf, hf;   /* Coordonn‚es de la fenˆtre */
int attr = (NAME|MOVER|CLOSER); /* Attributs GEM de la fenˆtre */

  if (hwind[2] > 0) /* Si la fenˆtre formulaire est d‚j… ouverte */
  {
    wind_set (hwind[2], WF_TOP);  /* On la met au premier plan */
  }
  else            /* Sinon, on l'ouvre */
  {
    x = adr_formwin->ob_x;  /* Lire coordonn‚es courantes du formulaire */
    y = adr_formwin->ob_y;
    w = adr_formwin->ob_width;
    h = adr_formwin->ob_height;

      /* En d‚duire les coordonn‚es totales de la fenˆtre */
    wind_calc (WC_BORDER, attr, x, y, w, h, &xf, &yf, &wf, &hf);
    hwind[2] = wind_create (attr, xf, yf, wf, hf);  /* Cr‚er la fenˆtre */
    if (hwind[2] > 0)   /* Si la fenˆtre a pu ˆtre cr‚e */
    {
      wind_set (hwind[2], WF_NAME, titre[2]); /* Titre fenˆtre */
      wind_open (hwind[2], xf, yf, wf, hf);   /* Ouverture fenˆtre */
    }
    else    /* Si la fenˆtre n'a pu ˆtre cr‚e */
    {
      hwind[2] = 0;
      afficher_alerte (NOTWIND);  /* Pr‚venir */
    }
  }
}
/* #] Ouvrir fenˆtre formulaire :                                     */ 
/* #[ Ouvrir fenˆtre Dessin :                                         */
void afficher_dessin (void)
{   /* Ouverture fenˆtre dessin */
int xf, yf, wf, hf;   /* Coordonn‚es fenˆtre */
int attr = (NAME|CLOSER|FULLER|MOVER|INFO|SIZER);

  if (hwind[0] > 0) /* Si la fenˆtre formulaire est d‚j… ouverte */
  {
    wind_set (hwind[0], WF_TOP);  /* On la met au premier plan */
  }
  else            /* Sinon, on l'ouvre */
  {
    xf = xb + (wb / 4); /* Position de d‚part de la fenˆtre */
    yf = yb + (hb / 4);
    wf = wb / 3;
    hf = hb / 3;
  
    hwind[0] = wind_create (attr, xf, yf, wf, hf);  /* Cr‚er la fenˆtre */
    if (hwind[0] > 0)   /* Si la fenˆtre a pu ˆtre cr‚e */
    {
      wind_set (hwind[0], WF_NAME, titre[0]); /* Titre fenˆtre */
      wind_set (hwind[0], WF_INFO, infos[0]); /* Ligne d'infos */
      wind_open (hwind[0], xf, yf, wf, hf);   /* Ouverture fenˆtre */
    }
    else    /* Si la fenˆtre n'a pu ˆtre cr‚e */
    {
      hwind[0] = 0;
      afficher_alerte (NOTWIND);  /* Pr‚venir */
    }
  }
}
/* #] Ouvrir fenˆtre Dessin :                                         */ 
/* #[ Ouvrir fenˆtre Texte :                                          */
void afficher_texte (void)
{   /* Ouverture fenˆtre texte */
int wcell, hcell, dummy;
int xf, yf, wf, hf;   /* Coordonn‚es fenˆtre */
int attr = (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE);

  if (hwind[1] > 0) /* Si la fenˆtre formulaire est d‚j… ouverte */
  {
    wind_set (hwind[1], WF_TOP);  /* On la met au premier plan */
  }
  else            /* Sinon, on l'ouvre */
  {
    xf = xb + (wb / 3); /* Position de d‚part de la fenˆtre */
    yf = yb + (hb / 3);
    wf = wb / 2;
    hf = hb / 2;
      /* Taille cellules de caractŠres */
    vst_height (handle, 13, &dummy, &dummy, &wcell, &hcell);
    lt = 60 * wcell;  /* Largeur totale fenˆtres */
    ht = 50 * hcell;  /* Hauteur totale fenˆtres */
  
    hwind[1] = wind_create (attr, xf, yf, wf, hf);  /* Cr‚er la fenˆtre */
    if (hwind[1] > 0)   /* Si la fenˆtre a pu ˆtre cr‚e */
    {
      wind_set (hwind[1], WF_NAME, titre[1]); /* Titre fenˆtre */
      wind_set (hwind[1], WF_INFO, infos[1]); /* Ligne d'infos */
      wind_set (hwind[1], WF_HSLIDE, 0);      /* Position HSLID */
      wind_set (hwind[1], WF_VSLIDE, 0);      /* Position VSLID */
      wind_set (hwind[1], WF_HSLSIZE, 1000);  /* Taille HSLIDE */
      wind_set (hwind[1], WF_VSLSIZE, 1000);  /* Taille VSLIDE */
      wind_open (hwind[1], xf, yf, wf, hf);   /* Ouverture fenˆtre */
      sliders ();   /* Ajuster tailles et positions sliders */
    }
    else    /* Si la fenˆtre n'a pu ˆtre cr‚e */
    {
      hwind[1] = 0;
      afficher_alerte (NOTWIND);  /* Pr‚venir */
    }
  }
}
/* #] Ouvrir fenˆtre Texte :                                          */ 
/* #[ Redraw :                                                        */
void redraw (int x, int y, int w, int h)
{   /* Gestion des redraws */
GRECT r, rd;
int index;

  if (buf[3] == hwind[0])   /* Chercher l'index de la fenˆtre */
    index = 0;
  else if (buf[3] == hwind[1])
    index = 1;
  else
    index = 2;

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
      if (index == 2)         /* Si fenˆtre formulaire */
        objc_draw (adr_formwin, 0, MAX_DEPTH, r.g_x, r.g_y, r.g_w, r.g_h);
      else      /* Si fenˆtre Dessin ou Texte */
      {
        set_clip (1, &r);   /* Clipping ON */
        if (index == 0)         /* Si fenˆtre Dessin */
          red_dessin ();
        else if (index == 1)    /* Si fenˆtre Texte */
          red_texte ();
        set_clip (0, &r);   /* Clipping OFF */
      }
    }
      /* Rectangle suivant */
    wind_get (buf[3], WF_NEXTXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
  }
  wind_update (END_UPDATE);   /* D‚bloquer les fonctions de la souris */
  v_show_c (handle, 1);       /* Rappeler la souris */
}
/* #] Redraw :                                                        */ 
/* #[ Redraw Dessin :                                                 */
void red_dessin (void)
{   /* Redraw fenˆtre Dessin */
int xw, yw, ww, hw;     /* Coordonn‚es zone de travail de la fenˆtre */
int pxy[4];

    /* Coordonn‚es zone de travail fenˆtre : */
  wind_get (hwind[0], WF_WORKXYWH, &xw, &yw, &ww, &hw);
  vsf_perimeter (handle, 0);  /* Pas de contour */
  vsf_color (handle, 1);      /* Couleur noire */
  vsf_interior (handle, 2);   /* Remplissage type trame */
  vsf_style (handle, cont_dessin);  /* Type de trame */
  pxy[0] = xw;    /* Coordonn‚es du rectangle tram‚ */
  pxy[1] = yw;
  pxy[2] = pxy[0] + ww - 1;
  pxy[3] = pxy[1] + hw - 1;
  v_bar (handle, pxy);  /* Tracer le rectangle */
}
/* #] Redraw Dessin :                                                 */ 
/* #[ Redraw Texte :                                                  */
void red_texte (void)
{   /* Redraw fenˆtre Texte */
char ligne[65], buffer[25];
int pxy[4], xw, yw, ww, hw, x, y, i, wcell, hcell, dummy;

    /* Taille cellules de caractŠres : */
  vst_height (handle, 13, &dummy, &dummy, &wcell, &hcell);
    /* Coordonn‚es zone de travail fenˆtre : */
  wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);

  pxy[0] = xw;                /* Pr‚parer effacement fenˆtre */
  pxy[1] = yw;
  pxy[2] = xw + ww - 1;
  pxy[3] = yw + hw - 1;
  vswr_mode (handle, MD_REPLACE);   /* Dessin en mode Remplacement */
  vsf_color (handle, 0);            /* Couleur blanche */
  v_bar (handle, pxy);              /* "Vider" la fenˆtre */

  y = yw - lin; /* Positionner l'affichage des lignes */
  x = xw - col;
  vst_alignment (handle, 0, 5, &dummy, &dummy); /* Texte en haut … gauche */
  for (i = 0 ; i < 50 ; i++)    /* 50 lignes */
  {
      /* Pr‚parer une ligne : */
    strcpy (ligne, " ");    /* On commence par un espace */
    if (cont_texte & 0x01)
    {   /* Si le handle fenˆtre est demand‚ */
      sprintf (buffer, "Fenˆtre %d. ", hwind[1]);
      strcat (ligne, buffer);
    }
    if (cont_texte & 0x02)
    {   /* Si le nø de ligne est demand‚ */
      sprintf (buffer, "Ligne nø %d. ", i + 1);
      strcat (ligne, buffer);
    }
    if (cont_texte & 0x04)
    {   /* Si le remplissage est demand‚ */
      strcat (ligne, "Le GEM, c'est super !");
    }

    v_gtext (handle, x, y, ligne);  /* Afficher la ligne */
    y += hcell;                     /* Position ligne suivante */
  }
}
/* #] Redraw Texte :                                                  */ 
/* #[ Intersection :                                                  */
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
/* #] Intersection :                                                  */ 
/* #[ Clipping :                                                      */
void set_clip (int clip_flag, GRECT *area)
{   /* Active ou d‚sactive le clipping d'une zone */
int pxy[4];

  pxy[0] = area->g_x;
  pxy[1] = area->g_y;
  pxy[2] = area->g_w + area->g_x - 1;
  pxy[3] = area->g_h + area->g_y - 1;
  vs_clip (handle, clip_flag, pxy);
}
/* #] Clipping :                                                      */ 
/* #[ Fulled :                                                        */
void fulled (void)
{   /* Fenˆtre plein pot ou retour */
int index, x, y, w, h;

  if (buf[3] == hwind[0])   /* Chercher l'index de la fenˆtre */
    index = 0;
  else if (buf[3] == hwind[1])
    index = 1;

  if (ful[index])           /* Si elle est d‚j… plein pot */
  {
    wind_get (buf[3], WF_PREVXYWH, &x, &y, &w, &h); /* Coord. pr‚c‚dentes */
    wind_set (buf[3], WF_CURRXYWH, x, y, w, h);     /* Nouvelles coord. */
    ful[index] = 0;                   /* Annuler flag */
  }
  else                      /* Sinon */
  {
    wind_set (buf[3], WF_CURRXYWH, xb, yb, wb, hb); /* Coord. maxi */
    ful[index] = 1;                   /* Positionner flag */
  }
  if (index == 1) /* Si fenˆtre de Texte */
    sliders (); /* Ajuster tailles et positions sliders */
}
/* #] Fulled :                                                        */ 
/* #[ Arrow :                                                         */
void arrow (void)
{   /* Message d'ascenseur */
int xw, yw, ww, hw, wcell, hcell, dummy;

    /* La taille des cellules de caractŠres sert pour les d‚calages
       d'une ligne ou d'une colonne. */
  vst_height (handle, 13, &dummy, &dummy, &wcell, &hcell);

  wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
  switch (buf[4])
  {
  case WA_UPPAGE :        /* Page vers le haut */
    if (lin > 0)  /* Si on n'est pas d‚j… au d‚but */
    {
      lin = max (lin - hw, 0);  /* Nouvelle ligne */
      redraw (xw, yw, ww, hw);  /* R‚affichage */
      sliders ();         /* Actualiser les sliders */
    }
    break;
  case WA_DNPAGE :        /* Page vers le bas */
    if ((lin + hw) < ht)  /* Si pas d‚j… … la fin */
    {
      lin = min (lin + hw, ht - hw);  /* Nouvelle ligne */
      redraw (xw, yw, ww, hw);  /* R‚affichage */
      sliders ();         /* Actualiser les sliders */
    }
    break;
  case WA_UPLINE :        /* Ligne vers le haut */
    if (lin > 0)  /* Si on n'est pas d‚j… au d‚but */
    {
      lin -= hcell; /* Nouvelle ligne */
      if (lin < 0)
        lin = 0;
      redraw (xw, yw, ww, hw);  /* R‚affichage */
      sliders ();         /* Actualiser les sliders */
    }
    break;
  case WA_DNLINE :        /* Ligne vers le bas */
    if ((lin + hw) < ht)  /* Si pas d‚j… … la fin */
    {
      lin += hcell; /* Nouvelle ligne */
      if (lin + hw > ht)
        lin = ht - hw;
      redraw (xw, yw, ww, hw);  /* R‚affichage */
      sliders ();         /* Actualiser les sliders */
    }
    break;
  case WA_LFPAGE :        /* Page vers la gauche */
    if (col > 0)  /* Si on n'est pas d‚j… au d‚but */
    {
      col = max (col - ww, 0);  /* Nouvelle colonne */
      redraw (xw, yw, ww, hw);  /* R‚affichage */
      sliders ();         /* Actualiser les sliders */
    }
    break;
  case WA_RTPAGE :        /* Page vers la droite */
    if ((col + ww) < lt)  /* Si pas d‚j… … la fin */
    {
      col = min (col + ww, lt - ww);  /* Nouvelle colonne */
      redraw (xw, yw, ww, hw);  /* R‚affichage */
      sliders ();         /* Actualiser les sliders */
    }
    break;
  case WA_LFLINE :        /* Ligne vers la gauche */
    if (col > 0)  /* Si on n'est pas d‚j… au d‚but */
    {
      col -= wcell; /* Nouvelle colonne */
      if (col < 0)
        col = 0;
      redraw (xw, yw, ww, hw);  /* R‚affichage */
      sliders ();         /* Actualiser les sliders */
    }
    break;
  case WA_RTLINE :        /* Ligne vers la droite */
    if ((col + ww) < lt)  /* Si pas d‚j… … la fin */
    {
      col += wcell; /* Nouvelle colonne */
      if (col + ww > lt)
        col = lt - ww;
      redraw (xw, yw, ww, hw);  /* R‚affichage */
      sliders ();         /* Actualiser les sliders */
    }
    break;
  }
}
/* #] Arrow :                                                         */ 
/* #[ Slider H :                                                      */
void hslider (void)
{
int slide, xw, yw, ww, hw;

  slide = buf[4];
  wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
    /* Calcul de la colonne : */
  col = ((long)slide * (lt - (long)ww) / 1000.0);
  if (col + ww > lt)  /* Corrections */
    col = lt - ww;
  if (col < 0)
    col = 0;
  wind_set (buf[3], WF_HSLIDE, slide);
  redraw (xw, yw, ww, hw);  /* R‚affichage */
}
/* #] Slider H :                                                      */ 
/* #[ Slider V :                                                      */
void vslider (void)
{
int slide, xw, yw, ww, hw;

  slide = buf[4];
  wind_get (buf[3], WF_WORKXYWH, &xw, &yw, &ww, &hw);
    /* Calcul de la ligne : */
  lin = ((long)slide * (ht - (long)hw) / 1000.0);
  if (lin + hw > ht)  /* Corrections */
    lin = ht - hw;
  if (lin < 0)
    lin = 0;
  wind_set (buf[3], WF_VSLIDE, slide);
  redraw (xw, yw, ww, hw);  /* R‚affichage */
}
/* #] Slider V :                                                      */ 
/* #[ Sliders :                                                       */
void sliders (void)
{   /* Tailles et Positions sliders */
    /* Ne concerne que la fenˆtre Texte */
int slide, xw, yw, ww, hw;
    /* Coordonn‚es zone de travail : */
  wind_get (hwind[1], WF_WORKXYWH, &xw, &yw, &ww, &hw);

  wind_set (hwind[1], WF_VSLSIZE,         /* Taille slider vertical */
            (int)((double)1000 * (double)((double)hw /
            (double)ht)));
  lin = min (lin, ht - hw); /* Calculer la ligne */
  lin = max (0, lin);

  wind_set (hwind[1], WF_HSLSIZE,         /* Taille slider horizontal */
            (int)((double)1000 * (double)((double)ww /
            (double)lt)));
  col = min (col, lt - ww); /* Calculer la colonne */
  col = max (0, col);

  slide = lin * 1000.0 / (ht - hw); /* Position vertical */
  if (slide < 0)
    slide = 0;
  if (slide > 1000)
    slide = 1000;
  wind_set (hwind[1], WF_VSLIDE, slide);

  slide = col * 1000.0 / (lt - ww); /* Position horizontal */
  if (slide < 0)
    slide = 0;
  if (slide > 1000)
    slide = 1000;
  wind_set (hwind[1], WF_HSLIDE, slide);
}
/* #] Sliders :                                                       */ 

/* #[ xform_do :                                                      */
int xform_do (int flags, OBJECT *address)
{   /* Fonction qui remplace le form_do du GEM */
int evnt;               /* Type d'‚v‚nement */
int dummy, i, j;        /* Divers */
int whandle;            /* Handle fenˆtre cliqu‚e */
int top;                /* Handle fenˆtre de premier plan */
int obflags, obstate;   /* ob_flags et ob_state objet cliqu‚ */
int champ;              /* Champ de saisie ‚ditable */
OBJECT *adr;            /* Adresse formulaire sur lequel on travaille */
char option[50], ctr;   /* Pour la recherche dans le menu */
unsigned char touc;

  objet = 0;    /* Mise … z‚ro avant de commencer */

  while (1)         /* BOUCLE "SANS FIN" */
  {   /* Surveillance des ‚v‚nements Clavier, Clic, Message et Timer */
    evnt = evnt_multi (flags, 2, 1, 1,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       buf, 10, 0, &mx, &my, &mk, &kbd, &key, &clik);

    if (evnt & MU_KEYBD)    /* Si ‚v‚nement clavier */
    {
      if (address == adr_desk)  /* Si on travaille sur le bureau */
      {
        wind_get (0, WF_TOP, &top, &dummy, &dummy, &dummy);
          /* Si la fenˆtre formulaire est au 1ø plan : */
        if ((hwind[2]) && (top == hwind[2]))
          adr = adr_formwin;  /* R‚cup‚rer adresse formulaire en fenˆtre */
        else
          adr = adr_desk;     /* R‚cup‚rer adresse du bureau */
  /* S'il y avait plusieurs fenˆtres avec formulaire,
     il faudrait faire plus de tests */
      }
      else      /* Si on travaille sur un formulaire */
      {
        adr = address;  /* R‚cup‚rer adresse formulaire */
      }

      if ((key == 0x720D) || (key == 0x1C0D)) /* Si <Return> ou <Enter> */
      {     /* Chercher bouton DEFAULT s'il y en a */
        i = 0;  /* En partant de la racine */
        do    /* Pour chaque objet */
        {
          if (adr[i].ob_flags & DEFAULT)  /* Si objet d‚faut */
          {
            adr[i].ob_state |= SELECTED;  /* S‚lectionner l'objet */
            objc_draw (adr, i, MAX_DEPTH, /* Le redessiner */
                       adr->ob_x, adr->ob_y,
                       adr->ob_width, adr->ob_height);
            evnt = MU_BUTTON; /* Modifier type d'‚v‚nement */
            objet = i;        /* Enregistrer l'objet */
            return (evnt);    /* Retourner l'‚v‚nement */
          }
        } while (! (adr[i++].ob_flags & LASTOB)); /* Jusqu'au dernier objet */
      }
      else if (edit)      /* S'il y a un champ ‚ditable */
      {
        if (key == 0x5000)      /* Si flŠche vers le bas */
        {
          champ = next (adr); /* Chercher champ suivant */
          if (champ > -1) /* S'il y en a un */
          {
            objc_edit (adr, edit, 0, &pos, ED_END);   /* D‚sactiver */
            edit = champ;   /* Nouvel ‚ditable */
            objc_edit (adr, edit, 0, &pos, ED_INIT);  /* R‚activer */
          }
        }
        else if (key == 0x4800) /* Si flŠche vers le haut */
        {
          champ = prev (adr); /* Chercher champ pr‚c‚dent */
          if (champ > -1) /* S'il y en a un */
          {
            objc_edit (adr, edit, 0, &pos, ED_END);   /* D‚sactiver */
            edit = champ;   /* Nouvel ‚ditable */
            objc_edit (adr, edit, 0, &pos, ED_INIT);  /* R‚activer */
          }
        }
        else                    /* Si autre touche */
        {   /* Le GEM s'occupe de tout */
          objc_edit (adr, edit, key, &pos, ED_CHAR);
        }
      }
      else      /* Sinon, chercher raccourcis dans le menu */
      {
        kbd = (int)Kbshift (-1);  /* Prendre ‚tat des touches sp‚ciales */
        kbd &= ~0x10; /* Annuler bit CapsLock */
        if ((kbd == K_RSHIFT) || (kbd == K_LSHIFT))
          ctr = 0x01;   /* CaractŠre repr‚sentant la touche sp‚ciale */
        else if (kbd == K_CTRL)
          ctr = 0x05E;
        else if (kbd == K_ALT)
          ctr = 0x07;
        else
          ctr = 0;
        if (ctr)
        {
          stdkey (&touc);   /* Recherche code Ascii */
          i = 0;
          do    /* Pour chaque objet du menu */
          {
            if (adr_menu[i].ob_type == G_STRING)  /* Si c'est une option */
            {
              strcpy (option, adr_menu[i].ob_spec.free_string); /* La lire */
              trim (option);  /* Virer les espaces */
              if ((*(option + strlen (option) - 1) == touc) &&
                  (*(option + strlen (option) - 2) == ctr))
              {   /* Si le caractŠre et la touche sp‚ciale correspondent */
                if (! (adr_menu[i].ob_state & DISABLED))  /* Si actif */
                {
                  evnt = MU_MESAG;  /* Fabriquer un ‚v‚nement */
                  buf[0] = MN_SELECTED;
                  buf[3] = m_title (adr_menu, i); /* Titre de l'option */
                  buf[4] = i;
                }
              }
            }
          } while (! (adr_menu[i++].ob_flags & LASTOB));
        }
      }
    }

    if (evnt & MU_MESAG)          /* Si ‚v‚nement message */
    {
      return (evnt);
    }

    if (evnt & MU_BUTTON)   /* Si ‚v‚nement clic souris */
    {
      if (address == adr_desk)      /* Si on travaille sur le bureau */
      {
        whandle = wind_find (mx, my); /* A t-on cliqu‚ sur une fenˆtre ? */
        if (whandle)                  /* Si oui */
        {   /* Chercher fenˆtre de premier plan */
          wind_get (0, WF_TOP, &top, &dummy, &dummy, &dummy);
          if (whandle == top)   /* Si on a cliqu‚ la fenˆtre de 1ø plan */
          {
            if (whandle == hwind[2])  /* Si c'est la fenˆtre de formulaire */
            {
              adr = adr_formwin;  /* Adresse formulaire en fenˆtre */
            }
          }
        }
      }
      else                          /* Si on travaille sur un formulaire */
      {
        adr = address;            /* Adresse formulaire */
      }

      objet = objc_find (adr, 0, MAX_DEPTH, mx, my); /* Objet cliqu‚ */
      if (objet > -1)     /* Si on a cliqu‚ sur un objet */
      {
        obflags = adr[objet].ob_flags;  /* Noter ob_flags objet */
        obstate = adr[objet].ob_state;  /* Noter ob_state objet */
  
        if (obstate & DISABLED)         /* Si l'objet est d‚sactiv‚ */
          return (evnt);    /* Sortir de suite */
  
        if (! (obflags & TOUCHEXIT))    /* Si ce n'est pas un TOUCHEXIT */
        {
          while (mk)  /* Attendre bouton souris relach‚ */
            graf_mkstate (&dummy, &dummy, &mk, &dummy);
        }
  
        if ((obflags & SELECTABLE) &&
            (! (obflags & RBUTTON)))    /* Si s‚lectable simple */
        {
          adr[objet].ob_state ^= SELECTED;    /* Inverser l'‚tat de l'objet */
          objc_draw (adr, objet, MAX_DEPTH,   /* Redessiner l'objet */
                     adr->ob_x, adr->ob_y,
                     adr->ob_width, adr->ob_height);
        }
  
        if ((obflags & SELECTABLE) &&
            (obflags & RBUTTON) &&
            (! (obstate & SELECTED)))   /* Si radio-bouton */
        {
          j = objet;                      /* Partir de cet objet */
          adr[objet].ob_state |= SELECTED;  /* Le s‚lectionner */
          objc_draw (adr, objet, MAX_DEPTH, adr->ob_x, adr->ob_y,
                     adr->ob_width, adr->ob_height);
          i = parent (adr, j);        /* Chercher le pŠre */
          j = adr[i].ob_head;         /* Partir du 1ø enfant... */
          i = adr[i].ob_tail;         /* jusqu'au dernier. */
          do
          {
            if ((adr[j].ob_flags & RBUTTON) && (j != objet) &&
                (adr[j].ob_state & SELECTED))
            {   /* Les mettre en normal si RBUTTON sauf l'objet cliqu‚. */
              adr[j].ob_state &= ~SELECTED;
              objc_draw (adr, j, MAX_DEPTH, adr->ob_x, adr->ob_y,
                         adr->ob_width, adr->ob_height);
            }
            j = adr[j].ob_next;                       /* Au suivant... */
          } while ((j <= i) && (j > adr[i].ob_next)); /* jusqu'au dernier. */
        }
  
        if (obflags & EDITABLE)         /* Si ‚ditable */
        {
          objc_edit (adr, edit, 0, &pos, ED_END);   /* D‚sactiver curseur */
          edit = objet;                     /* Nouvel ‚ditable courant */
          objc_edit (adr, edit, 0, &pos, ED_INIT);  /* R‚activer curseur */
        }
      }
      return (evnt);
    }
  }
}
/* #] xform_do :                                                      */ 
/* #[ parent () Cherche le pŠre d'un objet :                          */
int parent (OBJECT *adr, int object)
{   /* Retourne l'objet pŠre d'un objet */
register int i;

  i = object;                     /* Partir de cet objet */
  do
  {
    i = adr[i].ob_next;           /* Passer au suivant... */
  } while (i > object);           /* Jusqu'… revenir au pŠre. */

  return i;                       /* Retourner le pŠre */
}
/* #] parent () Cherche le pŠre d'un objet :                          */ 
/* #[ next () Champ suivant :                                         */
int next (OBJECT *adr)
{   /* Chercher l'‚ditable suivant */
int pere, vu = 1, ob = edit;

  while (! (adr[ob++].ob_flags & LASTOB))
  {   /* Tant qu'on n'est pas au dernier objet */
    pere = parent (adr, ob);  /* Chercher son pŠre */
      /* Si ce n'est pas la racine et pas HIDETREE */
    while ((pere > 0) && (vu))
    {   /* Si le pŠre est HIDETREE */
      if (adr[pere].ob_flags & HIDETREE)
        vu = 0;   /* l'objet n'est pas visible */
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
/* #] next () Champ suivant :                                         */ 
/* #[ prev () Champ pr‚c‚dent :                                       */
int prev (OBJECT *adr)
{   /* Chercher l'‚ditable pr‚c‚dent */
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
/* #] prev () Champ pr‚c‚dent :                                       */ 
/* #[ stdkey () Test tous claviers :                                  */
void stdkey (unsigned char *k)
{
KEYTAB *kt;

  kt = Keytbl((void *)-1, (void *)-1, (void *)-1);
  *k = toupper (kt->shift[(char)(key >> 8)]);
}
/* #] stdkey () Test tous claviers :                                  */ 
/* #[ trim () Vire espaces d‚but et fin de chaŒne :                   */
char *trim (char *str)
{
register char *s;
register int i = 0;
char chaine[MAX_LEN];

  while (*(str + i) == ' ')
    i++;
  strcpy (chaine, (str + i));

  s = chaine + strlen (chaine) - 1;
  for( ; (*s == ' ') && (s >= chaine) ; *s-- = 0);
  strcpy (str, chaine);
  return str;
}
/* #] trim () Vire espaces d‚but et fin de chaŒne :                   */ 
/* #[ m_title () Cherche le titre de menu d'une option :              */
int m_title (OBJECT *adresse, int option)
{
register menu = 1, k = 2;
int pere, titre;

  pere = parent (adresse, option);
  while (adresse[(k++) + 1].ob_type != G_BOX) ; /* Chercher 1ø G_BOX */

  while (k != pere)
  {
    k = adresse[k].ob_next;     /* Chercher menu correspondant */
    menu++;                     /* Les compter */
  }

  k = 3;
  do
  {
    titre = k++;        /* L'affecter */
  } while ((k - 3) != menu);

  return titre;
}
/* #] m_title () Cherche le titre de menu d'une option :              */ 

