/*

DSP-MOD-Player 
Coderight by bITmASTER of BSW

*/

#define POSTEST 0
#define LOD 1
#define PLAY 1

#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <ext.h>

/* Globales */

/*char dsp_buffer[10000];*/
int debug_buf[16384];
int debug_idx = 0;

long dsp_len;
long mod_space;
int flag = 0;

extern int cur, min, max, debug, dsp_debug;
extern int ExtSpeed;
extern int ModTracks, DspTracks;
extern char DspFlags;

extern char *snd[4];
extern long snd_len[4];

/* Prototypen */

void print_at( int y, int x, char *txt );
void dump( void );

extern int load_dsp( void );
extern int load_lod( char *fname );

extern char *init( unsigned int play_freq );
extern void off( void );
extern void PlayerOn( char *mod, int *vol_init );
extern void PlayerOff( void );
extern int  PlayTime( char *mod );
extern int  ModType( char *mod );
extern void init_snd( void );
extern void fx_test( int channel, long len, char *samp );

extern struct {
	long ptr;
	long end;
	long repstart;
	long replen;
	long ptr_frac;
	int per;
	int vol;
	int main_vol;
	int pos;
} SampSets[];

extern int SongPosition;
extern int PatternPosition;

extern unsigned long FracPos[];

extern void depack( char * );

extern void oszi_on( void );
extern void oszi_off( void );
extern void oszi_vbl( void );

int main( int argc, const char *argv[] )
{
	char *mod;
	int i;
	int time;
	char c;
	int vol_off;
    long old_super_stack;
	int vol_tab4[] = { 0x7fff, 0x7fff, 0x7fff, 0x7fff, 
					   0x7fff, 0x7fff, 0x7fff, 0x7fff };
	int vol_tab8[] = { 0x3fff, 0x3fff, 0x3fff, 0x3fff,
	                   0x3fff, 0x3fff, 0x3fff, 0x3fff };
	int *vol_tab_ptr;
	                   
			
	int handle;
	DTA	file_info;
	char fname[80]; 
	char *version;
	
	if ( argc == 1 )
		strcpy( fname, "e:\\mod\\fletch.MOD" );
	else  
		strcpy( fname, argv[1] );
				
	printf( "\x1b\x45\x1b\x66" );	/* cls / Cursor aus */	

	/* MOD laden */
	
	Fsfirst( fname, 0 );
	file_info = *Fgetdta();

	mod_space = file_info.d_length;
	mod = Malloc( mod_space );
	
	handle = (int)Fopen( fname, FO_READ );
	Fread( handle, 1000000L, mod );
	Fclose( handle );

/*	init_snd(); */
	
#if LOD
	load_lod( "C:\\DSPASS\\DSPMOD\\MODPLAY.LOD" );
#else
	load_dsp();							/* DSP-Programm starten */
#endif

	old_super_stack = Super( 0L );
	version = init( 49170U ); 			/* 32780 */
    Super((void *) old_super_stack );
	oszi_on();
	printf( "DSP-MOD Developer-System, (c) by bITmASTER of TCE / " );
	printf( "%s\n", version );
	time = PlayTime( mod );
	printf("Play-Time = %x ", time );
	
/*	for ( i = 0; i < 10000; i++ );*/ 

	vol_tab_ptr = vol_tab4;
	if ( ModType( mod ) == 8 )
		vol_tab_ptr = vol_tab8;

#if PLAY
 	PlayerOn( mod, vol_tab_ptr );
#endif

	while ( flag == 0 ) {
		if ( kbhit() ) {
			c = getch();
			switch( c ) {
				case ' ':
				case 'q': flag = 1; break;
				case 's': {
					DspFlags ^= 1;
					if ( DspFlags & 1 )
						print_at( 1, 60, "Surround" );
					else
						print_at( 1, 60, "        " );
					break;
				} 
				case 'i': {
					DspFlags ^= 2;
					if ( DspFlags & 2 )
						print_at( 2, 60, "Interpolate" );
					else
						print_at( 2, 60, "           " );
					break;
				} 
				case 't': {
					if ( DspTracks == 4 )
						DspTracks = 8;
					else {
						DspTracks = 4;
						print_at(  8, 0, "                       " );
						print_at(  9, 0, "                       " );
						print_at( 10, 0, "                       " );
						print_at( 11, 0, "                       " );
					}						
					break;
				}
				case '1':
				case '2':
				case '3':
				case '4': {
					c -= ( '0' + 1 );
					fx_test( c, snd_len[c], snd[c] );
					break;
				}
			}
		}
		oszi_vbl();
		printf( "\x1b\x59\x22\x20" );
		printf( "min: %04.4d max: %04.4d cur: %04.4d ExtSpeed: %04.4d Debug: %04.4d\n", min, max, cur, ExtSpeed, dsp_debug );
		printf( "songpos: %02.2d pattpos: %04.4d\n", SongPosition, PatternPosition >> 4 );
		for ( i = 0; i < DspTracks; i++ )
			printf( "%06.6lx %06.6lx %06.6lx %02.2d\n", SampSets[i].ptr, SampSets[i].end, SampSets[i].replen, SampSets[i].vol );
		}
	if ( c == 'q' ) {
		while( 1 ) {
			Vsync();
			vol_off = 0;
			for ( i = 0; i < 8; i++ ) {
				SampSets[i].main_vol -= ( 0x7fff / 400 );
				if ( SampSets[i].main_vol < 0 ) {
					SampSets[i].main_vol = 0;
					vol_off++;
				}
			}
			if ( vol_off == 8 )
				break;
		}
	}
	
#if PLAY
	PlayerOff();
#endif

	oszi_off();
	old_super_stack = Super( 0L );
	off();
    Super((void *) old_super_stack );
	printf("\x1b\x65");			/* Cursor an */

#if POSTEST

	if ( flag == 2 ) {
		printf( "poscalc-error !\n" );
		for ( i = 0; i < DspTracks; i++ ) {
			printf( "%08.8lx  ", SampSets[i].ptr_frac );
			printf( "%08.8lx\n", FracPos[i]<<1 );
		}
		getch();
	}
#endif
	dump();
	return(0);
}

void print_at( int y, int x, char *txt )
{
	char s[] = "\x1bY__";
	
	s[2] = y + 32;
	s[3] = x + 32;
	printf( "%s%s", s, txt );
}

void dump( void )
{
	FILE *fp;
	int i, d;
	
	if ( debug_idx ) {
		printf( "dumping\n" );
		fp = fopen( "C:\\DSPASS\\DUMP.txt", "w" );
		i = 0;
		while( i < debug_idx ) {
			d = debug_buf[i++];
			if ( d == -12345 )
				fprintf( fp, "\n" );
			else
				fprintf( fp, "%04.4d ", d );
		}
		fclose( fp );
	}
}
