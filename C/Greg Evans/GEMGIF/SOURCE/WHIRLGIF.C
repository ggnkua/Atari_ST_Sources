  
/*
 * whirlgif.c
 *
 * Copyright (C) 1995,1996 by Kevin Kadow (kadokev@msg.net)
 * 
 * Based on txtmerge.c
 * Copyright (C) 1990,1991,1992,1993 by Mark Podlipec. 
 * All rights reserved.
 *
 * This software may be freely copied, modified and redistributed
 * without fee provided that this copyright notice is preserved 
 * intact on all copies and modified copies.
 * 
 * There is no warranty or other guarantee of fitness of this software.
 * It is provided solely "as is". The author(s) disclaim(s) all
 * responsibility and liability with respect to this software's usage
 * or its effect upon hardware or computer systems.
 *
 */
 /*
  * Description:
  *
  * This program reads in a sequence of single-image GIF format files and
  * outputs a single multi-image GIF file, suitable for use as an animation.
  *
  * TODO:
  *
  * More options for dealing with the colormap
  *
  * Eventually, I'd like to have this program compare the current image
  * with the previous image and check to see if only a small section of
  * the screen changed from the previous image. Worth a shot.
  */

 /* ATARI ST version compiled by tommya@post3.tele.dk */
 /* Compiler: Lattice 5.52 -14.april 1997 */
 /* Compiler: GCC 2.7.2.2 -7. September 1997
  *  Well, it does not unpack any images, it just copies
  *  the data stream to output file. 
  *  Some functions is just doing nothing...
  */
  
 /*
  * tommya:
  * 6.sep: changed: Graphic Control Extension
  *        changed: gif comment bug
  *
  * Rev 2.01    31Aug96 Kevin Kadow
  *	disposal
  * Rev 2.00	05Feb96 Kevin Kadow
  *	transparency, gif comments,
  * Rev 1.10	29Jan96 Kevin Kadow
  *	first release of whirlgif
  *
  * txtmerge:
  * Rev 1.00	23Jul91	Mark Podlipec
  *	creation
  * Rev 1.01	08Jan92	Mark Podlipec
  *     use all colormaps, not just 1st.
  *
  * 
  */


#define DA_REV "2.01"

#include <stdio.h>
#include <stdlib.h>
#ifdef _USE_STRINGS_H
#include <strings.h>
#else
#include <string.h>
#endif

#include "whirlgif.h"
#ifdef LATTICE
#include <mintbind.h>
#endif

#define MAXVAL  4100            /* maxval of lzw coding size */
#define MAXVALP 4200

/* Tommy: retyped all prototypes
 */
void main(int argc,char *argv[]);
void TheEnd(void);
void TheEnd1(char *p);
void Usage(void);
void GIF_Read_File(FILE *fout,char *fname,int first_image);
void GIF_Decompress(FILE *fp,FILE *fout);
void GIF_Get_Next_Entry(FILE *fp);
void GIF_Add_To_Table(register ULONG body, register ULONG next,register ULONG index);
void GIF_Send_Data(register int index);
void GIF_Init_Table(void);
void GIF_Clear_Table(void);
ULONG GIF_Get_Code(FILE *fp,FILE *fout);
void GIF_Screen_Header(FILE *fp,FILE *fout,int first_time);
void GIF_Image_Header(FILE *fp,FILE *fout,int first_time);
int GIF_Get_Short(FILE *fp,FILE *fout,int first_time);
void GIF_Comment(FILE *fout,char *string);
void GIF_Loop(FILE *fout,unsigned int repeats);
void GIF_GCL(FILE *fout,unsigned int delay);
void Calc_Trans(char *string);
void set_offset(char *string);

/*
 * Set some defaults, these can be changed on the command line
 */
unsigned int loop=DEFAULT_LOOP,loopcount=0,
	use_colormap=DEFAULT_USE_COLORMAP,
	debug_flag=0,
	verbose=0;

int imagex = 0;
int imagey = 0;
int imagec = 0;

