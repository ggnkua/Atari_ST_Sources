/*
 * Check corrupted MODFiles
 * ------------------------
 *
 *
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h>




/* Structures used:
 */
#define BYTE	char
#define WORD	int
#define LONG	long


#define M_K_ 0x4d2e4b2eL		/* M.K. */
#define FLT4 0x464c5434L		/* FLT4 */



/* diverses */
typedef unsigned char	uchar;
typedef unsigned int	uint;
typedef unsigned long	ulong;
typedef unsigned short	ushort;

/* Der Instrumente-Eintrag:
 * sizeof(INST) = 30
 */
typedef struct {
    char    inst_name[22];      /* Name des Samples                 */
    ushort  s_length,           /* L„nge des Samples in WORDS       */
            s_defvolume,        /* Default-Volume (0..64)           */
            s_loopstart,        /* Sample-Loop-Start in WORDS       */
            s_looplength;       /* Sample-Loop-L„nge in WORDS       */
} INST;


/* Das Pattern:
 * sizeof(PATTERN) = 1024
 */
typedef struct {
    LONG   channel[64][4];     /* 64 Schritte zu 4 Eintr„gen       */
} PATTERN;


/* Aufbau eines 15-Instrumente Songs:
 * sizeof(SONG_15) = 600  (ohne pattern[])
 */
typedef struct {
    char    mod_name[20];       /* nicht unbedingt nullterm.String  */
    INST    instruments[15];    /* Verwendete Instrumente           */
    BYTE    seq_len,            /* Benutzte L„nge der Ablaufliste   */
            repeat;             /* Repeat from - index i.d. "       */
    BYTE    seqlist[128];       /* Ablaufliste mit Patternindizes   */
    PATTERN patterns[];         /* die Patterns                     */
} SONG_15;


/* Aufbau eines 31-Instrumente-Songs:
 * sizeof(SONG_31) = 1084  (ohne pattern[])
 */
typedef struct {
    char    mod_name[20];       /* nicht unbedingt nullterm.String  */
    INST    instruments[31];    /* Verwendete Instrumente           */
    BYTE    seq_len,            /* Benutzte L„nge der Ablaufliste   */
            repeat;             /* Repeat from - index i.d. "       */
    BYTE    seqlist[128];       /* Ablaufliste mit Patternindizes   */
    long    id;	                /* = "M.K." -> Mahoney & Kaktus     */
    PATTERN patterns[];         /* die Patterns                     */
} SONG_31;




/* interne Speicherung der Samples
 */
typedef struct {
	char	*sampledata;
	long	samplesize;			/* real sample size !! */
} SAMPLEHDR;









/* variables:
 */
int 	modfile_handle;					/* TOS handle of the modfile */
int		modfile_type;					/* 15 or 31 instr  */
long	modfile_size;					/* orignal file-size */
long	modfile_length;					/* correct size */

char 	songdata[sizeof(SONG_31)];		/* song data */

INST	*inst;							/* sampleheader */
BYTE	*seqlist;						/* seq.list */

#define SEQ_LEN -2						/* seqlist[SEQ_LEN] !! */
#define REPEAT_FROM -1

PATTERN *patterns;						/* pattern list */
int		num_patterns;

SAMPLEHDR	splmemory[32];				/* sample save positions */

char	mfpath[256];






/* usage...
 */
void usage(void)
{
	printf(	"CHECKMOD - test & repair damaged MODs\n"
			"Usage: CheckMod <modulenames>\n"
		  );
}


/* error...
 */
void error( char *text )
{
	printf("ERROR: %s\n", text);
}


/* release a modfile
 */
void free_modfile(void)
{
	int		i;
	
	if (modfile_handle) Fclose(modfile_handle);
	if (patterns)
	{
		Mfree(patterns);
		patterns=NULL;
	}
	for(i=0; i<32; i++)
	{
		if (splmemory[i].sampledata) Mfree((void *)splmemory[i].sampledata);
		splmemory[i].sampledata=0;
	};

}


/* opens a MODfile and loads Song-Data of a MODfile
 */
