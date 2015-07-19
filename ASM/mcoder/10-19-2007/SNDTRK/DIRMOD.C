/*
	programme d'affichage d'infos sur les modules

	overflow=nb bytes en trop...

*/
#include <stdio.h>
#include <string.h>
#include <dir.h>
#include <alloc.h>
int cdecl getch(void);

FILE *in,*out;
char mask[128]="*.MOD";
char filename[128];
char filename2[128];
char modulename[30];
long length;
long name;
long ins,longins;
int nbins,nbpat;
/*long debug;*/
/* variables pour la gestion m‚moire */
/*
int memory;
unsigned char huge *store;
unsigned char huge *debut;
*/
int cdecl main(int argc,char *argv[])
{
	int done;
	int i,j;
	struct ffblk ffblk;
	switch(argc)
	{
	case 1:
		break;
	case 2:
		strcpy(mask,argv[1]);
		break;
	default:
		printf("Syntax : DIRMOD [filename]\n");
		return 1;
	}
	done=findfirst(mask,&ffblk,0);
	if (done)
	{
		printf("No file matching %s.\n",mask);
		return 2;
	}
	else
	{
		printf("  Filename  |    Module name     |Length|Type|Pat|Overflow\n");
	}
	while(!done)
	{
		strcpy(filename,ffblk.ff_name);
		in=fopen(filename,"rb");
		if (in==NULL)
		{
			printf("Internal error 1");
			return 3;
		}

		printf("%12s|",filename);
		for(i=0;i<20;i++)
		{
			j=fgetc(in);
			if ((j<' ')||(j>'z'))
			{
				j=' ';
			}
			modulename[i]=(char)j;
		}
		modulename[20]=0;
		printf("%s|",modulename);

		fseek(in,0L,SEEK_END);
		length=ftell(in);
		printf("%6ld|",length);

		fseek(in,0x438L,SEEK_SET);
		name=0L;
		for (i=0;i<4;i++)
		{
			name<<=8;
			name+=fgetc(in);
		}
		if ((name==0x4D2E4B2EL)||(name==0x464C5434L))	/* M.K. ou FLT4 */
		{
			nbins=31;
		}
		else
		{
			nbins=15;
		}
		printf(" %d |",nbins);

		longins=20+30*nbins+128+2;
		if (nbins>15)
		{
			longins+=4;
		}
		if ((longins!=0x43C)&&(longins!=0x258))
		{
			printf("\n%lx\n",longins);		/* d‚buggage */
			printf("Internal error 2");
			return 5;
		}
/*
		printf("\n");
		debug=0;
*/
		for (i=0;i<nbins;i++)
		{
			fseek(in,20+22+i*30,SEEK_SET);
			ins=(((long)fgetc(in))<<8)+fgetc(in);
			ins=ins*2;
			longins+=ins;
/*
			debug+=ins;
			printf("%ld  ",ins);
*/
		}
/*
		printf(":%ld\n",debug);
*/
		ins=20+30*nbins+2;
		if ((ins!=0x3B8)&&(ins!=0x1D8))
		{
			printf("\n%lx\n",ins);			/* d‚buggage */
			printf("Internal error 3");
			return 6;
		}

		fseek(in,ins,SEEK_SET);
		nbpat=-1;
		for (i=0;i<128;i++)
		{
			j=fgetc(in);
			if (j>nbpat)
			{

				nbpat=j;
			}
		}
		nbpat++;
		longins+=(long)nbpat*1024;
		printf("%3d|",nbpat);

		printf("%7ld",length-longins);
		printf("\n");
		fclose(in);

/*
	correction des patterns
*/
		if (length!=longins)
		{
		if (length<longins)
		{
			printf("Correction ? ");
			i=getch();
			printf("\015");
			if ((i=='o')||(i=='O')||(i=='y')||(i=='Y'))
			{
				printf("Correction...");
				strcpy(filename2,filename);
				i=strlen(filename2);
				filename2[i-1]='$';
				filename2[i-2]='$';
				filename2[i-3]='$';
				printf("%s",filename2);
				i=rename(filename,filename2);
				if (i!=0)
				{
					printf("ProblŠme renommage %s en %s\n",filename,filename2);
					return 12;
				}
				in=fopen(filename2,"rb");
				if (in==NULL)
				{
					printf("pb relecture %s",filename2);
					return 13;
				}
				out=fopen(filename,"wb");
				if (out==NULL)
				{
					printf("pb sauvegarde %s",filename);
					return 14;
				}
				for (ins=0;ins<length;ins++)
				{
					fputc(fgetc(in),out);
				}
				for (ins=length;ins<longins;ins++)
				{
					fputc(0,out);
				}
				fclose(in);
				fclose(out);
			}
			printf("\n");
		}


		if (length>longins)
		{
			/* est-ce que l'on r‚duit le module ? */
			printf("Reduce module ? ");
			i=getch();
			printf("\015");
			if ((i=='o')||(i=='O')||(i=='y')||(i=='Y'))
			{
				printf("Reduction...");
				strcpy(filename2,filename);
				i=strlen(filename2);
				filename2[i-1]='$';
				filename2[i-2]='$';
				filename2[i-3]='$';
				printf("%s",filename2);
				i=rename(filename,filename2);
				if (i!=0)
				{
					printf("ProblŠme renommage %s en %s\n",filename,filename2);
					return 12;
				}
				in=fopen(filename2,"rb");
				if (in==NULL)
				{
					printf("pb relecture %s",filename2);
					return 13;
				}
				out=fopen(filename,"wb");
				if (out==NULL)
				{
					printf("pb sauvegarde %s",filename);
					return 14;
				}
				for (ins=0;ins<longins;ins++)
				{
					fputc(fgetc(in),out);
				}
				fclose(in);
				fclose(out);
/*
				memory=0;
				store=(unsigned char far *)farmalloc(dest_len);
				if (store!=NULL)
				{
					memory=1;
					debut=store;
				}

				rename
				in=fopen(filename,"rb");
				if (in==NULL)
				{
					printf("pb lecture %s\n",filename);
				}
				out=fopen(filename,"wb");
				if (out==NULL)
				{
					printf("pb cr‚ation %s\n",filename);
					return 11;
				}


				if (memory==0)
				{
					fseek(out,dest_len,SEEK_SET);
					fputc(d1,out);
				}
				else
				{
					*store=(unsigned char)d1;
					store++;
				}

				if (memory!=0)
				{
					do
					{
						--store;
						fputc(*store,out);
					}
					while(store>debut);
					farfree(debut);
				}
				fclose(in);
				fclose(out);
*/
				printf("\n");
			}
		}


		}
		done=findnext(&ffblk);
	}
	return 0;
}
