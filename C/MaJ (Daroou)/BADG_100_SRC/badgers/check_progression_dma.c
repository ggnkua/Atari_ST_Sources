/* **[Badgers]****************** */
/* *                           * */
/* * 04/01/2024 MaJ 04/01/2024 * */
/* ***************************** */

void check_progression_dma( void );




void check_progression_dma( void )
{
	int32 ptr[4];



	Buffptr( &ptr );


	if( ptr[0] > position_sequence_dma[index_sequence_dma] && ptr[0]<position_sequence_dma[index_sequence_dma+1] )
	{
		index_sequence_animation = index_sequence_dma;

		index_sequence_dma++;
		if( index_sequence_dma == (NB_SEQUENCE_ANIMATION-1) )
		{
			index_sequence_dma = 0;
		}
		Setbuffer ( SR_PLAY, position_sequence_dma[index_sequence_dma], position_sequence_dma[index_sequence_dma+1] );
	}


	return;


}

