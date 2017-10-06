/* arkanoid.c

inspire de Arkanoid  (mais tres loin...)

Gilles ROY
Supelec Promotion 94

*/


#ifndef VMS
#ifndef unix
#define cuserid(x) ""
#endif
#endif

#include <stdio.h>
#include <string.h>
#include "header.h"
#include "level.h"



typedef void *bloc;

extern unsigned int Jeupal[];
extern char *balle[],*raquette[],*raqtir[],*tir[],*logo[],*bidule[];
extern char *miniraq[],*fond[],*fond2[],*raq_larg[];

extern char *prime_raq[],*prime_tir[],*prime_colle[];
extern char *prime_large[],*prime_lent[],*prime_multi[],*prime_sortie[];

extern char *prime_raq_m[],*prime_tir_m[],*prime_colle_m[];
extern char *prime_large_m[],*prime_lent_m[],*prime_multi_m[],*prime_sortie_m[];

extern bloc S_Balle,S_Raquette,S_RaqTir,S_Tir,S_Logo,S_Bidule,S_MiniRaq,S_Fond,S_Fond2;
extern bloc S_RaqLarg;

/***************************************************************************
***************     Definition des constantes      *************************
***************************************************************************/


#define ORG_X     7
#define ORG_Y     7
#define MINIRAQ_Y 190
#define BORG_X    ORG_X+1
#define BORG_Y    ORG_Y+2
#define TAILLE_X  16
#define TAILLE_Y  8
#define RAQ_Y     180
#define MAX_X     217
#define BAS_ECRAN 196.
#define MAX_Y     190
#define H_BALLE   4.
#define L_BALLE   4.
#define VINIT     5
#define DYINIT    -0.866
#define DXINIT    0.5
#define MAX_LIG_BR 17
#define MAX_COL_BR 13
#define AVEC_DECOUPE       1
#define SANS_DECOUPE       0

#define MAX_CONTACT	50

#define MAX_LARG  48
#define MIN_LARG  34

#define OUI 1
#define NON 0

#define MAX_TIR   22
#define DELAI_TIR 3
#define UTILISE   1
#define LIBRE     0

const float MaxX = (float)(BORG_X+MAX_COL_BR*TAILLE_X-(int)L_BALLE);
const float MaxY = (float)(RAQ_Y-4);
const float MinX = (float)(ORG_X);
const float MinY = (float)(ORG_Y);
const float TabDx[] = { -0.99 , -0.70 , -0.5 , 0.5 , 0.7 , 0.99 };
const float TabDy[] = {  -.34 , -.70  ,  -.86, -.86, -.70, -.34 };


#define HALLNAME "kakanoid.hll"

#define NOIR         0
#define ORANGE       1
#define JAUNE        2
#define VERT         3
#define ROSE         4
#define ROUGE        5
#define ROUGE_FONCE  6
#define GRIS         7
#define GRIS_CLAIR   8
#define CYAN         9
#define BLEU_1       10
#define BLEU_2       11
#define BLEU_3       12
#define BLEU_4       13 
#define BLEU         14 
#define BLANC        15

#define PR_LENT   0
#define PR_LARGE  1
#define PR_COLLE  2
#define PR_MULTI  3
#define PR_TIR    4
#define PR_RAQ	  5
#define PR_SORTIE 6
#define MAX_PRIME 7
#define PRIME_X   228
#define PRIME_Y   90

#define SCORE_X   230
#define SCORE_Y   40

#define COLLE     1
#define RIEN      -1

#define HALL(a,b) (unsigned long)(G_Podium[a].score[b])
#define SCORE(i) HALL(i,0)*65536L+HALL(i,1)*256L+HALL(i,2)

#define MAX_PODIUM 10

/***************************************************************************
***************     Definition des types de donnees      *******************
***************************************************************************/

typedef struct
{
 char		nom[9];
 unsigned char	score[3];
 char		level;
} Joueur;


typedef struct
{
 float X,Y,Dx,Dy;
} Balle;

typedef struct
{
 int x,y;
 int etat;
} Tir;

typedef struct
{
 bloc	forme;
 int	proba;
 char	*texte;
 int    bonus;
} Prime;

/***************************************************************************
***************     Declaration des fonctions externes    ******************
***************************************************************************/
extern void GetSpriteFromChar( char *data[], bloc *Sprite );

/***************************************************************************
***************     Declaration des prototypes    **************************
***************************************************************************/
void GetBackup(void);
void GetLocalBackup(void);
void PutBackup(void);
void PutScore(void);
void ChangeScore(unsigned long nsc);
void TrouveHighScore(void);
void Jeu(void);
void Jouer(void);
void DessineDecor(void);
void CreatePodium(void);
void Podium(void);
void NouveauPodium(void);
void GetUsername(void);
void DessineBrique(int x, int y, char type );
void EffaceBrique(int x, int y );
void GameOver(void);
void ConstruireLevel(int dec);
int  ChoixLevel(void);
int  ChoixPosition(void);
void SetLevel( int level );
int  CompteBriques( void );
int  FaireRebond( Balle *balle, int RaqX , int *fin );
void DessineFond( void );
void DecoupeFond(void);
char **GenerePrime( char bord, char inter );
void Vide( void );
void TrouvePrime( void );
void InitPrimes( void );
void DessineMiniLevel( int xp,int yp,int level );

/***************************************************************************
***************     Declaration des variables globales    ******************
***************************************************************************/
Niveau        *G_Niveau;
int           G_Round;
int           G_NbRaq;
int           G_OldNbRaq;
char	      G_Nom[9];
int	      G_NomValide=0;
unsigned long G_Score=0L;
unsigned long G_HighScore=0L;
unsigned long G_OldScore=0L;
bloc          G_Backup;
bloc	      G_SuperSwap;
int           G_NbBalles;
int	      G_NbBriques;
int	      G_Vitesse;
bloc	      G_BlocFond[2*MAX_LIG_BR+1][MAX_COL_BR*2+1];
Prime	      G_BlocPrime[MAX_PRIME];
int	      G_Prime,G_Prime_x,G_Prime_y;
int	      G_Mode,G_Etat;
int	      G_Angle;
int 	      G_RaqLarg;
Tir	      G_Tir[MAX_TIR];
int	      G_FlagTir;
int	      G_Contact;
Joueur	      G_Podium[MAX_PODIUM];

int		G_updateXmin=2000;
int		G_updateXmax= -1;
int		G_updateYmin=2000;
int		G_updateYmax= -1;
bloc		tempobloc;
bloc		tempobloc2;
bloc		tempobloc3;

#ifdef VMS
extern int sdepth;
#else
int sdepth=8;
#endif

