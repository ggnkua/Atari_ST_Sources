

#ifndef __SETFILE_HH
#define __SETFILE_HH

#include <stfile.hh>


#define _SetFile_Size 1024


class SetFile : private STFile
{
private:
	char id_mark[16];
	
	int num_elements;
	int max_elements;
	char elements[_SetFile_Size][16];

public:
	SetFile( char *mark );
	~SetFile();
	
	Boolean Save( char *path=NULL );
	Boolean Load( char *path=NULL );

	int GetNumber();

	void	EraseAll();

	void Insert( char *fname, int pos );
	void Delete( int pos );
	
	char *Get( int item );

	STFile::SetFilePath( char * );
	STFile::GetFilePath( char * );
	Boolean STFile::Exists();
};

inline SetFile::SetFile( char *mark )
{
	memcpy( id_mark, mark, 16 );
	num_elements=0;
	max_elements=_SetFile_Size;
}

inline SetFile::~SetFile()
{

}

inline void SetFile::EraseAll()
{
	num_elements=0;
}


inline int SetFile::GetNumber()
{
	return num_elements;
}


inline char *SetFile::Get( int item )
{
	if( item>num_elements )
		return NULL;
	else
		return elements[item];
}

#endif

