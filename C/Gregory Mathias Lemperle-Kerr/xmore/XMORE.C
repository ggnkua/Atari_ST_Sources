#include <stdio.h>
#include <tos.h>
#include <ext.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <mydefs.h>

long	buf[8000];
long	*scb;

void savescreen(void)
	{
	long c;
	
	for(c=0L;c<8000;c++)
		buf[c]=*(scb+c);
		
	}

void restscreen(void)
	{
	long c;
	
	for (c=0L;c<8000;c++)
		*(scb+c)=buf[c];
	}

void moredeg(char *name)
	{
	int fd;
	
	savescreen();
	fd=Fopen(name,READ);
	Fread(fd,34,scb); 
	Fread(fd,32000,scb);
	Fclose(fd);
	while(kbhit())
		getchar();
	while(!kbhit());
	restscreen();
	}

void moredoo(char *name)
	{
	int fd;
	
	savescreen();
	fd=Fopen(name,READ);
	Fread(fd,32000,scb);
	Fclose(fd);
	while(kbhit())
		getchar();
	while(!kbhit());
	restscreen();
	}

int extcmp(char *s1, char *s2)
	{
	while ((*s1!=0)&&(*s2!='='))
		if (*s1!=*s2)
			return(0);
		else
			{
			++s1;
			++s2;
			}
	return(1);
	}

void morerun(
	char	*shellp,
	char	*name,
	char	*progname)
	{
	char *p;
	char prog[128];
	COMMAND line;
	line.command_tail[0]=0;
	
	if ((p=strrchr(progname,','))!=NULL)
		{
		strcpy(line.command_tail,p+1);
		strcat(line.command_tail," ");
		}
	else
		p=progname+strlen(progname);
	strncpy(prog,progname,(long)(p-progname));
	strcat(line.command_tail,name);
	line.length=strlen(line.command_tail);
	printf("%s %s\n",prog,line.command_tail);
	Pexec(0,prog,&line,shellp);
	}

void moreext(
	char	*shellp,
	char	*name)
	{
	char ext[4];
	char *sp;
	char *p;
	int	 i,flag;
	
	strncpy(ext,(p=(strrchr(name,'.')+1)),3);
	if ((p==NULL)||(p==name))
		ext[0]=0;
	for(i=0;i<3;i++)
		if (islower(ext[i]))
			ext[i]=toupper(ext[i]);
	ext[3]=0;
	sp=shellp;
	for(flag=0;flag!=2;flag++)
		{
		shellp=sp;
		while (*shellp != 0)
			{
			if ((*shellp == 'M')&&(*(shellp+1) == 'O')&&(*(shellp+2) == 'R')&&(*(shellp+3) == 'E'))
				if (extcmp(ext,shellp+4))
					{
					morerun(sp,name,shellp+5+strlen(ext));
					flag=1;
					}
			shellp+=strlen(shellp)+1;
			}
		strcpy(ext,"DFT");
		}
	}

int main(
	int		argc,
	char	**argv,
	char	*shellp)
	{
	char	name[16];
	long	l;
	
	scb=Physbase();
	puts("eXtended More V1.0 by Gregory Mathias Lemperle-Kerr\007");
	if (argc)
		{
		strcpy(name,argv[argc-1]);
		if (Fsfirst(name,0)<0)
			puts("Not Found!\007");
		else
			{
			Fgetdta();
			l=strlen(name);
			if (((name[l-3]=='P')&&(name[l-2]=='I'))||((name[l-3]=='p')&&(name[l-2]=='i')))
				moredeg(name);
			else if (((name[l-3]=='D')&&(name[l-1]=='O'))||((name[l-3]=='d')&&(name[l-1]=='o')))
				moredoo(name);
			else
				moreext(shellp,name);
			}
		}
	else
		puts("Need an argument\007!");
	return(0);
	}