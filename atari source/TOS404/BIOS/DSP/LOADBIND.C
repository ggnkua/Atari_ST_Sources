#include "osbind.h"
#include "dspcode.h"
#include "loadbind.i"

#define NUMTOKENS	6
#define DSPDATA 	1
#define DSPBLOCK 	2
#define DSPEND		5

#define BOOTLDSIZE 82L			/* THIS VALUE IS IN DSP WORDS  */

#define PLOADSIZE 152L			/* THIS VALUE IS IN DSP WORDS      */

#define BOOTJMPSIZE	71L		/* THIS VALUE IS IN DSP WORDS ALSO */

#define NUM_SUBROUTINES 8
#define VECTBASE	23
#define DSPMEMTOP	0x7ea8L		/* DSP top of usable prog/subr mem */
#define	MAXSUBRSIZE	1024L

typedef struct sublist
{
   long location;
   long size;
   int  vector;		/* Vectors 23 - 30, also use as handles, x2 = address */
   int  ability;
} SUBLIST;

SUBLIST	subarray[8];
long	dspcurtop;
long	subrtop;
long 	progtop;
int	progability;
int	cursub;
int	unique_ability;

typedef struct dta
{
   char res[21];
   char attr;
   int  time;
   int  date;
   long fsize;
   char str[14];
}DTA;

DTA dspdta;

static long bufsize;
static char *bufend;
static char *codebuf;
static char *curptr;
static long binindex;
static char *binbuff;

/* New declarations 7/13						     */
static long size_loc_index;		/* Place holder to put size of block */
					/* at beginning of block             */
					/* Keep track of this until we've    */
					/* actually calculated it	     */
static long size_count;			/* counter to place into binbuff at  */
					/* size_loc_index after block is     */
					/* processed			     */

static char *tokens[] =
{
   "START",
   "DATA",
   "BLOCKDATA",
   "SYMBOL",
   "COMMENT",
   "END"
};

static int token_lengths[] =
{
   5,
   4,
   9,
   6,
   7,
   3
};


/* DSP initialization routine.  For now, call it once at the beginning of */
/* the test program.  Later, call once at system initialization		  */

Dsp_Init()
{
   int i;

   vector_copy();			/* copy data to bss for romming */

   for(i = 0; i < NUM_SUBROUTINES;i++)
   {
	subarray[i].location = 0L;
	subarray[i].ability  = 0;
	subarray[i].vector = (i + VECTBASE);
   }
   dspcurtop = subrtop = DSPMEMTOP;
   progtop = 0;
   progability = 0;
   cursub = 0;
   unique_ability = 0x8000;			/* Begin abilities at 32K */
   DspExBoot(bootld, BOOTLDSIZE, 0);
   DspDoBlock(pload, PLOADSIZE, 0L, 0L); 
}

DspFlushSubroutines()
{
   int i;
   for(i = 0; i < NUM_SUBROUTINES;i++)
   {
	subarray[i].location = 0L;
	subarray[i].ability  = 0;
   }
   dspcurtop = subrtop;
   cursub = 0;
}

DspLdSubroutine(codeptr, size, ability)
long codeptr;
long  size;
int  ability;
{
   int i;
   long tempsize;
   int tempcur;
   if(size > MAXSUBRSIZE)
	return(0);		/* Subroutine is too large */
   if(progtop + size > dspcurtop)
	return(0);		/* Not enough memory to load subroutine */
   if(subarray[cursub].location != 0L)   /* If the slots already taken */
   {					 /* Replace the existing subroutine */
	Dsp_Move_Block(subarray[cursub].location-1, subrtop, 
			subarray[cursub].location - (dspcurtop+1));
	tempsize = subarray[cursub].size;
	for(i = 0; i < NUM_SUBROUTINES; i++)
	{
	   subarray[i].location += tempsize;
	   dsp_set_vector(subarray[i].location,subarray[i].vector);
	}
	dspcurtop += tempsize;
   }
   subarray[cursub].location = dspcurtop - size + 1;
   subarray[cursub].size = size;
   subarray[cursub].ability = ability;
   dspcurtop = dspcurtop - size;
   dsp_set_vector(subarray[cursub].location,subarray[cursub].vector);
   dsp_load_vectors();
   Dsp_Run_SubLoader();
   Send_Load_Info(subarray[cursub].location,
		  subarray[cursub].size);	/* Send code address and */
						/* code size to our loader */
   DspDoBlock(codeptr,size,0L,0L);		/* Send code to our loader */
   tempcur = cursub;				/* Increment fifo ptr */
   cursub++;
   if(cursub >= NUM_SUBROUTINES)
	cursub = 0;			/* Circle back around */
   return(subarray[tempcur].vector);
}


