/*
 *	Global configuration file for MiNT-Net.
 *
 *	10/26/93, kay roemer
 */

#ifndef _CONFIG_H
#define _CONFIG_H

/* use the new way for Fselect() (not yet official) */
/* #define NEW_SELECT */

/* switch of debugging info, thus producing a slightly smaller binary */
/* #define NDEBUG */

/* Use unix file name lookup cache. This speeds up on filesystems where
 * Fxattr() works for XATTR.index :-) and slows down on filesystems where
 * Fxattr() doesn't work for XATTR.index :-(.
 * That means:
 * - undefine if your unix sockets reside on TosFs
 * - define if your unix sockets reside on MinixFs
 */
#define USE_UN_LOOKUP_CACHE

/* Enable Unix style read()'s and write()'s, ie make them return as soon
 * as any data is available.
 */
#define USE_UNIX_TRANSFER_STYLE

#endif /* _CONFIG_H */
