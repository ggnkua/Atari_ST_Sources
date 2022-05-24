#include <stdio.h>
#include <conio.h>

#define SbIOaddr	0x220


int  SbInit(void);

static void (interrupt far *OldTimer)(void);

void main()
{
    if(SbInit())
        puts("Soundblaster not reset");
    else
        puts("Soundblaster reset");
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
