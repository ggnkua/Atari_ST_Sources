#include <vdi.h>
#include "prn_bind.h"

/*
 * Tab size = 8
 */


/****************************************************************/
/*								*/
/*	vq_margin						*/
/*								*/
/*	Cette fonction retourne les marges du driver en points	*/
/*	Ainsi que la r‚solution horisontale et verticale reŠlle */
/*	de l'imprimante (en DPI).				*/
/*								*/
/*	Binding:						*/
/*		contrl[0]=5;					*/
/*		contrl[1]=contrl[3]=0;				*/
/*		contrl[5]=2100;					*/
/*		contrl[6]=handle;				*/
/*		vdi();						*/
/*		intout[0] : 0 appel inhexistant			*/
/*		intout[1] : marge haute				*/
/*		intout[2] : marge basse				*/
/*		intout[3] : marge gauche			*/
/*		intout[4] : marge droite			*/
/*		intout[5] : Taille horizontale (sans les marges)*/
/*		intout[6] : Taille verticale (sans les marges)	*/
/*								*/
/****************************************************************/

/************************************************************************/
/*	binding PURE C							*/
/*									*/
/*	int vq_margin(int handle,int *top,int *bot,int *lft,int *rgt, int *xdpi, int *ydpi)	*/
/*									*/
/*	Retour: 0 si l'appel est inhexistant				*/
/*		top,bot,lft,rgt contiennent les marges (h,b,g,d)	*/
/*		xdpi et ydpi sont la r‚solution reelle de la page.	*/
/*									*/
/************************************************************************/

int vq_margin(int handle,int *top,int *bot,int *lft,int *rgt, int *xdpi, int *ydpi)
{
	VDIPB vdipb;
	
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;

	(vdipb.intout)[0]=0;
	
	(vdipb.contrl)[0]=5;    
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=2100;
	(vdipb.contrl)[6]=handle;	
	vdi(&vdipb);
	
	*top=(vdipb.intout)[1];
	*bot=(vdipb.intout)[2];
	*lft=(vdipb.intout)[3];
	*rgt=(vdipb.intout)[4];
	*xdpi=(vdipb.intout)[5];
	*ydpi=(vdipb.intout)[6];
	return ((vdipb.intout)[0]);
}



/****************************************************************/
/*								*/
/*	vq_driver_info						*/
/*								*/
/*	Retourne des informations sur le driver et la librairie	*/
/*	utilis‚e. Cette fonction permet de savoir si les	*/
/*	nouveaux appels vq_margin() et vq_bit_image() sont	*/
/*	disponibles (appels dont le sub-opcode est => 2100).	*/
/*								*/
/*	Binding:						*/
/*		contrl[0]=5;					*/
/*		contrl[1]=contrl[3]=0;				*/
/*		contrl[5]=2101;					*/
/*		contrl[6]=handle;				*/
/*		vdi();						*/
/*		intout[0] : 0 appel inhexistant			*/
/*		intout[1] : no de version de la librairie	*/
/*		intout[2] : no de version du driver		*/
/*		intout[3] : 1=monochrome, 3=CYM, 4=CYMK		*/
/*		intout[4] : attributs				*/
/*			bit 0 : quadri support‚			*/
/*			bit 1 : n‚gatif support‚		*/
/*			bit 2 : mirroir support‚		*/
/*			bit3&4: copie multiples 0=non, 1=hard	*/
/*						2=soft		*/
/*						3=reserv‚	*/
/*			bit 5 : paysage support‚		*/
/*								*/
/*		intout[5] ... intout[5+26]:nom du driver.	*/
/*								*/
/****************************************************************/

/********************************************************************************/
/*	binding PURE C								*/
/*										*/
/*	int vq_driver_info(int handle,int *lib, int *drv, int *plane, *int attr, char name[27]) */
/*										*/
/*	Retour: 0 si l'appel est inhexistant					*/
/*		lib,drv contiennent le no de version de la lib et du 		*/
/*			driver.							*/
/*		plane: 1=monochrome, 3=CYM, 4=CYMK				*/
/*										*/
/********************************************************************************/

int vq_driver_info(int handle,int *lib,int *drv,int *plane,int *attr, char name[27])
{
	int i;
	VDIPB vdipb;
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;    
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=2101;
	(vdipb.contrl)[6]=handle;	
	vdi(&vdipb);
	*lib=(vdipb.intout)[1];
	*drv=(vdipb.intout)[2];
	*plane=(vdipb.intout)[3];
	*attr=(vdipb.intout)[4];	
	for(i=0;i<26;i++)
		*name++=(vdipb.intout)[i+5];
	*name=0;
	return ((vdipb.intout)[0]);
}

