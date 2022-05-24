#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <ctype.h>
#include <dos.h>
#include <bios.h>

#define M_PI    3.141

#define SMPFRQ      20223
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

char *PlayBackBuffer;
int PlayBackCounter = 0;

double ColFreqArray[] = { 1209, 1336, 1477, 1633 };
double RowFreqArray[] = { 697,	770,  852,	941  };

#define writemixer(x,y) { outp(SbIOaddr+MIXER_ADDRESS,(x)); \
              outp(SbIOaddr+MIXER_DATA,(y)); }



void GenerateSample(char *, int);
void WriteDac(int);
int  SbInit(void);
void interrupt far NewTimer();
void SbVoice(int);
void SetTimer(unsigned long);
static int timerflag=0;


static void (interrupt far *OldTimer)(void);



int main()
{
	char	*DigitSamples[16];
	int 	i;
	int		key;
	static	char Pad[]="123A456B789C*0#D";

	PlayBackBuffer=NULL;

	for(i = 0; i < 16; i++) {
		DigitSamples[i] = (char *)malloc(SAMPLELEN);
		if(DigitSamples[i] == NULL) {
			fprintf(stderr, "\nError: insufficient memory\n");
			return -1;
		}
		GenerateSample(DigitSamples[i], i);
	}
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
				int raw;

				SbVoice(1);
				PlayBackBuffer = DigitSamples[i];
				PlayBackCounter = 0;




				while(PlayBackCounter < SAMPLELEN) {


					raw = *(PlayBackBuffer+PlayBackCounter);
					PlayBackCounter++;

					WriteDac(0x10);
					WriteDac(raw);

					timerflag = 0;
				}

				SbVoice(0);
				break;
			}
		}
	}
}


void GenerateSample(char *Buffer, int Digit)
{
	int		Count;

	double	ColFreq, RowFreq;
	double  ColInc, RowInc;
	double	ColValue, RowValue;
	double	fval;
	char	val;

	ColFreq = ColFreqArray[Digit % 4];
	RowFreq = RowFreqArray[Digit / 4];

	ColInc = ColFreq * ((2*M_PI)/ SMPFRQ);
	RowInc = RowFreq * ((2*M_PI)/ SMPFRQ);

	ColValue = RowValue = 0.0;

	for(Count = 0; Count < (SAMPLELEN); Count++) {
        fval  = 60.0*sin(ColValue) + 60.0*sin(RowValue);
		fval +=128;
		val = (unsigned char)fval;

		*(Buffer++) = val;
		ColValue += ColInc;
		RowValue += RowInc;
	}
}


void WriteDac(int byte)
{
    while(inp(SbIOaddr+DSP_WRITE_STATUS) & 0x80);
        outp(SbIOaddr+DSP_WRITE_DATA,(byte));
}


void SbVoice(int state)
{
	WriteDac((state) ? SPEAKER_ON : SPEAKER_OFF);
}


void interrupt far NewTimer()
{
	timerflag = 1;
    outp(0x20,0x20);
}



int SbInit()
{
	int count;

    outp(SbIOaddr + 6, 1);

    inp(SbIOaddr +6);
    inp(SbIOaddr +6);
    inp(SbIOaddr +6);
    inp(SbIOaddr +6);

    outp(SbIOaddr + 6, 0);
    outp(SbIOaddr + 10, 1);

	for( count = 0; count < 100; count ++) {
        if( inp(SbIOaddr +10) == 0xAA)
			return 0;
	}
	return 1;
}

void SetTimer(unsigned long time)
{
	unsigned int count;

	time = 1193180L/time;

	count = (unsigned)time;
    _disable();
    outp(0x43, 2+4+16+32);
    outp(0x40, count & 255);
    outp(0x40, (count >> 8) & 255);
    _enable();
}
