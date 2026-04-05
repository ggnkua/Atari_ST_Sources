/**[Fonction commune]***************/
/*                                 */
/* 19/05/2018 MaJ 30/07/2020       */
/***********************************/



#ifndef ___Fcm_init_DMA_sound___
#define ___Fcm_init_DMA_sound___



#include "../include/falcon.h"
#include "../audio/Fcm_check_dma_frequence.c"


/* fonction en version alpha */
/* aucun test pour le mode 16 bit, si support ou non */
/* etc... */
/* le mode 16 bit ne fonctionne pas sur falcon, doit manquer une init pour ce mode j'imagine... */

void Fcm_init_DMA_sound( s_MUSIQUE_PLAY *musique );



void Fcm_init_DMA_sound( s_MUSIQUE_PLAY *musique )
{


	Buffoper(0);
	Sndstatus( SND_RESET );


	musique->frequence = Fcm_check_dma_frequence( (int32)musique->frequence );


	if( Fcm_systeme.xbios_sound_mode==XBIOS_SOUND_MODE_STE_TT )
	{
		Devconnect( DMAPLAY, DAC, CLK25M, CLKOLD, 1);

		switch( musique->frequence & 0x00ffffff)
		{
			case 6250:
				Soundcmd( SETPRESCALE, 0);
				break;
			case 12500:
				Soundcmd( SETPRESCALE, 1);
				break;
			case 25000:
				Soundcmd( SETPRESCALE, 2);
				break;
			case 50000:
				Soundcmd( SETPRESCALE, 3);
				break;

			default:
				Soundcmd( SETPRESCALE, 2);
		}
	}
	else
	{
		switch( musique->frequence & 0x00ffffff)
		{
			case 6250:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK8K, 1);
				break;
			case 12500:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK12K, 1);
				break;

			case 25000:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK25K, 1);
				break;

			case 50000:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK50K, 1);
				break;

			default:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK25K, 1);
		}
	}

	Soundcmd( LTATTEN, 0); /* faut-il toucher au niveau sonore ??? */
	Soundcmd( RTATTEN, 0);


	if( musique->stereo != 0 )
	{
		/* Son stéréo */
		switch( musique->rez_bit )
		{
			case 8:
				Setmode( STEREO8  );
				break;
			case 16:
				Setmode( STEREO16 );
				break;

			default:
				Setmode( STEREO8 );
		}
	}
	else
	{
		/* son mono */
		Setmode( MONO8 );
	}



	return;

}

#endif  /* ___Fcm_init_DMA_sound___ */