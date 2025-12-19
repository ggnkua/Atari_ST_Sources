#include <tos.h>
#include <stdio.h>


typedef enum {NO_FILE=-1, SEGMNT, INST31, INST15} IN_MEMORY;

typedef struct
{
	char name[22];   
	unsigned short length;  /* offset to image of next instrument */
	unsigned short volume;  
	unsigned short transient_p;
	unsigned short loop_p;
} INST[32];


typedef struct
{
	int instrument;
	int frequency;
	int command;
	int parameter;
} MODCOMMAND;


typedef unsigned char SEQ[128];
typedef unsigned long PATT[][64][4];

char *MusicBuffer = 0;
int nr_sequence;
SEQ *Seq;
int nr_patt;
PATT *Patt;
INST *Inst;


char *CommandName[] = 
{
	"Arpeggio","Porta Up","Porta Down","Tone Portamento",
	"Vibrato","TonePlus Vol Slide","Vibrato Plus Vol Slide","*Tremolo",
	"*8","*Sample Offset","Volume Slide","Song Jump",
	"Set Volume","Patt. Break","*Extended Comm's*","Set Speed",

	"*Filter On Off","*Fine Porta Up","*Fine Porta Down","*Set Gliss Control",
	"*Set Vibrato Control","*Set Fine Tune","*Jump Loop","*Set Tremolo Control",
	"*8","*Retrig Note","*Volume Fine Up","*Volume Fine Down",
	"*Note Cut","*Note Delay","*Pattern Delay","*Funk It"
};
	


static void GetModulPar(char *buffer)
/* This routine exports the global vars :
 *   Seq, Patt, nr_patt,nr_sequnces
 */
{int i, a;

	Seq  = (SEQ *)(buffer + 0x3b8);
	Patt = (PATT *)(buffer + 0x43c);	
	Inst = (INST *)(buffer + 20);
	nr_patt = 0;
	nr_sequence = (int)buffer[0x3b6];
	
	for(i = 0; i < nr_sequence; ++i)
	{
		a = (*Seq)[i];
		if (a > nr_patt) nr_patt = a;
	}
}


static int readModule(int f, int file, long length) 
{int i;
 char *b;

	if (file == INST15)
		length += 0x1E4;

	if (( MusicBuffer = Malloc(length) ) == 0)
		return 1;

	b = MusicBuffer;

	if (file == INST15)
	{
		Fread(f, 20+15*30, b);
		
		b += 20+15*30;
		
		for(i=0; i<16*30; ++i) 
			*b++ = 0;
		
		Fread(f, 128+2, b);
		b += 128+2+4;
		Fread(f, length, b);
	}
	else
		Fread(f, length, b);

	b = MusicBuffer;
/*	mt_fixup(b); */
	GetModulPar(b);
	
	return 0;
}


static int getFileType(int f)
{long info[2];

	Fread(f, 4, info);
	
	if (*info == 'SEGM')
		return SEGMNT;
	
	Fseek(0x438, f, 0);
	Fread(f, 4, info);
	
	if (*info == 'M.K.')
		return INST31;
	
	return INST15;	
}


int loadModule(char *name)
{int f, file, err;
 long length;
 
	if ((f = Fopen(name,0) ) <= 0)
		return -1;
	
 	file = getFileType(f);
 	
	length = Fseek(0, f, 2);
	Fseek(0, f, 0);
	err = 0;
	
	if (file == INST31 || file == INST15)
		err = readModule(f, file, length);
	
	Fclose(f);
	
	return err;
}


void parseCommand(long encoded, MODCOMMAND *pcom)
{

	pcom->frequency  = (int)( (encoded & 0x3ff0000L) >> 16 );
	pcom->instrument = (int)( (encoded & 0xf000) >> 12 );
	
	if (encoded & 0x10000000L)
		pcom->instrument += 16;

	pcom->parameter  = (int)( encoded & 0xff );
	pcom->command    = (int)( (encoded & 0xf00) >> 8 );
	
	if (!pcom->parameter && !pcom->command)
		pcom->command = -1;
		
	if (pcom->command == 0xE)
	{
		pcom->command = (pcom->parameter >> 4) + 16;
		pcom->parameter &= 0xF;
	}
}


void listSequence(void)
{int i;

	printf("\nLIST SEQUENCE\n");

	for (i = 0; i < nr_sequence; i++)
	{
		if (i & 0xf)
			printf(", ");
		else
			printf("\n%2d: ", i);
			
		printf("%2d",(int)(*Seq)[i]);
	}
	
	printf("\n");
}



