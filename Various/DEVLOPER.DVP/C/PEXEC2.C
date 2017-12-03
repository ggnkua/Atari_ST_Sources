/**********************************************************/
/*   Postchargement d'un programme avec lancement diff‚r‚ */
/*   Megamax Laser C            PEXEC2.C   */
/**********************************************************/

#include <osbind.h>

#define CHARGER 3
#define LANCER 4
#define NOMFICH "NOMPRG.TOS"
#define PARAMETRE ""
#define ENVIRONNEMENT ""

long  basepage;    

main()
{
  Cconws ("Ceci est le programme appelant.\15\12\12");
  
  basepage = Pexec (CHARGER, NOMFICH, PARAMETRE, ENVIRONNEMENT);
  if (basepage < 0)
    Cconws ("Une erreur s'est produite!\15\12\12");
  else
  {
    Cconws ("Le programme a ‚t‚ charg‚. TOUCHE pour le lancer!\15\12\12");

    Crawcin();

    Pexec (LANCER, 0L, basepage, 0L);

    Cconws ("Revoici l'ancien programme!\15\12\12");
  }
  
  Crawcin();
}
