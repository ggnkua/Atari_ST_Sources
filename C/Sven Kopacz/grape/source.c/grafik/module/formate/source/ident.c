#include <stddef.h>
#include <aes.h>
#include <fiodef.h>
#include <string.h>

/* Reines Identifier-Modul */
void	cdecl mod_init(void);	/* Initialisierung des Moduls */
int		cdecl identify(FILE_DSCR *fd);

static MODULE_FIOFN mod_fn=
{
	/* Meine Funktionen */	
	mod_init,
	identify,
	NULL,
	NULL
};

static FIOMODBLK fblock=
{
	"GRAPEFIOMOD",
	'0101',
	
	/* id */
	'IdFy',
	
	/* name */
	"Identifier",

	/* Exportformate */
	0,
	
	/* Anzahl der Kompressionsverfahren */
	0,
	/* Namen */
	NULL,
	
	/* Anzahl der Optionen */
	0,
	/* Optionen */
	NULL,
	
		
	/* Meine Funktionen */	
	&mod_fn,
	
	/* Grape-Functions */
	NULL
};

void main(void)
{
	appl_init();
	if(fblock.magic[0])
		form_alert(1,"[3][Ich bin ein Grape-Modul!][Abbruch]");
	appl_exit();
}

void cdecl mod_init(void)
{
}

int		cdecl identify(FILE_DSCR *fd)
{
	int a, ascii=1, xascii=1;
	uchar	b;
	long	id, flen;
	static char	d[7*45];
	
	fd->descr=d;
	
	/* Test auf eigene Dateiformate */
	id=*((long*)(fd->buf256));

	if((id=='GCOL')&&(fd->flen==8))
	{
		strcpy(d, "Grape-Farbe. ™ffnen Sie den Farbeditor im|");
		strcat(d, "Men \'Fenster\' und klicken Sie auf das|");
		strcat(d, "Diskettensymbol, um die Farbe zu laden.");
		return(REL_REC);
	}
	if((id=='GCPL')&&(fd->flen==1576))
	{
		strcpy(d, "Grape-Farbpalette. ™ffnen Sie die Farbpalette|");
		strcat(d, "im Men \'Fenster\' und klicken Sie auf das|");
		strcat(d, "Diskettensymbol, um die Palette zu laden.");
		return(REL_REC);
	}
	if((id=='GPPR')&&(fd->flen==4412))
	{
		strcpy(d, "Grape-Stift. ™ffnen Sie die Stiftpalette,|");
		strcat(d, "selektieren Sie einen Stift und w„hlen Sie|");
		strcat(d, "\'Edit\'. Klicken Sie im erscheinenden|");
		strcat(d, "Stifteditor auf das Diskettensymbol links|");
		strcat(d, "unten, um den Stift zu laden.");
		return(REL_REC);
	}
	if(id=='GPPL')
	{
		strcpy(d, "Grape-Stiftpalette. ™ffnen Sie die Stift-|");
		strcat(d, "Palette im Men \'Fenster\' und klicken Sie|");
		strcat(d, "auf das Diskettensymbol, um die Stifte zu|");
		strcat(d, "laden.");
		return(REL_REC);
	}
	if((id=='GPLY')&&(fd->flen==1090))
	{
		strcpy(d, "Grape-Polynom. ™ffnen Sie den Polynomeditor,|");
		strcat(d, "z.B. indem Sie im Stifteditor eine der|");
		strcat(d, "Verlaufskurven anklicken.|");
		strcat(d, "Klicken Sie auf das Diskettensymbol links|");
		strcat(d, "unten, um das Polynom zu laden.");
		return(REL_REC);
	}
	if(id=='GSTP')
	{
		strcpy(d, "Grape-Stempel. ™ffnen Sie die Werkzeugpalette|"); /*< Maximale Zeilenl„nge */
		strcat(d, "im Men \'Fenster\' und w„hlen Sie den Stempel.|"); /* (L„nger wegen der \' )*/
		strcat(d, "Klicken Sie rechts auf den Optionsbutton und|");
		strcat(d, "im dann erscheinenden Fenster auf das Disket-|");
		strcat(d, "tensymbol, um den Stempel zu laden.");
		return(REL_REC);
	}

	/* Test auf Ascii-Datei */
	flen=fd->flen;
	if(flen > 256) flen=256;
	
	for(a=0; a < flen; ++a)
	{
		b=fd->buf256[a];
		
		if(b > 127) ascii=0;
		if((b<32) && (b!=10) && (b!=13) && (b!=9))
		{ascii=xascii=0;}
	}

	if((ascii==0)&&(xascii==0))
		return(UNKNOWN);

	if(ascii==1)
		strcpy(d, "Standard ASCII-Datei ohne Codes > 127");
	else
		strcpy(d, "Erweiterte ASCII-Datei mit Codes > 127");
	
	strcat(d, "|Diese Datei k”nnen Sie mit jedem Ascii-Editor|bearbeiten.");

	
	if(!strcmp(fd->ext, ".TXT"))
		return(EDT_REC);
		
	return(EXT_REC);
}

