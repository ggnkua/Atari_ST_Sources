/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef _file_h_
#define _file_h_

#define	MAXLEN_PATH	256
#define	MAXLEN_FILE	64

#ifndef	EINVFN
#define	EINVFN	-32L														/* invalid function number	*/
#endif

#include	"core.h"

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* functions prototypes																							*/
/*----------------------------------------------------------------------------------------*/

CFDataRef	FileASCIILoad( StringPtr path );

uint32	file_size(const uint8 *filename);
uint32	file_date( const uint8 *path );
boolean	file_exist( const uint8 *filename );
boolean	file_isprog( const uint8 *fname );
boolean	file_onfloppy( const uint8 *path );
boolean	file_name( const uint8 *string, uint8 **fname );
uint8		*file_name_ptr( const uint8 *string );

void		catbslash( uint8 *string );
void		delbslash( uint8 *string );

boolean	path_name( const uint8 *string );
boolean	path_exist( const uint8 *pathvar );
int16 	path_browse( const uint8 *filepath, void (*cb)(uint8* path) );
int16		path_resize( uint8 *longstring, int16 max_lenght);

#endif
