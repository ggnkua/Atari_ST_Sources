/*
	DOSFS Embedded FAT-Compatible Filesystem
	(C) 2005 Lewin A.R.W. Edwards (sysadm@zws.com)

	You are permitted to modify and/or use this code in your own projects without
	payment of royalty, regardless of the license(s) you choose for those projects.

	You cannot re-copyright or restrict use of the code as released by Lewin Edwards.
*/

#include <string.h>
#include <stdlib.h>

#include "dosfs.h"


/*
	Retrieve volume info from BPB and store it in a VOLINFO structure
	You must provide the unit and starting sector of the filesystem, and
	a pointer to a sector buffer for scratch
	Attempts to read BPB and glean information about the FS from that.
	Returns 0 OK, nonzero for any error.
	
	Code from: Jacknife wcx Total Commander module / author: ggn
*/
uint32_t DFS_GetVolInfo(uint8_t unit, uint8_t *scratchsector, uint32_t startsector, PVOLINFO volinfo)
{
	PLBR lbr = (PLBR) scratchsector;
	volinfo->unit = unit;
	volinfo->startsector = startsector;

	if (DFS_ReadSector(unit, scratchsector, startsector, 1)) { return DFS_ERRMISC; }

	// NOTE: a lot of these sanity check values are lifted from FastCopy Pro, so they should be reasonable

	volinfo->secperclus = lbr->secperclus;
	if ((volinfo->secperclus != 1) && (volinfo->secperclus != 2) && (volinfo->secperclus != 4) && (volinfo->secperclus != 8)) { return DFS_ERRMISC*2; }

	uint16_t bytes_per_sector = (lbr->bytepersec_h << 8) | lbr->bytepersec_l;
	if ((bytes_per_sector != 128) && (bytes_per_sector != 256) && (bytes_per_sector != 512) && (bytes_per_sector != 1024)) { return -bytes_per_sector; }

	volinfo->numsecs = (lbr->sectors_s_h << 8) | (lbr->sectors_s_l);
  
  if (lbr->secpertrk_l < 1 || lbr->secpertrk_l > 21) { return DFS_ERRMISC*4; } // caters for HD floppy drives

	// GEMDOS seems to ignore the high byte, so let's not use it as well (for example: ADITalk v2.3.msa)
	volinfo->reservedsecs = /* (lbr->reserved_h << 8) | */(lbr->reserved_l);
	if (volinfo->reservedsecs > volinfo->numsecs) { return DFS_ERRMISC*5; }

	volinfo->secperfat = (lbr->secperfat_h << 8) | (lbr->secperfat_l);
	if (volinfo->secperfat > 16) { return DFS_ERRMISC*6; } // random guess

	volinfo->label[0] = 0; // For GEMDOS FAT12 this is a file on the root directory

	// note: if rootentries is 0, we must be in a FAT16/32 volume.
	volinfo->rootentries = (lbr->rootentries_h << 8) | (lbr->rootentries_l);

	if (volinfo->rootentries > 240 || volinfo->rootentries < 16 /* || volinfo->rootentries % 16 != 0*/) { return DFS_ERRMISC*7; }
	if (volinfo->rootentries % 16)
	{
		// Some creative disk formatters could actually set this to anything, not just a multiple of 16
		// (or people just used hex editors for teh lulz). We should quantise the value though because the
		// calculations below that depend on this will point to trash
		volinfo->rootentries = (volinfo->rootentries) & 0xfff0;
	}
		
	// after extracting raw info we perform some useful precalculations
	volinfo->fat1 = startsector + volinfo->reservedsecs * (bytes_per_sector / 512);
	if (!volinfo->fat1) { volinfo->fat1 = 1; } // ggn: GEMDOS FAT12 specific

	uint16_t sides = (lbr->heads_h << 8) | lbr->heads_l;
	uint16_t bpb_sectors_per_track = (lbr->secpertrk_h << 8) | lbr->secpertrk_l;

	/*int disk_image_sectors = (int)disk_image.file_size / SECTOR_SIZE;
	int bpb_total_sectors = volinfo->numsecs + volinfo->reservedsecs + 2 * volinfo->secperfat + volinfo->rootentries / 16;
	
	if ((sides == 1 && disk_image.image_sides == 2) || (bpb_sectors_per_track != disk_image.image_sectors))
	{
		// In general, there are cases where the disk has been imaged without taking the BPB under consideration.
		// So the disk would be imaged with different values (for example 82 instead of 80 tracks, 10 instead of
		// 9 sectors... you name it). So if we detect this, we have to recalculate the sector offsets. This is done
		// in recalculate_sector(), but it needs to know the imaged disk geometry, as well as the BPB disk geometry.
		// So we need to fill in as much info as we can here, and the rest is done during disk image read.
		// For MSA images it's easy, for .ST images we just have to do our best to guess the disk geometry from file size.
		
		disk_image.disk_geometry_does_not_match_bpb = TRUE;
		disk_image.bpb_sectors_per_track = bpb_sectors_per_track;
		disk_image.bpb_sides = sides;
	}*/

	volinfo->rootdir = volinfo->fat1 + (volinfo->secperfat * 2);
	volinfo->dataarea = volinfo->rootdir + (((volinfo->rootentries * 32) + (SECTOR_SIZE - 1)) / SECTOR_SIZE);

	// Calculate number of clusters in data area and infer FAT type from this information.
	// ggn: the commented formula seems to be wrong
	// volinfo->numclusters = (volinfo->numsecs - volinfo->dataarea) / volinfo->secperclus;
	volinfo->numclusters = (volinfo->startsector + volinfo->numsecs - volinfo->dataarea) / volinfo->secperclus;

	if (volinfo->numclusters < 4085)
		volinfo->filesystem = FAT12;
	else if (volinfo->numclusters < 65525)
		volinfo->filesystem = FAT16;
	else
		volinfo->filesystem = FAT32;

	return DFS_OK;
}

/*
	Fetch FAT entry for specified cluster number
	You must provide a scratch buffer for one sector (SECTOR_SIZE) and a populated VOLINFO
	Returns a FAT32 BAD_CLUSTER value for any error, otherwise the contents of the desired
	FAT entry.
	scratchcache should point to a UINT32. This variable caches the physical sector number
	last read into the scratch buffer for performance enhancement reasons.
*/
uint32_t DFS_GetFAT(PVOLINFO volinfo, uint8_t *scratch, uint32_t *scratchcache, uint32_t cluster)
{
	uint32_t offset, sector, result;

	if (volinfo->filesystem == FAT12) {
		offset = cluster + (cluster / 2);
	}
	else if (volinfo->filesystem == FAT16) {
		offset = cluster * 2;
	}
	else if (volinfo->filesystem == FAT32) {
		offset = cluster * 4;
	}
	else
		return 0x0ffffff7;	// FAT32 bad cluster	

	// at this point, offset is the BYTE offset of the desired sector from the start
	// of the FAT. Calculate the physical sector containing this FAT entry.
	sector = ldiv(offset, SECTOR_SIZE).quot + volinfo->fat1;

	// If this is not the same sector we last read, then read it into RAM
	if (sector != *scratchcache) {
		if(DFS_ReadSector(volinfo->unit, scratch, sector, 1)) {
			// avoid anyone assuming that this cache value is still valid, which
			// might cause disk corruption
			*scratchcache = 0;
			return 0x0ffffff7;	// FAT32 bad cluster	
		}
		*scratchcache = sector;
	}

	// At this point, we "merely" need to extract the relevant entry.
	// This is easy for FAT16 and FAT32, but a royal PITA for FAT12 as a single entry
	// may span a sector boundary. The normal way around this is always to read two
	// FAT sectors, but that luxury is (by design intent) unavailable to DOSFS.
	offset = ldiv(offset, SECTOR_SIZE).rem;

	if (volinfo->filesystem == FAT12) {
		// Special case for sector boundary - Store last byte of current sector.
		// Then read in the next sector and put the first byte of that sector into
		// the high byte of result.
		if (offset == SECTOR_SIZE - 1) {
			result = (uint32_t) scratch[offset];
			sector++;
			if(DFS_ReadSector(volinfo->unit, scratch, sector, 1)) {
				// avoid anyone assuming that this cache value is still valid, which
				// might cause disk corruption
				*scratchcache = 0;
				return 0x0ffffff7;	// FAT32 bad cluster	
			}
			*scratchcache = sector;
			// Thanks to Claudio Leonel for pointing out this missing line.
			result |= ((uint32_t) scratch[0]) << 8;
		}
		else {
			result = (uint32_t) scratch[offset] |
			  ((uint32_t) scratch[offset+1]) << 8;
		}
		if (cluster & 1)
			result = result >> 4;
		else
			result = result & 0xfff;
	}
	else if (volinfo->filesystem == FAT16) {
		result = (uint32_t) scratch[offset] |
		  ((uint32_t) scratch[offset+1]) << 8;
	}
	else if (volinfo->filesystem == FAT32) {
		result = ((uint32_t) scratch[offset] |
		  ((uint32_t) scratch[offset+1]) << 8 |
		  ((uint32_t) scratch[offset+2]) << 16 |
		  ((uint32_t) scratch[offset+3]) << 24) & 0x0fffffff;
	}
	else
		result = 0x0ffffff7;	// FAT32 bad cluster	
	return result;
}


