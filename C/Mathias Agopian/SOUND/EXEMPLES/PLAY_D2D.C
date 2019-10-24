
/* Exemple d'utilisation du driver Sonore pour SpeedoGDOS */

#include <stdio.h>
#include <string.h>
#include <ext.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "bindings.h"

int open_work(int);
int ap_id;

int main(int argc,char *argv[])
{
	int handle;
	int res,ver;
	char name[28];
	
	ap_id=appl_init();	/* Donne moi un identificateur d'application */
	
	if (argc>1)					/* Est ce qu'on a re‡u un nom en parametre? */
	{ 
		handle=open_work(111); /* Alors ouvre la station de travail 111 */
		
		if (handle>0)					/* L'ouverture c'est bien pass‚? */
		{
			vq_driver_info(handle,&res,&ver,&res,&res,name);	/* Affiche le nom du driver */
			printf("\n%s version %04x\n",name,ver);
	
			if(vspl_load_d2d(handle,argv[1],0))	/* Chargement du fichier son ok? */
			{
				vspl_play_d2d(handle);					/* Commence a jouer */
				while(buffoper(-1) & 0x1)				/* C'est pas fini ? */
				{
					printf("\r %9lu ",vqspl_position_d2d(handle)); /* Affiche la position */			
					if (vqspl_status_d2d(handle)) /* Status du system sonore ok? */
						vspl_make_d2d(handle);			/* Alors continue */
					if (kbhit())							/* A t'on appuy‚ sur une touche? */
					{
						getch();							/* Oui alors on arrˆte */
						break;
					}
				}
				vspl_stop_d2d(handle);		/* On arrete de joue */
				vspl_unload_d2d(handle);	/* On libere la memoire */
			}

			v_clrwk(handle);					/* on r‚initialise le driver */
			v_clswk(handle);				/* et on le ferme */
		}
		else
		{
			printf("Impossible d'ouvrir la station de travail!\n");
			printf("Open workstation is not possible!\n");
			getchar();
		}
	}
	else
	{
		printf("\nVeuillez faire glisser un fichier son sur ce programme");
		printf("\nAppuyez sur une touche...");
		printf("\nPlease drag a sound file on this program");
		printf("\nHit any key...");
		getchar();
	} 
	appl_exit();
	return 0;
}

int open_work(int dev)
{
/****************************************************************
	Routine d'ouverture de la Station de travail sur un p‚riph‚rique
****************************************************************/
	
/****************************************************************
	 ATTENTION! Respectez l'ordre exact de ce qui suit 
*****************************************************************/

	int h;
	register int i;
	for (i=0;i<10;_VDIParBlk.intin[i++]=1);	
	_VDIParBlk.intin[0]=dev;
	_VDIParBlk.intin[10]=2;
	v_opnwk(_VDIParBlk.intin,&h,_VDIParBlk.intout);

	if(h>0)				/* Est ce que l'ouverture de la station de travail est ok? */
	{
		if(*(long *)_VDIParBlk.intout=='SMPL') /* Est ce le driver direct to disk? */
		{
			printf(" Maximum of bits   : %d\n",_VDIParBlk.intout[3]); /* Affiche les infos */
			printf(" Maximum of Tracks : %d\n",_VDIParBlk.intout[4]);
		}
		else
		{
			printf("Ce n'est pas un driver Direct To Disk\n");
			printf("It is not a Direct To Disk driver\n");
			getchar();
		}
	}
	return h;
}
