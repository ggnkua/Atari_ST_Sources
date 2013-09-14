void Do_Cache_Options( void );
int  CacheButton( int button, WORD *msg );
void Get_Default_Cache( void );


extern long    dcache_size;	/* actual usage of the data and bitmap cache */
extern long    bcache_size;	/* in KBYTES....			     */
