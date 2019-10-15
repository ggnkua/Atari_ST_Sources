
/*	Wordcounter zum Z„hlen von Worten, Zeilen und Zeichen
	einer beliebigen Datei unter TOS. (C) 1992 Frank Mathy, TOS */

#include <stdio.h>
#include <string.h>

#define FALSE 0
#define TRUE 1

int zaehl(long *zeichen,long *worte,long *zeilen);
void ausgabe(int option,char *optionch,char *name,
			long zeichen,long worte,long zeilen);

FILE   *datei;

int main (int argc,char *argv[])
	{
	int option=FALSE,start,fehler;
	long zeichen=0L,worte=0L,zeilen=0L,
	     gesamtzeichen=0L,gesamtworte=0L,gesamtzeilen=0L;

	if(argc>1)
		{
	    if (argv[1][0]=='-')
			{
	  	 	option=TRUE;
		  	start=2;
		  	}
		else start = 1;
		fehler=FALSE;
	 	while((start<argc)&&(!fehler))
	 		{
	 		if(datei=fopen(argv[start++],"rb"))
				{
				zeichen=worte=zeilen=0L;
				fehler=zaehl(&zeichen, &worte, &zeilen);
				fclose (datei);
				if (!fehler)
					{
					gesamtzeichen+=zeichen;
					gesamtworte+=worte;
					gesamtzeilen+=zeilen;
					ausgabe(option,argv[1],argv[start-1],zeichen,worte,zeilen);
					}
				else printf("Read error on %s\n",argv[start-1]);
				}
			else printf ("Can't open >%s<\n",argv[start-1]);
			}
		if((option&&(argc>3))||(!option&&(argc>2)))
		ausgabe (option, argv[1], "Total", gesamtzeichen, gesamtworte, gesamtzeilen);
	 	}
	else
		{
		printf("\nWordcounter (C) Frank Mathy, TOS\n");
		printf("Parameters: [-cwl] {Filenames} \n");
		}
	return 0;
	}

int zaehl(long *zeichen,long *worte,long *zeilen)
    {
	int einzeichen,fehler=0,imwort=0;

	while (((einzeichen=getc(datei))!=EOF)&&(!fehler))
		{
		if(!(fehler=ferror(datei)))
			{
			(*zeichen)++;
			if((einzeichen=='\t')||(einzeichen=='\r')||(einzeichen=='\n')
				||(einzeichen=='\f')||(einzeichen==' '))
				{
				if (imwort)
					{
					(*worte)++;
					imwort=0;
					}
				}
			else imwort=1;
			if ((einzeichen=='\n')||(einzeichen=='\f'))
				(*zeilen)++;
			}
		}
	return fehler;
	}

void ausgabe(int option,char *optionch,char *name,
			long zeichen,long worte,long zeilen)
     {
	 int cflag=FALSE,wflag=FALSE,lflag=FALSE;

	 if(!option) cflag=wflag=lflag=TRUE;
	 else
		{
		while (*optionch)
			{
			switch (*optionch)
				{
				case 'c':
				case 'C':	cflag=TRUE;
							break;
				case 'w':	
				case 'W':	wflag=TRUE;
							break;
				case 'l':
				case 'L':	lflag=TRUE;
							break;
				}
			optionch++;
			}
		}
	printf ("+------------------------------+\n");
	printf ("| Filename  : %-17s|\n", name);
	if(cflag) printf ("| Characters: %-17ld|\n",zeichen);
	if(wflag) printf ("| Words     : %-17ld|\n",worte);
	if(lflag) printf ("| Lines     : %-17ld|\n",zeilen);
	printf ("+------------------------------+\n\n");
	}
