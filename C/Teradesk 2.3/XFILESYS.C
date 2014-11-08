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

#include <np_aes.h>			/* HR 151102: modern */
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <boolean.h>
#include <library.h>
#include <mint.h>

#include "desk.h"
#include "error.h"
#include "desktop.h"			/* HR 151102: only 1 rsc */
#include "xfilesys.h"

#define XBUFSIZE	2048L
#define USE_gemdos 1

/* long maxpath = 128; */ /* HR 240203 */
static boolean flock;

int x_checkname(const char *path, const char *name)
{
	if (strlen(name) > x_pathconf(path, DP_NAMEMAX))
		return EFNTL;

	if (strlen(path) + strlen(name) + 2L > x_pathconf(path, DP_PATHMAX))
		return EPTHTL;

	return 0;
}

char *x_makepath(const char *path, const char *name, int *error)
{
	char *p;

	if ((p = malloc(strlen(path) + strlen(name) + 2L)) != NULL)
	{
		*error = 0;
		make_path(p, (char *) path, (char *) name);
	}
	else
		*error = ENSMEM;

	return p;
}

boolean x_exist(const char *file, int flags)
{
	XATTR attr;

	if (x_attr(0, file, &attr) != 0)
		return FALSE;
	else
	{
		if (((attr.mode & S_IFMT) == S_IFDIR) && ((flags & EX_DIR) == 0))
			return FALSE;
		else
		{
			if (((attr.mode & S_IFMT) != S_IFDIR) && ((flags & EX_FILE) == 0))
				return FALSE;
		}
		return TRUE;
	}
}

static int _fullname(char *buffer)
{
	char *name, *h, *d, *s;
	int error;

	if ((name = strdup(buffer)) == NULL)
		error = ENSMEM;
	else
	{
		d = buffer;

		if ((h = strchr(name, ':')) == NULL)
		{
			*d++ = (char) (x_getdrv() + 'A');
			*d++ = ':';
			h = name;
		}
		else
		{
			h++;
			s = name;
			while (s != h)
				*d++ = *s++;
		}

		if (*h == '\\')
		{
			strcpy(d, h);
			error = 0;
		}
		else
		{
#if USE_gemdos
			if ((error = xerror((int) gemdos(71, d, (int) (buffer[0] - 'A' + 1)))) == 0)
#else
			if ((error = xerror(Dgetpath(d, buffer[0] - 'A' + 1))) == 0)
#endif
				make_path(buffer, buffer, h);
		}
		free(name);
	}
	return error;
}

char *x_fullname(const char *file, int *error)
{
	char *buffer, *h;

	if ((buffer = malloc(sizeof(LNAME))) == NULL)			/* HR 240203 */
	{
		*error = ENSMEM;
		return NULL;
	}

	strcpy(buffer, file);

	if ((*error = _fullname(buffer)) != 0)
	{
		free(buffer);
		return NULL;
	}

	h = realloc(buffer, strlen(buffer) + 1);

	return (h == NULL) ? buffer : h;
}

/* Funkties voor directories */

int x_setpath(const char *path)
{
#if USE_gemdos
	return xerror((int) gemdos(59, path));
#else
	return xerror(Dsetpath(path));
#endif
}

char *x_getpath(int drive, int *error)
{
	char *buffer, *h;

	if ((buffer = malloc(sizeof(LNAME))) == NULL)			/* HR 240203 */
	{
		*error = ENSMEM;
		return NULL;
	}

	buffer[0] = (char) (((drive == 0) ? x_getdrv(): (drive - 1)) + 'A');
	buffer[1] = ':';

#if USE_gemdos
	if ((*error = xerror((int) gemdos(71, buffer + 2, drive))) < 0)
#else
	if ((*error = xerror(Dgetpath(buffer + 2, drive))) < 0)
#endif
	{
		free(buffer);
		return NULL;
	}

	h = realloc(buffer, strlen(buffer) + 1);

	return (h == NULL) ? buffer : h;
}

int x_mkdir(const char *path)
{
#if USE_gemdos
	return xerror((int) gemdos(57, path));
#else
	return xerror(Dcreate(path));
#endif
}

