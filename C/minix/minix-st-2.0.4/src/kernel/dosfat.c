/*
dosfat.c

Created:	Feb 24, 1994 by Philip Homburg <philip@cs.vu.nl>
*/

#include "kernel.h"
#include "driver.h"
#include "drvlib.h"
#if ENABLE_DOSFAT
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

typedef struct dd
{
	int dd_init;
	int dd_dead;
	int dd_dev_task;
	int dd_dev_minor;
	u32_t dd_rtdir_start;
	u32_t dd_fat_start;
	u32_t dd_data_start;
	u32_t dd_img_size;
	u32_t dd_nr_clusters;
	u32_t dd_cluster_map[CMAP_NO];
	u32_t dd_map_step;
	u32_t dd_step_mask;
	u32_t dd_cache_pos;
	int dd_fat_bits;
	int dd_step_shift;
	unsigned dd_cluster_size;
	unsigned dd_cache_cluster;
	unsigned dd_rtdir_size;
	unsigned dd_open_ct;

	/* for driver.c */
	struct device dd_part[DEV_PER_DRIVE];
} dd_t;

#define MAX_DRIVES	2

static struct dd dd_table[MAX_DRIVES];

#define NR_DEVICES	(MAX_DRIVES * DEV_PER_DRIVE)

#define CACHE_NR	(2 * sizeof(char *))

static struct
{
	dd_t *c_device;
	u32_t c_sector;
	u8_t c_block[SECTOR_SIZE];
} cache[CACHE_NR];
static int cache_victim= 0;
static int dosfat_tasknr= ANY;
static int dd_drive;
static dd_t *dd_curr;
static struct device *dd_dv;

#define NRVECS	32
static struct iorequest_s iotab[NRVECS];
struct
{
	struct iorequest_s *req_orig;
	size_t orig_size;
} ioextra[NRVECS];
static int iovec_indx= 0;
static int io_proc_nr;
static struct iorequest_s dd_iotab[NR_IOREQS];

#define islower(c)	((unsigned) ((c) - 'a') <= (unsigned) ('z' - 'a'))
#define toupper(c)	((c) - 'a' + 'A')


_PROTOTYPE( static char *dd_name, (void)				);
_PROTOTYPE( static int dd_do_open, (struct driver *dp, message *m_ptr)	);
_PROTOTYPE( static int dd_do_close, (struct driver *dp, message *m_ptr)	);
_PROTOTYPE( static struct device *dd_prepare, (int device)		);
_PROTOTYPE( static int dd_schedule, (int proc_nr,
					struct iorequest_s *request)	);
_PROTOTYPE( static int dd_finish, (void)				);
_PROTOTYPE( static void dd_geometry, (struct partition *entry)		);

_PROTOTYPE( static void init, (dd_t *ddp)				);
_PROTOTYPE( static int init_hd, (dd_t *ddp)				);
_PROTOTYPE( static u8_t *read_bytes, (dd_t *ddp, unsigned long pos,
							unsigned size)	);
_PROTOTYPE( static u16_t b2u16, (U8_t c0, U8_t c1)			);
_PROTOTYPE( static u32_t b2u32, (U8_t c0, U8_t c1, U8_t c2, U8_t c3)	);
_PROTOTYPE( static int dir_lookup, (dd_t *ddp, u8_t *name,
			unsigned long cluster, struct dirent *dirp)	);
_PROTOTYPE( static unsigned long next_cluster, (dd_t *ddp,
						unsigned long cluster)	);
_PROTOTYPE( static unsigned long cluster2block, (dd_t *ddp,
						unsigned long cluster)	);
_PROTOTYPE( static unsigned long img_cluster2block, (dd_t *ddp,
						unsigned long pos)	);
_PROTOTYPE( static int parse_env, (int drive, int *taskp, int *minorp,
							u8_t **namep)	);

static struct driver dd_dtab=
{
	dd_name,
	dd_do_open,
	dd_do_close,
	do_diocntl,
	dd_prepare,
	dd_schedule,
	dd_finish,
	nop_cleanup,
	dd_geometry,
};

void dosfat_task()
{
	int i;

	dosfat_tasknr= proc_number(proc_ptr);

	for (i= 0; i<MAX_DRIVES; i++)
		dd_table[i].dd_init= 0;
	driver_task(&dd_dtab);
}

static char *dd_name()
{
	static char name[]= "dosd4";

	name[4]= '0' + dd_drive * DEV_PER_DRIVE;
	return name;
}

