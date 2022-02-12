/*
ibm/portio.h

Created:	Jan 15, 1992 by Philip Homburg
*/

#ifndef _PORTIO_H_
#define _PORTIO_H_

#ifndef _ANSI_H
#include <ansi.h>
#endif

_PROTOTYPE( unsigned inb, (U16_t _port)					);
_PROTOTYPE( unsigned inw, (U16_t _port)					);
_PROTOTYPE( unsigned inl, (U32_t _port)					);
_PROTOTYPE( void outb, (U16_t _port, U8_t _value)			);
_PROTOTYPE( void outw, (U16_t _port, U16_t _value)			);
_PROTOTYPE( void outl, (U16_t _port, U32_t _value)			);
_PROTOTYPE( void rep_inb, (U16_t _port, u8_t *_buf, size_t _count)	);
_PROTOTYPE( void rep_inw, (U16_t _port, u16_t *_buf, size_t _count)	);
_PROTOTYPE( void rep_inl, (U16_t _port, u32_t *_buf, size_t _count)	);
_PROTOTYPE( void rep_outb, (U16_t _port, u8_t *_buf, size_t _count)	);
_PROTOTYPE( void rep_outw, (U16_t _port, u16_t *_buf, size_t _count)	);
_PROTOTYPE( void rep_outl, (U16_t _port, u32_t *_buf, size_t _count)	);
_PROTOTYPE( void intr_enable, (void)					);
_PROTOTYPE( void intr_disable, (void)					);

#endif /* _PORTIO_H_ */
