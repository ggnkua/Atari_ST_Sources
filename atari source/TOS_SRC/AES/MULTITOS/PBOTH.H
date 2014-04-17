/* pboth.h */
#include "portab.h"

WORD	res_handle( WORD in );
WORD	res_type( WORD in );
VOID	catchsignal( WORD ignore );

WORD	rom_ram( WORD which, REG LONG pointer );
WORD	rsc_read( VOID );