long DspLodToBinary(file,dspbuff)
char *file;
char *dspbuff;
{
   if(!read_dspcode(file))
   {
	return(-1L);
   }
   convert_file(dspbuff);		/* Convert ascii file to binary */
   free_dspcode();			/* Free file buffers		*/
   return(binindex/3L);
}

DspLdProg(file,ability,codeptr)
char *file;
int ability;
long codeptr;
{
   long codesize;
   codesize = DspLodToBinary(file,codeptr);
   if(codesize > 0L)
   {
      progability = ability;
      DspExProg(codeptr,codesize,ability);
   }
   if(codesize == -1L)
	return(-1);
   else
	return(0);
}

DspExProg(codeptr,codesize,ability)
char *codeptr;
long codesize;
int ability;
{
   DspExBoot(bootjmp,BOOTJMPSIZE,ability);	/* bootstrap our loader */
   DspBlkHandShake(codeptr,codesize,0L,0L);	/* Send code to our loader */
   dsp_send_vectors();				/* Send last block of stuff */
						/* to the loader (our vector */
						/* table... terminate with a */
						/* 0x03 in memtype field   */
   progability = ability;
}



/************************************************************************/
/* Simple string compare of current buffer pointer and table of tokens  */
/* Check for upper or lower case comparison matching			*/
/* Return 1 if strings ar equal or 0 if not				*/
/************************************************************************/

static strcmp1(bufstr,tablestr,len)
register char bufstr[];
register char tablestr[];
int  len;
{
   register int i;
   int identical;
   identical = 1;
   for(i = 0;i < len;i++)
	if(bufstr[i] != tablestr[i] && bufstr[i] != 
		(char)((int)tablestr[i] + 32))
	{
	   identical = 0;
   	   break;
	}
   return(identical);
}

/************************************************************************/
/* If first char of string is '_' then we have a token			*/
/* so return 1								*/
/************************************************************************/

static is_token()
{
   if(*curptr == '_')
   {
	curptr++;		/* Only bump pointer if we have a token */
	return(1);
   }
   else 
	return(0);
   
}

/************************************************************************/
/* Return token number associated with string pointed to by curptr	*/
/************************************************************************/

static get_token()
{
   int i;
   for(i = 0;i < NUMTOKENS;i++)
   {
	if(strcmp1(curptr,tokens[i],token_lengths[i]))
	   break;
   }
   return(i);
}

/************************************************************************/
/*	Move curptr to new line 					*/
/************************************************************************/

static newline()
{
   while(*curptr != 0x0d && curptr <= bufend)
	curptr++;
   if(curptr <= bufend)
      curptr += 2;			/* Skip the CR and LF 		*/
}

/************************************************************************/
/* Convert next 4 ascii hex digits into a binary number			*/
/************************************************************************/

static make_int()
{
   int val;
   int temp;
   int mult;
   int i;
   mult = 4096;
   val = 0;
   for(i = 0; i < 4;i++)
   {
 	if(*curptr >='0' && *curptr <= '9')
	   temp = *curptr - '0';
	else if(*curptr >= 'A' && *curptr <= 'F')
	   temp = (*curptr - 'A')+10;
	else
	   temp = (*curptr - 'a')+10;
	curptr++;
	val += temp * mult;
	mult /= 16;
   }
   return(val);
}

/************************************************************************/
/* 	Place the 3 bytes a,b,c into the binary buffer			*/
/************************************************************************/

static put_dspword(a,b,c)
char a;
char b;
char c;
{
   binbuff[binindex++] = a;
   binbuff[binindex++] = b;
   binbuff[binindex++] = c;
   size_count++;			/* counter for size of block    */
}

/*************************************************************************/
/*	Get new program location.  Reset size_count since we're starting */
/*	a new block.  Set size_loc_index so we can stuff size_count      */
/*  	after we're through with the block.  Place block type, start     */
/*	location, and a dummy size placeholder into buffer.		 */
/* 	Block types = 0 - program, 1 - X, 2 - Y				 */
/*************************************************************************/

