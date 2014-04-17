int vst_arbpt( int handle, int point, int *chwd, int *chht, int *cellwd, int *cellht );
int v_savecache( int handle, char *filename );
int v_loadcache( int handle, char *filename, int mode );
int v_flushcache( int handle );
void vqt_cachesize( int handle, int which_cache, long *size );