/***************************************************************************
***********************     Ca commence now     ****************************
***************************************************************************/
int main(void)
{
 unsigned int i,j;

 if (initsystem())
 {
  hide();
	
  setpalette(Jeupal);

  setcolor( BLANC );
  afftext( 100, 96 , "ATTENDEZ S.V.P.");
  swap();

  /**************************************************/
  /* Initialisation du bloc de sauvegarde du decors */
  /**************************************************/

  initbloc(&G_Backup);
  initbloc(&G_SuperSwap);
  initbloc(&tempobloc);
  initbloc(&tempobloc2);
  initbloc(&tempobloc3);

  /**********************************/
  /* Generation des sprites de base */
  /**********************************/
  GetSpriteFromChar( balle,&S_Balle );
  GetSpriteFromChar( raquette,&S_Raquette );
  GetSpriteFromChar( raq_larg,&S_RaqLarg );
  GetSpriteFromChar( raqtir,&S_RaqTir );
  GetSpriteFromChar( tir,&S_Tir );
  GetSpriteFromChar( logo,&S_Logo );
  GetSpriteFromChar( bidule,&S_Bidule );
  GetSpriteFromChar( miniraq,&S_MiniRaq );
  GetSpriteFromChar( fond,&S_Fond );
  GetSpriteFromChar( fond2,&S_Fond2 );

  /*******************************************************/
  /* Generation des sprites de primes a partir du modele */
  /*******************************************************/

  InitPrimes();

  if(sdepth == 1)
  {
   GetSpriteFromChar( prime_raq_m   , &G_BlocPrime[PR_RAQ].forme );
   GetSpriteFromChar( prime_tir_m   , &G_BlocPrime[PR_TIR].forme );
   GetSpriteFromChar( prime_colle_m , &G_BlocPrime[PR_COLLE].forme );
   GetSpriteFromChar( prime_large_m , &G_BlocPrime[PR_LARGE].forme );
   GetSpriteFromChar( prime_lent_m  , &G_BlocPrime[PR_LENT].forme );
   GetSpriteFromChar( prime_multi_m , &G_BlocPrime[PR_MULTI].forme );
   GetSpriteFromChar( prime_sortie_m, &G_BlocPrime[PR_SORTIE].forme );
  }
  else
  {
   GetSpriteFromChar( prime_raq   , &G_BlocPrime[PR_RAQ].forme );
   GetSpriteFromChar( prime_tir   , &G_BlocPrime[PR_TIR].forme );
   GetSpriteFromChar( prime_colle , &G_BlocPrime[PR_COLLE].forme );
   GetSpriteFromChar( prime_large , &G_BlocPrime[PR_LARGE].forme );
   GetSpriteFromChar( prime_lent  , &G_BlocPrime[PR_LENT].forme );
   GetSpriteFromChar( prime_multi , &G_BlocPrime[PR_MULTI].forme );
   GetSpriteFromChar( prime_sortie, &G_BlocPrime[PR_SORTIE].forme );
  }

  /*************************************************/
  /* Initialisation des bloc de sauvegarde du fond */
  /*************************************************/

  for( i = 0 ; i < MAX_LIG_BR*2+1 ; i++ )
   for( j = 0 ; j < MAX_COL_BR*2+1 ; j++ )
    initbloc( &G_BlocFond[i][j] );

  TrouveHighScore();
  Jeu();

  /*********************/
  /* Nettoyage general */
  /*********************/

  for( i = 0 ; i < MAX_LIG_BR*2+1 ; i++ )
   for( j = 0 ; j < MAX_COL_BR*2+1 ; j++ )
    freebloc( &G_BlocFond[i][j] );
	
  for( i = 0 ; i < MAX_PRIME ; i++) 
   freebloc( &G_BlocPrime[i].forme );

  freebloc(&S_Fond2);
  freebloc(&S_Fond);
  freebloc(&S_MiniRaq);
  freebloc(&S_Bidule);
  freebloc(&S_Logo);
  freebloc(&S_Tir);
  freebloc(&S_RaqTir);
  freebloc(&S_RaqLarg);
  freebloc(&S_Raquette);
  freebloc(&S_Balle);
		
  freebloc(&tempobloc3);
  freebloc(&tempobloc2);
  freebloc(&tempobloc);
  freebloc(&G_SuperSwap);
  freebloc(&G_Backup);

  killsystem();	
 }

 return 0;
}

/**************************************************************************/
void Jeu( void )
{
 char r=0;

 G_Niveau = &Levels[0];
 ConstruireLevel(SANS_DECOUPE);
 swap();

 while(1)
 {
  empty();
  r = getch();

  if( r == 'q' ) break;	
  if( r == 'p' ) Podium();
  if( r == 'j' ) Jouer();
 }
}

