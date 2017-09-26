int16 cdecl IF_CNkick( int16 handle );
int16 cdecl IF_CNbyte_count( int16 handle );
int16 cdecl IF_CNget_char( int16 handle );
NDB *cdecl	IF_CNget_NDB( int16 handle );
int16 cdecl	IF_CNget_block( int16 handle, void *buffer, int16 length );
CIB *cdecl	IF_CNgetinfo( int16 handle );
int16 cdecl	IF_CNgets( int16 cn, char *buffer, int16 len, char delim );

