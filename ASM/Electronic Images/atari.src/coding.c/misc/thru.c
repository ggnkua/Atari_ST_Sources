#include <stdio.h>
#include <conio.h>
#include <dos.h>

#define SbIOaddr            0x220
#define	IRQ					7


#define MIDI_READ_POLL	    0x30
#define MIDI_WRITE_POLL     0x38

#define DSP_READ_DATA       0x0A
#define DSP_WRITE_DATA      0x0C
#define DSP_WRITE_STATUS    0x0C
#define DSP_DATA_AVAIL      0x0E


int SbInit(void);

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


void writedac(int x)
{
	while(inp(SbIOaddr+DSP_WRITE_STATUS) & 0x80);
	outp(SbIOaddr+DSP_WRITE_DATA,(x));
}


void main()
{
	int i;

	SbInit();
	for(i = 0x30; i < 0x40; i++) {
		printf("\nTrying: %X\n", i);
		writedac(i);
		getch();
	}
}
