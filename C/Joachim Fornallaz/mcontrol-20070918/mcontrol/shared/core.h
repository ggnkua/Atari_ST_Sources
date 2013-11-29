#ifndef	_core_h_
#define	_core_h_

#ifndef	__2B_UNIVERSAL_TYPES__
#include	<types2b.h>
#endif

typedef	uint8*		StringPtr;

typedef	uint32		CFTypeID;
typedef	uint32		CFOptionFlags;
typedef	uint32		CFHashCode;
typedef	int32			CFIndex;

typedef enum {
	kCFTypeASCII,
	kCFTypeUnicode,
	kCFTypeBinary
} CFDataType;

typedef	struct  __CFData
{
	CFIndex		length;
	CFDataType	type;
	StringPtr	data;
} CFData;

typedef struct __CFData* CFDataRef;

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

CFDataRef	CFDataCreate( CFIndex bytes, CFDataType type );
boolean		CFDataClear( CFDataRef dref );

#endif