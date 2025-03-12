/*****************************************************************************/
/*   RCLIB.H Allgemeine RCLIB Definitionen                                   */
/*****************************************************************************/
/*                                                                           */
/*    Autor:  Uwe Seimet                                                     */
/*                                                                           */
/*****************************************************************************/

#ifndef __RCLIB__
#define __RCLIB__

int rc_equal( GRECT *prec1, GRECT *prec2 );
void rc_copy( GRECT *psbox, GRECT *pdbox );
int rc_intersect( GRECT *p1, GRECT *p2 );
int rc_inside( int x, int y, GRECT *pt );
void rc_grect_to_array( GRECT *area, int *array );

#endif /* __RCLIB__ */