static stuff_header(memtype)		/* Set new program counter */
char memtype;
{			
   long block_loc;

   /********************************************************/
   /*  First put the block type into the buffer		   */
   /********************************************************/
   binbuff[binindex++] = 0;
   binbuff[binindex++] = 0;
   if(memtype == 'P')
   {
      binbuff[binindex++] = 0;
   }
   else if(memtype == 'X')
   {
      binbuff[binindex++] = 1;
   }
   else
   {
      binbuff[binindex++] = 2;
   }

   /**********************************************************/
   /* Next store the block location			     */
   /**********************************************************/

   binbuff[binindex++] = 0;
   block_loc = (long)make_int();
   binbuff[binindex++] = (char)(block_loc >> 8);
   binbuff[binindex++] = (char)(block_loc);

   /***********************************************************/
   /* Now setup to store the block size.  Create place holder */
   /* in buffer, init size_loc_index to binindex, and reset   */
   /* size_count					      */
   /**********************************************************/
   
   size_count = 0L;
   size_loc_index = binindex;
   binindex += 3;      
   newline();
}

/************************************************************************/
/*	Take the next 6 ascii hex digits and convert to a 24 bit DSP 	*/
/*	word. (by creating 3 consecutive bytes				*/
/************************************************************************/

static make_dspword()
{
   int i,j;
   char ch[3];
   char mult;
   char temp;
   char val;
   for(i = 0; i < 3;i++)		/* For the next 3 bytes - 24 bits */
   {
	val = 0;
	mult = 16;
	for(j = 0;j < 2; j++)		/* 2 characters to a byte	  */
	{
	   if(*curptr >='0' && *curptr <= '9')
 		 temp = (*curptr - '0');
	   else if(*curptr >= 'A' && *curptr <= 'F')
	         temp = (*curptr - 'A')+10;
	   else
	      	 temp = (*curptr - 'a')+10;
	   curptr++;
	   val += temp * mult;
	   mult /= 16;
	}
	ch[i] = val;
   }
   put_dspword(ch[0],ch[1],ch[2]);   
}

/************************************************************************/
/* 	Convert a line of ascii hex into binary DSP code		*/
/************************************************************************/

static convert_line()
{
   while(*curptr != 0x0D)
   {
	while(*curptr == ' ')
	   curptr++;
	if(*curptr != 0x0D)		/* If not end of line then, */
	   make_dspword();		/* it must be a data word   */
   }
}

/************************************************************************/
/*	Move curptr to the end of the current token string		*/
/************************************************************************/

static move_to_endoftoken(index)
int index;
{
   curptr += token_lengths[index];
}
/* 	Called when a DATA token is found			*/


static do_convert()
{
   char memtype;		/* X, Y, or P memory			   */
   move_to_endoftoken(DSPDATA);
   while(*curptr == ' ')	/* Get rid of spaces between "DATA" and    */
	curptr++;		/* Memory type "X,Y,L, or P"		   */
   memtype = *curptr++;		/* Get memory type			   */
   curptr++;			/* skip next blank space		   */
   stuff_header(memtype);	/* Setup Block's header info		   */
   while(!is_token())		/* Convert all lines of this section to bin */
   {
	if(*curptr == 0x0d)
	   newline();
	else
	   convert_line();
   }
   /****************************************************************/
   /*  Now that we've completed the block and know its size, put   */
   /*  it into the blocks header that's at the beginning of the    */
   /*  block.							   */

   binbuff[size_loc_index++] = 0;
   binbuff[size_loc_index++] = (char)(size_count >> 8);
   binbuff[size_loc_index++] = (char)(size_count);
   
}

static convert_file(buffer)
char *buffer;
{
   int dsptoken;
   curptr = codebuf;
   binbuff = buffer;
   binindex = 0L;
   while(!is_token())		/* Look for first token, prime pump */
	newline();
   while((dsptoken = get_token()) != DSPEND)  
   {
	switch(dsptoken)
	{
	   case	DSPDATA:
	      do_convert();
	      break;
	   default:
	      newline();		/* Blow away token line */
	      while(!is_token())	/* Find next token */
		newline();
	      break;
	}
   }
}

/************************************************************************/
/*	Read in DSP load file.  					*/
/************************************************************************/

static read_dspcode(fname)
char *fname;
{
   long savedta;
   int fhandle;
   savedta = (long)Fgetdta();
   Fsetdta(&dspdta.res[0]);
   if(Fsfirst(fname,0) <= -1)
   {
	Fsetdta(savedta);
	/* Handle error */
	return(0);
   }
   bufsize = dspdta.fsize;
   codebuf = (char *)Malloc(bufsize);
   if(!codebuf)
   {
	Fsetdta(savedta);
	/* Handle error */
        return(0);
   }
   fhandle = Fopen(fname,0);
   Fread(fhandle,dspdta.fsize,codebuf);
   Fclose(fhandle);

   bufend = (codebuf + dspdta.fsize);
   Fsetdta(savedta);
   return(1);
}


static free_dspcode()
{
   Mfree(codebuf);
}
