#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <string.h>
#include <tos.h>

#define MAXANZAHL 100

void ausgabe(struct ffblk eintrag,int tiefe,FILE *datei)
	{
	int i;
	struct ftime *zeit=(struct ftime *) &eintrag.ff_ftime;
	if(tiefe>0) for(i=0; i<tiefe; i++) fprintf(datei,"  ");
	fprintf(datei,"%-12s ",eintrag.ff_name);
	if(eintrag.ff_attrib&FA_DIREC) fprintf(datei,"DIRECTORY ");
	else fprintf(datei,"%-9ld ",eintrag.ff_fsize);
	fprintf(datei,"%02d:%02d:%02dh %02d.%02d.%04d ",
			zeit->ft_hour,zeit->ft_min,zeit->ft_tsec*2,
			zeit->ft_day,zeit->ft_month,zeit->ft_year+1980);
	if(eintrag.ff_attrib&FA_RDONLY) fprintf(datei,"R");
	if(eintrag.ff_attrib&FA_HIDDEN) fprintf(datei,"H");
	if(eintrag.ff_attrib&FA_SYSTEM) fprintf(datei,"S");
	if(eintrag.ff_attrib&FA_LABEL) fprintf(datei,"L");
	if(eintrag.ff_attrib&FA_ARCH) fprintf(datei,"A");
	fprintf(datei,"\n");
	}

int dodir(char *dirname,int tiefe,FILE *ausgabedatei)
	{
	char pfadalt[80];
	int test,drivealt;
	struct ffblk eintrag;
	
	drivealt=Dgetdrv();
	if(dirname[1]==':')
		if((dirname[0]>='A')&&(dirname[0]<='Z'))
			Dsetdrv((int)(dirname[0]-'A'));
		else if((dirname[0]>='a')&&(dirname[0]<='z'))
				Dsetdrv((int)(dirname[0]-'a'));
	Dgetpath(pfadalt,0);
	if(!pfadalt[0]) strcpy(pfadalt,"\\");
	if(!Dsetpath(dirname))
		{
		test=findfirst("*.*",&eintrag,0);
			while(test!=EOF)
				{
				ausgabe(eintrag,tiefe,ausgabedatei);
				test=findnext(&eintrag);
				}
		test=findfirst("*.*",&eintrag,FA_DIREC);
			while(test!=EOF)
				{
				if(eintrag.ff_attrib&FA_DIREC)
					{
					if((strcmp(eintrag.ff_name,"."))&&
						(strcmp(eintrag.ff_name,"..")))
							{
							ausgabe(eintrag,tiefe,ausgabedatei);
							if(tiefe>=0)
								dodir(eintrag.ff_name,tiefe+1,ausgabedatei);
							}
					}
				test=findnext(&eintrag);
				}
		Dsetpath(pfadalt);
		Dsetdrv(drivealt);
		return(0);
		}
	else return(1);
	}


int main(int argc,char *argv[])
	{
	int rekursiv=-1,i,test=1;
	char dateiname[80];
	FILE *datei;
	dateiname[0]=0;
	if(argc==1)
		{
		test=dodir(".",0,stdout);
		}
	else if(argc>=2) 
		{
		if(argc>2)
			for(i=2; i<argc; i++)
				{
				if((!strcmp(argv[i],"-r"))||(!strcmp(argv[i],"-R")))
					rekursiv=0;
				if(argv[i][0]=='>') strcpy(dateiname,&argv[i][1]);
				}
		if(dateiname[0])
			{
			if(datei=fopen(dateiname,"w+"))
				{
				test=dodir(argv[1],rekursiv,datei);
				fclose(datei);
				}
			else return 3;
			}
		else test=dodir(argv[1],rekursiv,stdout);
		}
	return test;
	}