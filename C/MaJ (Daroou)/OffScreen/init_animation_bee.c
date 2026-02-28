/* **[Offscreen]**************** */
/* *                           * */
/* * 08/01/2016 MaJ 09/01/2016 * */
/* ***************************** */



#ifndef ___init_animation_bee___
#define ___init_animation_bee___



/* prototype */
void init_animation_bee( void );



/* Fonction */
void init_animation_bee( void )
{


	/* position BEE */
/*	pxy_bee[0]=0;
	pxy_bee[1]=0;
	pxy_bee[2]=BEE_WIDTH-1;
	pxy_bee[3]=BEE_HEIGHT-1;*/



	{
		int16  idx;
		uint16 base;
/*		uint16 max;*/

/*max=0;*/

		base=bee_index_coord[0];

		for( idx=0; idx<NB_BEE_MAX; idx++ )
		{
			bee_index_coord[idx]=base + (gb_decalage_bee*idx);

			if( bee_index_coord[idx] > 7337 )
			{
				bee_index_coord[idx]=bee_index_coord[idx]-6052; /* -7337 + 1285 */

				while( bee_index_coord[idx] > 7337 )
				{
					bee_index_coord[idx] = bee_index_coord[idx] - 7337;
				}
			}


/*max=MAX(max, bee_index_coord[idx] );*/


/*	{
		char texte[256];


		sprintf(texte,"bee_index_coord[idx]=%5d  max=%d  bee_index_coord[0]=%d   ", bee_index_coord[idx], max, bee_index_coord[0] );
		v_gtext(vdihandle,60*8,3*16, texte);
	}*/



		}

	}




	return;


}


#endif   /* ___init_animation_bee___ */

