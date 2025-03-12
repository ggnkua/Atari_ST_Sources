#ifndef __NEWRUBBER
#define __NEWRUBBER

# include <portab.h>


/* Verwaltet die Rubberbox */
WORD DoRubberbox( WORD  v_handle,
                  WORD  start_x, WORD start_y,
                  GRECT *rect,
                  WORD  *res_width, WORD *res_height,
                  VOID  (*call_func)(WORD *new_rect) );
                  
VOID DrawBox( WORD v_handle, WORD x1, WORD y1, WORD x2, WORD y2 );

#endif