/*
	Set FAT entry for specified cluster number
	You must provide a scratch buffer for one sector (SECTOR_SIZE) and a populated VOLINFO
	Returns DFS_ERRMISC for any error, otherwise DFS_OK
	scratchcache should point to a UINT32. This variable caches the physical sector number
	last read into the scratch buffer for performance enhancement reasons.

	NOTE: This code is HIGHLY WRITE-INEFFICIENT, particularly for flash media. Considerable
	performance gains can be realized by caching the sector. However this is difficult to
	achieve on FAT12 without requiring 2 sector buffers of scratch space, and it is a design
	requirement of this code to operate on a single 512-byte scratch.

	If you are operating DOSFS over flash, you are strongly advised to implement a writeback
	cache in your physical I/O driver. This will speed up your code significantly and will
	also conserve power and flash write life.
*/
uint32_t DFS_SetFAT(PVOLINFO volinfo, uint8_t *scratch, uint32_t *scratchcache, uint32_t cluster, uint32_t new_contents)
{
	uint32_t offset, sector, result;
	if (volinfo->filesystem == FAT12) {
		offset = cluster + (cluster / 2);
		new_contents &=0xfff;
	}
	else if (volinfo->filesystem == FAT16) {
		offset = cluster * 2;
		new_contents &=0xffff;
	}
	else if (volinfo->filesystem == FAT32) {
		offset = cluster * 4;
		new_contents &=0x0fffffff;	// FAT32 is really "FAT28"
	}
	else
		return DFS_ERRMISC;

	// at this point, offset is the BYTE offset of the desired sector from the start
	// of the FAT. Calculate the physical sector containing this FAT entry.
	sector = ldiv(offset, SECTOR_SIZE).quot + volinfo->fat1;

	// If this is not the same sector we last read, then read it into RAM
	if (sector != *scratchcache) {
		if(DFS_ReadSector(volinfo->unit, scratch, sector, 1)) {
			// avoid anyone assuming that this cache value is still valid, which
			// might cause disk corruption
			*scratchcache = 0;
			return DFS_ERRMISC;
		}
		*scratchcache = sector;
	}

	// At this point, we "merely" need to extract the relevant entry.
	// This is easy for FAT16 and FAT32, but a royal PITA for FAT12 as a single entry
	// may span a sector boundary. The normal way around this is always to read two
	// FAT sectors, but that luxury is (by design intent) unavailable to DOSFS.
	offset = ldiv(offset, SECTOR_SIZE).rem;

	if (volinfo->filesystem == FAT12) {

		// If this is an odd cluster, pre-shift the desired new contents 4 bits to
		// make the calculations below simpler
		if (cluster & 1)
			new_contents = new_contents << 4;

		// Special case for sector boundary
		if (offset == SECTOR_SIZE - 1) {

			// Odd cluster: High 12 bits being set
			if (cluster & 1) {
				scratch[offset] = (scratch[offset] & 0x0f) | new_contents & 0xf0;
			}
			// Even cluster: Low 12 bits being set
			else {
				scratch[offset] = new_contents & 0xff;
			}
			result = DFS_WriteSector(volinfo->unit, scratch, *scratchcache, 1);
			// mirror the FAT into copy 2
			if (DFS_OK == result)
				result = DFS_WriteSector(volinfo->unit, scratch, (*scratchcache)+volinfo->secperfat, 1);

			// If we wrote that sector OK, then read in the subsequent sector
			// and poke the first byte with the remainder of this FAT entry.
			if (DFS_OK == result) {
				// ggn: Original (in comment) caused ambiguities in some compilers
				// *scratchcache++
				(*scratchcache)++;
				result = DFS_ReadSector(volinfo->unit, scratch, *scratchcache, 1);
				if (DFS_OK == result) {
					// Odd cluster: High 12 bits being set
					if (cluster & 1) {
						// ggn: original (in comment) was wrong
						//scratch[0] = new_contents & 0xff00;
						scratch[0] = (new_contents & 0xff00) >> 8;
					}
					// Even cluster: Low 12 bits being set
					else {
						// ggn: original (in comment) was wrong
						//scratch[0] = (scratch[0] & 0xf0) | new_contents & 0x0f;
						scratch[0] = (scratch[0] & 0xf0) | (new_contents>>8) & 0x0f;
					}
					result = DFS_WriteSector(volinfo->unit, scratch, *scratchcache, 1);
					// mirror the FAT into copy 2
					if (DFS_OK == result)
						result = DFS_WriteSector(volinfo->unit, scratch, (*scratchcache)+volinfo->secperfat, 1);
				}
				else {
					// avoid anyone assuming that this cache value is still valid, which
					// might cause disk corruption
					*scratchcache = 0;
				}
			}
		} // if (offset == SECTOR_SIZE - 1)

		// Not a sector boundary. But we still have to worry about if it's an odd
		// or even cluster number.
		else {
			// Odd cluster: High 12 bits being set
			if (cluster & 1) {
				// ggn: original (in comment) was wrong
				//scratch[offset] = (scratch[offset] & 0x0f) | new_contents & 0xf0;
				//scratch[offset + 1] = new_contents & 0xff00;
				scratch[offset] = (scratch[offset] & 0x0f) | new_contents & 0xf0;
				scratch[offset + 1] = (new_contents & 0xff00) >> 8;
			}
			// Even cluster: Low 12 bits being set
			else {
				scratch[offset] = new_contents & 0xff;
				// ggn: original (in comment) was wrong
				//scratch[offset + 1] = (scratch[offset + 1] & 0xf0) | new_contents & 0x0f;
				scratch[offset+1] = (scratch[offset+1] & 0xf0) | (new_contents>>8) & 0x0f;
			}
			result = DFS_WriteSector(volinfo->unit, scratch, *scratchcache, 1);
			// mirror the FAT into copy 2
			if (DFS_OK == result)
				result = DFS_WriteSector(volinfo->unit, scratch, (*scratchcache)+volinfo->secperfat, 1);
		}
	}
	else if (volinfo->filesystem == FAT16) {
		scratch[offset] = (new_contents & 0xff);
		scratch[offset+1] = (new_contents & 0xff00) >> 8;
		result = DFS_WriteSector(volinfo->unit, scratch, *scratchcache, 1);
		// mirror the FAT into copy 2
		// ggn: the commented line did not take into account sectors > 512 bytes (i.e. hard disk images)
		//      TODO: explain why we need to divide volinfo->secperclus/2, this matches what GEMDOS does
		if (DFS_OK == result)
			//result = DFS_WriteSector(volinfo->unit, scratch, (*scratchcache)+volinfo->secperfat, 1);
			result = DFS_WriteSector(volinfo->unit, scratch, (*scratchcache) + volinfo->secperfat * volinfo->secperclus/2, 1);
	}
	else if (volinfo->filesystem == FAT32) {
		scratch[offset] = (new_contents & 0xff);
		scratch[offset+1] = (new_contents & 0xff00) >> 8;
		scratch[offset+2] = (new_contents & 0xff0000) >> 16;
		scratch[offset+3] = (scratch[offset+3] & 0xf0) | ((new_contents & 0x0f000000) >> 24);
		// Note well from the above: Per Microsoft's guidelines we preserve the upper
		// 4 bits of the FAT32 cluster value. It's unclear what these bits will be used
		// for; in every example I've encountered they are always zero.
		result = DFS_WriteSector(volinfo->unit, scratch, *scratchcache, 1);
		// mirror the FAT into copy 2
		// ggn: the commented line did not take into account sectors > 512 bytes (i.e. hard disk images)
		//      TODO: explain why we need to divide volinfo->secperclus/2, this matches what GEMDOS does
		if (DFS_OK == result)
			//result = DFS_WriteSector(volinfo->unit, scratch, (*scratchcache)+volinfo->secperfat, 1);
			result = DFS_WriteSector(volinfo->unit, scratch, (*scratchcache) + volinfo->secperfat * volinfo->secperclus/2, 1);
	}
	else
		result = DFS_ERRMISC;

	return result;
}

