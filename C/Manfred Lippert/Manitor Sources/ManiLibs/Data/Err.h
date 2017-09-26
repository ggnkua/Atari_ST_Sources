/*----------------------------------------------------------------------------------------
	Err.h, general (platform independend) error codes

	9.5.1999 by Manfred Lippert, mani@mani.de

	last change: 13.10.2001
----------------------------------------------------------------------------------------*/

#ifndef __ManiLibs_Err_H__
#define __ManiLibs_Err_H__

/*××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××
	MP-safe:			yes, if a Err object is manipulated by one thread per time only
						(normally that should never be a real problem.)

			CAUTION: DEBUG_OS_ERR != 0 can cause printf calls - these are NOT MP-safe!
						(If another thread makes a printf at the same time,
						 you may crash, or get cryptic output.)

	MP-callable:	any context
××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××*/

#include <Types2B.h>
#if DEBUG_OS_ERR
#include <stdio.h>
#endif

// negative errors are reserved for all possible general errors (for all applications)
// positive errors can be used for application specific errors

const int16 OK					=  0;		// OK, no error
const int16 ERR_ERR			= -1;		// general (or unknown) error
const int16 ERR_FINISHED	= -2;		// finished (no more items etc.) - the actual item is NOT valid
const int16 ERR_OS			= -3;		// OS error (use getOS() to get the OS error)
const int16 ERR_OOM			= -4;		// out of memory
const int16 ERR_READ			= -5;		// read error
const int16 ERR_WRITE		= -6;		// write error
const int16 ERR_SEEK			= -7;		// seek error
const int16 ERR_ACCDN		= -8;		// access denied
const int16 ERR_FOPEN		= -9;		// file open error
const int16 ERR_FCREATE		= -10;	// file create error
const int16 ERR_NOTOPEN		= -11;	// file not opened
const int16 ERR_PARAM		= -12;	// invalid parameter
const int16 ERR_EXISTS		= -13;	// file (or other object) already exists
const int16 ERR_NOTEXIST	= -14;	// file (or other object) does not exist
const int16 ERR_OOI			= -15;	// out of index
const int16 ERR_MODIFIED	= -16;	// modified (-> e.g. iterator needs to be reset)
const int16 ERR_NOTFOUND	= -17;	// object not found
const int16 ERR_SIZE			= -18;	// wrong size
const int16 ERR_OVERFLOW	= -19;	// number overflow
const int16 ERR_WARNING		= -20;	// harmless error, warning only
const int16 ERR_CORRUPT		= -21;	// data is corrupt

class Err {
	int16 code;
	int32 os;

public:

	Err() {code = OK; os = 0;};
	Err(int16 errcode, int32 oserror = 0) {code = errcode; os = oserror;};

	void set(int16 errcode) {code = errcode;};
#if DEBUG_OS_ERR
	void setOS(int32 oserror, char *file, long line) {
		printf("[OSErr: %ld (>%s<, line %ld)]\n", (long)oserror, file, line);
		code = ERR_OS; os = oserror;
	};
#else
	void setOS(int32 oserror) {code = ERR_OS; os = oserror;};
#endif

// takes only the first error code:
	void setErr(Err err) {if (code == OK) {code = err.code; os = err.os;}};

	int16 get(void) const {return code;};
	int32 getOS(void) const {return os;};

	bool is_error(void) const {return code != OK;};
	bool is_ok(void) const {return code == OK;};

	void operator=(int16 errcode) {set(errcode);};
	bool operator==(int16 errcode) {return (code == errcode);};
	bool operator==(Err& err) {return (code == err.code && (code != ERR_OS || os == err.os));};
	bool operator!=(int16 errcode) {return (code != errcode);};
	bool operator!=(Err& err) {return (code != err.code || (code == ERR_OS && os != err.os));};
};

#if DEBUG_OS_ERR
#define setOS(x) setOS(x, __FILE__, __LINE__)
#endif

#endif