/* global settings for offset, transparency */
Global global;

GIF_Color gif_cmap[256];
GIF_Color gif_globalmap[256];
int colors_in_globalmap=0;
int matches_globalmap=FALSE;

GIF_Screen_Hdr gifscrn;
GIF_Image_Hdr gifimage;
GIF_Table table[MAXVALP];

ULONG root_code_size,code_size,CLEAR,EOI,INCSIZE;
ULONG nextab;
ULONG gif_mask[16] = {1,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191,0,0};
ULONG gif_ptwo[16] = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,0,0};


UBYTE gif_buff[MAXVALP];
ULONG gif_block_size;
int num_bits,bits;

int pic_i;
char gif_file_name[BIGSTRING];
int screen_was_last;


void TheEnd(void)
{
	exit(0);
}

void TheEnd1(char *p)
{
	fprintf(stderr,"%s",p);
	TheEnd();
}

void Usage(void)
{
	fprintf(stderr,"\nUsage: whirlgif [-o outfile] [-loop [count]] [-time #delay]\n");
	fprintf(stderr,"\t[-disp_none | -disp_back | -disp_prev | -disp_not]\n");
	fprintf(stderr,"\t[ -i listfile] file1 [ -time #delay] file2 ...\n");
	exit(0);
}

void main(int argc,char *argv[])
{
	FILE * infile, *fout;
	char temp[BIGSTRING];
	int ret,i;
	int count=0;

#ifdef LATTICE
	Pdomain(1);	/* go into MiNT-domain NOW! */
#endif

	fprintf(stderr,"whirlgif Rev %s (C) 1996 by Kevin Kadow\n",DA_REV);
	fprintf(stderr,"                  (C) 1991,1992 by Mark Podlipec\n");
	fprintf(stderr,"Atari ST/TT version compiled "__DATE__" by T.Andersen\n");
	if (argc < 2)
		Usage();
 
	/* set global values */
	screen_was_last = FALSE;
	global.trans.type=TRANS_NONE;
	global.trans.valid=FALSE;
	global.time=DEFAULT_TIME;
	global.left=0;
	global.top=0;
	global.disposal=DEFAULT_DISPOSAL;


	fout=stdout;

#ifdef LATTICE
	fmode(stdout,1);	/* ohhh dear, we must switch to binary mode for stdout */
#endif

	i = 1;
	while( i < argc)
	{
		char *p;
		p = argv[i];
	  /*fprintf(stderr,"Option: %s\n",p);*/
		if ( (p[0] == '-') || (p[0] == '+') )
		{ 
			++p; /* strip off the - */
			switch(p[0])
			{
				case 'v':	/* Give lots of information */
					verbose++;
					i++;
					fprintf(stderr,"Verbose output\n");
					break;

				case 'd':	/* either Debug mode or disposal setting */
					i++;
					if(!strncmp("disp",p,4))
					{
						i++;
						p=argv[1];
						p++;
						if(verbose)
							fprintf(stderr,"Disposal method set\n");
						if(!strcmp("none",p)) 
							global.disposal = DISP_NONE;
						else if(!strcmp("not",p)) 
							global.disposal = DISP_NOT;
						else if(!strcmp("back",p)) 
							global.disposal = DISP_BACK;
						else if(!strcmp("prev",p)) 
							global.disposal = DISP_PREV;
						else global.disposal = DISP_NONE;
					}
					else
					{
						debug_flag++;
						fprintf(stderr,"DEBUG: Debug Level %d\n",debug_flag);
					}
					break;

			case 'l':	/* Enable looping */
				loop=TRUE;
				i++;
				if (*argv[i] !='-')
				{
					/* a loop count was given */
					loopcount=atoi(argv[i++]);
					if (verbose)
						fprintf(stderr,"Loop %d times\n",loopcount);
				}
				else
				{
					/* default to infinite loop */
					loopcount=0;
					if (verbose)
						fputs("Infinite looping enabled\n",stderr);
				}
				break;

				/* not used! */
			case 'u':	/* Use colormap? true or false */
				i++;
				if (atoi(argv[i]) || !strcmp("true",argv[i]))
					use_colormap=1;
				else
					use_colormap=0;
				i++;
				break;

			case 't':	/* either time or transparent */
				i++;
				if (!strcmp("time",p))
				{
					/* Delay time in 1/100's of a second */
					global.time=atoi(argv[i++]);
				}
				else if (!strncmp("trans",p,4))
				{
					if (argv[i])	/* Tommy: now checking for value! */
						Calc_Trans( argv[i] );
					else
					{	fprintf(stderr,"Missing parameter for -trans\n");
						exit(1);
					}
					i++;
				}
				break;

			case 'o':	/* Output file - send output to a given filename */
				i++;
				if (!strncmp("off",p,3))
					set_offset(argv[i]);
				else
					/* It must be 'output, so do that */
					if (NULL==(fout=fopen(argv[i],"wb")))
					{
						fprintf(stderr,"Cannot open %s for output\n",argv[i]);
						exit(1);
					}
					i++;
					break;
			case 'i':	/* input file - file with a list of images */
				i++;
				if (NULL != (infile=fopen(argv[i],"r")))
				{
					while (fgets(gif_file_name,BIGSTRING,infile))
					{
						strtok(gif_file_name,"\n");
						if (!count)
							GIF_Read_File(fout,gif_file_name,1);
						else
							GIF_Read_File(fout,gif_file_name,0);
						count++;
					}
					fclose(infile);
				}
				else
					fprintf(stderr,"Cannot read list file %s\n",argv[i]);
				i++;
				break;

			default: 
				Usage();
				exit(0);
				break;
			}
			continue;
		}
		/* Not an option, must be the name of an input file */
		if(!count)
			GIF_Read_File(fout,argv[i],1);	/* first_time=1 */
		else
			GIF_Read_File(fout,argv[i],0);
		count++;
		i++;
	}
	/* We're done with all the options, finish up */
	if(count >0)
	{
		fputc(';',fout); /* image separator */
		sprintf(temp,"whirlgif %s (C) kadokev@msg.net. %d images",DA_REV,count);
		GIF_Comment(fout,temp);
	}

	fclose(fout);
	fprintf(stderr,"Processed %d files.\n",count);
	exit(0);
}


