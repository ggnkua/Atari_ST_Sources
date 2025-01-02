
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <ldg.h>

#include "dosfs.h"

/* version, info */

const char* CDECL get_version() { return "1.03"; }
const char* CDECL get_info() { return "[1][jacknifed dosfs to access floppy disk images.][ Ok ]"; }

/*  attach and detach volume image from library */

uint8_t *disk_image_buffer;
uint32_t disk_image_len;

long CDECL host_attach(uint8_t *buffer, uint32_t len)
{
	if (buffer == NULL) { return (int32_t)DFS_HOSTMISSING; }
	if (len == 0) { return (int32_t)DFS_HOSTMISSING; }
	
	disk_image_buffer = buffer;
	disk_image_len = len;
	
	return (int32_t)0;
}
long CDECL host_detach()
{
	disk_image_buffer = NULL;
	disk_image_len = 0;
	
	return 0;
}

/* structures sizes (for the caller to Malloc()) */

unsigned int CDECL get_sizeof_volinfo_struct() { return (uint16_t)sizeof(VOLINFO); }
unsigned int CDECL get_sizeof_dirinfo_struct() { return (uint16_t)sizeof(DIRINFO); }
unsigned int CDECL get_sizeof_dirent_struct() { return (uint16_t)sizeof(DIRENT); }
unsigned int CDECL get_sizeof_fileinfo_struct() { return (uint16_t)sizeof(FILEINFO); }
unsigned int CDECL get_sizeof_scratch_sector() { return (uint16_t)SECTOR_SIZE; }

/* implementations for read/write sector for dosfs */

long host_read_sector(uint8_t *buffer, uint32_t sector)
{
	if ((uint32_t)(sector * SECTOR_SIZE) >= disk_image_len) { return (int32_t)0xfffffffd; }
	memcpy(buffer, disk_image_buffer + (sector * SECTOR_SIZE), SECTOR_SIZE);
	return 0;
}
uint32_t DFS_ReadSector(uint8_t unit, uint8_t *buffer, uint32_t sector, uint32_t count)
{
	return host_read_sector(buffer, sector);
}

long host_write_sector(uint8_t *buffer, uint32_t sector)
{
	if ((uint32_t)(sector * SECTOR_SIZE) >= disk_image_len) { return (int32_t)0xfffffffd; }
	memcpy(disk_image_buffer + (sector * SECTOR_SIZE), buffer, SECTOR_SIZE);
	return 0;
}
uint32_t DFS_WriteSector(uint8_t unit, uint8_t *buffer, uint32_t sector, uint32_t count)
{
	return host_write_sector(buffer, sector);
}

/* volume functions */

long CDECL dfs_get_vol_info(PVOLINFO volinfo, uint8_t *scratch_sector)
{
	if (disk_image_len == 0) { return (int32_t)DFS_HOSTMISSING; }
		
	return (int32_t)DFS_GetVolInfo((uint8_t)0, scratch_sector, 0, volinfo);
}
long CDECL dfs_get_vol_name(PVOLINFO volinfo, char *name, uint8_t *scratch_sector)
{
	if (disk_image_len == 0) { return (int32_t)DFS_HOSTMISSING; }

	return (int32_t)DFS_volumeName(volinfo, (uint8_t *)name, DFS_READ, scratch_sector);
}
long CDECL dfs_set_vol_name(PVOLINFO volinfo, char *name, uint8_t *scratch_sector)
{
	if (disk_image_len == 0) { return (int32_t)DFS_HOSTMISSING; }

	return (int32_t)DFS_volumeName(volinfo, (uint8_t *)name, DFS_WRITE, scratch_sector);
}

/* directory functions */

long CDECL dfs_open_dir(PVOLINFO volinfo, char *dirname, PDIRINFO dirinfo, uint8_t *scratch_sector)
{
	if (disk_image_len == 0) { return (int32_t)DFS_HOSTMISSING; }
	
	dirinfo->scratch = scratch_sector;
	
	return (int32_t)DFS_OpenDir(volinfo, (uint8_t *)dirname, dirinfo, 0);
}
long CDECL dfs_get_next(PVOLINFO volinfo, PDIRINFO dirinfo, PDIRENT dirent)
{
	if (disk_image_len == 0) { return (int32_t)DFS_HOSTMISSING; }
	
	return (int32_t)DFS_GetNext(volinfo, dirinfo, dirent);
}

/*  files functions */

