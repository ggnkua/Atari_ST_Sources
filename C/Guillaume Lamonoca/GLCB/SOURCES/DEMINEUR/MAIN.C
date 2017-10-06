/* main.c */

#include "header.h"
#include "demineur.h"

typedef void *bloc;

extern struct jeu      **tableau ;
extern int             nb_lig , nb_col , nb_mines ;
extern unsigned long   temps ;
extern int             perdu , gagne , jeu , ouvre ;

int RATIO=1;

#ifndef VMS
#ifndef unix
#define cuserid(x) ""
#endif
#endif

extern int score;
int tri[60];

#define HALLNAME "demineur.hll"

char username[9];

typedef struct
		{
			char username[9];
			unsigned char chrono[3];
		}
		player;

player hall[2][60];

#define HALL(a,b) hall[RATIO-1][a].chrono[b]
#define CHRONO(i) HALL(i,0)*100+HALL(i,1)*10+HALL(i,2)



void create_podium()
{
	int i;

	for(i=0;i<60;i++)
	{
		hall[0][i].username[0]=hall[1][i].username[0]=0;
		hall[0][i].chrono[0]=hall[1][i].chrono[0]=9;
		hall[0][i].chrono[1]=hall[1][i].chrono[1]=9;
		hall[0][i].chrono[2]=hall[1][i].chrono[2]=9;
	}

	bmake(HALLNAME,hall,(long)sizeof(hall));
}



void podium()
{
	int i,j,n,ok,t,k;
	char s[40];

	cls();

	setcolor(15);
	afftext(160-3*8,8,"podium");

	if (RATIO==2)
		afftext(160-8*8,16,"demineur normal!");
	else
		afftext(160-8*8,16,"demineur rapide!");

	if (!bexist(HALLNAME)) create_podium();

	while(bload(HALLNAME,hall,0L,(long)sizeof(hall))) waitdelay(1000);

	for(i=0;i<60;i++)
		tri[i]=i;
		
	ok=0;
	while(!ok)
	{
		ok=1;
		for(i=0;i<59;i++)
		if (CHRONO(tri[i])>CHRONO(tri[i+1]))
		{
			ok=0;
			t=tri[i];
			tri[i]=tri[i+1];
			tri[i+1]=t;
		}
	}


	for(j=0;j<3;j++)
		for(i=0;i<20;i++)
		{
			n=tri[i+j*20];
			if (hall[RATIO-1][n].username[0])
			{
				sprintf(s," %s %03d",hall[RATIO-1][n].username,CHRONO(n));
				for(k=0;s[k];k++) if (s[k]=='_') s[k]=' ';
				afftext(j*8*13,(4+i)*8,s);
			}
		}

	swap();

	while(!keyhit()) waitdelay(500);
	empty();
}



void save_hall()
{
	int numero,max,i;

	if (!bexist(HALLNAME)) create_podium();

	while(bload(HALLNAME,hall,0L,(long)sizeof(hall))) waitdelay(1000);

	numero= -1;
	for(i=0;i<60;i++)
		if (!strcmp(hall[RATIO-1][i].username,username)) numero=i;

	if (numero!= -1)
	{
		if (score>=CHRONO(numero)) numero= -1;
	}
	else
	{
		max=score;
		for(i=0;i<60;i++)
			if (CHRONO(i)>max)
			{
				max=CHRONO(i);
				numero=i;
			}
	}

	if (numero!= -1)
	{
		sprintf(hall[RATIO-1][numero].username,username);
		hall[RATIO-1][numero].chrono[0]=score/100;
		hall[RATIO-1][numero].chrono[1]=(score%100)/10;
		hall[RATIO-1][numero].chrono[2]=score%10;
		while(bsave(HALLNAME,&hall[RATIO-1][numero],
			(60*(RATIO-1)+numero)*(long)sizeof(player),
			(long)sizeof(player))) waitdelay(1000);
	}


}



