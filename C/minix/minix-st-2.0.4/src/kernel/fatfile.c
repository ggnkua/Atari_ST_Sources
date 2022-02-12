/*
fatfile.c

Created:	Feb 24, 1994 by Philip Homburg <philip@cs.vu.nl>
*/

#include "kernel.h"
#include "driver.h"
#include "drvlib.h"
#if ENABLE_FATFILE
#include <stdlib.h>
#include "assert.h"
INIT_ASSERT


#define BOOT_POS		((unsigned long)0)
#define BOOT_SIZE		512

struct bootsector {
	u8_t b_jmp[3];			/* JMP instruction to reach boot code */
	u8_t b_oem_name[8];		/* OEM name and version */
	u8_t b_bytes_per_sector[2];
	u8_t b_sectors_per_cluster;
	u8_t b_reserved[2];
	u8_t b_nr_fats;
	u8_t b_rootdir_entries[2];
	u8_t b_nr_sectors16[2];		/* # sectors if < 32M, otherwise 0 */
	u8_t b_media;
	u8_t b_sectors_per_fat16[2];	/* sec/fat if FAT-12 or FAT-16 */
	u8_t b_sectors_per_track[2];
	u8_t b_nr_heads[2];
	u8_t b_hidden_sectors[4];
	u8_t b_nr_sectors32[4];		/* # sectors if >= 32M */

	/* Only for FAT-32: */
	u8_t b_sectors_per_fat32[4];	/* sec/fat if FAT-32 */
	u8_t b_flags[2];
	u8_t b_version[2];
	u8_t b_rootdir_cluster[4];	/* First cluster in root directory */
	u8_t b_info_sector[2];
	u8_t b_backup_boot[2];
};

#define B_MAGIC_POS		0x1FE
#define B_MAGIC_OK(c1,c2)	((c1) == 0x55 && (c2) == 0xAA)

#define MAX_FAT12_CLUSTERS	0xFEE	/* Maximum for a 12 bit FAT. */

struct dirent
{
	u8_t d_name[8];
	u8_t d_ext[3];
	u8_t d_attr;
	u8_t d_Case;
	u8_t d_ctime_ms;
	u16_t d_ctime;
	u16_t d_cdate;
	u16_t d_adate;
	u8_t d_cluster2;
	u8_t d_cluster3;
	u16_t d_time;
	u16_t d_date;
	u8_t d_cluster0;
	u8_t d_cluster1;
	u8_t d_size0;
	u8_t d_size1;
	u8_t d_size2;
	u8_t d_size3;
};

#define DA_ISDIR	0x10

#if _WORD_SIZE == 2
#define CMAP_NO	129		/* [0..128] */
#else
#define CMAP_NO	513		/* [0..512] */
#endif

typedef struct ff
{
	int ff_init;
	int ff_dead;
	int ff_dev_task;
	int ff_dev_minor;
	u32_t ff_rtdir_start;
	u32_t ff_fat_start;
	u32_t ff_data_start;
	u32_t ff_img_size;
	u32_t ff_nr_clusters;
	u32_t ff_cluster_map[CMAP_NO];
	u32_t ff_map_step;
	u32_t ff_step_mask;
	u32_t ff_cache_pos;
	int ff_fat_bits;
	int ff_step_shift;
	unsigned ff_cluster_size;
	unsigned ff_cache_cluster;
	unsigned ff_rtdir_size;
	unsigned ff_open_ct;

	/* for driver.c */
	struct device ff_part[DEV_PER_DRIVE];
} ff_t;

#define MAX_DRIVES	2

static struct ff ff_table[MAX_DRIVES];

#define NR_DEVICES	(MAX_DRIVES * DEV_PER_DRIVE)

#define CACHE_NR	(2 * sizeof(char *))

static struct
{
	ff_t *c_device;
	u32_t c_sector;
	u8_t c_block[SECTOR_SIZE];
} cache[CACHE_NR];
static int cache_victim= 0;
static int fatfile_tasknr= ANY;
static int ff_drive;
static ff_t *ff_curr;
static struct device *ff_dv;

