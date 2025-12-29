
int qfax_init( void );
int qfax_open( char *file_name );
int qfax_pix( unsigned char *pix, int repeat );
int qfax_text( char *string );
int qfax_close( void );
int qfax_clr( void );

