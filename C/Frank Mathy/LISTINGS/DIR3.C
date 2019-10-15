#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <string.h>
#include <tos.h>

#define MAXANZAHL 100

void ausgabe(struct ffblk eintrag,int tiefe)
	{
	int i;
	struct ftime *zeit=(struct ftime *) &eintrag.ff_ftime;
	if(tiefe>0) for(i=0; i<tiefe; i++) printf("  ");
	printf("%-12s ",eintrag.ff_name);
	if(eintrag.ff_attrib&FA_DIREC) printf("DIRECTORY ");
	else printf("%-9ld ",eintrag.ff_fsize);
	printf("%02d:%02d:%02dh %02d.%02d.%04d ",
			zeit->ft_hour,zeit->ft_min,zeit->ft_tsec*2,
			zeit->ft_day,zeit->ft_month,zeit->ft_year+1980);
	if(eintrag.ff_attrib&FA_RDONLY) printf("R");
	if(eintrag.ff_attrib&FA_HIDDEN) printf("H");
	if(eintrag.ff_attrib&FA_SYSTEM) printf("S");
	if(eintrag.ff_attrib&FA_LABEL) printf("L");
	if(eintrag.ff_attrib&FA_ARCH) printf("A");
	printf("\n");
	}

int dodir(char *dirname,int tiefe)
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
				ausgabe(eintrag,tiefe);
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
							ausgabe(eintrag,tiefe);
							if(tiefe>=0)
								dodir(eintrag.ff_name,tiefe+1);
							}
					}
				test=findnext(&eintrag);
				}
		if(tiefe>0)
			{
			Dsetpath(pfadalt);
			Dsetdrv(drivealt);
			}
		return(0);
		}
	else return(1);
	}


int main(int argc,char *argv[])
	{
	int rekursiv=-1,i,test=1;
	if(argc==1)
		{
		test=dodir(".",0);
		}
	else if(argc>=2) 
		{
		if(argc>2)
			for(i=2; i<argc; i++)
				if((!strcmp(argv[i],"-r"))||(!strcmp(argv[i],"-R")))
					rekursiv=0;
		test=dodir(argv[1],rekursiv);
		}
	return test;
	}