//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//					        FAT16/32 File IO Library
//								    V2.6
// 	  							 Rob Riglar
//						    Copyright 2003 - 2010
//
//   					  Email: rob@robriglar.com
//
//								License: GPL
//   If you would like a version with a more permissive license for use in
//   closed source commercial applications please contact me for details.
//-----------------------------------------------------------------------------
//
// This file is part of FAT File IO Library.
//
// FAT File IO Library is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// FAT File IO Library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with FAT File IO Library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
#include <stdio.h>
#include <string.h>
#include "fat_defs.h"
#include "fat_access.h"
#include "fat_table.h"
#include "fat_write.h"
#include "fat_string.h"
#include "fat_misc.h"
#include "fat_cache.h"

//-----------------------------------------------------------------------------
// fatfs_init: Load FAT Parameters
//-----------------------------------------------------------------------------
int fatfs_init(struct fatfs *fs)
{
	unsigned char   num_of_fats;
	UINT16 reserved_sectors;
	UINT32 FATSz;
	UINT32 root_dir_sectors;
	UINT32 total_sectors;
	UINT32 data_sectors;
	UINT32 count_of_clusters;
	UINT32 partition_size = 0;
	unsigned char   valid_partition = 0;

	fs->currentsector.address = FAT32_INVALID_CLUSTER;
	fs->currentsector.dirty = 0;

	fs->next_free_cluster = 0; // Invalid

	fatfs_fat_init(fs);

	// Make sure we have a read function (write function is optional)
	if (!fs->disk_io.read_sector)
		return FAT_INIT_MEDIA_ACCESS_ERROR;

	// MBR: Sector 0 on the disk
	// NOTE: Some removeable media does not have this.

	// Load MBR (LBA 0) into the 512 byte buffer
	if (!fs->disk_io.read_sector(0, fs->currentsector.sector))
		return FAT_INIT_MEDIA_ACCESS_ERROR;

	// Make Sure 0x55 and 0xAA are at end of sector
	// (this should be the case regardless of the MBR or boot sector)
	if (fs->currentsector.sector[SIGNATURE_POSITION] != 0x55 || fs->currentsector.sector[SIGNATURE_POSITION+1] != 0xAA)
		return FAT_INIT_INVALID_SIGNATURE;

	// Now check again using the access function to prove endian conversion function
	if (GET_16BIT_WORD(fs->currentsector.sector, SIGNATURE_POSITION) != SIGNATURE_VALUE)
		return FAT_INIT_ENDIAN_ERROR;

	// Check the partition type code
	switch(fs->currentsector.sector[PARTITION1_TYPECODE_LOCATION])
	{
		case 0x0B:
		case 0x06:
		case 0x0C:
		case 0x0E:
		case 0x0F:
		case 0x05:
			valid_partition = 1;
		break;
		case 0x00:
			valid_partition = 0;
			break;
		default:
			if (fs->currentsector.sector[PARTITION1_TYPECODE_LOCATION] <= 0x06)
				valid_partition = 1;
		break;
	}

	if (valid_partition)
	{
		// Read LBA Begin for the file system
		fs->lba_begin = GET_32BIT_WORD(fs->currentsector.sector, PARTITION1_LBA_BEGIN_LOCATION);
		partition_size = GET_32BIT_WORD(fs->currentsector.sector, PARTITION1_SIZE_LOCATION);
	}
	// Else possibly MBR less disk
	else
		fs->lba_begin = 0;

	// Load Volume 1 table into sector buffer
	// (We may already have this in the buffer if MBR less drive!)
	if (!fs->disk_io.read_sector(fs->lba_begin, fs->currentsector.sector))
		return FAT_INIT_MEDIA_ACCESS_ERROR;

	// Make sure there are 512 bytes per cluster
	if (GET_16BIT_WORD(fs->currentsector.sector, 0x0B) != FAT_SECTOR_SIZE)
		return FAT_INIT_INVALID_SECTOR_SIZE;

	// Load Parameters of FAT partition
	fs->sectors_per_cluster = fs->currentsector.sector[BPB_SECPERCLUS];
	reserved_sectors = GET_16BIT_WORD(fs->currentsector.sector, BPB_RSVDSECCNT);
	num_of_fats = fs->currentsector.sector[BPB_NUMFATS];
	fs->root_entry_count = GET_16BIT_WORD(fs->currentsector.sector, BPB_ROOTENTCNT);

	if(GET_16BIT_WORD(fs->currentsector.sector, BPB_FATSZ16) != 0)
		fs->fat_sectors = GET_16BIT_WORD(fs->currentsector.sector, BPB_FATSZ16);
	else
		fs->fat_sectors = GET_32BIT_WORD(fs->currentsector.sector, BPB_FAT32_FATSZ32);

	// For FAT32 (which this may be)
	fs->rootdir_first_cluster = GET_32BIT_WORD(fs->currentsector.sector, BPB_FAT32_ROOTCLUS);
	fs->fs_info_sector = GET_16BIT_WORD(fs->currentsector.sector, BPB_FAT32_FSINFO);

	// For FAT16 (which this may be), rootdir_first_cluster is actuall rootdir_first_sector
	fs->rootdir_first_sector = reserved_sectors + (num_of_fats * fs->fat_sectors);
	fs->rootdir_sectors = ((fs->root_entry_count * 32) + (FAT_SECTOR_SIZE - 1)) / FAT_SECTOR_SIZE;

	// First FAT LBA address
	fs->fat_begin_lba = fs->lba_begin + reserved_sectors;

	// The address of the first data cluster on this volume
	fs->cluster_begin_lba = fs->fat_begin_lba + (num_of_fats * fs->fat_sectors);

	if (GET_16BIT_WORD(fs->currentsector.sector, 0x1FE) != 0xAA55) // This signature should be AA55
		return FAT_INIT_INVALID_SIGNATURE;

	// Calculate the root dir sectors
	root_dir_sectors = ((GET_16BIT_WORD(fs->currentsector.sector, BPB_ROOTENTCNT) * 32) + (GET_16BIT_WORD(fs->currentsector.sector, BPB_BYTSPERSEC) - 1)) / GET_16BIT_WORD(fs->currentsector.sector, BPB_BYTSPERSEC);

	if(GET_16BIT_WORD(fs->currentsector.sector, BPB_FATSZ16) != 0)
		FATSz = GET_16BIT_WORD(fs->currentsector.sector, BPB_FATSZ16);
	else
		FATSz = GET_32BIT_WORD(fs->currentsector.sector, BPB_FAT32_FATSZ32);

	if(GET_16BIT_WORD(fs->currentsector.sector, BPB_TOTSEC16) != 0)
		total_sectors = GET_16BIT_WORD(fs->currentsector.sector, BPB_TOTSEC16);
	else
		total_sectors = GET_32BIT_WORD(fs->currentsector.sector, BPB_TOTSEC32);

	data_sectors = total_sectors - (GET_16BIT_WORD(fs->currentsector.sector, BPB_RSVDSECCNT) + (fs->currentsector.sector[BPB_NUMFATS] * FATSz) + root_dir_sectors);

	// Find out which version of FAT this is...
	if (fs->sectors_per_cluster != 0)
	{
		count_of_clusters = data_sectors / fs->sectors_per_cluster;

		if(count_of_clusters < 4085)
			// Volume is FAT12
			return FAT_INIT_WRONG_FILESYS_TYPE;
		else if(count_of_clusters < 65525)
		{
			// Clear this FAT32 specific param
			fs->rootdir_first_cluster = 0;

			// Volume is FAT16
			fs->fat_type = FAT_TYPE_16;
			return FAT_INIT_OK;
		}
		else
		{
			// Volume is FAT32
			fs->fat_type = FAT_TYPE_32;
			return FAT_INIT_OK;
		}
	}
	else
		return FAT_INIT_WRONG_FILESYS_TYPE;
}
//-----------------------------------------------------------------------------
// fatfs_lba_of_cluster: This function converts a cluster number into a sector /
// LBA number.
//-----------------------------------------------------------------------------
UINT32 fatfs_lba_of_cluster(struct fatfs *fs, UINT32 Cluster_Number)
{
	if (fs->fat_type == FAT_TYPE_16)
		return (fs->cluster_begin_lba + (fs->root_entry_count * 32 / FAT_SECTOR_SIZE) + ((Cluster_Number-2) * fs->sectors_per_cluster));
	else
		return ((fs->cluster_begin_lba + ((Cluster_Number-2)*fs->sectors_per_cluster)));
}
//-----------------------------------------------------------------------------
// fatfs_sector_read:
//-----------------------------------------------------------------------------
int fatfs_sector_read(struct fatfs *fs, UINT32 lba, unsigned char *target)
{
	return fs->disk_io.read_sector(lba, target);
}
//-----------------------------------------------------------------------------
// fatfs_sector_write:
//-----------------------------------------------------------------------------
#if (0)
int fatfs_sector_write(struct fatfs *fs, UINT32 lba, unsigned char *target)
{
	return fs->disk_io.write_sector(lba, target);
}
#endif
//-----------------------------------------------------------------------------
// fatfs_sector_reader: From the provided startcluster and sector offset
// Returns True if success, returns False if not (including if read out of range)
//-----------------------------------------------------------------------------
int fatfs_sector_reader(struct fatfs *fs, UINT32 start_cluster, UINT32 offset, unsigned char *target)
{
	UINT32 sector_to_read = 0;
	UINT32 cluster_to_read = 0;
	UINT32 cluster_chain = 0;
	UINT32 i;
	UINT32 lba;

	// FAT16 Root directory
	if (fs->fat_type == FAT_TYPE_16 && start_cluster == 0)
	{
		if (offset < fs->rootdir_sectors)
			lba = fs->lba_begin + fs->rootdir_first_sector + offset;
		else
			return 0;
	}
	// FAT16/32 Other
	else
	{
		// Set start of cluster chain to initial value
		cluster_chain = start_cluster;

		// Find parameters
		cluster_to_read = offset / fs->sectors_per_cluster;
		sector_to_read = offset - (cluster_to_read*fs->sectors_per_cluster);

		// Follow chain to find cluster to read
		for (i=0; i<cluster_to_read; i++)
		{
			// Does the entry exist in the cache?
			if (!fatfs_browse_cache_get_next_cluster(fs, i, &cluster_chain))
			{
				// Scan file linked list to find next entry
                cluster_chain = fatfs_find_next_cluster(fs, cluster_chain);

				// Push entry into cache
				fatfs_browse_cache_set_next_cluster(fs, i, cluster_chain);
            }

		}

		// If end of cluster chain then return false
		if (cluster_chain == FAT32_LAST_CLUSTER)
			return 0;

		// Calculate sector address
		lba = fatfs_lba_of_cluster(fs, cluster_chain)+sector_to_read;
	}

	// User provided target array
	if (target)
		return fs->disk_io.read_sector(lba, target);
	// Else read sector if not already loaded
	else if (lba != fs->currentsector.address)
	{
		fs->currentsector.address = lba;
		return fs->disk_io.read_sector(fs->currentsector.address, fs->currentsector.sector);
	}
	else
		return 1;
}
//-----------------------------------------------------------------------------
// fatfs_read_sector: Read from the provided cluster and sector offset
// Returns True if success, returns False if not
//-----------------------------------------------------------------------------
#if (0)
int fatfs_read_sector(struct fatfs *fs, UINT32 cluster, UINT32 sector, unsigned char *target)
{
	// FAT16 Root directory
	if (fs->fat_type == FAT_TYPE_16 && cluster == 0)
	{
		UINT32 lba;

		// In FAT16, there are a limited amount of sectors in root dir!
		if (sector < fs->rootdir_sectors)
			lba = fs->lba_begin + fs->rootdir_first_sector + sector;
		else
			return 0;

		// User target buffer passed in
		if (target)
		{
			// Read from disk
			return fs->disk_io.read_sector(lba, target);
		}
		else
		{
			// Calculate read address
			fs->currentsector.address = lba;

			// Read from disk
			return fs->disk_io.read_sector(fs->currentsector.address, fs->currentsector.sector);
		}
	}
	// FAT16/32 Other
	else
	{
		// User target buffer passed in
		if (target)
		{
			// Calculate read address
			UINT32 lba = fatfs_lba_of_cluster(fs, cluster) + sector;

			// Read from disk
			return fs->disk_io.read_sector(lba, target);
		}
		else
		{
			// Calculate write address
			fs->currentsector.address = fatfs_lba_of_cluster(fs, cluster)+sector;

			// Read from disk
			return fs->disk_io.read_sector(fs->currentsector.address, fs->currentsector.sector);
		}
	}
}
#endif
//-----------------------------------------------------------------------------
// fatfs_write_sector: Write to the provided cluster and sector offset
// Returns True if success, returns False if not
//-----------------------------------------------------------------------------
//#ifdef FATFS_INC_WRITE_SUPPORT
int fatfs_write_sector(struct fatfs *fs, UINT32 cluster, UINT32 sector, unsigned char *target)
{
	// No write access?
	if (!fs->disk_io.write_sector)
		return 0;

	// FAT16 Root directory
	if (fs->fat_type == FAT_TYPE_16 && cluster == 0)
	{
		UINT32 lba;

		// In FAT16 we cannot extend the root dir!
		if (sector < fs->rootdir_sectors)
			lba = fs->lba_begin + fs->rootdir_first_sector + sector;
		else
			return 0;

		// User target buffer passed in
		if (target)
		{
			// Write to disk
			return fs->disk_io.write_sector(lba, target);
		}
		else
		{
			// Calculate write address
			fs->currentsector.address = lba;

			// Write to disk
			return fs->disk_io.write_sector(fs->currentsector.address, fs->currentsector.sector);
		}
	}
	// FAT16/32 Other
	else
	{
		// User target buffer passed in
		if (target)
		{
			// Calculate write address
			UINT32 lba = fatfs_lba_of_cluster(fs, cluster) + sector;

			// Write to disk
			return fs->disk_io.write_sector(lba, target);
		}
		else
		{
			// Calculate write address
			fs->currentsector.address = fatfs_lba_of_cluster(fs, cluster)+sector;

			// Write to disk
			return fs->disk_io.write_sector(fs->currentsector.address, fs->currentsector.sector);
		}
	}
}
//#endif
//-----------------------------------------------------------------------------
// fatfs_show_details: Show the details about the filesystem
//-----------------------------------------------------------------------------
#if (0)
void fatfs_show_details(struct fatfs *fs)
{
	FAT_PRINTF(("\r\nCurrent Disc FAT details\r\n------------------------\r\nRoot Dir First Cluster = "));
	FAT_PRINTF(("0x%x",fs->rootdir_first_cluster));
	FAT_PRINTF(("\r\nFAT Begin LBA = "));
	FAT_PRINTF(("0x%x",fs->fat_begin_lba));
	FAT_PRINTF(("\r\nCluster Begin LBA = "));
	FAT_PRINTF(("0x%x",fs->cluster_begin_lba));
	FAT_PRINTF(("\r\nSectors Per Cluster = "));
	FAT_PRINTF(("%d",fs->sectors_per_cluster));
	FAT_PRINTF(("\r\n\r\nFormula for conversion from Cluster num to LBA is;"));
	FAT_PRINTF(("\r\nLBA = (cluster_begin_lba + ((Cluster_Number-2)*sectors_per_cluster)))\r\n"));
}
#endif
//-----------------------------------------------------------------------------
// fatfs_get_root_cluster: Get the root dir cluster
//-----------------------------------------------------------------------------

