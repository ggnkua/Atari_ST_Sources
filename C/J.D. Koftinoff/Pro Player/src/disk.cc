/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
/*	disk.c				By Jeff Koftinoff
**	v1.0				started: apr 17/88
**
*/



#include "perform.h"
#include "protect.h"
#include "jk_os.h"
#include "setfile.hh"

#include "olddisk.h"


extern Boolean disk_error(  DiskErr,  char * );

Boolean load_set( SET *set, char *file )
{
	SetFile *s = new SetFile("SETV7.0 PERFORM ");
	
	if( !s->Load( file ) )
	{
		delete s;
		return disk_error( OpenError, file );
	}

	set->num_songs=s->GetNumber();
	if( set->num_songs>NUM_SONGS )
		set->num_songs=NUM_SONGS;

	for( unsigned short i=0; i<set->num_songs; i++ )
	{
		//printf( "read set: song '%s'\n", s->Get(i) );
		//getch();

		strcpy( set->list[i],s->Get(i) );
		*index( set->list[i], '.' )='\0';
	}
	delete s;
	return TRUE;
}


Boolean load_lyrics( char **data, char *file )
{
	int h;
	register char *p;
	
	if( (h=jk_open( file, JK_O_RO ))<0 )
		return FALSE;
	long len=jk_seek( 0, h, JK_S_END );
	jk_seek( 0, h, JK_S_BEG );

	p=(char *)malloc(len+32);	/*	allocate for lyrics	*/
	*data=p;
	if( !p ) goto close;
	
	(void)jk_read( h, len, *data );
	(*data)[len]='\0';

close: 
	(void)jk_close( h );
	return TRUE;	// always no error
}

/*	load_s_param() loads only the song parameters into memory.
**  it is up to you then to allocate memory and call
**	load_s_data()
*/

#if 0

Boolean load_s_param( SONG *song, char *file )
{
int h;
DiskErr err;
long type;
struct midi_header header;


	err=NoError;
	
	if( (h=jk_open( file, JK_O_RO ))<0 )
		return( disk_error( OpenError, file ) );
	if( jk_read( h, 4L, &type ) != 4L ) {
		err=ReadError;
		goto close;
	}


	if( type==TSNG1 ) {
		(void)jk_seek( 0L,h,JK_S_BEG );

		if( jk_read( h, (long)sizeof( SONG ), song ) != (long)sizeof(SONG)) {
			err=ReadError;
			goto close;
		}
	}
	else
	if( type==TMThd ) {
		/* read the MIDI file's parameters into memory	*/
		if( jk_read( h, (long)sizeof( struct midi_header ), &header )!=(long)sizeof( struct midi_header ) ) {
			err=ReadError;
			goto close;
		}
		if( header.format!=0 || header.ntracks!=1 ) {
			err=TypeError;
			goto close;
		}
		(void)jk_seek( header.header_len+8, h, JK_S_BEG );

		if( jk_read( h, 4L, &type )!=4L ) {
			err=ReadError;
			goto close;
		}
		if( type!=TMTrk ) {
			err=TypeError;
			goto close;
		}
		if( jk_read( h, 4L, &song->length )!=4L ) {
			err=ReadError;
			goto close;
		}
		/* calculate offset to song data */
		song->offset=header.header_len+8+8;
		
		/* use the file name as song name */
		
		separate_path( file, NULL, NULL, song->full_name );
	//		strcpy( song->full_name, file );
		*index( song->full_name, '.' )='\0';
		
		song->type=TMThd;
		song->thru=-2;	/* same as global param */
		song->master_local=-1;
		song->division=header.division;
	}
	else {
 		err=TypeError;
	}

close:
	(void)jk_close( h );
	
	return( disk_error( err, file ) );
}
#else
Boolean load_s_param( SONG *song, char *file )
{
int h;
DiskErr err;
long type;
struct midi_header header;
unsigned char buf[sizeof(SONG)];

	err=NoError;
	
	if( (h=jk_open( file, JK_O_RO ))<0 )
		return( disk_error( OpenError, file ) );
	if( jk_read( h, sizeof(SONG), buf ) != sizeof(SONG) ) 
	{
		err=ReadError;
		goto close;
	}
	
	type=OSTYPE( buf[0], buf[1], buf[2], buf[3] );

	

	if( type==TMThd ) 
	{
		/* read the MIDI file's parameters into memory	*/
		
		header=*((struct midi_header *)&buf[0]);

		if( header.format!=0 || header.ntracks!=1 ) {
			err=TypeError;
			goto close;
		}
				
		if( header.trk_type!=TMTrk ) 
		{
			err=TypeError;
			goto close;
		}
		song->length=header.trk_len;
		
		/* calculate offset to song data */
		song->offset=header.header_len+8+8;
		
		/* use the file name as song name */
		
	//	separate_path( file, NULL, NULL, song->full_name );
	
		for( int x=strlen( file ); x>0; x-- )
		{
			if( file[x]=='\\' )
			{
				break;
			}
		};
		
		strcpy( song->full_name, &file[x+1] );
		*index( song->full_name, '.' )='\0';
		
		song->type=TMThd;
		song->thru=-2;	/* same as global param */
		song->master_local=-1;
		song->division=header.division;
	}
	else
	if( type==TSNG1 )
	{
		*song=(*(SONG*)buf);
	}
	else 
	{
 		err=TypeError;
	}

close:
	(void)jk_close( h );
	
	return( disk_error( err, file ) );
}
#endif

/*	Once you have allocated memory for the song (and put the address
**	of it in the SONG struct, (in 'location' field)
**  	load_s_data loads the file into memory.
*/

Boolean load_s_data( SONG *song, char *file )
{
int h;
DiskErr err;

	err=NoError;
	
	if( (h=jk_open( file, JK_O_RO ))<0 )
		return( disk_error( OpenError, file ) );

	(void)jk_seek( song->offset, h, JK_S_BEG );

	if( jk_read( h, song->length, song->location ) != song->length ) {
		err=ReadError;
	}
	(void)jk_close( h );
	return( disk_error( err, file ) );

}


/* save_s_all() saves the entire song file (creates a file)
*/

Boolean save_s_all( SONG *song, char *file )
{
int 	h;
DiskErr err;
long orig_type;

	pwrite(1,1);
	err=NoError;

	orig_type=song->type;

	song->type=TSNG1;
	
	if( (h=jk_create( file, JK_C_RW ))<0 )
		return( disk_error( CreateError, file ) );
	if( pread(1)!=1 ) goto close;
	song->offset=sizeof( *song );
	if( jk_write( h, (long)sizeof( SONG ), song )!=(long)sizeof( SONG ) ) {
		err=WriteError;	
	}
	else {
		if( jk_write( h, song->length, song->location )!=song->length )
			err=WriteError;
	}
close:
	(void)jk_close( h );

	song->type=orig_type;

	return( disk_error( err, file ) );
}

