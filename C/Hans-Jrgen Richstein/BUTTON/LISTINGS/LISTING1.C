/***********************************************/
/* BUT_MNGE.C                                  */
/* 'Button Manager'  zum Verwalten selbstent-  */
/* worfener Knîpfe in Resourcen                */
/*                                             */
/* öbersetzt mit Turbo C 2.03                  */
/*                                             */
/* von Hans-JÅrgen Richstein                   */
/*     (c) 1990 Maxon Computer GmbH            */
/***********************************************/

#include <vdi.h>
#include <aes.h> 

/* Die vom 'Button-Design' Editor erzeugten Daten
 und die Struktur SWITCH werden hier eingefÅgt */

#include "switches.btn" 

#define RASTERBREITE 16
#define RASTERHOEHE 16
#define RASTER_WORTE 16

#define COL_SET 1
#define COL_RESET 0

/*------------- Prototypen --------------------*/
void init_buttons(int v_handle,OBJECT *trees[]);
void convert_tree(OBJECT *tree,unsigned int ob);
int find_switch(char pate);
int cdecl draw_procedure(PARMBLK *pb);
/*---------------------------------------------*/

int vdi_handle; /* FÅr die Zeichen- und Raster-*/
MFDB screen_mfdb,bitmap_mfdb; /* operationen   */

/* Hier werden nun die Platzhalter in einem
   String eingetragen und in gleicher Reihenfolge
   folgen die dazugehîrigen User-Blocks */
                        
char paten[] = "oxbe";  /* 4 Schalterarten */

USERBLK user_defined[] =
{ 
  draw_procedure,(long) &Mac_Radio,
  draw_procedure,(long) &Mac_Button, 
  draw_procedure,(long) &Binaerschalter,
  draw_procedure,(long) &Ein_Aus
};
/*---------------------------------------------*/
void init_buttons(int v_handle,OBJECT *trees[])
{ 
  int i = 0;
  screen_mfdb.fd_addr = NULL; /* = Bildschirm */ 
  bitmap_mfdb.fd_w = RASTERBREITE;
  bitmap_mfdb.fd_h = RASTERHOEHE;
  bitmap_mfdb.fd_wdwidth = 1;
  bitmap_mfdb.fd_stand = 1;
  bitmap_mfdb.fd_nplanes = 1;
  vdi_handle = v_handle;
  while (trees[i]) convert_tree(trees[i++],0);
}
/*---------------------------------------------*/
void convert_tree(OBJECT *tree,unsigned int ob)
{
 /* Durchsucht alle Kinder von 'ob' nach BOXCHARs
 die als Pate fÅr die neuen Buttons stehen und
 substituiert diese mit einem Zeiger auf die da-
 zugehîrige USERBLK-Struktur */

  static int schalter;
  int akt_child = tree[ob].ob_head;

  while (akt_child != ob)
  {
    if (tree[akt_child].ob_type == G_BOXCHAR)
    {     /* Boxchar ? */

      schalter = find_switch(tree[akt_child].
                      ob_spec.obspec.character);

      if (schalter >= 0) 
      {            /* So einen haben wir ! */

        tree[akt_child].ob_type = G_USERDEF;
        tree[akt_child].ob_spec.userblk = 
                       &user_defined[schalter];
      }
    }
    if (tree[akt_child].ob_head >= 0)
      convert_tree(tree,akt_child); /* Rekursiv
                                  durchhangeln */
    akt_child = tree[akt_child].ob_next;
  } 
}
/*---------------------------------------------*/
int find_switch(char pate)
{
 /* Sucht die zu einem Buchstaben gehîrende
    Schalterstruktur. Liefert -1, wenn fÅr diesen
    Buchstaben kein Button vorhanden ist. */

  char *cur = paten;
  int ctr = 0;
  while (*cur)
  {
    if (*cur == pate) return ctr;
    cur++; ctr++;
  }
  return -1;
}
/*---------------------------------------------*/
int cdecl draw_procedure(PARMBLK *pb)
{ 
  /* Dies ist die eigentliche Zeichenroutine */
  int pxy[8], col_index[2];
  
  col_index[0] = COL_SET;
  col_index[1] = COL_RESET;

  /* Evt. Clipping setzen */
  pxy[0] = pb->pb_xc; pxy[1] = pb->pb_yc;
  pxy[2] = pxy[0] + pb->pb_wc - 1; 
  pxy[3] = pxy[1] + pb->pb_hc - 1;
  
  if (pxy[2] || pxy[3]) 
     vs_clip(vdi_handle,1,pxy);

  if (pb->pb_currstate & OUTLINED) /* Rahmen ? */
  {
    pxy[0] = pb->pb_x - 2; pxy[1] = pb->pb_y - 2;
    pxy[2] = pxy[0] + RASTERBREITE + 3;
    pxy[3] = pxy[1] + RASTERHOEHE + 3;

    vsl_color(vdi_handle,COL_SET);
    vsf_interior(vdi_handle,FIS_HOLLOW);
    vsf_perimeter(vdi_handle,1);/* Rand sichtb.*/
    v_bar(vdi_handle,pxy);
  } 
                /* Ein- oder Ausschalter */
  bitmap_mfdb.fd_addr = 
      (char *) ((pb->pb_currstate & SELECTED) ? 
                ((SWITCH *) (pb->pb_parm))->on :
                ((SWITCH *) (pb->pb_parm))->off);

  pxy[0] = pxy[1] = 0; /* Quellrasterkoord. */
  pxy[2] = RASTERBREITE - 1;
  pxy[3] = RASTERHOEHE - 1;
  
  pxy[4] = pb->pb_x; pxy[5] = pb->pb_y;
  pxy[6] = pxy[4] + RASTERBREITE - 1; /* Ziel- */
  pxy[7] = pxy[5] + RASTERHOEHE - 1;  /* koord.*/
  
  v_hide_c(vdi_handle);   /* Maus aus */

  vrt_cpyfm(vdi_handle,MD_REPLACE,pxy,
            &bitmap_mfdb,&screen_mfdb,col_index);

  v_show_c(vdi_handle,1); /* und wieder an */

  return 0;   /* Sehr wichtig !!! */
}
