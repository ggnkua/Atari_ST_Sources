/*
 *	NetList Compiler
 *
 *	Compiles a fidonet nodelist to a text list of nets
 *	and a a string describing the net.
 *
 *	The format is:
 *
 *	<zone>:<net> name, town
 *
 *	Originally written for the BloufGate project by F Arnaud.
 *	Public Domain. May be copied, sold, etc freely.
 *
 */

#include	<stdio.h>
#include	<string.h>
#include	<stdarg.h>
#include	<stdlib.h>
#include	<time.h>
#include	<ctype.h>   
#include	<errno.h>

#define		NLLEN	30

/*#define ATARIST*/

#ifdef ATARIST
#include	<dos.h>
#define 	PATL	"nodelist.???"
#endif

#define 	SLIST_VERSION 	"0.9.2"


/* proto */
int write_net(FILE *,int,int,char *);
void usage(int);
/* global */
int uses_cities=0;


void usage(int x)
{
	printf("usage: nlist [-c] <st-louis-nodelist> [netlist]\n\n");
	exit(x);
}

void main(int argc, char **argv)
{
	FILE *nl;
	FILE *lzx;
	int curzone, curnet,n,i;
	char nlname[FILENAME_MAX],slxname[FILENAME_MAX];
	char temp[200];
	
#ifdef ATARIST
	struct FILEINFO inf;
#endif
	
	printf("NetList Compiler version %s, Public Domain Apr 1992\n\n",SLIST_VERSION);

	strcpy(slxname,"netlist.blf");
		
	i=1; n=0;
		
	if(argc>i)
	{
		if(stricmp(argv[i],"-c")==0)
		{ 
			i++; 
			uses_cities=1;
		}
	}
		
	if(argc<=i)
	{
#ifdef ATARIST
		*nlname=0;
		if(!dfind(&inf,PATL,0))
		{
			do {
				if( isdigit(inf.name[strlen(PATL)-3])
						&& isdigit(inf.name[strlen(PATL)-2])
						&& isdigit(inf.name[strlen(PATL)-1]) )
					strcpy(nlname,inf.name);
			} while(!dnext(&inf));
		}	
		
		if(!*nlname)
		{
			printf("Can't find nodelist!\n");
			usage(10);
		}
#else
		/* fixme: doesn't work everywhere, should show the usage */
		strcpy(nlname,"nodelist.*");
#endif
	}
	else
	{	
		strcpy(nlname,argv[i++]);
		if(argc>i)
			strcpy(slxname,argv[i]);
	}

	printf("Loading %s\n",nlname);
	
	nl=fopen(nlname,"r"); /* fixme ? */
	if(!nl)
	{
		printf("Can't open nodelist.*\n");
		usage(11);
	}
	else
	{
		lzx=fopen(slxname,"w");
		if(!lzx)
			printf("Can't open netlist output file\n");
		else
		{
			time_t now;
			/* print id */
			now=time(NULL);
			strftime(temp,200,"%d %b %y",localtime(&now));
			fprintf(lzx,"#\n# %s compiled on %s with NetList Compiler vers. %s\n#\n",
					nlname,temp,SLIST_VERSION);
			curzone=0;
			curnet=0;
			
			while(fgets(temp,200,nl)!=NULL)
			{
				if(*temp!=';')
				{
					if(*temp==',')
					{
						n++;
					}
					else if(strncmp(temp,"Zone,",5)==0)
					{
						curzone=atoi(temp+5);
						curnet=curzone;
						printf("Compiling Zone %d, Net %d\n",curzone,curnet);
						if(write_net(lzx,curzone,curnet,temp))
							break;
						n++;
					}
					else if(strncmp(temp,"Region,",7)==0)
					{
						curnet=atoi(temp+7);
						printf("Compiling Zone %d, Net %d\n",curzone,curnet);
						if(write_net(lzx,curzone,curnet,temp))
							break;
						n++;
					}
					else if(strncmp(temp,"Host,",5)==0)
					{
						curnet=atoi(temp+5);
						printf("Compiling Zone %d, Net %d\n",curzone,curnet);
						if(write_net(lzx,curzone,curnet,temp))
							break;
						n++;
					}
					else if( (strncmp(temp,"Pvt,",4)==0) || (strncmp(temp,"Hub,",4)==0) )
					{
						n++;
					}
					else if( (strncmp(temp,"Hold,",5)==0) || (strncmp(temp,"Down,",5)==0) )
					{
						n++;
					}
					else 
						printf("Bad keyword %s\n",temp);
				}
			}
			fclose(lzx);
		}
		fclose(nl);
	}
	printf("%d nodes processed.",n);
}

int write_net(FILE *idx, int zone, int net, char *temp)
{
	char *ptr;
	char t2[200];
	
	/* write node curzone, curnet, node */
	if(!zone || !net)
	{
		printf("Zone or Net 0!\n");
		return 1;
	}
	
	/* <w>,<nb>,System,City,Don't_care => "System,City" */
	ptr=strchr(temp,',');
	if(!ptr)
	{	
		printf("invalid line %s\n",temp);
		return 0;
	}
	ptr=strchr(++ptr,',');
	if(!ptr)
	{	
		printf("invalid line %s\n",temp);
		return 0;
	}
	
	strcpy(t2,++ptr);
	ptr=strchr(t2,',');
	if(!ptr)
	{
		printf("invalid line %s\n",temp);
		return 0;
	}
	
	if(uses_cities)
	{
		ptr=strchr(++ptr,',');
		if(!ptr)
		{
			printf("invalid line %s\n",temp);
			return 0;
		}
	}
	
	*ptr=0; /* truncate the end of the line */
	
	/* _ to spaces */
	ptr=t2;
	while(*ptr++)
		if(*ptr=='_')
			*ptr=' ';

	if(strlen(t2)>=NLLEN)
		t2[NLLEN-1]='\0';
	
	fprintf(idx,"%d:%d %s\n",zone,net,t2);
	
	return 0;
}