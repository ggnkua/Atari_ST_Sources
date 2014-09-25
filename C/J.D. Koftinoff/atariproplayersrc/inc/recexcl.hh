
#ifndef __RECEXCL_HH
#define __RECEXCL_HH

#include <sgdlog.hh>


class RecExcl : SGDlog
{
protected:
	unsigned char *excl_buffer;
	unsigned long excl_len;
	unsigned long buf_size;
	
	Boolean done;

	void 	SetStatusText( char *, Boolean draw );
	void	SaveExcl();
	Boolean RecordExcl();
	Boolean ObjectClick( int obj );	
public:
	RecExcl();
	virtual ~RecExcl();
	
	Boolean DoIt();
};


#endif


