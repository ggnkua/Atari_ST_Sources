/*****************************************************************/
/* HISTORY							 */
/*								 */
/* 11/06/89 - Modified initsys()				 */
/*	      added read_GOG() which will read in a GOG.DFT file */
/*	      if it exists and use the new LYT,DIC and Dress file*/
/*****************************************************************/

#include	<obdefs.h>
#include	<gemdefs.h>
#include	<osbind.h>
#include	"deskset2.h"
#include	"comp.h"

#define		FREAD		0

char	drsf[]	= "DRESS1.DRS";
char	dicf[]	= "BASIC.DIC";
char	kbdf[]	= "501.LYT";
char	akey1[] = "GoG";
char	akey2[] = "CmP";
char	akey3[6]= { 0xe2, 0xe1, 0xe3, 0xe6, 0xeb, 0 };
char	spbms[] = " ";
char	exdcmd[]= "DSU1.PRG";
char	trncmd[]= "DSU2.PRG";

struct txtattr	gltxtattr;
struct textobj	gltext;
int		glgrattr[11];		/* changed 10 to 11 cjg */
char		syspath[100];		/* Boot up system path	*/
FDB		char_MFDB;		/* Intellifont MFDB	*/

long	_stksize =	20240L;

extern	char		pathbuf[];	/* current file path	*/
extern	unsigned char	ptsfpos[256], mcsdbl[303];
extern	unsigned	H_MARGIN;	/* Horiztal Left margin	*/
extern	unsigned	V_MARGIN;	/* Vertical Top	margin	*/
extern	char		nuls[];

extern int pstorage[];

/****************************************************************/
/* 		   H&J Module Interface  			*/
/****************************************************************/
init_tattr()
{
/*
	gltxtattr.ptsz  = 24*8;
	gltxtattr.font  = 1;
	gltxtattr.ssiz  = 24*8;
	gltxtattr.lnsp  = (long)pttomu(26);
	gltxtattr.mcomp	= 0;	* Manual char. COMPensation off *
	gltxtattr.acomp	= 0;	* Auto.  char. COMPensation off *
	gltxtattr.kernmd= 0;	* KERNing	 MoDe flag off	*
	gltxtattr.hypmd	= 1;	* HYPhenation	 MoDe flag on	*
	gltxtattr.nsuchyp= 2;	* No. of SUCcessive	HYPhens	*
	gltxtattr.nbefhyp= 2;	* No. of chars BEFore	HYPhen	*
	gltxtattr.nafthyp= 3;	* No. of chars AFTer	HYPhen	*
	gltxtattr.ltsmd	= 1;	* LetTerSpacing MoDe flag on	*
	gltxtattr.plts	= 3;	* Positive LetTer Space in RU	*
	gltxtattr.nlts	= 1;	* Negative LetTer Space in RU	*
	gltxtattr.minsp	= 12;	* MINimum	SPace	 in RU	*
	gltxtattr.prfsp	= 8;	* PReFerred	SPace	 in RU	*
	gltxtattr.maxsp	= 30;	* MAXimum	SPace	 in RU	*
	gltxtattr.rvomd	= 0;	* Reverse VideO MoDe flag off	*
	gltxtattr.psimd	= 0;	* PSeudo Italic MoDe flag off	*
	gltxtattr.jstmd	= 0;	* JuSTification MoDe flag AJ	*
	gltxtattr.scoff = 0;	* Scan line offset		*
*/
	/* See Resource.C for a Description of pstorage[]	*/
	gltxtattr.ptsz  = pstorage[9];   
	gltxtattr.font  = pstorage[8];
	gltxtattr.ssiz  = pstorage[10];
	gltxtattr.lnsp  = pstorage[11];
	gltxtattr.mcomp	= pstorage[37];	/* Manual char. COMPensation off*/
	gltxtattr.acomp	= pstorage[38];	/* Auto.  char. COMPensation off*/
	gltxtattr.kernmd= pstorage[12];	/* KERNing	 MoDe flag off	*/
	gltxtattr.hypmd	= pstorage[39];	/* HYPhenation	 MoDe flag on	*/
	gltxtattr.nsuchyp= pstorage[40];/* No. of SUCcessive	HYPhens	*/
	gltxtattr.nbefhyp= pstorage[41];/* No. of chars BEFore	HYPhen	*/
	gltxtattr.nafthyp= pstorage[42];/* No. of chars AFTer	HYPhen	*/
	gltxtattr.ltsmd	= pstorage[43];/* LetTerSpacing MoDe flag on	*/
	gltxtattr.plts	= pstorage[44];/* Positive LetTer Space in RU	*/
	gltxtattr.nlts	= pstorage[45];/* Negative LetTer Space in RU	*/
	gltxtattr.minsp	= pstorage[46];/* MINimum	SPace	 in RU	*/
	gltxtattr.prfsp	= pstorage[47];/* PReFerred	SPace	 in RU	*/
	gltxtattr.maxsp	= pstorage[48];/* MAXimum	SPace	 in RU	*/
	gltxtattr.rvomd	= pstorage[13];/* Reverse VideO MoDe flag off	*/
	gltxtattr.psimd	= pstorage[49];/* PSeudo Italic MoDe flag off	*/
	gltxtattr.jstmd	= pstorage[14];/* JuSTification MoDe flag AJ	*/
	gltxtattr.scoff = pstorage[16];/* Scan line offset		*/

}