int x_rmdir(const char *path)
{
#if USE_gemdos
	return xerror((int) gemdos(58, path));
#else
	return xerror(Ddelete(path));
#endif
}

int x_dfree(DISKINFO *diskinfo, int drive)
{
#if USE_gemdos
	return xerror((int) gemdos(54, diskinfo, drive));
#else
	return xerror(Dfree(diskinfo, drive));
#endif
}

int x_getdrv(void)
{
#if USE_gemdos
	return (int) gemdos(25);
#else
	return Dgetdrv();
#endif
}

long x_setdrv(int drive)
{
#if USE_gemdos
	return gemdos(14, drive);
#else
	return Dsetdrv(drive);
#endif
}

int x_getlabel(int drive, char *label)
{
	DTA *olddta, dta;
	int error;
	char path[10];

#if USE_gemdos
	olddta = (DTA *) gemdos(47);
	gemdos(26, &dta);
#else
	olddta = Fgetdta();
	Fsetdta(&dta);
#endif

	strcpy(path, "A:\\*.*");
	path[0] += (char) drive;

#if USE_gemdos
	error = (int) gemdos(78, path, 0x3F);
#else
	error = Fsfirst(path, 0x3F);
#endif

	/* if ((error == 0) && (dta.d_attrib & 8)) DjV 004 300103 */
	if ((error == 0) && (dta.d_attrib & FA_VOLUME)) /* DjV 004 300103 same but more readable */
		strcpy(label, dta.d_fname);
	else
		*label = 0;

#if USE_gemdos
	gemdos(26, olddta);
#else
	Fsetdta(olddta);
#endif

	return ((error == -49) || (error == -33)) ? 0 : error;
}

/* File funkties */

int x_rename(const char *oldname, const char *newname)
{
#if USE_gemdos
	return xerror((int) gemdos(86, 0, oldname, newname));
#else
	return xerror(Frename(0, oldname, newname));
#endif
}

int x_unlink(const char *file)
{
#if USE_gemdos
	return xerror((int) gemdos(65, file));
#else
	return xerror(Fdelete(file));
#endif
}

int x_fattrib(const char *file, int wflag, int attrib)
{
#if USE_gemdos
	return xerror((int) gemdos(67, file, wflag, attrib));
#else
	return xerror(Fattrib(file, wflag, attrib));
#endif
}

int x_datime(DOSTIME *time, int handle, int wflag)
{
#if USE_gemdos
	return xerror((int) gemdos(87, time, handle, wflag));
#else
	return xerror(Fdatime(time, handle, wflag));
#endif
}

int x_open(const char *file, int mode)
{
	long result;			/* HR 151102 */

	if (!flock)
		mode &= O_RWMODE;

#if USE_gemdos
	result = gemdos(61, file, mode);
#else
	result = Fopen(file, mode);
#endif

	return (result < 0) ? xerror(result) : result;
}

int x_create(const char *file, int attr)
{
	long result;				/* HR 101202 long */

#if USE_gemdos
	result = (int) gemdos(60, file, attr);
#else
	result = Fcreate(file, attr);
#endif

	return (result < 0) ? xerror(result) : result;
}

int x_close(int handle)
{
#if USE_gemdos
	return xerror((int) gemdos(62, handle));
#else
	return xerror(Fclose(handle));
#endif
}

long x_read(int handle, long count, char *buf)
{
	long result;

#if USE_gemdos
	result = gemdos(63, handle, count, buf);
#else
	result = Fread(handle, count, buf);
#endif

	return (result < 0) ? (long) xerror((int) result) : result;
}

long x_write(int handle, long count, char *buf)
{
	long result;

#if USE_gemdos
	result = gemdos(64, handle, count, buf);
#else
	result = Fwrite(handle, count, buf);
#endif

	return (result < 0) ? (long) xerror((int) result) : result;
}

long x_seek(long offset, int handle, int seekmode)
{
	long result;

#if USE_gemdos
	result = gemdos(66, offset, handle, seekmode);
#else
	result = Fseek(offset, handle, seekmode);
#endif

	return (result < 0) ? (long) xerror((int) result) : result;
}

/* Funkties voor het lezen van een directory */