/*
 * Read a GIF file, outputting to fname as we go.
 * It would be faster to read and write the individual blocks,
 * but eventually we'd like to optimize based on changes from
 * previous images(ie only a small section of the image changed.
 */
void
GIF_Read_File(FILE *fout,char *fname,int first_image)
{
	FILE *fp;
	int ret,i,exit_flag;

	if ( (fp=fopen(fname,"rb"))==0)
	{ 
		fprintf(stderr,"Can't open %s for reading.\n",fname); 
		TheEnd();
	}

	GIF_Screen_Header(fp,fout,first_image);

	/*** read until  ,  separator */
	do
	{	i=fgetc(fp);
		if ( (i<0) && feof(fp))
		{
			fclose(fp);
			TheEnd1("GIF_Read_Header: Unexpected End of File\n");
		}
	} while(i != ',');

	if(first_image)
	{	/* stuff we only do once , the NETSCAPE EXTENSION*/
		if (loop)
			GIF_Loop(fout,loopcount);
	}

	/* Write a Graphic Control Extension */
	if ( global.time || (global.trans.type!=TRANS_NONE && global.trans.valid))
		GIF_GCL(fout,global.time);

	fputc(',',fout); /* image separator */

	GIF_Image_Header(fp,fout,first_image);	/* image description */

	/*FOO*/

	/*** Setup ACTION for IMAGE */

	GIF_Decompress(fp,fout);	/* tommy: 3 args before... */
	fputc(0,fout);  /* block count of zero */

	fclose(fp);
}

