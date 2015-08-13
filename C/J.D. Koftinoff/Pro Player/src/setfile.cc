/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include <jklib.hh>
#include "perform.h"


#include "setfile.hh"


Boolean SetFile::Save( char *path  )
{
	if( path )
		SetFilePath( path );
		
	Create();
	
	if( Open( io_write )!=NoErr )
		return FALSE;	
	
	if( Write( 16, id_mark )!=NoErr )
	{
		Close();
		return FALSE;
	}
	
	WriteString( JKForm64( "\r\n%04d\r\n", GetNumber() ) );
	
	for( int i=0; i<GetNumber(); i++ )
	{
		WriteString( Get( i ) );
		WriteString( "\r\n" );
	}

	Close();
	return TRUE;
}


Boolean SetFile::Load( char *path )
{
	char id[16];
	
	if( path )
		SetFilePath( path );
	

	if( Open()!=NoErr )
		return FALSE;
	
	if( Read( 16, id )!=NoErr )
	{
		Close();
		return FALSE;
	}
	

	for( int i=0; i<16; i++ )
		if( id[i] != id_mark[i] )
		{
//			paramdlog( "set file is wrong type" );
			Close();
			return FALSE;
			
		}
	

	char s[20];
	int num;
	
	ReadString(s,16 );
	
		
	if( ReadString( s, 15 )==NoErr )
	{
		sscanf( s, "%d", &num );
		
		if( num>0 )
		{
			EraseAll();
			
			if( num>max_elements )
				num=max_elements;
			
			for( int i=0; i<num; i++ )
			{
				ReadString( s, 16 );
				if( strlen(s)>0 )
				{
					Insert( s, i );
				}
			}
		}
	}

	Close();
	
	return TRUE;
}


void SetFile::Insert( char *fname, int pos )
{
	if( pos>=max_elements || pos<0 )
		return;
		
	if( pos!=num_elements )
	{
		memcpy( elements[pos+1], elements[pos], (num_elements-pos)*16 );
	}
	
	strncpy( elements[pos], fname, 15 );
	num_elements++;
	return;
	
	
	
}


void SetFile::Delete( int pos )
{
	if( pos>=max_elements || pos<0 || pos>=num_elements )
		return;

	memcpy( elements[pos], elements[pos+1], (num_elements-pos-1)*16 );
	num_elements--;
	
}


