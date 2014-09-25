/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "setlist.hh"


SetList::SetList( int size=1024 )
{
	
}

SetList::~SetList()
{
	Clear();
}

void SetList::Clear()
{
	SetListItem *item;
	
	for( unsigned short i=0; i<number; i++ )
	{
		item=GetSetListItem( i );
		if( item->song )
			delete item->song;
		if( item->excl )
			delete item->excl;
		if( item->text )
			delete item->text;
	}
	
	List::Clear();	
}

Boolean SetList::CreateSet()
{

}

Boolean SetList::LoadSet( int num )
{

}
	
Song *SetList::GetSong( int num )
{
	return GetSetListItem( num )->song;
}

Song *SetList::GetExclusive( int num )
{
	return GetSetListItem( num )->excl;
}

Song *SetList::GetText( int num )
{
	return GetSetListItem( num )->text;
}