/* Convert a DTA structure to a XATTR structure. The index, dev,
   rdev, blksize and nblocks fields in attrib are not set. They
   are not necessary anyway on TOS. */

static void dta_to_xattr(DTA *dta, XATTR *attrib)
{
	/* DjV 004 300103 ---vvv--- */
	/* Add pseudo attribute "parent dir" */
	if ( (dta->d_fname[0] == '.') && (dta->d_fname[1] == '.') )
		dta->d_attrib |= FA_PARDIR;
	/* DjV 004 300103 ---^^^--- */
	attrib->mode = 0777;
	if (dta->d_attrib & FA_SUBDIR)
		attrib->mode |= S_IFDIR;
	else
		attrib->mode |= S_IFREG;
	if (dta->d_attrib & FA_READONLY)
		attrib->mode &= ~(S_IWUSR | S_IWGRP | S_IWOTH);
	attrib->size = dta->d_length;
	attrib->uid = 0;
	attrib->gid = 0;
	attrib->mtime = attrib->atime = attrib->ctime = dta->d_time;
	attrib->mdate = attrib->adate = attrib->cdate = dta->d_date;
	attrib->attr = (int) dta->d_attrib & 0xFF;
}

/* HR 050203 */
static
bool is_uni(char *s)
{
	return *(s+1) == ':' && ((*s) == 'u' || *s == 'U');
}


/* HR 151102: courtesy XaAES & EXPLODE; now it also works with MagiC */

boolean x_inq_xfs(const char *path, boolean *casesens)
{
	long c, t, csens; char p[256];

	strcpy(p, path);
	if (*(p + strlen(p) - 1) != '\\')
		strcat(p, "\\");

	c = Dpathconf(p, DP_CASE);
	t = Dpathconf(p, DP_TRUNC);

	csens = !(c == DP_NOSENSITIVE && t == DP_DOSTRUNC);

	if (casesens)
		*casesens = csens;

	return (c >= 0 && csens);
}

XDIR *x_opendir(const char *path, int *error)
{
#if _MINT_
	if (mint)			/* HR 151102 */
	{
		XDIR *dir;

		if ((dir = malloc(sizeof(XDIR))) == NULL)
			*error = ENSMEM;
		else
		{
			dir->path = (char *) path;
			dir->type = x_inq_xfs(path, nil) ? 0 : 1;	/* HR 151102 */

			if (dir->type)
			{
				/*
				 * Dos file system.
				 */

				dir->data.gdata.first = 1;
#if USE_gemdos
				dir->data.gdata.old_dta = (DTA *) gemdos(47);
				gemdos(26, &dir->data.gdata.dta);
#else
				dir->data.gdata.old_dta = Fgetdta();
				Fsetdta(&dir->data.gdata.dta);
#endif
				*error = 0;
			}
			else
			{
				/*
				 * File system with long filenames.
				 */
	
#if USE_gemdos
				if (((dir->data.handle = gemdos(0x128, path, 0)) & 0xFF000000L) == 0xFF000000L)
#else
				if (((dir->data.handle = Dopendir(path, 0)) & 0xFF000000L) == 0xFF000000L)
#endif
				{
					*error = xerror((int) dir->data.handle);
					free(dir);
					dir = NULL;
				}
			}
		}
		return dir;	
	}
	else
#endif
	{
		XDIR *dir;
	
		if ((dir = malloc(sizeof(XDIR))) == NULL)
			*error = ENSMEM;
		else
		{
			dir->path = (char *) path;
			dir->data.gdata.first = 1;
#if USE_gemdos
			dir->data.gdata.old_dta = (DTA *) gemdos(47);
			gemdos(26, &dir->data.gdata.dta);
#else
			dir->data.gdata.old_dta = Fgetdta();
			Fsetdta(&dir->data.gdata.dta);
#endif
			*error = 0;
		}
		return dir;
	}
}

