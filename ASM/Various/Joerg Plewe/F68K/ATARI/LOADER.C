/********************************************************************

	Loader program for a F68K image file
	
	
	This loader tries to open a file F68K.CFG which
	holds information about the F68K system to be loaded.
	
	
********************************************************************/
#define DEBUG


#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h> 
 
 
#define CODESIZE 0x20000L
#define DATASIZE 0x20000L
#define TIBSIZE  2048
#define MAX_DEVICES 10
#define BPB  2048                 /* Bytes Per Block */

#define FALSE (0)
#define TRUE (-1)

#define CONSOLE 2

#define fsize(x) Fseek(0L,fileno(x),2)



long cdecl key_quest();
long cdecl key();
void cdecl emit();
long cdecl r_w();
long cdecl writesys();
long cdecl readsys();

void read_paras(long*);
void read_segments(void**,void**);

char devicename[MAX_DEVICES][FILENAME_MAX];
FILE* device[MAX_DEVICES];
FILE* infile;
long roottable[MAX_DEVICES*2 +1]; 

long codesz = CODESIZE;
long datasz = DATASIZE; 
char imagename[FILENAME_MAX] = "F68K.IMG";
char outfilename[FILENAME_MAX] = "F68K.OUT";
char cfgname[FILENAME_MAX] = "F68K.CFG";

void main(int argc, const char *argv[])
{
void *codeseg,*dataseg;


long keytable[]		= {1, (long)key};
long keyqtable[]	= {1, (long)key_quest};
long emittable[]	= {1, (long)emit};
long r_wtable[]		= {1, (long)r_w};
long readsystable[]	= {1, (long)readsys};
long writesystable[]	= {1, (long)writesys};

struct forthparas
{
	long registers[16];	/* to be filled by F68K */
 	void *data;		/* A3 */
	void *code;		/* A5 */
	void *datastack;	/* A6 */
	void *retstack;  	/* A7 */
	void *TIBptr;
	long codelen;
	long datalen;
	void *emittable;
	void *keytable;
	void *keyqtable;
	void *r_wtable;
	void *readsystable;
	void *writesystable;
	void *roottable;
} forthparas; 

typedef void cdecl FUNC(struct forthparas*);

 
	forthparas.emittable 	= emittable;
	forthparas.keytable 	= keytable;
	forthparas.keyqtable 	= keyqtable;
	forthparas.r_wtable 	= r_wtable;
	forthparas.readsystable = readsystable;
	forthparas.writesystable= writesystable;
	forthparas.roottable 	= roottable;


	if(argc==2)  strcpy(cfgname,argv[1]);


        read_paras(roottable);
        forthparas.codelen	= codesz;
        forthparas.datalen	= datasz; 
       
        read_segments(&codeseg,&dataseg);
        forthparas.code		= codeseg;
        forthparas.data		= dataseg;
        forthparas.datastack	= (void*)((long)dataseg+datasz-TIBSIZE);
        forthparas.retstack	= (void*)((long)dataseg+datasz);
        forthparas.TIBptr	= (void*)((long)dataseg+datasz-TIBSIZE);
        
        Super(0);
		(*(FUNC*)codeseg)(&forthparas);

}


/************************************************************************
*                                                                       *
*       the F68K I/O-functions                                          *
*                                                                       *
************************************************************************/
long cdecl key_quest()   
{  
        return (long)Bconstat(CONSOLE);

}

long cdecl key()   
{  
        return (long)Bconin(CONSOLE);
}

void cdecl emit(ch)   
long ch;
{
        Bconout(CONSOLE,(int)ch);
}

 
long cdecl r_w(buffer,block,flag)   
void *buffer;
long block,flag;
{
int i, dev;
long rootblk=0L, maxblock=0L;
char buf[10];   /* buffer for number conversion */
int handle;
#ifdef DEBUG
char message[100];    /* this is for the errormessage */
#endif

        for(i=0; i<roottable[0]; i++)  /* find device */
                if( (roottable[2*i+1] >= rootblk) && (block >= roottable[2*i+1]))
                        {
                        maxblock += roottable[2*i+2];
                        rootblk = roottable[2*i+1];
                        dev = i;
                        }
                                       
        if(block >= maxblock)   /* block in range? */
        	{
         	goto bad;
         	}

	if(Mediach(0) != 0)       /* Disk A only!! */ 
		{
		rewind(device[dev]);
		fclose(device[dev]);
		device[dev]=fopen(devicename[dev],"rb+");
		}

	handle = fileno(device[dev]);  /* never trust standard functions! */

        if( Fseek((block-rootblk)*BPB,handle,0)!=(block-rootblk)*BPB)
                {
				goto bad;
                }

        if(flag!=0L)  
                {
                if( Fwrite(handle,BPB,buffer)!=BPB)
                        {
                        goto bad;
                        }
                }
        else
                {
                if( Fread(handle,BPB,buffer)!=BPB)
                        {
                        goto bad;
                        }
                }
        
        return TRUE;
        
bad:        

#ifdef DEBUG
message[0]=0;
strcpy(message,"\n*** F68K loader warning:\
 tried to reach physical block: ");
printf(strcat(message,strcat(ultoa(block,buf,10)," ***\n")));
#endif
	return FALSE;  
}




