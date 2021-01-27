#define EMULATOR     -1
#define ATARI_ST     0    
#define ATARI_STE    1 
#define ATARI_BOOK   2    
#define ATARI_MSTE   3     
#define ATARI_TT     4      
#define ATARI_F030   5   
#define MEDUSA       6   
#define HADES        7
#define SPARROW			 8												 /* [GS]									 */
#define MILAN 			 9												 /* [GS]									 */
#define ARANYM 			10												 /* [GS]									 */

WORD get_mch( VOID )
{
	REG WORD i=ATARI_ST;
	LONG cv;

	if( GetCookie( 'hade',NULL ) )               /* Hades 040/060          */
		return( HADES );

	if( GetCookie( '_MCH',&cv ) )               
	{
		if( cv == -1L )                           /* Emulator                */
		{
			i = EMULATOR;
		}
		else if( (WORD)cv == 0x4D34 )             /* Medusa 040/060          */
		{
			i = MEDUSA;                  
		}
		else
		{
			switch( (WORD)(cv >> 16) )                 
			{
				case 1 :                             /* STE/BOOK/MSTE           */
				{
					i = ATARI_STE;                  
					if( (WORD)cv == 1 )  i = ATARI_BOOK;                  
					if( (WORD)cv == 16 ) i = ATARI_MSTE;                  
					if( (WORD)cv == 0x100 ) i = SPARROW;	/* [GS]								*/
					break;
				}

				case 2 :                            /* TT                     */
				{
					i = ATARI_TT; break;
				}

				case 3 :                            /* Falcon                 */ 
				{
					i = ATARI_F030; break;
				}

				case 4 :                            /* Milan  [GS]	          */ 
				{
					i = MILAN; break;
				}

				case 5 :                            /* ARAnyM  [GS]	          */ 
				{
					i = ARANYM; break;
				}

				default : break;
			}
		}
	}

	return( i );
}
