/****************************************************************************/
/* DEMO3.C :  Exemple de r‚cup‚ration de fichiers de d‚finition d'ic“nes    */
/* -------    couleur cr‚‚s avec EIKONA. Ce listing est copiable librement, */
/*            vous pouvez le modifier et en utiliser les routines dans vos  */
/*            programmes personnels...                                      */
/*                                                                          */
/*            B.MARICHAL  02.93                                             */
/****************************************************************************/

#include	<aes.h>
#include	<vdi.h>
#include	<tos.h>		
#include	<stdlib.h>

#define		TRUECOLORS	0xFFFF9800L

#define		min( a, b )		(a<b?a:b)

/* D‚finitions propres … l'AES v4.00 */

#define	G_CICON	33
#define	__MAXMTFCOUNT	200

#define	NULL		((void*)0L)

typedef struct cicon_data {
        int     num_planes;             /* number of planes in the following data */
        int     *col_data;              /* pointer to color bitmap in standard form */
        int     *col_mask;              /* pointer to single plane mask of col_data */
        int     *sel_data;              /* pointer to color bitmap of selected icon */
        int     *sel_mask;              /* pointer to single plane mask of selected icon */
        struct cicon_data *next_res;    /* pointer to next icon for a different resolution */
} CICON;

typedef struct cicon_blk {
        ICONBLK monoblk;                /* default monochrome icon */
        CICON   *mainlist;              /* list of color icons for different resolutions */
} CICONBLK;



/* D‚finitions du programme */

#define	NOBJ		17

#include	"leop.icn"			/* Motifs monochromes … 1 plan de bits des ic“nes */
#include	"leop.icm"
#include	"logo.icn"
#include	"logo.icm"

#include	"leop1pn.icn"		/* Cette ic“ne couleur comportera un motif de s‚lection */
#include	"leop1pn.icm"		/* dans tous les mode graphiques (fichiers ...s.icn )   */
#include	"leop1ps.icn"		
#include	"leop1ps.icm"
#include	"leop2pn.icn"
#include	"leop2pn.icm"
#include	"leop2ps.icn"		/* ATTENTION, les motifs de s‚lection ...s.icn et les   */
#include	"leop2ps.icm"		/* motifs normaux ...n.icn appari‚s doivent avoir le    */
#include	"leop4pn.icn"		/* mˆme nombre de plans de bits, veillez donc … les     */
#include	"leop4pn.icm"		/* sauver au mˆme format.                               */
#include	"leop4ps.icn"
#include	"leop4ps.icm"

#include	"logo1pn.icn"		/* Cette ic“ne ne disposera pas de motif de s‚lection.*/
#include	"logo1pn.icm"		/* Lorsqu'elle sera s‚lectionn‚e, elle apparaŒtra     */
#include	"logo2pn.icn"		/* gris‚e. */
#include	"logo2pn.icm"
#include	"logo4pn.icn"
#include	"logo4pn.icm"

CICON		cicn_leop_4p = { LEOP4PN_D_PL, leop4pn_d, leop4pn_m, leop4ps_d, leop4ps_m, 0L },	/* 0L <=> pas d'autres r‚solutions */
				cicn_leop_2p = { LEOP2PN_D_PL, leop2pn_d, leop2pn_m, leop2ps_d, leop2ps_m, &cicn_leop_4p },
				cicn_leop_1p = { LEOP1PN_D_PL, leop1pn_d, leop1pn_m, leop1ps_d, leop1ps_m, &cicn_leop_2p };

/* Les CICONs sont d‚clar‚s '… l'envers' pour que les CICONs mentionn‚s aient d‚j… ‚t‚ d‚finis */

CICON		cicn_logo_4p = { LOGO4PN_D_PL, logo4pn_d, logo4pn_m, 0L, 0L, 0L },
				cicn_logo_2p = { LOGO2PN_D_PL, logo2pn_d, logo2pn_m, 0L, 0L, &cicn_logo_4p },
				cicn_logo_1p = { LOGO1PN_D_PL, logo1pn_d, logo1pn_m, 0L, 0L, &cicn_logo_2p };