long x_xreaddir(XDIR *dir, char *buffer, int len, XATTR *attrib)
{
#if _MINT_
	if (mint)			/* HR 151102 */
	{
		if (dir->type)
		{
			/*
			 * DOS file system.
			 */
	
			int error;
		
			if (dir->data.gdata.first != 0)
			{
				char *fspec;
		
				if ((fspec = x_makepath(dir->path, "*.*", &error)) != NULL)
				{
#if USE_gemdos
					error = xerror((int) gemdos(78, fspec, 0x37));
#else
					error = xerror(Fsfirst(fspec, 0x37));
#endif
					free(fspec);
					dir->data.gdata.first = 0;
				}
			}
			else
#if USE_gemdos
				error = xerror((int) gemdos(79));
#else
				error = xerror(Fsnext());
#endif

			if (error == 0)
			{
				if (strlen(dir->data.gdata.dta.d_fname) + 1 > len)
					error = EFNTL;
				else
				{
					strupr(dir->data.gdata.dta.d_fname);		/* HR 151102: arrogant MiNT tampering with filenames. */
					strncpy(buffer, dir->data.gdata.dta.d_fname, len);
					dta_to_xattr(&dir->data.gdata.dta, attrib);
				}
			}
			return (long) error;
		}
		else
		{
			/*
			 * File system with long filenames.
			 * HR 130203: Use Dxreaddir in stead of Dreaddir,
			 *            handle links correctly.
			 */
	
			int h;
			char str[260];
			long error, rep;
	
			if ((error = Dxreaddir(len, dir->data.handle, str, (long)attrib, &rep)) == 0)
				strcpy(buffer, &str[4]);

			if (error == 0)
				return error;
		
			return (long) xerror((int) error);
		}
	}
	else
#endif
	{
		int error;
	
		if (dir->data.gdata.first != 0)
		{
			char *fspec;
	
			if ((fspec = x_makepath(dir->path, "*.*", &error)) != NULL)
			{
#if USE_gemdos
				error = xerror((int) gemdos(78, fspec, 0x37));
#else
				error = xerror(Fsfirst(fspec, 0x37));
#endif
				free(fspec);
				dir->data.gdata.first = 0;
			}
		}
		else
#if USE_gemdos
			error = xerror((int) gemdos(79));
#else
			error = xerror(Fsnext());
#endif
	
		if (error == 0)
		{
			if (strlen(dir->data.gdata.dta.d_fname) + 1 > len)
				error = EFNTL;
			else
			{
				strncpy(buffer, dir->data.gdata.dta.d_fname, len);
				dta_to_xattr(&dir->data.gdata.dta, attrib);
			}
		}
		return (long) error;
	
	}
}

long x_rewinddir(XDIR *dir)
{
#if _MINT_
	if (mint)			/* HR 151102 */
	{
		if (dir->type)
		{
			/*
			 * DOS file system.
			 */
	
			dir->data.gdata.first = 1;
			return 0L;
		}
		else
		{
			/*
			 * File system with long filenames.
			 */
	
#if USE_gemdos
			return xerror(gemdos(0x12A, dir->data.handle));
#else
			return xerror(Drewinddir(dir->data.handle));
#endif
		}
	}
	else
#endif
	{
		dir->data.gdata.first = 1;
		return 0L;
	}
}

long x_closedir(XDIR *dir)
{
#if _MINT_
	if (mint)			/* HR 151102 */
	{
		if (dir->type)
		{
			/*
			 * DOS file system.
			 */
	
#if USE_gemdos
			gemdos(26, dir->data.gdata.old_dta);
#else
			Fsetdta(dir->data.gdata.old_dta);
#endif
			free(dir);
			return 0L;
		}
		else
		{
			/*
			 * File system with long filenames.
			 */
	
			long error;
	
#if USE_gemdos
			error = xerror(gemdos(0x12B, dir->data.handle));
#else
			error = xerror(Dclosedir(dir->data.handle));
#endif
			free(dir);
			return error;
		}
	}
	else
#endif
	{
#if USE_gemdos
		gemdos(26, dir->data.gdata.old_dta);
#else
		Fsetdta(dir->data.gdata.old_dta);
#endif
		free(dir);
		return 0L;
	}
}

#pragma warn -par