UINT32 fatfs_get_root_cluster(struct fatfs *fs)
{
	// NOTE: On FAT16 this will be 0 which has a special meaning...
	return fs->rootdir_first_cluster;
}
//-------------------------------------------------------------
// fatfs_get_file_entry: Find the file entry for a filename
//-------------------------------------------------------------
UINT32 fatfs_get_file_entry(struct fatfs *fs, UINT32 Cluster, char *name_to_find, struct fat_dir_entry *sfEntry)
{
	unsigned char item=0;
	UINT16 recordoffset = 0;
	unsigned char i=0;
	int x=0;
	char *long_filename = NULL;
	char short_filename[13];
	struct lfn_cache lfn;
	int dotRequired = 0;
	struct fat_dir_entry *directoryEntry;

	fatfs_lfn_cache_init(&lfn, TRUE);

	// Main cluster following loop
	while (TRUE)
	{
		// Read sector
		if (fatfs_sector_reader(fs, Cluster, x++, FALSE)) // If sector read was successfull
		{
			// Analyse Sector
			for (item = 0; item < FAT_DIR_ENTRIES_PER_SECTOR; item++)
			{
				// Create the multiplier for sector access
				recordoffset = FAT_DIR_ENTRY_SIZE * item;

				// Overlay directory entry over buffer
				directoryEntry = (struct fat_dir_entry*)(fs->currentsector.sector+recordoffset);

#if FATFS_INC_LFN_SUPPORT
				// Long File Name Text Found
				if (fatfs_entry_lfn_text(directoryEntry) )
					fatfs_lfn_cache_entry(&lfn, fs->currentsector.sector+recordoffset);

				// If Invalid record found delete any long file name information collated
				else if (fatfs_entry_lfn_invalid(directoryEntry) )
					fatfs_lfn_cache_init(&lfn, FALSE);

				// Normal SFN Entry and Long text exists
				else if (fatfs_entry_lfn_exists(&lfn, directoryEntry) )
				{
					long_filename = fatfs_lfn_cache_get(&lfn);

					// Compare names to see if they match
					if (fatfs_compare_names(long_filename, name_to_find))
					{
						memcpy(sfEntry,directoryEntry,sizeof(struct fat_dir_entry));
						return 1;
					}

		 			fatfs_lfn_cache_init(&lfn, FALSE);
				}
				else
#endif
				// Normal Entry, only 8.3 Text
				if (fatfs_entry_sfn_only(directoryEntry) )
				{
					memset(short_filename, 0, sizeof(short_filename));

					// Copy name to string
					for (i=0; i<8; i++)
						short_filename[i] = directoryEntry->Name[i];

					// Extension
					dotRequired = 0;
					for (i=8; i<11; i++)
					{
						short_filename[i+1] = directoryEntry->Name[i];
						if (directoryEntry->Name[i] != ' ')
							dotRequired = 1;
					}

					// Dot only required if extension present
					if (dotRequired)
					{
						// If not . or .. entry
						if (short_filename[0]!='.')
							short_filename[8] = '.';
						else
							short_filename[8] = ' ';
					}
					else
						short_filename[8] = ' ';

					// Compare names to see if they match
					if (fatfs_compare_names(short_filename, name_to_find))
					{
						memcpy(sfEntry,directoryEntry,sizeof(struct fat_dir_entry));
						return 1;
					}

					fatfs_lfn_cache_init(&lfn, FALSE);
				}
			} // End of if
		}
		else
			break;
	} // End of while loop

	return 0;
}
//-------------------------------------------------------------
// fatfs_sfn_exists: Check if a short filename exists.
// NOTE: shortname is XXXXXXXXYYY not XXXXXXXX.YYY
//-------------------------------------------------------------
#ifdef FATFS_INC_WRITE_SUPPORT
int fatfs_sfn_exists(struct fatfs *fs, UINT32 Cluster, char *shortname)
{
	unsigned char item=0;
	UINT16 recordoffset = 0;
	int x=0;
	struct fat_dir_entry *directoryEntry;

	// Main cluster following loop
	while (TRUE)
	{
		// Read sector
		if (fatfs_sector_reader(fs, Cluster, x++, FALSE)) // If sector read was successfull
		{
			// Analyse Sector
			for (item = 0; item < FAT_DIR_ENTRIES_PER_SECTOR; item++)
			{
				// Create the multiplier for sector access
				recordoffset = FAT_DIR_ENTRY_SIZE * item;

				// Overlay directory entry over buffer
				directoryEntry = (struct fat_dir_entry*)(fs->currentsector.sector+recordoffset);

#if FATFS_INC_LFN_SUPPORT
				// Long File Name Text Found
				if (fatfs_entry_lfn_text(directoryEntry) )
					;

				// If Invalid record found delete any long file name information collated
				else if (fatfs_entry_lfn_invalid(directoryEntry) )
					;
				else
#endif
				// Normal Entry, only 8.3 Text
				if (fatfs_entry_sfn_only(directoryEntry) )
				{
					if (strncmp((const char*)directoryEntry->Name, shortname, 11)==0)
						return 1;
				}
			} // End of if
		}
		else
			break;
	} // End of while loop

	return 0;
}
#endif
//-------------------------------------------------------------
// fatfs_update_file_length: Find a SFN entry and update it
// NOTE: shortname is XXXXXXXXYYY not XXXXXXXX.YYY
//-------------------------------------------------------------
#ifdef FATFS_INC_WRITE_SUPPORT
int fatfs_update_file_length(struct fatfs *fs, UINT32 Cluster, char *shortname, UINT32 fileLength)
{
	unsigned char item=0;
	UINT16 recordoffset = 0;
	int x=0;
	struct fat_dir_entry *directoryEntry;

	// No write access?
	if (!fs->disk_io.write_sector)
		return 0;

	// Main cluster following loop
	while (TRUE)
	{
		// Read sector
		if (fatfs_sector_reader(fs, Cluster, x++, FALSE)) // If sector read was successfull
		{
			// Analyse Sector
			for (item = 0; item < FAT_DIR_ENTRIES_PER_SECTOR; item++)
			{
				// Create the multiplier for sector access
				recordoffset = FAT_DIR_ENTRY_SIZE * item;

				// Overlay directory entry over buffer
				directoryEntry = (struct fat_dir_entry*)(fs->currentsector.sector+recordoffset);

#if FATFS_INC_LFN_SUPPORT
				// Long File Name Text Found
				if (fatfs_entry_lfn_text(directoryEntry) )
					;

				// If Invalid record found delete any long file name information collated
				else if (fatfs_entry_lfn_invalid(directoryEntry) )
					;

				// Normal Entry, only 8.3 Text
				else
#endif
				if (fatfs_entry_sfn_only(directoryEntry) )
				{
					if (strncmp((const char*)directoryEntry->Name, shortname, 11)==0)
					{
						directoryEntry->FileSize = fileLength;
						// TODO: Update last write time

						// Update sfn entry
						memcpy((unsigned char*)(fs->currentsector.sector+recordoffset), (unsigned char*)directoryEntry, sizeof(struct fat_dir_entry));

						// Write sector back
						return fs->disk_io.write_sector(fs->currentsector.address, fs->currentsector.sector);
					}
				}
			} // End of if
		}
		else
			break;
	} // End of while loop

	return 0;
}
#endif
//-------------------------------------------------------------
// fatfs_mark_file_deleted: Find a SFN entry and mark if as deleted
// NOTE: shortname is XXXXXXXXYYY not XXXXXXXX.YYY
//-------------------------------------------------------------
#ifdef FATFS_INC_WRITE_SUPPORT
int fatfs_mark_file_deleted(struct fatfs *fs, UINT32 Cluster, char *shortname)
{
	unsigned char item=0;
	UINT16 recordoffset = 0;
	int x=0;
	struct fat_dir_entry *directoryEntry;

	// No write access?
	if (!fs->disk_io.write_sector)
		return 0;

	// Main cluster following loop
	while (TRUE)
	{
		// Read sector
		if (fatfs_sector_reader(fs, Cluster, x++, FALSE)) // If sector read was successfull
		{
			// Analyse Sector
			for (item = 0; item < FAT_DIR_ENTRIES_PER_SECTOR; item++)
			{
				// Create the multiplier for sector access
				recordoffset = FAT_DIR_ENTRY_SIZE * item;

				// Overlay directory entry over buffer
				directoryEntry = (struct fat_dir_entry*)(fs->currentsector.sector+recordoffset);

#if FATFS_INC_LFN_SUPPORT
				// Long File Name Text Found
				if (fatfs_entry_lfn_text(directoryEntry) )
					;

				// If Invalid record found delete any long file name information collated
				else if (fatfs_entry_lfn_invalid(directoryEntry) )
					;

				// Normal Entry, only 8.3 Text
				else
#endif
				if (fatfs_entry_sfn_only(directoryEntry) )
				{
					if (strncmp((const char *)directoryEntry->Name, shortname, 11)==0)
					{
						// Mark as deleted
						directoryEntry->Name[0] = FILE_HEADER_DELETED;

						// Update sfn entry
						memcpy((unsigned char*)(fs->currentsector.sector+recordoffset), (unsigned char*)directoryEntry, sizeof(struct fat_dir_entry));

						// Write sector back
						return fs->disk_io.write_sector(fs->currentsector.address, fs->currentsector.sector);
					}
				}
			} // End of if
		}
		else
			break;
	} // End of while loop

	return 0;
}
#endif
//-----------------------------------------------------------------------------
// fatfs_list_directory_start: Initialise a directory listing procedure
//-----------------------------------------------------------------------------
#if FATFS_DIR_LIST_SUPPORT
void fatfs_list_directory_start(struct fatfs *fs, struct fs_dir_list_status *dirls, UINT32 StartCluster)
{
	dirls->cluster = StartCluster;
	dirls->sector = 0;
	dirls->offset = 0;
}
#endif
//-----------------------------------------------------------------------------
// fatfs_list_directory_next: Get the next entry in the directory.
// Returns: 1 = found, 0 = end of listing
//-----------------------------------------------------------------------------
#if FATFS_DIR_LIST_SUPPORT
int fatfs_list_directory_next(struct fatfs *fs, struct fs_dir_list_status *dirls, struct fs_dir_ent *entry)
{
	unsigned char i,item;
	UINT16 recordoffset;
	unsigned char LFNIndex=0;
	UINT32 x=0;
	struct fat_dir_entry *directoryEntry;
	char *long_filename = NULL;
	char short_filename[13];
	struct lfn_cache lfn;
	int dotRequired = 0;
	int result = 0;

	// Initialise LFN cache first
	fatfs_lfn_cache_init(&lfn, FALSE);

	while (TRUE)
	{
		// If data read OK
		if (fatfs_sector_reader(fs, dirls->cluster, dirls->sector, FALSE))
		{
			LFNIndex=0;

			// Maximum of 16 directory entries
			for (item = dirls->offset; item < FAT_DIR_ENTRIES_PER_SECTOR; item++)
			{
				// Increase directory offset
				recordoffset = FAT_DIR_ENTRY_SIZE * item;

				// Overlay directory entry over buffer
				directoryEntry = (struct fat_dir_entry*)(fs->currentsector.sector+recordoffset);

#if FATFS_INC_LFN_SUPPORT
				// Long File Name Text Found
				if ( fatfs_entry_lfn_text(directoryEntry) )
					fatfs_lfn_cache_entry(&lfn, fs->currentsector.sector+recordoffset);

				else if(directoryEntry->Name[0]==FILE_HEADER_BLANK)
                   			return 0;

				// If Invalid record found delete any long file name information collated
				else if ( fatfs_entry_lfn_invalid(directoryEntry) )
					fatfs_lfn_cache_init(&lfn, FALSE);

				// Normal SFN Entry and Long text exists
				else if (fatfs_entry_lfn_exists(&lfn, directoryEntry) )
				{
					// Get text
					long_filename = fatfs_lfn_cache_get(&lfn);
					strncpy(entry->filename, long_filename, FATFS_MAX_LONG_FILENAME-1);

		 			if (fatfs_entry_is_dir(directoryEntry))
						entry->is_dir = 1;
					else
						entry->is_dir = 0;

					entry->size = ENDIAN_32BIT(directoryEntry->FileSize);
					entry->cluster = (((unsigned long)ENDIAN_16BIT(directoryEntry->FstClusHI))<<16) | ENDIAN_16BIT(directoryEntry->FstClusLO);

					// Next starting position
					dirls->offset = item + 1;
					result = 1;
		 			return 1;
				}
				// Normal Entry, only 8.3 Text
				else
#endif
				if ( fatfs_entry_sfn_only(directoryEntry) )
				{
       				fatfs_lfn_cache_init(&lfn, FALSE);

					memset(short_filename, 0, sizeof(short_filename));

					// Copy name to string
					for (i=0; i<8; i++)
						short_filename[i] = directoryEntry->Name[i];

					// Extension
					dotRequired = 0;
					for (i=8; i<11; i++)
					{
						short_filename[i+1] = directoryEntry->Name[i];
						if (directoryEntry->Name[i] != ' ')
							dotRequired = 1;
					}

					// Dot only required if extension present
					if (dotRequired)
					{
						// If not . or .. entry
						if (short_filename[0]!='.')
							short_filename[8] = '.';
						else
							short_filename[8] = ' ';
					}
					else
						short_filename[8] = ' ';

					strncpy(entry->filename, short_filename, FATFS_MAX_LONG_FILENAME-1);

		 			if (fatfs_entry_is_dir(directoryEntry))
						entry->is_dir = 1;
					else
						entry->is_dir = 0;

					entry->size = ENDIAN_32BIT(directoryEntry->FileSize);
                    entry->cluster = (((unsigned long)ENDIAN_16BIT(directoryEntry->FstClusHI))<<16) | ENDIAN_16BIT(directoryEntry->FstClusLO);
					// Next starting position
					dirls->offset = item + 1;
					result = 1;
					return 1;
				}
			}// end of for

			// If reached end of the dir move onto next sector
			dirls->sector++;
			dirls->offset = 0;
		}
		else
			break;
	}

	return result;
}
#endif


