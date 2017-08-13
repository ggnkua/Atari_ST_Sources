
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>
#include <math.h>
#include <conio.h>

#include "main.h"
#include "datatypes.h"
#include "filestuff.h"
#include "arj_convert.h"
#include "image.h"


char linkerlist_file[256] = "linkerlist.txt";
char linkerlist[65536];



char packer_fn[MAXAA]	= "arjbeta.exe";
char arj_arg1[MAXAA]	= " a";
char arj_arg2[MAXAA]	= " -m4";
char archive_name[MAXAA]= "1.ARJ";	// archive filename
char input_name[MAXAA]	= "1.PRG";	// input filename

char image_fn[MAXAA];
char boot_fn[MAXAA];
char kernel_fn[MAXAA];

char space[] = " ";

char commandline[CMDMAX];


void build_commandline()
{
	strcpy(commandline, packer_fn	);
	strcat(commandline, arj_arg1	);
	strcat(commandline, arj_arg2	);
	strcat(commandline, space		);
	strcat(commandline, archive_name);	// archive filename
	strcat(commandline, space		);
	strcat(commandline, input_name	);	// input filename
	//printf("\n\n%s\n",commandline);
	printf("\n");
}


int arj_pack()
{
	printf("\npacking: %s\n",input_name);

	build_commandline();
	system(commandline);
	convert_arj_file();
	return 0;
}

char * skip_line(char *p)
{
	while( (*p!=0x0A)&&(*p!=0x00) ) p++;
	p++;
	if(*p == 0x00) p=0;
	return p;
}

char * search_string(char *p,char *s)
{
	int slen=strlen(s);
	int i=0;

	do
	{
		if(p[i]!=s[i])
		{
			p = skip_line(p);
			if(p==0) return 0;
			i=0;
		}
		else
		{
			i++;
			if(i==slen)
			{
				p = skip_line(p);	// skip rest of line
				return p;
			}
		}
	}while(1);
	return 0;
}


char * copy_line(char *p,char *out)
{
	while ( (*p!=0x0A)&&(*p!=0) )
	{
		*out++=*p++;
	}
	if( out[-1] == 0x0D) out--;
	*out++=0;
	p++;		// skip 0x0A
	return p;
}

char * skip_whitelines(char *p)
{
	do
	{
		if(*p==0) return 0;
		if(*p==0x0D) p++;
		if(*p==0x0A) p++;
		else return p;
	}while(1);

	return 0;

}

void build_archive_name()
{
	int i,slen;

	slen = strlen(input_name);
	strcpy(archive_name,input_name);

	i=slen-1;
	while (archive_name[i]!='.') i--;

	archive_name[i+1] = 0;
	strcat(archive_name,"ARJ");

//	printf("\n%s",archive_name);
}


int process_files()
{
	char *p;
	int pack_file;

	p = linkerlist;
	p = search_string(p,"#IMAGE");
	copy_line(p,image_fn);

	p = linkerlist;
	p = search_string(p,"#BOOT");
	copy_line(p,boot_fn);

	p = linkerlist;
	p = search_string(p,"#KERNEL");
	copy_line(p,kernel_fn);

	printf("\nimagefile : %s\n",image_fn  );
	printf("\nbootfile  : %s\n",boot_fn   );
	printf("\nkernelfile: %s\n",kernel_fn );

	printf("\n\n----------------------------------------------\n\n");

	load_imagefile();

	write_boot();

	write_kernel();


	p = linkerlist;
	p = search_string(p,"#FILES");
	if(p==0) return -1;

	do
	{
		pack_file = 0;
		if(*p =='*')
		{
			pack_file = 1;
			p++;
		}

		p = copy_line(p,input_name);
		
		build_archive_name();

		if(pack_file)
		{
			arj_pack();
		}
		else
		{
			strcpy(archive_name,input_name);
		}

		printf("\nwriting to image: %s\n",archive_name);

		write_file_to_disk(archive_name);

		//printf("\n%s",input_name);
		//printf("\n%s",archive_name);

		p = skip_whitelines(p);

	}while(p!=0);

	save_imagefile();

	return 0;
}


int main(int argc,char **argv)
//int argc;       // amount of arguments (1=only programname)
//char **argv;    // argumentlist
{
	int i;


	printf("\nATARI ST demo linker (w)2013 lsl/checkpoint\n\n");

/*
	printf("\n%i",argc);
	for(i=0;i<argc;i++)
		printf("\n%i: n%s", i, argv[i] );
	getch();
*/
	if(argc>1)
		strcpy(linkerlist_file, argv[1] );	// linkerlist-filename

	memset(linkerlist,0,sizeof(linkerlist) );

	if ( load_file(linkerlist_file,(u8*)linkerlist) == -1)
	{
		printf("\n\n**ERROR** Could not load linkerlist-file!\n");
		getch();
		return -1;
	}

//	printf("\n%s",linkerlist);
//	getch();

	process_files();

	printf("\n\n**DONE**\n");
	getch();
	return 0;
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
	build_commandline();

	system(commandline);

	convert_arj_file();


	printf("\n\n**DONE**\n");
	getch();
	return 0;
}