/* les 0L dans le CICON pr‚c‚dent signifient l'absence de motifs de s‚lection */

CICONBLK		leop_cicbk = { { leop_m, leop_d, "  L‚opards  ", 0x1000, 0,0, 22,0, LEOP_D_W, LEOP_D_H, 0,32, 74,8 }, &cicn_leop_1p },
						logo_cicbk = { { logo_m, logo_d, "   EIKONA   ", 0x1000, 0,0, 22,0, LOGO_D_W, LOGO_D_H, 0,32, 74,8 }, &cicn_logo_1p };


char																						/* ChaŒnes du menu */
	str_3[] = " ",
	str_4[] = " Fichiers",
	str_7[] = "  A propos de cet exemple...",
	str_8[] = "------------------------------",
	str_9[] = "  Accessoire     1  ",
	str_10[] = "  Accessoire     2  ",
	str_11[] = "  Accessoire     3  ",
	str_12[] = "  Accessoire     4  ",
	str_13[] = "  Accessoire     5  ",
	str_14[] = "  Accessoire     6  ",
	str_16[] = "  Quitter ";
	
OBJECT																					/* D‚finition du menu */
	tr_MENU[] =	
	{
		{ 0xFFFF, 0x0001, 0x0005, 0x0019, 0x0000, 0x0000, 0x00000000L, 0x0000, 0x0000, 0x0050, 0x0019 },
		{ 0x0005, 0x0002, 0x0002, 0x0014, 0x0000, 0x0000, 0x00001100L, 0x0000, 0x0000, 0x0050, 0x0201 },
		{ 0x0001, 0x0003, 0x0004, 0x0019, 0x0000, 0x0000, 0x00000000L, 0x0002, 0x0000, 0x000E, 0x0301 },
		{ 0x0004, 0xFFFF, 0xFFFF, 0x0020, 0x0000, 0x0000, (long)str_3, 0x0000, 0x0000, 0x0004, 0x0301 },
		{ 0x0002, 0xFFFF, 0xFFFF, 0x0020, 0x0000, 0x0000, (long)str_4, 0x0004, 0x0000, 0x000A, 0x0301 },
		{ 0x0000, 0x0006, 0x000F, 0x0019, 0x0000, 0x0000, 0x00000000L, 0x0000, 0x0301, 0x0050, 0x0013 },
		{ 0x000F, 0x0007, 0x000E, 0x0014, 0x0000, 0x0000, 0x00FF1100L, 0x0002, 0x0000, 0x001E, 0x0008 },
		{ 0x0008, 0xFFFF, 0xFFFF, 0x001C, 0x0000, 0x0000, (long)str_7, 0x0000, 0x0000, 0x001E, 0x0001 },
		{ 0x0009, 0xFFFF, 0xFFFF, 0x001C, 0x0000, 0x0008, (long)str_8, 0x0000, 0x0001, 0x001E, 0x0001 },
		{ 0x000A, 0xFFFF, 0xFFFF, 0x001C, 0x0000, 0x0000, (long)str_9, 0x0000, 0x0002, 0x001E, 0x0001 },
		{ 0x000B, 0xFFFF, 0xFFFF, 0x001C, 0x0000, 0x0000, (long)str_10, 0x0000, 0x0003, 0x001E, 0x0001 },
		{ 0x000C, 0xFFFF, 0xFFFF, 0x001C, 0x0000, 0x0000, (long)str_11, 0x0000, 0x0004, 0x001E, 0x0001 },
		{ 0x000D, 0xFFFF, 0xFFFF, 0x001C, 0x0000, 0x0000, (long)str_12, 0x0000, 0x0005, 0x001E, 0x0001 },
		{ 0x000E, 0xFFFF, 0xFFFF, 0x001C, 0x0000, 0x0000, (long)str_13, 0x0000, 0x0006, 0x001E, 0x0001 },
		{ 0x0006, 0xFFFF, 0xFFFF, 0x001C, 0x0000, 0x0000, (long)str_14, 0x0000, 0x0007, 0x001E, 0x0001 },
		{ 0x0005, 0x0010, 0x0010, 0x0014, 0x0000, 0x0000, 0x00FF1100L, 0x0006, 0x0000, 0x000C, 0x0001 },
		{ 0x000F, 0xFFFF, 0xFFFF, 0x001C, 0x0020, 0x0000, (long)str_16, 0x0000, 0x0000, 0x000C, 0x0001 }
	};

