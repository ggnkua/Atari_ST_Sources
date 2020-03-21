/* Test des DSP subroutines relogeables */
/* La subroutine trie un tableau 100 de mots (24 bits) */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <tos.h>
#include <math.h>

unsigned int ability;
unsigned int handle;
unsigned int status;
long size;
char *file="RELOGE.LOD";
char *codeptr;
size_t nombre[100];
int i;

int quit(int error);

void main(void)
{

	/*
	 * On cr‚e un tableau de nombre al‚atoires
	 */
	 
	for(i=0;i<=99;i++)
		nombre[i]=(long)rand();
		
	/*
	 * Reserve de la place pour le code DSP (1024 mots maximum)
	 */
	 
	codeptr=Malloc(1024*3);

	/*
	 * On demande une ability 
	 */
	 		
	ability=Dsp_RequestUniqueAbility();
	
	/*
	 * On converti le .LOD en code binaire DSP
	 * D‚tail amusant, que je ne m'explique pas, la routine
	 * Dsp_LodToBinary ne se contente pas de convertir le LOD
	 * en binaire, elle ajoute une sorte d'entete de 3 mots DSP
	 * qu'il faut supprimer sans quoi Dsp_LoadSubroutine()
	 * plante completement! Et vous oblige … effectuer un RESET
	 * sans quoi vous resterez scotch‚ dans la ROM du FALCON
	 * au prochain appel!
	 */
	 
	size=Dsp_LodToBinary(file,codeptr);
	codeptr+=9;

	/*
	 * Le DSP est il libre ?
	 * Et la convertion LOD->BIN a t elle r‚ussie?
	 */

	if ((size>0) && (!Dsp_Lock()))
	{
		/* 
		 * On regarde d'abord si une routine correspondant …
		 * notre ability existe d‚ja.
		 */
		
		handle=Dsp_InqSubrAbility(ability);
		
		/*
		 * Si ce n'est pas le cas, il faut recharger la routine
		 */
		
		if (handle==0)
			handle=Dsp_LoadSubroutine(codeptr,size,ability);
			
		/*
		 * Maintenant qu'on a un handle, on peut ex‚cuter la subroutine
		 */ 
		 
		if (handle)
		{
			status=Dsp_RunSubroutine(handle);
			Dsp_BlkUnpacked((long *)nombre,100,(long *)nombre,100);
			
			/*
			 * On affiche le resultat
			 */
			 
			for(i=0;i<=99;i++)
				printf("%lu\n",nombre[i]);
		}
		Dsp_Unlock();
	}
	else
		printf("Le DSP est occup‚ ou le fichier RELOGE.LOD est introuvable.!\n");
		
	printf("Appuyez sur une touche\n");
	Bconin(2);
	Mfree(codeptr);
	quit(0);
}

int quit(int error)
{
	return error;
}
