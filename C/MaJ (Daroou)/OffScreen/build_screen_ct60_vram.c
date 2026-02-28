/* **[Offscreen]**************** */
/* *                           * */
/* * 31/01/2016 MaJ 07/02/2016 * */
/* ***************************** */





/* prototype */
void build_screen_ct60_vram( void );




/* Fonction */
void build_screen_ct60_vram( void )
{




	/* ---------------------------------------- */
	/* Restauration du fond                     */
	/* ---------------------------------------- */
	{
		if( scroll_y < 0 )
		{
			scroll_y=(SCREEN_HEIGHT-1);
		}

		if( scroll_y == 0 )
		{
			vro_cpyfm(vdihandle, 3, pxy_screen, &mfdb_fond_ct60_vram, &mfdb_offscreen_ct60_vram );
		}
		else
		{
			pxy_fond[0]=0;
			pxy_fond[1]=scroll_y;
			pxy_fond[2]=SCREEN_WIDTH-1;
			pxy_fond[3]=SCREEN_HEIGHT-1;

			pxy_fond[4]=0;
			pxy_fond[5]=0;
			pxy_fond[6]=SCREEN_WIDTH-1;
			pxy_fond[7]=SCREEN_HEIGHT-1-scroll_y;

			vro_cpyfm(vdihandle,3,pxy_fond, &mfdb_fond_ct60_vram, &mfdb_offscreen_ct60_vram );


			pxy_fond[0]=0;
			pxy_fond[1]=0;
			pxy_fond[2]=SCREEN_WIDTH-1;
			pxy_fond[3]=scroll_y-1;

			pxy_fond[4]=0;
			pxy_fond[5]=SCREEN_HEIGHT-1 - scroll_y+1;
			pxy_fond[6]=SCREEN_WIDTH-1;
			pxy_fond[7]=SCREEN_HEIGHT-1;

			vro_cpyfm(vdihandle,3,pxy_fond, &mfdb_fond_ct60_vram, &mfdb_offscreen_ct60_vram );
		}

		scroll_y--;
	}






	pxy_bar[0]=0;
	pxy_bar[1]=0;
	pxy_bar[2]=BAR_WIDTH-1;
	pxy_bar[3]=BAR_HEIGHT-1;

	pxy_bar[4]=0;
	pxy_bar[6]=BAR_WIDTH-1;



	/* ---------------------------------------- */
	/* Bar arriŠre plan                         */
	/* ---------------------------------------- */
	{
		int16 idx;

		for( idx=0; idx<NB_BAR; idx++ )
		{
			if( bar_index_y[idx] == NB_BAR_Y )
			{
				bar_sens[idx]=1;
				bar_index_y[idx]=(NB_BAR_Y-2);
			}

			if( bar_index_y[idx] < 0 )
			{
				bar_sens[idx]=0;
				bar_index_y[idx]=1;
			}
		}



		if( bar_index_y[0]<20 && bar_sens[0]==1 )
		{
			for( idx=0; idx<NB_BAR; idx++ )
			{
				if( bar_sens[idx]==1 )
				{
					pxy_bar[5]=position_y[  bar_index_y[idx]  ];
					pxy_bar[7]=pxy_bar[5]+(BAR_HEIGHT-1);
					bar_index_y[idx]--;
					vro_cpyfm(vdihandle,3,pxy_bar, &mfdb_bar_ct60_vram[idx], &mfdb_offscreen_ct60_vram );
				}
			}
		}
		else
		{
			for( idx=(NB_BAR-1); idx>=0; idx-- )
			{
				if( bar_sens[idx]==1 )
				{
					pxy_bar[5]=position_y[  bar_index_y[idx]  ];
					pxy_bar[7]=pxy_bar[5]+(BAR_HEIGHT-1);
					bar_index_y[idx]--;
					vro_cpyfm(vdihandle,3,pxy_bar, &mfdb_bar_ct60_vram[idx], &mfdb_offscreen_ct60_vram );
				}
			}
		}
	}







	/* ------------------------------------------ */
	/* Affichage Bee                              */
	/* ------------------------------------------ */
	{
		int16 idx;

		pxy_bee[0]=0;
		pxy_bee[1]=0;
		pxy_bee[2]=BEE_WIDTH-1;
		pxy_bee[3]=BEE_HEIGHT-1;

		for( idx=0; idx<gb_nb_bee; idx++ )
		{
			pxy_bee[4]=bee_xy[ bee_index_coord[idx] ].x;
			pxy_bee[5]=bee_xy[ bee_index_coord[idx] ].y;
			pxy_bee[6]=pxy_bee[4]+pxy_bee[2];
			pxy_bee[7]=pxy_bee[5]+pxy_bee[3];

			vrt_cpyfm(vdihandle,2,pxy_bee, &mfdb_bee_mask_ct60_vram, &mfdb_offscreen_ct60_vram, mask_couleur );
			vro_cpyfm(vdihandle,7,pxy_bee, &mfdb_bee_ct60_vram, &mfdb_offscreen_ct60_vram );

			bee_index_coord[idx]++;

			/* Gestion du rebouclage de la trajectoire des sprites */
			if( bee_index_coord[idx] > 7337 )
			{
				bee_index_coord[idx]=1285;
			}
		}
	}






	/* ---------------------------------------- */
	/* Bar premier plan                         */
	/* ---------------------------------------- */
	{
		int16 idx;

		if( bar_index_y[NB_BAR-1]<20 && bar_sens[NB_BAR-1]==0 )
		{
			for( idx=0; idx<NB_BAR; idx++ )
			{
				if( bar_sens[idx]==0 )
				{
					pxy_bar[5]=position_y[  bar_index_y[idx]  ];
					pxy_bar[7]=pxy_bar[5]+(BAR_HEIGHT-1);
					bar_index_y[idx]++;
					vro_cpyfm(vdihandle,3,pxy_bar, &mfdb_bar_ct60_vram[idx], &mfdb_offscreen_ct60_vram );
				}
			}
		}
		else
		{
			for( idx=NB_BAR-1; idx>=0; idx-- )
			{
				if( bar_sens[idx]==0 )
				{
					pxy_bar[5]=position_y[  bar_index_y[idx]  ];
					pxy_bar[7]=pxy_bar[5]+(BAR_HEIGHT-1);
					bar_index_y[idx]++;
					vro_cpyfm(vdihandle,3,pxy_bar, &mfdb_bar_ct60_vram[idx], &mfdb_offscreen_ct60_vram );
				}
			}
		}
	}




	return;


}

