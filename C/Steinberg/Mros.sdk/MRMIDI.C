
/* small MROS Midi test */

#include <stdio.h>
#include <string.h>

#ifndef WORD
#define LONG long
#define WORD int
#define BYTE char
#define VOID void
#endif

#define Open_mros(a)        MEM(0,a)
#define Close_mros(a)       MEM(1,a)

#define Snd_mevent(a,b,c,d,e)   IOM(2,a,b,c,d,e)
#define Snd_mmult(a,b,c,d)      IOM(3,a,b,c,d)
#define Mget(a,b)               IOM(5,a,b)
#define Next_device(a,b)        IOM(22,a,b)

/* structures */

typedef struct mem_struct
{
   VOID *a;
   WORD b;
   WORD c;
   WORD d;  
   WORD e;
   WORD f; 
   WORD g;
   WORD h;
   BYTE i[14];
   BYTE appl_name[16];	/* write name in here       */  
} MEM_STRUCT;

typedef struct dev_struct
{
	VOID *a;
	WORD b;
	WORD c;
	WORD d;
	WORD e;
	VOID *f;
	VOID *g;
	VOID *h;
	VOID *i;
	WORD devact;				/* <>0, if device active            */
	WORD devnum;				/* device no.                       */
	WORD devmins;				/* no. of midi inputs (0=no input)  */
	WORD devmouts;				/* midi outputs                     */
	VOID *j;
	VOID *k;
	VOID *l;
	WORD m;
	WORD n;
	WORD o;
	WORD devvers;				/* version no.						*/
	BYTE devname[8];			/* 8 ascii device name              */
} DEV_STRUCT;

/* globals */

MEM_STRUCT my_mros;
WORD mroshandle = 0;

/* prototypes */

WORD main(VOID);
VOID start_mros(VOID);
VOID end_mros(VOID);
VOID test_scale(VOID);

/* extern (asm) */

LONG get_mrosversion(BYTE *string);
LONG MEM(void,...);
LONG IOM(void,...);

/*-----------------------------------------------------------------*/

WORD main(VOID)
{
	BYTE string[16];

	if(get_mrosversion(string) < 0)
	{
		/* you should load and execute mros here... */
		printf("\nMROS not Found!");
		return 0;
	}
	else printf("\n%s", string);
	start_mros();
	if(mroshandle > 0) test_scale();
	end_mros();
	return 0;
}

VOID start_mros(VOID)
{
	if(mroshandle > 0) return;
	memset(&my_mros, 0, sizeof(MEM_STRUCT));
	strcpy(my_mros.appl_name, "My Application");	/* max 15 char */
	mroshandle = (WORD)Open_mros(&my_mros);
}

VOID end_mros(VOID)
{
	if(mroshandle <= 0) return;
	Close_mros(mroshandle);
	mroshandle = 0;
}

VOID test_scale(VOID)
{
	DEV_STRUCT *ds;
	BYTE multest[4];
	LONG m;
	WORD i, n, note, first = 1;
	
	for(i = 0; i < 16; i++, first = 0)
	{
		ds = (DEV_STRUCT *)Next_device(0, first);
		if((LONG)ds < 0) break;
		if(ds->devact && ds->devmouts && ds->devnum != 7)
			/* you won't hear the mros device */
		{
			printf("\n%s", ds->devname);
			if(ds->devmins)
			{
				printf("\nPlay a Note, please...");
				note = -1;
				while(note < 0)	/* get a note */
				{
					note = (WORD)Mget(ds->devnum, 0);
					if(note > 0 && note < 0x80) break;
					/* take any data byte */
					note = -1;
				}
			}
			else note = 0x30;

			for(n = 0; n < 13; n++)
			{
				Snd_mevent(ds->devnum, 0, 0x90, n + note, 0x40);
				for(m = 0; m < 200000L; m++);
				multest[0] = 0x90;
				multest[1] = n + note;
				multest[2] = 0;
				Snd_mmult(ds->devnum, 0, &multest[0], 3);
				for(m = 0; m < 10000L; m++);
			}
		}
	}
}
