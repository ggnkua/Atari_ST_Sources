/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 16/12/2015 * */
/* ***************************** */





/* prototype */
void build_screen_vram( void );




/* Fonction */
void build_screen_vram( void )
{
	int16 winx;
	int16 winy;



	{
		int16 dummy;

		/* on cherche les coordonn‚es de la fenˆtre */
		wind_get(h_win[W_SPRITE_OFFSCREEN],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);
	}

/*			pxy_fond[0]=winx + 0;
			pxy_fond[1]=winy + SCREEN_HEIGHT;
			pxy_fond[2]=pxy_fond[0] + SCREEN_WIDTH-1;
			pxy_fond[3]=winy + SCREEN_HEIGHT + SCREEN_HEIGHT - 1;

			pxy_fond[4]=winx;
			pxy_fond[5]=winy;
			pxy_fond[6]=pxy_fond[4]+SCREEN_WIDTH-1;
			pxy_fond[7]=pxy_fond[5]+SCREEN_HEIGHT-1;

			vro_cpyfm(vdihandle,3,pxy_fond, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );
			return;
*/


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
			pxy_fond[0]=winx + 0;
			pxy_fond[1]=winy + SCREEN_HEIGHT;
			pxy_fond[2]=pxy_fond[0] + SCREEN_WIDTH-1;
			pxy_fond[3]=winy + SCREEN_HEIGHT + SCREEN_HEIGHT - 1;

			pxy_fond[4]=winx;
			pxy_fond[5]=winy;
			pxy_fond[6]=pxy_fond[4]+SCREEN_WIDTH-1;
			pxy_fond[7]=pxy_fond[5]+SCREEN_HEIGHT-1;

			vro_cpyfm(vdihandle,3,pxy_fond, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );

		}
		else
		{
			pxy_fond[0]=winx + 0;
			pxy_fond[1]=winy + SCREEN_HEIGHT + scroll_y;
			pxy_fond[2]=pxy_fond[0] + SCREEN_WIDTH - 1;
			pxy_fond[3]=winy + SCREEN_HEIGHT + SCREEN_HEIGHT - 1;

			pxy_fond[4]=winx;
			pxy_fond[5]=winy;
			pxy_fond[6]=pxy_fond[4] + SCREEN_WIDTH - 1;
			pxy_fond[7]=pxy_fond[5] + SCREEN_HEIGHT - 1 - scroll_y;

			vro_cpyfm(vdihandle,3,pxy_fond, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );



			pxy_fond[0]=winx + 0;
			pxy_fond[1]=winy + SCREEN_HEIGHT + 0;
			pxy_fond[2]=pxy_fond[0] + SCREEN_WIDTH - 1;
			pxy_fond[3]=winy + SCREEN_HEIGHT + scroll_y - 1;

			pxy_fond[4]=winx + 0;
			pxy_fond[5]=winy + SCREEN_HEIGHT - 1 - scroll_y + 1;
			pxy_fond[6]=pxy_fond[4] + SCREEN_WIDTH - 1;
			pxy_fond[7]=winy + SCREEN_HEIGHT - 1;

			vro_cpyfm(vdihandle,3,pxy_fond, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );

		}

		scroll_y--;
	}




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
					pxy_bar[0]=winx+0;
					pxy_bar[1]=winy+0+400+(BAR_HEIGHT*idx);
					pxy_bar[2]=pxy_bar[0]+BAR_WIDTH-1;
					pxy_bar[3]=pxy_bar[1]+BAR_HEIGHT-1;

					pxy_bar[4]=winx+0;
					pxy_bar[5]=winy+position_y[  bar_index_y[idx]  ];
					pxy_bar[6]=pxy_bar[4]+BAR_WIDTH-1;
					pxy_bar[7]=pxy_bar[5]+(BAR_HEIGHT-1);

					vro_cpyfm(vdihandle,3,pxy_bar, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );
					bar_index_y[idx]--;

				}
			}
		}
		else
		{
			for( idx=(NB_BAR-1); idx>=0; idx-- )
			{
				if( bar_sens[idx]==1 )
				{
					pxy_bar[0]=winx+0;
					pxy_bar[1]=winy+0+400+(BAR_HEIGHT*idx);
					pxy_bar[2]=pxy_bar[0]+BAR_WIDTH-1;
					pxy_bar[3]=pxy_bar[1]+BAR_HEIGHT-1;

					pxy_bar[4]=winx+0;
					pxy_bar[5]=winy+position_y[  bar_index_y[idx]  ];
					pxy_bar[6]=pxy_bar[4]+BAR_WIDTH-1;
					pxy_bar[7]=pxy_bar[5]+(BAR_HEIGHT-1);

					vro_cpyfm(vdihandle,3,pxy_bar, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );

					bar_index_y[idx]--;
				}
			}
		}
	}







	/* ------------------------------------------ */
	/* Affichage Bee                              */
	/* ------------------------------------------ */
