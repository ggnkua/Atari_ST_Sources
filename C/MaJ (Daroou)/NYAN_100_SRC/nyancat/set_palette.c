/* **[nyancat]****************** */
/* *                           * */
/* * 08/11/2023 MaJ 08/11/2023 * */
/* ***************************** */


void set_palette(const int16 action_mode);



/*

  action_mode:
  PALETTE_SAVE     : save system palette
  PALETTE_INSTALL  : install app palette
  PALETTE_RESTORE  : restore system palette
  
 */


/* Fonction */
void set_palette(const int16 action_mode)
{
	
	#ifdef LOG_FILE
	sprintf( buf_log, "# set_palette()"CRLF );
	log_print(FALSE);
	#endif

	if( action_mode == PALETTE_SAVE )
	{
		int16 idx;
		int16  rgb_in[3];
		int16 reponse;

#ifdef LOG_FILE
sprintf( buf_log, " => PALETTE_SAVE"CRLF );
log_print(FALSE);
#endif

		global_palette_save=TRUE;
		
		for( idx=0; idx<PALETTE_NB_COULEUR; idx++ )
		{			
			reponse = vq_color( vdihandle, idx, 1, rgb_in);

			if( reponse != -1 )
			{
				global_palette[idx][0]=rgb_in[0];
				global_palette[idx][1]=rgb_in[1];
				global_palette[idx][2]=rgb_in[2];
			}
			else
			{
				global_palette[idx][0]=-1;
			}
		}
		return;
	}

	if( action_mode == PALETTE_INSTALL )
	{
		int16  rgb_in[3];

#ifdef LOG_FILE
sprintf( buf_log, " => PALETTE_INSTALL"CRLF );
log_print(FALSE);
#endif

		rgb_in[0]=1000;
		rgb_in[1]=1000;
		rgb_in[2]=1000;
		vs_color( vdihandle, 0, rgb_in );

		rgb_in[0]=0;
		rgb_in[1]=0;
		rgb_in[2]=0;
		vs_color( vdihandle, 1, rgb_in );


		rgb_in[0]=(165*1000)/255;
		rgb_in[1]=(165*1000)/255;
		rgb_in[2]=(165*1000)/255;
		vs_color( vdihandle, 2, rgb_in );

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(165*1000)/255;
		rgb_in[2]=(255*1000)/255;
		vs_color( vdihandle, 3, rgb_in );

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(16*1000)/255;
		rgb_in[2]=(16*1000)/255;
		vs_color( vdihandle, 4, rgb_in );

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(165*1000)/255;
		rgb_in[2]=(8*1000)/255;
		vs_color( vdihandle, 5, rgb_in );

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(255*1000)/255;
		rgb_in[2]=(8*1000)/255;
		vs_color( vdihandle, 6, rgb_in );

		rgb_in[0]=(66*1000)/255;
		rgb_in[1]=(255*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, 7, rgb_in );

		rgb_in[0]=(16*1000)/255;
		rgb_in[1]=(173*1000)/255;
		rgb_in[2]=(247*1000)/255;
		vs_color( vdihandle, 8, rgb_in );

		rgb_in[0]=(115*1000)/255;
		rgb_in[1]=(66*1000)/255;
		rgb_in[2]=(255*1000)/255;
		vs_color( vdihandle, 9, rgb_in );

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(206*1000)/255;
		rgb_in[2]=(156*1000)/255;
		vs_color( vdihandle, 10, rgb_in );

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(49*1000)/255;
		rgb_in[2]=(156*1000)/255;
		vs_color( vdihandle, 11, rgb_in );

		rgb_in[0]=(107*1000)/255;
		rgb_in[1]=(0*1000)/255;
		rgb_in[2]=(74*1000)/255;
		vs_color( vdihandle, 12, rgb_in );

		rgb_in[0]=(181*1000)/255;
		rgb_in[1]=(0*1000)/255;
		rgb_in[2]=(148*1000)/255;
		vs_color( vdihandle, 13, rgb_in );

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(0*1000)/255;
		rgb_in[2]=(222*1000)/255;
		vs_color( vdihandle, 14, rgb_in );

		rgb_in[0]=(16*1000)/255;
		rgb_in[1]=(66*1000)/255;
		rgb_in[2]=(115*1000)/255;
		vs_color( vdihandle, 15, rgb_in );

		return;
	}



	if( action_mode == PALETTE_RESTORE )
	{
		int16 idx;
		int16  rgb_in[3];

#ifdef LOG_FILE
sprintf( buf_log, " => PALETTE_RESTORE"CRLF );
log_print(FALSE);
#endif

		for( idx=0; idx<PALETTE_NB_COULEUR; idx++ )
		{
			if( global_palette[idx][0] != -1 )
			{
				rgb_in[0]=global_palette[idx][0];
				rgb_in[1]=global_palette[idx][1];
				rgb_in[2]=global_palette[idx][2];

				vs_color( vdihandle, idx, rgb_in );
			}
		}

		return;
	}



	return;

}

