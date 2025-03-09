/***********************************************/
/* BUT_DSGN.C                                  */
/* 'Button Designer' zum Entwurf eigener       */
/* Knîpfe fÅr Resourcen                        */
/*                                             */
/* öbersetzt mit Turbo C 2.03                  */
/*                                             */
/* von Hans-JÅrgen Richstein                   */
/*     (c) 1990 Maxon Computer GmbH            */
/***********************************************/

#include <vdi.h>
#include <aes.h> 
#include <stdio.h>
#include <tos.h>
#include <string.h>

#include "but_dsgn.h"
#include "but_dsgn.rsh" /* Resource File 
                           Dekompilat, erzeugt 
                           mit "RSC2CSRC" von 
                           Erik Dick,Kaisers-
                           lautern             */
/*------------- Prototypen --------------------*/

void hauptprogramm(void);
void handle_form(int sel_obj);
void redraw(int tree_nr,int obnr);
void edit_on_switch(void);
void edit_off_switch(void);
void save_bitmap(void);
void load_bitmap(void);
void save_c_code(char *mode);
void make_header(FILE *dest);
void make_raster(void);
void clear_raster(void);
void copy_to_raster(void);
void move_up(void);
void move_down(void);
void move_left(void);
void move_right(void);
void switch_test(void);
void flip_pixel(int mx, int my);
void copy_bitmap(char *src,int obj);
void main_init(void);

/*------------ Einige Makros ------------------*/

#define Pfeil graf_mouse(ARROW,0)
#define Biene graf_mouse(BUSYBEE,0)
#define TRUE 1
#define FALSE 0

#define PIXELBREITE 7  /* Im Mal-Raster */
#define RASTERBREITE 16
#define RASTERHOEHE 16
#define RASTER_WORTE 16

/*---------------------------------------------*/
int  appl_id,msgbuf[8],vdi_handle,/* GEM Krams */
     work_in[] = {1,1,1,1,1,1,1,1,1,1,2},
     work_out[57],dummy,mouse_x,mouse_y;
   
char path[128],   /* Puffer fÅr Pfadnamen */
     f_name[14] = "",
     *schaltername;

unsigned int *on_bitmap,*off_bitmap,
    *switch_bitmap; /* Die akt. Switch-Bitmap */
    
int cur_switch,     /* Das akt. Switch-Obj.   */
    test_status;
    color_index[] = {1,0};
    
enum {TOGGLE,ON,OFF} drawing_mode;

MFDB screen_mfdb,bitmap_mfdb; 

/*--------------- Alert - Texte ---------------*/
char noname_alert[] = "[1][ |"
                " Es wurde noch kein Name fÅr|"
                " diesen Schalter eingegeben!]"
                "[ Ok ]";               
