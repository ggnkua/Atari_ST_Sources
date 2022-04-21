/****************************************************************************/
/* DEMO2.C :  Exemple de r‚cup‚ration de fichiers de d‚finition d'ic“nes    */
/* -------    cr‚‚s avec EIKONA. Ce listing est copiable librement, vous    */
/*            pouvez le modifier et en utiliser les routines dans vos       */
/*            programmes personnels...                                      */
/*                                                                          */
/*            B.MARICHAL  02.93                                             */
/****************************************************************************/

#include	<aes.h>
#include	<vdi.h>
#include	<tos.h>		

#define	NOBJ	17

#include	"leop.icn"
#include	"leop.icm"
#include	"logo.icn"
#include	"logo.icm"

ICONBLK		leop_icbk = { leop_m, leop_d, "  L‚opards  ", 0x1000, 0,0, 22,0, LEOP_D_W, LEOP_D_H, 0,32, 74,8 },
					logo_icbk = { logo_m, logo_d, "   EIKONA   ", 0x1000, 0,0, 22,0, LOGO_D_W, LOGO_D_H, 0,32, 74,8 };
					
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

OBJECT
	newdesk[] =
	{
		{ 0xFFFF, 0x0001, 0x0002, G_BOX, 0x0000, 0x0000, 0x00fe11c3L, 0, 0, 0, 0 },
		{ 0x0002, 0xFFFF, 0xFFFF, G_ICON, 0x0000, 0x0000, (long)&leop_icbk, 0x0005, 0x0002, 0x4a00, 0x2800 },
		{ 0x0000, 0xFFFF, 0xFFFF, G_ICON, 0x0000, 0x0000, (long)&logo_icbk, 0x0010, 0x0002, 0x4a00, 0x2800 },
	};
	
char	alerte[] = "[0][\10 Programme de d‚monstration  |"
							 "d'utilisation  des  fichiers|"
							 "*.ICN cr‚‚s avec EIKONA|"
							 "\10 Vous  pouvez  d‚placer  et|"
							 "s‚lectionner les ic“nes...][ DEMO2.C |   O K   ]"; 
	
int	ap_id, vdih;



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



void main( void )
{
  int			work_in[11], work_out[57], i, mg_buff[16], w0[4], bid, mx, my, mk, nk,
  				newx, newy, event = 0, end = 0, oldx, oldy;
  				
  OBJECT	*obj;
  
  
  ap_id = appl_init();										/* init. AES */

  for( i=0; i<10; i++ ) work_in[i]=1;
  work_in[10] = 2;
  v_opnvwk( work_in, &vdih, work_out );		/* init. VDI */
  
  graf_mouse( 0, 0L );
  
	obj = tr_MENU;
	for( i=0; i<NOBJ; i++ )	rsrc_obfix( obj++, 0 );	
																							/* Convertir les dimensions du menu */
	obj = newdesk;
	for( i=0; i<3; i++ )	rsrc_obfix( obj++, 0 );	
																							/* Convertir les dimensions du menu */

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
	
  v_clsvwk( vdih );														/* Fermer la VDI */
  appl_exit();																/* Fermer l'AES */
}

