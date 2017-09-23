#include <portab.h>
#include <string.h>
#include <stdlib.h>
#include "xgem.h"
#include "gwindows.h"
#include "bulle.h"


/*#include "bulle.rsh"*/

#define true  (1 == 1)
#define false (1 == 0)

#define max(exp1,exp2) ((exp1 > exp2) ? exp1 : exp2)
#define min(exp1,exp2) ((exp1 < exp2) ? exp1 : exp2)

#define CR    '\r'
#define LF    '\n'

typedef struct
{	unsigned int framecol		:4;
	unsigned int textcol		:4;
	unsigned int textmode		:1;
	unsigned int fillpattern	:3;
	unsigned int interiorcol	:4;
}BFOB;

static OBJECT *piece_bulle = NULL ;

int BHelpSetRSCFile(char *file)
{
  if ( Xrsrc_load( file ) == 0 ) return( -1 ) ;
  if ( Xrsrc_gaddr( R_TREE, FORM_BULLE, &piece_bulle ) == 0 ) return( -1 ) ;

  return( 0 ) ;
}

/*********************************************************************/
/** RENVOIE LA POSITION X Y DE LA SOURIS ET L'ETAT DU BOUTON GAUCHE **/
/** APRES UN CERTAIN DELAI											**/
/*********************************************************************/
void mouse_x_y_k(int *ev_mmox, int *ev_mmoy, int *ev_mmbutton, int *ev_mmokstate)
{	int ev_mwhich, ev_mflags,
		ev_mgpbuff[8], ev_mkreturn=0, ev_mbreturn=0;
	
	ev_mflags=MU_TIMER|MU_BUTTON;

	ev_mwhich=evnt_multi(	ev_mflags,
							1, 1, 1,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							ev_mgpbuff,
							40, 0,
							ev_mmox, ev_mmoy, ev_mmbutton, ev_mmokstate,
        					&ev_mkreturn, &ev_mbreturn
        			 	);
	
/*SI UN BOUTON A ETE CLIQUER, ON MET 1 PAR DEFAUT*/
	if((ev_mwhich&MU_BUTTON)==MU_BUTTON)
		*ev_mmbutton=1;
	else
		*ev_mmbutton=0;
}/*mouse_x_y_k*/


/**********************************************************/
/** CREER UNE BOX BLANCHE QUI SERVIRA DE FOND A LA BULLE **/
/**********************************************************/
void init_obj_box_bulle(OBJECT *bulle, int i, int pos_x, int pos_y, int w, int h)
{	if(i>1)
	{	bulle[i-1].ob_next = i;
		bulle[i-1].ob_flags = NONE;
	}/*if*/
		
	bulle[i].ob_next = 0;
	bulle[i].ob_head = -1;
	bulle[i].ob_tail = -1;
	bulle[i].ob_type = G_BOX;
	bulle[i].ob_flags = NONE|LASTOB;
	bulle[i].ob_state = NORMAL;
	bulle[i].ob_spec.obspec.framesize = 0;
	bulle[i].ob_spec.obspec.framecol = 1;
	bulle[i].ob_spec.obspec.textcol = 1;
	bulle[i].ob_spec.obspec.fillpattern = 0;
	bulle[i].ob_x = pos_x;
	bulle[i].ob_y = pos_y;
	bulle[i].ob_width = w;
	bulle[i].ob_height = h;
}/*init_obj_box_bulle*/

/*****************************************************/
/** COPY LA STRUCTURE ICONE D'UNE PIECE DE LA BULLE **/
/*****************************************************/
void init_obj_bulle(OBJECT *bulle, OBJECT *piece_bulle, int i, int icone, int pos_x, int pos_y)
{	if(i>1)
	{	bulle[i-1].ob_next = i;
		bulle[i-1].ob_flags = NONE;
	}/*if*/
	
	memcpy(&bulle[i], &piece_bulle[icone], sizeof(OBJECT));
	bulle[i].ob_next = 0;
	bulle[i].ob_flags = NONE|LASTOB;
	bulle[i].ob_x = pos_x;
	bulle[i].ob_y = pos_y;
}/*init_obj_bulle*/


