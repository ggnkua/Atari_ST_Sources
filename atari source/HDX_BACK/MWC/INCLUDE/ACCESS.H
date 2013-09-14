/*
 * access.h -- modes for the access system call.
 *
 * Copyright (c) 1982-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

#define	AREAD	04		/* Test for read */
#define	AWRITE	02		/* Test for write */
#define	AEXEC	01		/* Test for execute */
#define	AAPPND	AWRITE		/* Test for append */

/* Dummy directory modes */
#define	ALIST	AREAD		/* List directory */
#define	ADEL	AWRITE		/* Delete directory entry */
#define	ASRCH	AEXEC		/* Search directory */
#define	ACREAT	AAPPND		/* Create directory entry */
