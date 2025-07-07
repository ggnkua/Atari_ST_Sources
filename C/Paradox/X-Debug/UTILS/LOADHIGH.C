
/* program which loads Mon high in RAM for serious debugging */

#define	NEW_RAMTOP	512*1024L
//#define	OLD_RAMTOP	1024*1024L

#define	FILENAME	"XDB.PRG"

#if !defined(TEST)
#define TEST 0
#endif

#include <stdio.h>
#include <stdlib.h>
#include <osbind.h>
#include <strings.h>
#include <basepage.h>

typedef short word;

#define	PHYSTOP	((long*)(0x42e))

void (*reset)(void);

void fatal(char *msg)
{
	printf("FATAL ERROR: %s\n",msg);
	Bconin(2);
	exit(10);
}


struct {
	word magic;
	long tlen,dlen,blen;
	long symlen,r0,r1;
	word reloc;
	} sthead;

void load_mon(long start, long end)
{
FILE *fp;
long len;
long pc;
int c;


	fp=fopen(FILENAME,"rb");
	if (fp==NULL)
		fatal("Cannot find " FILENAME);
	fread(&sthead,sizeof(sthead),1,fp);
	memset((void*)start, 0, (size_t)(end-start) );
	len=sthead.tlen+sthead.dlen;
	if ( (start+len+100000)>end )
		fatal("not enough room");

	fread((void*)start,len,1,fp);			// read text & data segment

	fseek(fp,sthead.symlen,SEEK_CUR);		// skip symbols
	
	fread(&pc,4,1,fp);
	if (pc==0L)
		return;
	
	*(long*)(pc+start) += start;
	while (c=fgetc(fp))
		{
		unsigned char d;
		if (c==EOF)
			fatal("EOF in relocation");
		d = (unsigned char)c;
		if (d==1)
			pc += 254;
		else
			{
			pc += d;
			*(long*)(pc+start) += start;
			}
		}	
}

int main(int argc, char *argv[])
{
long oldssp;
long phystop;

	printf("LOADHIGH 1.2 Copyright Andy Pennell 1992\n");

#if TEST
char *ram;

	ram = malloc(400*1024L);
	if (ram==NULL)
		fatal("no test RAM");
	load_mon(ram,ram+400*1024L);
	return 0;
#endif
	oldssp=Super(0L);
	phystop=*PHYSTOP;
	if (phystop==NEW_RAMTOP)
		{
		long exec,pc;
		BASEPAGE *bp;
		char cmdline[2];
		
		Super(oldssp);
		load_mon(phystop+0x100,*(long*)phystop);
		cmdline[0]=cmdline[1]=0;
		exec=Pexec(5,NULL,cmdline,NULL);
		if (exec<0L)
			fatal("Cannot create basepage");
		bp = (BASEPAGE*)exec;
		bp->p_lowtpa = NEW_RAMTOP;
		bp->p_hitpa = *(long*)phystop;
		bp->p_tbase = pc = NEW_RAMTOP+0x100;		// where it starts
		pc += sthead.tlen;
		bp->p_tlen = sthead.tlen;
		
		bp->p_dbase = pc;
		pc += sthead.dlen;
		bp->p_dlen = sthead.dlen;
		
		bp->p_bbase = pc;
		bp->p_blen = sthead.blen;

		exec=Pexec(4,NULL,exec,NULL);
		if (exec<0)
			fatal("Pexec failed");
		}
	else
		{
		printf("About to RESET - run LOADHIGH afterwards\nPress any key");
		Bconin(2);
		*(long*)(NEW_RAMTOP) = phystop;		// remember old value
		*PHYSTOP=NEW_RAMTOP;
		reset = *(long*)4;
		reset();
		}
	return 0;
}