#define islower(c)	((unsigned) ((c) - 'a') <= (unsigned) ('z' - 'a'))
#define toupper(c)	((c) - 'a' + 'A')


_PROTOTYPE( static char *ff_name, (void)				);
_PROTOTYPE( static int ff_do_open, (struct driver *dp, message *m_ptr)	);
_PROTOTYPE( static int ff_do_close, (struct driver *dp, message *m_ptr)	);
_PROTOTYPE( static struct device *ff_prepare, (int device)		);
_PROTOTYPE( static int ff_transfer, (int proc_nr, int opcode,
			off_t position, iovec_t *iov, unsigned nr_req)	);
_PROTOTYPE( static void ff_geometry, (struct partition *entry)		);

_PROTOTYPE( static void init, (ff_t *ffp)				);
_PROTOTYPE( static int init_hd, (ff_t *ffp)				);
_PROTOTYPE( static u8_t *read_bytes, (ff_t *ffp, unsigned long pos,
							unsigned size)	);
_PROTOTYPE( static u16_t b2u16, (U8_t c0, U8_t c1)			);
_PROTOTYPE( static u32_t b2u32, (U8_t c0, U8_t c1, U8_t c2, U8_t c3)	);
_PROTOTYPE( static int dir_lookup, (ff_t *ffp, u8_t *name,
			unsigned long cluster, struct dirent *dirp)	);
_PROTOTYPE( static unsigned long next_cluster, (ff_t *ffp,
						unsigned long cluster)	);
_PROTOTYPE( static unsigned long cluster2block, (ff_t *ffp,
						unsigned long cluster)	);
_PROTOTYPE( static unsigned long img_cluster2block, (ff_t *ffp,
						unsigned long pos)	);
_PROTOTYPE( static int parse_env, (int drive, int *taskp, int *minorp,
							u8_t **namep)	);

static struct driver ff_dtab=
{
	ff_name,
	ff_do_open,
	ff_do_close,
	do_diocntl,
	ff_prepare,
	ff_transfer,
	nop_cleanup,
	ff_geometry,
};

void fatfile_task()
{
	fatfile_tasknr= proc_number(proc_ptr);
	driver_task(&ff_dtab);
}

static char *ff_name()
{
	static char name[]= "fatfile-d0";

	name[9]= '0' + ff_drive;
	return name;
}

static int ff_do_open(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
	if (ff_prepare(m_ptr->DEVICE) == NULL)
		return ENXIO;
	if (!ff_curr->ff_init)
		init(ff_curr);
	if (ff_curr->ff_dead)
		return ENXIO;
	if (ff_curr->ff_open_ct++ == 0)
	{
		partition(&ff_dtab, ff_drive*DEV_PER_DRIVE, P_PRIMARY);
	}
	return OK;
}

static int ff_do_close(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
	if (ff_prepare(m_ptr->DEVICE) == NULL)
		return ENXIO;
	ff_curr->ff_open_ct--;
	return OK;
}

static struct device *ff_prepare(device)
int device;
{
	if (device < NR_DEVICES)
	{
		ff_drive= device / DEV_PER_DRIVE;
		ff_curr= &ff_table[ff_drive];
		ff_dv= &ff_curr->ff_part[device % DEV_PER_DRIVE];
	}
	else
		return NULL;

	if (ff_curr->ff_dead)
		return NULL;
	return ff_dv;
}

