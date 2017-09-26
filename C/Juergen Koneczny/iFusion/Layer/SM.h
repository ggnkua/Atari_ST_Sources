void cdecl	IF_set_dgram_ttl( IP_DGRAM *datagram );
int16 cdecl	IF_check_dgram_ttl( IP_DGRAM *datagram );
int32 cdecl	IF_set_sysvars( int16 new_active, int16 new_fraction );
void cdecl	IF_query_chains( void **port, void **drv, void **layer );
int32 cdecl IF_protect_exec( void *para, int32 cdecl ( *code ) (void *));
