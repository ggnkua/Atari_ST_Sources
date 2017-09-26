int16 cdecl	IF_resolve( char *inp, char **real, uint32 *lst, int16 len );
char *cdecl	IF_get_err_text( int16 error_code );
char *cdecl	IF_getvstr( char *specifier );
int16 cdecl	IF_carrier_detect( void );
void cdecl	IF_housekeep( void );
void cdecl	IF_ser_disable( void );
void cdecl  IF_ser_enable( void );
int16 cdecl IF_set_flag( int16 flag );
void cdecl	IF_clear_flag( int16 flag );
int16 cdecl	IF_on_port( char *port_name );
void cdecl	IF_off_port( char *port_name );
int16	cdecl	IF_setvstr( char *specifier, char *value );
int16 cdecl IF_query_port( char *port_name );

int16	read_config( void );