OBJECT				/* d‚finition de l'arbre d'objets contenant les icones */
	newdesk[] =
	{
		{ 0xFFFF, 0x0001, 0x0002, G_BOX, 0x0000, 0x0000, 0x00fe11c3L, 0, 0, 0, 0 },
		{ 0x0002, 0xFFFF, 0xFFFF, G_CICON, 0x0000, 0x0000, (long)&leop_cicbk, 0x0005, 0x0002, 0x4a00, 0x2800 },
		{ 0x0000, 0xFFFF, 0xFFFF, G_CICON, 0x0000, 0x0000, (long)&logo_cicbk, 0x0010, 0x0002, 0x4a00, 0x2800 },
	};

	
char	alerte[] = "[0][\10 Programme de d‚monstration  |"
							 "d'utilisation  des  fichiers|"
							 "*.ICN cr‚‚s avec EIKONA|"
							 "\10 Vous  pouvez  d‚placer  et|"
							 "s‚lectionner les ic“nes...][ DEMO3.C |   O K   ]"; 
	
int	ap_id, vdih;


/********* D‚clarations pour les nouvelles fonctions *********/

int		__NewMtfCount, *__NewMtf[__MAXMTFCOUNT];

/*************************************************************/


int getx( OBJECT *tree, int obj )
{
	int parent = obj, inc;
	
	while((( obj > tree[parent].ob_tail )||( obj < tree[parent].ob_head ))&&( parent != -1 )) parent = tree[parent].ob_next;
	
	if( parent != -1 )	inc = getx( tree, parent );
	else inc = 0;
	
	return tree[obj].ob_x + inc;
}


int gety( OBJECT *tree, int obj )
{
	int parent = obj, inc;
	
	while((( obj > tree[parent].ob_tail )||( obj < tree[parent].ob_head ))&&( parent != -1 )) parent = tree[parent].ob_next ;
	
	if( parent != -1 ) inc = gety( tree, parent );
	else inc = 0;
	
	return tree[obj].ob_y + inc;
}


void setx( OBJECT *tree, int obj, int x )
{
	int oldx = getx( tree, obj );
	tree[obj].ob_x += ( x - oldx );
}


void sety( OBJECT *tree, int obj, int y )
{
	int oldy = gety( tree, obj );
	tree[obj].ob_y += ( y - oldy );
}


