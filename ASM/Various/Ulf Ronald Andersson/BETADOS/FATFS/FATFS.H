/*
 * This file belongs to FreeMiNT. It's not in the original MiNT 1.12
 * distribution. See the file CHANGES for a detailed log of changes.
 * 
 * 
 * Copyright 2000 Frank Naumann <fnaumann@freemint.de>
 * All rights reserved.
 * 
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 * 
 * begin:	1998-02
 * last change: 1998-06-24
 * 
 * Author: Frank Naumann <fnaumann@freemint.de>
 * 
 * please send suggestions, patches or bug reports to me or
 * the MiNT mailing list
 *  
 */

# ifndef _fatfs_h
# define _fatfs_h

# include "mint/mint.h"
# include "mint/file.h"


# ifdef OLDTOSFS
# define FATFS_TESTING
# endif

/*
 * exported data structures
 */

extern FILESYS fatfs_filesys;

/*
 * exported functions
 */

void fatfs_init (void);
long fatfs_config (const ushort drv, const long config, const long mode);

/* config: */

# define FATFS_VFAT	1	/* enable/disable VFAT extension [on drv]
				 */
# define FATFS_VCASE	2	/* change short name handling
				 * (original/always lowercase)
				 */
# define FATFS_SECURE	3	/* change default root permissions
				 * mode = SecureLevel:
				 * 0 -> -rwxrwxrwx
				 * 1 -> -rwxrwx---
				 * 2 -> -rwx------
				 */

# define FATFS_DEBUG	100	/* only for debugging, kernel internal */
# define FATFS_DEBUG_T	101

# ifdef FATFS_TESTING
# define FATFS_DRV	1000	/* temporary:
				 * activate or deactivate fatfs for specified drive
				 */
# endif


# endif /* _fatfs_h */
