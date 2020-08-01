/////////////////////////////////////////////////////////////////////////////
//
//  GEMdeskaccessory
//
//  A GEMdeskaccessory is a GEM desk accessory.
//
//  This is the base class from which a desk accessory application derives
//  the interactive object - defining the Open() and Close() methods for
//  the desk accessory.
//
//  WARNING:  Programs which will function as desk accessories
//            should include the following definitions:
//
//            extern int _app;
//            char _stack_heap[1024];
//            void *_heapbase = (void *)_stack_heap;
//            long _stksize = sizeof(_stack_heap);
//
//            The program may test the _app global.  If 1, function
//            as an application, otherwise as a desk accessory.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMda_h
#define GEMda_h


class GEMapplication;
class GEMactivity;
class GEMevent;

class GEMdeskaccessory
{
public:
	GEMdeskaccessory(const GEMapplication& appl, GEMactivity& in, const char* MenuItemName);
	virtual ~GEMdeskaccessory();

	void Open(const GEMevent&);
	void Close(const GEMevent&);

protected:
	virtual void Open()=0;
	virtual void Close()=0;

private:
	GEMactivity& act;
	int menuid;
};


#endif