static int dd_do_open(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
	if (dd_prepare(m_ptr->DEVICE) == NULL)
		return ENXIO;
	if (!dd_curr->dd_init)
		init(dd_curr);
	if (dd_curr->dd_dead)
		return ENXIO;
	if (dd_curr->dd_open_ct++ == 0)
	{
		partition(&dd_dtab, dd_drive*DEV_PER_DRIVE, P_PRIMARY);
	}
	return OK;
}

static int dd_do_close(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
	if (dd_prepare(m_ptr->DEVICE) == NULL)
		return ENXIO;
	dd_curr->dd_open_ct--;
	return OK;
}

static struct device *dd_prepare(device)
int device;
{
	if (device < NR_DEVICES)
	{
		dd_drive= device / DEV_PER_DRIVE;
		dd_curr= &dd_table[dd_drive];
		dd_dv= &dd_curr->dd_part[device % DEV_PER_DRIVE];
	}
	else
		return NULL;

	if (dd_curr->dd_dead)
		return NULL;
	return dd_dv;
}

/*
dd_schedule
*/
static int dd_schedule(proc_nr, request)
int proc_nr;
struct iorequest_s *request;
{
	int r;
	unsigned long prev_pos, pos, newpos;
	unsigned prev_size, size, worksize;
	char *prev_buf, *buf;

	io_proc_nr= proc_nr;

	size= request->io_nbytes;
	pos= request->io_position;
	buf= request->io_buf;

	if (pos >= dd_dv->dv_size)
		return OK;		/* At EOF */
	if (pos + size > dd_dv->dv_size)
		size = dd_dv->dv_size - pos;
	pos += dd_dv->dv_base;

	prev_size= 0;
	prev_pos= 0;
	prev_buf= 0;
	while (size)
	{
		if (pos >= dd_curr->dd_img_size)
			break;
		if (pos & SECTOR_MASK)
			break;
		worksize= ((pos + dd_curr->dd_cluster_size) &
			~(dd_curr->dd_cluster_size-1)) - pos;
		if (worksize > dd_curr->dd_img_size-pos)
			worksize= dd_curr->dd_img_size-pos;
		if (worksize > size)
			worksize= size;
		if (worksize & SECTOR_MASK)
			break;
		newpos= img_cluster2block(dd_curr, pos);
		if (prev_size == 0)
		{
			prev_size= worksize;
			prev_pos= newpos;
			prev_buf= buf;
		}
		else if (newpos == prev_pos + prev_size)
		{
			/* Chain pieces */
			prev_size += worksize;
		}
		else
		{
			iotab[iovec_indx].io_position= prev_pos;
			iotab[iovec_indx].io_buf= prev_buf;
			iotab[iovec_indx].io_nbytes= prev_size;
			iotab[iovec_indx].io_request= request->io_request;
			ioextra[iovec_indx].req_orig= request;
			ioextra[iovec_indx].orig_size= prev_size;
			iovec_indx++;
			if (iovec_indx == NRVECS)
			{
				r= dd_finish();
				if (r != OK)
					return r;
			}
			prev_size= worksize;
			prev_pos= newpos;
			prev_buf= buf;
		}
		pos += worksize;
		buf += worksize;
		size -= worksize;
	}
	if (prev_size != 0)
	{
		iotab[iovec_indx].io_position= prev_pos;
		iotab[iovec_indx].io_buf= prev_buf;
		iotab[iovec_indx].io_nbytes= prev_size;
		iotab[iovec_indx].io_request= request->io_request;
		ioextra[iovec_indx].req_orig= request;
		ioextra[iovec_indx].orig_size= prev_size;
		iovec_indx++;
		if (iovec_indx == NRVECS)
		{
			r= dd_finish();
			if (r != OK)
				return r;
		}
	}
	return OK;
}

/*
dd_finish
*/
static int dd_finish()
{
	message m;
	int i, r;

	if (iovec_indx == 0)
		return OK;


	m.m_type= SCATTERED_IO;
	m.DEVICE= dd_curr->dd_dev_minor;
	m.PROC_NR= io_proc_nr;
	m.COUNT= iovec_indx;
	m.ADDRESS= (char *) iotab;
	r= sendrec(dd_curr->dd_dev_task, &m);
	assert(r == OK);
	if (m.REP_STATUS != OK)
	{
		assert(m.REP_STATUS < 0);
		iovec_indx= 0;
		return m.REP_STATUS;
	}

	for (i= 0; i<iovec_indx; i++)
	{
		if (ioextra[i].req_orig->io_nbytes < 0)
			continue;	/* Already got an error */
		if (iotab[i].io_nbytes < 0)
		{
			ioextra[i].req_orig->io_nbytes= iotab[i].io_nbytes;
			continue;
		}
		assert(ioextra[i].orig_size >= iotab[i].io_nbytes);
		ioextra[i].req_orig->io_nbytes -= (ioextra[i].orig_size -
			iotab[i].io_nbytes);
		assert(ioextra[i].req_orig->io_nbytes >= 0);
	}
	iovec_indx= 0;
	return OK;
}