void get_username()
{
	int i;
	char r;
	char s[80];

	sprintf(username,"        ");
	sprintf(s,cuserid(0));

	if (s[0])	
	{
		i=0;
		while((s[i])&&(i<8))
		{
			username[i]=s[i];
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
			setcolor(15);
			afftext(160-6*8,100-4,"nom:");
			afftext(160-2*8,100-4,username);
			affchar(160-2*8+8*i,100-4,'_');
			swap();
			
			while(!kbhit()) waitdelay(100);
			r=getch();
			if ((r==8)&&(i))
				username[--i]=' ';
			else
				if ((r>=' ')&&(i<8))
					username[i++]=r;			
		}
	
	}

}




/* ~~~~~~~~~~~~~~~~~~~~~~~~~~ Programme principal ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

int main()
{
   int             i ,oldx,oldy,mx,my;

   unsigned long   ref , courant , ancien ;

   int             event = 0;
   int             lig , col ;

   if (!initsystem())
      exit ( 1 ) ;

	get_username();

while((event!='q')&&(event!='Q'))
{
	cls();
	dbox(0,0,320,101,15);
	dbox(0,100,320,100,15);
	afftext(160-8*7-4,50-4,"demineur normal");
	afftext(160-8*7-4,150-4,"demineur rapide");
	swap();

	while (!getmouse()) waitdelay(500);
	if (msey<100) RATIO=2; else RATIO=1;
	empty();

	nb_lig=NB_LIG;
	nb_col=NB_COL;

   nb_mines = NB_MINES ;

   while ( HAUTEUR_FEN > 200 )
   {
      nb_lig -- ;
      nb_mines = NB_MINES ;
   }
   while ( LARGEUR_FEN > 320 )
   {
      nb_col -- ;
      nb_mines = NB_MINES ;
   }

   cree_pixmaps ( ) ;

   /* initialisation du jeu */
   
   /* on rajoute deux rangees supplementaires pour ne pas avoir a s'occuper *
    * des effets de bord lors du comptage du nombre de mines adjacentes     */
 
   tableau = ( struct jeu ** ) memalloc ( ( nb_lig + 2 ) *
                                        (long)sizeof ( struct jeu * ) ) ;
   for ( i = 0 ; i < nb_lig + 2 ; i ++ )
   {
      tableau [ i ] = ( struct jeu * ) memalloc ( ( nb_col + 2 ) *
                                         (long)sizeof ( struct jeu ) );
   }

   ouvre=1;

   remplis_et_compte ( ) ;
   bord();
   affiche_jeu();

   /* le jeu */
	event=0;
	empty();

   while ( (event!='q')&&(event!='Q')&&(event!='a')&&(event!='A') )
   {
    	getbackup();
	    swap();
	    putbackup();
   	
		if (!keyhit()) waitdelay(200);
		if (!keyhit()) waitdelay(200);
		if (!keyhit()) waitdelay(200);
    	if (!keyhit()) waitdelay(200);
				
        event=0;
		if (buthit()) event=getmouse();
		if (kbhit()) event=getch();

         switch ( event )
         {
         case 'p':
         case 'P':
         		podium();
         		
         		swap();
         		putbackup();
         		
         		break;
		 case ' ':
			 	mx=mousex;
			 	my=mousey;
		 
                 if ( mx > X_JEU            &&
                      mx < X_JEU + LARG_JEU &&
                      my > Y_JEU            &&
                      my < Y_JEU + HAUT_JEU &&
                      ! perdu && ! gagne )
            {
               if ( ( mx - X_JEU ) % ( LARG_CASE + 1 ) == 0 ||
                    ( my - Y_JEU ) % ( HAUT_CASE + 1 ) == 0 )
               {
               }
               else
               {
                  icone_joue ( ) ;

                  lig = 1 + ( my - Y_JEU ) / ( HAUT_CASE + 1 ) ;
                  col = 1 + ( mx - X_JEU ) / ( LARG_CASE + 1 ) ;

                  if ( tableau [ lig ] [ col ] . etat == DECOUVERTE )
                  {
                     cases_vides ( lig , col ) ;

			    	getbackup();
				    swap();
				    putbackup();

                  if ( tableau [ lig ] [ col ] . nombre ==
                          nombre_de_drapeaux ( lig , col ) )
                  {
                     double_clic ( lig , col ) ;
                  }
                  else
                  {
                     affiche_bloc ( lig , col ) ;
                  }

		            icone_perdu_gagne ( ) ;

                  }
			   }
			}

            break ;

         case 1:
         case 2:
       		oldx=msex;
       		oldy=msey;
         	
            if ( oldy >= Y_ICONE              &&
                 oldy <= Y_ICONE + HAUT_ICONE &&
                 oldx >= X_ICONE              &&
                 oldx <= X_ICONE + LARG_ICONE &&
                 msek == 1 )
            {
               icone_activee ( ) ;

		    	getbackup();
			    swap();
			    putbackup();

               remplis_et_compte ( ) ;
               affiche_jeu ( ) ;

            }
            else if ( oldx > X_JEU            &&
                      oldx < X_JEU + LARG_JEU &&
                      oldy > Y_JEU            &&
                      oldy < Y_JEU + HAUT_JEU &&
                      ! perdu && ! gagne )
            {
               if ( ( oldx - X_JEU ) % ( LARG_CASE + 1 ) == 0 ||
                    ( oldy - Y_JEU ) % ( HAUT_CASE + 1 ) == 0 )
               {
               }
               else
               {
                  icone_joue ( ) ;

                  lig = 1 + ( oldy - Y_JEU ) / ( HAUT_CASE + 1 ) ;
                  col = 1 + ( oldx - X_JEU ) / ( LARG_CASE + 1 ) ;

                  if ( msek == 1          &&
                       tableau [ lig ] [ col ] . etat != DECOUVERTE &&
                       tableau [ lig ] [ col ] . etat != MARQUEE )
                  {
                     case_vide ( lig , col ) ;

			    	getbackup();
				    swap();
				    putbackup();

                     joue ( lig , col ) ;

                     if ( ! jeu && !gagne && ! perdu )
                     {
                        jeu = 1 ;
                        ancien = ref = systime ( ) ;
                     }

                  }
                  else if ( msek == 2          &&
                            tableau [ lig ] [ col ] . etat != DECOUVERTE )
                  {
                     marque ( lig , col ) ;

                     if ( ! jeu && ! gagne && ! perdu )
                     {
                        jeu = 1 ;
                        ancien = ref = systime ( ) ;
                     }
                  }
               }
            }
            break ;

		 case 'a':
		 case 'A':
	     case 'q':
         case 'Q':
            
               for ( i = 0 ; i < nb_lig + 2 ; i ++ )
               {
                  memfree ( &tableau [ i ] ) ;
               }
               memfree ( &tableau ) ;
               detruit_pixmaps ( ) ;
            
            break ;
         }
      

      if ( jeu  )
      {
         courant = systime ( ) ;
         if ( ancien != courant )
         {
            ancien = courant ;
            temps = (courant - ref)/1000 ;
            if (temps>999) temps=999;
            chronometre ( ) ;
         }
      }
   }

}
	killsystem();

	return 0;
}

int nombre_de_drapeaux ( lig , col )
int lig , col ;
{
   return ( drapeau01 ( lig - 1 , col - 1 ) +
            drapeau01 ( lig - 1 , col     ) +
            drapeau01 ( lig - 1 , col + 1 ) +
            drapeau01 ( lig     , col - 1 ) +
            drapeau01 ( lig     , col + 1 ) +
            drapeau01 ( lig + 1 , col - 1 ) +
            drapeau01 ( lig + 1 , col     ) +
            drapeau01 ( lig + 1 , col + 1 ) ) ;
}

int drapeau01 ( lig , col )
int lig , col ;
{
   return ( ( tableau [ lig ] [ col ] . etat == MARQUEE ) ? 1 : 0 ) ;
}
