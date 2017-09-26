int16 cdecl	IF_IP_send( uint32 scr_host, uint32 dest_host, uint8 tos, uint16 dont_frag, uint8 ttl, uint8 protocol, uint16 ident, void *data, uint16 data_length, void *options, uint16 options_length );
IP_DGRAM *cdecl	IF_IP_fetch( int16 protocol );
int16 cdecl	IF_IP_handler( int16 protocol, int16 cdecl (* handler) (IP_DGRAM *), int16 install_code );
void cdecl	IF_IP_discard( IP_DGRAM *datagram, int16 all_flag );
