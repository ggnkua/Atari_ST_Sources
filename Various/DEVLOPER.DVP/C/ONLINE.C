/*****************************************************************/
/*   Teste si l'imprimante est prˆte … recevoir (avec Bcostat)   */
/*****************************************************************/

#include <osbind.h>
#define  imprimante 0
#define  console 2

int  status;

main()
{
  status = Bcostat (imprimante);
  
  if (status == -1)
    printf ("\nL'imprimante est prˆte!\n");
  else
    printf ("\nL'imprimante n'est pas prˆte!\n");
      Bconin (console);     /* Attend touche */
}

