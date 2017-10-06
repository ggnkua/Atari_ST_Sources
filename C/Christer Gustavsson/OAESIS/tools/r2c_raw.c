#define	__TCC_COMPAT__

#include	<aesbind.h>
#include	<osbind.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#define TRUE	1

typedef struct treeinfo
{
	long	tree;
	
	char	*name;
	
	struct	treeinfo	*next;
}TREEINFO;

static unsigned char *memory;
	

char	*stripext(char *instring)
{
	static char	outstring[100];
	
	static int	i;
	
	i = 0;
	
	while((instring[i] != 0) & (instring[i] != '.'))
	{
		outstring[i] = instring[i];
		i++;
	};
	
	outstring[i] = 0;
	
	return(outstring);
};


void	insert(long tree,char *name,TREEINFO	**treeinf)
{
	TREEINFO	*treedum;
	
	treedum = (TREEINFO *)malloc(sizeof(TREEINFO));
	treedum->next = *treeinf;
	*treeinf = treedum;
	treedum->name = (char *)malloc(strlen(name)+1);
	strcpy(treedum->name,name);
	treedum->tree = tree;
};

void	delete(TREEINFO **treeinf)
{
	TREEINFO	*treedum;
	
	while(*treeinf != NULL)
	{
		free((*treeinf)->name);
		treedum = (*treeinf)->next;
		free(*treeinf);
		*treeinf = treedum;
	};
};

char	*find(long tree,TREEINFO *treeinf)
{
	TREEINFO	*treedum;
	
	treedum = treeinf;
	
	while(treedum != NULL)
	{
		if(tree == treedum->tree)
		{
			return(treedum->name);
		};
		
		treedum = treedum->next;
	};
	
	return(NULL);
};

void	printwords(FILE *fput,long mem,long nr)
{
	short	i;
	
	fprintf(fput,"{\n\t");

	for(i = 0; i < nr; i++)
	{
		if(i)
			fprintf(fput,",");
			
		fprintf(fput,"0x%04x",((short *)mem)[i]);
	};

	fprintf(fput,"\n}");
};

void	nfsprint(FILE *fput,char *pc)
{
	while (*pc != '\0')
		if ((unsigned int) *pc < 32) 
		{
			fprintf (fput, "\\%u", *pc);
			pc++;
		}
		else
		{
			fprintf (fput, "%c", *pc);
			pc++;
		};
};		
			

void	main(int argc,char *argv[]) {
	char	c;
	char	infile[200];
	char	orgfile[200],outfile[200];
	char	dumstring[200];
	char	type;

	FILE	*fput;
	
	int	fpin;
	int	i;
	int	number;
	int	tree;
	

	TREEINFO	*treeindx = NULL;
		
	
	strcpy(orgfile,argv[1]);
	
	strcpy(infile,stripext(orgfile));
	strcat(infile,".HRD");
	fpin = (short)Fopen(infile,0);
	
	strcpy(outfile,stripext(orgfile));
	
	strcat(outfile,".H");
	
	fput = fopen(outfile,"w");
	
	printf("Converting file %s -> %s\n",infile,outfile);

	fprintf(fput,"extern char %s[];\n\n",stripext(orgfile));

	Fread(fpin,8,dumstring);
	
	Fread(fpin,1,&type);
	
	while(type != 6)
	{
		i = 0;
		
		fprintf(fput,"#define	");
		
		Fread(fpin,1,dumstring);
	
		Fread(fpin,2,&tree);
		
		Fread(fpin,2,&number);
		
		Fread(fpin,1,&c);
	
		while(c)
		{
			dumstring[i] = c;
			i++;
			fprintf(fput,"%c",c);
			Fread(fpin,1L,&c);
		}while(c);
			
		dumstring[i] = 0;
	
		fprintf(fput,"	");
	
		switch(type)
		{
			case	0:
			case	1:		
				fprintf(fput,"%d\n",tree);
				strlwr(dumstring);
				strcat(dumstring,"tad");
				insert(tree,dumstring,&treeindx);
				break;
			
			case	2:	
			case	3:
				fprintf(fput,"%d\n",tree);
				break;
				
			default:
				fprintf(fput,"%d\n",number);
		};
		
		Fread(fpin,1,&type);
	};	
	
	fprintf(fput,"\n");
		
	Fclose(fpin);
	fclose(fput);
		
	strcpy(outfile,stripext(orgfile));
	strcat(outfile,".C");
				
		
	strcpy(infile,stripext(orgfile));
		
	strcat(infile,".RSC");
	printf("Converting file %s -> %s\n",infile,outfile);
	
	{
		long size;
		
		fpin = (short)Fopen(infile,0);
		size = Fseek(0,fpin,2);
		Fseek(0,fpin,0);
					
		memory = (unsigned char *)Malloc(size);

		if(memory != 0) {
			long i = 0;
			
			Fread(fpin,size,memory);
			Fclose (fpin);
				
			fput = fopen(outfile,"w");

			fprintf(fput,"char %s[] = {\n",stripext(orgfile));

			while(i < size) {
				fprintf(fput,"0x%02x",memory[i]);
				
				if(i < (size - 1)) {
					fprintf(fput,", ");
				};
				
				if((i % 8) == 7) {
					fprintf(fput,"\n");
				};
				
				i++;
			};
			
			fprintf(fput,"\n};\n");
			
			fclose (fput);
			
			Mfree ((void *)memory);
		}
		else
		{
			printf("Not enough memory to run!\nPress return to continue.\n");
			getchar();
		};
		
	};

	delete(&treeindx);
	
};
