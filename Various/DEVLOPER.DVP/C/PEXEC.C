/*********************************************************************/
/*   Postchargement d'un programme et lancement imm‚diat par Pexec   */
/*            Megamax Laser C          PEXEC.C        */
/*********************************************************************/


#include <osbind.h>

#define CHARGE_ET_LANCE 0
#define NOMFICH "NOMPRG.TOS"
#define PARAMETRE ""
#define ENVIRONNEMENT ""

main()
{
  Cconws ("Ceci est le programme appelant.\15\12\12");

  if (Pexec (CHARGE_ET_LANCE, NOMFICH, PARAMETRE, ENVIRONNEMENT) < 0)  
      Cconws("Une erreur s'est produite!!!\15\12\12");

  Cconws ("Revoici le programme appelant!\15\12"); 
  Crawcin();     /* Fin en tapant une touche */
}