/*
	Convert a filename element from canonical (8.3) to directory entry (11) form
	src must point to the first non-separator character.
	dest must point to a 12-byte buffer.
*/
uint8_t *DFS_CanonicalToDir(uint8_t *dest, uint8_t *src)
{
	uint8_t *destptr = dest;

	memset(dest, ' ', 11);
	dest[11] = 0;

	while (*src && (*src != DIR_SEPARATOR) && (destptr - dest < 11)) {
		if (*src >= 'a' && *src <='z') {
			*destptr++ = (*src - 'a') + 'A';
			src++;
		}
		else if (*src == '.') {
			src++;
			destptr = dest + 8;
		}
		else {
			*destptr++ = *src++;
		}
	}

	return dest;
}

/*
	Find the first unused FAT entry
	You must provide a scratch buffer for one sector (SECTOR_SIZE) and a populated VOLINFO
	Returns a FAT32 BAD_CLUSTER value for any error, otherwise the contents of the desired
	FAT entry.
	Returns FAT32 bad_sector (0x0ffffff7) if there is no free cluster available
*/
uint32_t DFS_GetFreeFAT(PVOLINFO volinfo, uint8_t *scratch)
{
	uint32_t i, result = 0xffffffff, scratchcache = 0;
	
	// Search starts at cluster 2, which is the first usable cluster
	// NOTE: This search can't terminate at a bad cluster, because there might
	// legitimately be bad clusters on the disk.
	for (i=2; i < volinfo->numclusters; i++) {
		result = DFS_GetFAT(volinfo, scratch, &scratchcache, i);
		if (!result) {
			return i;
		}
	}
	return 0x0ffffff7;		// Can't find a free cluster
}


/*
	Open a directory for enumeration by DFS_GetNextDirEnt
	You must supply a populated VOLINFO (see DFS_GetVolInfo)
	The empty string or a string containing only the directory separator are
	considered to be the root directory.
	Returns 0 OK, nonzero for any error.
*/
uint32_t DFS_OpenDir(PVOLINFO volinfo, uint8_t *dirname, PDIRINFO dirinfo, uint8_t volflag)
{
	// Default behavior is a regular search for existing entries
	dirinfo->flags = 0;

	if (!strlen((char *) dirname) || (strlen((char *) dirname) == 1 && dirname[0] == DIR_SEPARATOR)) {
		if (volinfo->filesystem == FAT32) {
			dirinfo->currentcluster = volinfo->rootdir;
			dirinfo->currentsector = 0;
			dirinfo->currententry = 0;

			// read first sector of directory
			return DFS_ReadSector(volinfo->unit, dirinfo->scratch, volinfo->dataarea + ((volinfo->rootdir - 2) * volinfo->secperclus), 1);
		}
		else {
			dirinfo->currentcluster = 0;
			dirinfo->currentsector = 0;
			dirinfo->currententry = 0;

			// read first sector of directory
			return DFS_ReadSector(volinfo->unit, dirinfo->scratch, volinfo->rootdir, 1);
		}
	}

	// This is not the root directory. We need to find the start of this subdirectory.
	// We do this by devious means, using our own companion function DFS_GetNext.
	else {
		uint8_t tmpfn[12];
		uint8_t *ptr = dirname;
		uint32_t result;
		DIRENT de;

		if (volinfo->filesystem == FAT32) {
			dirinfo->currentcluster = volinfo->rootdir;
			dirinfo->currentsector = 0;
			dirinfo->currententry = 0;

			// read first sector of directory
			if (DFS_ReadSector(volinfo->unit, dirinfo->scratch, volinfo->dataarea + ((volinfo->rootdir - 2) * volinfo->secperclus), 1))
				return DFS_ERRMISC;
		}
		else {
			dirinfo->currentcluster = 0;
			dirinfo->currentsector = 0;
			dirinfo->currententry = 0;

			// read first sector of directory
			if (DFS_ReadSector(volinfo->unit, dirinfo->scratch, volinfo->rootdir, 1))
				return DFS_ERRMISC;
		}

		// skip leading path separators
		while (*ptr == DIR_SEPARATOR && *ptr)
			ptr++;

		// Scan the path from left to right, finding the start cluster of each entry
		// Observe that this code is inelegant, but obviates the need for recursion.
		while (*ptr) {
			DFS_CanonicalToDir(tmpfn, ptr);

			de.name[0] = 0;

			if (volflag == 1)
			{
			  // (raj) keep previous way if searching for the volume name
			  do {
			    result = DFS_GetNext(volinfo, dirinfo, &de);
				} while (!result && memcmp(de.name, tmpfn, 11));
			}
			else
			{
			  do {
				  result = DFS_GetNext(volinfo, dirinfo, &de);
				  // ggn: If the disk has a volume label which is the same as the name of the folder we're scanning
				  //      against, and that label existed before the folder, then this loop was going to stop at the
				  //      label, so the if immediately below this would mismatch the ATTR_DIRECTORY scan.
				  //      So we added an extra clause to keep looping if we detect ATTR_VOLUME_ID
			  } while (!result && memcmp(de.name, tmpfn, 11) || ((de.attr & ATTR_VOLUME_ID) == ATTR_VOLUME_ID));
			}

			if (!memcmp(de.name, tmpfn, 11) && ((de.attr & ATTR_DIRECTORY) == ATTR_DIRECTORY)) {
				if (volinfo->filesystem == FAT32) {
					dirinfo->currentcluster = (uint32_t) de.startclus_l_l |
					  ((uint32_t) de.startclus_l_h) << 8 |
					  ((uint32_t) de.startclus_h_l) << 16 |
					  ((uint32_t) de.startclus_h_h) << 24;
				}
				else if (volinfo->filesystem == FAT16) {
					dirinfo->currentcluster = (uint32_t) de.startclus_l_l |
					  ((uint32_t) de.startclus_l_h) << 8;
				}
				else { // ggn - FAT12
					dirinfo->currentcluster = (uint32_t)de.startclus_l_l |
						((uint32_t)de.startclus_l_h & 0xf) << 8;
				}

				dirinfo->currentsector = 0;
				dirinfo->currententry = 0;

				if (DFS_ReadSector(volinfo->unit, dirinfo->scratch, volinfo->dataarea + ((dirinfo->currentcluster - 2) * volinfo->secperclus), 1))
					return DFS_ERRMISC;
			}
			else if (!memcmp(de.name, tmpfn, 11) && !(de.attr & ATTR_DIRECTORY))
				return DFS_NOTFOUND;

			// seek to next item in list
			while (*ptr != DIR_SEPARATOR && *ptr)
				ptr++;
			if (*ptr == DIR_SEPARATOR)
				ptr++;
		}

		if (!dirinfo->currentcluster)
			return DFS_NOTFOUND;
	}
	return DFS_OK;
}

