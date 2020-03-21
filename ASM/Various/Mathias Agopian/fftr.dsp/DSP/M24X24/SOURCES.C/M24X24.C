/* 
 * Programme d'exemple de multiplication
 * 16*16=32 bits au DSP
 *
 * ( Bien sur c'est pas top top rapide, mais c'est
 * pour l'exemple, hein! )
 *
 * (c) 1994 AGOPIAN Mathias
 * pour STMAG
 *
 */

/*
 * Ce programme contient toute la s‚quence
 * de chargement d'un programme dans le DSP.
 *
 */ 
 
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>

unsigned int ability;
unsigned int handle;
unsigned int status;
long size;
char *file="M24X24.LOD";		/* nom du programme DSP */
char *adr;
int i;
long xmem,ymem;
long my_xmem,my_ymem;
int operandes[2];
long resultat[2];
long a;

int main(void)
{
	 
	/*
	 * On r‚serve de la m‚moire
	 * Le buffer doit etre assez grand pour contenir le
	 * programme DSP en mot DSP (24 bits).
	 */
	 
	 adr=Malloc(4096);
	 
	/*
	 * On demande une ability 
	 */
	 		
	ability=Dsp_RequestUniqueAbility();
	
	/*
	 * On met en place quelques variables relatives
	 * au programme DSP
	 * my_xmem est la m‚moire X utilis‚e par le programme
	 * my_ymem est la m‚moire Y utilis‚e par le programme
	 */
	 
	 my_xmem=20;
	 my_ymem=20;
	 
	/*
	 * Le DSP est il libre ?
	 */

	if (!Dsp_Lock())
	{
	
		/*
		 * Est ce que notre programme est 
		 * toujours dans le DSP?
	 	 */
	 
		if (Dsp_GetProgAbility()!=ability)
		{
		
			/*
			 * Non, il faut le recharger
			 *
			 * Mais y a t il assez de m‚moire libre dans le DSP?
			 * Notez que c'est … vous de savoir combient
			 * de m‚moire votre programme a besoin, ici c'est
			 * dans les variables my_xmem pour la m‚moire X et
			 * my_ymem pour la m‚moire Y requise.
			 */
			 
			Dsp_Available(&xmem,&ymem);
			
			/*
			 * Si il n'y a pas assez de m‚moire, alors
			 * il faut expluser les subroutines
			 */
			 
			if ((xmem<my_xmem) || (ymem<my_ymem))
				Dsp_FlushSubroutines();
			
			/*
			 * On peut enfin charger notre programme dans
			 * le DSP. Le programme peut etre un fichier LOD
			 * ou bien du code binaire, dans ce cas, on utilise
			 * Dsp_ExecProg(codeptr,codesize,ability)
			 * char *codeptr
			 * long codesize (en mots DSP (24 bits)
			 * int ability
			 */
			 
			status=Dsp_LoadProg(file,ability,adr);
			
			/*
			 * Il faut maintenant reserver la
			 * m‚moire occup‚e par notre programme
			 * pour etre sur qu'une subroutine ne
			 * viendra pas l'‚craser!
			 */
			 
			Dsp_Reserve(my_xmem,my_ymem);
		}
		
		/*
		 * Maintenant on peut envoyer nos donn‚es
		 * … traiter au DSP, et r‚cupp‚rer le r‚sultat
		 */
		 
		if (!status)
		{
			/*
			 * On fait un exemple sur -4*3
			 * tout le monde sait que ca fait -12.
			 * tout le monde, hein... mais si
			 * -4*3 ca fait -12... si...
			 * Ahhh, ok... pour moi ca a l'air ‚vident, alors
			 * j'insiste, c'est pas trŠs malin...
			 *
			 */
		
			operandes[0]=3;
			operandes[1]=-4;
			Dsp_BlkWords(operandes,2,0,0);
			Dsp_BlkUnpacked(0,0,resultat,2);
			a=resultat[0]+(resultat[1]<<24);
			printf("%d * %d = %ld \n",operandes[0],operandes[1],a);
		}
		else
			printf("Fichier %s introuvable.\n",file);
		
		/*
		 * Enfin on libŠre le DSP
		 */
		 
		Dsp_Unlock();
	}
	else
		printf("Le DSP est occup‚\n");
		
	printf("Appuyez sur une touche\n");
	Bconin(2);
	Mfree(adr);
	return 0;
}

