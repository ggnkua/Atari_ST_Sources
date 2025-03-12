/****************************************/
/* DRAG.C : MultipleDragging            */
/*    von : Markus H”vener,             */
/*          (c) MAXON Computer 1991     */
/*  Datum : 9.1.1991                    */
/****************************************/
    
# include <aes.h>
# include <vdi.h>

# include "drag.h"

/* Die Rechtecke */
static GRECT rect[8]; 

/* Mausparameter & Vektoren */
static int mousex, 
           mousey, 
           mousek,
           x_vec,
           y_vec;
           
/****************************************/
/* Eintragen                            */
/****************************************/
void set_rect ( int index, int x, int y, int w, int h )
{
  rect[index].g_x = x;
  rect[index].g_y = y;
  rect[index].g_w = w;
  rect[index].g_h = h;
}

/****************************************/
/* Die Hauptroutine                     */
/****************************************/
void move_rect ( int v_handle, int rect_anzahl, int *result_x, int *result_y, int work_x, int work_y, int work_w, int work_h )
{
  int i,
      big_x = work_w,
      big_y = work_h,
      big_w = 0,
      big_h = 0,
      anfang_x, 
      anfang_y,
      _void,
      old_x,
      old_y;
  
  vswr_mode( v_handle, MD_XOR );

  /* Eigener Linientyp */
  vsl_type ( v_handle, 7 );

  /* Normale Breite */
  vsl_width( v_handle, 1 );
  
  /* Grožes Rechteck ermitteln */
  for ( i=0;i<rect_anzahl;i++ )
  {
    big_x = ( (rect[i].g_x < big_x ) ? rect[i].g_x : big_x );
    big_y = ( (rect[i].g_y < big_y ) ? rect[i].g_y : big_y );
    big_w = ( (rect[i].g_x + rect[i].g_w > big_w) ? rect[i].g_x + rect[i].g_w : big_w );
    big_h = ( (rect[i].g_y + rect[i].g_h > big_h) ? rect[i].g_y + rect[i].g_h : big_h );
  }

  /* Mausposition ermitteln */
  vq_mouse ( v_handle, &_void, &anfang_x, &anfang_y );
  
  /* Die  Hauptschleife */
  do
  {
    vq_mouse ( v_handle, &_void, &old_x, &old_y );
    x_vec = old_x - anfang_x;
    y_vec = old_y - anfang_y;
 
    if ( big_x + x_vec < work_x )
      x_vec = -big_x + work_x;
    if ( big_y + y_vec < work_y )
      y_vec = -big_y + work_y;
    
    if ( big_w+ x_vec > work_w )
      x_vec = work_w-big_w;
    if ( big_h + y_vec > work_y + work_h )
      y_vec = work_h - big_h + work_y;
      
    /* Zum ersten Mal malen */
    draw_boxes( v_handle, rect_anzahl );
    
    do
    {
      /* Warten... */
      vq_mouse ( v_handle, &mousek, &mousex, &mousey );
    }
    while ( (old_x == mousex) && (old_y == mousey) && (mousek!= 0) ); 

    /* Zum zweiten Mal */
    draw_boxes( v_handle, rect_anzahl );
  }
  while ( mousek != 0 );

  /* End-Vektor berechnen */
  *result_x = x_vec;
  *result_y = y_vec;

  /* Alter Modus */
  vswr_mode( v_handle, MD_REPLACE );
  vsl_type ( v_handle, 1 );
}

/****************************************/
/* Das Malen der Boxen                  */
/****************************************/
void draw_boxes ( int v_handle, int anzahl )
{
  int i,
      xy[4];
      
  /* Maus hidden */
  graf_mouse ( M_OFF, 0L );

  for ( i=0;i<anzahl;i++ )
  {
    xy[0] = xy[2] = rect[i].g_x + x_vec;
    xy[1] = rect[i].g_y + y_vec;
    xy[3] = rect[i].g_y + rect[i].g_h + y_vec;
    vsl_udsty( v_handle,
               ( ( (xy[0]%2) == (xy[1]%2) )
                 ? 21845
                 : (int)43690L ) );
    v_pline ( v_handle, 2, xy );

    xy[0] = xy[2] = rect[i].g_x + rect[i].g_w + x_vec;
    vsl_udsty( v_handle,
               ( ( (xy[0]%2) == (xy[1]%2) )
                 ? 21845
                 : (int)43690L ) );
    v_pline ( v_handle, 2, xy );

    xy[0] = rect[i].g_x + x_vec;
    xy[2] = rect[i].g_x + rect[i].g_w + x_vec;
    xy[1] = xy[3] = rect[i].g_y + y_vec;
    vsl_udsty( v_handle,
               ( ( (xy[1]%2) )
                 ? (int)43690L
                 : 21845 ) );
    v_pline ( v_handle, 2, xy );

    xy[1] = xy[3] = rect[i].g_y + rect[i].g_h + y_vec;
    vsl_udsty( v_handle,
               ( ( (xy[1]%2) )
                 ? (int)43690L
                 : 21845 ) );
    v_pline ( v_handle, 2, xy );
  }

  /* Maus wieder darstellen */
  graf_mouse ( M_ON, 0L );
}

