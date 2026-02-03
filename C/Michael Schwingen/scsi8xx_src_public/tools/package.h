/*
  Tool to generate Milan ROM packages.
  (C) 1999 Michael Schwingen
*/

#ifndef _PACKAGE_H
#define _PACKAGE_H

#define PKG_MAGIC 0x4D504B47
typedef struct
{
  ULONG magic;		/* "MPKG" */
  UWORD header_version;	/* version number of this header: currently 1 */
  WORD  pkg_type;	/* type of package */
  WORD  pkg_id;		/* sub-ID for package */
  UWORD	compr_type;	/* compression type: 0 = none, 1 =  gzip */
  ULONG compressed_len;	/* length of compressed data */
  ULONG compr_crc;	/* crc32 for compressed data */
  ULONG orig_len;	/* uncompressed length */
  ULONG orig_crc;	/* crc32 for original data */
  UBYTE pkg_name[32];	/* (file)name of package */
  UBYTE pkg_descr[32];	/* description of package */
} PKG_HEADER;

typedef enum
{
  PKGTYPE_UNKNOWN,
  PKGTYPE_TOS, PKGTYPE_GEMRSC, PKGTYPE_DESKRSC, PKGTYPE_DESKINF,
  PKGTYPE_AUTOPRG, PKGTYPE_ACC, PKGTYPE_DESKICON
} PKG_TYPE;

typedef enum
{
  PKGLANG_UNKNOWN,
  PKGLANG_USA, PKGLANG_GRM, PKGLANG_FRE, PKGLANG_ITA, PKGLANG_SPA,
  PKGLANG_SWE
} PKG_LANG;

typedef enum
{
  COMPR_NONE, COMPR_GZIP
} COMPR_TYPE;
#endif







