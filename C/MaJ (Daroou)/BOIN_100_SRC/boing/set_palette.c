/* **[boing]******************** */
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
		vs_color( vdihandle, G_WHITE, rgb_in );

		rgb_in[0]=0;
		rgb_in[1]=0;
		rgb_in[2]=0;
		vs_color( vdihandle, G_BLACK, rgb_in );


		rgb_in[0]=(173*1000)/255;
		rgb_in[1]=(0*1000)/255;
		rgb_in[2]=(181*1000)/255;
		vs_color( vdihandle, G_CYAN, rgb_in );

		rgb_in[0]=(173*1000)/255;
		rgb_in[1]=(173*1000)/255;
		rgb_in[2]=(165*1000)/255;
		vs_color( vdihandle, G_LBLACK, rgb_in );

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(0*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, G_RED, rgb_in );

		rgb_in[0]=(226*1000)/255;
		rgb_in[1]=(148*1000)/255;
		rgb_in[2]=(144*1000)/255;
		vs_color( vdihandle, G_LMAGENTA, rgb_in );



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