/****************************************************************/
/*								*/
/*	vq_bit_image						*/
/*								*/
/*	Retourne des informations sur les formats de fichiers	*/
/*	accept‚es par v_bit_image() dans intout[2].		*/
/*								*/
/*	bit 0 & 1:	00 = IMG monochrome			*/
/*		 	01 = r‚serv‚				*/
/*			10 = r‚serv‚				*/
/*			11 = r‚serv‚				*/
/*	bit 2 & 3:	00 = TGA non reconnu			*/
/*		 	01 = TGA type 2 non compress‚ OK	*/
/*		 	10 = r‚serv‚				*/
/*		 	11 = r‚serv‚				*/
/*	bit 4 … 15	r‚serv‚s				*/
/*								*/
/*								*/
/*	Binding:						*/
/*		contrl[0]=5;					*/
/*		contrl[1]=contrl[3]=0;				*/
/*		contrl[5]=2102;					*/
/*		contrl[6]=handle;				*/
/*		vdi();						*/
/*		intout[0] : 0 appel inhexistant			*/
/*		intout[1] : no de version de v_bit_image	*/
/*		intout[2] : Nombre maximum d'image sur une page	*/
/*		intout[3] : formats disponnibles		*/
/*								*/
/****************************************************************/

/************************************************************************/
/*	binding PURE C							*/
/*									*/
/*	int vq_bit_image(int handle,int *ver,int *maximg,int *form)	*/
/*									*/
/*	Retour: 0 si l'appel est inhexistant				*/
/*		ver,for contiennent le no de version de v_bit_image 	*/
/*			et les formats disponibles.			*/
/*									*/
/************************************************************************/


int vq_bit_image(int handle,int *ver,int *maximg,int *form)
{
	VDIPB vdipb;
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;    
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=0;
	(vdipb.contrl)[5]=2102;
	(vdipb.contrl)[6]=handle;	
	vdi(&vdipb);
	*ver=(vdipb.intout)[1];
	*maximg=(vdipb.intout)[2];
	*form=(vdipb.intout)[3];
	return ((vdipb.intout)[0]);
}



/****************************************************************/
/*								*/
/*	vs_page_info						*/
/*								*/
/*	Permet de sp‚cifier l'origine du document, le cr‚atueur */
/*	ainsi que le nom du document. Ces informations seront	*/
/*	‚crite dans l'historique des impressions ainsi que dans	*/
/*	le fichier textes cr‚e lors de l'impressionsur disque	*/
/*								*/
/*	Binding:						*/
/*		contrl[0]=5;					*/
/*		contrl[1]=contrl[3]=0;				*/
/*		contrl[5]=2103;					*/
/*		contrl[6]=handle;				*/
/*		contrl[3]=nombre d'‚l‚ment intin[]		*/
/*		intin[0]=type de l'information			*/
/*			0 (APPL) : application			*/
/*			1 (DOC)  : document			*/
/*			2 (CREAT): cr‚ateur			*/
/*			3 (REM)	 : remarque/commentaire		*/
/*		intin[1] … intin[???]				*/
/*			chaine ASCII, ou chaque element de	*/
/*			intin[] contient un seul caractere	*/
/*		vdi();						*/
/*		intout[0] : 0 appel inhexistant			*/
/*								*/
/****************************************************************/

/************************************************************************/
/*	binding PURE C							*/
/*									*/
/*	int vs_page_info(int handle,int type,char txt[60])		*/
/*									*/
/*	Retour: 0 si l'appel est inhexistant				*/
/*									*/
/************************************************************************/

int vs_page_info(int handle,int type,char txt[60])
{
	int i;
	VDIPB vdipb;
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[5]=2103;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=type;
			
	for(i=0;((i<60) && (txt[i]!=0));i++)
		(vdipb.intin)[i+1]=(int)txt[i];		
	(vdipb.intin)[i+1]=0;
	i++;
	
	(vdipb.contrl)[3]=i+2;
	vdi(&vdipb);
	return ((vdipb.intout)[0]);
}



/****************************************************************/
/*								*/
/*	vs_crop							*/
/*								*/
/*	Positionne des repŠres sur la page, pour permetre les	*/
/*	d‚coupes lors de l'impression d'un document en plusieurs*/
/*	pages.							*/
/*								*/
/*	Binding:						*/
/*		contrl[0]=5;					*/
/*		contrl[1]=contrl[3]=0;				*/
/*		contrl[5]=2104;					*/
/*		contrl[6]=handle;				*/
/*		contrl[3]=6;					*/
/*		intin[0]=coordonn‚e X du coin sup‚rieur gauche	*/
/*		intin[1]=coordonn‚e Y du coin sup‚rieur gauche	*/
/*		intin[2]=coordonn‚e X du coin inf‚rieur droit	*/
/*		intin[3]=coordonn‚e Y du coin inf‚rieur droit	*/
/*		intin[4]=longueur des traits de d‚coupe		*/
/*		intin[5]=position des traits par rapport aux coordonn‚es */
/*		vdi();						*/
/*		intout[0] : 0 appel inhexistant			*/
/*								*/
/*								*/
/* Note: pour supprimer ce marquage, il faut mettre:		*/
/* intin[0] … intin[5] = 0					*/
/*								*/
/****************************************************************/