static void dd_geometry(entry)
struct partition *entry;
{
	/* The number of sectors per track is chosen to match the cluster size
	 * to make it easy for people to place partitions on cluster boundaries.
	 */
	entry->cylinders= dd_curr->dd_img_size / dd_curr->dd_cluster_size / 64;
	entry->heads= 64;
	entry->sectors= dd_curr->dd_cluster_size >> SECTOR_SHIFT;
}

/*
init
*/
static void init(ddp)
dd_t *ddp;
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

	ddp->dd_init= 1;
	ddp->dd_dead= 1;

	if (parse_env(dd_drive, &ddp->dd_dev_task, &ddp->dd_dev_minor,
		&name) != OK)
	{
		return;
	}
	if (init_hd(ddp) != OK)
	{
		printf("%s: init_hd failed\n", dd_name());
		return;
	}
	cp= read_bytes(ddp, BOOT_POS, BOOT_SIZE);
	if (cp == NULL)
		return;
	bp= (struct bootsector *) cp;
	if (!B_MAGIC_OK(cp[B_MAGIC_POS], cp[B_MAGIC_POS + 1]))
	{
		printf("%s: magic AA55 not found\n", dd_name());
		return;
	}
	bytespsec= b2u16(bp->b_bytes_per_sector[0], bp->b_bytes_per_sector[1]);
	if (bp->b_nr_fats != 2)
	{
		printf("%s: strange number of fats: %d\n",
			dd_name(), bp->b_nr_fats);
		return;
	}
	ddp->dd_fat_bits= 12;	/* Assume 12, later correct to 16 or 32 */

	secspfat= b2u16(bp->b_sectors_per_fat16[0], bp->b_sectors_per_fat16[1]);
	if (secspfat == 0) {
		ddp->dd_fat_bits= 32;
		secspfat= b2u32(bp->b_sectors_per_fat32[0],
				bp->b_sectors_per_fat32[1],
				bp->b_sectors_per_fat32[2],
				bp->b_sectors_per_fat32[3]);
	}
	fatsize= secspfat * bytespsec;
	ddp->dd_fat_start= b2u16(bp->b_reserved[0],
				bp->b_reserved[1]) * bytespsec;
	rtdir_ents= b2u16(bp->b_rootdir_entries[0], bp->b_rootdir_entries[1]);
	ddp->dd_rtdir_size= rtdir_ents * sizeof(struct dirent);
	ddp->dd_rtdir_start= ddp->dd_fat_start + bp->b_nr_fats * fatsize;
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
	ddp->dd_nr_clusters= nr_secs / (secspclus == 0 ? 1 : secspclus);
	ddp->dd_cluster_size= bytespsec * secspclus;
	ddp->dd_data_start= ddp->dd_rtdir_start + ddp->dd_rtdir_size;
	if (ddp->dd_fat_bits == 12 && ddp->dd_nr_clusters > MAX_FAT12_CLUSTERS)
	{
		ddp->dd_fat_bits= 16;
	}
	max_cluster=
		((u32_t) -1 - ddp->dd_data_start) / ddp->dd_cluster_size + 2;
	if (ddp->dd_nr_clusters > max_cluster) {
		/* A filesystem > 4G?  I'm afraid we can't do that. */
		ddp->dd_nr_clusters= max_cluster;
	}

#if DEBUG
	printf("%s: os name is '%.8s'\n", dd_name(), bp->oem_name);