/*
	Get next entry in opened directory structure. Copies fields into the dirent
	structure, updates dirinfo. Note that it is the _caller's_ responsibility to
	handle the '.' and '..' entries.
	A deleted file will be returned as a NULL entry (first char of filename=0)
	by this code. Filenames beginning with 0x05 will be translated to 0xE5
	automatically. Long file name entries will be returned as NULL.
	returns DFS_EOF if there are no more entries, DFS_OK if this entry is valid,
	or DFS_ERRMISC for a media error
*/
uint32_t DFS_GetNext(PVOLINFO volinfo, PDIRINFO dirinfo, PDIRENT dirent)
{
	uint32_t tempint;	// required by DFS_GetFAT
	uint32_t tempcluster;	// ggn: protection against end of directory entries

	// Do we need to read the next sector of the directory?
	if (dirinfo->currententry >= SECTOR_SIZE / sizeof(DIRENT)) {
		dirinfo->currententry = 0;
		dirinfo->currentsector++;

		// Root directory; special case handling
		// Note that currentcluster will only ever be zero if both:
		// (a) this is the root directory, and
		// (b) we are on a FAT12/16 volume, where the root dir can't be expanded
		if (dirinfo->currentcluster == 0) {
			// Trying to read past end of root directory?
			if (dirinfo->currentsector * (SECTOR_SIZE / sizeof(DIRENT)) >= volinfo->rootentries)
				return DFS_EOF;

			// Otherwise try to read the next sector
			if (DFS_ReadSector(volinfo->unit, dirinfo->scratch, volinfo->rootdir + dirinfo->currentsector, 1))
				return DFS_ERRMISC;
		}

		// Normal handling
		else {
			if (dirinfo->currentsector >= volinfo->secperclus) {
				dirinfo->currentsector = 0;
				if ((dirinfo->currentcluster >= 0xff7 &&  volinfo->filesystem == FAT12) ||
				  (dirinfo->currentcluster >= 0xfff7 &&  volinfo->filesystem == FAT16) ||
				  (dirinfo->currentcluster >= 0x0ffffff7 &&  volinfo->filesystem == FAT32)) {
				  
				  	// We are at the end of the directory chain. If this is a normal
				  	// find operation, we should indicate that there is nothing more
				  	// to see.
				  	if (!(dirinfo->flags & DFS_DI_BLANKENT))
						return DFS_EOF;
					
					// On the other hand, if this is a "find free entry" search,
					// we need to tell the caller to allocate a new cluster
					else
						return DFS_ALLOCNEW;
				}
				// ggn: we can't just assign the result directly because we might get an end-of-directory
				//      marker and the caller might need dirinfo->currentcluster's last valid value.
				//dirinfo->currentcluster = DFS_GetFAT(volinfo, dirinfo->scratch, &tempint, dirinfo->currentcluster);
				tempcluster = DFS_GetFAT(volinfo, dirinfo->scratch, &tempint, dirinfo->currentcluster);
				// ggn: Handle (hopefully) a corner case of the directory having all its clusters' worth of entries
				//      filled completely.
				if ((volinfo->filesystem == FAT12 && tempcluster == 0x00000fff) ||
					(volinfo->filesystem == FAT16 && tempcluster == 0x0000ffff) ||
					(volinfo->filesystem == FAT32 && tempcluster == 0xffffffff))
				{
					// We are at the end of the directory chain. If this is a normal
					// find operation, we should indicate that there is nothing more
					// to see.
					if (!(dirinfo->flags & DFS_DI_BLANKENT))
						return DFS_EOF;

					// On the other hand, if this is a "find free entry" search,
					// we need to tell the caller to allocate a new cluster
					else
						return DFS_ALLOCNEW;
				}
				dirinfo->currentcluster = tempcluster;
			}
			if (DFS_ReadSector(volinfo->unit, dirinfo->scratch, volinfo->dataarea + ((dirinfo->currentcluster - 2) * volinfo->secperclus) + dirinfo->currentsector, 1))
				return DFS_ERRMISC;
		}
	}

	memcpy(dirent, &(((PDIRENT) dirinfo->scratch)[dirinfo->currententry]), sizeof(DIRENT));

	if (dirent->name[0] == 0) {		// no more files in this directory
		// If this is a "find blank" then we can reuse this name.
		if (dirinfo->flags & DFS_DI_BLANKENT)
			return DFS_OK;
		else
			return DFS_EOF;
	}

	if (dirent->name[0] == 0xe5)	// handle deleted file entries
	{
		dirent->name[0] = 0;
		// ggn: If we don't exit here, dirinfo->currententry will be increased by one.
		//      This was causing problems in DFS_Openfile, so with the addition of the
		//      following 2 lines, the problem of creating a file on an empty disk
		//      (DFS_Openfile would try to write outside the FAT buffer) goes away
		if (dirinfo->flags & DFS_DI_BLANKENT)
			return DFS_OK;
	}
	else if ((dirent->attr & ATTR_LONG_NAME) == ATTR_LONG_NAME)
		dirent->name[0] = 0;
	else if (dirent->name[0] == 0x05)	// handle kanji filenames beginning with 0xE5
		dirent->name[0] = 0xe5;

	dirinfo->currententry++;

	return DFS_OK;
}

