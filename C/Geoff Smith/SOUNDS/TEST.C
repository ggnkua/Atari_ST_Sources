/************************************/
/* This is a test for sampled sound */
/************************************/

#include <sound.h>

/* declare structure to store sound */
SOUNDSTUFF test_sample;

void main(void)
{
	char dir[40]  = {".\\"};
	char file[20] = {"TEST.AVR"};

	read_sound( dir, file, &test_sample );
	play_sound( &test_sample );
	printf("press a key when sound has finished\n");
	getch();
	free_sound( &test_sample );
}
