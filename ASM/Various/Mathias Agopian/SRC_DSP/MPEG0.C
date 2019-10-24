#include <string.h>
#include <stdio.h>
#include <ext.h>
#include <tos.h>
#include <aes.h>

#include "defines.h"
#include "decoder.h"

void force_ext(char *name,long ext);

char *default_filename="fr_gall.mpg";

int ap_id;

int main(int argc,char *argv[])
{
	char *filename;
	
	ap_id=appl_init();

	if (argc>1)		filename=argv[1];
	else			filename=default_filename;
	
	if (init_dsp())
	{
		printf("\nD‚codeur MPEG st‚r‚o 32Khz");
		printf("\n(c) 1995, AGOPIAN Mathias");
		printf("\nPour STMAG.");
		printf("\n\nFichier: %s\n",filename);
		init_mpeg_decoder();
		decode_mpeg_sequence(filename);
		Dsp_Unlock();
	}

	appl_exit();
	return 0;
}

void force_ext(char *name,long ext)
{
	char *extension=name+strlen(name)-1;
	*extension--=(char)(ext & 0xff);	ext>>=8;
	*extension--=(char)(ext & 0xff);	ext>>=8;
	*extension--=(char)(ext & 0xff);	ext>>=8;
	*extension=(char)(ext & 0xff);
}
