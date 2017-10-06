/*
 * Aes file selector library interface
 *
 * ++jrb bammi@cadence.com
 * modified: mj -- ntomczak@vm.ucs.ualberta.ca
 * modified: cf -- felsch@tu-harburg.de
 */
#include "gem.h"


int fsel_exinput(char *path, char *file, int *exit_but, char *title)
{
   aes_addrin[0] = (long)path;  
   aes_addrin[1] = (long)file;  
   aes_addrin[2] = (long)title;
	aes_control[0] = 91;
	aes_control[1] = 0;
	aes_control[2] = 2;
	aes_control[3] = 3;
	aes_control[4] = 0;
	aes(&aes_params);
   *exit_but = aes_intout[1];
   return aes_intout[0];
}

int fsel_input(char *path, char *file, int *exit_but)
{
   aes_addrin[0] = (long)path;  
   aes_addrin[1] = (long)file;  
	aes_control[0] = 90;
	aes_control[1] = 0;
	aes_control[2] = 2;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
   *exit_but = aes_intout[1];
   return aes_intout[0];
}


