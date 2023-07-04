
// DReloc - fix up files for TOS pre 1.4
// requires -cm flag

#include <stdio.h>
#include <stdlib.h>

struct { short x; long y[3]; long symlen; long junk[2]; short xx; } sthead;

int main(int argc, char *argv[])
{
FILE *fp;
long addr;
unsigned char c;
long counter;
long reloclen;

	printf("DRELOC 1.0 Copyright Andy Pennell 1992\n");
	if ( (argc!=2) || ( (fp=fopen(argv[1],"rb+"))==NULL ) )
		{
		printf("bad args\n");
		exit(10);
		}
	fread(&sthead,sizeof(sthead),1,fp);
	fseek(fp,sthead.y[0]+sthead.y[1]+sthead.symlen,SEEK_CUR);
	reloclen=ftell(fp);

	fread(&addr,4,1,fp);
/*	printf("Start addr: %08lx\n",addr);	*/
	counter=4L;
	if (addr)
	for (;;)
		{
		counter++;
		c=fgetc(fp);
		if (c==0)
			break;
/*		printf("%x ",(int)c);	*/
		if (c==1)
			addr+=254;
		else
			{
			addr+=(long)c;
/*			printf("=%08lx\n",addr);	*/
			}
		}		
	fseek(fp,0L,SEEK_END);
	reloclen=ftell(fp)-reloclen;

	if ( ((short)(reloclen))>=counter )
		printf("File OK\n");
	else 
	{
	printf("File:%s uses $%lx bytes of reloc but really $%lx\n",
		argv[1],counter,reloclen);
	
	if (counter>=0x8000L)
		printf("ERROR: 32k max debug allowed\n");
	else //if ( ((short)(reloclen))<counter)
		{
		long pad,wanted;
		wanted=counter|(reloclen&0xFFFF0000L);
		if (reloclen&0x8000L)
			wanted+=0x10000L;
		pad=wanted-reloclen;
		if (pad<0)
			printf("INTERNAL ERROR: %lx is negative\n",pad);
		else
			{
			printf("DANGER: padding reloc by %ld bytes\n",pad);
			while (pad--)
				{
				fputc('\0',fp);
				}
			}
		}
	}
	
	if (fclose(fp))
		{
		printf("Error closing file (disk full?)\n");
		return 10;
		}
	return 0;
}
