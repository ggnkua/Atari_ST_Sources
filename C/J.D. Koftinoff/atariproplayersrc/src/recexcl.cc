/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include <sglib.h>

#include "recexcl.hh"
#include "rec_excl.h"
#include "jk_os.h"
#include "olddisk.h"


typedef struct _SONG {
	long	type,
		length,
		offset;			// 	offset to song data
	unsigned char	*location;
	char	thru,
		master_local,
		full_name[32];
	short	division;		// for Midi files	
	char	_later[76];			
} SONG;

static iorec *rs_iorec, rs_iocpy;
static char *rs_buffer=NULL;

Boolean rs_init( int );
void rs_exit();
long jk_get_200();
Boolean save_s_all( SONG *song, char *file );


/* save_s_all() saves the entire song file (creates a file)
*/

Boolean save_s_all( SONG *song, char *file )
{
int 	h;
Boolean err;
long orig_type;

	err=FALSE;

	orig_type=song->type;

	song->type=OSTYPE( 'S', 'N', 'G', '1' );
	
	if( (h=jk_create( file, JK_C_RW ))<0 )
		return FALSE;

	song->offset=sizeof( *song );
	if( jk_write( h, (long)sizeof( SONG ), song )!=(long)sizeof( SONG ) ) 
	{
		err=TRUE;	
	}
	else 
	{
		if( jk_write( h, song->length, song->location )!=song->length )
			err=TRUE;
	}
close:
	(void)jk_close( h );

	song->type=orig_type;

	return !err;
}


static long t_time;

static void getit()
{
	t_time=(*(long *)0x4ba);
}

long jk_get_200()
{
	Supexec( getit );
	return t_time;
}



Boolean rs_init( int size)    /* initialize buffers, */
{
	if( rs_buffer ) 
	{
		rs_exit();
	}
	rs_buffer=(char *)malloc( size );
	if( !rs_buffer ) return( FAILED );
	
    rs_iorec=(iorec *)Iorec(2);
    rs_iocpy=*rs_iorec;

    rs_iorec->ibuf=rs_buffer;
    rs_iorec->ibufsiz=size;
    rs_iorec->ibufhd=0;
    rs_iorec->ibuftl=0;
    rs_iorec->ibuflow=size/2;
    rs_iorec->ibufhigh=size/4*3;
	return( OK );
}



void rs_exit()    /* reset buffers            */
{
	if( rs_buffer ) {
   	 	*rs_iorec = rs_iocpy;
   	 	free( rs_buffer );
   	 }
}


extern OBJECT *rs_trindex[];

RecExcl::RecExcl()
{
	InitDlog( rs_trindex[TR_EXCL] );
	buf_size=0;
	excl_buffer=0;
	done=0;
	
	rs_init(8192);

	long max_mem=(long)Malloc(-1L);				
	excl_buffer = (unsigned char *)malloc(max_mem/4*3);
	if( excl_buffer )
		buf_size=max_mem/4*3;
	else
	{
		excl_buffer = (unsigned char *)malloc(max_mem/2);
		if( excl_buffer )
			buf_size=max_mem/2;	
	}

}

RecExcl::~RecExcl()
{
	if( excl_buffer )
	{
		free( excl_buffer );
		excl_buffer=0;
	}
	rs_exit();
}



void RecExcl::SetStatusText( char *s, Boolean draw )
{
	strcpy( GetText( TE_STAT ), s );
	if( draw )
		DrawItem( TE_STAT );
}


void RecExcl::SaveExcl()
{
	SONG song;
	
	song.length=excl_len;
	song.offset=0;
	song.thru=16;
	song.master_local=-1;
	song.full_name[0]='\0';
	song.location=excl_buffer;
	
	// do a fsel here to \songs
	char path[96];
	char fname[16];
	
	strcpy( path, "\\SONGS\\" );
	if( SGfsel( "*.EXC", path ) )
	{
		Draw();
		for( int j=strlen(path); j>=0; j-- )
		{
			if( path[j]=='\\' )
			{
				strncpy( song.full_name,
					&path[j+1], 14 );
				break;			
			}
		}
		while( !save_s_all( &song, path ) )
		{
			if( form_alert( 1,"[1][Error writing file. Try again?]"
				"[ YES | NO ]" ) ==2 )
					break;
		}
	}
	Draw();
}

Boolean RecExcl::RecordExcl()
{
	long last_time=0;
	long dif;
	excl_len=0;
	int byte;
	
	SetStatusText( "RECORDING EXCL - ANY KEY ENDS", TRUE );	
	
	while( !kbhit() )
	{
		if( excl_len > buf_size - 1024 )
		{
			form_alert( 1, "[1][ Out of memory! ][ Oh oh ]" );
			SetStatusText(
		       "                             ", TRUE );
			return FALSE;
		}
		
		if( midi_stat() )
		{
			if( last_time )
			{
				dif=jk_get_200() - last_time;
				
				if( dif > 200 )
					dif=200;
				if( dif >5 )
				{
					excl_buffer[excl_len++]=0xff;
					excl_buffer[excl_len++]=dif;
				}
			}
			
			last_time=jk_get_200();
			byte=midi_in();
			if( byte>0xf0 && byte<0xf7 )
				continue;
			if( byte>0xf7 )
				continue;

			excl_buffer[excl_len++]=byte;
		}
	}
	if( kbhit() )
		getch();
		
	SetStatusText( "                             ", TRUE );

	if( excl_len )
		return TRUE;
	else
		return FALSE;
}

Boolean RecExcl::ObjectClick( int obj )
{
	if( obj==TE_START )
	{
		if( RecordExcl() )
			SaveExcl();
		DeSelect( obj );
		DrawItem( obj );
		return TRUE;
	}
	if( obj==TE_EXIT )
	{
		DeSelect( obj );
		DrawItem( obj );
		done=TRUE;
		return TRUE;
	}
	return FALSE;
}

Boolean RecExcl::DoIt()
{
	if( !excl_buffer )
	{
		form_alert( 1, "[1][ Sorry, there was a memory allocation|Error]"
			"[ EXIT ]" );
		return TRUE;
	}
	
	SetStatusText("",FALSE);
	Draw();

	while( !done )
	{
		ObjectClick( form_do( o.d, 0 )&0x7fff );
	}
	return TRUE;
}