void GIF_Decompress(FILE *fp,FILE *fout)
{
	register ULONG code,old;

	pic_i = 0;
	bits=0;
	num_bits=0;
	gif_block_size=0;
	/* starting code size of LZW */
	root_code_size=(fgetc(fp) & 0xff);

	fputc(root_code_size,fout);		/* send it to animated gif */

	GIF_Clear_Table();					/* clear decoding symbol table */

	code=GIF_Get_Code(fp,fout);

	if (code==CLEAR) 
	{
		GIF_Clear_Table(); 
		code=GIF_Get_Code(fp,fout);
	}
	/* write code(or what it currently stands for) to file */
	GIF_Send_Data(code);   
	old=code;
	code=GIF_Get_Code(fp,fout);
	do
	{
		if (table[code].valid==1)    /* if known code */
		{	/* send it's associated string to file */
			GIF_Send_Data(code);
			GIF_Get_Next_Entry(fp);       /* get next table entry (nextab) */
			GIF_Add_To_Table(old,code,nextab);  /* add old+code to table */
			old=code;
		}
		else      /* code doesn't exist */
		{
			GIF_Add_To_Table(old,old,code);   /* add old+old to table */
			GIF_Send_Data(code);
			old=code;
		}
		code=GIF_Get_Code(fp,fout);
		if (code==CLEAR)
		{ 
			GIF_Clear_Table();
			code=GIF_Get_Code(fp,fout);
			GIF_Send_Data(code);
			old=code;
			code=GIF_Get_Code(fp,fout);
		}
	} while(code!=EOI);
}


void GIF_Get_Next_Entry(FILE *fp)
{
   /* table walk to empty spot */

	while(  (table[nextab].valid==1) &&(nextab<MAXVAL) )
		nextab++;

	/* 
	 * Ran out of space?!  Something's gone sour...
	 */

	if (nextab>=MAXVAL)    
	{ 
		fprintf(stderr,"Error: GetNext nextab=%d\n",nextab);
		fclose(fp);
		TheEnd();
	}
	if (nextab==INCSIZE)   /* go to next table size (and LZW code size ) */
	{	/* fprintf(stderr,"GetNext INCSIZE was %d ",nextab); */
		code_size++;
		INCSIZE=(INCSIZE*2)+1;
		if (code_size>=12)
			code_size=12;
		/*   fprintf(stderr,"<%d>",INCSIZE); */
	}
}



/*  body is associated string
    next is code to add to that string to form associated string for
    index
 */     

void GIF_Add_To_Table(register ULONG body, register ULONG next,register ULONG index)
{
	if (index>MAXVAL)
	{ 
		fprintf(stderr,"Error index=%d\n",index);
	}
	else
	{
		table[index].valid=1;
		table[index].data=table[next].first;
		table[index].first=table[body].first;
		table[index].last=body;
	}
}




void GIF_Send_Data(register int index)
{
	register int i,j;
	i=0;
	do         /* table walk to retrieve string associated with index */
	{ 
		gif_buff[i]=table[index].data; 
		i++;
		index=table[index].last;
		if (i>MAXVAL)
		{ 
			fprintf(stderr,"Error: Sending i=%d index=%d\n",i,index);
			TheEnd();
		}
	} while(index>=0);

	/* now invert that string since we retreived it backwards */
	i--;
	for(j=i;j>=0;j--)
	{	/*pic[pic_i] = gif_buff[j] | gif_pix_offset;*/
		pic_i++;
	}
}


/* 
 * initialize string table 
 */
void GIF_Init_Table(void)
{
	register int maxi,i;

	if (debug_flag)
		fprintf(stderr,"Initing Table...");
	maxi=gif_ptwo[root_code_size];
	for(i=0; i<maxi; i++)
	{
		table[i].data=i;   
		table[i].first=i;
		table[i].valid=1;  
		table[i].last = -1;
	}
	CLEAR=maxi; 
	EOI=maxi+1; 
	nextab=maxi+2;
	INCSIZE = (2*maxi)-1;
	code_size=root_code_size+1;
}


/* 
 * clear table 
 */

