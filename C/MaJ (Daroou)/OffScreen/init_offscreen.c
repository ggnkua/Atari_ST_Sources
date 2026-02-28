/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 19/12/2015 * */
/* ***************************** */




#include <TGA_SA_LDG.H>

#include "fonction/Fcm_fenetre_launch.c"
#include "fonction/graphique/Fcm_select_pixel_xformat.c"


#include "check_fichier.c"
#include "init_surface.c"
#include "init_surface_stram.c"
#include "init_surface_ttram.c"
#include "init_surface_ct60_vram.c"

#include "init_animation_global.c"
#include "init_info_sys.c"

#include "load_animation.c"
#include "init_animation_bee.c"

#include "offscreen_error_code.h"
#include "affiche_error.c"



/* prototype */
int32 init_offscreen( void );




/* Fonction */
int32 init_offscreen( void )
{

	int32    reponse;




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_offscreen()"CRLF);
	log_print(FALSE);
	#endif


	/* 256 couleurs minimum */
	if( Fcm_screen.nb_plan<8 )
	{
		return(OFFSCREEN_ERROR_REZ_256C);
	}


	flag_render_ok=TRUE;



	/* format des pixels reconnu ? */
	if( Fcm_screen.pixel_xformat <= 0 )
	{
		Fcm_select_pixel_xformat();
	}



	/* ---------------------------- */
	/* Couleur pour les masques VDI */
	/* ---------------------------- */
	mask_couleur[0]=1;
	mask_couleur[1]=0;

	if( Fcm_screen.pixel_xformat==PIXEL_8_PACKED || Fcm_screen.pixel_xformat==PIXEL_8_PLAN )
	{
		mask_couleur[0]=0;
		mask_couleur[1]=0;
	}



	Fcm_fenetre_launch( LH_INIT_BOING, LAUNCH_OPEN, LAUNCH_WAIT_NORMAL);



	/* ******************************************************** */
	/* * Init Generale                                        * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_VERIF_FICHIER, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);


	reponse = check_fichier();

	if( reponse != 0 )
	{
		return(reponse);
	}






	/* ******************************************************** */
	/* * Chargement animation                                 * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_CHARGE_ANIM, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);


	reponse= load_animation();

	if( reponse != 0 )
	{
		return(reponse);
	}

	init_animation_bee();





	/* ******************************************************** */
	/* * Open TGA_SA_LDG                                      * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_OUVRE_TGA_LDG, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);

	{
		int16 ldg_version;

		if( open_LDG_TGA(&ldg_version) != 0L )
		{
			flag_render_ok=FALSE;
			return( OFFSCREEN_ERROR_OPEN_TGA_LDG );
		}

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" TGA_SA.LDG version : %04x, (%d)"CRLF, ldg_version, ldg_version );
		log_print(FALSE);
		#endif

	}






	/* ******************************************************** */
	/* * Init Surface                                         * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);

	reponse = init_surface();

	if( reponse != 0L )
	{
		flag_render_ok=FALSE;
	}

	if( surface_offscreen_vdi.handle_offscreen==0 )
	{
		gb_mode_vdi_actif=FALSE;
	}



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);

	reponse = init_surface_stram();

	if( reponse != 0L )
	{
		gb_mode_stram_actif=FALSE;

		affiche_error( OFFSCREEN_ERROR_MODE_STRAM );
	}




	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);

	reponse = init_surface_ttram();

	if( reponse != 0L )
	{
		gb_mode_ttram_actif=FALSE;

		affiche_error( OFFSCREEN_ERROR_MODE_TTRAM );
	}



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);

	reponse = init_surface_ct60_vram();

	if( reponse != 0L )
	{
		gb_mode_ct60_vram_actif=FALSE;
	}




	/* ******************************************************** */
	/* * Fermeture TGA_SA.LDG                                 * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_FERME_TGA_LDG, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);

	close_LDG_TGA();






	/* ******************************************************** */
	/* * Partie graphique OK ?                                * */
	/* ******************************************************** */
	if( flag_render_ok == FALSE )
	{
		return(reponse);
	}




	if( Fcm_screen.h_desktop<600  || Fcm_screen.w_desktop<640)
	{
		gb_mode_vram_actif=FALSE;

		affiche_error(OFFSCREEN_ERROR_REZ_TOO_LITTLE);
	}




	init_animation_global();
	init_info_sys();

	init_rsc();



	/* ******************************************************** */
	/* * Execution module termin‚e                            * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_INIT_TERMINE, LAUNCH_UPDATE, LAUNCH_WAIT_NORMAL);
	Fcm_fenetre_launch( LH_INIT_TERMINE, LAUNCH_CLOSE, LAUNCH_WAIT_NORMAL);






	/* ------------------------- */
	/* Tableau pour l'appl_write */
	/* ------------------------- */

	tube_gem[0]=12345;
	tube_gem[1]=ap_id;
	tube_gem[2]=0;
	tube_gem[3]=0;
	tube_gem[4]=0;
	tube_gem[5]=0;
	tube_gem[6]=0;
	tube_gem[7]=0;




	return 0L;


}

