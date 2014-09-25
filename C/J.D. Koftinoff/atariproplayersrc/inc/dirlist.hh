

#ifndef _DIRLIST_H
#define _DIRLIST_H

#include "list.hh"


class DirList : private List
{
public:
			DirList( int s=128 );

		void	List::Clear();

		int     Search( char *tmplate, int file_type=0 );
		int	MultiSearch( char **tmplate_table, int file_type=0 ); 

	virtual void    Sort();
	
	inline  int     GetNumberFiles()
				{ return number; }
	inline  char *  GetFileName( int num )
				{ return (char*)GetElement( num ); }
		
};


#endif
