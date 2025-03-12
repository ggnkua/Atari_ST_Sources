# include <aes.h>
# include <portab.h>


/* Konstanten fÅr slider_type */
#define VERT_SLIDER   1
#define HORT_SLIDER   !VERT_SLIDER


VOID DoRealtimeSlide( OBJECT  *dialptr,
                      WORD    back_index, WORD slider_index,
                      WORD    slider_type,
                      VOID    (*call_func)(WORD new_pos) );