long x_attr(int flag, const char *name, XATTR *xattr)
{
#if _MINT_
	if (mint)				/* HR 151102 */
	#if USE_gemdos
		return xerror((int) gemdos(0x12C, flag, name, xattr));
	#else
		return xerror(Fxattr(flag, name, xattr));
	#endif
	else
#endif
	{
		DTA *olddta, dta;
		int result;
	
#if USE_gemdos
		olddta = (DTA *) gemdos(47);
		gemdos(26, &dta);
	
		if ((result = xerror((int) gemdos(78, name, 0x37))) == 0)
			dta_to_xattr(&dta, xattr);
	
		gemdos(26, olddta);
#else
		olddta = Fgetdta();
		Fsetdta(&dta);
	
		if ((result = xerror(Fsfirst(name, 0x37))) == 0)
			dta_to_xattr(&dta, xattr);
	
		Fsetdta(olddta);
#endif

		return result;
	}
}

#pragma warn .par

/* Configuratie funkties */

#pragma warn -par

long x_pathconf(const char *path, int which)
{
#if _MINT_
	if (mint)				/* HR 151102 */
	{
		long result;
	
		result = Dpathconf(path, which);

		return (result < 0) ? xerror((int) result) : result;
	}
	else
#endif
	{
		if (which == DP_PATHMAX)
			 return 128;
		else if (which == DP_NAMEMAX)
			return 12;
		return 0;
	}
}

#pragma warn .par

/* Funkties voor het uitvoeren van programma's */

long x_exec(int mode, void *ptr1, void *ptr2, void *ptr3)
{
	int result;

	result = xerror((int) Pexec(mode, ptr1, ptr2, ptr3));

	if ((result != EFILNF) && (result != EPTHNF) && (result != ENSMEM) && (result != EPLFMT))
		result = 0;

	return result;
}

/* Geheugen funkties */

void *x_alloc(long amount)
{
#if USE_gemdos
	return (void *) gemdos(72, amount);
#else
	return Malloc(amount);
#endif
}

int x_free(void *block)
{
#if USE_gemdos
	return xerror((int) gemdos(73, block));
#else
	return xerror(Mfree(block));
#endif
}

int x_shrink(void *block, long newsize)
{
#if USE_gemdos
	return xerror((int) gemdos(74, (int) 0, block, newsize));
#else
	return xerror(Mshrink(0, block, newsize));
#endif
}

/* GEM funkties */

char *xshel_find(const char *file, int *error)
{
	char *buffer, *h;

	if ((buffer = calloc(sizeof(LNAME), 1)) == NULL)			/* HR 240203 */
	{
		*error = ENSMEM;
		return NULL;
	}
	else
	{
		strcpy(buffer, file);

		if (shel_find(buffer) == 0)
			*error = EFILNF;
		else
		{
			if ((*error = _fullname(buffer)) == 0)
			{
				if ((h = realloc(buffer, strlen(buffer) + 1)) == NULL)
					h = buffer;
				return h;
			}
		}
		free(buffer);
		return NULL;
	}
}

char *xfileselector(const char *path, char *name, const char *label)
{
	char *buffer, *h;
	int error, button;

	if ((buffer = malloc(sizeof(LNAME))) == NULL)			/* HR 240203 */
	{
		xform_error(ENSMEM);
		return NULL;
	}
	strcpy(buffer, path);

	wind_update(BEG_UPDATE);
	if (tos1_4() == TRUE)
		error = fsel_exinput(buffer, name, &button, (char *) label);
	else
		error = fsel_input(buffer, name, &button);
	wind_update(END_UPDATE);

	if ((error == 0) || (button == 0))
	{
		if (error == 0)
			alert_printf(1, MFSELERR);
	}
	else
	{
		if ((error = _fullname(buffer)) == 0)
		{
			if ((h = realloc(buffer, strlen(buffer) + 1)) == NULL)
				h = buffer;
			return h;
		}
		xform_error(error);
	}
	free(buffer);
	return NULL;
}

/********************************************************************
 *																	*
 * Vervangers van fopen enz. uit de standaard bibliotheek.			*
 *																	*
 ********************************************************************/

static int read_buffer(XFILE *file)
{
	long n;

	if ((n = x_read(file->handle, XBUFSIZE, file->buffer)) < 0)
		return (int) n;

	else
	{
		file->write = (int) n;
		file->read = 0;
		file->eof = (n != XBUFSIZE) ? TRUE : FALSE;

		return 0;
	}
}