int rsrcc_obfix( OBJECT *tree, int obj, int nbpl )
{
/* Convertit les coordonn‚es 'caractŠre' d'un objet en coordonn‚es '‚cran',     */
/* choisit pour les objets G_CICON le CICON appropri‚ pour la repr‚sentation 		*/
/* de l'ic“ne … l'‚cran en adaptant le nombre de plans de bits au mode vid‚o    */
/* actuel. Renvoie 0 en cas d'erreur, 1 sinon.                                  */
	
	int		np, i, j, k, l, pix, *wdst, *wsrc, stock1[16], stock2[16], mtf_h, mtf_w, mtf, *colptr;
	CICON	*cicnp, *good_cicnp;
	static int colors[256], regw, tc_color;
	static long	*reg_base=(long*)TRUECOLORS, regl, oldsstack;
		
	if( tree[obj].ob_type == G_CICON )															/* Si l'objet est une icone couleur */
	{
		cicnp = (( CICONBLK* )( tree[obj].ob_spec.index ))->mainlist; /* pointeur sur la liste de CICONs */
		np = 0;																												/* initialisation du meilleur nombre de plans */
		
		while( cicnp )																								/* tant qu'il y a des CICONs */
		{
			if(( cicnp->num_planes > np )&&( cicnp->num_planes <= nbpl )) /* Si ce CICON est meilleur que les autres */
			{
				np = cicnp->num_planes;																			/* Enregistrer son nombre de plans */
				good_cicnp = cicnp;																					/* et son adresse */
			}
			cicnp = cicnp->next_res;																			/* Passer au CICON suivant */
		}
		
		if( np == 0 )																													/* Si on n'a pas trouv‚ de CICON convenable, */
		 (( CICONBLK* )( tree[obj].ob_spec.index ))->mainlist = ( CICON* )0L;	/* Supprimer la liste de CICON du CICONBLK   */
		else
		{
			(( CICONBLK* )( tree[obj].ob_spec.index ))->mainlist = good_cicnp;	/* sinon, mettre le bon CICON en premier dans la liste */
			good_cicnp->next_res = ( CICON* )0L;																/* occulter les autres */
			
			if( np != nbpl )	/* si le nombre de plans de bits ne correspond pas au mode vid‚o actuel */
			{
				mtf_w = (tree[obj].ob_spec.iconblk)->ib_wicon;	/* enregistrer la largeur du motif */
				mtf_h = (tree[obj].ob_spec.iconblk)->ib_hicon;	/* enregistrer la hauteur du motif */

				if( nbpl == 16 )						/* si on est en mode true color, il faut saisir la palette */
				{
					oldsstack = Super( 0L );									/* passage en superviseur */
					for( regw=0; regw<256; regw++ )
					{
						regl = reg_base[regw];									/* saisir contenu long du registre */
						tc_color = ((int)(*((char*)&regl)))<<5;	/* extraire la composante rouge et d‚caler */
						tc_color |= (*((int*)&regl))&31;				/* ajouter la composante verte */
						tc_color <<= 6;													/* d‚caler en tenant compte du bit d'ovl */
						tc_color |= (int)( regl&31L );					/* ajouter composante bleue */
						colors[regw] = tc_color;								/* stocker la couleur '‚cran' */
					}
					Super( (void*)oldsstack );								/* retour en mode utilisateur */
				}
					
				for( mtf=0; mtf<2; mtf++ )											/* pour le motif 'N' et le motif 'S' */
				{				
					switch( mtf )
					{
						case 0:
							wsrc = good_cicnp->col_data;							/* pointeur sur motif 'N' */
							break;
						case 1:
							wsrc = good_cicnp->sel_data;							/* pointeur sur motif 'S' */
							break;
					}
					
					if( wsrc != NULL )														/* Si le motif existe */
					{
						if( __NewMtfCount >= __MAXMTFCOUNT ) return 0;	/* S'il n'y a plus de place dans le tableau, renvoyer un code d'erreur */
						
						__NewMtf[__NewMtfCount] = (int*)malloc( nbpl*( mtf_w/16 )*mtf_h*2 );
																												/* R‚server de la m‚moire pour le nouveau motif */									
						wdst = __NewMtf[__NewMtfCount];

						if( wdst == NULL )
							return 0;										/* Si il y a eu erreur, retourner 0 */
						else
							switch( mtf )								/* Sinon, ... */
							{
								case 0:
									good_cicnp->col_data = wdst;		/* modifier le pointeur */
									good_cicnp->num_planes = nbpl;	/* et le nombre de plans */
									break;
								case 1:
									good_cicnp->sel_data = wdst;		/* idem pour le motif 'S' */
									break;
							}

						__NewMtfCount++;						/* On a un pointeur de plus dans la liste des nouveaux motifs */
												
						for( j=0; j<mtf_h; j++ )		/* Pour chaque ligne */
						{
							for( i=0; i<(( mtf_w+15 )/16 ); i++ )		/* Pour chaque mot de la ligne */
							{
								for( k=0; k<np; k++ ) stock1[k] = *wsrc++;	/* Charger np mots (pour np plans ) */
							
								for( pix=0, colptr=stock2; pix<16; pix++ )									/* pour chaque pixel */
								{
									for( k=np-1, regw=0; k>=0; k-- )	/* d‚terminer l'index de registre du pixel */
									{
										regw <<= 1;
										if( stock1[k]&0x8000L ) regw |= 1;
										stock1[k]<<=1;
									}
									
									if( regw == ( ~( 0xffff<<np ))) regw = ( ~( 0xffff<<min( nbpl, 8 )));

									if( nbpl != 16 )
										for( k=0; k<nbpl; regw>>=1, k++ )	/* remplacer par le nouvel index de registre sur nbpl plans */
										{
											stock2[k] <<= 1;
											if( regw&1 ) stock2[k] |= 1;
										}
									else
										*colptr++ = colors[regw];  /* en true color, il suffit de stocker la couleur … afficher */
								}
								
								for( l=0; l<nbpl; l++ ) *wdst++ = stock2[l];	/* Sauver les nouveaux plans */
							}
						}
					}
				}		
			}
		}
	}
	
	i = rsrc_obfix( tree, obj );		/* cette fonction renvoie toujours 1 */

	return i;			/* retourner le r‚sultat de rsrc_obfix (toujours 1 ) */
}