/*
	INTERNAL
	Find a free directory entry in the directory specified by path
	This function MAY cause a disk write if it is necessary to extend the directory
	size.
	Note - di.scratch must be preinitialized to point to a sector scratch buffer
	de is a scratch structure
	Returns DFS_ERRMISC if a new entry could not be located or created
	de is updated with the same return information you would expect from DFS_GetNext
*/
uint32_t DFS_GetFreeDirEnt(PVOLINFO volinfo, uint8_t *path, PDIRINFO di, PDIRENT de, uint8_t mode)
{
	uint32_t tempclus,i;

	if (DFS_OpenDir(volinfo, path, di, 0))
		return DFS_NOTFOUND;

	// Set "search for empty" flag so DFS_GetNext knows what we're doing
	di->flags |= DFS_DI_BLANKENT;

	// We seek through the directory looking for an empty entry
	// Note we are reusing tempclus as a temporary result holder.
	tempclus = 0;
	do {
		tempclus = DFS_GetNext(volinfo, di, de);

		// Empty entry found
		if (tempclus == DFS_OK && (!de->name[0])) {
			return DFS_OK;
		}

		// End of root directory reached
		else if (tempclus == DFS_EOF)
			return DFS_ERRMISC;
			
		else if (tempclus == DFS_ALLOCNEW) {
			tempclus = DFS_GetFreeFAT(volinfo, di->scratch);
			// ggn: ????? gemdos seems to do that in my example
			if (mode & DFS_FOLDER)
			{
				tempclus++;
			}
			if (tempclus == 0x0ffffff7)
				return DFS_ERRMISC;

			// write out zeroed sectors to the new cluster
			memset(di->scratch, 0, SECTOR_SIZE);
			for (i=0;i<volinfo->secperclus;i++) {
				if (DFS_WriteSector(volinfo->unit, di->scratch, volinfo->dataarea + ((tempclus - 2) * volinfo->secperclus) + i, 1))
					return DFS_ERRMISC;
			}
			// Point old end cluster to newly allocated cluster
			i = 0;
			DFS_SetFAT(volinfo, di->scratch, &i, di->currentcluster, tempclus);

			// Update DIRINFO so caller knows where to place the new file
			di->currentcluster = tempclus;
			di->currentsector = 0;
			di->currententry = 1;	// since the code coming after this expects to subtract 1
			
			// Mark newly allocated cluster as end of chain
			// ggn: For GEMDOS the end-of-chain marker is fff/ffff/fffffff
			switch(volinfo->filesystem) {
				case FAT12:		tempclus = 0xfff;	break;
				case FAT16:		tempclus = 0xffff;	break;
				case FAT32:		tempclus = 0x0fffffff;	break;
				default:		return DFS_ERRMISC;
			}
			// ggn: If we reached this far then we should exit instead of looping
			//      TODO: get rid of the do{} block?
			//tempclus = 0;
			di->currententry = 0;
			DFS_SetFAT(volinfo, di->scratch, &i, di->currentcluster, tempclus);
			return DFS_OK;
		}
	} while (!tempclus);

	// We shouldn't get here
	return DFS_ERRMISC;
}

/*
	Open a file for reading or writing. You supply populated VOLINFO, a path to the file,
	mode (DFS_READ or DFS_WRITE) and an empty fileinfo structure. You also need to
	provide a pointer to a sector-sized scratch buffer.
	Returns various DFS_* error states. If the result is DFS_OK, fileinfo can be used
	to access the file from this point on.
*/
uint32_t DFS_OpenFile(PVOLINFO volinfo, uint8_t *path, uint8_t mode, uint8_t *scratch, PFILEINFO fileinfo, uint32_t filedatetime)
{
	uint8_t tmppath[MAX_PATH];
	uint8_t filename[12];
	uint8_t *p;
	DIRINFO di;
	DIRENT de;

	// larwe 2006-09-16 +1 zero out file structure
	memset(fileinfo, 0, sizeof(FILEINFO));

	// save access mode
	fileinfo->mode = mode;

	// Get a local copy of the path. If it's longer than MAX_PATH, abort.
	strncpy((char *) tmppath, (char *) path, MAX_PATH);
	tmppath[MAX_PATH - 1] = 0;
	if (strcmp((char *) path,(char *) tmppath)) { return DFS_PATHLEN; }

	// strip leading path separators
	while (tmppath[0] == DIR_SEPARATOR) { strcpy((char *) tmppath, (char *) tmppath + 1); }

	// Parse filename off the end of the supplied path
	p = tmppath;
	while (*(p++));

	p--;
	while ((p > tmppath) && (*p != DIR_SEPARATOR)) { p--; } // larwe 9/16/06 ">=" to ">" bugfix
		
	if (*p == DIR_SEPARATOR) { p++; }

	DFS_CanonicalToDir(filename, p);

	if (p > tmppath) { p--; }
		
	if ((*p == DIR_SEPARATOR) || (p == tmppath)) { *p = 0; } // larwe 9/16/06 +"|| p == tmppath" bugfix

	// At this point, if our path was MYDIR/MYDIR2/FILE.EXT, filename = "FILE    EXT" and
	// tmppath = "MYDIR/MYDIR2".
	di.scratch = scratch;
	if (DFS_OpenDir(volinfo, tmppath, &di, 0))
		return DFS_NOTFOUND;

	while (!DFS_GetNext(volinfo, &di, &de)) {
	strncpy((char *) path, (char *) de.name, 11); path[12] = 0;
		if (!memcmp(de.name, filename, 11)) {
			fileinfo->volinfo = volinfo;
			fileinfo->pointer = 0;
			// The reason we store this extra info about the file is so that we can
			// speedily update the file size, modification date, etc. on a file that is
			// opened for writing.
			if (di.currentcluster == 0)
				fileinfo->dirsector = volinfo->rootdir + di.currentsector;
			else
				fileinfo->dirsector = volinfo->dataarea + ((di.currentcluster - 2) * volinfo->secperclus) + di.currentsector;
			fileinfo->diroffset = di.currententry - 1;
			if (volinfo->filesystem == FAT32) {
				fileinfo->cluster = (uint32_t) de.startclus_l_l |
				  ((uint32_t) de.startclus_l_h) << 8 |
				  ((uint32_t) de.startclus_h_l) << 16 |
				  ((uint32_t) de.startclus_h_h) << 24;
			}
			else {
				fileinfo->cluster = (uint32_t) de.startclus_l_l |
				  ((uint32_t) de.startclus_l_h) << 8;
			}
			fileinfo->firstcluster = fileinfo->cluster;
			fileinfo->filelen = (uint32_t) de.filesize_0 |
			  ((uint32_t) de.filesize_1) << 8 |
			  ((uint32_t) de.filesize_2) << 16 |
			  ((uint32_t) de.filesize_3) << 24;

			// You can't use this function call to open a directory.
			if (de.attr & ATTR_DIRECTORY)
				// ggn: But UnlinkFile() might ask us if this directory exists, so better explicitly return that
				//return DFS_NOTFOUND;
				return DFS_ISDIRECTORY;

			// ggn: If we opened the file for writing and it exists, delete it
			//      (TODO: this is optional, perhaps it should be the default, so we match all fopen() implementations)
			if (mode & DFS_DELETEOPEN && mode & DFS_WRITE)
			{
				if (DFS_UnlinkFile(volinfo, path, scratch))
					return DFS_ERRMISC;
				// Fallthrough to the new file code below
				break;
			}

			return DFS_OK;
		}
	}

	// At this point, we KNOW the file does not exist. If the file was opened
	// with write access, we can create it.
	if (mode & DFS_WRITE) {
		uint32_t cluster, temp;

		// Locate or create a directory entry for this file
		if (DFS_OK != DFS_GetFreeDirEnt(volinfo, tmppath, &di, &de, mode))
			return DFS_ERRMISC;

		// put sane values in the directory entry
		memset(&de, 0, sizeof(de));
		memcpy(de.name, filename, 11);
		
		if (filedatetime)
		{
			de.crtdate_h = (uint8_t)(filedatetime >> 24);
			de.crtdate_l = (uint8_t)(filedatetime >> 16);
			de.crttime_h = (uint8_t)(filedatetime >> 8);
			de.crttime_l = (uint8_t)filedatetime;
			de.wrtdate_h = (uint8_t)(filedatetime >> 24);
			de.wrtdate_l = (uint8_t)(filedatetime >> 16);
			de.wrttime_h = (uint8_t)(filedatetime >> 8);
			de.wrttime_l = (uint8_t)filedatetime;
		}
		else
		{
			de.crttime_l = 0x20;	// 01:01:00am, Jan 1, 2006.
			de.crttime_h = 0x08;
			de.crtdate_l = 0x11;
			de.crtdate_h = 0x34;
			de.lstaccdate_l = 0x11;
			de.lstaccdate_h = 0x34;
			de.wrttime_l = 0x20;
			de.wrttime_h = 0x08;
			de.wrtdate_l = 0x11;
			de.wrtdate_h = 0x34;
		}

		// ggn: If we were asked to create a folder, then let's add the folder attribute
		if (mode & DFS_FOLDER)
		{
			de.attr = ATTR_DIRECTORY;
		}

		// allocate a starting cluster for the directory entry
		cluster = DFS_GetFreeFAT(volinfo, scratch);

		de.startclus_l_l = cluster & 0xff;
		de.startclus_l_h = (cluster & 0xff00) >> 8;
		de.startclus_h_l = (cluster & 0xff0000) >> 16;
		de.startclus_h_h = (cluster & 0xff000000) >> 24;

		// update FILEINFO for our caller's sake
		fileinfo->volinfo = volinfo;
		fileinfo->pointer = 0;
		// The reason we store this extra info about the file is so that we can
		// speedily update the file size, modification date, etc. on a file that is
		// opened for writing.
		if (di.currentcluster == 0)
			fileinfo->dirsector = volinfo->rootdir + di.currentsector;
		else
			fileinfo->dirsector = volinfo->dataarea + ((di.currentcluster - 2) * volinfo->secperclus) + di.currentsector;
		// ggn: The original code would write outside the FAT buffer on an empty disk. A couple of ideas were tried
		//      (like clamping the value if it's 0 originally), but this led to more problems in the long run.
		//      So a differnt approach was tried in DFS_GetNext() which removes the need to decrease di.currententry by 1.
		//fileinfo->diroffset = di.currententry - 1;
		fileinfo->diroffset = di.currententry;
		fileinfo->cluster = cluster;
		fileinfo->firstcluster = cluster;
		fileinfo->filelen = 0;
		
		// write the directory entry
		// note that we no longer have the sector containing the directory entry,
		// tragically, so we have to re-read it
		if (DFS_ReadSector(volinfo->unit, scratch, fileinfo->dirsector, 1))
			return DFS_ERRMISC;
		//memcpy(&(((PDIRENT) scratch)[di.currententry-1]), &de, sizeof(DIRENT));
		memcpy(&(((PDIRENT)scratch)[di.currententry]), &de, sizeof(DIRENT));
		if (DFS_WriteSector(volinfo->unit, scratch, fileinfo->dirsector, 1))
			return DFS_ERRMISC;

		// Mark newly allocated cluster as end of chain
		// ggn: For GEMDOS the end-of-chain marker is fff/ffff/fffffff
		switch(volinfo->filesystem) {
			case FAT12:		cluster = 0xfff;	break;
			case FAT16:		cluster = 0xffff;	break;
			case FAT32:		cluster = 0x0fffffff;	break;
			default:		return DFS_ERRMISC;
		}
		temp = 0;
		DFS_SetFAT(volinfo, scratch, &temp, fileinfo->cluster, cluster);

		return DFS_OK;
	}

	return DFS_NOTFOUND;
}

