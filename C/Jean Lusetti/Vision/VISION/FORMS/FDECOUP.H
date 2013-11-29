#ifndef __FDECOUP
#define __FDECOUP

typedef struct
{
  int valid ;
  int nb_colonnes ;
  int nb_lignes ;
  int num ;
}
DECOUP ;

int get_decoup(DECOUP *dcp) ;

#endif
