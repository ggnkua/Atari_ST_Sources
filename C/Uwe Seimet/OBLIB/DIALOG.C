/* Dialog mittels ob_draw_dialog, ob_undraw_dialog und ob_undostate */
/* tree erhÑlt die Adresse des Objektbaums                          */
/* index ist die Nummer des ersten Eingabefeldes                    */

void dialog(tree,index)
OBJECT *tree;
int index;
{
  int exit_obj;

  ob_draw_dialog(tree,40,40,4,4);         /* Dialog mit growbox zeichnen  */
  exit_obj=form_do(tree,index);           /* Benutzereingaben abwarten    */
  ob_undraw_dialog(tree,40,40,4,4);       /* Dialog entfernen, shrinkbox  */
  ob_undostate(tree,exit_obj,SELECTED);   /* Exit-Button zurÅcksetzen     */
  return;                                 /* so einfach ist das           */
}
