/**[Fonction Audio]*****************/
/* --/--/---- # 30/06/2020         */
/***********************************/



/*
 *
 * 30/06/2020: correction champ rate, il etait sur 32 bits.
 *              Seul 24 bits sont utilises pour la frequence. 
 *
 */



#ifndef ___AVR_HEADER___
#define ___AVR_HEADER___


#ifdef MAGIC_2BIT
#error "MAGIC_2BIT d‚j… d‚fini"
#endif


#define MAGIC_2BIT  (0x32424954)


typedef struct
{
	 unsigned	reserved :  8;
	 unsigned	valeur   : 24;
} AVRRATE;


typedef struct
{
    long  magic;            /* = "2BIT" */
    char  name[8];          /* null-padded sample name */
    short mono;             /* 0 = mono, 0xffff = stereo */
    short rez;              /* 8 = 8 bit, 16 = 16 bit */
    short sign;             /* 0 = unsigned, 0xffff = signed */
    short loop;             /* 0 = no loop, 0xffff = looping sample */
    short midi;             /* 0xffff = no MIDI note assigned,
                               0xffXX = single key note assignment
                               0xLLHH = key split, low/hi note */
    AVRRATE  rate;          /* sample frequency in hertz , only low 3byte 0x??rrrrrr */
    long  size;             /* sample length in bytes or words (see rez) */
    long  lbeg;             /* offset to start of loop in bytes or words.
                               set to zero if unused. */
    long  lend;             /* offset to end of loop in bytes or words.
                               set to sample length if unused. */
    short res1;             /* Reserved, MIDI keyboard split */
    short res2;             /* Reserved, sample compression */
    short res3;             /* Reserved */
    char  ext[20];          /* Additional filename space, used
                               if (name[7] != 0) */
    char  user[64];         /* User defined. Typically ASCII message. */

} s_AVR_HEADER;


#endif

