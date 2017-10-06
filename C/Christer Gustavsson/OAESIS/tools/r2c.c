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

static long	memory;
	

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

void	printti(FILE *fput,TREEINFO *treeinf)
{	
	TEDINFO	*dumted;
	
	if(treeinf != NULL)
	{
		printti(fput,treeinf->next);
		dumted = (TEDINFO *)(treeinf->tree + memory);
		fprintf(fput,"TEDINFO	%s =\n{\n",treeinf->name);
		fprintf(fput,"	\"%s\",\n",(char *)((long)dumted->te_ptext
						    + memory));
		fprintf(fput,"	\"%s\",\n",(char *)((long)dumted->te_ptmplt
						    + memory));
		fprintf(fput,"	\"%s\",\n",(char *)((long)dumted->te_pvalid
						    + memory));
		fprintf(fput,"	0x%04x,",dumted->te_font);
		fprintf(fput," 0x%04x,",dumted->te_fontid);
		fprintf(fput," 0x%04x,",dumted->te_just);
		fprintf(fput," 0x%04x,",dumted->te_color);
		fprintf(fput," 0x%04x,",dumted->te_fontsize);
		fprintf(fput," 0x%04x,",dumted->te_thickness);
		fprintf(fput," 0x%04x,",dumted->te_txtlen);
		fprintf(fput," 0x%04x\n};\n\n",dumted->te_tmplen);
	
	};
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

void	printib(FILE *fput,TREEINFO *treeinf)
{	
	ICONBLK	*dumib;
	
	if(treeinf != NULL)
	{
		printib(fput,treeinf->next);
		dumib = (ICONBLK *)(treeinf->tree + memory);

		fprintf(fput,"short\tmask%s[] =\n",treeinf->name);
		printwords(fput,(long)dumib->ib_pmask + memory,(((dumib->ib_wicon + 15) >> 4) * dumib->ib_hicon));
		fprintf(fput,";\n");

		fprintf(fput,"short\tdata%s[] =\n",treeinf->name);
		printwords(fput,(long)dumib->ib_pdata + memory,(((dumib->ib_wicon + 15) >> 4) * dumib->ib_hicon));
		fprintf(fput,";\n\n");
		
		
		fprintf(fput,"ICONBLK\t%s =\n{\n",treeinf->name);
		fprintf(fput,"\tmask%s,\n",treeinf->name);
		fprintf(fput,"\tdata%s,\n",treeinf->name);
		fprintf(fput,"	\"%s\",\n",(char *)((long)dumib->ib_ptext
						    + memory));
		fprintf(fput,"	0x%04x,",dumib->ib_char);
		fprintf(fput," 0x%04x,",dumib->ib_xchar);
		fprintf(fput," 0x%04x,",dumib->ib_ychar);
		fprintf(fput," 0x%04x,",dumib->ib_xicon);
		fprintf(fput," 0x%04x,",dumib->ib_yicon);
		fprintf(fput," 0x%04x,",dumib->ib_wicon);
		fprintf(fput," 0x%04x,",dumib->ib_hicon);
		fprintf(fput," 0x%04x,",dumib->ib_xtext);
		fprintf(fput," 0x%04x,",dumib->ib_ytext);
		fprintf(fput," 0x%04x,",dumib->ib_wtext);
		fprintf(fput," 0x%04x\n};\n\n",dumib->ib_htext);
	};
};


void	printci(FILE *fput,TREEINFO *treeinf)
{	
	ICONBLK	*dumblk;
	
	if(treeinf != NULL)
	{
		printci(fput,treeinf->next);
		dumblk = (ICONBLK *)(treeinf->tree + memory);
		fprintf(fput,"CICONBLK\t%s =\n{\n",treeinf->name);
		fprintf(fput,"%ld,\n",(long)dumblk->ib_pmask + memory);
		fprintf(fput,"%ld,\n",(long)dumblk->ib_pdata + memory);
		fprintf(fput,"	\"%s\",\n",(char *)((long)dumblk->ib_ptext
						    + memory));
		fprintf(fput,"	0x%04x,",dumblk->ib_char);
		fprintf(fput," 0x%04x,",dumblk->ib_xchar);
		fprintf(fput," 0x%04x,",dumblk->ib_ychar);
		fprintf(fput," 0x%04x,",dumblk->ib_xicon);
		fprintf(fput," 0x%04x,",dumblk->ib_yicon);
		fprintf(fput," 0x%04x,",dumblk->ib_wicon);
		fprintf(fput," 0x%04x,",dumblk->ib_hicon);
		fprintf(fput," 0x%04x,",dumblk->ib_xtext);
		fprintf(fput," 0x%04x,",dumblk->ib_ytext);
		fprintf(fput," 0x%04x,",dumblk->ib_wtext);
		fprintf(fput," 0x%04x\n}\n\n",dumblk->ib_htext);
		/*fprintf(fput," 0x%04x\n};\n\n",dumblk->ib_resvd);*/
	
	};
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
			

void	main(int argc,char *argv[])
{
	char	c;
	char	infile[200];
	char	orgfile[200],outfile[200];
	char	prefix[500];
	char	printfreestring = 0;
	char	dumstring[200],dumstring2[200];
	char	type;

	FILE	*fput;
	
	int	cicount;
	int	fpin;
	int	i,ibcount;
	int	maxtree = 0;
	int	number;
	int	obj;
	int	ticount,tree;
	

	OBJECT	*treestart;
	OBJECT	**treeindex;

	RSHDR	header;
	
	TREEINFO	*iblist = NULL;	
	TREEINFO	*treeindx = NULL;
	TREEINFO	*tilist = NULL;
	TREEINFO	*cilist = NULL;
		
	
	strcpy(orgfile,argv[1]);
	
	strcpy(infile,stripext(orgfile));
	strcat(infile,".HRD");
	fpin = (short)Fopen(infile,0);
	
	strcpy(outfile,stripext(orgfile));
	
	strcat(outfile,".H");
	
	fput = fopen(outfile,"w");
	
	printf("Converting file %s -> %s\n",infile,outfile);

	fprintf(fput,"#include\t<aesbind.h>\n\n");
	
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
				maxtree = tree;
				break;
			
			case	2:	
			case	3:
				fprintf(fput,"%d\n",tree);
				printfreestring = 1;
				break;
				
			default:
				fprintf(fput,"%d\n",number);
		};
		
		Fread(fpin,1,&type);
	};	
	
	fprintf(fput,"\n");
	
	for(i = 0; i <= maxtree; i++)
	{
		fprintf(fput,"extern	OBJECT	%s[];\n",find(i,treeindx));
	};
	
	if(printfreestring)
		fprintf(fput,"\nextern char\t*fr_string[];\n");
	
	Fclose(fpin);
	fclose(fput);
		
	strcpy(outfile,stripext(orgfile));
	strcat(outfile,".C");
				
		
	strcpy(infile,stripext(orgfile));
		
	strcat(infile,".RSC");
	printf("Converting file %s -> %s\n",infile,outfile);
	{
		fpin = (short)Fopen(infile,0);			
		Fread (fpin, (long) sizeof(RSHDR), &header);
					
		memory = (long)Malloc((long)header.rsh_rssize);
		if (memory != 0)
		{
			Fseek (0L,fpin,0);
			Fread (fpin,(long)header.rsh_rssize,(void *)memory);
			Fclose (fpin);
				
			fput = fopen (outfile,"w");

			fprintf(fput,"#include\t<aesbind.h>\n\n");
			
			treeindex = (OBJECT **)(memory + header.rsh_trindex);
			
			
			for(tree = 0; tree < header.rsh_ntree; tree++)
			{
				cicount =0;
				ticount = 0;
				ibcount = 0;
				strcpy(prefix,find(tree,treeindx));
				prefix[(int)strlen(prefix) -3] = 0;
				treestart = (OBJECT *)((long)treeindex[tree] + (long)memory);
				
				obj = 0;
				
				do
				{
					switch(treestart[obj].ob_type)
					{
						case	G_TEXT:
						case	G_BOXTEXT:
						case	G_FTEXT:
						case	G_FBOXTEXT:
							strcpy(dumstring,prefix);
							strcat(dumstring,"ti");
							sprintf(dumstring2,"%d",ticount);
							strcat(dumstring,dumstring2);
							insert(treestart[obj].ob_spec.index,dumstring,&tilist);
							ticount++;
							break;
						case	G_ICON:
							strcpy(dumstring,prefix);
							strcat(dumstring,"ib");
							sprintf(dumstring2,"%d",ibcount);
							strcat(dumstring,dumstring2);
							insert(treestart[obj].ob_spec.index,dumstring,&iblist);
							ibcount++;
							break;
						case	33:
							strcpy(dumstring,prefix);
							strcat(dumstring,"ci");
							sprintf(dumstring2,"%d",cicount);
							strcat(dumstring,dumstring2);
							insert(treestart[obj].ob_spec.index,dumstring,&cilist);
							cicount++;
							break;
					};
					
					if(treestart[obj].ob_flags & LASTOB)
					{
						break;
					};
					
					obj++;
				}while(TRUE);
				printti(fput,tilist);

				printci(fput,cilist);				
				
				printib(fput,iblist);
				
				fprintf(fput,"OBJECT	%s[]	=\n{",find(tree,treeindx));
				obj = 0;
				do
				{
					fprintf(fput,"	0x%04x, ",treestart[obj].ob_next);
					fprintf(fput,"0x%04x, ",treestart[obj].ob_head);
					fprintf(fput,"0x%04x, ",treestart[obj].ob_tail);
					switch(treestart[obj].ob_type)
					{
						case	G_BOX:
										fprintf(fput,"G_BOX		,");
										break;
						case	G_TEXT:
										fprintf(fput,"G_TEXT		,");
										break;
						case	G_BOXTEXT:
										fprintf(fput,"G_BOXTEXT	,");
										break;
						case	G_IMAGE:
										fprintf(fput,"G_IMAGE		,");
										break;
						case	G_USERDEF:
										fprintf(fput,"G_USERDEF	,");
										break;
						case	G_IBOX:
										fprintf(fput,"G_IBOX		,");
										break;
						case	G_BUTTON:
										fprintf(fput,"G_BUTTON	,");
										break;
						case	G_BOXCHAR:
										fprintf(fput,"G_BOXCHAR	,");
										break;
						case	G_STRING:
										fprintf(fput,"G_STRING	,");
										break;
						case	G_FTEXT:
										fprintf(fput,"G_FTEXT		,");
										break;
						case	G_FBOXTEXT:
										fprintf(fput,"G_FBOXTEXT	,");
										break;
						case	G_ICON:
										fprintf(fput,"G_ICON		,");
										break;
						case	G_TITLE:
										fprintf(fput,"G_TITLE		,");
										break;
						case	33:
										fprintf(fput,"G_CICON\t\t,");
										break;
						default:
										fprintf(fput,"0x%04x\t,",treestart[obj].ob_type);		
										break;
					};
					
					fprintf(fput,"0x%04x, ",treestart[obj].ob_flags);
					fprintf(fput,"0x%04x, ",treestart[obj].ob_state);
					
					switch(treestart[obj].ob_type)
					{
						case	G_TEXT:
						case	G_BOXTEXT:
						case	G_FTEXT:
						case	G_FBOXTEXT:
										fprintf(fput,"(long)(&%s), ",find(treestart[obj].ob_spec.index,tilist));
										break;
						case	G_IMAGE:
										fprintf(fput,"G_IMAGE		,");
										break;
						case	G_USERDEF:
										fprintf(fput,"G_USERDEF	,");
										break;
						case	G_BUTTON:
						case	G_STRING:
						case	G_TITLE:
			   fprintf(fput,"(long)\"%s\", ",(char *)(memory +					   								       treestart[obj].ob_spec.index));
										break;
						case	G_ICON:
										fprintf(fput,"(long)(&%s), ",find(treestart[obj].ob_spec.index,iblist));
										break;
						case	G_BOX:
						case	G_IBOX:
						case	G_BOXCHAR:
						default:
										fprintf(fput,"0x%08lxL, ",treestart[obj].ob_spec.index);
										break;
					};
					
					fprintf(fput,"0x%04x, ",treestart[obj].ob_x);
					fprintf(fput,"0x%04x, ",treestart[obj].ob_y);
					fprintf(fput,"0x%04x, ",treestart[obj].ob_width);
					fprintf(fput,"0x%04x",treestart[obj].ob_height);
					
					if(treestart[obj].ob_flags & LASTOB)
					{
						break;
					};
					
					fprintf(fput,",\n");
					
					obj++;
				}while(TRUE);
				
				fprintf(fput,"\n};\n\n");
				
				
				
				delete(&tilist);
				delete(&cilist);
				delete(&iblist);
			};
			
			if(header.rsh_nstring)
			{
				fprintf(fput,"\nchar\t*fr_string[] =\n{\n");
				
				i = 0;
				
				while(1)
				{
					fprintf(fput,"\t\"%s\"",(char *)(((long *)((long)header.rsh_frstr + memory))[i] + memory));		
				
					i++;
					
					if(i == header.rsh_nstring)
						break;
						
					fprintf(fput,",\n");
				};

				fprintf(fput,"\n};\n");
			};
						
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
