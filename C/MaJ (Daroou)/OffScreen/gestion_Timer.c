/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 31/12/2015 * */
/* ***************************** */




#include "affiche_screen.c"




/* Fonction */
void gestion_timer( void )
{
	static uint32 old_timer_fps=0;
/*	static  int16 frame_cpt=0;*/





	{
		uint32 timer = Fcm_get_timer();






{
/*
	char texte[256];

	sprintf(texte,"timer=%ld  old_timer_fps=%ld   %ld  ", timer, old_timer_fps, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,2*16,texte);

	sprintf(texte,"gb_stats_stram_ecran=%ld  gb_stats_ttram_ecran=%ld   %ld  ", gb_stats_stram_ecran, gb_stats_ttram_ecran, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,3*16,texte);

	sprintf(texte,"gb_stats_vdi_ecran=%ld  gb_stats_stram_stram=%ld   %ld  ", gb_stats_vdi_ecran, gb_stats_stram_stram, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,4*16,texte);

	sprintf(texte,"gb_stats_ttram_ttram=%ld  gb_stats_vdi_vdi=%ld   %ld  ", gb_stats_ttram_ttram, gb_stats_vdi_vdi, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,5*16,texte);

	sprintf(texte,"gb_stats_vdi_vdi2=%ld  gb_stats_ecran_ecran=%ld   %ld  ", timer, old_timer_fps, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,6*16,texte);

	sprintf(texte,"gb_stats_mode_vdi_fps=%ld  gb_stats_mode_vdi_bp=%ld   %ld  ", gb_stats_mode_vdi_fps, gb_stats_mode_vdi_bp, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,7*16,texte);

	sprintf(texte,"gb_stats_mode_vram_fps=%ld  gb_stats_mode_vram_bp=%ld   %ld  ", gb_stats_mode_vram_fps, gb_stats_mode_vram_bp, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,8*16,texte);

	sprintf(texte,"gb_stats_mode_stram_fps=%ld  gb_stats_mode_stram_bp=%ld   %ld  ", gb_stats_mode_stram_fps, gb_stats_mode_stram_bp, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,9*16,texte);

	sprintf(texte,"gb_stats_mode_ttram_fps=%ld  gb_stats_mode_ttram_bp=%ld   %ld  ", gb_stats_mode_ttram_fps, gb_stats_mode_ttram_bp, timer-old_timer_fps );
	v_gtext(vdihandle,1*8,10*16,texte);

*/

/*{
	int16 xyarr[8];
	int8 bezarr[8];
	int16 extent[8];
	int16 totpts[8];
	int16 totmoves[8];



   v_bez_fill( vdihandle, 3, xyarr, bezarr, extent, totpts, totmoves);
}*/

}




		/* une seconde s'est ‚coul‚ ? */
		if( (timer-old_timer_fps) >= 200 )
		{



			/* init premier passage */
			if( old_timer_fps==0 )
			{
				old_timer_fps=timer-200;
			}


			/* Mise a jour des stats */
			if( h_win[W_STATS] > 0 && win_iconified[W_STATS]!=TRUE )
			{
				OBJECT	*adr_formulaire;


/*				octet_total = octet_total + (octet_par_frame*frame_cpt);*/



				rsrc_gaddr( R_TREE, DL_STATS, &adr_formulaire );

				sprintf( (adr_formulaire+TXT_STAT_FPS   )->ob_spec.free_string, "%ld",  gb_frame_fps    );
				sprintf( (adr_formulaire+TXT_STAT_REDRAW)->ob_spec.free_string, "%lu", octet_redraw );
				sprintf( (adr_formulaire+TXT_STAT_TOTALE)->ob_spec.free_string, "%lu", octet_total  );
				sprintf( (adr_formulaire+TXT_STAT_TRANS )->ob_spec.free_string, "%lu Mo/s", (octet_total/1048576UL) );

				Fcm_objet_draw( adr_formulaire, h_win[W_STATS], FD_STAT_FPS,    0 );
				Fcm_objet_draw( adr_formulaire, h_win[W_STATS], FD_STAT_REDRAW, 0 );
				Fcm_objet_draw( adr_formulaire, h_win[W_STATS], FD_STAT_TOTALE, 0 );
				Fcm_objet_draw( adr_formulaire, h_win[W_STATS], FD_STAT_TRANS,  0 );
			}



			switch( offscreen_mode )
			{
				case RB_STAT_OFF_VDI:
					gb_stats_mode_vdi_fps = MAX( gb_stats_mode_vdi_fps , gb_frame_fps );
					gb_stats_mode_vdi_bp  = MAX( gb_stats_mode_vdi_bp, (octet_total/1048576) );
/*					gb_stats_mode_vdi_fps=gb_frame_fps;
					gb_stats_mode_vdi_bp=(octet_total/1048576);*/
					break;

				case RB_STAT_OFF_VRAM:
					gb_stats_mode_vram_fps = MAX( gb_stats_mode_vram_fps, gb_frame_fps );
					gb_stats_mode_vram_bp  = MAX( gb_stats_mode_vram_bp, (octet_total/1048576) );
/*					gb_stats_mode_vram_fps=gb_frame_fps;
					gb_stats_mode_vram_bp=(octet_total/1048576);*/
					break;

				case RB_STAT_OFF_STRM:
					gb_stats_mode_stram_fps = MAX( gb_stats_mode_stram_fps, gb_frame_fps );
					gb_stats_mode_stram_bp  = MAX( gb_stats_mode_stram_bp, (octet_total/1048576) );
/*					gb_stats_mode_stram_fps=gb_frame_fps;
					gb_stats_mode_stram_bp=(octet_total/1048576);*/
					break;

				case RB_STAT_OFF_TTRM:
					gb_stats_mode_ttram_fps = MAX( gb_stats_mode_ttram_fps, gb_frame_fps );
					gb_stats_mode_ttram_bp  = MAX( gb_stats_mode_ttram_bp,(octet_total/1048576) );
/*					gb_stats_mode_ttram_fps=gb_frame_fps;
					gb_stats_mode_ttram_bp=(octet_total/1048576);*/
					break;
			}


/*{
	char texte[256];

	sprintf(texte,"gb_stats_mode_vdi_fps=%ld gb_stats_mode_vram_fps=%ld gb_stats_mode_stram_fps=%ld gb_stats_mode_ttram_fps=%ld      ", gb_stats_mode_vdi_fps, gb_stats_mode_vram_fps, gb_stats_mode_stram_fps,gb_stats_mode_ttram_fps  );
	v_gtext(vdihandle,10*8,2*16,texte);
	sprintf(texte,"gb_stats_mode_vdi_bp=%ld gb_stats_mode_vram_bp=%ld gb_stats_mode_stram_bp=%ld gb_stats_mode_ttram_bp=%ld      ", gb_stats_mode_vdi_bp, gb_stats_mode_vram_bp, gb_stats_mode_stram_bp,gb_stats_mode_ttram_bp  );
	v_gtext(vdihandle,10*8,3*16,texte);
}*/



			old_timer_fps = Fcm_get_timer(); /*timer;*/ /*old_timer_fps+200;*/
			gb_frame_fps  = 0;
			octet_total   = 0;
			octet_redraw  = 0;


		}
	}



	pf_build_screen();
	affiche_screen();

	gb_frame_fps++;


	octet_total = octet_total + octet_par_frame;



	appl_write( ap_id, 16, tube_gem);


/*	evnt_timer(1000);*/



/*
	{
		int16 pxy_fond[8];

			pxy_fond[0]=0;
			pxy_fond[1]=0;
			pxy_fond[2]=SCREEN_WIDTH-1;
			pxy_fond[3]=SCREEN_HEIGHT-1;

			pxy_fond[4]=0;
			pxy_fond[5]=0;
			pxy_fond[6]=SCREEN_WIDTH-1;
			pxy_fond[7]=SCREEN_HEIGHT-1;

			vro_cpyfm(vdihandle,3,pxy_fond, &mfdb_offscreen_vdi, &Fcm_mfdb_ecran );
	}


{
	char texte[256];

	sprintf(texte,"mfdb vdi:%8lx   mfdb offscreen:%8lx     ", (uint32)mfdb_offscreen_vdi.fd_addr, (uint32)mfdb_offscreen.fd_addr );
	v_gtext(vdihandle,82*8,2*16,texte);
}
*/




	return;


}

