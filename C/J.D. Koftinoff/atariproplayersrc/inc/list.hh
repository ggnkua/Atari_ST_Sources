

#ifndef __LIST_HH
#define __LIST_HH

//
//      This whole class is hokey.
//
//
//      It SHOULD just inherit from 'Persist', then the Configuration
//      class should use Persist for filing, rather than JKFile.
//      cause JKFile is kind of silly,too. 
//      that would cure the 'friend class Configuration' problem,
//      since then Configuration would be able to inherit List.
//      Since Persist only consists of a few virtual methods, and no
//      instance variables, Persist will not add any overhead to other users
//      of List.
//
//      Actually, this class should be called 'Array', not list.
//

class List
{

	friend  class   Configuration;  // this is cuz GNU G++ v1.35 don't got
					// multiple inheritance
	
protected:
	int     number, sizeofeach, size;
	uchar   *data;

		Boolean Expand( int incr=64 );
public:



	inline          List() { data=0; number=0; size=0; sizeofeach=0; }
			List( int s_of_each, int initial_num=64 );
	virtual         ~List();

	
		Boolean AddElement( void * );
	inline  void *  GetElement( int item )
			{
				if( data && item<number && item>=0)
					return( data + (item*sizeofeach) );
				else
					return NULL;
			}


	virtual void    Clear();



};


#endif