/*
ff_transfer
*/
static int ff_transfer(proc_nr, opcode, position, iovec, nr_req)
int proc_nr;
int opcode;
off_t position;
iovec_t *iovec;
unsigned nr_req;
{
	iovec_t *request, *iovec_end= iovec + nr_req;
	unsigned long first_dev_pos, dev_pos, pos;
	int r;
	unsigned dev_nr_req;
	unsigned nbytes, count;
	unsigned dev_size;
	unsigned long dv_size;
	iovec_t iovec1;
	message m;

	while (nr_req > 0)
	{
		/* How many bytes to transfer? */
		nbytes= 0;
		for (request= iovec; request < iovec_end; request++)
			nbytes += request->iov_size;

		/* Handle partition translation. */
		dv_size = cv64ul(ff_dv->dv_size);
		pos = position;
		if (pos >= dv_size)
			return OK;
		if (pos + nbytes > dv_size)
			nbytes = dv_size - pos;
		pos += cv64ul(ff_dv->dv_base);
		if (pos >= ff_curr->ff_img_size)
			return EIO;
		if (pos + nbytes > ff_curr->ff_img_size)
			return EIO;

		/* How many bytes can be found in consecutive clusters? */
		count= 0;
		while (count < nbytes)
		{
			dev_pos= img_cluster2block(ff_curr, pos);
			if (count == 0)
			{
				first_dev_pos= dev_pos;
			}
			else
			{
				if (dev_pos != first_dev_pos + count)
					break;
			}
			dev_size= ff_curr->ff_cluster_size
					- (pos % ff_curr->ff_cluster_size);
			if (count + dev_size > nbytes)
				dev_size = nbytes - count;

			pos += dev_size;
			count += dev_size;
		}

		/* How many I/O requests can be executed on those clusters? */
		dev_nr_req= 0;
		request= iovec;
		while (count > 0)
		{
			if (count < request->iov_size)
				break;
			count -= request->iov_size;
			request++;
			dev_nr_req++;
		}

		if (dev_nr_req > 0)
		{
			/* Do those requests that can be done, then exit. */
			m.m_type= opcode;
			m.DEVICE= ff_curr->ff_dev_minor;
			m.PROC_NR= proc_nr;
			m.POSITION= first_dev_pos;
			m.ADDRESS= (char *) iovec;
			m.COUNT= dev_nr_req;
			r= sendrec(ff_curr->ff_dev_task, &m);
			assert(r == OK);

			/* EOF is checked here, so no half-baked results. */
			return iovec[0].iov_size == 0 ? OK : EIO;
		}

		/* The first request can only be partially executed. */
		iovec1.iov_addr= iovec[0].iov_addr;
		iovec1.iov_size= count;

		m.m_type= opcode;
		m.DEVICE= ff_curr->ff_dev_minor;
		m.PROC_NR= proc_nr;
		m.POSITION= first_dev_pos;
		m.ADDRESS= (char *) &iovec1;
		m.COUNT= 1;
		r= sendrec(ff_curr->ff_dev_task, &m);
		assert(r == OK);

		if (iovec1.iov_size != 0)
			return EIO;

		/* Book the partial I/O and try again with the updated list. */
		iovec[0].iov_addr+= count;
		iovec[0].iov_size-= count;
		position += count;
	}
	return OK;
}

static void ff_geometry(entry)
struct partition *entry;
{
	/* The number of sectors per track is chosen to match the cluster size
	 * to make it easy for people to place partitions on cluster boundaries.
	 */
	entry->cylinders= ff_curr->ff_img_size / ff_curr->ff_cluster_size / 64;
	entry->heads= 64;
	entry->sectors= ff_curr->ff_cluster_size >> SECTOR_SHIFT;
}

