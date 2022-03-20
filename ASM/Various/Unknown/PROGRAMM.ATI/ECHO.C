 
#include <stdio.h>
#include <tos.h>

unsigned int ability;
unsigned int handle;
unsigned int status;
long size;
char *file="ECHO.LOD";		/* nom du programme DSP */
char *adr;
int i;

int main(void)
{
	adr=Malloc(4096);
	if (adr)
	{
		ability=Dsp_RequestUniqueAbility();
		status=Dsp_LoadProg(file,ability,adr);
		if (!status)
		{
			dsptristate(1,1);
			devconnect(3,2,0,1,1);
			devconnect(1,8,0,1,1);
			setmode(1);
			settracks(0,0);
			soundcmd(4,2);
			soundcmd(5,0);
		}
		else
		{
			printf("Fichier %s introuvable.\n",file);
			Bconin(2);
		}
			
		Mfree(adr);
	}
	return 0;
}