/**************************************************************************/
void Jouer(void)
{
 int   RaqX,fin,pause = 0;
 int   bx,by,i,j,redessiner;
 long  cpt;
 Balle Balle[3];

 G_OldNbRaq = G_NbRaq = 3;

 /**********************************************/
 /* 1) L'utilisateur choisi le level de depart */
 /**********************************************/

 ChangeScore(0);
 G_OldScore = 0;
 copyscreen();
 GetBackup();
 if( (G_Round = ChoixLevel()) == -1)
 {
  PutBackup();
  swap(); 
  GameOver();
  return;
 }
 
 ConstruireLevel(AVEC_DECOUPE);
 G_NbBriques = CompteBriques();
 G_NbBalles = 1;
 GetBackup();
 GetLocalBackup();

 /****************************************************/
 /* 2) L'utilisateur place la raquette ou il veut... */
 /****************************************************/

 empty();

 G_RaqLarg = MIN_LARG;
 if( (RaqX = ChoixPosition()) == 0)
 {
  GameOver();
  return;
 }

 /***********************************/
 /* 3) Initialisation des variables */
 /***********************************/

 G_Vitesse = VINIT;
 G_Prime = RIEN;
 G_Mode = RIEN;
 G_Etat = RIEN;
 cpt = 0;

 G_Angle = 3;
 Balle[0].Dy = DYINIT;
 Balle[0].Dx = DXINIT; 
 Balle[0].X = (float)(RaqX+G_RaqLarg/2);
 Balle[0].Y = (float)(RAQ_Y-5);
 Vide();

 /*********************/
 /* 4) C'est parti... */
 /*********************/

 empty();

 while( G_NbRaq > 0 )
 {
  PutBackup();

  G_updateXmin=2000;
  G_updateXmax= -1;
  G_updateYmin=2000;
  G_updateYmax= -1;
  redessiner = 0;

  fin = 0;

  while( (!kbhit()) && (fin == 0)  && (G_NbBriques > 0))
  {
   (void)buthit();

	/******************************/
	/* Deplacement de la raquette */
	/******************************/
 
   RaqX = mousex-16;
   if( RaqX < ORG_X           )  RaqX = ORG_X;
   else if( RaqX + G_RaqLarg >= MAX_X ) RaqX = MAX_X-G_RaqLarg;

	/****************************/
	/* Rencontre avec une prime */
	/****************************/

   if( G_Prime != RIEN &&
	G_Prime_y > RAQ_Y && G_Prime_y < RAQ_Y+10 &&
	G_Prime_x+TAILLE_X > RaqX && G_Prime_x < RaqX+G_RaqLarg )
   {
    switch( G_Prime )
    {
     case PR_TIR:
			G_Mode = PR_TIR;
			G_Etat = RIEN;
			G_FlagTir = 0;
			break;

     case PR_COLLE:
			G_Mode = PR_COLLE;
			break;

     case PR_LARGE:
			G_Mode = PR_LARGE;
			G_Etat = RIEN;
			break;

     case PR_LENT:	G_Vitesse-=5;
                        if( G_Vitesse < VINIT ) G_Vitesse = VINIT;
			G_Mode = RIEN;
			G_Etat = RIEN;
			break;

     case PR_RAQ:	G_NbRaq++;
			G_Mode = RIEN;
			G_Etat = RIEN;
			break;

     case PR_SORTIE:	G_Score += G_NbBriques;
			G_NbBriques = 0;
			G_Mode = RIEN;
			G_Etat = RIEN;
			break;

     case PR_MULTI:	G_NbBalles = 3;
			G_Mode = PR_MULTI;
			G_Etat = RIEN;
			Balle[1].X = Balle[2].X = Balle[0].X;
			Balle[1].Y = Balle[2].Y = Balle[0].Y;
 			Balle[1].Dy = TabDy[2];
			Balle[1].Dx = TabDx[2]; 
 			Balle[2].Dy = TabDy[4];
			Balle[2].Dx = TabDx[4]; 
			break;
    }

    ChangeScore( G_Score + G_BlocPrime[G_Prime].bonus );
    G_Prime = RIEN;
    redessiner = 1;
   }
 

	/********************/
	/* gestion des tirs */
	/********************/

   for( i = 0 ; i < MAX_TIR ; i++ )
   {
    if( G_Tir[i].etat == UTILISE )
    {
     G_Tir[i].y -= 8;
     if( G_Tir[i].y < BORG_Y ) G_Tir[i].etat = LIBRE;
     else
     {
      bx = (G_Tir[i].x+7-BORG_X)/TAILLE_X;
      by = (G_Tir[i].y-BORG_Y)/TAILLE_Y;

      if( bx >= 0 && bx < MAX_COL_BR && 
	  by >= 0 && by < MAX_LIG_BR &&
          G_NiveauActif[by][2*bx] != ' ' )
      {
       if( G_NiveauActif[by][2*bx] != 'I' )
       {
	if( G_NiveauActif[by][2*bx] == 'G' && G_NiveauActif[by][2*bx+1] != '1' )
	{
	 G_NiveauActif[by][2*bx+1]--;
	}
	else
	{
         G_NbBriques--;
         ChangeScore(G_Score+1);
         EffaceBrique( bx , by );
         G_NiveauActif[by][2*bx] = ' ';	
         redessiner = 1;
	}
       }
       G_Tir[i].etat = LIBRE;
      }

      bx = (G_Tir[i].x+25-BORG_X)/TAILLE_X;

      if( bx >= 0 && bx < MAX_COL_BR && 
          by >= 0 && by < MAX_LIG_BR &&
	  G_NiveauActif[by][2*bx] != ' ' )
      {
       if( G_NiveauActif[by][2*bx] != 'I' )
       {
	if( G_NiveauActif[by][2*bx] == 'G' && G_NiveauActif[by][2*bx+1] != '1' )
	{
	 G_NiveauActif[by][2*bx+1]--;
	}
	else
	{
         G_NbBriques--;
         ChangeScore(G_Score+1);
         EffaceBrique( bx , by );
         G_NiveauActif[by][2*bx] = ' ';
         redessiner = 1;
        }
       }
       G_Tir[i].etat = LIBRE;
      } 
     }
    }
   }

   if( redessiner > 0 )
   {
    GetLocalBackup();

    G_updateXmin=2000;
    G_updateXmax= -1;
    G_updateYmin=2000;
    G_updateYmax= -1;
    redessiner = 0;
   }

   /*********************************************************/
   /* Tous les affichage des objets animes doivent etre ici */
   /*********************************************************/

	/************************/
	/* Affichage des primes */
	/************************/

   if( G_Prime != RIEN )
   {
    G_Prime_y+=2;
    if( G_Prime_y > MAX_Y ) G_Prime = RIEN;
    else putbloc( &G_BlocPrime[G_Prime].forme,G_Prime_x,G_Prime_y );
   }

	/**********************/
	/* Affichage des tirs */
	/**********************/

   for( i = 0 ; i < MAX_TIR ; i++ )
    if( G_Tir[i].etat == UTILISE )
      putbloc( &S_Tir , G_Tir[i].x , G_Tir[i].y );


	/************************/
	/* Affichage des balles */
	/************************/

   if( G_Mode == PR_COLLE && G_Etat == COLLE )
   {
    Balle[0].X = RaqX+G_Angle*G_RaqLarg/6;
    Balle[0].Y = RAQ_Y-5;
   }

   for( i = 0 ; i < G_NbBalles ; i++ )
      putbloc( &S_Balle , (int)Balle[i].X, (int)Balle[i].Y );

        /****************************/ 
	/* Affichage de la raquette */
        /****************************/

   if( G_Mode == PR_TIR && G_RaqLarg == MIN_LARG)
         putbloc( &S_RaqTir , RaqX , RAQ_Y ); 
   else
   { 
    putbloc( &S_Raquette , RaqX , RAQ_Y ); 
    if( G_Mode == PR_LARGE )
    {
     putbloc( &S_RaqLarg , RaqX + G_RaqLarg - MIN_LARG , RAQ_Y );
     if( G_RaqLarg < MAX_LARG ) G_RaqLarg++;
    }
    else if( G_RaqLarg > MIN_LARG )
    {
     putbloc( &S_RaqLarg , RaqX + G_RaqLarg - MIN_LARG , RAQ_Y );
     G_RaqLarg--;
    }
   } 

   if( pause == 1 )
   {
    swap();
    copyscreen();
    afftext(88,100,"PAUSE");     
    swap();
    empty();
    while( getch() != ' ' );
    pause = 0;
   }

   swap();

   PutBackup();

	/********************************************/
	/* On anime les balles, si colle, on attend */
	/********************************************/

   if( G_Mode == PR_COLLE && G_Etat == COLLE )
   {
    if( getmouse() == 1 ) G_Etat = RIEN;
   }
   else
    for( i = 0 ; i < G_Vitesse ; i++)
     for( j = 0 ; j< G_NbBalles ; j++ )
      redessiner += FaireRebond( &Balle[j] , RaqX , &fin );

	/*********************************************/
	/* Si click et Tir, on cherche des munitions */
	/*********************************************/

   if( G_Mode == PR_TIR && mousek & 1 )
   {
    if( G_FlagTir-- == 0 )
    {
     i = MAX_TIR-1;
     while( i >= 0 && G_Tir[i].etat != LIBRE ) i--;
     if( i >= 0 )
     {
      G_Tir[i].x = RaqX;
      G_Tir[i].y = RAQ_Y;
      G_Tir[i].etat = UTILISE;
     }
     G_FlagTir = DELAI_TIR;
    }
    else G_FlagTir = 0;
   }
 
   cpt++;
   if( cpt == 500 )
   {
    G_Vitesse++; 
    cpt = 0;
   }

   if( G_Contact == MAX_CONTACT )  /* Baffe sur la balle si cycle */
   {
    Balle[0].Dx += 0.1;
    Balle[0].Dy += 0.2; 
    G_Contact = 0;
   }
 
  } /* Fin du Tant que fin == 0 et Pas touche et G_NbBriques > 0 */ 

	/***********************/
	/* Annulation des tirs */
	/***********************/
        
   for( i = 0 ; i < MAX_TIR ; i++ )
    G_Tir[i].etat = LIBRE;

  /**************************************************************/
  /* Si l'on sort par KbHit, on cherche la fonction a appliquer */
  /**************************************************************/
 
  if(kbhit() ) 
  {
   switch( getch() )
   {
    case ' ' :                                /* PAUSE */
	       pause = 1;
	       break;

    case 'q' : fin = 2;			      /* QUITTE */
               G_NbRaq = 0;
	       break;

    case 's' : fin = 1;			      /* SUICIDE */
	       G_NbBalles = 0;
	       break;

    default:   empty();
   }
  }

  /**************************************************************/
  /* Si G_NbBriques = 0 alors il faut passer au tableau suivant */
  /**************************************************************/
 
  if( (G_NbBriques == 0) && (fin == 0) )
  {
   swap();
   SetLevel((++G_Round)%MAX_LEVEL); 
   ConstruireLevel(AVEC_DECOUPE);
   G_NbBriques = CompteBriques();
   GetBackup();
   GetLocalBackup();
   G_Prime = RIEN;
   G_NbBalles = 1;
   G_Mode = RIEN;
   G_Etat = RIEN;
   G_RaqLarg = MIN_LARG;
 
   if( (RaqX = ChoixPosition()) == 0) G_NbRaq = 0;
   else
   {
    G_Vitesse = VINIT;
    Balle[0].Dy = DYINIT;
    Balle[0].Dx = DXINIT; 
    Balle[0].X = (float)(RaqX+G_RaqLarg/2);
    Balle[0].Y = (float)(RAQ_Y-5);
   }
   Vide();
  }  

  /*****************************************************************/
  /* Si fin = 1 && qu'il reste des raquettes, replacer la raquette */
  /*****************************************************************/

  if( fin == 1 && G_NbRaq > 0 )
  {
    /* On determine quelle est la balle fautive &
       on la retire de l'ensemble des balles */

   for( i = 0 ; i < G_NbBalles ; i++ )
   {
    if( Balle[i].X <= 5. )
    {
     G_NbBalles--;
     for( j = i ; j< G_NbBalles ; j++ )
     {
      Balle[j].X = Balle[j+1].X;
      Balle[j].Y = Balle[j+1].Y;
      Balle[j].Dx = Balle[j+1].Dx;
      Balle[j].Dy = Balle[j+1].Dy;
     }
    }
   }

   /* Si nb balles = 1, & qu'on vient d'en perdre un
      on a de nouveau le droit de recevoir des primes */

   if( G_NbBalles == 1 ) G_Mode = RIEN;

   if( G_NbBalles == 0 && --G_NbRaq > 0)
   {
    G_RaqLarg = MIN_LARG;
    G_Prime = RIEN;
    G_NbBalles = 1;
    G_Mode = RIEN;
    G_Etat = RIEN;
    ConstruireLevel(SANS_DECOUPE);
    GetBackup();
    GetLocalBackup();

    RaqX = ChoixPosition();
    if( RaqX == 0 ) G_NbRaq = 0;
    else
    {
     Balle[0].Dy = DYINIT;
     Balle[0].Dx = DXINIT;
     Balle[0].X = (float)(RaqX+G_RaqLarg/2);
     Balle[0].Y = (float)(RAQ_Y-5);
     G_Vitesse-=5;
     if( G_Vitesse < VINIT ) G_Vitesse = VINIT;
    }
    Vide();
   }
  } /* fin du Si il faut replacer la raquette */

 } /* Fin du Tant que NbRaq > 0 */
 GameOver();
 if( fin != 2 )  NouveauPodium();
}