void load_song( char *module )
{
	long	amount;
	void	*sng;
	int		i, patcnt;
	long	songsize;
	
	printf("\nFilename: %s\n", module);
	
	modfile_handle = (int)Fopen( module, FO_READ );
	if (modfile_handle>0)
	{
		modfile_size = Fseek(0, modfile_handle, 2);
		Fseek(0, modfile_handle, 0);
		
		amount = Fread( modfile_handle, sizeof(SONG_31), songdata );
		if (amount<sizeof(SONG_31))
		{
			/* fehler -> keine Modul */
			error("Not a MODfile.");
			Fclose(modfile_handle);
			modfile_handle = 0;
		}
		else
		{
			sng = &songdata;
			if ((memcmp( &((char *)sng)[2], "-lz5-", 5) == 0) ||
				(memcmp( &((char *)sng)[2], "-afx-", 5) == 0)  )
			{
				printf("This is a LARC-packed archive, please unpack first!\n"
					   "...any key to continue");
				Fclose(modfile_handle);
				Cconin();
				goto outhere;
			}
			if ((((SONG_31 *)sng)->id == M_K_) ||
				(((SONG_31 *)sng)->id == FLT4) )
			{
				modfile_type = 31;			/* 31 instruments */
				inst	= &(((SONG_31 *)sng)->instruments);
				seqlist	= &(((SONG_31 *)sng)->seqlist);
				songsize = sizeof(SONG_31);
			}
			else
			{
				modfile_type = 15;			/* old format */
				Fseek( sizeof(SONG_15), modfile_handle, 0);
				inst	= &(((SONG_15 *)sng)->instruments);
				seqlist	= &(((SONG_15 *)sng)->seqlist);
				songsize = sizeof(SONG_15);
			}
			printf(	"MOD-name: '%.20s' (%d-Instruments)\n",
					((SONG_31 *)sng)->mod_name, modfile_type);
			
			/* OK, Pattern z„hlen. */
			for (i=0, patcnt=0; i<128; i++)
				patcnt = (seqlist[i]>patcnt) ? seqlist[i] : patcnt;
			patcnt++;
			num_patterns=patcnt;

			printf("Song contains %d patterns.\n", num_patterns);
			
			/* Pattern laden... */
			songsize += sizeof(PATTERN)*patcnt;
			
			patterns = Malloc(sizeof(PATTERN)*patcnt);
			if (patterns==0)
			{
				error("Out of memory!");
				free_modfile();
				exit(0);			/* TOS clears the bullshit... */
			}
			Fread(modfile_handle, sizeof(PATTERN)*patcnt, patterns);
			modfile_length = songsize;
			if (Fseek(songsize, modfile_handle, 0) != songsize)
			{
				error("corrupted Pattern List.");
				free_modfile();
			}
		}
	}
	else
outhere:
		modfile_handle = 0;
}




/* checks & loads samples
 */
void load_samples( void )
{
	INST	*r;
	long	ist_laenge, soll_laenge;
	char	*spl;
	int		i;
	
	
	r = inst;
	for (i=0; i<modfile_type; i++)
	{
		soll_laenge = 2 * (long)r->s_length;
		if (soll_laenge > 0 )
		{
			printf( "Inst %02d, %6ld bytes: '%.22s'\n",
					i, soll_laenge, r->inst_name );
			spl = Malloc(soll_laenge);
			splmemory[i].sampledata = spl;
			
			if (spl==0)
			{
				error("Out of memory!");
				free_modfile();
				exit(0);			/* TOS clears the bullshit... */
			}
			memset(spl,0,soll_laenge);
			ist_laenge = Fread(modfile_handle, soll_laenge, spl);
			
			splmemory[i].samplesize = soll_laenge;
			if (ist_laenge<soll_laenge)
			{
				printf(" -> short sample: only %ld bytes.\n", ist_laenge);
			}
			else if (soll_laenge > 65534L)
			{
				printf(" -> maximum sample length (64K) exceeded.\n");
				splmemory[i].samplesize = 65534L;
				r->s_length = 65534L/2;				/* in words */
			}
			
			modfile_length += soll_laenge;
		}
		else
		{
			splmemory[i].sampledata = 0;
			splmemory[i].samplesize = 0;
		}
		r++;
	}
	
	/* Fertig. Ist die Datei auch zu Ende? */
	if (modfile_length < modfile_size)
	{
		printf("Module contains superfluous data (%ld bytes).\n",
				modfile_size-modfile_length);
	}
};



/* closes the MODfile
 */
void close_module( void )
{
	if (modfile_handle)
		Fclose(modfile_handle);
	modfile_handle=0;
}



/* saves a module, setting the correct length
 */
void save_module( void )
{
	int		h, i;
	long 	e;
	
	h=(int)Fcreate(mfpath, 0);
	if (h>0)
	{
		if (modfile_type==15)
			e=Fwrite(h, sizeof(SONG_15), songdata);
		else
			e=Fwrite(h, sizeof(SONG_31), songdata);
		if (e<0) { free_modfile(); exit((int)e); }

		e=Fwrite(h, sizeof(PATTERN)*num_patterns, patterns);
		if (e<0) { free_modfile(); exit((int)e); }

		for (i=0; i<31; i++)
		{
			if (splmemory[i].samplesize)
			{
				e=Fwrite(h, splmemory[i].samplesize, splmemory[i].sampledata);
				if (e<0) { free_modfile(); exit((int)e); }
			}
		}
		Fclose(h);
	}
	else printf("Can't write file\n");
}



/* main.
 */
int main(int argc, char *argv[])
{
	int 	i;
	
	if (argc<2)
	{
		usage();
		return 0;
	}
	
	puts("CHECK-MOD "
			__DATE__
		 " by P. Fellerich");
	
	for (i=1; i<argc; i++)
	{
		load_song( argv[i] );
		if (modfile_handle)
		{
			load_samples();
			close_module();
			printf("Save Module as (empty line quits): ");
			gets(mfpath);
			if (mfpath[0]!=0)
			{
				if (strcmp(mfpath, ".") == 0)
					strcpy(mfpath, argv[i]);
				save_module();
			}
			free_modfile();
		}
	}
	return 0;
}

