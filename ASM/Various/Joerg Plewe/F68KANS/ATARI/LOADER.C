/********************************************************************

	Loader program for a F68K image file
	
	
	This loader tries to open a file F68K.CFG which
	holds information about the F68K system to be loaded.
	
	
********************************************************************/
/*#define DEBUG
*/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h> 
#include "loader.h"
 
 
#define CODESIZE 0x20000L
#define DATASIZE 0x20000L
#define TIBSIZE  2048
#define MAX_DEVICES 10
#define BPB  2048                 /* Bytes Per Block */

#define FALSE (0)
#define TRUE (-1)

#define CONSOLE 2

#define fsize(x) Fseek(0L,fileno(x),2)


/*
 * declaration of the BIOS functions
 */
long cdecl key();
long cdecl key_quest();
void cdecl emit();
long cdecl emit_quest();
void cdecl biostest();



/*
 * declaration of internal functions
 */
void parameter(int,char**);
	int getinfiles(char*,int);
void read_paras(void);
void read_segments(void**,void**);


/*
 * some globals
 */
long codesz = CODESIZE;
long datasz = DATASIZE; 
char imagename[FILENAME_MAX] = "F68KANS.IMG";
char cfgname[FILENAME_MAX] = "F68KANS.CFG";

int echo = 0;			/* echo loading files? */

FILE *(infiles[100]);
int current_infile = 0;

extern SI_funcarr SI_BIOS_fa[];
extern SI_funcarr SI_CLIB_fa[];
extern SI_funcarr SI_FLOT_fa[];
extern SI_funcarr SI_PBGI_fa[];

/*
 * main
 */
int main(int argc, const char *argv[])
{
void *codeseg,*dataseg;
FORTHPARAS forthparas;

SI_group SI[4];

	/*
	 * initialisation of system interface
	 */
	strcpy(SI[0].SI_id, "BIOS");
	SI[0].SI_fa = SI_BIOS_fa;

	strcpy(SI[1].SI_id, "CLIB");
	SI[1].SI_fa = SI_CLIB_fa;

	strcpy(SI[2].SI_id, "FLOT");
	SI[2].SI_fa = SI_FLOT_fa;

	strcpy(SI[3].SI_id, "PBGI");
	SI[3].SI_fa = SI_PBGI_fa;

	strcpy(SI[4].SI_id, "    ");
	SI[4].SI_fa = NULL;


	parameter(argc,(char**)argv);


	forthparas.si		= SI;

    read_paras();
    forthparas.codelen	= codesz;
    forthparas.datalen	= datasz; 
       
    read_segments(&codeseg,&dataseg);
    forthparas.code		= codeseg;
    forthparas.data		= dataseg;
    forthparas.datastack= (void*)((long)dataseg+datasz-TIBSIZE);
    forthparas.retstack	= (void*)((long)dataseg+datasz);
    forthparas.TIBptr	= (void*)((long)dataseg+datasz-TIBSIZE);
        
    Super(0);
	(*(FUNC*)codeseg)(&forthparas);

	return 0;
}


/*
 * Checking for input files in commadline
 */
void parameter(argc, argv)
int argc;
char** argv;
{
int i, filecntr = 0;

	for(i=1; i<argc; i++)
		{
		if( argv[i][0] == '-' )		/* option */
			{
			switch( argv[i][1] )
				{
				case 'v':	echo = TRUE;	break;
				case 'c':	strcpy(cfgname, &(argv[i][2]));
				case 'f':	filecntr = getinfiles( &(argv[i][2]), filecntr);
				}
			
			}
		else
			{	
			infiles[filecntr++] = fopen(argv[i], "rb");
			}
		}
	infiles[filecntr] = NULL;
}


/*
 * get input files from file
 * return new infile-index
 */
int getinfiles( fname, cntr)
char* fname;
int cntr;
{
FILE* inf;
char name[FILENAME_MAX];

	inf = fopen( fname, "r");
	
	while( fscanf( inf, "%s", name ) == 1 )
		infiles[cntr++] = fopen(name, "rb");	

	return cntr;
}



/*
 * read configuration file
 */
void read_paras()
{
FILE *paras;


        if( (paras=fopen(cfgname,"r"))==NULL)  
                {
                fprintf(stderr,"*** F68K loader warning: configuration file F68KANS.CFG not found\n");
                return;
                }
        if( !fscanf(paras,"image: %s%*d\n",imagename))
                fprintf(stderr,"*** F68K loader warning: no imagefile given in F68KANS.CFG, suppose F68KANS.IMG\n");
        if( !fscanf(paras,"code: 0x%lx%*d\n",&codesz))
                fprintf(stderr,"*** F68K loader warning: no codesize given in F68KANS.CFG, suppose %ld\n",CODESIZE);
        if( !fscanf(paras,"data: 0x%lx%*d\n",&datasz))
                fprintf(stderr,"*** F68K loader warning: no datasize given in F68KANS.CFG, suppose %ld\n",DATASIZE);

#ifdef DEBUG
fprintf(stderr,"\n");
#endif
}


void read_segments(codeseg,dataseg)
void **codeseg, **dataseg;
{       
FILE *image;

struct header
{
        int magic;
        unsigned long codesize;
        unsigned long datasize;
        int dont_care[9];
} header;


        if( ((*codeseg = malloc(codesz)) == NULL) | 
            ((*dataseg = malloc(datasz)) == NULL))   
                {
                fprintf(stderr,"*** F68K loader error:  segments allocation fault\n");
                exit(-1);
                }

        if( (image=fopen(imagename,"rb")) == NULL )
                {
                fprintf(stderr,"*** F68K loader error:  image file not found\n");
                exit(-1);
                }
        
        if( read(fileno(image),&header,(long)sizeof(header)) != (long)sizeof(header))
                {
                fprintf(stderr,"*** F68K loader error:  image file read error (header)\n");
                exit(-1);
                }

	if(header.magic != 'JP') 
		{
		fprintf(stderr,"*** F68K loader error:  this is not an F68K image\n");
		exit(-1);
		}

        if( read(fileno(image), *codeseg, header.codesize) != header.codesize)
                {
                fprintf(stderr,"*** F68K loader error:  image file read error (code)\n");
                exit(-1);
                }
        if( read(fileno(image), *dataseg, header.datasize) != header.datasize)
                {
                fprintf(stderr,"*** F68K loader error:  image file read error (data)\n");
                exit(-1);
                }
}