/**************************************************************************/
int FaireRebond( Balle *balle, int RaqX , int *fin )
{
 int dis,i,bx,by,redessiner = 0;

 if( balle->X == 0. ) return( 0 );

 balle->X += balle->Dx;
 balle->Y += balle->Dy;

 if( balle->X >= MaxX && balle->Dx > 0 ||
     balle->X <= MinX && balle->Dx < 0 )
 {
  balle->Dx = -balle->Dx;
  balle->X += balle->Dx;
 }

 if( balle->Y <= MinY )
 {
  balle->Dy = -balle->Dy;
  balle->Y += balle->Dy;
 }  

 /*************************/
 /* Detection des briques */
 /*************************/

 /********************************************************************/
 /* 1) determiner quelle brique est sur la trajectoire  selon l'axe X*/
 /********************************************************************/

 if( balle->Dx > 0 ) bx = ((int)(balle->X-(float)BORG_X))/TAILLE_X;  
 else                bx = ((int)(balle->X-L_BALLE-(float)BORG_X))/TAILLE_X;
 by = ((int)(balle->Y-H_BALLE/2.-(float)BORG_Y))/TAILLE_Y;

 if( by < MAX_LIG_BR && G_NiveauActif[by][2*bx] != ' ' )
 {
  if(( G_NiveauActif[by][2*bx] == 'G' && 
       G_NiveauActif[by][2*bx+1] != '1' ) || G_NiveauActif[by][2*bx] == 'I' )
  {
   G_NiveauActif[by][2*bx+1]--;
   balle->Dx = -balle->Dx;
   G_Contact++;			/* On compte les rebonds sur briques */
   dbox( BORG_X+bx*TAILLE_X,BORG_Y+by*TAILLE_Y , TAILLE_X,TAILLE_Y , BLANC );
  }
  else
  { 
   if( G_Mode != PR_MULTI && G_Prime == RIEN 
	&& G_NiveauActif[by][2*bx] != 'G' )
   {
    TrouvePrime();
    G_Prime_x = BORG_X + bx * TAILLE_X;
    G_Prime_y = BORG_Y + by * TAILLE_Y;
   }
   G_NiveauActif[by][2*bx] = ' ';
   G_NbBriques--;
   ChangeScore(G_Score+1);
   EffaceBrique( bx , by );
   balle->Dx = -balle->Dx;
   redessiner = 1;
   G_Contact = 0;
  }
 }

 /*******************************/
 /* 2) meme chose selon l'axe Y */
 /*******************************/

 if( balle->Dy > 0 ) by = ((int)(balle->Y-(float)BORG_Y))/TAILLE_Y;
 else                by = ((int)(balle->Y-H_BALLE-(float)BORG_Y))/TAILLE_Y;
 bx = ((int)(balle->X-L_BALLE/2-(float)BORG_X))/TAILLE_X;

 if( by < MAX_LIG_BR && G_NiveauActif[by][2*bx] != ' ' )
 {
  if(( G_NiveauActif[by][2*bx] == 'G' && 
       G_NiveauActif[by][2*bx+1] != '1' ) || G_NiveauActif[by][2*bx] == 'I' )
  {
   G_NiveauActif[by][2*bx+1]--;
   balle->Dy = -balle->Dy;
   G_Contact++;			/* On compte les rebonds sur briques */
   dbox( BORG_X+bx*TAILLE_X,BORG_Y+by*TAILLE_Y , TAILLE_X,TAILLE_Y , BLANC );
  }
  else
  {
   if( G_Mode != PR_MULTI && G_Prime == RIEN 
	&& G_NiveauActif[by][2*bx] != 'G' )
   {
    TrouvePrime();
    G_Prime_x = BORG_X + bx * TAILLE_X;
    G_Prime_y = BORG_Y + by * TAILLE_Y;
   }
   G_NiveauActif[by][2*bx] = ' ';
   G_NbBriques--;
   ChangeScore(G_Score+1);
   EffaceBrique( bx , by);
   balle->Dy = -balle->Dy;
   redessiner = 1;
   G_Contact = 0;
  }
 }

 /**************************************/
 /* Detection des rebonds sur les murs */
 /**************************************/

 if( balle->Y >= BAS_ECRAN )
 {
  balle->X = balle->Y = 0.;
  *fin = 1;
 } 
 
 /*****************************************/
 /* Detection des rebonds sur la raquette */
 /*****************************************/

 if( (balle->Y >= MaxY) && (balle->Y <= MaxY+3. ) &&
     (balle->X+L_BALLE > (float)RaqX) && 
     (balle->X < (float)(RaqX+G_RaqLarg) ) )
 {
  dis = balle->X-(float)RaqX;
  if( dis < 0 ) dis = 0;

  for( i = 0 ; i < 5 ; i++ )
   if( dis <= i * G_RaqLarg/6 ) break;

  G_Angle = i;
  balle->Dx = TabDx[G_Angle];
  balle->Dy = TabDy[G_Angle];

  balle->X += balle->Dx;
  balle->Y += balle->Dy;

  if( G_Mode == PR_COLLE )
  {
   G_Etat = COLLE;
   empty();
  }

  G_Contact = 0;
 } 

 return(redessiner);
}

