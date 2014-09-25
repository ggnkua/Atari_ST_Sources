/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include <jk_sys.h>
#include <list.hh>

List::~List()
{
	delete data;
}

void List::Clear()
{ 
	number=0; 
}
			
List::List( int s_of_each, int initial_num )
{
	data=new uchar[initial_num * s_of_each ];

	number=0;
	size=initial_num;
	sizeofeach=s_of_each;
}


Boolean List::AddElement( void *element )
{
	if( !data )
		return FALSE;
		
	if( number>=size-1 )
		if( !Expand() )
			return FALSE;
			
	memcpy( data + (number*sizeofeach), element, sizeofeach );
	
	number++;
	return TRUE;
}



Boolean List::Expand( int incr )
{
	if( !data )
		return FALSE;
	uchar *tmp = new uchar[ (sizeofeach * size) + incr ];
	if( tmp )
	{
		memcpy( tmp, data, sizeofeach*size );
		delete data;
		data=tmp;
		size+=incr;
		return TRUE;
	}
	
	return FALSE;	// out of memory
}

