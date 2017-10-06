/* demineur.c */

#include "header.h"
#include "demineur.h"

struct jeu **tableau ;   /* le tableau de jeu */

int nb_lig = NB_LIG ;    /* nombre de lignes   du tableau de jeu */
int nb_col = NB_COL ;    /* nombre de colonnes du tableau de jeu */
int nb_mines ;           /* nombre de mines    du tableau de jeu */

int mines ;              /* nombre de mines restant a trouver */

unsigned long temps ;           /* nombre de secondes ecoulees depuis le debut du jeu */

int perdu , gagne , jeu , ouvre = 0 ;
int score;

extern unsigned long temps;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Gestion du jeu ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

int aleatoire()
{
	return randint()^(0x7fff&(unsigned int)systime());
}


void gagne_perdu ( )
{
   register int l , c;
   int ok = 1 ;

   for ( l = 1 ; l <= nb_lig ; l ++ )
   {
      for ( c = 1 ; c <= nb_col ; c ++ )
      {
         if ( tableau [ l ] [ c ] . etat != DECOUVERTE &&
              tableau [ l ] [ c ] . etat != MARQUEE )
         {
            ok = 0 ;
         }
      }
   }
   if ( ok )   /* gagne ! */
   {
      gagne = 1 ;
      jeu = 0 ;
      icone_perdu_gagne ( ) ;
      score=(unsigned int)temps;      
	  if (score<999) save_hall();
   }
}



void decouvre ( lig , col )
int lig , col ;
{
   if ( lig >= 1 && lig <= nb_lig && col >= 1 && col <= nb_col )
   {
      if ( tableau [ lig ] [ col ] . etat != DECOUVERTE &&
           tableau [ lig ] [ col ] . etat != MARQUEE )
      {
         tableau [ lig ] [ col ] . etat = DECOUVERTE ;
         affiche_case ( lig , col ) ;
         if ( tableau [ lig ] [ col ] . mine )
         {
            perdu = 1 ;
            jeu = 0 ;
            affiche_jeu ( ) ;
         }
         if ( tableau [ lig ] [ col ] . nombre == 0 )
         {
            decouvre ( lig - 1 , col - 1 ) ;
            decouvre ( lig - 1 , col     ) ;
            decouvre ( lig - 1 , col + 1 ) ;
            decouvre ( lig     , col - 1 ) ;
            decouvre ( lig     , col + 1 ) ;
            decouvre ( lig + 1 , col - 1 ) ;
            decouvre ( lig + 1 , col     ) ;
            decouvre ( lig + 1 , col + 1 ) ;
         }
         if ( mines == 0 )   /* gagne ? */
         {
            gagne_perdu ( ) ;
         }
      }
   }
}



void remplis_et_compte ( )
{
   register int l , c , i ;

   /* initialisation des variables */

   mines = nb_mines ;
   temps = 0L ;
   perdu = gagne = jeu = 0 ;

   /* initialisation du tableau */

   for ( l = 0 ; l < nb_lig + 2 ; l ++ )
   {
      for ( c = 0 ; c < nb_col + 2 ; c ++ )
      {
         tableau [ l ] [ c ] . mine   = 0 ;
         tableau [ l ] [ c ] . nombre = 0 ;
         tableau [ l ] [ c ] . etat   = COUVERTE ;
      }
   }

   /* pose des mines */

   i = nb_mines ;
   while ( i > 0 )
   {
      l = 1 + ( int ) ( aleatoire ( ) % nb_lig ) ;
      c = 1 + ( int ) ( aleatoire ( ) % nb_col ) ;
      if ( ! tableau [ l ] [ c ] . mine )
      {
         tableau [ l ] [ c ] . mine = 1 ;
         i -- ;
      }
   }

   /* comptage des mines */

   for ( l = 1 ; l <= nb_lig ; l ++ )
   {
      for ( c = 1 ; c <= nb_col ; c ++ )
      {
         tableau [ l ] [ c ] . nombre = mine01 ( l - 1 , c - 1 ) +
                                        mine01 ( l - 1 , c     ) +
                                        mine01 ( l - 1 , c + 1 ) +
                                        mine01 ( l     , c - 1 ) +
                                        mine01 ( l     , c + 1 ) +
                                        mine01 ( l + 1 , c - 1 ) +
                                        mine01 ( l + 1 , c     ) +
                                        mine01 ( l + 1 , c + 1 ) ;
      }
   }

   /* ouverture automatique */

   while ( ouvre )
   {
      l = 1 + ( int ) ( aleatoire ( ) % nb_lig ) ;
      c = 1 + ( int ) ( aleatoire ( ) % nb_col ) ;
      if ( tableau [ l ] [ c ] . nombre == 0 &&
           ! tableau [ l ] [ c ] . mine )
      {
         decouvre ( l , c ) ;
         break ;
      }
   }
}


int mine01 ( lig , col )
int lig , col ;
{
   return ( tableau [ lig ] [ col ] . mine ? 1 : 0 ) ;
}

void joue ( lig , col )
int lig , col ;
{
   if ( tableau [ lig ] [ col ] . mine )   /* perdu ! */
   {
      perdu = 1 ;
      jeu = 0 ;
      tableau [ lig ] [ col ] . etat = DECOUVERTE ;
      affiche_jeu ( ) ;
   }
   else if ( tableau [ lig ] [ col ] . nombre == 0 )
   {
      decouvre ( lig , col ) ;
   }
   else
   {
      tableau [ lig ] [ col ] . etat = DECOUVERTE ;
      affiche_case ( lig , col ) ;
   }
   if ( mines == 0 )   /* gagne ? */
   {
      gagne_perdu ( ) ;
   }
}

void double_clic ( lig , col )
int lig , col ;
{
   decouvre ( lig - 1 , col - 1 ) ;
   decouvre ( lig - 1 , col     ) ;
   decouvre ( lig - 1 , col + 1 ) ;
   decouvre ( lig     , col - 1 ) ;
   decouvre ( lig     , col + 1 ) ;
   decouvre ( lig + 1 , col - 1 ) ;
   decouvre ( lig + 1 , col     ) ;
   decouvre ( lig + 1 , col + 1 ) ;
}

void marque ( lig , col )
int lig , col ;
{
   switch ( tableau [ lig ] [ col ] . etat )
   {
   case COUVERTE :
      if ( mines > 0 )
      {
         tableau [ lig ] [ col ] . etat = MARQUEE ;
         mines -- ;
         nombre_de_mines ( ) ;
         affiche_case ( lig , col ) ;
         if ( mines == 0 )   /* gagne ? */
         {
               gagne_perdu ( ) ;
         }
      }
      break ;
   case MARQUEE :
      tableau [ lig ] [ col ] . etat = INTERRO ;
      mines ++ ;
      nombre_de_mines ( ) ;
      affiche_case ( lig , col ) ;
      break ;
   case INTERRO :
      tableau [ lig ] [ col ] . etat = COUVERTE ;
      affiche_case ( lig , col ) ;
      break ;
   }
}