/**************************************************************************/
void InitPrimes( void )
{
 int i=0; 
 
 G_BlocPrime[i].bonus = 1; G_BlocPrime[i].proba = 7; G_BlocPrime[i++].texte = "lent";
 G_BlocPrime[i].bonus = 2; G_BlocPrime[i].proba = 13; G_BlocPrime[i++].texte = "large";
 G_BlocPrime[i].bonus = 3; G_BlocPrime[i].proba = 18; G_BlocPrime[i++].texte = "colle";
 G_BlocPrime[i].bonus = 4; G_BlocPrime[i].proba = 22; G_BlocPrime[i++].texte = "multi";
 G_BlocPrime[i].bonus = 5; G_BlocPrime[i].proba = 28; G_BlocPrime[i++].texte = "tir";
 G_BlocPrime[i].bonus = 7; G_BlocPrime[i].proba = 30; G_BlocPrime[i++].texte = "raquette";
 G_BlocPrime[i].bonus = 10; G_BlocPrime[i].proba = 31; G_BlocPrime[i++].texte = "sortie";

}

/**************************************************************************/
void TrouvePrime( void )
{
 int nb,i;

 nb = randval(29*3);

 G_Prime = RIEN;
 for( i = 0 ; i < MAX_PRIME ; i++ ) 
 {
  if( nb < G_BlocPrime[i].proba ) 
  {
   G_Prime = i;
   break;
  }
 }
}

/**************************************************************************/
void Vide( void )
{
 int i;

 for( i = 0 ; i < MAX_TIR ; i++ ) G_Tir[i].etat = LIBRE;
}

/**************************************************************************/
int CompteBriques( void )
{
 int x,y,nb = 0;

 for( y = 0 ; y < MAX_LIG_BR ; y++ )
  for( x = 0 ; x < MAX_COL_BR ; x++ )
   if( G_NiveauActif[y][2*x] != 'I' && G_NiveauActif[y][2*x] != ' ' ) nb++;

 return( nb );
}

/***************************************************************************
** Positionne la raquette avant le depart de la balle, renvois sa position**
** revois 0 si l'utilisateur annule la partie (touche 'Q')                **
***************************************************************************/
int ChoixPosition( void )
{
 int RaqX;
 char lev[10];
 int x;
 char r=0;

 sprintf( lev , "ROUND %d", G_Round+1 );
 x = 4+((int)MAX_X-(int)strlen(lev)*8)/2;
 setcolor(JAUNE);
 empty();

 while(!buthit() && r != 'q' )
 {
  if(kbhit()) r=getch();
  
  RaqX = mousex-16;
  if( RaqX < ORG_X )          RaqX = ORG_X;
  else if( RaqX+G_RaqLarg >= MAX_X ) RaqX = MAX_X-G_RaqLarg;

  PutBackup();
  putbloc( &S_Raquette , RaqX , RAQ_Y ); 
  putbloc( &S_Balle , RaqX+G_RaqLarg/2 , RAQ_Y - 5 );
  afftext( x , 120 , lev ); 
  swap();
 }

 if( r == 'q' ) return(0);
 return( RaqX );
}

/**************************************************************************/
int ChoixLevel ( void )
{
 char r = 0;
 int  im,x,y,lx,ly,al,l;
 const int MINI_LX = MAX_COL_BR*4+20;
 const int MINI_LY = MAX_LIG_BR*2+4;
 const int MINI_X  = 12;
 const int MINI_Y  = 8;

 cls();
 DessineFond();
 DessineDecor();

 im = 0;
 for( y = 0 ; y < 5 ; y++ )
  for( x = 0 ; x < 3 ; x++ )
  {
   DessineMiniLevel( MINI_X+MINI_LX*x,MINI_Y+MINI_LY*y,im++);
   if( im >= MAX_LEVEL ) { x= 10; y = 10; }
  }

 swap();

 empty();
 x = mousex;
 y = mousey;
 al = 0;

 do
 {
  lx = ( mousex - MINI_X ) / MINI_LX;
  ly = ( mousey - MINI_Y ) / MINI_LY;

  if( lx > 2 || ly > 4 || ly*3+lx >= MAX_LEVEL ) l = al;
  else l = ly*3+lx;


  if( kbhit() ) r = getch();
  if( l != al )
  {
   copyscreen();
   x = (al % 3)*MINI_LX+MINI_X;
   y = (al / 3)*MINI_LY+MINI_Y;
   dbox(x,y,MAX_COL_BR*4+4,MAX_LIG_BR*2+4,GRIS);

   x = (l % 3)*MINI_LX+MINI_X;
   y = (l / 3)*MINI_LY+MINI_Y;
   dbox(x,y,MAX_COL_BR*4+4,MAX_LIG_BR*2+4,JAUNE);

   swap();
   al = l;
  }
 } while( (getmouse() != 5) && (r == 0) );

 if( r == 'q' ) return( -1 );

 SetLevel( l );
 
 return(l);
}

/**************************************************************************/
void SetLevel( int level )
{
 int x,y;

 G_Niveau = &Levels[level];

 for( y = 0 ; y < MAX_LIG_BR ; y ++ )
  for( x = 0 ; x < MAX_COL_BR*2 ; x++ )
    G_NiveauActif[y][x] = (*G_Niveau)[y][x];

 G_Niveau = &G_NiveauActif;
}