void listPattern(int pattern,int voice)
{int i;
 MODCOMMAND pcom;
 
	printf("\nLIST PATTERN %d ---  Voice %d\n",pattern, voice);

	for (i = 0; i < 64; i++)
	{
		/* nothing in the command, skip it */
		if ((*Patt)[pattern][i][voice] == 0)	
			continue;

		printf("%2d: ",	i);
		parseCommand((*Patt)[pattern][i][voice], &pcom);

		printf("inst:%3d --- freq:%3d --- ",
			pcom.instrument,pcom.frequency);
	
		if (pcom.command >= 0)
			printf("%16s(%3d)\n", CommandName[pcom.command],pcom.parameter);
		else
			printf("\n");
	}
	
	printf("\n");
	
}



int InstrumentInfo(int i)
{long leng,loop,tran;
 long n_length,n_loopstart,n_replen;
 int no_repeat,err;
 
	leng = (long)2*(*Inst)[i].length;
	tran = (long)2*(*Inst)[i].transient_p;
	loop = (long)2*(*Inst)[i].loop_p;

	printf("*** %2d: %22s ***\n", i, (*Inst)[i].name);
	
	printf("volume: %4d\n", (*Inst)[i].volume);
	
	printf("length: %4ld\n", leng);
	printf("trans:  %4ld\n", tran);
	printf("loop:   %4ld\n", loop);

	no_repeat = (loop == 2);
	err = 0;
	
	if (tran)
	{
		n_loopstart = tran;
		n_length    = loop+tran;
		n_replen    = loop;
		
		err |= (n_length > leng);
	}
	else
	{
		n_loopstart = 0;
		n_length    = leng;
		n_replen    = loop;
	}
	
	printf("(0 -> %ld, then ", n_length);
	
	if (no_repeat) 
		printf("STOP)");
	else
	{
		printf(" %ld -> %ld)",n_loopstart, n_replen);

		err |= (n_loopstart + n_replen > leng);
	}
	
	if (err)
		printf("-- Error in sample\n\n");
	else
		printf("\n\n");
	
	return err;
}	

	
	
	
void getResourceUse(void)
{char       com[32], inst[32];
 int        i, unsupported,inst_err;
 long       waste;
 MODCOMMAND pcom;
 
 	/* clear "used-command" vector */
 	for(i = 0; i < 32; com[i++] = 0);
 	
	/* clear "used-instrument" vector */ 
 	for (i = 0; i < 32; inst[i++] = 0);

	unsupported = 0;
	inst_err = 0;
	
	for (i = 0; i < nr_patt*64*4; i++)
	{
		parseCommand((*Patt)[0][i>>2][i & 3], &pcom);
		inst[pcom.instrument] = 1;
		if (pcom.command >= 0)
			com[pcom.command] = 1;
	}
	
	
	/*
	 *  List the used instruments 
	 */
	 
	printf("\nUSED INSTRUMENTS :\n");
	
	for (i = 1; i < 32; i++)
	{
		if (inst[i])
		{
			inst_err += InstrumentInfo(i-1);
		}
	}
	printf("\n");

	
	/*
	 *  List the used commands 
	 */
	 
	printf("USED COMMANDS :\n");
	
	for (i = 1; i < 32; i++)
	{
		if (com[i])
		{
			printf("%2d: %s\n", i, CommandName[i]);
			if (*CommandName[i] == '*')
				unsupported++;
		}
	}
	
	printf("\n");
	
	if (unsupported)
	{
		printf("WARNING: %d ProTracker commands\n", unsupported);		
	}
	
	if (inst_err)
	{
		printf("WARNING: %d errors in the samples\n", inst_err);		
	}
	
	inst_err = 0;
	waste    = 0;
	
	for (i = 1; i < 32; i++)
	{
		if (!inst[i] && (*Inst)[i-1].length > 0)
		{
			waste += (long)2*(*Inst)[i].length;
			inst_err++;
		}
	}
	
	if (inst_err)
	{
		printf("WARNING: %d unused samples in MODule, using %ld bytes\n", inst_err, waste);		
	}
	
}


main(int argc, char *argv[])
{int err,i;

	if (argc > 1)
	{	
		printf("File: %s\n\n",argv[1]);
	
		if ((err = loadModule(argv[1])) == 0)
		{
			printf("Name: %s\n\n",MusicBuffer);
			
			printf("Sequence Length: %d, Number of Patterns: %d, \n",
				nr_sequence, nr_patt);
			
			getResourceUse();
			
			listSequence();
			for (i = 0; i < nr_patt; i++)
			{
				listPattern(i,0);
				listPattern(i,1);
				listPattern(i,2);
				listPattern(i,3);
			}
		}
		else
			printf("Error by load : %d\n",err);
			
		if (MusicBuffer)
			Mfree(MusicBuffer);
	}
	
	return 0;
}