void rsrcc_free( void )
{
/* LibŠre les zones m‚moire ‚ventuellement allou‚es pour adapter les motifs */
/* au nombre de plans correspondant au mode vid‚o actuel.                   */

	if( __NewMtfCount ) /* Si on a r‚serv‚ des blocs m‚moire */
		do
		{
			__NewMtfCount--;									/* d‚cr‚menter le compteur */
			free( __NewMtf[__NewMtfCount] );	/* et lib‚rer */
		} while( __NewMtfCount );
}



void main( void )
{
  int			work_in[11], work_out[57], i, mg_buff[16], w0[4], bid, mx, my, mk, nk,
  				newx, newy, event = 0, end = 0, oldx, oldy, nbpl;
  				
  OBJECT	*obj;
  
  
  ap_id = appl_init();										/* init. AES */

  for( i=0; i<10; i++ ) work_in[i]=1;
  work_in[10] = 2;
  v_opnvwk( work_in, &vdih, work_out );		/* init. VDI */
  
	vq_extnd( vdih, 1, work_out );
	nbpl = work_out[4];						/* Saisir le nombre de plans de bits actuel */

  graf_mouse( 0, 0L );
  
	obj = tr_MENU;
	for( i=0; i<NOBJ; i++ )
		if( rsrcc_obfix( obj++, 0, nbpl ) == 0 ) end = 1;	
									/* Convertir les dimensions du menu */
	obj = newdesk;
	for( i=0; i<3; i++ )
		if( rsrcc_obfix( obj++, 0, nbpl ) == 0 ) end = 1;
									/* Convertir les dimensions du menu */

	if( end == 1 ) 	/* En cas d'erreur, terminer */
	{
		form_alert( 1, "[1][ |Erreur d'initialisation !  |Retour au bureau...][ OK ]" );
		rsrcc_free();				/* Lib‚rer les zones allou‚es ressource */
  	v_clsvwk( vdih );		/* Fermer la VDI */
  	appl_exit();				/* Fermer l'AES */
  	Pterm0();						/* Terminer programme */
  }
		
	wind_get( 0, WF_WORKXYWH, w0, w0+1, w0+2, w0+3 );	
	w0[0] -= 1; w0[1] -= 1;						/* Calcul et ajustement des dimensions du bureau */
	w0[2] += 2; w0[3] += 2;
	
	newdesk[0].ob_x = w0[0];								/* Ajuster les dimensions du fond */
	newdesk[0].ob_y = w0[1];
	newdesk[0].ob_width = w0[2];
	newdesk[0].ob_height = w0[3];
	
	wind_set( 0, WF_NEWDESK, newdesk, 0, 0 );		/* remplacement du bureau */
/*	form_dial( FMD_START, 0,0,0,0, w0[0],w0[1],w0[2],w0[3] );*/
	form_dial( FMD_FINISH, 0,0,0,0, w0[0],w0[1],w0[2],w0[3] );
																							/* G‚n‚rer un redessin total */

	menu_bar( tr_MENU, 1 );											/* Afficher la barre de menus */
	
	do
	{
		if( event == 0 ) event = evnt_multi( 18, 2, 1, 1, 0,0,0,0,0, 0,0,0,0,0, mg_buff, 0,0, &mx, &my, &mk, &bid, &bid, &nk );
																							/* Attente d'‚vŠnement */
		if( event&16 )														/* Un message est arriv‚... */
		{
			if( mg_buff[0] == 10 )									/* ...c'est un clic dans un menu */
			{
				switch( mg_buff[4] )
				{
					case 7:
						form_alert( 2, alerte );					/* Affichage alerte */
						break;
					case 16:
						end = 1;													/* Fin */
						break;
				}
				menu_tnormal( tr_MENU, mg_buff[3], 1 );	/* D‚selectionner la barre de menus */
			}
			event &= ~16; 
		}
		else
		if( event&2 )															/* Il y a eu un clic */
		{
			i = objc_find( newdesk, 0, 1, mx, my );	/* Chercher l'objet */
			
			if( i > 0 )
			{
				graf_mkstate( &mx, &my, &mk, &bid );	/* Tester l'‚tat des boutons */
				if( mk )
				{
					oldx = getx( newdesk, i );
					oldy = gety( newdesk, i );
					graf_dragbox( newdesk[i].ob_width, newdesk[i].ob_height, oldx, oldy,
												w0[0], w0[1], w0[2], w0[3], &newx, &newy );
																							/* D‚placer le 'fant“me' de l'ic“ne */
					setx( newdesk, i, newx );						/* Fixer les nouvelles coordonn‚es */
					sety( newdesk, i, newy );

/*					form_dial( FMD_START, 0,0,0,0, oldx, oldy, newdesk[i].ob_width, newdesk[i].ob_height );*/
					form_dial( FMD_FINISH, 0,0,0,0, oldx, oldy, newdesk[i].ob_width, newdesk[i].ob_height );
																							/* Forcer un redraw local*/
/*					form_dial( FMD_START, 0,0,0,0, newx, newy, newdesk[i].ob_width, newdesk[i].ob_height );*/
					form_dial( FMD_FINISH, 0,0,0,0, newx, newy, newdesk[i].ob_width, newdesk[i].ob_height );
																							/* Forcer un redraw local*/
				}
				else
				{
					newdesk[i].ob_state ^= 1;						/* S‚lectionner */

/*					form_dial( FMD_START, 0,0,0,0, getx( newdesk, i ), gety( newdesk, i ), newdesk[i].ob_width, newdesk[i].ob_height );*/
					form_dial( FMD_FINISH, 0,0,0,0, getx( newdesk, i ), gety( newdesk, i ), newdesk[i].ob_width, newdesk[i].ob_height );
																							/* Forcer un redraw local*/
				}
			}
			else Cconout( 7 );											/* Rien sous le curseur => Bip */
			
			event &= ~2; 
		}		
	}
	while( end == 0 );
	
	wind_set( 0, WF_NEWDESK, 0, 0, 0, 0 );			/* Remettre l'ancien bureau en place */
	menu_bar( tr_MENU, 0 );											/* D‚sactiver la barre de menus */
	
	rsrcc_free();																/* Lib‚rer le ressource */
  v_clsvwk( vdih );														/* Fermer la VDI */
  appl_exit();																/* Fermer l'AES */
}


