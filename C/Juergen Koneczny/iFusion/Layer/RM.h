int16 cdecl	IF_load_routing_table( void );
int16 cdecl	IF_get_route_entry( int16 index, uint32 *subnet, uint32 *submask, void **port, uint32 *gateway );
int16 cdecl	IF_set_route_entry( int16 index, uint32 subnet, uint32 submask, void *port, uint32 gateway );
