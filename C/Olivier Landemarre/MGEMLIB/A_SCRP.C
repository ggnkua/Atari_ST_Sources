/*
 * Aes scrap interface
 *
 * ++fgth	ridderbusch.pad@nixdorf.com
 * modified: cf -- felsch@tu-harburg.de
 * modified: ol -- olivier.landemarre.free.fr
 */
#include "mgem.h"


int mt_scrp_clear( INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={82,0,1,0,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef scrp_clear
#undef scrp_clear
#endif
int scrp_clear()
{
	return(mt_scrp_clear(aes_global));
}


int mt_scrp_read(char *Scrappath, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={80,0,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_addrin[0] = (long)Scrappath;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef scrp_read
#undef scrp_read
#endif
int scrp_read(char *Scrappath)
{
	return(mt_scrp_read(Scrappath, aes_global));
}

int mt_scrp_write(char *Scrappath, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={81,0,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
	aes_addrin[0] = (long)Scrappath;

	aes(&aes_params);

	return aes_intout[0];
}

#ifdef scrp_write
#undef scrp_write
#endif
int scrp_write(char *Scrappath)
{
	return(mt_scrp_write(Scrappath, aes_global));
}
