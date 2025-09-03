#include "ccport.h"



/* +-----------------------------------------------------------------------+ */
/* | KLEMMBRETT INITIALISIEREN						   | */
/* +-----------------------------------------------------------------------+ */

word	scrp_init(pfad)
	byte *pfad;

{
	byte scrap[64];
	long handle;

	scrp_read(scrap);
	if(scrap[0]==0)
	{	strcpy(scrap,pfad);
		scrp_write(scrap);
		{	handle = Dcreate(scrap);
			if((handle<0)&&(handle!=-36))
			{	scrp_write("");
				form_error(1);
				return(0);
			}
		}
	}
	return(1);
}



/* +-----------------------------------------------------------------------+ */
/* | DATEIEN IM SCRAP-DIRECTORY L™SCHEN					   | */
/* +-----------------------------------------------------------------------+ */

void	scrp_clear()

{	char xpfad[ FMSIZE],gesammtpfad[ FMSIZE],xname[ FMSIZE],scrap[256];
	struct FILEINFO file;
	int ret;

	scrp_read(scrap);
	strmfp(xpfad,scrap,"SCRAP.*");
	ret=dfind(&file,xpfad,0);
	while(ret==0L)
	{	stcgfp(gesammtpfad,xpfad);
		strmfp(xname,gesammtpfad,file.name);
		remove(xname);
		ret=dnext(&file);
	}

}



/* +-----------------------------------------------------------------------+ */
/* | LŽNGE DES KLEMMBRETT-INHALTS ALS WORD IN KYBTES LIEFERN		   | */
/* +-----------------------------------------------------------------------+ */

word	scrp_length()

{
	byte name[ FMSIZE], filename[ FMSIZE];
	struct FILEINFO dta;
	long length = 0;

	scrp_read(filename);
	strmfp(name,filename,"SCRAP.*");

	if(!dfind(&dta,name,0))
		do
			length += dta.size;
		while(!dnext(&dta));
	else
		return(0);

	return((word)((length+512)/1024));
}



/* +-----------------------------------------------------------------------+ */
/* | EINE ROUTINE, DIE ZU EINER GEGEBENEN EXTENSION DAS CLIPFILE LIEFERT   | */
/* +-----------------------------------------------------------------------+ */

word	scrp_find(extension,filename)
	byte *extension,*filename;

{
	byte datei[ FMSIZE];
	byte scrap[256];
	word c = 0;
	struct FILEINFO dta;

	scrp_read(scrap);
	strcpy(datei,scrap);
	strcat(datei,"\\SCRAP.");
	strcat(datei,extension);
	if(!dfind(&dta,datei,0))
	{
		c++;
		strcpy(datei,scrap);
		strmfp(filename,datei,dta.name);
		while(!dnext(&dta)) c++;
	}
	else
		return(0);
	return(c);
}
