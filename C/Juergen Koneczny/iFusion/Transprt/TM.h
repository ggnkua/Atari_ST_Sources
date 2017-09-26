int16 cdecl	IF_TCP_open( uint32 rem_host, uint16 rem_port, uint16 tos, uint16 buffer_size );
int16 cdecl	IF_TCP_close( int16 handle, int16 timeout );
int16 cdecl IF_TCP_send( int16 handle, void *buffer, int16 length );
int16 cdecl IF_TCP_wait_state( int16 handle, int16 state, int16 timeout );
int16 cdecl IF_TCP_ack_wait( int16 handle, int16 timeout );