/**************************************************************************/
void DecoupeFond(void)
{
 bloc tmp;
 int x,y;

 initbloc(&tmp);
 getbloc(&tmp,288,0,32,4);

 for( y = 0 ; y <= MAX_LIG_BR*2 ; y++ )
  for( x = 0 ; x < MAX_COL_BR*2 ; x++ )
  {
   getbloc( &G_BlocFond[y][x] , 
            (BORG_X + x * (TAILLE_X/2))&0xfff0 ,
            BORG_Y + y * (TAILLE_Y/2) , 
            16, TAILLE_Y/2 );
   pbox(304,0,16,4,MASK);
   getmask( &G_BlocFond[y][x] , 304,0);

   if (x&1)
	    putbloc( &G_BlocFond[y][x] , 304,0);
   else
	    putbloc( &G_BlocFond[y][x] , 296,0);
   
  	pbox(312,0,8,4,FOND);
	getbloc( &G_BlocFond[y][x] , 304,0,16,4);
   	pbox(304,0,8,4,MASK);
	getmask( &G_BlocFond[y][x] , 304,0);
  }
  
  putbloc(&tmp,288,0);
  freebloc(&tmp);
}

/**************************************************************************/
void DessineMiniLevel( int xp,int yp,int level )
{
 int x,y;
 char type;
 int coul;

 pbox(xp,yp,MAX_COL_BR*4+4,MAX_LIG_BR*2+4,NOIR);
 dbox(xp,yp,MAX_COL_BR*4+4,MAX_LIG_BR*2+4,GRIS);

 for( y = 0 ; y < MAX_LIG_BR ; y++ )
 {
  for( x = 0 ; x < MAX_COL_BR ; x++ )
  {
   type = Levels[level][y][2*x];
   coul = -1;
   if( type != ' ' )
   {
    if( type != 'G' && type != 'I' )
    {
     coul = (int)(type<='9'?(type-'0'):(type-'A'+10));
    }
    else
    {
     if( type == 'G' ) coul = GRIS_CLAIR;
     else	       coul = JAUNE;
    }
   }
   if( coul != -1 ) 
    pbox( 2+xp + x * 4 , 2+yp + y*2 , 3, 1 , coul);
  }
 }
}

/**************************************************************************/
void ConstruireLevel( int dec )
{
 int x,y;

 cls();
 DessineFond();
 
 
 if( dec == AVEC_DECOUPE )
 {
  DessineDecor();
  DecoupeFond();
 }

 for( y = 0 ; y < MAX_LIG_BR ; y++ )
  for( x = 0 ; x < MAX_COL_BR ; x++ )
   DessineBrique(x,y,(*G_Niveau)[y][x*2]);


 DessineDecor();
 PutScore();
}

/**************************************************************************/
void GameOver(void)
{
 copyscreen();
 setcolor(BLANC); 
 afftext(68 , 100 , "GAME OVER" );
 swap();
}

/**************************************************************************/
void CreatePodium(void)
{
 int i,j;

 for(i=0;i<MAX_PODIUM;i++)
 {
  for(j=0;j<8;j++) G_Podium[i].nom[j] = '-';
  G_Podium[i].nom[j] = '\0';
  G_Podium[i].score[0]= 0;
  G_Podium[i].score[1]= 0;
  G_Podium[i].score[2]= 0;
  G_Podium[i].level   = 0;
 }

 bmake(HALLNAME,G_Podium,(long)sizeof(G_Podium));
}

/**************************************************************************/
void EffaceBrique(int x, int y )
{
 /*
   une brique est composee de :  abcd : quatre quart + 123 3 quart d'ombre 

                  aabb
                  ccdd11
                    2233
 */

 int Xmin,Ymin,Xmax,Ymax;

 Xmin=BORG_X+x*TAILLE_X;
 Ymin=BORG_Y+y*TAILLE_Y;
 Xmax=Xmin+(3*TAILLE_X)/2;
 Ymax=Ymin+(3*TAILLE_Y)/2;

 if (Xmin<G_updateXmin) G_updateXmin=Xmin;
 if (Ymin<G_updateYmin) G_updateYmin=Ymin;
 if (Xmax>G_updateXmax) G_updateXmax=Xmax;
 if (Ymax>G_updateYmax) G_updateYmax=Ymax;

 /* Dans tous les cas on efface d */

 putbloc( &G_BlocFond[y*2+1][x*2+1],
	  BORG_X + x * TAILLE_X + TAILLE_X/2, BORG_Y + y * TAILLE_Y + TAILLE_Y/2);


 /* Si pas de brique dessous oter l'ombre en 2 */ 

 if( y == (MAX_LIG_BR-1) || (G_NiveauActif[y+1][2*x] == ' '))
   putbloc( &G_BlocFond[y*2+2][x*2+1],
            BORG_X + x * TAILLE_X +TAILLE_X/2, BORG_Y + y * TAILLE_Y + TAILLE_Y); 

 /* Si pas de brique a droite oter l'ombre en 1 */ 

 if( x == 12 || G_NiveauActif[y][2*x+2] == ' ' )
   putbloc( &G_BlocFond[2*y+1][2*x+2],
            BORG_X + x * TAILLE_X+TAILLE_X , BORG_Y + y * TAILLE_Y + TAILLE_Y/2); 

 /* Si pas de brique dessous a droite oter l'ombre en 3 */ 

 if( x == 12 || ( y == (MAX_LIG_BR-1) || G_NiveauActif[y+1][2*x+2] == ' ' ))
   putbloc( &G_BlocFond[2*y+2][2*x+2],
            BORG_X + x * TAILLE_X+TAILLE_X , BORG_Y + y * TAILLE_Y + TAILLE_Y ); 

 /* Si une brique a gauche, mettre ombre en c sinon effacer briquette c*/

 if( x > 0 &&  G_NiveauActif[y][2*x-2] != ' ' )
   pbox( BORG_X + x * TAILLE_X , BORG_Y + y * TAILLE_Y + TAILLE_Y/2 ,
	 TAILLE_X/2,TAILLE_Y/2 , NOIR);
 else putbloc( &G_BlocFond[y*2+1][x*2],
         BORG_X + x * TAILLE_X , BORG_Y + y * TAILLE_Y + TAILLE_Y/2);

 /* Si une brique au dessus, mettre une ombre en b */

 if( y > 0 &&  G_NiveauActif[y-1][2*x] != ' ' )
   pbox( BORG_X + x * TAILLE_X + TAILLE_X/2, BORG_Y + y * TAILLE_Y ,
	 TAILLE_X/2,TAILLE_Y/2 , NOIR);
 else putbloc( &G_BlocFond[y*2][x*2+1],
         BORG_X + x * TAILLE_X + TAILLE_X/2, BORG_Y + y * TAILLE_Y );

 /* Si une brique au dessus a gauche, mettre une ombre en a */

 if( y > 0 && x > 0 &&  G_NiveauActif[y-1][2*x-2] != ' ' )
   pbox( BORG_X + x * TAILLE_X , BORG_Y + y * TAILLE_Y ,
	 TAILLE_X/2,TAILLE_Y/2 , NOIR);
 else putbloc( &G_BlocFond[y*2][x*2],
         BORG_X + x * TAILLE_X , BORG_Y + y * TAILLE_Y );
}