#endif

	if (ddp->dd_fat_bits <= 16) {
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
		r= dir_lookup(ddp, cp, cluster, &dirent);
		if (r != OK)
			return;
		if (ddp->dd_fat_bits <= 16) {
			cluster= b2u16(dirent.d_cluster0, dirent.d_cluster1);
		} else {
			cluster= b2u32(dirent.d_cluster0, dirent.d_cluster1,
					dirent.d_cluster2, dirent.d_cluster3);
		}
		if (*name == 0)
			break;
		if (!(dirent.d_attr & DA_ISDIR))
		{
			printf("%s: '%s' is not a directory\n", dd_name(), cp);
			return;
		}
	}
	if (dirent.d_attr & DA_ISDIR)
	{
		printf("%s: '%s' is not a file\n", dd_name(), cp);
		return;
	}
	ddp->dd_img_size= b2u32(dirent.d_size0, dirent.d_size1, dirent.d_size2,
				dirent.d_size3);
	ddp->dd_map_step= ddp->dd_cluster_size;
	while (ddp->dd_map_step * (CMAP_NO-1) < ddp->dd_img_size)
		ddp->dd_map_step <<= 1;

	for (i= 0; (1L << i) < ddp->dd_map_step; i++)
		; /* no nothing */
	if ((1L << i) != ddp->dd_map_step)
	{
		printf("%s: dd_map_step (= %ld) is not a power of 2\n",
			dd_name(), ddp->dd_map_step);
		return;
	}
	ddp->dd_step_shift= i;
	ddp->dd_step_mask= ddp->dd_map_step-1;
	i= 0;
	for (off= 0; off < ddp->dd_img_size; off += ddp->dd_cluster_size)
	{
		if ((off & ddp->dd_step_mask) == 0)
		{
			ddp->dd_cluster_map[i++]= cluster;
		}
		if (cluster == 0)
		{
			printf("%s: cluster chain finishes early!\n",
				dd_name());
			return;
		}
		cluster= next_cluster(ddp, cluster);
	}
	ddp->dd_cache_pos= 0;
	ddp->dd_cache_cluster= ddp->dd_cluster_map[0];
	ddp->dd_dead= 0;
	ddp->dd_part[0].dv_size= ddp->dd_img_size;
}

static int init_hd(ddp)
dd_t *ddp;
{
	message m;
	int r;

	m.m_type= DEV_OPEN;
	m.DEVICE= ddp->dd_dev_minor;
	m.PROC_NR= dosfat_tasknr;
	m.COUNT= R_BIT|W_BIT;
	r= sendrec(ddp->dd_dev_task, &m);
	assert (r == OK);
	r= m.REP_STATUS;
	if (r != OK)
	{
		printf("%s: dev_open failed: %d\n", dd_name(), r);
		return EIO;
	}
	return OK;
}