static int write_buffer(XFILE *file)
{
	long n;

	if (file->write != 0)
	{
		if ((n = x_write(file->handle, file->write, file->buffer)) < 0)
			return (int) n;

		else
		{
			if (n == (long) file->write)
			{
				file->write = 0;
				file->eof = TRUE;

				return 0;
			}
			else
				return EDSKFULL;
		}
	}
	else
		return 0;
}


XFILE *x_fopen(const char *file, int mode, int *error)
{
	int result = 0, rwmode = mode & O_RWMODE;
	XFILE *xfile;

	if ((xfile = malloc(sizeof(XFILE) + XBUFSIZE)) == NULL)
		result = ENSMEM;
	else
	{
		xfile->mode = mode;
		xfile->buffer = (char *) (xfile + 1);
		xfile->bufsize = (int) XBUFSIZE;
		xfile->read = 0;
		xfile->write = 0;
		xfile->eof = FALSE;
		xfile->memfile = FALSE;

		if (rwmode == O_RDONLY)
		{
			if ((xfile->handle = x_open(file, mode)) < 0)
				result = xfile->handle;
		}
		else if (rwmode == O_WRONLY)
		{
			if ((xfile->handle = x_create(file, 0)) < 0)
				result = xfile->handle;
		}
		else
			result = EINVFN;

		if (result != 0)
		{
			free(xfile);
			xfile = NULL;
		}
	}

	*error = result;

	return xfile;
}

XFILE *x_fmemopen(int mode, int *error)
{
	int result = 0, rwmode = mode & O_RWMODE;
	XFILE *xfile;

	if ((xfile = malloc(sizeof(XFILE))) == NULL)
		result = ENSMEM;
	else
	{
		xfile->mode = mode;
		xfile->buffer = NULL;
		xfile->bufsize = 0;
		xfile->read = 0;
		xfile->write = 0;
		xfile->eof = FALSE;
		xfile->memfile = TRUE;

		if (rwmode != O_RDWR)
		{
			result = EINVFN;
			free(xfile);
			xfile = NULL;
		}
	}

	*error = result;

	return xfile;
}

int x_fclose(XFILE *file)
{
	int error, rwmode = file->mode & O_RWMODE;

	if (file->memfile)
	{
		error = 0;
		if (file->buffer)
			free(file->buffer);
	}
	else
	{
		int h;

		h = (rwmode == O_RDONLY) ? 0 : write_buffer(file);
		if ((error = x_close(file->handle)) == 0)
			error = h;
	}

	free(file);

	return error;
}

long x_fread(XFILE *file, void *ptr, long length)
{
	long rem = length, n, size;
	char *dest = (char *) ptr, *src;
	int read, write, error;

	if (file->memfile)
	{
		read = file->read;
		write = file->write;
		src = file->buffer;

		while ((rem > 0) && (file->eof == FALSE))
		{
			if (read == write)
				file->eof = TRUE;
			else
			{
				*dest++ = src[read++];
				rem--;
			}
		}

		file->read = read;

		return (length - rem);
	}
	else
	{
		if ((file->mode & O_RWMODE) == O_WRONLY)
			return 0;

		src = file->buffer;

		do
		{
			if ((file->read == file->write) && (file->eof == FALSE))
			{
				if ((error = read_buffer(file)) < 0)
					return (long) error;
			}

			read = file->read;
			write = file->write;

			while ((read < write) && (rem > 0))
			{
				*dest++ = src[read++];
				rem--;
			}

			file->read = read;

			if ((rem >= XBUFSIZE) && (file->eof == FALSE))
			{
				size = rem - (rem % XBUFSIZE);

				if ((n = x_read(file->handle, size, dest)) < 0)
					return n;

				if (n != size)
					file->eof = TRUE;

				rem -= n;
			}
		}
		while ((rem > 0) && (file->eof == FALSE));

		return (length - rem);
	}
}

