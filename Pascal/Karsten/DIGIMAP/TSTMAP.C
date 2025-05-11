/***********************************************************************
***                     T S T M A P . T O S                          ***
***********************************************************************/

#include <stdio.h>
#include <string.h>
#include <ext.h>
#include <stdlib.h>

#define Def_File "DIGIMAP.DAT"
#define Err_File "DIGIMAP.TST"

FILE *dat,*err;
int errcount= 0;

int test(char *line)
{
	char new[255];
	int help,i;
	
	help = 0;
	if (line[0] != '#')
	{
		if (strstr(line,"()") != NULL) help = 2;
		strcpy(new,line);
		while (*line != ' ') 
			line++;
		*line = '\0';
		i = 0;
		while (new[i] != ',') i++;
		if ((new[i+1] == ' ') || (new[i+1] == ',')) help |= 1; 
	};
	if (help != 0) errcount++;
return help;
}

void write_err(char *s,int i)
{
	if (i != 0) 
	{
		fputs(s,err);
		switch (i)
		{
			case 1: fputs(": Locator fehlt\r\n",err);
					break;
			case 2:	fputs(": Links fehlen\r\n",err);
			        break;
			case 3: fputs(": Locator und Links fehlen\r\n",err);
					break;
		}
	}
}

int main(void)
{
	puts("TSTMAP V.0.1 ST von DC7OS\n\r\n");
	if ((dat = fopen(Def_File,"r")) != NULL)
	{
		if ((err = fopen(Err_File,"w")) != NULL)
		{
			char line[255];
			while (fgets(line,255,dat) != NULL)
			{
				int i = test(line);
				write_err(line,i);
			}
			fflush(err);
			fclose(err);
			if (errcount > 0)
			{	
				char val[9],str[80];
				itoa(errcount,val,10);
				strcpy(str,"Bei ");
				strcat(str,val);
				strcat(str," Digipeatern fehlen Daten\r\n");
				puts(str);
				puts("Weitere Infos in: DIGIMAP.TST\n\r");
			}
		}
		else puts("Kann Ausgabe-File nicht îffnen \n\r");
		fclose(dat);
	}
	else puts("Kann DIGIMAP.DAT nicht lesen\n\r");	
	puts("\n\nBitte <RETURN> drÅcken!"); getch();
	return 0;
}

		