/*---------------------------------------------*/
int main(void)
{
  int pxy[4];
  
  appl_id = appl_init();  /* Standard Initiali-
                             sierung im GEM */
  if (appl_id != -1)
  {
    vdi_handle = graf_handle(&dummy,&dummy,
                                &dummy,&dummy);
    v_opnvwk(work_in,&vdi_handle,work_out);
    if (vdi_handle != 0)
    {
      /* Default - Clipping setzen */
      pxy[0] = pxy[1] = 0;
      pxy[2] = work_out[0]; 
      pxy[3] = work_out[1];
      vs_clip(vdi_handle,1,pxy);

      main_init(); /* Erst mal 'klar Schiff' */
      Pfeil;
      hauptprogramm();

      v_clsvwk(vdi_handle);
    }
    appl_exit();
  }
  return (0);
}   
/*---------------------------------------------*/
void hauptprogramm(void)
{
  int x,y,w,h,sel_obj,m_button;

  form_center(TREE[MAINFORM],&x,&y,&w,&h);
  form_dial(FMD_START,0,0,0,0,x,y,w,h);
  form_dial(FMD_GROW,x+w/2,y+h/2,10,10,x,y,w,h);
  redraw(MAINFORM,0);
  make_raster();
  
  do
  {
    graf_mkstate(&dummy,&dummy,&m_button,&dummy);
    if (!m_button) drawing_mode = TOGGLE;
    
    sel_obj = form_do(TREE[MAINFORM],
                (drawing_mode == TOGGLE) ? 
                                 SWTCHNME : -1);
    graf_mkstate(&mouse_x,&mouse_y,
                              &dummy,&dummy);
    sel_obj &= 0x7fff; /* Doppelklicks 
                                    ignorieren */
    handle_form(sel_obj);

  } while(sel_obj != ENDE);

  form_dial(FMD_SHRINK,x+w/2,y+h/2,10,10,
                                    x,y,w,h);
  form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);    
}
/*---------------------------------------------*/
void handle_form(int sel_obj)
{
/* Verzweigt aufgrund des selektierten Objektes
    in die entsprechenden Routinen.            */

  switch (sel_obj)
  {
    case RASTER   : flip_pixel(mouse_x,mouse_y);
                    break;
    case BUTNEIN  : 
    case BUTNAUS  : if (sel_obj == BUTNAUS)
                      edit_off_switch();
                    else
                      edit_on_switch();
                    make_raster();
                    redraw(MAINFORM,EINTEXT);
                    redraw(MAINFORM,AUSTEXT);
                    redraw(MAINFORM,ORSWITCH);
                    break;
    case CLEARALL : clear_raster(); break;
    case ORSWITCH : copy_to_raster(); break;
    case MOVEUP   : move_up(); break;
    case MOVEDOWN : move_down(); break;
    case MOVELEFT : move_left(); break;
    case MOVERGHT : move_right(); break;
    case TEST     : switch_test(); break;
    case NEWCODE  : save_c_code("w"); break;
    case APPEND   : save_c_code("a"); break;
    case SAVEIMG  : save_bitmap(); break;
    case LOADIMG  : load_bitmap(); break;
  }
  
  switch (sel_obj) 
  {
   /* Raster-Update nach diesen Aufrufen */ 

    case CLEARALL: case ORSWITCH: case MOVEUP:
    case MOVEDOWN: case MOVELEFT: case MOVERGHT:

        make_raster();
        copy_bitmap((char *) switch_bitmap,
                                    cur_switch);
        break;

   /* Komplett-Update nach diesen Aufrufen */   

    case NEWCODE: case APPEND:
    case SAVEIMG: case LOADIMG:
        redraw(MAINFORM,0); make_raster();
        break;
  }
}
/*---------------------------------------------*/
void main_init(void)
{
  objc_init(); /* Nîtig, da wir die Resource 
                  nicht mit 'rsc_load' laden */

  /* Formular und Variablen vorbelegen    */

  path[0] = Dgetdrv() + 'A'; /* Aktuellen Pfad */
  path[1] = ':';             /* ermitteln      */
  Dgetpath(&path[2],0);
  strcat(path,"\\");

  /* Diese Zeiger sparen Schreibarbeit */ 

  on_bitmap = (unsigned int *) 
                  TREE[MAINFORM][BUTNEIN]
                      .ob_spec.bitblk->bi_pdata;
  off_bitmap = (unsigned int *) 
                  TREE[MAINFORM][BUTNAUS]
                      .ob_spec.bitblk->bi_pdata;
  schaltername = TREE[MAINFORM][SWTCHNME]
                     .ob_spec.tedinfo->te_ptext;

  schaltername[0] = 0; /* Eingabefeld lîschen */
  edit_off_switch(); /* Startedierung ist der
                        deselektierte Schalter */
  drawing_mode = TOGGLE;

  screen_mfdb.fd_addr = NULL; /* = Bildschirm */
  /* Quelle fÅr Rasterkopien */
  bitmap_mfdb.fd_w = RASTERBREITE;
  bitmap_mfdb.fd_h = RASTERHOEHE;
  bitmap_mfdb.fd_wdwidth = 1;
  bitmap_mfdb.fd_stand = 1;
  bitmap_mfdb.fd_nplanes = 1;
}
/*---------------------------------------------*/
void redraw(int tree_nr,int obnr)
{
/* Zeichnet Obj.'obnr' in Baum 'tree_nr' neu */

  objc_draw(TREE[tree_nr],obnr,MAX_DEPTH,
            0,0,0,0); /* = Default-Clipping */
}
/*---------------------------------------------*/
void clear_raster(void) /* Raster lîschen */
{ 
  int i;
  for (i = 0; i < RASTER_WORTE; 
                        switch_bitmap[i++] = 0);
}
/*---------------------------------------------*/
void copy_to_raster(void) /* Jeweils anderen   */
{                         /* Knopf hereinodern */
  unsigned int i,*source;
  if (switch_bitmap == on_bitmap)
    source = off_bitmap;
  else
    source = on_bitmap;
  for (i = 0; i < RASTER_WORTE; 
                switch_bitmap[i] |= source[i++]);
}
/*---------------------------------------------*/
void move_up(void) /* Ein Pixel nach oben */
{
  int i;
  for (i = 0;i < RASTER_WORTE - 1;i++)
        switch_bitmap[i] = switch_bitmap[i + 1];
  switch_bitmap[RASTER_WORTE - 1] = 0;
}
/*---------------------------------------------*/
void move_down(void) /* Ein Pixel nach unten */
{
  int i;
  for (i = RASTER_WORTE - 1;i > 0;i--)
        switch_bitmap[i] = switch_bitmap[i - 1];
  switch_bitmap[0] = 0;
}
/*---------------------------------------------*/
void move_left(void) /* Ein Pixel nach links */
{
  int i;
  for (i = 0;i < RASTER_WORTE;
                      switch_bitmap[i++] <<= 1);
}
/*---------------------------------------------*/
void move_right(void) /* Ein Pixel nach rechts */
{
  int i;
  for (i = 0;i < RASTER_WORTE;
                      switch_bitmap[i++] >>= 1);
}
/*---------------------------------------------*/
void switch_test(void)
{
  /* Kopiert wechselweise den selektierten oder
    deselektierten Schalter ins Testfeld. */ 
  int dum,mb;
  if (test_status)
  { 
    test_status = 0;
    copy_bitmap((char *) on_bitmap,TESTAREA);
  }
  else
  { 
    test_status = 1;
    copy_bitmap((char *) off_bitmap,TESTAREA);
  }
  do
  { /* Und auf Loslassen der Maustaste warten */
    graf_mkstate(&dum,&dum,&mb,&dum);
  } while(mb);
}
/*---------------------------------------------*/
void edit_on_switch(void)
{
  /* Schaltet auf Edierung des selektierten
    Schalters um (ohne 'redraw') */
  cur_switch = BUTNEIN;
  switch_bitmap = on_bitmap;
  TREE[MAINFORM][AUSTEXT].ob_state = DISABLED;
  TREE[MAINFORM][EINTEXT].ob_state = NONE;
  TREE[MAINFORM][ORSWITCH].ob_spec.free_string 
                              = "RASTER +'AUS'";
}
/*---------------------------------------------*/
void edit_off_switch(void)
{
  /* Schaltet auf Edierung des deselektierten
    Schalters um (ohne 'redraw') */
  cur_switch = BUTNAUS;
  switch_bitmap = off_bitmap;
  TREE[MAINFORM][EINTEXT].ob_state = DISABLED;
  TREE[MAINFORM][AUSTEXT].ob_state = NONE;
  TREE[MAINFORM][ORSWITCH].ob_spec.free_string
                              = "RASTER +'EIN'";
}
/*---------------------------------------------*/
void make_raster(void)
{
  /* Zeichnet in den Button 'RASTER' ein Gitter
    und fÅllt alle Punkte, die in der aktuellen 
    'switch_bitmap' gesetzt sind */
  int pxy[4],x_min,y_min,x_max,y_max,mask,x,y;
  
  objc_offset(TREE[MAINFORM],RASTER,
                            &x_min,&y_min);

  x_max = x_min+TREE[MAINFORM][RASTER].ob_width;
  y_max = y_min+TREE[MAINFORM][RASTER].ob_height;

  vsl_udsty(vdi_handle,0xaaaa); /* Punktiert */
  vsl_type(vdi_handle,7);
  v_hide_c(vdi_handle);

  pxy[0] = x_min + PIXELBREITE; pxy[1] = y_min;
  pxy[2] = pxy[0]; pxy[3] = y_max - 1;

  while (pxy[0] < x_max)
  {
    v_pline(vdi_handle,2,pxy);
    pxy[0] += PIXELBREITE + 1;
    pxy[2] += PIXELBREITE + 1;
  } 

  pxy[0] = x_min; pxy[1] = y_min + PIXELBREITE;
  pxy[2] = x_max - 1; pxy[3] = pxy[1];

  while (pxy[1] < y_max)
  {
    v_pline(vdi_handle,2,pxy);
    pxy[1] += PIXELBREITE + 1;
    pxy[3] += PIXELBREITE + 1;
  }
  
  for (x = 0;x < RASTERBREITE;x++)
    for (y = 0;y < RASTERHOEHE;y++)
    { 
      pxy[0] = x_min + x * (PIXELBREITE + 1);
      pxy[1] = y_min + y * (PIXELBREITE + 1);
      pxy[2] = pxy[0] + PIXELBREITE - 1;
      pxy[3] = pxy[1] + PIXELBREITE - 1;
   
      mask = 0x8000 >> x;
      vsf_interior(vdi_handle,
                    (switch_bitmap[y] & mask 
                                ? FIS_SOLID
                                : FIS_HOLLOW));
      vr_recfl(vdi_handle,pxy);
    }
    
  v_show_c(vdi_handle,0);
}
/*---------------------------------------------*/
void flip_pixel(int mx, int my)
{
  /* Vertauscht die Farbe des Pixels unter der
    Maus. Der Drawing-Mode wird auf den akt.
    Pixelwert gesetzt und bis zum Loslassen der
    Maustaste beibehalten */
  int pxy[4],x,y,raster_x,raster_y,mask,col;
  
  objc_offset(TREE[MAINFORM],RASTER,&x,&y);
  x = (mx - x)/(PIXELBREITE + 1);
  y = (my - y)/(PIXELBREITE + 1);
  objc_offset(TREE[MAINFORM],RASTER,
                        &raster_x,&raster_y);

  mask = 0x8000 >> x;
  switch (drawing_mode)
  {
    case TOGGLE : switch_bitmap[y] ^= mask;
                  break;
    case ON     : switch_bitmap[y] |= mask;
                  break;
    case OFF    : switch_bitmap[y] &= ~mask;
                  break;
  }
  col = switch_bitmap[y] & mask;  
  drawing_mode = (col ? ON : OFF);
  
  pxy[0] = raster_x + x * (PIXELBREITE + 1);
  pxy[1] = raster_y + y * (PIXELBREITE + 1);
  pxy[2] = pxy[0] + PIXELBREITE - 1;
  pxy[3] = pxy[1] + PIXELBREITE - 1;

  vsf_interior(vdi_handle,(col ? FIS_SOLID
                                :FIS_HOLLOW));
  v_hide_c(vdi_handle);
  vr_recfl(vdi_handle,pxy);
  copy_bitmap((char *) switch_bitmap,cur_switch);
  v_show_c(vdi_handle,0);
}
/*---------------------------------------------*/
void copy_bitmap(char *src,int obj)
{
  /* Kopiert die Bitmap eines Schalters auf den
    Schirm. Ein normales 'redraw' funktioniert
    bei 'BITBLK'-Objekten leider nicht im 
    'replace'-Modus...   */

  int pxy[8];
  
  bitmap_mfdb.fd_addr = src;  
  pxy[0] = pxy[1] = 0;
  pxy[2] = RASTERBREITE - 1;
  pxy[3] = RASTERHOEHE - 1;
  
  objc_offset(TREE[MAINFORM],obj,&pxy[4]
                                ,&pxy[5]);
  pxy[6] = pxy[4] + RASTERBREITE - 1;
  pxy[7] = pxy[5] + RASTERHOEHE - 1;

  v_hide_c(vdi_handle);
  vrt_cpyfm(vdi_handle,MD_REPLACE,pxy,
                     &bitmap_mfdb,&screen_mfdb,
                      color_index);
  v_show_c(vdi_handle,1);
}
/*---------------------------------------------*/
void save_bitmap(void)
{
  /* Schreibt die Bitmap fÅr einen Schalter und 
    seinen Namen */
  int exit;
  FILE *dest;

  strcat(path,"*.BBM");
  if (fsel_input(path,f_name,&exit) 
      && (exit == 1) && f_name[0])
  {
    Biene;    
    *(strrchr(path,'\\') + 1) = 0;
    strcat(path,f_name);
    dest = fopen(path,"wb"); 
    if (dest)
    {
      fwrite(on_bitmap,sizeof(int),RASTER_WORTE,
                                          dest);
      fwrite(off_bitmap,sizeof(int),RASTER_WORTE,
                                          dest);
      fwrite(schaltername,1,14,dest);
      fclose(dest);
    }
    Pfeil;
  }   
  *(strrchr(path,'\\') + 1) = 0; /* Pfadnamen
                                  korrigieren */
}
/*---------------------------------------------*/
void load_bitmap(void)
{
  /* Liest die Bitmap fÅr einen Schalter und 
    seinen Namen */
  int exit;
  FILE *dest;

  strcat(path,"*.BBM");
  if (fsel_input(path,f_name,&exit) 
      && (exit == 1) && f_name[0])
  {
    Biene;    
    *(strrchr(path,'\\') + 1) = 0;
    strcat(path,f_name);
    dest = fopen(path,"rb"); 
    if (dest)
    {
      fread(on_bitmap,sizeof(int),RASTER_WORTE,
                                          dest);
      fread(off_bitmap,sizeof(int),RASTER_WORTE,
                                          dest);
      fread(schaltername,1,14,dest);
      fclose(dest);
      copy_bitmap((char *) off_bitmap,BUTNAUS);
      copy_bitmap((char *) on_bitmap,BUTNEIN);
      redraw(MAINFORM,SWTCHNME);
    }
    Pfeil;
  }   
  *(strrchr(path,'\\') + 1) = 0; /* Pfadnamen */
}                               /* korrigieren*/
/*---------------------------------------------*/
void save_c_code(char *mode)
{
  /* Schreibt den C-Code fÅr den aktuellen 
    Schalter. Wenn nicht angefÅgt wird, wird
    zusÑtzlich der Datenstrukturheader erzeugt */

  int exit,i;
  FILE *dest;

  if (schaltername[0] == 0)
  {
    form_alert(1,noname_alert);
    return;
  }
  
  strcat(path,"*.BTN");
  if (strrchr(f_name,'.')) 
    strcpy(strrchr(f_name,'.') + 1,"BTN");  

  if (fsel_input(path,f_name,&exit) 
      && (exit == 1) && f_name[0])
  {
    Biene;
    *(strrchr(path,'\\') + 1) = 0;
    strcat(path,f_name);
    dest = fopen(path,mode); 
    if (dest)
    {
      if (mode[0] == 'w') make_header(dest);

      fprintf(dest,"\nSWITCH %s = \n{",
                                  schaltername);
      for(i = 0;i< RASTER_WORTE; i++)
      { 
        if (!(i % 8)) fprintf(dest,"\n\t"); 
        fprintf(dest,"%+#06x,",on_bitmap[i]);
      }
      fprintf(dest,"\n\t");
      for(i = 0;i< RASTER_WORTE - 1; i++)
      { 
        if (!(i % 8)) fprintf(dest,"\n\t"); 
        fprintf(dest,"%+#06x,",off_bitmap[i]);
      }
      fprintf(dest,"%+#06x\n};\n",
                    on_bitmap[RASTER_WORTE - 1]);
      fclose(dest);
    }
    Pfeil;
  }   
  *(strrchr(path,'\\') + 1) = 0; /* Pfadnamen
                                  korrigieren */
}
/*---------------------------------------------*/
void make_header(FILE *dest)
{
  /* Erzeugt einen Header mit der Datenstruktur
    'SWITCH'. Ist nur fÅr den ersten Schalter
    nîtig, folgende kînnen angefÅgt werden     */

  fprintf(dest,"/**************************/\n"
               "/* Schalter-Datenstruktur */\n"
               "/**************************/\n");
  fprintf(dest,"typedef struct\n{\n\tint on[%d];"
               "\n\tint off[%d];\n} SWITCH;\n\n",
               RASTER_WORTE,RASTER_WORTE);
  fprintf(dest,"/**************************/\n"
               "/*    Schalter-Bitmaps    */\n"
               "/**************************/\n");
}
/*---------------------------------------------*/
