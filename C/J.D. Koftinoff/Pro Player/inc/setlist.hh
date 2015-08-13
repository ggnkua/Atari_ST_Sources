
#ifndef __SETLIST_HH
#define __SETLIST_HH

#include <list.hh>
#include "song.hh"
#include "text.hh"



struct SetListItem
{
	Song *song;
	Song *excl;
	TextFile *text;
};


class SetList : private List
{
protected:
	int set_number;

	SetListItem *GetSetListItem( int num );
public:
	SetList( int size=1024 );
	~SetList();

	void Clear();	
	Boolean LoadSet( int num );
	Boolean CreateSet();
	
	FileErr LoadItem( int num );
	
	Song *GetSong( int num );
	Song *GetExclusive( int num );
	Song *GetText( int num );
	
	int GetSetNumber();
};


inline int SetList::GetSetNumber() { return set_number };

inline SetListItem *GetSetListItem( int num )
{
	return (SetListItem*)GetElement(num);
}



#endif


