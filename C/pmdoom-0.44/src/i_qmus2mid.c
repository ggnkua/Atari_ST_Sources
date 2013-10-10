/*
   Quick MUS to Midi converter.
   (C) 1995,96 Sebastien Bacquet  ( bacquet@iie.cnam.fr )
   
   Ported to unix by Hans Peter Verne ( hpv@kjemi.uio.no )

   This is free software, distributed under the terms of the
   GNU General Public License. For details see the file COPYING.

   Use gcc to compile, if possible.  Please look in  "qmus2mid.h"
   for system dependencies, in particular the int2 and int4 typedef's.

   For the time being, this only works for little-endian machines,
   such as i86, dec-mips, alpha;  but not rs6000, sparc....

   Ripped for the lsdldoom port by Sam Lantinga - Thanks! :)
*/

#include <stdlib.h>
#include <string.h>

#include <SDL.h>

#include "z_zone.h"
#include "i_system.h"
#include "i_qmus2mid.h"

int4 TRACKBUFFERSIZE = 65536L ;  /* 64 Ko */

typedef struct {
	unsigned char *buf;
	int len;
} buflen_t;

/* Read a 16-bit little-endian value */
static int read1(buflen_t *buflen)
{
	int value;

	if ( buflen->len < 1 ) {
		return(-1);
	}
	value = buflen->buf[0];
	buflen->buf++;
	buflen->len--;
	return(value);
}

static int read2(int2 *intp, buflen_t *buflen)
{
	int i;

	if ( buflen->len < 2 ) {
		return(0);
	}
	for ( i=0; i<2; ++i ) {
		*intp <<= 8;
		*intp |= buflen->buf[1-i];
	}
	buflen->buf += 2;
	buflen->len -= 2;
	return(1);
}

static size_t fwrite2(const int2 *ptr, size_t size, SDL_RWops *rw)
{
	int4 rev = 0;
	int i;

	for( i = 0 ; i < size ; i++ )
		rev = (rev << 8) + (((*ptr) >> (i*8)) & 0xFF) ;

	return SDL_RWwrite(rw,&rev, size, 1) ;
}


static void FreeTracks( struct Track track[] )
{
	int i ;

	for( i = 0 ; i < 16 ; i++ )
		if( track[i].data )
			Z_Free( track[i].data ) ;
}


static void TWriteByte( unsigned char MIDItrack, char byte, struct Track track[] )
{
	int4 pos ;

	pos = track[MIDItrack].current ;
	if( pos < TRACKBUFFERSIZE )
		track[MIDItrack].data[pos] = byte ;
	else {
		I_Error("ERROR : Track buffer full.\n"
			"Increase the track buffer size (option -size).\n" ) ;
	}
	track[MIDItrack].current++ ;
}


static void TWriteVarLen( int tracknum, register int4 value, 
                  struct Track track[] )
{
	register int4 buffer ;

	buffer = value & 0x7f ;
	while( (value >>= 7) ) {
		buffer <<= 8 ;
		buffer |= 0x80 ;
		buffer += (value & 0x7f) ;
	}
	while( 1 ) {
		TWriteByte( tracknum, buffer, track ) ;
		if( buffer & 0x80 )
			buffer >>= 8 ;
		else
			break;
	}
}


static int ReadMUSheader( MUSheader *MUSh, buflen_t *buflen )
{
	if ( buflen->len < 4 ) {
		return NOTMUSFILE ;
	}
	memcpy(MUSh->ID, buflen->buf, 4);
	buflen->buf += 4;
	buflen->len -= 4;
	if( strncmp( MUSh->ID, MUSMAGIC, 4 ) ) 
		return NOTMUSFILE ;
	if( read2( &(MUSh->ScoreLength),  buflen ) != 1 )
		return COMUSFILE ;
	if( read2( &(MUSh->ScoreStart),  buflen ) != 1 )
		return COMUSFILE ;
	if( read2( &(MUSh->channels),  buflen ) != 1 )
		return COMUSFILE ;
	if( read2( &(MUSh->SecChannels),  buflen ) != 1 )
		return COMUSFILE ;
	if( read2( &(MUSh->InstrCnt),  buflen ) != 1 )
		return COMUSFILE ;
	if( read2( &(MUSh->dummy),  buflen ) != 1 )
		return COMUSFILE ;
#if 0
	MUSh->instruments = (int2 *) Z_Malloc(MUSh->InstrCnt*sizeof(int2), PU_STATIC, NULL) ;
	if( SDL_RWread(rw, MUSh->instruments, 2, MUSh->InstrCnt) != MUSh->InstrCnt ) {
		Z_Free( MUSh->instruments ) ;
		return COMUSFILE ;
	}
	Z_Free( MUSh->instruments ) ; /* suppress this line if you want to display
				 instruments later */
#else
	buflen->buf += 2*MUSh->InstrCnt;
	buflen->len += 2*MUSh->InstrCnt;
#endif
	return 0 ;
}


