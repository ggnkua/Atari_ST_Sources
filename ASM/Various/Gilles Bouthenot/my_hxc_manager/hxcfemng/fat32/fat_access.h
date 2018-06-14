#ifndef __FAT_ACCESS_H__
#define __FAT_ACCESS_H__

#include "fat_defs.h"
#include "fat_opts.h"

//-----------------------------------------------------------------------------
// Defines
//-----------------------------------------------------------------------------
#define FAT_INIT_OK							0
#define FAT_INIT_MEDIA_ACCESS_ERROR			(-1)
#define FAT_INIT_INVALID_SECTOR_SIZE		(-2)
#define FAT_INIT_INVALID_SIGNATURE			(-3)
#define FAT_INIT_ENDIAN_ERROR				(-4)
#define FAT_INIT_WRONG_FILESYS_TYPE			(-5)
#define FAT_INIT_WRONG_PARTITION_TYPE		(-6)

#define FAT_DIR_ENTRIES_PER_SECTOR			(FAT_SECTOR_SIZE / FAT_DIR_ENTRY_SIZE)

//-----------------------------------------------------------------------------
// Function Pointers
//-----------------------------------------------------------------------------
typedef int (*fn_diskio_read) (UINT32 sector, unsigned char *buffer);
typedef int (*fn_diskio_write)(UINT32 sector, unsigned char *buffer);

//-----------------------------------------------------------------------------
// Structures
//-----------------------------------------------------------------------------
struct disk_if
{
	// User supplied function pointers for disk IO
	fn_diskio_read		read_sector;
	fn_diskio_write		write_sector;
};

// Forward declaration
struct sector_buffer;

struct sector_buffer
{
	unsigned char			sector[FAT_SECTOR_SIZE];
	UINT32					address;
	int						dirty;

	// Next in chain of sector buffers
	struct sector_buffer  *next;
};

typedef enum eFatType
{
	FAT_TYPE_16,
	FAT_TYPE_32
} tFatType;

struct fatfs
{
	// Filesystem globals
	unsigned char			sectors_per_cluster;
	UINT32					cluster_begin_lba;
	UINT32					rootdir_first_cluster;
	UINT32					rootdir_first_sector;
	UINT32					rootdir_sectors;
	UINT32					fat_begin_lba;
	UINT16					fs_info_sector;
	UINT32					lba_begin;
	UINT32					fat_sectors;
	UINT32					next_free_cluster;
	UINT16					root_entry_count;
	UINT16					reserved_sectors;
	unsigned char			num_of_fats;
	tFatType				fat_type;

	// Disk/Media API
	struct disk_if			disk_io;

	// [Optional] Thread Safety
	void					(*fl_lock)(void);
	void					(*fl_unlock)(void);

	// Working buffer
	struct sector_buffer	currentsector;

	// FAT Buffer
	struct sector_buffer	*fat_buffer_head;
	struct sector_buffer	fat_buffers[FAT_BUFFERED_SECTORS];
};

struct fs_dir_list_status
{
	UINT32					sector;
	UINT32					cluster;
	unsigned char			offset;
};

struct fs_dir_ent
{
	char					filename[FATFS_MAX_LONG_FILENAME];
	unsigned char			is_dir;
	UINT32					cluster;
	UINT32					size;
};

//-----------------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------------
int		fatfs_init(struct fatfs *fs);
UINT32	fatfs_lba_of_cluster(struct fatfs *fs, UINT32 Cluster_Number);
int		fatfs_sector_reader(struct fatfs *fs, UINT32 Startcluster, UINT32 offset, unsigned char *target);
int		fatfs_sector_read(struct fatfs *fs, UINT32 lba, unsigned char *target);
int		fatfs_sector_write(struct fatfs *fs, UINT32 lba, unsigned char *target);
int		fatfs_read_sector(struct fatfs *fs, UINT32 cluster, UINT32 sector, unsigned char *target);
int		fatfs_write_sector(struct fatfs *fs, UINT32 cluster, UINT32 sector, unsigned char *target);
void	fatfs_show_details(struct fatfs *fs);
UINT32	fatfs_get_root_cluster(struct fatfs *fs);
UINT32	fatfs_get_file_entry(struct fatfs *fs, UINT32 Cluster, char *nametofind, struct fat_dir_entry *sfEntry);
int		fatfs_sfn_exists(struct fatfs *fs, UINT32 Cluster, char *shortname);
int		fatfs_update_file_length(struct fatfs *fs, UINT32 Cluster, char *shortname, UINT32 fileLength);
int		fatfs_mark_file_deleted(struct fatfs *fs, UINT32 Cluster, char *shortname);
void	fatfs_list_directory_start(struct fatfs *fs, struct fs_dir_list_status *dirls, UINT32 StartCluster);
int		fatfs_list_directory_next(struct fatfs *fs, struct fs_dir_list_status *dirls, struct fs_dir_ent *entry);

#endif
