/*
 * Avril 1995 AGOPIAN Mathias pour STMAG
 *
 * Effectue automatiquement toutes les ‚tapes
 * de la compilation d'un fichier source DSP (*.ASM)
 *
 * Utilisable avec les outils de d‚veloppement MOTOROLA
 * (outils du KIT d‚veloppeur FALCON)
 *
 */


#include <aes.h>
#include <vdi.h>
#include <string.h>
#include <tos.h>
#include "FSELECT.H"

DTA dta;
int ap_id;
int	handle,wcell,hcell,WorkWCeil,WorkHCeil;
AESPB aespb;

char *asmname="ASM56000.TTP";					/* Nom des outils 		*/
char *cldname="CLDLOD.TTP";						/* de developpement		*/
char *info="MAKEDSP.INF";

char utlpath[256];
char asmpath[256];
char cldpath[256];
char cld[256];
char lod[256];
char asmcmd[256];
char lnkcmd[256];
char fpath[256];
char fname[12];
char fcld[12];

void open_work(void);
void extention(char *file,char *ext);
void findpath(char *filename,char *fpath,char *fname);

int main(int argc,char *argv[])
{
	long error;
	int ecran_standard;
	int fhandle;
	int ecran;
	static char filename[256];
	static char deflt[12];
	static char *mask="*.ASM\0\0\0\0\0\0\0\0";
	static char *loadtxt="Assembler *.ASM";
	static char infodeflt[12];
	static char *infomask="*.TTP\0\0\0\0\0\0\0\0";
	static char *infotxt="ASM56000.TTP et CLDLOD.TTP ?";
	static char dummy[12];

	ap_id=appl_init();
	if (ap_id==-1)		return -1;

	open_work();

	Fsetdta(&dta);

	/*
	 * Y'a-t-il un fichier de configuration ?
	 */
	 
	if (Fsfirst(info,0)==0)
	{
		/* oui, alors le lire */
		fhandle=(int)Fopen(info,FO_READ);
		Fread(fhandle,256,utlpath);
		Fclose(fhandle);
	}
	else
	{
		/* non, alors le cr‚er */
		if (fileselect(infomask,infodeflt,filename,infotxt))
			return -1;			
		findpath(filename,utlpath,dummy);
		fhandle=(int)Fcreate(info,0);
		Fwrite(fhandle,strlen(utlpath)+1,utlpath);
		Fclose(fhandle);
	}

	strcpy(asmpath,utlpath);
	strcat(asmpath,"\\");
	strcat(asmpath,asmname);
	strcpy(cldpath,utlpath);
	strcat(cldpath,"\\");
	strcat(cldpath,cldname);

	if (argc>1) strcpy(filename,argv[1]);
	else if (fileselect(mask,deflt,filename,loadtxt))
		return -1;

	strcpy(cld,filename);							/* creer chemin+nom pour le linker	*/
	strcpy(lod,filename);							/* creer chemin+nom pour cld2lod	*/
	extention(cld,".CLD");							/* ajouter les extensions			*/
	extention(lod,".LOD");

	findpath(filename,fpath,fname);					/* extraire le chemin et le nom		*/
	findpath(cld,fpath,fcld);						/* … cause d'un bug on doit			*/
	Dsetdrv((int)(fpath[0]-'A'));					/* faire un Dsetdrv() et Dsetpath()	*/
	Dsetpath(fpath);

	strcpy(asmcmd," -A -B -L -V ");					/* Fabriquer les lignes de commande */
	strcat(asmcmd,fname);
	strcpy(lnkcmd," ");
	strcat(lnkcmd,fcld);

	error=Pexec(0,asmpath,asmcmd,"");				/* lancer l'assemblage							*/
	
	ecran_standard=1;								/* handle de l'‚cran standard					*/
	fhandle=(int)Fcreate(lod,0);					/* ouvrir le fichier listing sur disc			*/
	ecran=(int)Fdup(ecran_standard);				/* copier l'‚cran vars un handle non standard	*/
	Fforce(ecran_standard,fhandle);					/* Diriger l'‚cran vers le fichier				*/
	error=Pexec(0,cldpath,lnkcmd,"");
	Fforce(ecran_standard,ecran);					/* remettre l'‚cran sur l'‚cran					*/
	Fclose(fhandle);								/* fermer le fichier							*/
	if (error<0)									/* sortir si erreur								*/
		return (int)error;
	
	v_clsvwk(handle);
	appl_exit();
	return 0;										/* quitter	*/
}



/*
 * Force une extension
 */

void extention(char *file,char *ext)
{
	char *s=file+strlen(file);
	while((s>=file) && (*s!='.')) s--;
	if (*s=='.') *s=0;
	strcat(s,ext);
}



/*
 * Extraire le chemin et le nom, d'un nom de fichier complet
 */
 
void findpath(char *filename,char *fpath,char *fname)
{
	char *s;
	static char file[256];
	strcpy(file,filename);	
	s=file+strlen(file);
	while((s>file) && (*s!='\\')) s--;
	if (*s=='\\')
	{
		strcpy(fname,s+1);
		*s=0;
		strcpy(fpath,file);
	}
	else
	{
		*fpath=0;
		strcpy(fname,file);		
	}
}


void open_work(void)
{
	register int i;
	for (i=0;i<10;_VDIParBlk.intin[i++]=1);
	_VDIParBlk.intin[0]=Getrez()+2;
	_VDIParBlk.intin[10]=2;
	handle=graf_handle(&wcell,&hcell,&WorkWCeil,&WorkHCeil);
	v_opnvwk(_VDIParBlk.intin,&handle,_VDIParBlk.intout);
}