/*
	Function to initialize with default files
*/
initsys()
{
	get_path();			/* For GOG own use...		*/
	strcpy(setp.ftdrs,drsf);	/* FonT DResS : dress1.drs	*/
	strcpy(setp.edict,dicf);	/* Exc. DICTionary : basic.dic	*/
	strcpy(setp.kblyt,kbdf);	/* KeyBoard LaYouT : 501.lyt	*/
	setp.omod	= 5;		/* Ouptut device : Atari laser	*/
	setp.hylg	= 1;		/* HYphenation LanGuage : ENG	*/

	IFerr		= 4;		/* no previous cache setup...	*/

        gltext.slvlist	= (struct slvll *)0L;
        gltext.attr	= &gltxtattr;

	char_MFDB.fd_stand	= 0;	/* setup IFont char MFDB	*/
	char_MFDB.fd_nplanes	= 1;

	H_MARGIN = 0;			/* 0 pica  invisible margin	*/
	V_MARGIN = 0;			/* 0 point invisible margin	*/
	init_Tpos();			/* setup Text Window vars	*/
	read_GOG();			/* Read in GOG defaults, if any */
	sysfiles();			/* load default files...	*/
	clear_tags();			/* start with no text tags	*/
}

/*
	Function to load default files
*/
sysfiles()
{
	ld_lyt(setp.kblyt);			/* load Keyboard Layout	*/
	ld_lang();				/* load Hyp. language	*/
	ld_dict(setp.edict,0);			/* load Dictionary..	*/
	ld_dress(setp.ftdrs,0);			/* load Font dress..	*/
}

/****************************************/
/*	get entry current path		*/
/****************************************/
get_path()
{
	syspath[0] = (char)Dgetdrv() + 'A';
	syspath[1] = ':';
	Dgetpath(&syspath[2],0);
	strcat(syspath,"\\");
	strcpy(pathbuf,syspath);
}

/*
	Function to report a user message appended with a fixed error
	one selected by argument 'mod'
	Mod :	1 -- Not found on Disk
		2 -- Read Error
		3 -- Write Error
*/
setnfd(file,mod)
char *file, mod;
{
	OBJECT	*errobj;
	int	msgno;
	char	*msgp;

	if (mod == 1)	msgno = SNF1;
	else
	if (mod == 2)	msgno = SNF2;
	else
	if (mod == 3)	msgno = SNF3;
	else		return;
	rsrc_gaddr(R_STRING,msgno,&msgp);
	rsrc_gaddr(0,SNFMSG,&errobj);
	errobj[SNFILE].ob_spec	= (long)file;
	errobj[SNFMS].ob_spec	= (long)msgp;
	errobj[execform(errobj,0)].ob_state = NORMAL;
}

