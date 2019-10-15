#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <string.h>
#include <tos.h>

int dodir(char *dirname)
	{
	char pfadalt[80],drivealt;
	int test;
	struct ffblk eintrag;
	struct ftime *zeit=(struct ftime *) &eintrag.ff_ftime;
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
		test=findfirst("*.*",&eintrag,FA_DIREC);
			while(test!=EOF)
				{
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
	int test;
	if(argc==1) 
		test=dodir(".");
	else if(argc==2) 
		test=dodir(argv[1]);
	else
		{
		printf("Erforderlicher Parameter: <suchmuster>\n");
		return 2;
		}
	return test;
	}