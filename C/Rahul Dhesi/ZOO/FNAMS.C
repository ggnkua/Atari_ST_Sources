#include <portab.h>
#include <osbind.h>		/* Fsetdta/Fgetdta/Fsfirst/Fsnext */
#include <stdio.h>		/* fuer stderr und stdout */
#include <ctype.h>		/* fuer toupper */

typedef struct {
	char d_reserved[21];
	char d_attrib;
	WORD d_time;
	WORD d_date;
	long d_lenght;
	char d_fname[14];
	} DTA;

#define DIR	16			/* attributbits in der DTA */
#define NO_DIR 0

/*
 *	"tarzan schwingt sich durch den ordnerdschungel"
 *
 *	wie so etwas funktioniert stand mal in der ST-Computer, oder
 *	war das in der c't, wer programmiert endlich mal eine literatur-
 *	verwaltung (gefuellt natuerlich ;-)?
 */

WORD tree(pf,d)
char *pf;
WORD d;
{  
	DTA l_dta;
	char l_name1[256];
	VOID work_tree();

	Fsetdta(&l_dta);
	work_tree(pf);			/* die arbeitsroutine */
	sprintf(l_name1,"%s*.*",pf);
	if (Fsfirst(l_name1,DIR) >= 0)
	{ 
		if (l_dta.d_attrib & DIR)
			if (strcmp(l_dta.d_fname,".") && strcmp(l_dta.d_fname,".."))
			{  
				sprintf(l_name1,"%s%s\\",pf,l_dta.d_fname);
				tree(l_name1,d);
				Fsetdta(&l_dta);
			}
		while (Fsnext() >= 0)
		{  
			if (l_dta.d_attrib & DIR)
				if (strcmp(l_dta.d_fname,".") && strcmp(l_dta.d_fname,".."))
				{  
					sprintf(l_name1,"%s%s\\",pf,l_dta.d_fname);
					tree(l_name1,d);
					Fsetdta(&l_dta);
				}
		}
	}
}


VOID work_tree(pf)
char *pf;
{
	DTA *f_dta;
	char fpf[256];

	f_dta = (DTA *) Fgetdta();
	sprintf(fpf,"%s*.*",pf);
	if (Fsfirst(fpf,NO_DIR) >= 0)
		do {  
			fprintf(stdout,"%s%s\n",pf,f_dta->d_fname);
		} while (Fsnext() >= 0);
}

char pfad[256];

int main(argc, argv)
int argc;
char **argv;
{
	char *p;

	fprintf(stderr,"fnams v1.0 sb\n\r");
	if (argc < 2)
	{
		fprintf(stderr,"Anwendung: fnams {pfadname}   (Bsp.: fnams a:\\)\n\r");
		fprintf(stderr,"(Abbruch mit CONTROL-C)\n\r\n\r");
		fprintf(stderr,"fnams ");
		scanf("%s",pfad);
	} else {
		strcpy(pfad,argv[1]);
	}

	p = pfad;
	do {
		*p = toupper(*p);
	} while (*++p);

	fprintf(stdout,"\n");
	tree(pfad,0);
	fprintf(stdout,"\n");
	exit(0);
}