static int WriteMIDheader( int2 ntrks, int2 division, SDL_RWops *rw)
{
	SDL_RWwrite(rw, MIDIMAGIC , 10, 1) ;
	fwrite2( &ntrks, 2, rw) ;
	fwrite2( &division, 2, rw ) ;
	return 0 ;
}

        /* maybe for ms-dog too ? */ /* Yes, why not ?... */
#define last(e)         ((unsigned char)(e & 0x80))
#define event_type(e)   ((unsigned char)((e & 0x7F) >> 4))
#define channel(e)      ((unsigned char)(e & 0x0F))

static void WriteTrack( int tracknum, SDL_RWops *rw, struct Track track[] )
{
	int2 size ;
	size_t quot, rem ;

	/* Do we risk overflow here ? */
	size = track[tracknum].current+4 ;
	SDL_RWwrite(rw,"MTrk", 4, 1) ;
	if( !tracknum )
		size += 33 ;

	fwrite2( &size, 4, rw ) ;
	if( !tracknum)
		SDL_RWwrite(rw, TRACKMAGIC1 "Quick MUS->MID ! by S.Bacquet", 33, 1) ;
	quot = (size_t) (track[tracknum].current / 4096) ;
	rem = (size_t) (track[tracknum].current - quot*4096) ;
	SDL_RWwrite(rw,track[tracknum].data, 4096, quot) ;
	SDL_RWwrite(rw,((const unsigned char *) track[tracknum].data)+4096*quot,
		rem, 1) ;
	SDL_RWwrite(rw,TRACKMAGIC2, 4, 1 ) ;
}


static void WriteFirstTrack( SDL_RWops *rw )
{
	int2 size ;

	size = 43 ;
	SDL_RWwrite(rw, "MTrk", 4, 1) ;
	fwrite2( &size, 4, rw) ;
	SDL_RWwrite(rw,TRACKMAGIC3 , 4, 1) ;
	SDL_RWwrite(rw,"QMUS2MID (C) S.Bacquet", 22, 1) ;
	SDL_RWwrite(rw,TRACKMAGIC4, 6, 1) ;
	SDL_RWwrite(rw,TRACKMAGIC5, 7, 1) ;
	SDL_RWwrite(rw,TRACKMAGIC6, 4, 1) ;
}

static int4 ReadTime( buflen_t *buflen )
{
	register int4 time = 0 ;
	int byte ;

	do {
		byte = read1( buflen ) ;
		if( byte != EOF )
			time = (time << 7) + (byte & 0x7F) ;
	} while( (byte != EOF) && (byte & 0x80) ) ;

	return time ;
}

static char FirstChannelAvailable( signed char MUS2MIDchannel[] )
{
	int i ;
	signed char old15 = MUS2MIDchannel[15], max = -1 ;

	MUS2MIDchannel[15] = -1 ;
	for( i = 0 ; i < 16 ; i++ )
		if( MUS2MIDchannel[i] > max )
			max = MUS2MIDchannel[i] ;
	MUS2MIDchannel[15] = old15 ;

	return (max == 8 ? 10 : max+1) ;
}


