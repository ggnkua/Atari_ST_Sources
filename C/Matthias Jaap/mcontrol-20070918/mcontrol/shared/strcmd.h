/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef	_strcmd_h_
#define	_strcmd_h_

#ifndef EOS
#define EOS         '\0'
#endif

#ifndef	__2B_UNIVERSAL_TYPES__
#include	<types2b.h>
#endif

#ifndef	_core_h_
#include	"core.h"
#endif

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

void		tab2space( uint8 *string );
boolean	match_start( uint8 *src, uint8 *cmp );
boolean	strsame( uint8 *src, uint8 *cmp );
boolean	strfind( uint8 *src, uint8 *cmp );
uint8 	*strstri( const uint8 *s, const uint8 *wanted );
boolean	str_insert( uint8 *dest, uint8 *src, uint8 *key, uint8 *ins );
void		str_upper( uint8 *src );
int16		str_delchr( uint8 *str, uint8 chr );
int16		str_clean( const uint8 *string );

uint8		*read_line( uint8 *src, uint8 *dest );
int16		voidchars( uint8 *string );
boolean	get_inside( uint8 beg, uint8 end, uint8 *zeile, uint8 *val );
int16		parse_items( uint8 *zeile, uint8 *data, uint8 *value );

int16		AttrGetString( StringPtr attrs, StringPtr key, StringPtr value );
int16		AttrGetInt16( StringPtr attrs, StringPtr key, int16 *value );
int16		AttrGetInt32( StringPtr attrs, StringPtr key, int32 *value );
int16		AttrGetUint32( StringPtr attrs, StringPtr key, uint32 *value );
int16		AttrGetBoolean( StringPtr attrs, StringPtr key, boolean *value );

int16		read_cfg_bool( uint8 *str, boolean *val );
boolean	get_posval( int16 position, uint8 *string, uint8 *value );
void		get_str( uint8 *str, uint8 *val );
boolean	is_filled( const uint8 *string );
boolean	nowildcard( const uint8 *fname );

boolean	make_vstr( uint8 *string, uint8 *prefix, int16 version, int16 radix );
void		vstringread( StringPtr vstring, uint16 vfield[] );

uint8		*divlist_get( uint8 *dest, uint8 *dlist, uint8 div );
boolean	divlist_add( uint8 *name, uint8 *dlist, uint8 div, boolean cs );
boolean	divlist_del( uint8 *name, uint8 *dlist, uint8 div, boolean cs );
boolean	namelist_add( uint8 *list, uint8 *name );

#endif