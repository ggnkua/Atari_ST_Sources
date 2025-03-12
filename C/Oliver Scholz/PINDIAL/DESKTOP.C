/*
 * DESKTOP.C
 * Verwaltung der auf dem Desktop
 * gepinnten Dialogboxen
 * by Oliver Scholz
 * Copyright (c) 1991 MAXON Computer
 */

#include <aes.h>
#include <portab.h>

#include "defs.h"
#include "pindials.h"

#define GLOBAL extern
#include "globals.h"

extern VOID redraw_dt_grect(WORD index,
                            GRECT *t2);
extern VOID get_grect(WORD index, GRECT *t);
extern VOID enlarge_grect(GRECT *t);
extern VOID redraw_dt_obj(WORD index);

VOID toggle_dt_button(WORD *but, WORD object);

VOID click_desktop(WORD index)
{
  GRECT t2;
  
    switch (index)
    {
      case FONTPIN:
          if(!font_pinned)
              return;
                           
          newdesk[FONTPIN].ob_spec.bitblk =
                pin_unpinned;
          newdesk[FONTIBOX].ob_flags |= HIDETREE;
          newdesk[FONTOK].ob_flags &= ~HIDETREE ;
          font_pinned = FALSE;
                        
          get_grect(FONTBOX,&t2);
          enlarge_grect(&t2);
          redraw_dt_grect(ROOT, &t2);

          break;

      case TEXTPIN:
          if(!text_pinned)  /* Tool Dialog Pin */
              return;
                
          newdesk[TEXTPIN].ob_spec.bitblk =
                pin_unpinned;
          newdesk[TEXTIBOX].ob_flags |= HIDETREE;
          newdesk[TEXTOK].ob_flags &= ~HIDETREE ;
          text_pinned = FALSE;
          
          get_grect(TEXTBOX,&t2);
          enlarge_grect(&t2);
          redraw_dt_grect(ROOT, &t2);

          break;
                        
      case FPICA:
      case FELITE:
      case FTIMES:
          switch(status.font)
          {
              case PICA:
                  newdesk[FPICA].ob_state &= 
                        ~SELECTED;
                  redraw_dt_obj(FPICA);
                  break;
                    
              case TIMES:
                  newdesk[FTIMES].ob_state &=
                        ~SELECTED;
                  redraw_dt_obj(FTIMES);
                  break;
                    
              case ELITE:
                  newdesk[FELITE].ob_state &=
                        ~SELECTED;
                  redraw_dt_obj(FELITE);
                  break;
          }
          newdesk[index].ob_state |= SELECTED;
          redraw_dt_obj(index);
          
          switch(index)
          {
              case FELITE:
                  status.font = ELITE;
                  break;
                  
              case FTIMES:
                  status.font = TIMES;
                  break;
                    
              case FPICA:
                  status.font = PICA;
                  break;
          }
          break;

      case TKURSIV:
          toggle_dt_button(&status.kursiv,index);
          break;
                            
      case TUNTER:
          toggle_dt_button(&status.unterstrichen,
                           index);
          break;

      case TLEICHT:
          toggle_dt_button(&status.leicht,index);
          break;

      case TFETT:
          toggle_dt_button(&status.fett, index);
          break;
    }
}
 
/* Knopf umschalten, entsprechende   */
/* Variable umsetzen und neuzeichnen */
 
VOID toggle_dt_button(WORD *but, WORD object)
{
    if (*but)
    {
        *but = FALSE;
        newdesk[object].ob_state &= ~SELECTED;
    }
    else
    {
        *but = TRUE;
        newdesk[object].ob_state |= SELECTED;
    }
    redraw_dt_obj(object);
}
