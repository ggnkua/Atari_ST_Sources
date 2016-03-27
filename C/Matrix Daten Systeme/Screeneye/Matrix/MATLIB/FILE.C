#include <stddef.h>
#include <stdlib.h>
#include <tos.h>

# include <global.h>
# include <error.h>

# include "file.h"


/*------------------------------------------------- FileExists -----*/
bool FileExists ( char *filename, bool zero_result ) 
{
	int fhandle ;
	
	if ( *filename == 0 )
		return zero_result ;
	fhandle = (int)Fopen ( filename, 0 ) ;
	if ( fhandle < 0 ) 
		return FALSE ;
	else
	{
		Fclose ( fhandle ) ;
		return TRUE ;
	}
}
	

/*------------------------------------------------- clear_buffer ---*/
void clear_buffer ( DATAbuffer *buffer )
{
	buffer->used = 0 ;
	buffer->size = 0 ;
	buffer->data = NULL ;
	buffer->malloced = FALSE ;
}

/*------------------------------------------------- free_buffer -----*/
void free_buffer ( DATAbuffer *buffer )
{
	if ( buffer == NULL )
		return ;
	
	if ( buffer->malloced && buffer->data != NULL )
		free ( buffer->data ) ;

	clear_buffer ( buffer ) ;
}

/*------------------------------------------------- malloc_buffer -----*/
bool malloc_buffer ( DATAbuffer *buffer, size_t si )
{
	if ( si > 0 )
	{
		buffer->used = 0 ;
		buffer->size = si ;
		buffer->data  = malloc ( buffer->size ) ;
		buffer->malloced = buffer->data != NULL ;
		if ( buffer->malloced )
			return ( TRUE ) ;
	}
	clear_buffer ( buffer ) ;
	return ( FALSE ) ;
}


/*------------------------------------------------- assign_buffer -----*/
void assign_buffer ( DATAbuffer *buffer, char *str, size_t siz )
{
	buffer->data  = str ;
	buffer->used = siz ;
	buffer->size = siz ;
	buffer->malloced = FALSE ;
}


/*--------------------------------------------------- read_buffer -----*/
int read_buffer ( const char *filename, DATAbuffer *buffer )
{
	int		handle, result ;
	size_t  filesize, readsize ;
	
	handle = (int)Fopen ( filename, 0 ) ;
	if ( handle > 0 ) 
	{
		filesize = Fseek ( 0, handle, 2 ) ;
		if ( malloc_buffer ( buffer, filesize ) )
		{
			Fseek ( 0, handle, 0 ) ;
			readsize = Fread ( handle, filesize, buffer->data ) ;
			if ( readsize == filesize ) 
			{
				buffer->used = filesize ;
				Fdatime( &buffer->time, handle, 0 ) ;
				result = OK ;
			}
			else
			{
				result = READerror ;
				free_buffer ( buffer ) ;
			}
		}
		else
			result = NOmemory ;
		Fclose ( handle ) ;
	}
	else
	{
		result = FILEopenError ;
	}
	return ( result ) ;
}

/*--------------------------------------------------- write_buffer -----*/
int write_buffer ( const char *filename, DATAbuffer *buffer, int wrdatim ) 
{
	int	 handle, result ;
	
	handle = (int)Fcreate ( filename, 0 ) ;
	if ( handle > 0 ) 
	{
		if ( Fwrite ( handle, buffer->size, buffer->data ) == buffer->size )
		{
			if ( wrdatim )
				Fdatime( &buffer->time, handle, 1 ) ;
			result = OK ;
		}
		else
		{
			result = FILEwriteError ;
		}
		Fclose ( handle ) ;
	}
	else
	{
		result = FILEopenError ;
	}
    return ( result ) ;
}

/*--------------------------------------------------- read_blocks -----*/
int read_blocks ( const char *filename, void *data1, long length1,
										void *data2, long length2,
										long *read )
{
	int	 handle, result ;
	long read2 ;
	
	*read = 0 ;
	handle = (int)Fopen ( filename, 0 ) ;
	if ( handle > 0 ) 
	{
		if ( ( *read = Fread ( handle, length1, data1 ) ) == length1 
 		  && ( read2 = Fread ( handle, length2, data2 ) ) == length2 ) 
		{
			*read += read2 ;
			result = OK ;
		}
		else
			result = READerror ;
		Fclose ( handle ) ;
	}
	else
	{
		result = FILEopenError ;
	}
	return ( result ) ;
}

/*--------------------------------------------------- read_block -----*/
int read_block ( const char *filename, void *data, long length, long *read )
{
	int		handle, result ;
	
	handle = (int)Fopen ( filename, 0 ) ;
	if ( handle > 0 ) 
	{
		if ( ( *read = Fread ( handle, length, data ) ) == length ) 
			result = OK ;
		else
			result = READerror ;
		Fclose ( handle ) ;
	}
	else
	{
		*read = 0 ;
		result = FILEopenError ;
	}
	return ( result ) ;
}


/*--------------------------------------------------- write_block -----*/
int write_blocks ( const char *filename, void *data1, long length1,
										 void *data2, long length2 )
{
	int	 handle, result ;
	
	handle = (int)Fcreate ( filename, 0 ) ;
	if ( handle > 0 ) 
	{
		if (  Fwrite ( handle, length1, data1 ) == length1
		   && Fwrite ( handle, length2, data2 ) == length2 )
				result = OK ;
		else
			result = FILEwriteError ;
		Fclose ( handle ) ;
	}
	else
		result = FILEopenError ;
	return ( result ) ;
}

/*--------------------------------------------------- write_block -----*/
int write_block ( const char *filename, void *data, long length )
{
	int	 handle, result ;
	
	handle = (int)Fcreate ( filename, 0 ) ;
	if ( handle > 0 ) 
	{
		if ( Fwrite ( handle, length, data ) == length )
			result = OK ;
		else
			result = FILEwriteError ;
		Fclose ( handle ) ;
	}
	else
		result = FILEopenError ;
	return ( result ) ;
}


# if 0
/*--------------------------------------------- buffers_different ------*/
bool buffers_different ( char *buf1, size_t size1, 
					     char *buf2, size_t size2 ) 
{
	if ( size1 != size2 ) 
		return ( TRUE ) ;
	else
		while ( size1-- > 0 ) 
			if ( tolower ( *buf1++ ) != tolower ( *buf2++ ) ) 
				return ( TRUE ) ;
	return ( FALSE ) ;
}
# endif

/*------------------------------------------------ file_copy -------*/
int file_copy ( const char *inname, const char *outname, int wrdatim ) 
{
	DATAbuffer file_buffer ;
	int	 result ;
		
	clear_buffer ( &file_buffer ) ;

	result = read_buffer ( inname, &file_buffer ) ;
	if ( result == OK )
		result = write_buffer ( outname, &file_buffer, wrdatim ) ; 
	free_buffer ( &file_buffer ) ;

	return result ;
}
	

/*------------------------------------------------ file_rename -------*/
int file_rename ( const char *oldname, const char *newname ) 
{
	return Frename ( 0, oldname, newname ) == 0 ? OK : CANTrename ;
}

/*------------------------------------------------ file_delete -------*/
int file_delete ( const char *name ) 
{
	return Fdelete ( name ) == 0 ? OK : CANTdeleteFile ;
}