void GIF_Clear_Table(void)   
{
	register int i;
	if (debug_flag) fprintf(stderr,"Clearing Table...\n");
	for(i=0;i<MAXVAL;i++)
		table[i].valid=0;
	GIF_Init_Table();
}


/* this one simply copies the data stream to the destination. No
 * unpacking or what so ever.
 * /

/*CODE*/
ULONG GIF_Get_Code(FILE *fp,FILE *fout) /* get code depending of current LZW code size */
{
	ULONG code;
	register int tmp;

	while(num_bits < code_size)
	{	/**** if at end of a block, start new block */
		if (gif_block_size==0) 
		{
		tmp = fgetc(fp);
	   if (tmp >= 0 )
   	{
	    fputc(tmp,fout);
   	 gif_block_size=(ULONG)(tmp);
	   }
   	else
   		TheEnd1("EOF in data stream\n");
	}

	tmp = fgetc(fp);
	gif_block_size--;

	if (tmp >= 0)
	{
		fputc(tmp,fout);
		bits |= ( ((ULONG)(tmp) & 0xff) << num_bits );
		num_bits+=8;
	}
	else TheEnd1("EOF in data stream\n");
	}
  
	code = bits & gif_mask[code_size];
	bits >>= code_size;
	num_bits -= code_size; 


	if (code>MAXVAL)
	{ 
		fprintf(stderr,"\nError! in stream=%x \n",code); 
		fprintf(stderr,"CLEAR=%x INCSIZE=%x EOI=%x code_size=%x \n",
                                           CLEAR,INCSIZE,EOI,code_size); 
	code=EOI;
	}

	if (code==INCSIZE)
	{
		if (code_size<12)
		{
			code_size++; INCSIZE=(INCSIZE*2)+1;
		}
		else if (debug_flag)
			fprintf(stderr,"<13?>"); 
	}
	return(code);
}


/* 
 * read and write GIF header 
 */

void GIF_Screen_Header(FILE *fp,FILE *fout,int first_time)
{
	int temp,i;

	for(i=0;i<6;i++)
	{
		temp = fgetc(fp);
		if (i==4 && temp == '7')
			temp='9';
		if (first_time)
			fputc(temp,fout);
	}

	gifscrn.width  = GIF_Get_Short(fp,fout,first_time);
	gifscrn.height = GIF_Get_Short(fp,fout,first_time);
	temp=fgetc(fp);
	if (first_time==TRUE)
		fputc(temp,fout);
	gifscrn.m       =  temp & 0x80;
	gifscrn.cres    = (temp & 0x70) >> 4;
	gifscrn.pixbits =  temp & 0x07;

	gifscrn.bc  = fgetc(fp);

	if (first_time==TRUE) 
	{	/* we really should set the background color to the transparent color */
		fputc(gifscrn.bc,fout);
	}

	temp=fgetc(fp);
	if (first_time==TRUE)
		fputc(temp,fout);
	imagec=gif_ptwo[(1+gifscrn.pixbits)];

	if (first_time)
		colors_in_globalmap=imagec;

	if (verbose)
		fprintf(stderr,"Screen: %dx%dx%d m=%d cres=%d bkgnd=%d pix=%d\n",
			gifscrn.width,gifscrn.height,imagec,gifscrn.m,gifscrn.cres,\
			gifscrn.bc,gifscrn.pixbits);

	if (global.trans.type==TRANS_RGB)
		global.trans.valid=0;

	matches_globalmap=FALSE;

	if (gifscrn.m)
	{
		for (i=0;i<imagec;i++)
		{
			gif_cmap[i].cmap.red = temp = fgetc(fp); 
			if (first_time)	/* save a global colormap */
			{	gif_globalmap[i].cmap.red = temp;
				fputc(temp,fout);
			}
			gif_cmap[i].cmap.green = temp = fgetc(fp); 
			if (first_time)
			{	gif_globalmap[i].cmap.green = temp;
				fputc(temp,fout);
			}
			gif_cmap[i].cmap.blue = temp = fgetc(fp); 
			if (first_time)
			{	gif_globalmap[i].cmap.blue = temp;
				fputc(temp,fout);
			}
			if (global.trans.type==TRANS_RGB && !global.trans.valid)
				if (global.trans.red==gif_cmap[i].cmap.red && 
				 global.trans.green==gif_cmap[i].cmap.green &&
				 global.trans.blue==gif_cmap[i].cmap.blue)
				{
					if(debug_flag>1)
						fprintf(stderr," Transparent match at %d\n",i);
					global.trans.map=i;
					global.trans.valid=TRUE;	/* found the transparent color */
				}
		}
		/* tommya: check for equal colormap in gif as in global color map */
		if ( imagec==colors_in_globalmap )
		{
			matches_globalmap =TRUE;
			for (i=0;i<imagec;i++)
			{	if (gif_cmap[i].cmap.red != gif_globalmap[i].cmap.red )
					matches_globalmap=FALSE;
				if (gif_cmap[i].cmap.green != gif_globalmap[i].cmap.green )
					matches_globalmap=FALSE;
				if (gif_cmap[i].cmap.blue != gif_globalmap[i].cmap.blue )
					matches_globalmap=FALSE;
			}
		}
	}
	screen_was_last = TRUE;
}