/****************************************************************************/
/**                CREATION DE LA DITE BULLE EN FONCTION                   **/
/**                   DU NOMBRE DE LIGNE, DU NOMBRE DE                     **/
/**                CARACTERE ET DE LA POSITION A L'ECRAN                   **/
/**                     ***************************                        **/
/** piece_bulle => formulaire qui contient la bulle en piece d‚tach‚       **/
/** nb_ligne => nombre de ligne                                            **/
/** nb_cara => longueur maxi d'une ligne                                   **/
/** m_x, my => position de la souris                                       **/
/** num_1er_item => numero objet de la 1Šre ligne                          **/
/** la fonction renvoie le pointeur de la bulle qui est un bˆte formulaire **/
/****************************************************************************/
OBJECT *creer_bulle(OBJECT *piece_bulle, int nb_ligne, int nb_cara, int m_x, int m_y, int *num_1er_item)
{	int nb64=0, nb32=0, nb16=0, icone, k;
	int i, j, nb_objets, nb_pixel, pos_y, pos_x;
	int coin_gauche, haut;
	OBJECT *bulle=NULL;
	BFOB *modif=NULL; 

/*DETERMINE LE NOMBRE D'OBJET*/	
	nb_pixel=nb_cara*6;

	nb64=(int)(nb_pixel/64);
	nb_pixel-=nb64*64;

	nb32=(int)(nb_pixel/32);
	nb_pixel-=nb32*32;

	nb16=(int)(nb_pixel/16);
	nb_pixel-=nb16*16;

/* LE PERE + LE POINTEUR + LES 2 BORDS + XXX */
	nb_objets=2+1+(nb64+nb32+nb16+2)*2+(nb_ligne-1)*2+nb_ligne;
	
/*ALLOCATION DE LA BULLE*/
	bulle = (OBJECT *)calloc(nb_objets, sizeof (OBJECT));
	
	if( bulle )
	{/*DEFINITION DU PERE ([0])*/
		bulle->ob_next = -1;
		bulle->ob_head = 1;
		bulle->ob_tail = nb_objets-1;
		bulle->ob_type = G_IBOX;
		bulle->ob_flags = NONE;
		bulle->ob_state = NORMAL;
		bulle->ob_spec.obspec.framesize = 0;
		bulle->ob_spec.obspec.framecol = 1;
		bulle->ob_spec.obspec.textcol = 1;
		bulle->ob_spec.obspec.fillpattern = 0;
		bulle->ob_width = (nb64*64)+(nb32*32)+((nb16+2)*16);
		bulle->ob_height = (nb_ligne+1)*8+16;

	/*DETERMINE LA POSITION DU POINTEUR DE LA BULLE*/
	/*POSITION X*/	
		if(m_x<(Xmax/3)*2)
		{	pos_x=0;
			coin_gauche=true;
		}
		else
		{	pos_x=bulle->ob_width-16;
			m_x-=bulle->ob_width;
			coin_gauche=false;
		}/*if*/
	/*POSITION Y*/	
		if(m_y<(Ymax/3)*2)
			haut=true;
		else
		{	m_y-=bulle->ob_height;
			haut=false;
		}/*if*/
		
	/*POSITIONNE LE PERE*/
		bulle->ob_x = m_x;
		bulle->ob_y = m_y;
	
	/*DEFINITION DU POINTEUR DE LA BULLE et SA POSITION*/
		if(haut)
		{	if(coin_gauche)	icone=16; else icone=17;
			i=1;
			pos_y=0;
		}
		else
		{	if(coin_gauche)	icone=22; else icone=23;
			i=nb_objets-nb_ligne-1;
			pos_y=bulle->ob_height-16;
		}/*if*/
		
	/*INIT POINTEUR*/
		init_obj_bulle(bulle, piece_bulle, i, icone, pos_x, pos_y);

	/*OU ET PAR QUI ON CONTINUE*/
		if(haut)
		{	pos_y+=16;
			i=2;
		}
		else
		{	pos_y=0;
			i=1;
		}/*if*/
		pos_x=0;
			
	/*DEFINITION DU FOND DE LA BULLE*/ 	
		init_obj_box_bulle(bulle, i, 16, pos_y+8, bulle->ob_width-32, bulle->ob_height-32);
		i++;
		
	/*DEFINITION DES AUTRES FILS*/	
		for(j=0; j<nb_ligne+1; j++, pos_x=0, pos_y+=8)
		{/** GAUCHE **/
		/*SI HAUT, ALORS COIN GAUCHE HAUT*/
			if(j==0) 
				if(coin_gauche && haut) icone=18;
				else icone=1;
		/*SI BAS, ALORS COIN GAUCHE BAS*/
			else if(j==nb_ligne) 
				if(haut || coin_gauche==false) icone=3;
				else icone=20; 
		/*SI MILIEU*/	
			else icone=2;

	/**INIT L'OBJET**/	
			init_obj_bulle(bulle, piece_bulle, i, icone, pos_x, pos_y);
			i++;
			pos_x=16;
	
		/*MILIEU*/
			for(k=0; k<nb64; k++)
			{	/*SI HAUT, ALORS SOMMET HAUT*/
					if(j==0) icone=10;
				/*SI BAS, ALORS SOMMET BAS*/
					else if(j==nb_ligne) icone=12;
				/*SI MILIEU, ALORS MILIEU*/
					else icone=0;
			
			/**INIT L'OBJET**/	
				if(icone)
				{	init_obj_bulle(bulle, piece_bulle, i, icone, pos_x, pos_y);
					i++;
				}/*if*/
				pos_x+=64;
			}/*for*/
				
			for(k=0; k<nb32; k++)
			{	/*SI HAUT, ALORS SOMMET HAUT*/
					if(j==0) icone=7;
				/*SI BAS, ALORS SOMMET BAS*/
					else if(j==nb_ligne) icone=9;
				/*SI MILIEU, ALORS MILIEU*/
					else icone=0;

			/**INIT L'OBJET**/	
				if(icone)
				{	init_obj_bulle(bulle, piece_bulle, i, icone, pos_x, pos_y);
					i++;
				}/*if*/
				pos_x+=32;
			}/*for*/
	
			for(k=0; k<nb16; k++)
			{	/*SI HAUT, ALORS SOMMET HAUT*/
					if(j==0) icone=4;
				/*SI BAS, ALORS SOMMET BAS*/
					else if(j==nb_ligne) icone=6;
				/*SI MILIEU, ALORS MILIEU*/
					else icone=0;
					
			/**INIT L'OBJET**/		
				if(icone)
				{	init_obj_bulle(bulle, piece_bulle, i, icone, pos_x, pos_y);
					i++;
				}/*if*/
				pos_x+=16;
			}/*for*/
	
		/*DROITE*/
			/*SI HAUT, ALORS COIN DROITE HAUT*/
				if(j==0) 
					if(coin_gauche || haut==false) icone=13;
					else icone=19;
			/*SI BAS, ALORS COIN DROITE BAS*/
				else if(j==nb_ligne) 
					if(coin_gauche || haut) icone=15;	
					else icone=21;
			/*SI MILIEU*/
				else icone=14;

		/**INIT L'OBJET**/				
			init_obj_bulle(bulle, piece_bulle, i, icone, pos_x, pos_y);
			i++;
		}/*for*/
		
	/*SI PAS HAUT ALORS MET LES BONS FLAGS SUR LE POINTEUR DE BULLE*/	
		if(!haut)
		{	bulle[i-1].ob_next = i;
			bulle[i-1].ob_flags = NONE;
			i++;
		}/*if*/
			
	/*MET EN PLACE LES LIGNES DE TEXTE*/
		if(haut)
			pos_y=16+5;
		else
			pos_y=5;	
		pos_x=(bulle->ob_width-(nb_cara*6))/2;
		
	/*ENREGISTRE LE NUMERO DU 1ER ITEM*/
		*num_1er_item=i;
	
	/*CREER LES LIGNES*/
		for(; i<nb_objets; i++, pos_y+=8)
		{	bulle[i-1].ob_next = i;
			bulle[i].ob_next = 0;
			bulle[i].ob_head = -1;
			bulle[i].ob_tail = -1;
			bulle[i].ob_type = G_TEXT;
			bulle[i-1].ob_flags = NONE;
			bulle[i].ob_flags = NONE|LASTOB;
			bulle[i].ob_state = NORMAL;
			bulle[i].ob_spec.tedinfo=(TEDINFO*)calloc(1, sizeof(TEDINFO));
			bulle[i].ob_spec.tedinfo->te_ptext=calloc(1+nb_cara, sizeof(char));
			bulle[i].ob_spec.tedinfo->te_txtlen=nb_cara;
			bulle[i].ob_spec.tedinfo->te_font=5;
			modif=(BFOB *) &bulle[i].ob_spec.tedinfo->te_color;
			modif->textcol=BLACK;
			modif->textmode=0;
			bulle[i].ob_x = pos_x;
			bulle[i].ob_y = pos_y;
			bulle[i].ob_width = nb_cara*6;
			bulle[i].ob_height = 6;
		}/*for*/
	}/*if*/
	
	return bulle;
}/*creer_bulle*/