int qmus2mid( void *mus, size_t len, SDL_RWops *rw,
              int nodisplay, int2 division, int BufferSize, int nocomp )
{
	struct Track track[16] ;
	int2 TrackCnt = 0 ;
	unsigned char et, MUSchannel, MIDIchannel, MIDItrack, NewEvent ;
	int i, event, data, r ;
	buflen_t buflen;
	static MUSheader MUSh ;
	int4 DeltaTime, TotalTime = 0, time, min, n = 0 ;
	unsigned char MUS2MIDcontrol[15] = {
		0,			/* Program change - not a MIDI control change */
		0x00,		/* Bank select */
		0x01,		/* Modulation pot */
		0x07,		/* Volume */
		0x0A,		/* Pan pot */
		0x0B,		/* Expression pot */
		0x5B,		/* Reverb depth */
		0x5D,		/* Chorus depth */
		0x40,		/* Sustain pedal */
		0x43,		/* Soft pedal */
		0x78,		/* All sounds off */
		0x7B,		/* All notes off */
		0x7E,		/* Mono */
		0x7F,		/* Poly */
		0x79		/* Reset all controllers */
	}, MIDIchan2track[16] ;
	signed char MUS2MIDchannel[16] ;
	char ouch = 0, sec ;

	/* Set up the MUS data source */
	buflen.buf = (unsigned char *)mus;
	buflen.len = len;

	r = ReadMUSheader( &MUSh, &buflen ) ;
	if( r<0 )
		return r ;

	buflen.buf = (unsigned char *)mus + MUSh.ScoreStart;
	buflen.len = len - MUSh.ScoreStart;
	if ( buflen.len <= 0 )
		return MUSFILECOR ;

	if( !nodisplay )
		printf( "MUS chunk (%lu bytes) contains %d melodic channel%s.\n",
			(unsigned long) len, MUSh.channels,
			MUSh.channels >= 2 ? "s" : "" );
	if( MUSh.channels > 15 )      /* <=> MUSchannels+drums > 16 */
		return TOOMCHAN ;

	for( i = 0 ; i < 16 ; i++ ) {
		MUS2MIDchannel[i] = -1 ;
		track[i].current = 0 ;
		track[i].vel = 64 ;
		track[i].DeltaTime = 0 ;
		track[i].LastEvent = 0 ;
		track[i].data = NULL ;
	}
	if( BufferSize ) {
		TRACKBUFFERSIZE = ((int4) BufferSize) << 10 ;
		if( !nodisplay )
			printf( "Track buffer size set to %d KB.\n", BufferSize ) ;
	}

	if( !nodisplay ) {
		printf( "Converting..." ) ;
	}
	event = read1( &buflen ) ;
	et = event_type( event ) ;
	MUSchannel = channel( event ) ;
	while( (et != 6) && (buflen.len > 0) ) {
		if( MUS2MIDchannel[MUSchannel] == -1 ) {
			MIDIchannel = MUS2MIDchannel[MUSchannel ] = 
				(MUSchannel == 15 ? 9 : FirstChannelAvailable( MUS2MIDchannel)) ;
			MIDItrack   = MIDIchan2track[MIDIchannel] = TrackCnt++ ;
			if( !(track[MIDItrack].data = (char *) Z_Malloc( TRACKBUFFERSIZE,PU_STATIC,NULL )) ) {
				FreeTracks( track ) ;
				return MEMALLOC ;
			}
		} else {
			MIDIchannel = MUS2MIDchannel[MUSchannel] ;
			MIDItrack   = MIDIchan2track [MIDIchannel] ;
		}
		TWriteVarLen( MIDItrack, track[MIDItrack].DeltaTime, track ) ;
		track[MIDItrack].DeltaTime = 0 ;
		switch( et ) {
			case 0 :                /* release note */
				NewEvent = 0x90 | MIDIchannel ;
				if( (NewEvent != track[MIDItrack].LastEvent) || nocomp ) {
					TWriteByte( MIDItrack, NewEvent, track ) ;
					track[MIDItrack].LastEvent = NewEvent ;
				} else
					n++ ;
				data = read1( &buflen ) ;
				TWriteByte( MIDItrack, data, track ) ;
				TWriteByte( MIDItrack, 0, track ) ;
				break ;
			case 1 :
				NewEvent = 0x90 | MIDIchannel ;
				if( (NewEvent != track[MIDItrack].LastEvent) || nocomp ) {
					TWriteByte( MIDItrack, NewEvent, track ) ;
					track[MIDItrack].LastEvent = NewEvent ;
				} else
					n++ ;
				data = read1( &buflen ) ;
				TWriteByte( MIDItrack, data & 0x7F, track ) ;
				if( data & 0x80 )
					track[MIDItrack].vel = read1( &buflen ) ;
				TWriteByte( MIDItrack, track[MIDItrack].vel, track ) ;
				break ;
			case 2 :
				NewEvent = 0xE0 | MIDIchannel ;
				if( (NewEvent != track[MIDItrack].LastEvent) || nocomp ) {
					TWriteByte( MIDItrack, NewEvent, track ) ;
					track[MIDItrack].LastEvent = NewEvent ;
				} else
					n++ ;
				data = read1( &buflen ) ;
				TWriteByte( MIDItrack, (data & 1) << 6, track ) ;
				TWriteByte( MIDItrack, data >> 1, track ) ;
				break ;
			case 3 :
				NewEvent = 0xB0 | MIDIchannel ;
				if( (NewEvent != track[MIDItrack].LastEvent) || nocomp ) {
					TWriteByte( MIDItrack, NewEvent, track ) ;
					track[MIDItrack].LastEvent = NewEvent ;
				} else
					n++ ;
				data = read1( &buflen ) ;
				TWriteByte( MIDItrack, MUS2MIDcontrol[data], track ) ;
				if( data == 12 )
					TWriteByte( MIDItrack, MUSh.channels+1, track ) ;
				else
					TWriteByte( MIDItrack, 0, track ) ;
				break ;
			case 4 :
				data = read1( &buflen ) ;
				if( data ) {
					NewEvent = 0xB0 | MIDIchannel ;
					if( (NewEvent != track[MIDItrack].LastEvent) || nocomp ) {
						TWriteByte( MIDItrack, NewEvent, track ) ;
						track[MIDItrack].LastEvent = NewEvent ;
					} else
						n++ ;
					TWriteByte( MIDItrack, MUS2MIDcontrol[data], track ) ;
				} else {
					NewEvent = 0xC0 | MIDIchannel ;
					if( (NewEvent != track[MIDItrack].LastEvent) || nocomp ) {
						TWriteByte( MIDItrack, NewEvent, track ) ;
						track[MIDItrack].LastEvent = NewEvent ;
					} else
						n++ ;
				}
				data = read1( &buflen ) ;
				TWriteByte( MIDItrack, data, track ) ;
				break ;
			case 5 :
			case 7 :
				FreeTracks( track ) ;
				return MUSFILECOR ;
			default :
				break ;
		}
		if( last( event ) ) {
			DeltaTime = ReadTime( &buflen ) ;
			TotalTime += DeltaTime ;
			for( i = 0 ; i < (int) TrackCnt ; i++ )
				track[i].DeltaTime += DeltaTime ;
		}
		event = read1( &buflen ) ;
		if( event != EOF ) {
			et = event_type( event ) ;
			MUSchannel = channel( event ) ;
		} else
			ouch = 1 ;
	}
	if( !nodisplay )
		printf( "done !\n" ) ;
	if( ouch )
		printf( "WARNING : There are bytes missing at the end of MUS.\n          "
			"The end of the MIDI file might not fit the original one.\n") ;
	if( !division )
		division = 89 ;
	else
		if( !nodisplay )
			printf( "Ticks per quarter note set to %d.\n", division ) ;
	if( !nodisplay ) {
		if( division != 89 ) {
			time = TotalTime / 140 ;
			min = time / 60 ;
			sec = (char) (time - min*60) ;
			printf( "Playing time of the MUS file : %u'%.2u''.\n", min, sec ) ;
		}
		time = (TotalTime * 89) / (140 * division) ;
		min = time / 60 ;
		sec = (char) (time - min*60) ;
		if( division != 89 )
			printf( "                    MID file" ) ;
		else
			printf( "Playing time" ) ;
		printf( " : %u'%.2u''.\n", min, sec ) ;
	}
	if( !nodisplay ) {
		printf( "Writing..." ) ;
	}
	WriteMIDheader( TrackCnt+1, division, rw) ;
	WriteFirstTrack( rw ) ;
	for( i = 0 ; i < (int) TrackCnt ; i++ )
		WriteTrack( i, rw, track ) ;
	if( !nodisplay )
		printf( "done; MIDI size: %d\n", SDL_RWtell(rw)) ;

	FreeTracks( track ) ;

	return SDL_RWtell(rw) ;
}


