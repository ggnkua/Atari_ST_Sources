#ifndef __LDV
#define __LDV

#ifndef __LDG__
#include "ldg.h"
#endif

/* Structure de definition du LDV  */
/* Popur un nombre de plans defini */
typedef struct
{
  short NbPlanes ; /* Nombre de plans de l'image :  */
                   /* 0 : Ignorer cette structure   */
                   /* 1, 2, 4, 8, 15, 16, 24, ou 32 */
}
LDV_CAPS ;

typedef struct
{
  short StrSize ;          /* Taille de la structure LDV_INFOS */
  char  ShortName[1+15] ;  /* Nom court du module              */
  char  LongName[1+31] ;   /* Nom long du module               */
  char  Authors[1+45] ;    /* Liste du ou des auteurs          */
  char Description[1+79] ; /* Description du module            */

  LDV_CAPS Caps[10] ;      /* Ce que ce LDV sait faire, pour   */
                           /* Chaque type d'image              */
                           /* Mettre cette structure a zero    */
                           /* Des que la liste est terminee    */
}
LDV_INFOS ;


LDV_MODULE *LDVGetModuleList(char *path) ;
void        LDVFreeModuleList(LDV_MODULE *module_list) ;

#endif