/*
init
*/
static void init(ffp)
ff_t *ffp;
{
	u8_t *cp, *name;
	struct bootsector *bp;
	struct dirent dirent;
	int i, r;
	unsigned long cluster;
	unsigned long off;

	unsigned rtdir_ents;
	unsigned bytespsec;
	unsigned long secspfat;
	unsigned long fatsize;
	unsigned secspclus;
	unsigned long nr_secs;
	unsigned long rtdir_cluster;
	unsigned long max_cluster;

	ffp->ff_init= 1;
	ffp->ff_dead= 1;

	if (parse_env(ff_drive, &ffp->ff_dev_task, &ffp->ff_dev_minor,
		&name) != OK)
	{
		return;
	}
	if (init_hd(ffp) != OK)
	{
		printf("%s: init_hd failed\n", ff_name());
		return;
	}
	cp= read_bytes(ffp, BOOT_POS, BOOT_SIZE);
	if (cp == NULL)
		return;
	bp= (struct bootsector *) cp;
	if (!B_MAGIC_OK(cp[B_MAGIC_POS], cp[B_MAGIC_POS + 1]))
	{
		printf("%s: magic AA55 not found\n", ff_name());
		return;
	}
	bytespsec= b2u16(bp->b_bytes_per_sector[0], bp->b_bytes_per_sector[1]);
	if (bp->b_nr_fats != 2)
	{
		printf("%s: strange number of fats: %d\n",
			ff_name(), bp->b_nr_fats);
		return;
	}
	ffp->ff_fat_bits= 12;	/* Assume 12, later correct to 16 or 32 */

	secspfat= b2u16(bp->b_sectors_per_fat16[0], bp->b_sectors_per_fat16[1]);
	if (secspfat == 0) {
		ffp->ff_fat_bits= 32;
		secspfat= b2u32(bp->b_sectors_per_fat32[0],
				bp->b_sectors_per_fat32[1],
				bp->b_sectors_per_fat32[2],
				bp->b_sectors_per_fat32[3]);
	}
	fatsize= secspfat * bytespsec;
	ffp->ff_fat_start= b2u16(bp->b_reserved[0],
				bp->b_reserved[1]) * bytespsec;
	rtdir_ents= b2u16(bp->b_rootdir_entries[0], bp->b_rootdir_entries[1]);
	ffp->ff_rtdir_size= rtdir_ents * sizeof(struct dirent);
	ffp->ff_rtdir_start= ffp->ff_fat_start + bp->b_nr_fats * fatsize;
	rtdir_cluster= b2u32(bp->b_rootdir_cluster[0],
				bp->b_rootdir_cluster[1],
				bp->b_rootdir_cluster[2],
				bp->b_rootdir_cluster[3]);
	secspclus= bp->b_sectors_per_cluster;
	nr_secs= b2u16(bp->b_nr_sectors16[0], bp->b_nr_sectors16[1]);
	if (nr_secs == 0)
	{
		nr_secs= b2u32(bp->b_nr_sectors32[0], bp->b_nr_sectors32[1],
				bp->b_nr_sectors32[2], bp->b_nr_sectors32[3]);
	}
	ffp->ff_nr_clusters= nr_secs / (secspclus == 0 ? 1 : secspclus);
	ffp->ff_cluster_size= bytespsec * secspclus;
	ffp->ff_data_start= ffp->ff_rtdir_start + ffp->ff_rtdir_size;
	if (ffp->ff_fat_bits == 12 && ffp->ff_nr_clusters > MAX_FAT12_CLUSTERS)
	{
		ffp->ff_fat_bits= 16;
	}
	max_cluster=
		((u32_t) -1 - ffp->ff_data_start) / ffp->ff_cluster_size + 2;
	if (ffp->ff_nr_clusters > max_cluster) {
		/* A filesystem > 4G?  I'm afraid we can't do that. */
		ffp->ff_nr_clusters= max_cluster;
	}

#if DEBUG
	printf("%s: os name is '%.8s'\n", ff_name(), bp->b_oem_name);
#endif

	if (ffp->ff_fat_bits <= 16) {
		cluster= 0;		/* Indicates root directory segment. */
	} else {
		cluster= rtdir_cluster;	/* FAT-32 root directory chain. */
	}

	for (;;)
	{
		cp= name;
		while (*cp == '\\' || *cp == '/') cp++;
		name= cp;
		while (*name != 0)
		{
			if (*name == '\\' || *name == '/')
			{
				*name++ = 0;
				break;
			}
			name++;
		}
		r= dir_lookup(ffp, cp, cluster, &dirent);
		if (r != OK)
			return;
		if (ffp->ff_fat_bits <= 16) {
			cluster= b2u16(dirent.d_cluster0, dirent.d_cluster1);
		} else {
			cluster= b2u32(dirent.d_cluster0, dirent.d_cluster1,
					dirent.d_cluster2, dirent.d_cluster3);
		}
		if (*name == 0)
			break;
		if (!(dirent.d_attr & DA_ISDIR))
		{
			printf("%s: '%s' is not a directory\n", ff_name(), cp);
			return;
		}
	}
	if (dirent.d_attr & DA_ISDIR)
	{
		printf("%s: '%s' is not a file\n", ff_name(), cp);
		return;
	}
	ffp->ff_img_size= b2u32(dirent.d_size0, dirent.d_size1, dirent.d_size2,
				dirent.d_size3);
	ffp->ff_map_step= ffp->ff_cluster_size;
	while (ffp->ff_map_step * (CMAP_NO-1) < ffp->ff_img_size)
		ffp->ff_map_step <<= 1;

	for (i= 0; (1L << i) < ffp->ff_map_step; i++)
		; /* no nothing */
	if ((1L << i) != ffp->ff_map_step)
	{
		printf("%s: ff_map_step (= %ld) is not a power of 2\n",
			ff_name(), ffp->ff_map_step);
		return;
	}
	ffp->ff_step_shift= i;
	ffp->ff_step_mask= ffp->ff_map_step-1;
	i= 0;
	for (off= 0; off < ffp->ff_img_size; off += ffp->ff_cluster_size)
	{
		if ((off & ffp->ff_step_mask) == 0)
		{
			ffp->ff_cluster_map[i++]= cluster;
		}
		if (cluster == 0)
		{
			printf("%s: cluster chain finishes early!\n",
				ff_name());
			return;
		}
		cluster= next_cluster(ffp, cluster);
	}
	ffp->ff_cache_pos= 0;
	ffp->ff_cache_cluster= ffp->ff_cluster_map[0];
	ffp->ff_dead= 0;
	ffp->ff_part[0].dv_size= cvul64(ffp->ff_img_size);
}

