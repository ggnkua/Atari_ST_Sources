/* **[Badgers]****************** */
/* *                           * */
/* * 08/11/2023 MaJ 14/11/2023 * */
/* ***************************** */

void set_palette(const int16 action_mode);




#ifndef ___SET_PALETTE_C___
#define ___SET_PALETTE_C___




/*

  action_mode:
  PALETTE_SAVE     : save system palette
  PALETTE_INSTALL  : install app palette
  PALETTE_RESTORE  : restore system palette
  
 */



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
		vs_color( vdihandle, 0, rgb_in ); /* blanc */

		rgb_in[0]=0;
		rgb_in[1]=0;
		rgb_in[2]=0;
		vs_color( vdihandle, 1, rgb_in ); /* noir */


		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(255*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, 2, rgb_in ); /* jaune */

		rgb_in[0]=(0*1000)/255;
		rgb_in[1]=(160*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, 3, rgb_in );  /* vert */


		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(0*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, 4, rgb_in ); /* rouge */

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(200*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, 5, rgb_in ); /* orange */

		rgb_in[0]=(150*1000)/255;
		rgb_in[1]=(255*1000)/255;
		rgb_in[2]=(255*1000)/255;
		vs_color( vdihandle, 6, rgb_in ); /* cyan */

		rgb_in[0]=(255*1000)/255;
		rgb_in[1]=(255*1000)/255;
		rgb_in[2]=(160*1000)/255;
		vs_color( vdihandle, 7, rgb_in ); /* sable 1 */

		rgb_in[0]=(250*1000)/255;
		rgb_in[1]=(250*1000)/255;
		rgb_in[2]=(100*1000)/255;
		vs_color( vdihandle, 8, rgb_in ); /* sable 2 */

		rgb_in[0]=(41*1000)/255;
		rgb_in[1]=(214*1000)/255;
		rgb_in[2]=(255*1000)/255;
		vs_color( vdihandle, 9, rgb_in ); /* ciel */

		rgb_in[0]=(154*1000)/255;
		rgb_in[1]=(41*1000)/255;
		rgb_in[2]=(5*1000)/255;
		vs_color( vdihandle, 10, rgb_in ); /* brun arbre */

		rgb_in[0]=(90*1000)/255;
		rgb_in[1]=(90*1000)/255;
		rgb_in[2]=(90*1000)/255;
		vs_color( vdihandle, 11, rgb_in ); /* gris 1 */

		rgb_in[0]=(130*1000)/255;
		rgb_in[1]=(130*1000)/255;
		rgb_in[2]=(130*1000)/255;
		vs_color( vdihandle, 12, rgb_in ); /* gris 2 */

		rgb_in[0]=(0*1000)/255;
		rgb_in[1]=(60*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, 13, rgb_in );  /* vert 1 */

		rgb_in[0]=(0*1000)/255;
		rgb_in[1]=(130*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, 14, rgb_in );  /* vert 2 */

		rgb_in[0]=(0*1000)/255;
		rgb_in[1]=(190*1000)/255;
		rgb_in[2]=(0*1000)/255;
		vs_color( vdihandle, 15, rgb_in );  /* vert 3 */

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


#endif   /*   ___SET_PALETTE_C___   */ 

