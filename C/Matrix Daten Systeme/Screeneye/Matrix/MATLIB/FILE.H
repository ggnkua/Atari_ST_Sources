typedef struct
{
	char	*data ;			/* general fields	*/
	size_t	used, size ;
	bool	malloced ;
	
	DOSTIME	time ;			/* file specific fields	*/
} DATAbuffer ;
	
extern void clear_buffer ( DATAbuffer *buffer ) ;
extern void free_buffer ( DATAbuffer *buffer ) ;
extern bool malloc_buffer ( DATAbuffer *buffer, size_t si ) ;

extern int read_buffer  ( const char *filename, DATAbuffer *buffer ) ;
extern int write_buffer ( const char *filename, DATAbuffer *buffer, int wrdatim ) ; 

extern int write_block ( const char *filename, void *data, long length ) ;
extern int write_blocks ( const char *filename, void *data1, long length1,
												void *data2, long length2 ) ;
extern int read_block  ( const char *filename, void *data, long length, long *read  ) ;
extern int read_blocks ( const char *filename, void *data1, long length1,
											   void *data2, long length2,
											   long *read ) ;

extern int  file_copy   ( const char *inname, const char *outname, int wrdatim ) ;
extern int  file_rename ( const char *oldname, const char *newname ) ;
extern int file_delete  ( const char *name ) ;

extern bool FileExists  ( char *filename, bool zero_result ) ;