static int init_hd(ffp)
ff_t *ffp;
{
	message m;
	int r;

	m.m_type= DEV_OPEN;
	m.DEVICE= ffp->ff_dev_minor;
	m.PROC_NR= fatfile_tasknr;
	m.COUNT= R_BIT|W_BIT;
	r= sendrec(ffp->ff_dev_task, &m);
	assert (r == OK);
	r= m.REP_STATUS;
	if (r != OK)
	{
		printf("%s: dev_open failed: %d\n", ff_name(), r);
		return EIO;
	}
	return OK;
}

/*
read_bytes
*/
static u8_t *read_bytes(ffp, pos, size)
ff_t *ffp;
unsigned long pos;
unsigned size;
{
	message m;
	unsigned long sector;
	unsigned off;
	int i, r;
	iovec_t iovec1;

	sector= pos >> SECTOR_SHIFT;
	off= pos & SECTOR_MASK;
	assert(off+size <= SECTOR_SIZE);

	/* search the cache */
	for (i= 0; i<CACHE_NR; i++)
	{
		if (cache[i].c_device == ffp && cache[i].c_sector == sector)
			return cache[i].c_block + off;
	}

	i= cache_victim;
	if (++cache_victim == CACHE_NR)
		cache_victim= 0;

	cache[i].c_device= NULL;	/* in case of failures */
	iovec1.iov_addr= (vir_bytes)cache[i].c_block;
	iovec1.iov_size= SECTOR_SIZE;
	m.m_type= DEV_GATHER;
	m.DEVICE= ffp->ff_dev_minor;
	m.POSITION= sector << SECTOR_SHIFT;
	m.PROC_NR= fatfile_tasknr;
	m.ADDRESS= (char *) &iovec1;
	m.COUNT= 1;
	r= sendrec(ffp->ff_dev_task, &m);
	assert(r == OK);
	if (iovec1.iov_size != 0)
	{
		printf("%s: dev_read failed: %d\n", ff_name(), m.REP_STATUS);
		return NULL;
	}
	cache[i].c_device= ffp;
	cache[i].c_sector= sector;
	return cache[i].c_block+off;
}