/************************************************************************/
/*	binding PURE C							*/
/*									*/
/*	int vs_crop(int handle,int ltx1,int lty1,int ltx2,int lty2,int ltlen,int ltoffset) */
/*									*/
/*	Retour: 0 si l'appel est inhexistant				*/
/*									*/
/************************************************************************/

int vs_crop(int handle,int ltx1,int lty1,int ltx2,int lty2,int ltlen,int ltoffset)
{
	VDIPB vdipb;
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=6;
	(vdipb.contrl)[5]=2104;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=ltx1;
	(vdipb.intin)[1]=lty1;
	(vdipb.intin)[2]=ltx2;
	(vdipb.intin)[3]=lty2;
	(vdipb.intin)[4]=ltlen;
	(vdipb.intin)[5]=ltoffset;	
	vdi(&vdipb);
	return ((vdipb.intout)[0]);
}

/****************************************************************/
/*								*/
/*	vq_image_type						*/
/*								*/
/*	Retourne des informations sur un fichier bitmap donn‚	*/
/*								*/
/*	Le nom complet du fichier est pass‚ … la fonction	*/
/*	ainsi que l'adresse d'une structure BIT_IMAGE		*/
/*								*/
/*	En retour, la structure est remplie, si le type de	*/
/*	fichier est connu (par v_bitimage())			*/
/*								*/
/*	ATTENTION: Actuellemnt, la fonction se base sur 	*/
/*	l'extention du nom du fichier pour d‚terminer son type	*/
/*	.IMG (pour les fichier img) et .TGA (pour les TGA)	*/
/*								*/
/*								*/
/*	Binding:						*/
/*		contrl[0]=5;					*/
/*		contrl[1]=1;					*/
/*		contrl[3]=strlen(filename)+1;			*/
/*		contrl[5]=2105;					*/
/*		contrl[6]=handle;				*/
/*		ptsin[0]=img & 0xffff;				*/
/*		ptsin[1]=img>>16;				*/
/*		intin[0] … intin[n]: nom du fichier + NULL	*/
/*		vdi();						*/
/*		intout[0] : 0: appel inhexistant		*/
/*		intout[1] : 0: fichier inconnu,	1: IMG, 2:TGA	*/
/*								*/
/****************************************************************/

/************************************************************************/
/*	binding PURE C							*/
/*									*/
/*	int vq_image_type(int handle,char *file,BIT_IMAGE *image)	*/
/*									*/
/*	Retour: 0: fichier inconnu, 1:IMG, 2:TGA			*/
/*		La structure BIT_IMAGE est remplie			*/
/*									*/
/************************************************************************/

int vq_image_type(int handle,char *file,BIT_IMAGE *image)
{
	int i;
	VDIPB vdipb;
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;	
	i=0;
	while(*file)
	{
		(vdipb.intin)[i++]=*file++;
	}
	(vdipb.intin)[i++]=0;
	(vdipb.contrl)[3]=i;	
	((long *)(vdipb.ptsin))[0]=(long)image;
	(vdipb.contrl)[1]=1;	
	(vdipb.contrl)[5]=2105;	
	(vdipb.contrl)[6]=handle;	
	vdi(&vdipb);
	return ((vdipb.intout)[1]);
}




/************************************************************************/
/*									*/
/* The following functions are not documented: Don't use!		*/
/*									*/
/************************************************************************/

int vs_save_disp_list(int handle,char *name)
{
	VDIPB vdipb;
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=2;
	(vdipb.contrl)[5]=2106;
	(vdipb.contrl)[6]=handle;
	((long *)(vdipb.intin))[0]=(long)name;
	vdi(&vdipb);
	return ((vdipb.intout)[1]);
}

/************************************************************************/
/* Don't use!								*/
/************************************************************************/

int vs_load_disp_list(int handle,char *name)
{
	VDIPB vdipb;
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=2;
	(vdipb.contrl)[5]=2107;
	(vdipb.contrl)[6]=handle;
	((long *)(vdipb.intin))[0]=(long)name;
	vdi(&vdipb);
	return ((vdipb.intout)[1]);
}

/************************************************************************/
/* Don't use!								*/
/************************************************************************/

int vs_lum(int handle,int cont1000,int lum1000)
{
	VDIPB vdipb;
	vdipb.contrl	=_VDIParBlk.contrl;
	vdipb.intin	=_VDIParBlk.intin;
	vdipb.intout	=_VDIParBlk.intout;
	vdipb.ptsin	=_VDIParBlk.ptsin;
	vdipb.ptsout	=_VDIParBlk.ptsout;
	(vdipb.intout)[0]=0;
	(vdipb.contrl)[0]=5;
	(vdipb.contrl)[1]=0;
	(vdipb.contrl)[3]=2;
	(vdipb.contrl)[5]=2200;
	(vdipb.contrl)[6]=handle;
	(vdipb.intin)[0]=cont1000;
	(vdipb.intin)[1]=lum1000;
	vdi(&vdipb);
	return ((vdipb.intout)[0]);
}