/**************************************************************************/
void DessineBrique(int x, int y, char type )
{
 int c,ch;

 if( type != ' ' )
 {
  if( type != 'G' && type != 'I' )
  {
   pbox( BORG_X + x * TAILLE_X +TAILLE_X/2, BORG_Y + y * TAILLE_Y +TAILLE_Y/2 ,
	   TAILLE_X, TAILLE_Y,NOIR);
   pbox( BORG_X + x * TAILLE_X , BORG_Y + y * TAILLE_Y , 
           TAILLE_X - 1, TAILLE_Y -1,
           (int)(type<='9'?(type-'0'):(type-'A'+10)));
  }
  else
  {
   switch( type )
   {
    case 'G' : c = GRIS_CLAIR; ch = BLANC; break;
    case 'I' : c = JAUNE; ch = BLANC; break;
   }
   pbox( BORG_X + x * TAILLE_X +TAILLE_X/2, BORG_Y + y * TAILLE_Y +TAILLE_Y/2 ,
	   TAILLE_X , TAILLE_Y ,NOIR);

   pbox( BORG_X + x * TAILLE_X , BORG_Y + y * TAILLE_Y , 
           TAILLE_X - 1, TAILLE_Y -1, c );

   dline(BORG_X + x * TAILLE_X, BORG_Y + y * TAILLE_Y+TAILLE_Y -2,
	 BORG_X + x * TAILLE_X, BORG_Y + y * TAILLE_Y, ch );
   dline(BORG_X + x * TAILLE_X, BORG_Y + y * TAILLE_Y,
	 BORG_X + x * TAILLE_X+TAILLE_X - 2,BORG_Y + y * TAILLE_Y,-1 );
  }

  dline(1+BORG_X + x * TAILLE_X, BORG_Y + y * TAILLE_Y+TAILLE_Y -1,
         BORG_X + x * TAILLE_X+TAILLE_X - 1,
	 BORG_Y + y * TAILLE_Y+TAILLE_Y -1,NOIR );

  dline( BORG_X + x * TAILLE_X+TAILLE_X - 1,
	  BORG_Y + y * TAILLE_Y+TAILLE_Y -1,
          BORG_X + x * TAILLE_X+TAILLE_X - 1,BORG_Y + y * TAILLE_Y+1,-1 );

 }
}


/**************************************************************************/
void Podium(void)
{
 int i;
 int x,y;
 char s[80];
 const debut = 7,fin= 310-6;

 copyscreen();
 GetBackup();
 setcolor(JAUNE);
 afftext( BORG_X+((int)MAX_X-120)/2 , 140 , "ATTENDEZ S.V.P." );
 swap();
 cls();

 if( sdepth != 1 )
 {
  y = 0;
  while( y < 200 )
  {
   x = debut+1;
   while( x < 320 )
   {
    putbloc( &S_Fond , x , y );
    x+= 20;
   }
   y+= 16;
  }
 }

 vline(debut+1,1,199,BLANC);
 vline(debut+2,2,199,BLANC);
 vline(debut+3,3,199,GRIS_CLAIR);
 vline(debut+4,4,199,GRIS);
 vline(debut+5,5,199,GRIS);
 vline(debut+6,6,199,GRIS_CLAIR);

 vline(fin+1,6,199,BLANC);
 vline(fin+2,5,199,BLANC);
 vline(fin+3,4,199,GRIS_CLAIR);
 vline(fin+4,3,199,GRIS);
 vline(fin+5,2,199,GRIS);
 vline(fin+6,1,199,GRIS_CLAIR);

 hline(debut+1,1,fin+6,BLANC);
 hline(debut+2,2,fin+5,BLANC);
 hline(debut+3,3,fin+4,GRIS_CLAIR);
 hline(debut+4,4,fin+3,GRIS);
 hline(debut+5,5,fin+2,GRIS);
 hline(debut+6,6,fin+1,GRIS_CLAIR);

 hline(0,0,319,NOIR);
		   
 for(i=0;i<5;i++)
 {
  putbloc( &S_Bidule , debut,20+35*i );
  putbloc( &S_Bidule , fin ,20+35*i );
 }

 setcolor(BLANC);

 afftext(160-3*8,8, " podium");

 putbloc(&S_Logo,160-5*8,16);

 setcolor( JAUNE );
 afftext(72,190,"APPUYER SUR UNE TOUCHE");

 if (!bexist(HALLNAME)) CreatePodium();

 bload(HALLNAME,G_Podium,0L,(long)sizeof(G_Podium));

 setcolor(JAUNE);
 afftext(74,55,"Joueur           Round");
 afftext(74+10*8+4,55,"Score");
 setcolor(BLANC);
 for(i=0;i<MAX_PODIUM;i++)
 {
  if( SCORE(i) == G_Score ) setcolor( ROUGE );
  sprintf(s," %9s  %07ld0  %d",G_Podium[i].nom,SCORE(i),G_Podium[i].level);
  afftext(50,70+i*10,s);
  if( SCORE(i) == G_Score ) setcolor( BLANC );
 }

 swap();

 empty();
 while(!keyhit()) waitdelay(500);
 PutBackup();
 swap();
 empty();
}

/**************************************************************************/
void NouveauPodium( void )
{
 int i,t;
 int perhaps=1;

 if (!bexist(HALLNAME)) CreatePodium();
 bload(HALLNAME,G_Podium,0L,(long)sizeof(G_Podium));

 if (!G_NomValide) GetUsername();
 G_NomValide=1;

 for( t = 0 ; t < MAX_PODIUM ; t++ )
  if( !strcmp(G_Podium[t].nom,G_Nom))
  {
  	if( SCORE(t) < G_Score )
	{
	   for( i = t ; i < MAX_PODIUM-1 ; i++ )
	   {
	    strcpy( G_Podium[i].nom , G_Podium[i+1].nom );
	    G_Podium[i].score[0] = G_Podium[i+1].score[0];
	    G_Podium[i].score[1] = G_Podium[i+1].score[1];
	    G_Podium[i].score[2] = G_Podium[i+1].score[2];
	    G_Podium[i].level = G_Podium[i+1].level;
	   }
	}
	else
 	 	perhaps=0;
  }

 if (perhaps)
 for( t = 0 ; t < MAX_PODIUM ; t++ )
  if( SCORE(t) < G_Score )
  {
   for( i = MAX_PODIUM-1 ; i > t ; i-- )
   {
    strcpy( G_Podium[i].nom , G_Podium[i-1].nom );
    G_Podium[i].score[0] = G_Podium[i-1].score[0];
    G_Podium[i].score[1] = G_Podium[i-1].score[1];
    G_Podium[i].score[2] = G_Podium[i-1].score[2];
    G_Podium[i].level = G_Podium[i-1].level;
   }

   strcpy( G_Podium[t].nom , G_Nom );
   G_Podium[t].score[0]=(unsigned char)(G_Score/65536L);
   G_Podium[t].score[1]=(unsigned char)((G_Score%65536L)/256L);
   G_Podium[t].score[2]=(unsigned char)(G_Score%256L);
   G_Podium[t].level = G_Round+1;
   break;
  }

 bsave(HALLNAME,G_Podium,0L,(long)sizeof(G_Podium));
 waitdelay(2000);
 empty();
 Podium();
}