static u16_t b2u16(c0, c1)
u8_t c0;
u8_t c1;
{
	return c0 | (c1 << 8);
}

static u32_t b2u32(c0, c1, c2, c3)
u8_t c0;
u8_t c1;
u8_t c2;
u8_t c3;
{
	return (u32_t)c0 | ((u32_t)c1 << 8)
		| ((u32_t)c2 << 16) | ((u32_t)c3 << 24);
}

/*
dir_lookup
*/
static int dir_lookup(ffp, name, cluster, dirp)
ff_t *ffp;
u8_t *name;
unsigned long cluster;
struct dirent *dirp;
{
	struct dirent *direntp;
	u8_t base[8], ext[3];
	int i;
	u8_t *cp;
	unsigned long offset;
	unsigned long cluster_block;
	unsigned off;

	cp= name;
	memset(base, ' ', 8);
	for (i= 0; *cp != '\0' && *cp != '.'; i++, cp++)
	{
		if (i >= 8)
			continue;
		if (islower(*cp))
			base[i]= toupper(*cp);
		else
			base[i]= *cp;
	}
	if (*cp == '.')
		cp++;
	memset(ext, ' ', 3);
	for (i= 0; *cp != '\0'; i++, cp++)
	{
		if (i >= 3)
			continue;
		if (islower(*cp))
			ext[i]= toupper(*cp);
		else
			ext[i]= *cp;
	}

	if (cluster == 0)
	{
		/* Root directory */
		offset= 0;
		while(offset < ffp->ff_rtdir_size)
		{
			cp= read_bytes(ffp, ffp->ff_rtdir_start + offset,
				SECTOR_SIZE);
			if (cp == NULL)
				return EIO;
			for (i= 0; i<SECTOR_SIZE && offset < ffp->ff_rtdir_size;
				i += sizeof(struct dirent))
			{
				direntp= (struct dirent *)&cp[i];
				if (memcmp(direntp->d_name, base, 8) == 0 &&
					memcmp(direntp->d_ext, ext, 3) == 0)
				{
					memcpy(dirp, cp+i,
						sizeof(struct dirent));
					return OK;
				}
				offset += sizeof(struct dirent);
			}
		}
	}
	else
	{
		/* Any sub directory */
		offset= 0;
		off= 0;
		cluster_block= cluster2block(ffp, cluster);
		for (;;)
		{
			cp= read_bytes(ffp, cluster_block + off, SECTOR_SIZE);
			if (cp == NULL)
				return EIO;
			for (i= 0; i<SECTOR_SIZE; i += sizeof(struct dirent))
			{
				direntp= (struct dirent *)&cp[i];
				if (memcmp(direntp->d_name, base, 8) == 0 &&
					memcmp(direntp->d_ext, ext, 3) == 0)
				{
					memcpy(dirp, cp+i,
						sizeof(struct dirent));
					return OK;
				}
				offset += sizeof(struct dirent);
			}
			off += SECTOR_SIZE;
			if (off >= ffp->ff_cluster_size)
			{
				cluster= next_cluster(ffp, cluster);
				off= 0;
				if (cluster == 0)
					break;
			}
		}
	}
	printf("%s: '%s' not found\n", ff_name(), name);
	return ENOENT;
}

