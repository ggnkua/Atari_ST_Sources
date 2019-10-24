/* 
 * Programme d'exemple sur la maniŠre d'appeler
 * un programme DSP
 *
 * (c) 1994 AGOPIAN Mathias
 * pour STMAG
 *
 * Exemple: Multiplication de matrice (sources DSP motorola)
 * Attention il s'agit de mot au format DSP, c'est … dire:
 * 0x000000 ->  0.0
 * 0x000001 ->  0.0000001
 * 0x7f0000 ->  0.999999
 * 0x800000 -> -1.0
 * 0xffffff -> -0.000001
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>

unsigned int ability;
unsigned int handle;
unsigned int status;
long size;
char *file="MATMUL1.LOD";			/* nom du programme DSP */
char *adr;
int i;
long xmem,ymem;
long my_xmem,my_ymem;

long matrix_A[3];
long matrix_B[9];
long matrix_X[3]={0,0,0};

int quit(int error);

void main(void)
{

	/*
	 * On cr‚e les deux matrices … multiplier
	 * al‚atoirement.
	 */
	 
	 matrix_A[0]=rand();
	 matrix_A[1]=rand();
	 matrix_A[2]=rand();
	 
	 matrix_B[0]=rand();
	 matrix_B[1]=rand();
	 matrix_B[2]=rand();
	 matrix_B[3]=rand();
	 matrix_B[4]=rand();
	 matrix_B[5]=rand();
	 matrix_B[6]=rand();
	 matrix_B[7]=rand();
	 matrix_B[8]=rand();
	 
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
	 
	 my_xmem=0x80;			/* c'est un exemple */
	 my_ymem=0x80;			/* c'est aussi un exemple */
	 
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
			for(i=0;i<3;i++)
				printf("A[1,%d]=%e\n",i+1,(float)matrix_A[i]/0x800000L);
			printf("\n");
			for(i=0;i<3;i++)
				printf("B[1,%d]=%e\t",i+1,(float)matrix_B[i]/0x800000L);
			printf("\n");
			for(i=0;i<3;i++)
				printf("B[2,%d]=%e\t",i+1,(float)matrix_B[i+3]/0x800000L);
			printf("\n");
			for(i=0;i<3;i++)
				printf("B[3,%d]=%e\t",i+1,(float)matrix_B[i+6]/0x800000L);

			Dsp_BlkUnpacked(matrix_A,3,0,0);
			Dsp_BlkUnpacked(matrix_B,9,0,0);
			Dsp_BlkUnpacked(0,0,matrix_X,3);
		
			printf("\n\n");
			for(i=0;i<3;i++)
				printf("X[1,%d]=%e\n",i+1,(float)matrix_X[i]/0x800000L);
		}
		else
			printf("Fichier MATMUL1.LOD introuvable.\n");
		
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
	quit(0);
}

int quit(int error)
{
	return error;
}