/*	{
		int16 rndx;
		int16 rndy;

		rndx=rand() % 10;
		rndy=rand() % 10;

		pxy_bee[0]=0;
		pxy_bee[1]=0;
		pxy_bee[2]=BEE_WIDTH-1;
		pxy_bee[3]=BEE_HEIGHT-1;

		pxy_bee[4]=winx + 128+ rndx;
		pxy_bee[5]=winy +  72+ rndy;
		pxy_bee[6]=pxy_bee[4]+(BEE_WIDTH -1);
		pxy_bee[7]=pxy_bee[5]+(BEE_HEIGHT-1);

		vrt_cpyfm(vdihandle,2,pxy_bee, &mfdb_bee_mask, &Fcm_mfdb_ecran, mask_couleur );


		pxy_bee[0]=winx+0;
		pxy_bee[1]=winy+498;
		pxy_bee[2]=winx+BEE_WIDTH-1;
		pxy_bee[3]=winy+498+BEE_HEIGHT-1;


		pxy_bee[4]=winx + 128+ rndx;
		pxy_bee[5]=winy +  72+ rndy;
		pxy_bee[6]=pxy_bee[4]+(BEE_WIDTH -1);
		pxy_bee[7]=pxy_bee[5]+(BEE_HEIGHT-1);

		vro_cpyfm(vdihandle,7,pxy_bee, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );
	}*/






	/* ------------------------------------------ */
	/* Affichage Bee                              */
	/* ------------------------------------------ */
	{

		int16 idx;

/*{
	char texte[256];

	sprintf(texte,"index_coord=%d      ", index_coord  );
	v_gtext(vdihandle,2*8,2*16,texte);
}*/

/*		pxy_bee[0]=0;
		pxy_bee[1]=0;
		pxy_bee[2]=BEE_WIDTH-1;
		pxy_bee[3]=BEE_HEIGHT-1;*/

/*		pxy_bee[4]=128+ (rand() % 10);
		pxy_bee[5]= 72+ (rand() % 10);
		pxy_bee[6]=pxy_bee[4]+(BEE_WIDTH -1);
		pxy_bee[7]=pxy_bee[5]+(BEE_HEIGHT-1);

		vrt_cpyfm(offscreenhandle,2,pxy_bee, &mfdb_bee_mask, &mfdb_offscreen_vdi, mask_couleur );
		vro_cpyfm(offscreenhandle,7,pxy_bee, &mfdb_bee, &mfdb_offscreen_vdi );
*/


		for( idx=0; idx<gb_nb_bee; idx++ )
		{

/*{
	char texte[256];

	sprintf(texte,"bee_index_coord[idx]=%d    x=%d y=%d  ", bee_index_coord[idx], bee_xy[ bee_index_coord[idx] ].x, bee_xy[ bee_index_coord[idx] ].y  );
	v_gtext(vdihandle,2*8,(2+idx)*16,texte);
}*/
		pxy_bee[0]=0;
		pxy_bee[1]=0;
		pxy_bee[2]=BEE_WIDTH-1;
		pxy_bee[3]=BEE_HEIGHT-1;

		pxy_bee[4]=winx + bee_xy[ bee_index_coord[idx] ].x;
		pxy_bee[5]=winy + bee_xy[ bee_index_coord[idx] ].y;
		pxy_bee[6]=pxy_bee[4]+(BEE_WIDTH -1);
		pxy_bee[7]=pxy_bee[5]+(BEE_HEIGHT-1);

		vrt_cpyfm(vdihandle,2,pxy_bee, &mfdb_bee_mask, &Fcm_mfdb_ecran, mask_couleur );



		pxy_bee[0]=winx+0;
		pxy_bee[1]=winy+498;
		pxy_bee[2]=winx+BEE_WIDTH-1;
		pxy_bee[3]=winy+498+BEE_HEIGHT-1;

		pxy_bee[4]=winx + bee_xy[ bee_index_coord[idx] ].x;
		pxy_bee[5]=winy + bee_xy[ bee_index_coord[idx] ].y;
		pxy_bee[6]=pxy_bee[4]+(BEE_WIDTH -1);
		pxy_bee[7]=pxy_bee[5]+(BEE_HEIGHT-1);

		vro_cpyfm(vdihandle,7,pxy_bee, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );



/*			pxy_bee[4]=bee_xy[ bee_index_coord[idx] ].x;
			pxy_bee[5]=bee_xy[ bee_index_coord[idx] ].y;
			pxy_bee[6]=pxy_bee[4]+pxy_bee[2];
			pxy_bee[7]=pxy_bee[5]+pxy_bee[3];

			vrt_cpyfm(offscreenhandle,2,pxy_bee, &mfdb_bee_mask, &mfdb_offscreen_vdi, mask_couleur );
			vro_cpyfm(offscreenhandle,7,pxy_bee, &mfdb_bee, &mfdb_offscreen_vdi );
*/
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
					pxy_bar[0]=winx+0;
					pxy_bar[1]=winy+0+400+(BAR_HEIGHT*idx);
					pxy_bar[2]=pxy_bar[0]+BAR_WIDTH-1;
					pxy_bar[3]=pxy_bar[1]+BAR_HEIGHT-1;

					pxy_bar[4]=winx+0;
					pxy_bar[5]=winy+position_y[  bar_index_y[idx]  ];
					pxy_bar[6]=pxy_bar[4]+BAR_WIDTH-1;
					pxy_bar[7]=pxy_bar[5]+(BAR_HEIGHT-1);

					vro_cpyfm(vdihandle,3,pxy_bar, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );

					bar_index_y[idx]++;
				}
			}
		}
		else
		{
			for( idx=NB_BAR-1; idx>=0; idx-- )
			{
				if( bar_sens[idx]==0 )
				{
					pxy_bar[0]=winx+0;
					pxy_bar[1]=winy+0+400+(BAR_HEIGHT*idx);
					pxy_bar[2]=pxy_bar[0]+BAR_WIDTH-1;
					pxy_bar[3]=pxy_bar[1]+BAR_HEIGHT-1;

					pxy_bar[4]=winx+0;
					pxy_bar[5]=winy+position_y[  bar_index_y[idx]  ];
					pxy_bar[6]=pxy_bar[4]+BAR_WIDTH-1;
					pxy_bar[7]=pxy_bar[5]+(BAR_HEIGHT-1);

					vro_cpyfm(vdihandle,3,pxy_bar, &Fcm_mfdb_ecran, &Fcm_mfdb_ecran );

					bar_index_y[idx]++;
				}
			}
		}

	}



	return;


}