/*
 * Image description
 */

void GIF_Image_Header(FILE *fp,FILE *fout,int first_time)
{
	int temp,tnum,i,r,g,b;

	gifimage.left = GIF_Get_Short(fp,fout,1);	/* normally 0 */
	if (global.left)
		gifimage.left+=global.left;

	gifimage.top = GIF_Get_Short(fp,fout,1);	/* normally 0 */
	if (global.top)
		gifimage.top+=global.top;

	gifimage.width  = GIF_Get_Short(fp,fout,1);
	gifimage.height = GIF_Get_Short(fp,fout,1);

	temp=fgetc(fp); 
	gifimage.i        = temp & 0x40;
	gifimage.pixbits  = temp & 0x07;
	gifimage.m        = temp & 0x80;

	/* this forces the local colormap bit to true */

	if (screen_was_last && (first_time==FALSE) && !matches_globalmap)
		temp |= 0x80;

	temp &= 0xf8;
	temp |= gifscrn.pixbits;
	fputc(temp,fout);

	imagex=gifimage.width;
	imagey=gifimage.height;
	tnum=gif_ptwo[(1+gifimage.pixbits)];
	if (verbose)
		fprintf(stderr,"Image: %dx%dx%d (%d,%d) m=%d i=%d pix=%d \n",
		imagex,imagey,tnum,gifimage.left,gifimage.top,
		gifimage.m,gifimage.i,gifimage.pixbits);

	/* if there is an local image cmap, then use it */

	if (gifimage.m)
	{
		if(debug_flag)
			fprintf(stderr,"DEBUG:Transferring local colormap of %d colors\n",imagec);
		for(i=0;i<tnum;i++)
		{
			gif_cmap[i].cmap.red   = r = fgetc(fp);
			gif_cmap[i].cmap.green = g = fgetc(fp);
			gif_cmap[i].cmap.blue  = b = fgetc(fp);
			fputc(r,fout);
			fputc(g,fout);
			fputc(b,fout);
		}
	}  /* else if screen was last not 1st time */
	else if (screen_was_last && (first_time==FALSE) && !matches_globalmap)
	{
		if(debug_flag>1)
			fprintf(stderr,"DEBUG:Writing local colormap of %d colors\n",imagec);
		for(i=0;i<imagec;i++)
		{
			fputc(gif_cmap[i].cmap.red  ,fout);
			fputc(gif_cmap[i].cmap.green,fout);
			fputc(gif_cmap[i].cmap.blue ,fout);
		}
	}
	screen_was_last = FALSE; 
}


/*
 *
 */
int GIF_Get_Short(FILE *fp,FILE *fout,int first_time)
{
	register int temp,tmp1;

	temp=fgetc(fp);
	if (first_time==TRUE)
		fputc(temp,fout);

	tmp1=fgetc(fp);
	if (first_time==TRUE)
		fputc(tmp1,fout);
	return(temp|( (tmp1) << 8 ));
}


