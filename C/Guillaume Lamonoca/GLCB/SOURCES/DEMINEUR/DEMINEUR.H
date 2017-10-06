/* demineur.h */

extern int RATIO;		/* 2:demineur normal 1:demineur rapide (enorme) */

#define BORD           (19-7*RATIO)   /* bord entourant la fenetre et le tableau de jeu */
#define LARG_BORD      (3/RATIO)   /* largeur du bord (en pixels) */

#define MARGE_HAUT    ( 2 * BORD + (58/RATIO) )   /* marge superieure (icone, indicateurs) */

#define LARG_CASE     (20/RATIO)   /* largeur d'une case (en pixels) */
#define HAUT_CASE     (20/RATIO)   /* hauteur d'une case (en pixels) */

#define X_JEU         BORD
#define Y_JEU         MARGE_HAUT
#define LARG_JEU      nb_col * LARG_CASE + nb_col + 1
#define HAUT_JEU      nb_lig * HAUT_CASE + nb_lig + 1

#define LARGEUR_FEN   LARG_JEU + 2 * BORD
#define HAUTEUR_FEN   HAUT_JEU + MARGE_HAUT + BORD
#define X_FEN         ( 320 - LARGEUR_FEN ) / 2
#define Y_FEN         ( 200 - HAUTEUR_FEN ) / 2

#define HAUT_NUMERO   (30/RATIO)
#define LARG_NUMERO   (20/RATIO)

#define X_NB_MINES    ( MARGE_HAUT - HAUT_NUMERO ) / 2
#define Y_NB_MINES    ( MARGE_HAUT - HAUT_NUMERO ) / 2

#define LARG_ICONE    (40/RATIO)
#define HAUT_ICONE    (40/RATIO)
#define X_ICONE       ( LARGEUR_FEN - LARG_ICONE ) / 2
#define Y_ICONE       ( MARGE_HAUT  - HAUT_ICONE ) / 2 

#define X_CHRONO      LARGEUR_FEN - ( MARGE_HAUT - HAUT_NUMERO ) / 2 - 3 * LARG_NUMERO
#define Y_CHRONO      ( MARGE_HAUT - HAUT_NUMERO ) / 2


#define NB_LIG     16   /* nombre de lignes   du tableau de jeu (par defaut) */
#define NB_COL     30   /* nombre de colonnes du tableau de jeu (par defaut) */
#define NB_MINES   ( int ) ( ( double ) ( nb_lig * nb_col ) / 4.8 )

struct jeu
{
   int       mine ;     /* 1 s'il y a une mine, 0 sinon  */
   int       nombre ;   /* nombre de mines autour de cette case */
   enum
   {
      COUVERTE     /* on n'a pas regarde     */ ,
      DECOUVERTE   /* on a decouvert la case */ ,
      MARQUEE      /* il y a une mine        */ ,
      INTERRO      /* on se demande          */
   }
   etat ;          /* etat de la case */
} ;