/*
	Read an open file
	You must supply a prepopulated FILEINFO as provided by DFS_OpenFile, and a
	pointer to a SECTOR_SIZE scratch buffer.
	Note that returning DFS_EOF is not an error condition. This function updates the
	successcount field with the number of bytes actually read.
*/
uint32_t DFS_ReadFile(PFILEINFO fileinfo, uint8_t *scratch, uint8_t *buffer, uint32_t *successcount, uint32_t len)
{
	uint32_t remain;
	uint32_t result = DFS_OK;
	uint32_t sector;
	uint32_t bytesread;

	// Don't try to read past EOF
	if (len > fileinfo->filelen - fileinfo->pointer)
		len = fileinfo->filelen - fileinfo->pointer;

	remain = len;
	*successcount = 0;

	while (remain && result == DFS_OK) {
		// This is a bit complicated. The sector we want to read is addressed at a cluster
		// granularity by the fileinfo->cluster member. The file pointer tells us how many
		// extra sectors to add to that number.
		sector = fileinfo->volinfo->dataarea +
		  ((fileinfo->cluster - 2) * fileinfo->volinfo->secperclus) +
		  div(div(fileinfo->pointer,fileinfo->volinfo->secperclus * SECTOR_SIZE).rem, SECTOR_SIZE).quot;

		// Case 1 - File pointer is not on a sector boundary
		if (div(fileinfo->pointer, SECTOR_SIZE).rem) {
			uint16_t tempreadsize;

			// We always have to go through scratch in this case
			result = DFS_ReadSector(fileinfo->volinfo->unit, scratch, sector, 1);

			// This is the number of bytes that we actually care about in the sector
			// just read.
			tempreadsize = SECTOR_SIZE - (div(fileinfo->pointer, SECTOR_SIZE).rem);
					
			// Case 1A - We want the entire remainder of the sector. After this
			// point, all passes through the read loop will be aligned on a sector
			// boundary, which allows us to go through the optimal path 2A below.
		   	if (remain >= tempreadsize) {
				memcpy(buffer, scratch + (SECTOR_SIZE - tempreadsize), tempreadsize);
				bytesread = tempreadsize;
				buffer += tempreadsize;
				fileinfo->pointer += tempreadsize;
				remain -= tempreadsize;
			}
			// Case 1B - This read concludes the file read operation
			else {
				memcpy(buffer, scratch + (SECTOR_SIZE - tempreadsize), remain);

				buffer += remain;
				fileinfo->pointer += remain;
				bytesread = remain;
				remain = 0;
			}
		}
		// Case 2 - File pointer is on sector boundary
		else {
			// Case 2A - We have at least one more full sector to read and don't have
			// to go through the scratch buffer. You could insert optimizations here to
			// read multiple sectors at a time, if you were thus inclined (note that
			// the maximum multi-read you could perform is a single cluster, so it would
			// be advantageous to have code similar to case 1A above that would round the
			// pointer to a cluster boundary the first pass through, so all subsequent
			// [large] read requests would be able to go a cluster at a time).
			if (remain >= SECTOR_SIZE) {
				result = DFS_ReadSector(fileinfo->volinfo->unit, buffer, sector, 1);
				remain -= SECTOR_SIZE;
				buffer += SECTOR_SIZE;
				fileinfo->pointer += SECTOR_SIZE;
				bytesread = SECTOR_SIZE;
			}
			// Case 2B - We are only reading a partial sector
			else {
				result = DFS_ReadSector(fileinfo->volinfo->unit, scratch, sector, 1);
				memcpy(buffer, scratch, remain);
				buffer += remain;
				fileinfo->pointer += remain;
				bytesread = remain;
				remain = 0;
			}
		}

		*successcount += bytesread;

		// check to see if we stepped over a cluster boundary
		if (div(fileinfo->pointer - bytesread, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot !=
		  div(fileinfo->pointer, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot) {
			// An act of minor evil - we use bytesread as a scratch integer, knowing that
			// its value is not used after updating *successcount above
			bytesread = 0;
			if (((fileinfo->volinfo->filesystem == FAT12) && (fileinfo->cluster >= 0xff8)) ||
			  ((fileinfo->volinfo->filesystem == FAT16) && (fileinfo->cluster >= 0xfff8)) ||
			  ((fileinfo->volinfo->filesystem == FAT32) && (fileinfo->cluster >= 0x0ffffff8)))
				result = DFS_EOF;
			else
				fileinfo->cluster = DFS_GetFAT(fileinfo->volinfo, scratch, &bytesread, fileinfo->cluster);
		}
	}
	
	return result;
}

/*
	Seek file pointer to a given position
	This function does not return status - refer to the fileinfo->pointer value
	to see where the pointer wound up.
	Requires a SECTOR_SIZE scratch buffer
*/
void DFS_Seek(PFILEINFO fileinfo, uint32_t offset, uint8_t *scratch)
{
	uint32_t tempint;

	// larwe 9/16/06 bugfix split case 0a/0b and changed fallthrough handling
	// Case 0a - Return immediately for degenerate case
	if (offset == fileinfo->pointer) {
		return;
	}
	
	// Case 0b - Don't allow the user to seek past the end of the file
	if (offset > fileinfo->filelen) {
		offset = fileinfo->filelen;
		// NOTE NO RETURN HERE!
	}

	// Case 1 - Simple rewind to start
	// Note _intentional_ fallthrough from Case 0b above
	if (offset == 0) {
		fileinfo->cluster = fileinfo->firstcluster;
		fileinfo->pointer = 0;
		return;		// larwe 9/16/06 +1 bugfix
	}
	// Case 2 - Seeking backwards. Need to reset and seek forwards
	else if (offset < fileinfo->pointer) {
		fileinfo->cluster = fileinfo->firstcluster;
		fileinfo->pointer = 0;
		// NOTE NO RETURN HERE!
	}

	// Case 3 - Seeking forwards
	// Note _intentional_ fallthrough from Case 2 above

	// Case 3a - Seek size does not cross cluster boundary - 
	// very simple case
	// larwe 9/16/06 changed .rem to .quot in both div calls, bugfix
	if (div(fileinfo->pointer, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot ==
	  div(fileinfo->pointer + offset, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot) {
		fileinfo->pointer = offset;
	}
	// Case 3b - Seeking across cluster boundary(ies)
	else {
		// round file pointer down to cluster boundary
		fileinfo->pointer = div(fileinfo->pointer, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot *
		  fileinfo->volinfo->secperclus * SECTOR_SIZE;

		// seek by clusters
		// larwe 9/30/06 bugfix changed .rem to .quot in both div calls
		while (div(fileinfo->pointer, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot !=
		  div(fileinfo->pointer + offset, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot) {

			fileinfo->cluster = DFS_GetFAT(fileinfo->volinfo, scratch, &tempint, fileinfo->cluster);
			// Abort if there was an error
			if (fileinfo->cluster == 0x0ffffff7) {
				fileinfo->pointer = 0;
				fileinfo->cluster = fileinfo->firstcluster;
				return;
			}
			fileinfo->pointer += SECTOR_SIZE * fileinfo->volinfo->secperclus;
		}

		// since we know the cluster is right, we have no more work to do
		fileinfo->pointer = offset;
	}
}

/*
	Delete a file
	scratch must point to a sector-sized buffer
*/
uint32_t DFS_UnlinkFile(PVOLINFO volinfo, uint8_t *path, uint8_t *scratch)
{
	PDIRENT de = (PDIRENT) scratch;
	FILEINFO fi;
	uint32_t cache = 0;
	uint32_t tempclus;

	// DFS_OpenFile gives us all the information we need to delete it
	// ggn: extended for the case of deleting an empty folder (the caller assumes responsibility for this)
	//if (DFS_OK != DFS_OpenFile(volinfo, path, DFS_READ, scratch, &fi, 0))
	uint32_t ret = DFS_OpenFile(volinfo, path, DFS_READ, scratch, &fi, 0);
	if (ret != DFS_OK && ret != DFS_ISDIRECTORY)
		return DFS_NOTFOUND;

	// First, read the directory sector and delete that entry
	if (DFS_ReadSector(volinfo->unit, scratch, fi.dirsector, 1))
		return DFS_ERRMISC;
	((PDIRENT) scratch)[fi.diroffset].name[0] = 0xe5;
	if (DFS_WriteSector(volinfo->unit, scratch, fi.dirsector, 1))
		return DFS_ERRMISC;

	// Now follow the cluster chain to free the file space
	while (!((volinfo->filesystem == FAT12 && fi.firstcluster >= 0x0ff7) ||
	  (volinfo->filesystem == FAT16 && fi.firstcluster >= 0xfff7) ||
	  (volinfo->filesystem == FAT32 && fi.firstcluster >= 0x0ffffff7))) {
		tempclus = fi.firstcluster;

		fi.firstcluster = DFS_GetFAT(volinfo, scratch, &cache, fi.firstcluster);
		DFS_SetFAT(volinfo, scratch, &cache, tempclus, 0);

	}
	return DFS_OK;
}


/*
	Write an open file
	You must supply a prepopulated FILEINFO as provided by DFS_OpenFile, and a
	pointer to a SECTOR_SIZE scratch buffer.
	This function updates the successcount field with the number of bytes actually written.
*/
uint32_t DFS_WriteFile(PFILEINFO fileinfo, uint8_t *scratch, uint8_t *buffer, uint32_t *successcount, uint32_t len)
{
	uint32_t remain;
	uint32_t result = DFS_OK;
	uint32_t sector;
	uint32_t byteswritten;

	// Don't allow writes to a file that's open as readonly
	if (!(fileinfo->mode & DFS_WRITE))
		return DFS_ERRMISC;

	remain = len;
	*successcount = 0;

	while (remain && result == DFS_OK) {
		// This is a bit complicated. The sector we want to read is addressed at a cluster
		// granularity by the fileinfo->cluster member. The file pointer tells us how many
		// extra sectors to add to that number.
		sector = fileinfo->volinfo->dataarea +
		  ((fileinfo->cluster - 2) * fileinfo->volinfo->secperclus) +
		  div(div(fileinfo->pointer,fileinfo->volinfo->secperclus * SECTOR_SIZE).rem, SECTOR_SIZE).quot;

		// Case 1 - File pointer is not on a sector boundary
		if (div(fileinfo->pointer, SECTOR_SIZE).rem) {
			uint16_t tempsize;

			// We always have to go through scratch in this case
			result = DFS_ReadSector(fileinfo->volinfo->unit, scratch, sector, 1);

			// This is the number of bytes that we don't want to molest in the
			// scratch sector just read.
			tempsize = div(fileinfo->pointer, SECTOR_SIZE).rem;
					
			// Case 1A - We are writing the entire remainder of the sector. After
			// this point, all passes through the read loop will be aligned on a
			// sector boundary, which allows us to go through the optimal path
			// 2A below.
		   	if (remain >= (uint32_t)(SECTOR_SIZE - tempsize)) {
				memcpy(scratch + tempsize, buffer, SECTOR_SIZE - tempsize);
				if (!result)
					result = DFS_WriteSector(fileinfo->volinfo->unit, scratch, sector, 1);

				byteswritten = SECTOR_SIZE - tempsize;
				buffer += SECTOR_SIZE - tempsize;
				fileinfo->pointer += SECTOR_SIZE - tempsize;
				if (fileinfo->filelen < fileinfo->pointer) {
					fileinfo->filelen = fileinfo->pointer;
				}
				remain -= SECTOR_SIZE - tempsize;
			}
			// Case 1B - This concludes the file write operation
			else {
				memcpy(scratch + tempsize, buffer, remain);
				if (!result)
					result = DFS_WriteSector(fileinfo->volinfo->unit, scratch, sector, 1);

				buffer += remain;
				fileinfo->pointer += remain;
				if (fileinfo->filelen < fileinfo->pointer) {
					fileinfo->filelen = fileinfo->pointer;
				}
				byteswritten = remain;
				remain = 0;
			}
		} // case 1
		// Case 2 - File pointer is on sector boundary
		else {
			// Case 2A - We have at least one more full sector to write and don't have
			// to go through the scratch buffer. You could insert optimizations here to
			// write multiple sectors at a time, if you were thus inclined. Refer to
			// similar notes in DFS_ReadFile.
			if (remain >= SECTOR_SIZE) {
				result = DFS_WriteSector(fileinfo->volinfo->unit, buffer, sector, 1);
				remain -= SECTOR_SIZE;
				buffer += SECTOR_SIZE;
				fileinfo->pointer += SECTOR_SIZE;
				if (fileinfo->filelen < fileinfo->pointer) {
					fileinfo->filelen = fileinfo->pointer;
				}
				byteswritten = SECTOR_SIZE;
			}
			// Case 2B - We are only writing a partial sector and potentially need to
			// go through the scratch buffer.
			else {
				// If the current file pointer is not yet at or beyond the file
				// length, we are writing somewhere in the middle of the file and
				// need to load the original sector to do a read-modify-write.
				if (fileinfo->pointer < fileinfo->filelen) {
					result = DFS_ReadSector(fileinfo->volinfo->unit, scratch, sector, 1);
					if (!result) {
						memcpy(scratch, buffer, remain);
						result = DFS_WriteSector(fileinfo->volinfo->unit, scratch, sector, 1);
					}
				}
				else {
					result = DFS_WriteSector(fileinfo->volinfo->unit, buffer, sector, 1);
				}

				buffer += remain;
				fileinfo->pointer += remain;
				if (fileinfo->filelen < fileinfo->pointer) {
					fileinfo->filelen = fileinfo->pointer;
				}
				byteswritten = remain;
				remain = 0;
			}
		}

		*successcount += byteswritten;

		// ggn: Corner case where size is a multiple of a cluster: don't run the following as it
		//      will allocate an extra cluster
		if (!remain) break;

		// check to see if we stepped over a cluster boundary
		if (div(fileinfo->pointer - byteswritten, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot !=
		  div(fileinfo->pointer, fileinfo->volinfo->secperclus * SECTOR_SIZE).quot) {
		  	uint32_t lastcluster;

		  	// We've transgressed into another cluster. If we were already at EOF,
		  	// we need to allocate a new cluster.
			// An act of minor evil - we use byteswritten as a scratch integer, knowing
			// that its value is not used after updating *successcount above
			byteswritten = 0;

			lastcluster = fileinfo->cluster;
			fileinfo->cluster = DFS_GetFAT(fileinfo->volinfo, scratch, &byteswritten, fileinfo->cluster);
			
			// Allocate a new cluster?
			if (((fileinfo->volinfo->filesystem == FAT12) && (fileinfo->cluster >= 0xff8)) ||
			  ((fileinfo->volinfo->filesystem == FAT16) && (fileinfo->cluster >= 0xfff8)) ||
			  ((fileinfo->volinfo->filesystem == FAT32) && (fileinfo->cluster >= 0x0ffffff8))) {
			  	uint32_t tempclus;

				tempclus = DFS_GetFreeFAT(fileinfo->volinfo, scratch);
				byteswritten = 0; // invalidate cache
				if (tempclus == 0x0ffffff7)
					return DFS_ERRMISC;

				// Link new cluster onto file
				DFS_SetFAT(fileinfo->volinfo, scratch, &byteswritten, lastcluster, tempclus);
				fileinfo->cluster = tempclus;

				// Mark newly allocated cluster as end of chain
				switch(fileinfo->volinfo->filesystem) {
					case FAT12:		tempclus = 0xfff;	break; // ggn: Changed this from ff8 for debugging (matching GEMDOS' behaviour)
					case FAT16:		tempclus = 0xffff;	break;
					case FAT32:		tempclus = 0x0ffffff8;	break;
					default:		return DFS_ERRMISC;
				}
				DFS_SetFAT(fileinfo->volinfo, scratch, &byteswritten, fileinfo->cluster, tempclus);

				result = DFS_OK;
			}
			// No else clause is required.
		}
	}
	
	// Update directory entry
		if (DFS_ReadSector(fileinfo->volinfo->unit, scratch, fileinfo->dirsector, 1))
			return DFS_ERRMISC;
		// ggn: Don't write file size on a folder entry, that's silly
		if (!(fileinfo->mode & DFS_FOLDER))
		{
			((PDIRENT)scratch)[fileinfo->diroffset].filesize_0 = fileinfo->filelen & 0xff;
			((PDIRENT)scratch)[fileinfo->diroffset].filesize_1 = (fileinfo->filelen & 0xff00) >> 8;
			((PDIRENT)scratch)[fileinfo->diroffset].filesize_2 = (fileinfo->filelen & 0xff0000) >> 16;
			((PDIRENT)scratch)[fileinfo->diroffset].filesize_3 = (fileinfo->filelen & 0xff000000) >> 24;
		}
		if (DFS_WriteSector(fileinfo->volinfo->unit, scratch, fileinfo->dirsector, 1))
			return DFS_ERRMISC;
	return result;
}

/*
	(raj) Rename a file, newname is the new file name (without path)
	scratch must point to a sector-sized buffer
*/
uint32_t DFS_RenameFile(PVOLINFO volinfo, uint8_t *path, uint8_t *newname, uint8_t *scratch)
{
	PDIRENT de = (PDIRENT) scratch;
	FILEINFO fi;
	uint8_t filename[12];

	// DFS_OpenFile gives us all the information we need to rename it
	uint32_t ret = DFS_OpenFile(volinfo, path, DFS_READ, scratch, &fi, 0);
	if ((ret != DFS_OK) && (ret != DFS_ISDIRECTORY)) { return DFS_NOTFOUND; }

	// First, read the directory sector and delete that entry
	if (DFS_ReadSector(volinfo->unit, scratch, fi.dirsector, 1)) { return DFS_ERRMISC; }
	
	DFS_CanonicalToDir(filename, newname);

	memcpy(((PDIRENT) scratch)[fi.diroffset].name, filename, 11);
	
	if (DFS_WriteSector(volinfo->unit, scratch, fi.dirsector, 1)) { return DFS_ERRMISC; }

	return DFS_OK;
}

/*
	(raj) get volume name and set it if newname has length. You supply populated VOLINFO,
	a pointer to buffer that will contain the name in return (mode = DFS_READ) or the name
	that must be changed (mode = DFS_WRITE) if the entry exists (attribute ATTR_VOLUME_ID).
	You also need to provide a pointer to a sector-sized scratch buffer.
	Returns various DFS_* error states. If the result is DFS_OK.
*/
uint32_t DFS_volumeName(PVOLINFO volinfo, uint8_t *name, uint8_t mode, uint8_t *scratch)
{
	uint8_t tmppath[11];
	DIRINFO di;
	DIRENT de;
	FILEINFO fi;

  tmppath[0] = 0;
	memset(&fi, 0, sizeof(FILEINFO));

	di.scratch = scratch;
	if (DFS_OpenDir(volinfo, tmppath, &di, 1)) { return DFS_NOTFOUND; }

	while (!DFS_GetNext(volinfo, &di, &de))
	{
		if (de.attr & ATTR_VOLUME_ID)
		{
			if (mode & DFS_READ)
			{
				strncpy((char *)name, (char *)de.name, 11); name[12] = 0;
			
				return DFS_OK;
			}
			else if (mode & DFS_WRITE)
			{
				if (di.currentcluster == 0)
				{
					fi.dirsector = volinfo->rootdir + di.currentsector;
				}
				else
				{
					fi.dirsector = volinfo->dataarea + ((di.currentcluster - 2) * volinfo->secperclus) + di.currentsector;
				}
				fi.diroffset = di.currententry - 1;

				if (DFS_ReadSector(volinfo->unit, scratch, fi.dirsector, 1)) { return DFS_ERRMISC; }
	
				memcpy(((PDIRENT) scratch)[fi.diroffset].name, name, 11); name[12] = 0;
	
				if (DFS_WriteSector(volinfo->unit, scratch, fi.dirsector, 1)) { return DFS_ERRMISC; }

				return DFS_OK;
			}
		}
	}
	
	return DFS_NOTFOUND;
}
