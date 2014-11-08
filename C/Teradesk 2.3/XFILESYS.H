/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#define DP_PATHMAX	2
#define DP_NAMEMAX	3

/* TOS file attributen */

#define FA_READONLY     0x01
#define FA_HIDDEN       0x02
#define FA_SYSTEM       0x04
#define FA_VOLUME       0x08
#define FA_SUBDIR       0x10
#define FA_ARCHIVE      0x20
#define FA_PARDIR       0x40 /* DjV 004 300103 */

/* Unix file attributen */

#define S_IFMT	0170000
#define S_IFREG	0100000		/* Regular file */
#define S_IFDIR	0040000		/* Directory */
#define S_IFCHR	0020000		/* BIOS special file */
#define S_IFIFO 0120000		/* FIFO */
#define S_IMEM	0140000		/* memory region or process */
#define S_IFLNK	0160000		/* symbolic link */

#define S_IRUSR	0400
#define S_IWUSR 0200
#define S_IXUSR 0100
#define S_IRGRP 0040
#define S_IWGRP	0020
#define S_IXGRP	0010
#define S_IROTH	0004
#define S_IWOTH	0002
#define S_IXOTH	0001

/* Modes voor x_exist */

#define EX_FILE		1
#define EX_DIR		2

/* Modes voor x_open en x_fopen */

#define O_RWMODE  	0x03		/* isoleert read write mode */
#define O_RDONLY	0x00
#define O_WRONLY	0x01
#define O_RDWR		0x02

#define O_SHMODE	0x70		/* isoleert file sharing mode */
#define O_COMPAT	0x00
#define O_DENYRW	0x10
#define O_DENYW		0x20
#define O_DENYR		0x30
#define O_DENYNONE	0x40

enum
{
	DP_NOTRUNC,
	DP_AUTOTRUNC,
	DP_DOSTRUNC,
	DP_SENITIVE   = 0,
	DP_NOSENSITIVE,
	DP_SAVE_ONLY,
	DP_TRUNC      = 5,
	DP_CASE
};

#ifndef __TOS

typedef struct
{
	unsigned char length;
	char command_tail[128];
} COMMAND;

typedef struct
{
	unsigned long b_free;
	unsigned long b_total;
	unsigned long b_secsiz;
	unsigned long b_clsiz;
} DISKINFO;

typedef struct
{
	int time;
	int date;
} DOSTIME;

typedef struct
{
	char d_reserved[21];
	unsigned char d_attrib;
	int d_time;
	int d_date;
	unsigned long d_length;
	char d_fname[14];
} DTA;

#endif

typedef struct
{
	char *path;
	union
	{
		long handle;
		struct
		{
			int first;			/* 1 = eerste file lezen, 0 = huidige lezen. */
			DTA *old_dta;
			DTA dta;
		} gdata;
	} data;
#if _MINT_
	int type;
#endif
} XDIR;

typedef struct
{
	int handle;
	int mode;
	int bufsize;
	int read;
	int write;
	char *buffer;
	unsigned int eof : 1;
	unsigned int memfile : 1;
} XFILE;

/* niet GEMDOS en MiNT funkties */

int x_checkname(const char *path, const char *name);
char *x_makepath(const char *path, const char *name, int *error);
boolean x_exist(const char *file, int flags);
char *x_fullname(const char *file, int *error);

/* Directory funkties */

int x_setpath(const char *path);
char *x_getpath(int drive, int *error);
int x_mkdir(const char *path);
int x_rmdir(const char *path);
int x_dfree(DISKINFO *diskinfo, int drive);
int x_getdrv(void);
long x_setdrv(int drive);
int x_getlabel(int drive, char *label);

/* File funkties */

int x_rename(const char *oldname, const char *newname);
int x_unlink(const char *file);
int x_fattrib(const char *file, int wflag, int attrib);
int x_datime(DOSTIME *time, int handle, int wflag);

int x_open(const char *file, int mode);
int x_create(const char *file, int attr);
int x_close(int handle);
long x_read(int handle, long count, char *buf);
long x_write(int handle, long count, char *buf);
long x_seek(long offset, int handle, int seekmode);

/* Funkties voor het lezen van een directory */

XDIR *x_opendir(const char *path, int *error);
long x_xreaddir(XDIR *dir, char *buffer, int len, XATTR *attrib);
long x_rewinddir(XDIR *dir);
long x_closedir(XDIR *dir);
long x_attr(int flag, const char *name, XATTR *attrib);

/* Configuratie funkties */

long x_pathconf(const char *path, int which);

/* Funkties voor het uitvoeren van programma's */

long x_exec(int mode, void *ptr1, void *ptr2, void *ptr3);

/* Geheugen funkties */

void *x_alloc(long amount);
int x_free(void *block);
int x_shrink(void *block, long newsize);

/* GEM funkties */

char *xshel_find(const char *file, int *error);
char *xfileselector(const char *path, char *name, const char *label);

/* Vervangers voor de standaard bibliotheek. */

XFILE *x_fopen(const char *file, int mode, int *error);
XFILE *x_fmemopen(int mode, int *error);
int x_fclose(XFILE *file);
long x_fread(XFILE *file, void *ptr, long length);
long x_fwrite(XFILE *file, void *ptr, long length);
long x_fseek(XFILE *file, long offset, int mode);
char *x_freadstr(XFILE *file, char *string, size_t max, int *error);
int x_fwritestr(XFILE *file, const char *string);
int x_fgets(XFILE *file, char *string, int n);
boolean x_feof(XFILE *file);
boolean x_inq_xfs(const char *path, boolean *casesens);		/* HR 151102 */

void x_init(void);
