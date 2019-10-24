/* (c) 1996 AGOPIAN Mathias */
/* pour STMAG               */


#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <vdi.h>
#include <aes.h>

#include "prn_bind.h"

int ap_id;
int open_dev(int dev);

int main(void)
{
	char nom[27],car_name[40];
	char *str="Fox Mulder and Dana Scully";
	int pts[8];
	int pxy[4];
	int rgb[3];
	int nb_fontes;
	int dummy,version,lib_version,type;
	int handle;
	int *intout;
	int haut,bas,droite,gauche;
	int xdpi,ydpi,xres,yres;
	int error,index;
	int i;
	
	/* Tester la pr‚sence de GDOS */
	
	if (!vq_gdos())
	{
		return -1;
	}
	
	/* D‚clarer l'application */

	ap_id=appl_init();
	if (ap_id<0)
	{
		return -1;
	}
	
	/* Ouverture de la station 21 (imprimante par d‚faut) */
	
	handle=open_dev(21);
	if (handle>0)
	{
		intout=_VDIParBlk.intout;
		
		/* Demander le type du driver */

		type=vq_driver_info(handle,&lib_version,&version,&dummy,&dummy,nom);
		
		if (type)
		{
		
			/* C'est un nouveau driver, alors on donne les informations sur notre document */
			
			/* Le nom du prgramme qui a effectu‚ cette impression */
			
			vs_page_info(handle,APPL,"PRINT.PRG");
			
			/* Le titre du document imprim‚ */
			
			vs_page_info(handle,DOC,"Fox Mulder and Dana Scully.");
			
			/* Le cr‚ateur du document (ce peut etre un programme */
			
			vs_page_info(handle,CREAT,"(c) 1996 AGOPIAN Mathias");
			
			/* Enfin, les remarques */
			
			vs_page_info(handle,REM,"Programme d'exemple pour STMAG");


			/* Demander les marges de l'imprimante */
			
			vq_margin(handle,&haut,&bas,&droite,&gauche,&xdpi,&ydpi);

			/* Demander la largeur et la hauteur en pixels de l'imprimante */
			
			vq_extnd(handle,0,intout);
			xres=intout[0];
			yres=intout[1];

			/* Afficher le nom de l'imprimante ainsi que la version du driver */
			
			printf("\nImpression sur %s (v%x.%02x)",nom,version>>8,version & 0xff);

			/* Afficher la r‚solution */

			printf("\nR‚solution %d x %d DPI",xdpi,ydpi);
			printf("\nAppuyez sur UNDO pour stopper l'impression");
			
			/* Chargement des fontes vectorielles */

			nb_fontes=vst_load_fonts(handle,0);
			
			/* On s‚lectionne la derniŠre fonte (au hazard baltazar!) */
			
			index=vqt_name(handle,nb_fontes-1,car_name);
			vst_font(handle,index);

			/* On rŠgle la taille de la police … 24 points (pas pixels, hein, POINTS!) */

			vst_arbpt(handle,24,&dummy,&dummy,&dummy,&dummy);

			/* Quelle est la zone occup‚e par le texte? */

			vqt_f_extent(handle,str,pts);
			
			/* Choix de la couleur du texte */
			
			rgb[0]=800;
			rgb[1]=100;
			rgb[2]=250;
			vs_color(handle,255,rgb);
			vst_color(handle,255);

			/* Calcul des coordonn‚es (en haut, centr‚) */

			pxy[0]=(xres-(pts[2]-pts[0]))/2;
			pxy[1]=haut+abs(pts[1]-pts[7]);

			/* Affichage */

			v_ftext(handle,pxy[0],pxy[1],str);
			
			/* Positionnement de la premiŠre image: */
			/* 3 pouces sur 3 pouces, proportionnel */

			pxy[0]=(xres/2-xdpi*3)/2;
			pxy[1]+=haut;
			pxy[2]=pxy[0]+xdpi*3;
			pxy[3]=pxy[1]+ydpi*3;	
			v_bit_image(handle,"MULDER.TGA",1,0,0,1,1,pxy);

			/* de la deuxiŠme */
			/* 3 pouces sur 3 pouces, proportionnel */

			pxy[0]=xres/2+(xres/2-xdpi*3)/2;
			pxy[2]=pxy[0]+xdpi*3;
			v_bit_image(handle,"SCULLY.TGA",1,0,0,1,1,pxy);

			/* Le graphisme vectoriel */
			
			vsl_width(handle,1);
			vsf_interior(handle,FIS_SOLID);
			vsf_perimeter(handle,0);
			for (i=32;i<255;i++) 
			{
				vsf_color(handle,i);
				v_circle(handle,xres/2,yres/4,((long)xres*(255-i))/2550);
			}


			printf("\nVeuillez patientez quelques minutes...");

			/* On imprime la page */

			v_updwk(handle);
			error=intout[0];
			if (error)
			{
				printf("\nProblŠme durant l'impression (erreur %d)",error);
			}
			else
			{
				printf("\nImpression du document termin‚e");

			}
			
			/* On libŠre les fontes */
			
			vst_unload_fonts(handle,0);

			/* On ‚jecte la page */
			
			v_clrwk(handle);

		}
		else
		{
			printf("\nCe n'est pas un nouveau driver!");
		}
		
		/* Fermeture de la station de travail */
		
		v_clswk(handle);
	}
	else
	{
		printf("\nDriver non install‚");
	}
	
	printf("\nAppuyez sur une touche");
	Bconin(2);
	
	/* exit */
	
	appl_exit();
	return 0;
}


int open_dev(int dev)
{
	int i;
	int handle;
	for (i=0;i<10;i++)
	{
		_VDIParBlk.intin[i]=1;
	}	
	_VDIParBlk.intin[0]=dev;
	_VDIParBlk.intin[10]=2;	
	v_opnwk(_VDIParBlk.intin,&handle,_VDIParBlk.intout);	
	return handle;
}
