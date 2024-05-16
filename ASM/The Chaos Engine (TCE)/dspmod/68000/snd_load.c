#include <tos.h>
#include <string.h>


char *snd[4];
long snd_len[4];

void init_snd( void )
{
	int i;
	long j;
	char *p;
	char fname[] = "D:\\SOUNDS\\1.SND";
	int pos = 10;
	int handle;
	DTA	file_info;
		
	if ( Fsfirst( fname, 0 ) != 0 ) {
		strcpy( fname, "1.SND" );
		pos = 0;
	}

	for ( i = 0; i < 4; i++ ) {
		Fsfirst( fname, 0 );
		file_info = *Fgetdta();
		snd[i] = Malloc( file_info.d_length );
		handle = (int)Fopen( fname, FO_READ );
		Fread( handle, 1000000L, snd[i] );
		Fclose( handle );
		snd_len[i] = file_info.d_length;
		fname[pos]++;
		p = snd[i];
		for ( j = 1L; j <= snd_len[i]; j++ ) 
			*p++ ^= 0x80;
	}
}
