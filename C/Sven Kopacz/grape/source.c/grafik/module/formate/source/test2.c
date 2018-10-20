#include <stddef.h>
#include <aes.h>
#include <fiodef.h>

void cdecl	mod_init(void);	/* Initialisierung des Moduls */
int cdecl		identify(int fh, long flen, uchar *buf256, char *ext, FILE_DSCR *fd);
int cdecl		load_file(int fh, GRAPE_DSCR *dd);
int cdecl		save_file(int fh, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options);

char *comp_names[]={"Ganz toll", "Toll", "Nicht so toll", "Steif"};
char *o1[]={"Destruktiv"};
char *o2[]={"Operativ"};
char *o3[]={"Konjunktiv"};
char *o4[]={"Windschief"};
char *o5[]={"GrÅn", "GrÅner", "Am grÅnsten"};
char *o6[]={"Gelb", "Gelber", "Am gelbsten"};
char *o7[]={"Rot", "Roter", "Am rotesten"};
char *o8[]={"Blau", "Blauer", "Am blausten"};
OPTION opts[]=
{
	1,o1,
	1,o2,
	1,o3,
	1,o4,
	3,o5,
	3,o6,
	3,o7,
	3,o8
};

static MODULE_FIOFN mod_fn=
{
	/* Meine Funktionen */	
	mod_init,
	identify,
	load_file,
	save_file
};

static FIOMODBLK fblock=
{
	"GRAPEFIOMOD",
	'0101',
	
	/* id */
	'Tes2',
	
	/* name */
	"Scheiûe 1",

	/* Exportformate */
	SUP1|SUP4|SUP8C|SUP24RGB,
	
	/* Anzahl der Kompressionsverfahren */
	4,
	/* Namen */
	comp_names,
	
	/* Anzahl der Optionen */
	8,
	/* Optionen */
	opts,
	
		
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

int	cdecl	identify(int fh, long flen, uchar *buf256, char *ext, FILE_DSCR *fd)
{
	_GF_ form_alert(1,"[1][Identify aufgerufen][OK]");
	return(UNKNOWN);
}

int	cdecl	load_file(int fh, GRAPE_DSCR *dd)
{
	_GF_ form_alert(1,"[1][Load aufgerufen][OK]");
	return(0);
}

int cdecl	save_file(int fh, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options)
{
	_GF_ form_alert(1,"[1][Save aufgerufen][OK]");
	return(0);
}