/*************************************/
/**   GESTION DES BULLES D'AIDES    **/
/** arbre => formulaire courant     **/
/** mx, my => position de la souris **/
/*************************************/
int bulle_aide(int m_x, int m_y, char *txt)
{
  int x=0, y=0, w=0, h=0, nb_ligne, nb_cara, num_1er_item=0, i, j, k ;
  int ev_mmox=0, ev_mmoy=0, ev_mmbutton=0, ev_mmokstate=0;
  long long_txt;
  char buf_txt[61];
  OBJECT *bulle=NULL;

  if ( piece_bulle == NULL ) return( 0 ) ;
/*  {
    Xrsrc_fix( rs_trindex[FORM_BULLE] ) ;
    piece_bulle = rs_trindex[FORM_BULLE] ;
  }*/

  v_hide_c(handle);

  long_txt = strlen( txt ) ;
  nb_ligne = nb_cara = 0 ;
  for ( i = 0, j = 1; i < long_txt; i++, j++ )
  {
    if ( ( txt[i] == CR && txt[i+1]==LF ) || ( i+1==long_txt ) )
    {
      nb_ligne++ ;
      if ( i+1 != long_txt ) j-- ;
      nb_cara = max( j, nb_cara ) ;
      j = 0 ;
      i++;
    }
  }
		
  nb_ligne = min( nb_ligne, 60 ) ;
  nb_cara  = 1 + min( nb_cara, 60 ) ;

  bulle = creer_bulle( piece_bulle, nb_ligne, nb_cara, m_x, m_y, &num_1er_item ) ;
  if ( bulle )
  {
    x = bulle->ob_x;      y = bulle->ob_y ;
	w = bulle->ob_width ; h = bulle->ob_height ;

    for ( i = 0, j = 0, k = 0; i <= long_txt; i++, j++ )
    {
      if ( ( i==long_txt ) || ( txt[i]==CR && txt[i+1]==LF ) )
      {
        buf_txt[j] = '\0' ;
        write_text( bulle, num_1er_item+k, buf_txt );
        buf_txt[0] = '\0' ;
        k++; i++; j = -1 ;
      }
      else buf_txt[j] = txt[i] ;
	}
    form_dial( FMD_START, x, y, w, h, x, y, w, h ) ;
    objc_draw( bulle, 0, 10, x, y, w, h ) ;

    do
    {
      mouse_x_y_k( &ev_mmox, &ev_mmoy, &ev_mmbutton, &ev_mmokstate ) ;
    }
    while ( ( ev_mmox == m_x ) && ( ev_mmoy == m_y && ev_mmbutton == 0 ) ) ;
			
	form_dial( FMD_FINISH, x, y, w, h, x, y, w, h ) ;

    for ( i = num_1er_item; i < num_1er_item+nb_ligne; i++ )
    {
      if ( bulle[i].ob_spec.tedinfo )
      {
        if ( bulle[i].ob_spec.tedinfo->te_ptext ) free( bulle[i].ob_spec.tedinfo->te_ptext ) ;
        free( bulle[i].ob_spec.tedinfo ) ;
      }
    }		
    free( bulle ) ;
  }

  v_show_c( handle, 1 ) ;
	
  return( ev_mmbutton ) ;
}
