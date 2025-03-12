/*********************************************/
/*   Modul : REALTIME.C                      */
/* Aufgabe : Slider in Echtzeit              */
/*   Autor : Markus H”vener                  */
/*   Datum : 7.9.1991                        */
/*           (c) MAXON Computer GmbH         */
/*********************************************/


# include <aes.h>
# include <portab.h>

# include "realtime.h"



/*********************************************/
/* Slider in Echtzeit bewegen                */
/*********************************************/
VOID DoRealtimeSlide( OBJECT  *dialptr,
          WORD    back_index, WORD slider_index,
          WORD    slider_type,
          VOID    (*call_func)(WORD new_pos) )
{
  WORD   /* Aktuelle Mauskoordinaten     */
         m_x, m_y,  
         /* Anf„ngliche Mauskoordinaten  */       
         beg_mx, beg_my,
         /* Anf„ngliche Sliderpositionen */   
         dial_x, dial_y,
         /* Koordinaten des 'back_index' */   
         abs_x, abs_y,
         /* Maximale Sliderposition */     
         max_pos,
         /* Position zum Vergleich  */          
         prev_x, prev_y,   
         events,
         _void;
         
  
  /* Maus als Hand */
  graf_mouse( FLAT_HAND, 0L );
  
  
  /* Mauskoordinaten holen */
  graf_mkstate( &m_x, &m_y, &_void, &_void );
  beg_mx = m_x;
  beg_my = m_y;


  /* Sliderposition ermitteln */
  dial_x = dialptr[slider_index].ob_x;
  dial_y = dialptr[slider_index].ob_y;

  
  /* Maximale Verschiebung */
  if( slider_type == VERT_SLIDER )
    max_pos = dialptr[back_index].ob_height -
              dialptr[slider_index].ob_height;
  else
    max_pos = dialptr[back_index].ob_width - 
              dialptr[slider_index].ob_width;
  

  /* Absolute Koordinaten vom Hintergrundobjekt */
  objc_offset( dialptr, back_index, &abs_x, &abs_y );
  
  
  
  do
  {
    /* Sliderposition merken */
    prev_x = dialptr[slider_index].ob_x;
    prev_y = dialptr[slider_index].ob_y;
    
    
    /* Event */
    events = evnt_multi( /* Maus- und Rechteckevents */
                         MU_BUTTON|MU_M1,
                         /* Mausklick */
                         1, 1, 0,
                         /* Das Rechteck */
                         1, m_x, m_y, 1, 1,
                         0, 0, 0, 0, 0,
                         /* Message-Buffer */
                         0L,
                         /* Kein Timer */
                         0, 0,
                         /* Endparameter */
                         &m_x,   &m_y,   &_void,
                         &_void, &_void, &_void );

    /* Neue Position errechnen */
    if( slider_type == VERT_SLIDER )
      dialptr[slider_index].ob_y = dial_y + m_y - beg_my;
    else
      dialptr[slider_index].ob_x = dial_x + m_x - beg_mx;
      
    
    /* Eingrenzen */
    if( slider_type == VERT_SLIDER )
    {
      dialptr[slider_index].ob_y = (dialptr[slider_index].ob_y < 0)
                                   ? 0
                                   : dialptr[slider_index].ob_y;
      dialptr[slider_index].ob_y = (dialptr[slider_index].ob_y > max_pos)
                                   ? max_pos 
                                   : dialptr[slider_index].ob_y;
    }
    else
    {
      dialptr[slider_index].ob_x = (dialptr[slider_index].ob_x < 0)
                                   ? 0  
                                   : dialptr[slider_index].ob_x;
      dialptr[slider_index].ob_x = (dialptr[slider_index].ob_x > max_pos)
                                   ? max_pos 
                                   : dialptr[slider_index].ob_x;
    }


    /*****************************************/
    /* Žnderung                              */
    /*****************************************/
    if( (dialptr[slider_index].ob_y != prev_y) ||
        (dialptr[slider_index].ob_x != prev_x) )
    {
      /* Funktion evtl. aufrufen */
      if( call_func )
        call_func( dialptr[slider_index].ob_y );

      
      /* Den Hintergrund neumalen */
      if( slider_type == VERT_SLIDER )
      {
        if( dialptr[slider_index].ob_y > prev_y )
          objc_draw( dialptr, back_index, 1,
                     abs_x,
                     abs_y + prev_y - 1,
                     dialptr[back_index].ob_width,
                     dialptr[slider_index].ob_y - prev_y );
        else
          objc_draw( dialptr, back_index, 1,
                     abs_x,
                     abs_y + dialptr[slider_index].ob_y + dialptr[slider_index].ob_height,
                     dialptr[back_index].ob_width,
                     prev_y - dialptr[slider_index].ob_y + 1 );
      }
      else
      {
        if( dialptr[slider_index].ob_x > prev_x )
          objc_draw( dialptr, back_index, 1,
                     abs_x + prev_x - 1,
                     abs_y,
                     dialptr[slider_index].ob_x - prev_x,
                     dialptr[back_index].ob_height );
        else
          objc_draw( dialptr, back_index, 1,
                     abs_x + dialptr[slider_index].ob_x + dialptr[slider_index].ob_width,
                     abs_y,
                     prev_x - dialptr[slider_index].ob_x + 1,
                     dialptr[back_index].ob_height );
      }
      
      /* ... und den Slider neumalen */
      objc_draw( dialptr, slider_index, 1,
                 abs_x, 
                 abs_y + dialptr[slider_index].ob_y - 1,
                 abs_x + dialptr[slider_index].ob_width,
                 abs_y + dialptr[slider_index].ob_y + dialptr[slider_index].ob_height );
    }
  }
  while( !(events & MU_BUTTON) );
  
  
  /* Normale Maus */
  graf_mouse( ARROW, 0L );
}