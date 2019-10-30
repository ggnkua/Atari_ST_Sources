/*********************************/
/*  AFFICHAGE MESSAGES D'ERREUR  */
/*********************************/
#include <STDIO.H>
#include <GEMFAST.H>
#include <INITGEM.H>

void aff_erreurs()
{
  form_error(0);
  form_error(2);
  form_error(4);
  form_error(5);
  form_error(8);
  form_error(15);
}

void main()
{
  InitGem();
  aff_erreurs();
  CloseGem();
}
