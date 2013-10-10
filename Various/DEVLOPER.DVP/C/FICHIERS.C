/*************************************************/
/*       Exemple de fichiers sous GEMDOS       */
/*  Megamax Laser C    FICHIERS.C  */
/*************************************************/

#define  LECT_SEUL 1
#include <osbind.h>

int  handle;
char *ligne = {"Voici le texte qui va entrer dans le fichier."}; 
main()
{
  handle = Fcreate ("READ.ME", LECT_SEUL);
  
  if (handle < 0)
    printf ("Erreur … l'ouverture du fichier!\n");
  else
  {
    Fwrite (handle, (long) strlen (ligne), ligne);
    Fclose (handle);
  }
}


