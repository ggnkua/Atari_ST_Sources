/*
 * Aes scrap interface
 *
 * ++fgth	ridderbusch.pad@nixdorf.com
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int scrp_clear(void)
{
   aes_control[0] = 82;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 0;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int scrp_read(char *Scrappath)
{
	aes_addrin[0] = (long)Scrappath;
   aes_control[0] = 80;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}


int scrp_write(char *Scrappath)
{
	aes_addrin[0] = (long)Scrappath;
   aes_control[0] = 81;
   aes_control[1] = 0;
   aes_control[2] = 1;
   aes_control[3] = 1;
   aes_control[4] = 0;
   aes(&aes_params);
	return aes_intout[0];
}