long cdecl readsys(buffer,count)
unsigned long *buffer, count;
{
  
        if ( fread(buffer,count,1,infile) != 1)
                {
                return FALSE;
                }
                        
        return TRUE;
}


long cdecl writesys(buffer,count)
unsigned long *buffer, count;
{
static FILE *out = NULL;

        if(!out)
       	if( (out = fopen(outfilename,"wb"))== NULL)    
               	{
               	return FALSE;
               	}

        if ( fwrite(buffer,count,1,out) != 1)
                {
                return FALSE;
                }
                        
        return TRUE;
}

/************************************************************************
*       end of I/O functions                                            *
************************************************************************/



void read_paras(roottable)
long *roottable;
{
FILE *paras;
int devices, dev;
long devicesize[MAX_DEVICES];
char infilename[FILENAME_MAX];
int i;
long startblock = 0;


        if( (paras=fopen(cfgname,"r"))==NULL)  
                {
                fprintf(stderr,"*** F68K loader warning: configuration file F68K.CFG not found\n");
                return;
                }
        if( !fscanf(paras,"image: %s%*d\n",imagename))
                fprintf(stderr,"*** F68K loader warning: no imagefile given in F68K.CFG, suppose F68K.IMG\n");
        if( !fscanf(paras,"code: 0x%lx%*d\n",&codesz))
                fprintf(stderr,"*** F68K loader warning: no codesize given in F68K.CFG, suppose %ld\n",CODESIZE);
        if( !fscanf(paras,"data: 0x%lx%*d\n",&datasz))
                fprintf(stderr,"*** F68K loader warning: no datasize given in F68K.CFG, suppose %ld\n",DATASIZE);
        if( !fscanf(paras,"input: %s%*d\n", infilename))
                {
                fprintf(stderr,"*** F68K loader warning: no input file given in F68K.CFG, suppose F68K.IN\n");
                strcpy(infilename,"F68K.IN");
                }
        if( (infile = fopen(infilename,"rb"))==NULL)
                fprintf(stderr,"*** F68K loader warning: cannot open input file, READSYS not available\n");
        if( !fscanf(paras,"output: %s%*d\n", outfilename))
                fprintf(stderr,"*** F68K loader warning: no output file given in F68K.CFG, suppose F68K.OUT\n");
        if( !fscanf(paras,"devices: %d%*d\n",&devices))
                fprintf(stderr,"*** F68K loader warning: no number of devices given in F68K.CFG\n");
        if( devices == 0)
                fprintf(stderr,"*** F68K loader warning: no block storage device available\n");
        if( devices > MAX_DEVICES )
                {
                fprintf(stderr,"*** F68K loader error: too much devices (max. %d devices available)\n"); 
                exit(0);
                }
        for(i=0; i<devices; i++)
                {
                if( fscanf(paras,"d%d: ",&dev) && (dev>=0) && (dev<MAX_DEVICES))
                        fscanf(paras,"%s%*d\n",devicename[dev]);
                else
                        {
                        fprintf(stderr,"*** F68K loader error: invalid device specification\n");
                        exit(0);
                        }
                if( (device[dev]=fopen(devicename[dev],"rb+")) != NULL)
                        {
                        devicesize[dev] = fsize(device[dev]);
                        roottable[2*dev+1] = startblock;
                        roottable[2*(dev+1)] = devicesize[dev]/BPB;
#ifdef DEBUG                        
fprintf(stderr,"*** F68K loader message:  \
D%d: (%s) starts with block #%ld  ***\n",dev,devicename[dev],startblock);
#endif
                        startblock += devicesize[dev]/BPB;      
                        }
                else
                        {
                        fprintf(stderr,"*** F68K loader warning: device D%d: cannot be accessed\n",dev);        
                        roottable[2*dev+1] = -1;
                        roottable[2*(dev+1)] = 0;
                        }
                }
        roottable[0] = devices;
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
