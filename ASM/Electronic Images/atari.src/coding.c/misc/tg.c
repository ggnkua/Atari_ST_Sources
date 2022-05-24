#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <dos.h>
#include <ctype.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>
#include <string.h>


#pragma pack(0);

struct Fmt {
    char    fID[4];
    int     fLen;
    short   wFormatTag;
    short   nChannels;
    short   nSamplesPerSec;
    short   nAvgBytesPerSec;
    short   nBlockAlign;
    short   FormatSpecific1;
    short   FormatSpecific2;
    short   SampleBits;
};


struct DataChk {
    char    dId[4];
    int     dLen;
};


struct rData    {
    char    wID[4];
    struct  Fmt Format;
    struct  DataChk Data;
};

struct WavHdr {
    char    rID[4];
    int     rLen;
    struct  rData Data;
};


#define	SINACC	1024
#define BITS	8

#define M_PI    3.1415927

int ColFreqArray[4];
int RowFreqArray[4];
int SinTable[1024];

void GenArray(int);

void DoHdr(struct WavHdr *Wave, int Freq, int Len, int Bits, int Channels)
{
    memcpy(&(Wave->rID), "RIFF", 4);
    Wave->rLen = sizeof(struct rData) + Len;
    if(Wave->rLen & 1) Wave->rLen++;
    memcpy(&(Wave->Data.wID), "WAVE", 4);
    memcpy(&(Wave->Data.Format.fID), "fmt ", 4);
    Wave->Data.Format.fLen = 16;
    Wave->Data.Format.wFormatTag = 1;
    Wave->Data.Format.nChannels = Channels;
    Wave->Data.Format.nSamplesPerSec = Freq;
    Wave->Data.Format.nAvgBytesPerSec = 0;//Channels * Freq * (Bits / 8);
    Wave->Data.Format.nBlockAlign = Freq;
    Wave->Data.Format.FormatSpecific1 = 0;
    Wave->Data.Format.FormatSpecific2 = 1;
    Wave->Data.Format.SampleBits = Bits;
    memcpy(&(Wave->Data.Data.dId), "data", 4);
    Wave->Data.Data.dLen = Len;
}


int main(int argc, char *argv[])
{
    char *fname, *dialstr;
    int outfile;
    int freq=11025, ftime, fgap;
	int 	i;
	int	key;
	static	char Pad[]="123A456B789C*0#D";
	float a;
	char *buffer;
	int index=0;
	int handle;
    struct WavHdr   Wave;

	if(argc < 3) {
		fprintf(stderr, "syntax: tg [freq] dialstr outputfile\n");
		exit(0);
	}
	if(argc == 4) {
		freq = atoi(*(++argv));
	}
    ftime = freq / 10;
    fgap = freq / 20;
	dialstr = *(++argv);
	fname = *(++argv);
		
	for(i=0, a=0; i<SINACC; i++, a+=((2*M_PI)/SINACC))
		SinTable[i]=(int)((1<<(BITS-2)-1)*sin(a));
    GenArray(freq);
    buffer = (char *)malloc((ftime+fgap) * (1+strlen(dialstr)) );
	if(buffer == NULL) {
			fprintf(stderr, "Cant malloc memory\n");
			exit(1);
	}

	printf("Dialing %s\nOutput File %s\nGenerating sample at %dHz\n",
		dialstr, fname, freq);
	while(*dialstr) {
		key = toupper(*dialstr);
		for(i = 0; i < 16; i++) {
			if(Pad[i] == key) {

				int Counter = 0;
				int ColInc, RowInc;
				int ColValue = 0;
				int RowValue = 0;

				ColInc = ColFreqArray[i % 4];
				RowInc = RowFreqArray[i / 4];

						 while(Counter++ < ftime) {
					*(buffer+index) = SinTable[ColValue]+SinTable[RowValue]+128;
					ColValue = (ColValue+ColInc) & (SINACC-1);
					RowValue = (RowValue+RowInc) & (SINACC-1);
					index++;
				}
								memset(buffer+index, 0, fgap);
								index += fgap;
				break;
			}
		}
		if(i == 16){
			fprintf(stderr,"\nIllegal Character in Dialstring: %c", *dialstr);
			exit(0);
		}
		dialstr++;
	}
		memset(buffer+index, 0, fgap+ftime);
		index += fgap+ftime;
	handle = open(fname, O_WRONLY | O_CREAT);
	if(handle > -1) {
        DoHdr(&Wave, freq, index, 8, 1);
        write(handle, &Wave, sizeof(struct WavHdr));
	    write(handle, buffer, index);
	    close(handle);
	} else {
	    fprintf(stderr, "\nCouldnt open output file");
	}
	free(buffer);
	return 0;
}




void GenArray(int Freq)
{
	static long col[]={ 1209, 1336, 1477, 1633 };
	static long row[]={ 697, 770, 852, 941 };
	long newrow, newcol;

	int i;

	for( i=0; i<4; i++) {
		newcol=col[i];
		newcol*=SINACC;
        newcol/=Freq;
		ColFreqArray[i]=(int)newcol;

		newrow=row[i];
		newrow*=SINACC;
        newrow/=Freq;
		RowFreqArray[i]=(int)newrow;
	}
}