/*
read_bytes
*/
static u8_t *read_bytes(ddp, pos, size)
dd_t *ddp;
unsigned long pos;
unsigned size;
{
	message m;
	unsigned long sector;
	unsigned off;
	int i, r;

	sector= pos >> SECTOR_SHIFT;
	off= pos & SECTOR_MASK;
	assert(off+size <= SECTOR_SIZE);

	/* search the cache */
	for (i= 0; i<CACHE_NR; i++)
	{
		if (cache[i].c_device == ddp && cache[i].c_sector == sector)
			return cache[i].c_block + off;
	}

	i= cache_victim;
	if (++cache_victim == CACHE_NR)
		cache_victim= 0;

	cache[i].c_device= NULL;	/* in case of failures */
	m.m_type= DEV_READ;
	m.DEVICE= ddp->dd_dev_minor;
	m.POSITION= sector << SECTOR_SHIFT;
	m.PROC_NR= dosfat_tasknr;
	m.ADDRESS= (char *) cache[i].c_block;
	m.COUNT= SECTOR_SIZE;
	r= sendrec(ddp->dd_dev_task, &m);
	assert(r == OK);
	r= m.REP_STATUS;
	if (r != SECTOR_SIZE)
	{
		printf("%s: dev_read failed: %d\n", dd_name(), r);
		return NULL;
	}
	cache[i].c_device= ddp;
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
static int dir_lookup(ddp, name, cluster, dirp)
dd_t *ddp;
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
		while(offset < ddp->dd_rtdir_size)
		{
			cp= read_bytes(ddp, ddp->dd_rtdir_start + offset,
				SECTOR_SIZE);
			if (cp == NULL)
				return EIO;
			for (i= 0; i<SECTOR_SIZE && offset < ddp->dd_rtdir_size;
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
		cluster_block= cluster2block(ddp, cluster);
		for (;;)
		{
			cp= read_bytes(ddp, cluster_block + off, SECTOR_SIZE);
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
			if (off >= ddp->dd_cluster_size)
			{
				cluster= next_cluster(ddp, cluster);
				off= 0;
				if (cluster == 0)
					break;
			}
		}
	}
	printf("%s: '%s' not found\n", dd_name(), name);
	return ENOENT;
}

/*
next_cluster
*/
static unsigned long next_cluster(ddp, cluster)
dd_t *ddp;
unsigned long cluster;
{
	unsigned long next;
	u8_t *pnext;

	switch (ddp->dd_fat_bits)
	{
	case 12:
		pnext= read_bytes(ddp, ddp->dd_fat_start +
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
		pnext= read_bytes(ddp, ddp->dd_fat_start +
			((unsigned) cluster * 2), 2);
		if (pnext == 0)
			return 0;
		next= b2u16(pnext[0], pnext[1]);
		break;
	case 32:
		pnext= read_bytes(ddp, ddp->dd_fat_start +
			(cluster * 4), 4);
		if (pnext == 0)
			return 0;
		next= b2u32(pnext[0], pnext[1], pnext[2], pnext[3]);
		break;
	}
	return next < ddp->dd_nr_clusters ? next : 0;
}

static unsigned long cluster2block(ddp, cluster)
dd_t *ddp;
unsigned long cluster;
{
	return ddp->dd_data_start + (cluster-2) * ddp->dd_cluster_size;
}

static unsigned long img_cluster2block(ddp, pos)
dd_t *ddp;
unsigned long pos;
{
	unsigned long posbase, cachebase;
	int posindx;

	posbase= (pos & ~ddp->dd_step_mask);
	cachebase= (ddp->dd_cache_pos & ~ddp->dd_step_mask);
	if (posbase != cachebase || pos < ddp->dd_cache_pos)
	{
		posindx= posbase >> ddp->dd_step_shift;
		ddp->dd_cache_pos= posbase;
		ddp->dd_cache_cluster= ddp->dd_cluster_map[posindx];
	}
	while (ddp->dd_cache_pos + ddp->dd_cluster_size <= pos)
	{
		ddp->dd_cache_pos += ddp->dd_cluster_size;
		ddp->dd_cache_cluster= next_cluster(ddp, ddp->dd_cache_cluster);
		assert(ddp->dd_cache_cluster != 0);
	}
	assert(pos-ddp->dd_cache_pos < ddp->dd_cluster_size);
	return cluster2block(ddp, ddp->dd_cache_cluster)+
		pos-ddp->dd_cache_pos;
}

static int parse_env(drive, taskp, minorp, namep)
int drive;
int *taskp;
int *minorp;
u8_t **namep;
{
	static char namebuf[256];

	char *env_var;
	char *cp, *op, *check;
	int taskno, ok;
	unsigned long nr;
	unsigned minor;

	env_var= dd_name();
	cp= k_getenv(env_var);
	if (cp == NULL)
	{
		printf("%s: no environment variable '%s'\n",
			dd_name(), env_var);
		return ESRCH;
	}
	printf("%s: using %s\n", dd_name(), cp);
	op= cp;
	ok= 1;
	switch (cp[0])
	{
#if ENABLE_WINI
	case 'h':	taskno= WINCHESTER;	break;
#endif
#if ENABLE_SCSI
	case 's':	taskno= SCSI;		break;
#endif
	case 'f':	taskno= FLOPPY;		break;
	default:	ok= 0;
	}
	if (ok) {
		if (cp[1] != 'd') ok= 0;
	}
	if (ok) {
		cp += 2;
		nr= strtoul(cp, &check, 0);
		if (nr >= 8 * (NR_PARTITIONS+1) || check == cp) ok= 0;
	}
	if (ok) {
		cp= check;
		minor= nr;
		if (op[0] != 'f' && (unsigned) (*cp - 'a') < NR_PARTITIONS) {
			unsigned d= minor / (1 + NR_PARTITIONS);
			unsigned p= (minor % (1 + NR_PARTITIONS)) - 1;
			minor= MINOR_hd1a
				+ (d * NR_PARTITIONS + p) * NR_PARTITIONS
				+ *cp - 'a';
			cp++;
		}
	}

	if (!ok || *cp++ != ':')
	{
		printf("%s: unable to parse '%s'\n", dd_name(), op);
		return EINVAL;
	}
	if (strlen(cp) > sizeof(namebuf)-1)
	{
		printf("%s: name too long '%s'\n", dd_name(), cp);
		return EINVAL;
	}
	strcpy(namebuf, cp);
	*taskp= taskno;
	*minorp= minor;
	*namep= (u8_t *) namebuf;
	return OK;
}
#endif /* ENABLE_DOSFAT */