long CDECL dfs_open_file(PVOLINFO volinfo, char *path, uint32_t mode, PFILEINFO fileinfo, uint32_t filedatetime, uint8_t *scratch_sector)
{
	if (disk_image_len == 0) { return (int32_t)DFS_HOSTMISSING; }
	
	return (int32_t)DFS_OpenFile(volinfo, (uint8_t *)path, (uint8_t)mode, scratch_sector, fileinfo, filedatetime);
}
long CDECL dfs_read_file(PFILEINFO fileinfo, uint8_t *buffer, uint32_t len, uint8_t *scratch_sector)
{
	uint32_t successcount;

	uint32_t ret = DFS_ReadFile(fileinfo, scratch_sector, buffer, &successcount, len);
	
	if ((ret == DFS_OK) || (ret == DFS_EOF))  { return successcount; }
	
	return -ret;
}
long CDECL dfs_write_file(PFILEINFO fileinfo, uint8_t *buffer, uint32_t len, uint8_t *scratch_sector)
{
	uint32_t successcount;

	uint32_t ret = DFS_WriteFile(fileinfo, scratch_sector, buffer, &successcount, len);

	if ((ret == DFS_OK) || (ret == DFS_EOF))  { return successcount; }
	
	return -ret;
}
long CDECL dfs_unlink_file(PVOLINFO volinfo, char *path, uint8_t *scratch_sector)
{
	if (disk_image_len == 0) { return (int32_t)DFS_HOSTMISSING; }

	return (int32_t)DFS_UnlinkFile(volinfo, (uint8_t *)path, scratch_sector);
}
long CDECL dfs_rename_file(PVOLINFO volinfo, char *path, char *newname, uint8_t *scratch_sector)
{
	if (disk_image_len == 0) { return (int32_t)DFS_HOSTMISSING; }

	return (int32_t)DFS_RenameFile(volinfo, (uint8_t *)path, (uint8_t *)newname, scratch_sector);
}

/* populate functions list and info for the LDG */

PROC LibFunc[] = { 
  {"get_version", "char* get_version(void);\n", get_version},
  {"get_info", "char* get_info(void);\n", get_info},

  {"host_attach", "long dfs_host_attach(uint8_t *buffer, uint32_t len);\n", host_attach},
  {"host_detach", "long dfs_host_detach();\n", host_detach},

  {"get_sizeof_volinfo_struct", "long get_sizeof_volinfo_struct(void);\n", get_sizeof_volinfo_struct},
  {"get_sizeof_dirinfo_struct", "long get_sizeof_dirinfo_struct(void);\n", get_sizeof_dirinfo_struct},
  {"get_sizeof_dirent_struct", "long get_sizeof_dirent_struct(void);\n", get_sizeof_dirent_struct},
  {"get_sizeof_fileinfo_struct", "long get_sizeof_fileinfo_struct(void);\n", get_sizeof_fileinfo_struct},
  {"get_sizeof_scratch_sector", "long get_sizeof_scratch_sector(void);\n", get_sizeof_scratch_sector},
	
  {"dfs_get_vol_info", "long dfs_get_vol_info(PVOLINFO volinfo, uint8_t *scratch_sector);\n", dfs_get_vol_info},
  {"dfs_get_vol_name", "long dfs_get_vol_name(PVOLINFO volinfo, uint8_t *name, uint8_t *scratch_sector);\n", dfs_get_vol_name},
  {"dfs_set_vol_name", "long dfs_set_vol_name(PVOLINFO volinfo, uint8_t *name, uint8_t *scratch_sector);\n", dfs_set_vol_name},

  {"dfs_open_dir", "long dfs_open_dir(PVOLINFO volinfo, char *dirname, PDIRINFO dirinfo, uint8_t *scratch_sector);\n", dfs_open_dir},
  {"dfs_get_next", "long dfs_get_next(PVOLINFO volinfo, PDIRINFO dirinfo, PDIRENT dirent);\n", dfs_get_next},

  {"dfs_open_file", "long dfs_open_file(PVOLINFO volinfo, char *path, uint16_t mode, PFILEINFO fileinfo, uint32_t filedatetime, uint8_t *scratch_sector);\n", dfs_open_file},
  {"dfs_read_file", "long dfs_read_file(PFILEINFO fileinfo, uint8_t *buffer, uint32_t len, uint8_t *scratch_sector);\n", dfs_read_file},
  {"dfs_write_file", "long dfs_write_file(PFILEINFO fileinfo, uint8_t *buffer, uint32_t len, uint8_t *scratch_sector);\n", dfs_write_file},
  {"dfs_unlink_file", "long dfs_unlink_file(PVOLINFO volinfo, char *path, uint8_t *scratch_sector);\n", dfs_unlink_file},
  {"dfs_rename_file", "long dfs_unlink_file(PVOLINFO volinfo, char *path, char *newname, uint8_t *scratch_sector);\n", dfs_rename_file},
	};

LDGLIB LibLdg[] = { { 0x0002,	19, LibFunc, "jacknifed dosfs to access floppy disk images.", 1} };

/*  */

int main(void) {
	ldg_init(LibLdg);
	return 0;
	}
