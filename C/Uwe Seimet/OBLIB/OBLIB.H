/*****************************************************************************/
/*   OBLIB.H Allgemeine OBLIB Definitionen                                   */
/*****************************************************************************/
/*                                                                           */
/*    Autor:  Uwe Seimet                                                     */
/*                                                                           */
/*****************************************************************************/

#ifndef __OBLIB__
#define __OBLIB__

void ob_dostate ( OBJECT *tree, int index, int state );
void ob_undostate ( OBJECT *tree, int index, int state );
int ob_isstate ( OBJECT *tree, int index, int state );
void ob_doflag ( OBJECT *tree, int index, int flag );
void ob_undoflag ( OBJECT *tree, int index, int flag );
int ob_isflag ( OBJECT *tree, int index, int flag );
void ob_xywh ( OBJECT *tree, int index, GRECT *rec );
char *ob_get_text ( OBJECT *tree, int index, int clear );
void ob_set_text ( OBJECT *tree, int index, char *p );
void ob_draw_dialog ( OBJECT *tree, int xl, int yl, int wl, int hl );
void ob_undraw_dialog ( OBJECT *tree, int xl, int yl, int wl, int hl );

#endif /* __OBLIB__ */