/**************************************************************************/
void GetUsername( void )
{
 int i;
 char r;
 char s[80];

 GetBackup();

 sprintf(G_Nom,"        ");
 sprintf(s,cuserid(0));

 if (s[0])	
 {
	waitdelay(1000);

	i=0;
	while((s[i])&&(i<8))
	{
		if (s[i]=='_') s[i]=' ';
		G_Nom[i]=s[i];
		i++;
	}
 }
 else
 {
  i=0;
  r=0;
  while(r!=13)
  {
   cls();
   PutBackup();
   pbox(96,100-12,128,24,NOIR);
   dbox(96,100-12,128,24,BLANC);
   setcolor(BLANC);
   afftext(160-6*8,100-4,"nom:");
   afftext(160-2*8,100-4,G_Nom);
   affchar(160-2*8+8*i,100-4,'_');
   swap();
		
   while(!kbhit()) waitdelay(100);
   r=getch();

   if ((r==8)&&(i))          G_Nom[--i]=' ';
   else
   {
    if ((r>=' ')&&(i<8))     G_Nom[i++]=r;
   }			
  }
 }

 PutBackup();
 swap();
}


/**************************************************************************/
void GetBackup( void )
{
 getbloc(&G_Backup,0,0,320,200);
}

/**************************************************************************/
void GetLocalBackup( void )
{
 int x,y,lx,ly;
 char s[10];

 if (G_updateXmin<G_updateXmax && G_updateYmin<G_updateYmax)
 {
  if (G_updateXmin<0) G_updateXmin=0;
  if (G_updateYmin<0) G_updateYmin=0;
  if (G_updateXmax>320) G_updateXmax=320;
  if (G_updateYmax>200) G_updateYmax=200;
  G_updateXmin&=0xfff0;
  G_updateXmax=(G_updateXmax+15)&0xfff0;

  x=G_updateXmin;
  y=G_updateYmin;
  lx=G_updateXmax-G_updateXmin;
  ly=G_updateYmax-G_updateYmin;

  getbloc(&tempobloc,x,y,lx,ly);
  copybloc(&tempobloc,0,0,lx,ly,&G_Backup,x,y);
 }

 if( G_OldScore != G_Score )
 {
  lx=8*8;
  ly=8;

  pbox(SCORE_X,SCORE_Y+8,lx,ly,NOIR);
  setcolor(BLANC);
  sprintf(s,"%07ld0", G_Score);
  afftext(SCORE_X,SCORE_Y+8,s);

  getbloc(&tempobloc2,SCORE_X,SCORE_Y+8,lx,ly);
  copybloc(&tempobloc2,0,0,lx,ly,&G_Backup,SCORE_X,SCORE_Y+8);
  if( G_Score == G_HighScore )
   copybloc(&tempobloc2,0,0,lx,ly,&G_Backup,SCORE_X,SCORE_Y+4*8);
  G_OldScore = G_Score;
 }


 if( G_OldNbRaq != G_NbRaq )
 {    
  for( x = 0 ; x < G_NbRaq-1 ; x++ )
            putbloc(  &S_MiniRaq, BORG_X + 4 + x * 18 , MINIRAQ_Y );

  x=0;
  y=190;
  lx=192+16;
  ly=8;
  getbloc(&tempobloc3,x,y,lx,ly);
  copybloc(&tempobloc3,0,0,lx,ly,&G_Backup,x,y);
  G_OldNbRaq = G_NbRaq;
 }
 
}

/**************************************************************************/
void PutBackup( void )
{
 putbloc(&G_Backup,0,0);
}


/**************************************************************************/
void ChangeScore( unsigned long nsc )
{
 G_Score = nsc;
 if( G_Score > G_HighScore ) G_HighScore = G_Score;
}

/**************************************************************************/
void PutScore( void )
{
 int  x;
 char s[10];

 pbox(SCORE_X,SCORE_Y+8,8*8,8,NOIR);
 setcolor(BLANC);
 sprintf(s,"%07ld0", G_Score);
 afftext(SCORE_X,SCORE_Y+8,s);

 pbox( SCORE_X,SCORE_Y+4*8,8*8,8,NOIR);
 setcolor(BLANC);
 if( G_HighScore >= G_Score )
   sprintf(s,"%07ld0", G_HighScore);
 else
   sprintf(s,"%07ld0", G_Score);
 afftext(SCORE_X,SCORE_Y+4*8,s);

 for( x = 0 ; x < G_NbRaq-1 ; x++ )
               putbloc(  &S_MiniRaq, BORG_X + 4 + x * 18 , MINIRAQ_Y );

}

void TrouveHighScore()
{
 if (bexist(HALLNAME))
 {
  bload(HALLNAME,G_Podium,0L,(long)sizeof(G_Podium));
  G_HighScore = SCORE(0); 
 }
 else G_HighScore = 0;
}

/**************************************************************************/
void DessineFond( void )
{
 int x,y;
 bloc *motif;

 if( sdepth == 1 ) return;

 if( G_Round % 2 == 0 )motif = &S_Fond;
 else		       motif = &S_Fond2;

 y = 0;
 while( y < 200 )
 {
  x = 1;
  while( x < MAX_COL_BR*TAILLE_X )
  {
   putbloc( motif , x , y );
   x+= 20;
  }
  y+= 16;
 }

 hline( 0,0,319,NOIR );
}

/**************************************************************************/
void DessineDecor( void )
{
 int t;
 const base = 216;
 
 vline(1,1,199,BLANC);
 vline(2,2,199,BLANC);
 vline(3,3,199,GRIS_CLAIR);
 vline(4,4,199,GRIS);
 vline(5,5,199,GRIS);
 vline(6,6,199,GRIS_CLAIR);

 vline(base+1,6,199,BLANC);
 vline(base+2,5,199,BLANC);
 vline(base+3,4,199,GRIS_CLAIR);
 vline(base+4,3,199,GRIS);
 vline(base+5,2,199,GRIS);
 vline(base+6,1,199,GRIS_CLAIR);

 hline(1,1,base+6,BLANC);
 hline(2,2,base+5,BLANC);
 hline(3,3,base+4,GRIS_CLAIR);
 hline(4,4,base+3,GRIS);
 hline(5,5,base+2,GRIS);
 hline(6,6,base+1,GRIS_CLAIR);

 hline(0,0,14*16,0);

 setcolor(BLANC);
		
 putbloc( &S_Logo,224,4 );
 
 for(t=0;t<5;t++)
 {
  putbloc( &S_Bidule , 0,20+35*t );
  putbloc( &S_Bidule , base ,20+35*t );
 }

 afftext( SCORE_X+5,20,"G.ROY(93)" );
 afftext( SCORE_X,SCORE_Y,"score");
 afftext( SCORE_X,SCORE_Y+3*8,"hiscore");
 PutScore();

 for( t = 0 ; t < MAX_PRIME ; t++ )
 {
  putbloc( &G_BlocPrime[t].forme , PRIME_X , PRIME_Y+t*10 );
  afftext( PRIME_X+20 , PRIME_Y+t*10 , G_BlocPrime[t].texte );
 }

 afftext(224+4,200-32,"j:Jeu");
 afftext(224+4,200-24,"p:Podium");
 afftext(224+4,200-16,"s:Suicide");
 afftext(224+4,200-8, "q:Quitter");
}