/* Comment Extension */

void GIF_Comment(FILE *fout,char *string)
{
	if( !string || !strlen(string))
   {
		/* Bogus string */
		if(debug_flag)
			fprintf(stderr,"GIF_Comment: invalid argument");
		return;
	}
	fputc(0x21,fout);
	fputc(0xFE,fout);
	fputc(strlen(string),fout);	/* tommya: this one was missing! */
	fputs(string,fout);
	fputc(0,fout);
}

/*
 * Write a Netscape loop marker.
 */
void GIF_Loop(FILE *fout,unsigned int repeats)
{
	UBYTE low=0,high=0;

	if(repeats)
	{
		/* non-zero repeat count- Netscape hasn't implemented this yet */
		high=repeats / 256;
		low=repeats % 256;
	}

	fputc(0x21,fout);
	fputc(0xFF,fout);
	fputc(0x0B,fout);
	fputs("NETSCAPE2.0",fout);
	fputc(0x03,fout);
	fputc(0x01,fout);

	fputc(low,fout); /* the delay count - 0 for infinite */
	fputc(high,fout); /* second byte of delay count */
	fputc(0x00,fout); /* terminator */

	if(verbose)
		fprintf(stderr,"Wrote loop extension\n");
}

/*
 * GIF_GCL - add a Control Label to set an inter-frame delay value.
 * AKA Graphic Control Extension
 */

#define DISPOSAL 0x04
#define TRANS_COLOR_FLAG 0x01

void GIF_GCL(FILE *fout,unsigned int delay)
{
	UBYTE low=0,high=0,flag=0;

	if(delay)
	{	/* non-zero delay, figure out low/high bytes */
		high=delay / 256;
		low=delay % 256;
	}

	fputc(0x21,fout);
	fputc(0xF9,fout);
	fputc(0x04,fout);

	if (global.disposal)
		flag |= DISPOSAL;

/*
	tommya: This is not documented anywhere, we take it out!
	if(delay)
		flag |=0x80;
*/

	if (global.trans.valid)
		flag |= TRANS_COLOR_FLAG;

	fputc(flag,fout);

	fputc(low,fout); /* the delay speed - 0 is instantaneous */
	fputc(high,fout); /* second byte of delay count */

	fputc(global.trans.map,fout);	/* transperant color index */
	fputc(0,fout);

	if(debug_flag>1)
	{
		fprintf(stderr,"GCL: delay %d",delay);
		if (global.trans.valid)
			fprintf(stderr," Transparent: %d",global.trans.map);
		fputc('\n',stderr);
	}
}


void Calc_Trans(char *string)
{
	if(string[0] != '#')
	{	/* just a index to colormap */
		global.trans.type=TRANS_MAP;
		global.trans.map=atoi(string);
		global.trans.valid=1;
	}
	else
	{	/* it's a RGB value */
		int r,g,b;
		string++;
		if (3==sscanf(string,"%2x%2x%2x",&r,&g,&b))
		{
			global.trans.red=r;
			global.trans.green=g;
			global.trans.blue=b;
			global.trans.type=TRANS_RGB;
			if(debug_flag)
				fprintf(stderr,"Transparent RGB=(%x,%x,%x)\n",r,g,b);
		}
	}
	if(debug_flag)
		fprintf(stderr,"DEBUG:Calc_trans is %d\n",global.trans.type);
}

void set_offset(char *string)
{
	char *off_x,*off_y;

	off_x=(char *) strtok(string,",");
	off_y=(char *) strtok((char *)NULL,",");

	if(off_x && off_y)
	{	/* set the offset */
		global.left=atoi(off_x);
		global.top=atoi(off_y);
		if(debug_flag>1)
			fprintf(stderr,"Offset changed to %d,%d\n",global.left,global.top);
		return;
	}
	if(debug_flag>1) fprintf(stderr,"Couldn't parse offset values.\n");
		exit(1);
}
