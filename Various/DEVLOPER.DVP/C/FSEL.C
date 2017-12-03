/****************************************************************/
/*   Consulter un nom de fichier dans le s‚lecteur de fichiers  */
/*   Megamax Laser C                      FSEL.C   */
/****************************************************************/

#include <osbind.h>
#include "gem_inex.c"

char fname[80];

int filename(masque, def, affichage)    /* def = default, */
    char masque[], def[], affichage[];  /* r‚serv‚ en C   */
{
  char path[64],
       fnam[13];
  int  back,
       button,
       i;
  
  strcpy (fnam, def);
  
  path[0] = 'A' + Dgetdrv();  /* Nom du lecteur courant */
  path[1] = ':';
  Dgetpath (&path[2], 0);     /* Chemin du lecteur courant */
  strcat (path, "\\");        /* \\ signifie \ */
  strcat (path, masque);
  
  back = fsel_input (path, fnam, &button);
  
  if (button == 0 || fnam[0] == '\0') 
    return (0);  /* La fonction = 0 si quitte ou erreur de s‚lection*/

  for (i = strlen(path) - 1;   path[i] != '\\';   path[i--] = '\0'); 
  strcat (path, fnam);
  strcpy (affichage, path);
  
  return (1);
}


main()
{
  gem_init();
  graf_mouse (0, 0L);     /* Pointeur souris normal (flŠche) */
  
  if (filename ("*.*", "", fname))
    Cconws (fname);
  else
    Cconws ("S‚lection erron‚e!");
    
  Crawcin();
  
  gem_exit();
}                                                                
