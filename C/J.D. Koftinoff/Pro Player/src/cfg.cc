/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "perform.h"
#pragma hdrstop

#include "cfg.hh"



Configuration::Configuration(char *id, int max_size ) :
	l( sizeof( ConfigElement ), max_size )
{
	memcpy( id_mark, id, 16 );
}


Boolean Configuration::Load( char *path )
{
	char id[16];
	long sz;
	int i;

	if( path )
		SetFilePath( path );

	if( Open()!=NoErr )
		return FALSE;

	Read( 16, id );

	for( i=0; i<16; i++ )
		if( id[i] != id_mark[i] )
		{
			Close();
			return FALSE;
		}

	ReadLong( &sz );
#if _INTEL
	TWIDDLELONG( &sz );
#endif

	if( sz>l.size && sz<256 )
	{
		free( l.data );
		l.data=(uchar *)malloc( (sz+64) * l.sizeofeach );
		if( !l.data )
		{
			sz=0;
			Close();
			return FALSE;
		}
		l.size=sz+64;
	}

	if( sz>0 )
		Read( sz*sizeof( ConfigElement ), l.data );
	l.number=sz;

	Twiddle();
	Close();
	return TRUE;
}

Boolean Configuration::Save( char *path )
{
	if( path )
		SetFilePath( path );

	if( !l.data )
		return FALSE;

	Create();
	if( Open( io_write )!=NoErr )
		return FALSE;
	Write( 16, id_mark );
	Twiddle();

#if _INTEL
	long xx=l.number;
	TWIDDLELONG( &xx );
	WriteLong( xx );
#endif
#if _MOTOROLA
	WriteLong( l.number );
#endif

	if( l.number>0 )
		Write( l.number*sizeof( ConfigElement ),l.data );
	Twiddle();
	Close();
	changed=FALSE;
	return TRUE;
}


Boolean Configuration::Get( long type, long *value )
{
	ConfigElement *e;

	for( int i=0; i<l.number; i++ )
	{
		e=(ConfigElement *)l.GetElement( i );

		if( e->type==type )
		{
			*value=e->value;
			return TRUE;
		}
	}
	*value=-1;
	return FALSE;
}

long Configuration::Get( long type )
{
	ConfigElement *e;
	
	for( int i=0; i<l.number; i++ )
	{
		e=(ConfigElement *)l.GetElement( i );
		
		if( e->type==type )
		{
			return e->value;
		}
	}
	return -1;
}


Boolean Configuration::Set( long type, long value )
{
	long old_value;
	
	ConfigElement *e;
	
	for( int i=0; i<l.number; i++ )         // first try find it
	{
		e=(ConfigElement *)l.GetElement( i );
		
		if( e->type==type )
		{
			e->value=value;         // set new value
			changed=TRUE;
			return TRUE;
		}
	}

	// ok, we didn't find it. can we add it?        

	ConfigElement f;
	f.type=type;
	f.value=value;
	changed=TRUE;
	return l.AddElement( &f );                      // try add the element
}


void    Configuration::Twiddle()
{
#if     _INTEL          // this way, the actual binary files are compatible.
	for( int i=0; i<l.number*l.sizeofeach; i++ )
	{

		TWIDDLELONG( &(((long *)l.data)[i])  );

	}
#endif
}