long x_fwrite(XFILE *file, void *ptr, long length)
{
	long rem = length, n, size;
	char *dest, *src = (char *) ptr;
	int write, error;

	if ((file->mode & O_RWMODE) == O_RDONLY)
		return EINVFN;

	if (file->memfile)
	{
		write = file->write;
		dest = file->buffer;

		while (rem > 0)
		{
			if (write == file->bufsize)
			{
				char *new;

				if (file->buffer)
					new = realloc(file->buffer, file->bufsize + 128);
				else
					new = malloc(128);

				if (new == NULL)
					return ENSMEM;
				dest = file->buffer = new;
				file->bufsize += 128;
			}

			dest[write++] = *src++;
			rem--;
		}

		file->write = write;

		return length;
	}
	else
	{
		dest = file->buffer;

		do
		{
			write = file->write;

			while ((write < XBUFSIZE) && (rem > 0))
			{
				dest[write++] = *src++;
				rem--;
			}

			file->write = write;

			if (file->write == XBUFSIZE)
			{
				if ((error = write_buffer(file)) < 0)
					return (long) error;
			}

			if (rem >= XBUFSIZE)
			{
				size = rem - (rem % XBUFSIZE);

				if ((n = x_write(file->handle, size, dest)) < 0)
					return n;

				if (n != size)
					return EDSKFULL;

				rem -= n;
			}
		} while (rem > 0);

		return (length - rem);
	}
}

long x_fseek(XFILE *file, long offset, int mode)
{
	if (!file->memfile || (mode != 0) || (offset != 0))
		return EINVFN;
	else
	{
		file->read = (int) offset;
		return 0;
	}
}

/* HR 240103: It is imparative that this function has a maximum
              be it only to protect the stack in certain calling functions. */
char *x_freadstr(XFILE *file, char *string, size_t max, int *error)
{
	int l;
	long n;
	char *s;

	if ((n = x_fread(file, &l, sizeof(int))) == sizeof(int))
	{
		if (l > max - 1)		/* max is basically the size of an array that leaves place for a null character. */
			l = max - 1;

		if (string == NULL)
		{
			if ((s = malloc(l + 1)) == NULL)
			{
				*error = ENSMEM;
				return NULL;
			}
		}
		else
			s = string;

		if ((n = x_fread(file, s, l + 1)) != l + 1)
		{
			if (string == NULL)
				free(s);
			*error = (n < 0) ? (int) n : EEOF;
			return NULL;
		}
	}
	else
	{
		*error = (n < 0) ? (int) n : EEOF;
		return NULL;
	}

	*error = 0;

	return s;
}

int x_fwritestr(XFILE *file, const char *string)
{
	int l;
	long n;

	l = (int) strlen(string);

	if ((n = x_fwrite(file, &l, sizeof(int))) < 0)
		 return (int) n;

	if ((n = x_fwrite(file, string, l + 1)) < 0)
		return (int) n;

	return 0;
}

int x_fgets(XFILE *file, char *string, int n)
{
	boolean ready = FALSE;
	int i = 1, read, write, error;
	char *dest, *src, ch, nl = 0;

	if (file->memfile)
		return EINVFN;

	if ((file->mode & O_RWMODE) != O_RDONLY)
	{
		*string = 0;
		return 0;
	}

	if (x_feof(file) == TRUE)
		return EEOF;

	dest = string;
	src = file->buffer;
	read = file->read;
	write = file->write;

	while (ready == FALSE)
	{
		if (read == write)
		{
			if (file->eof == TRUE)
				ready = TRUE;
			else
			{
				if ((error = read_buffer(file)) < 0)
					return error;
				read = file->read;
				write = file->write;
			}
		}
		else
		{
			if (nl != 0)
			{
				ready = TRUE;
				if ((((ch = src[read]) == '\n') || (ch == '\r')) && (nl != ch))
					read++;
			}
			else
			{
				if (((ch = src[read++]) == '\n') || (ch == '\r'))
					nl = ch;
				else if (i < n)
				{
					*dest++ = ch;
					i++;
				}
			}
		}
	}

	file->read = read;

	*dest = 0;

	return 0;
}

boolean x_feof(XFILE *file)
{
	return ((file->eof == TRUE) && (file->read == file->write)) ? TRUE : FALSE;
}

void x_init(void)
{
	if (find_cookie('_FLK') != -1)		/* HR 151102 */
		flock = TRUE;
	else
		flock = FALSE;
}
