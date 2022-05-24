#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <dos.h>
#include <ctype.h>

#define SMPFRQ      6000
#define SbIOaddr	0x220

#define DSP_WRITE_DATA      0x0C
#define DSP_WRITE_STATUS    0x0C
#define DSP_DATA_AVAIL      0x0E

#define SPEAKER_ON	    0xD1
#define SPEAKER_OFF	    0xD3


#define MASTER_VOL  0x22
#define VOC_VOL     0x04
#define LINE_VOL    0x2e
#define FM_VOL	    0x26
#define CD_VOL	    0x28
#define RECORD_SRC  0x0C


#define MIXER_ADDRESS       0x04    /* Pro only */
#define MIXER_DATA          0x05    /* Pro only */


#define	SAMPLELEN	(SMPFRQ/10)
#define	SINACC	1024

int ColFreqArray[4];
int RowFreqArray[4];
int SinTable[1024];

#define writemixer(x,y) { outportb(SbIOaddr+MIXER_ADDRESS,(x)); \
			  outportb(SbIOaddr+MIXER_DATA,(y)); }



void GenerateSample(char *, int);
void WriteDac(int);
int  SbInit(void);
void GenArray(void);
void interrupt far NewTimer();
void SbVoice(int);
void SetTimer(unsigned long);
static int timerflag=0;


static void (interrupt far *OldTimer)(void);



int main()
{
	int 	i;
	int		key;
	static	char Pad[]="123A456B789C*0#D";
	float a;


	for(i=0, a=0; i<1024; i++, a+=((2*M_PI)/1024) )
		SinTable[i]=(int)(60*sin(a));

	GenArray();

	if(SbInit()) {
		fprintf(stderr, "Error: cant initialise soundblaster\n");
		return -1;
	}

	OldTimer =_dos_getvect(0x08);
	_dos_setvect(0x08, NewTimer);
	SetTimer(SMPFRQ);
	writemixer(VOC_VOL,0x88);
	writemixer(MASTER_VOL,0x88);

	while(1) {
		key = getch();
		if( key == 'q' || key == 'Q' ) {
			SetTimer(19);
			_dos_setvect(0x08, OldTimer);

			return 1;
		}

		key = toupper(key);
		for(i = 0; i < 16; i++) {
			if(Pad[i] == key) {

				int	Counter = 0;
				int ColInc, RowInc;
				int	ColValue = 0;
				int	RowValue = 0;

				SbVoice(1);
				ColInc = ColFreqArray[i % 4];
				RowInc = RowFreqArray[i / 4];

				while(Counter++ < SAMPLELEN) {

					WriteDac(0x10);
					WriteDac(SinTable[ColValue]+SinTable[RowValue]+128);
					ColValue = (ColValue+ColInc) & (SINACC-1);
					RowValue = (RowValue+RowInc) & (SINACC-1);

					while(timerflag == 0);
					timerflag = 0;
				}
				SbVoice(0);
				break;
			}
		}
	}
}


void WriteDac(int byte)
{
	while(inportb(SbIOaddr+DSP_WRITE_STATUS) & 0x80);
		outportb(SbIOaddr+DSP_WRITE_DATA,(byte));
}


void SbVoice(int state)
{
	WriteDac((state) ? SPEAKER_ON : SPEAKER_OFF);
}


void interrupt far NewTimer()
{
	timerflag = 1;
	_asm {
	mov dx,0x20
	mov al,0x20
	out dx,al
	}
}



int SbInit()
{
	int count;

	outportb(SbIOaddr + 6, 1);

	inportb(SbIOaddr +6);
	inportb(SbIOaddr +6);
	inportb(SbIOaddr +6);
	inportb(SbIOaddr +6);

	outportb(SbIOaddr + 6, 0);
	outportb(SbIOaddr + 10, 1);

	for( count = 0; count < 100; count ++) {
		if( inportb(SbIOaddr +10) == 0xAA)
			return 0;
	}
	return 1;
}

void SetTimer(unsigned long time)
{
	unsigned int count;

	time = 1193180L/time;

	count = (unsigned)time;
    _asm {
			cli
	    mov cx,[count]
	    mov al,2+4+16+32
	    out 0x43,al
			mov al,cl
			out 0x40,al
	    mov al,ch
	    out 0x40,al
			sti
    }
}


void GenArray()
{
	static long col[]={ 1209, 1336, 1477, 1633 };
	static long row[]={ 697, 770, 852, 941 };
	long newrow, newcol;

	int i;

	for( i=0; i<4; i++) {
		newcol=col[i];
		newcol*=SINACC;
		newcol/=SMPFRQ;
		ColFreqArray[i]=(int)newcol;

		newrow=row[i];
		newrow*=SINACC;
		newrow/=SMPFRQ;
		RowFreqArray[i]=(int)newrow;
	}
}



