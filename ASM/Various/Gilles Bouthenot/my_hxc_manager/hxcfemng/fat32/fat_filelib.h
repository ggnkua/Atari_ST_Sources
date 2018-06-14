#ifndef __FAT_FILELIB_H__
#define __FAT_FILELIB_H__

#include "fat_opts.h"
#include "fat_access.h"

//-----------------------------------------------------------------------------
// Defines
//-----------------------------------------------------------------------------
#ifndef SEEK_CUR
	#define SEEK_CUR    1
#endif

#ifndef SEEK_END
	#define SEEK_END    2
#endif

#ifndef SEEK_SET
	#define SEEK_SET    0
#endif

#ifndef EOF
	#define EOF			(-1)
#endif

//-----------------------------------------------------------------------------
// Structures
//-----------------------------------------------------------------------------
struct sFL_FILE;

struct cluster_lookup
{
	UINT32 ClusterIdx;
	UINT32 CurrentCluster;
};

typedef struct sFL_FILE
{
	unsigned long			parentcluster;
	unsigned long			startcluster;
	unsigned long			bytenum;
	unsigned long			filelength;
	int						filelength_changed;
	char					path[FATFS_MAX_LONG_FILENAME];
	char					filename[FATFS_MAX_LONG_FILENAME];
	unsigned char			shortfilename[11];

#ifdef FAT_CLUSTER_CACHE_ENTRIES
	unsigned long			cluster_cache_idx[FAT_CLUSTER_CACHE_ENTRIES];
	unsigned long			cluster_cache_data[FAT_CLUSTER_CACHE_ENTRIES];
#endif

	// Cluster Lookup
	struct cluster_lookup	last_fat_lookup;

	// Read/Write sector buffer
	struct sector_buffer	file_data;

	// File fopen flags
	unsigned char			flags;
#define FILE_READ	(1 << 0)
#define FILE_WRITE	(1 << 1)
#define FILE_APPEND	(1 << 2)
#define FILE_BINARY	(1 << 3)
#define FILE_ERASE	(1 << 4)
#define FILE_CREATE	(1 << 5)

	struct sFL_FILE			*next;
} FL_FILE;

//-----------------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------------

// External
void				fl_init(void);
void				fl_attach_locks(struct fatfs *fs, void (*lock)(void), void (*unlock)(void));
int					fl_attach_media(fn_diskio_read rd, fn_diskio_write wr);
void				fl_shutdown(void);

// Standard API
void*				fl_fopen(const char *path, const char *modifiers);
void				fl_fclose(void *file);
int					fl_fflush(void *file);
int					fl_fgetc(void *file);
int					fl_fputc(int c, void *file);
int					fl_fputs(const char * str, void *file);
int					fl_fwrite(const void * data, int size, int count, void *file );
int					fl_fread(void * data, int size, int count, void *file );
int					fl_fseek(void *file , long offset , int origin );
int					fl_fgetpos(void *file , unsigned long * position);
long				fl_ftell(void *f);
int					fl_feof(void *f);
int					fl_remove( const char * filename );

// Extensions
void				fl_listdirectory(const char *path);
int					fl_createdirectory(const char *path);
int					fl_list_opendir(const char *path, struct fs_dir_list_status *dirls);
int					fl_list_readdir(struct fs_dir_list_status *dirls, struct fs_dir_ent *entry);
int					fl_is_dir(const char *path);

int					fl_fswrite(unsigned char * buffer, int size,int start_sector, void *f);

// Test hooks
#ifdef FATFS_INC_TEST_HOOKS
struct fatfs*		fl_get_fs(void);
#endif

//-----------------------------------------------------------------------------
// Stdio file I/O names
//-----------------------------------------------------------------------------
#ifdef USE_FILELIB_STDIO_COMPAT_NAMES

#define FILE			FL_FILE

#define fopen(a,b)		fl_fopen(a, b)
#define fclose(a)		fl_fclose(a)
#define fflush(a)		fl_fflush(a)
#define fgetc(a)		fl_fgetc(a)
#define fputc(a,b)		fl_fputc(a, b)
#define fputs(a,b)		fl_fputs(a, b)
#define fwrite(a,b,c,d)	fl_fwrite(a, b, c, d)
#define fread(a,b,c,d)	fl_fread(a, b, c, d)
#define fseek(a,b,c)	fl_fseek(a, b, c)
#define fgetpos(a,b)	fl_fgetpos(a, b)
#define ftell(a)		fl_ftell(a)
#define feof(a)			fl_feof(a)
#define remove(a)		fl_remove(a)

#endif

#endif