/*
	Function to find & open a file
*/
fopfl(file,mod)
char *file;
int mod;
{
	int fid = -1;
	char mpath[100];

	if (!findfile(file,mpath) || (fid = open(mpath,mod)) < 0)
		setnfd(file,1);
	return(fid);
}

/*
	Load Hyphenation Language
*/
ld_lang()
{
	inithyph();				/* init Hyphenation	*/
	if (llang(setp.hylg)) {			/* load Hyp. language	*/
		do_alert(NORULE);
		return(0);
	}
	else	return(1);
}

/*
	Load Dictionary file
*/
ld_dict(file,mod)
char *file;
int mod;
{
	int	fid, ok = 0;
	if (mod) {
		if ((fid = open(file,FREAD)) <= 0)
			setnfd(file,1);
	}
	else	fid = fopfl(file,FREAD);
	if (fid > 0) {
		if (!ldict(fid))
			setnfd(file,2);
		else	ok = 1;
	}
	return(ok);
}

/*
	Load Keyboard Layout file
*/
ld_lyt(file)
char *file;
{
	int	fp, ok = 0;

	if ((fp = fopfl(file,FREAD)) < 0) {	/* find it to read..	*/
		do_alert(LYTMS1);		/* no use int tables	*/
		ok = 1;
	}
	else {
	  if (	read(fp,ptsfpos,256) != 256 ||
		read(fp,mcsdbl,303)  != 303  )
		do_alert(LYTMS2);
	  else	ok = 2;
	  close(fp);
	}
	if (ok) bld_flash();		/* build Fpos to Ascii table	*/
	return(ok);
}

/*
	This function locates a file, utilizing the current path then
	the boot up path.
	fname		: name of the file to be searched.
	fpname		: buffer to hold full path filename if file found.
	Returns		True/False
*/
findfile(fname,fpname)
char *fname, *fpname;
{
extern	char	syspath[];		/* Boot up file path	*/
extern	char	pathbuf[];		/* Current file path	*/
	char	*sfn, *dfn;

	for (	sfn = dfn = fname;*sfn;	/* upper case fname...	*/
		*dfn++ = toupper(*sfn++)  );
	strcpy(fpname,pathbuf);
	strcat(fpname,fname);
	if (!access(fpname,0))		/* in current path ?	*/
		return(1);
	strcpy(fpname,syspath);
	strcat(fpname,fname);
	if (!access(fpname,0))		/* in boot up path ?	*/
		return(1);
	return(0);			/* can't find file...	*/
}

/*
	Function to run the external Exception Dictionary utility
*/
runExDict()
{
	runExtM(0);
}

/*
	Function to run the external Text Translation utility
*/
runTrans()
{
	runExtM(1);
}

/*
	Function to run an external module :
	mode:	0 -- Exception Dictionary
		1 -- Text Translation
*/
runExtM(mode)
int	mode;
{
	char	pcmd[100], argm[80], lgn[4];
	char	*Ecmd;

	Ecmd = !mode ? exdcmd:trncmd;
	if (!findfile(Ecmd,pcmd)) {
		setnfd(Ecmd,1);
		return;
	}
	strcpy(argm,akey1);
	strcat(argm,spbms);
	strcat(argm,akey2);
	strcat(argm,spbms);
	strcat(argm,akey3);
	if (!mode) {
		strcat(argm,spbms);
		strcat(argm,setp.edict);
		strcat(argm,spbms);
		itoa(setp.hylg,lgn);
		strcat(argm,lgn);
	}
	if (Pexec(0,pcmd,argm,nuls) == -1)
		do_alert(MERM0);
}

/*
	Function to write out default setup structure in document
*/
write_setp()
{
	return(dwrite(&setp,sizeof(struct pwup)));
}

/*
	Function to read in default setup structure from document
*/
read_setp()
{
	return(dread(&setp,sizeof(struct pwup)));
}