/*
next_cluster
*/
static unsigned long next_cluster(ffp, cluster)
ff_t *ffp;
unsigned long cluster;
{
	unsigned long next;
	u8_t *pnext;

	switch (ffp->ff_fat_bits)
	{
	case 12:
		pnext= read_bytes(ffp, ffp->ff_fat_start +
			((unsigned) cluster * 3 / 2), 2);
		if (pnext == 0)
			return 0;
		next= b2u16(pnext[0], pnext[1]);

		if ((cluster & 1) == 0) {
			next &= 0xfff;
		} else {
			next >>= 4;
		}
		break;
	case 16:
		pnext= read_bytes(ffp, ffp->ff_fat_start +
			(cluster * 2), 2);
		if (pnext == 0)
			return 0;
		next= b2u16(pnext[0], pnext[1]);
		break;
	case 32:
		pnext= read_bytes(ffp, ffp->ff_fat_start +
			(cluster * 4), 4);
		if (pnext == 0)
			return 0;
		next= b2u32(pnext[0], pnext[1], pnext[2], pnext[3]);
		break;
	}
	return next < ffp->ff_nr_clusters ? next : 0;
}

static unsigned long cluster2block(ffp, cluster)
ff_t *ffp;
unsigned long cluster;
{
	return ffp->ff_data_start + (cluster-2) * ffp->ff_cluster_size;
}

static unsigned long img_cluster2block(ffp, pos)
ff_t *ffp;
unsigned long pos;
{
	unsigned long posbase, cachebase;
	int posindx;

	posbase= (pos & ~ffp->ff_step_mask);
	cachebase= (ffp->ff_cache_pos & ~ffp->ff_step_mask);
	if (posbase != cachebase || pos < ffp->ff_cache_pos)
	{
		posindx= posbase >> ffp->ff_step_shift;
		ffp->ff_cache_pos= posbase;
		ffp->ff_cache_cluster= ffp->ff_cluster_map[posindx];
	}
	while (ffp->ff_cache_pos + ffp->ff_cluster_size <= pos)
	{
		ffp->ff_cache_pos += ffp->ff_cluster_size;
		ffp->ff_cache_cluster= next_cluster(ffp, ffp->ff_cache_cluster);
		assert(ffp->ff_cache_cluster != 0);
	}
	assert(pos-ffp->ff_cache_pos < ffp->ff_cluster_size);
	return cluster2block(ffp, ffp->ff_cache_cluster)+
		pos-ffp->ff_cache_pos;
}

static int parse_env(drive, taskp, minorp, namep)
int drive;
int *taskp;
int *minorp;
u8_t **namep;
{
	static char namebuf[256];

	char *env_var, *env_val;
	char *cp, *check, *taskname;
	int ok, task;
	unsigned long minor;

	env_var= ff_name();
	env_val= getenv(env_var);
	if (env_val == NULL)
	{
		printf("%s: no environment variable '%s'\n",
			ff_name(), env_var);
		return ESRCH;
	}

	cp= env_val;
	ok= (cp= strchr(cp, ':')) != NULL;
	if (ok) {
		*cp= 0;
		for (task= -NR_TASKS; task < 0; task++) {
			if (strcmp(env_val, tasktab[task+NR_TASKS].name) == 0)
				break;
		}
		*cp++= ':';
		if (task == 0) {
			printf("%s: driver named in '%s' is not available\n",
				ff_name(), env_val);
			return EINVAL;
		}
	}
	if (ok) {
		minor= strtoul(cp, &check, 0);
		if (minor >= 256) {
			printf(
			"%s: minor device number in '%s' is out of range\n",
				ff_name(), env_val);
			return EINVAL;
		}
		if (check == cp || *check != ':') ok= 0;
		cp= check+1;
	}

	if (!ok)
	{
		printf("%s: unable to parse '%s'\n", ff_name(), env_val);
		return EINVAL;
	}
	if (strlen(cp) > sizeof(namebuf)-1)
	{
		printf("%s: file name too long in '%s'\n", ff_name(), env_val);
		return EINVAL;
	}
	strcpy(namebuf, cp);
	*taskp= task;
	*minorp= minor;
	*namep= (u8_t *) namebuf;
	printf("%s: using %s\n", ff_name(), env_val);
	return OK;
}
#endif /* ENABLE_FATFILE */
