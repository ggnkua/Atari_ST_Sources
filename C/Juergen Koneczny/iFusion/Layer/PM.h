int16 cdecl	IF_PRTCL_announce( int16 protocol );
int16 cdecl	IF_PRTCL_get_parameters( uint32 rem_IP, uint32 *lcl_IP, int16 *ttl, uint16 *mtu );
int16 cdecl	IF_PRTCL_request( void *connect, CN_FUNCS *functions );
void cdecl	IF_PRTCL_release( int16 handle );
void *cdecl IF_PRTCL_lookup( int16 handle, CN_FUNCS *functions );
