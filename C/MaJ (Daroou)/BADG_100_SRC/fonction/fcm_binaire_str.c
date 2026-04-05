/* ***************************** */
/* *                           * */
/* * 29/03/2015 MaJ 29/03/2015 * */
/* ***************************** */

/* Prototype */
int32 Fcm_binaire_str( char *buffer, int32 data, int16 taille );


/* Fonction */
int32 Fcm_binaire_str( char *buffer, int32 data, int16 taille )
{

	int16 masque=1;
/*	int16 bcl;*/


	buffer[taille]=0;

	for(taille--; taille>=0; taille --)
	{
		if( data & masque )
		{
			buffer[taille]='1';
		}
		else
		{
			buffer[taille]='0';
		}

		masque=masque<<1;

	}







	return 0L;

}
