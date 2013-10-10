/* ------------------------------------------------------------------------
 *		CRC.LIB
 *		Assemblerroutines (68000er) for CRC calculations;
 *
 *		(c) 1994 by Jan Kriesten, D-35039 Marburg, FidoNet: 2:244/4344
 *
 *		The CRC tables are included in the library.
 */

#ifndef __CRC_H__
#define __CRC_H__

/*--- includes              ---*/

/*--- defines               ---*/

/*--- types                 ---*/

/*--- variables             ---*/

/*--- prototypes            ---*/

extern	unsigned int	*Crc16Tab;

unsigned int	Crc16Str	( BYTE *str );
unsigned int	Crc16Blk	( BYTE *blk, ULONG length );
unsigned int	Crc16Upd	( UWORD crc, UBYTE c );

/*
 *  The return values of Crc32Str and Crc32Blk are not
 *  negated!
 */
extern	unsigned long	*Crc32Tab;

unsigned long	Crc32Str	( BYTE *str );
unsigned long	Crc32Blk	( BYTE *blk, ULONG length );
unsigned long	Crc32Upd	( ULONG crc, UBYTE c );

/*--- End of crc.h module  ---*/
#endif

