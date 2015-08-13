

#ifndef __CFG_HH
#define __CFG_HH


#include "list.hh"
#include "jkfile.hh"



struct ConfigElement
{
	long type;
	long value;
};


class Configuration :
	public JKFile
{
private:
	List l;
	Boolean changed;
protected:
	char id_mark[16];
	void    Twiddle();
public:
		Configuration( char *id, int max_size=64 );

		Boolean Load( char *path=NULL);
		Boolean Save( char *path=NULL);

		Boolean Get( long type, long *value );
		long    Get( long type );
		Boolean Set( long type, long value );

	inline  Boolean HasChanged()
			{ return changed; }
};

#endif
