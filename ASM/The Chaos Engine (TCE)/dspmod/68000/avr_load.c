#include <tos.h>
#include <string.h>

typedef struct
{
  long magic;
  char sample_name[8];
  int mode;
  int resolution;
  int sign;
  int loop;
  int note;
  long speed;
  long len;
  long beg_loop;
  long end_loop;
  int res1, res2, res3;
  char extension[20];
  char free_area[64];
} AVRHEAD;

char *load_avr( char *name );

char *avr[4];
long avr_len[4];

void init_avr( void )
{
	
	long d = sizeof( AVRHEAD );
	AVRHEAD *p;
	int i;
	char *fname = "1.AVR";
		
	for ( i = 0; i < 4; i++ ) {
		avr[i] = load_avr( fname );
		p = (AVRHEAD*)avr[i];
		avr_len[i] = p->len;
		avr[i] += d;
		fname[0]++;
	}
}


char *load_avr( char *name )
{
	char fname[80] = "D:\\SOUNDS\\";
	char *avr, *p;
	int handle;
	DTA	file_info;

	strcat( fname, name );
	p = name;

	if ( Fsfirst( name, 0 ) != 0 ) {
		Fsfirst( fname, 0 );
		p = fname;
	}
	file_info = *Fgetdta();
	
	avr = Malloc( file_info.d_length );
	
	handle = (int)Fopen( p, FO_READ );
	Fread( handle, 1000000L, avr );
	Fclose( handle );
	
	return( avr );
}
