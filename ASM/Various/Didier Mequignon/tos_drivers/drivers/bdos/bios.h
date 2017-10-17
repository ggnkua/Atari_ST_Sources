/*
 * bios.h - bios defines
 *
 * Copyright (c) 2001 Martin Doering
 *
 * Authors:
 *  SCC    Steve C. Cavender
 *  KTB    Karl T. Braun (kral)
 *  MAD    Martin Doering
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

#ifndef BIOS_H
#define BIOS_H


/*
 *  Bios Function Numbers
 */

//#define B_MDCHG         9               /*  media change                */

/*
 * BIOS level character device handles
 */

//#define BFHPRN  0
//#define BFHAUX  1
//#define BFHCON  2


/*
 *  return codes
 */

#define DEVREADY        -1L             /*  device ready                */
#define DEVNOTREADY     0L              /*  device not ready            */
#define MEDIANOCHANGE   0L              /*  media def has not changed   */
#define MEDIAMAYCHANGE  1L              /*  media may have changed      */
#define MEDIACHANGE     2L              /*  media def has changed       */

/*
 *  code macros
 */

//#define ADDRESS_OF(x)   x
//#define INP             inp
//#define OUTP            outp


/*
 *  bios data types
 */


/*
 *  ISR - Interrupt Service Routines.
 *      These routines currently do not return anything important.  In
 *      future versions, they will return boolean values that indicate
 *      whether a displatch should occurr (TRUE) or not.
 */

//typedef BOOL ISR;               /*  interrupt service routine   */
//typedef ISR     (*PISR)() ;     /*  pointer to isr routines     */

/*
 *  SSN - Sequential Sector Numbers
 *      At the outermost level of support, the disks look like an
 *      array of sequential logical sectors.  The range of SSNs are
 *      from 0 to n-1, where n is the number of logical sectors on
 *      the disk.  (logical sectors do not necessarilay have to be
 *      the same size as a physical sector.
 */

//typedef long    SSN ;


/*
 *  Data Structures
 */

/*
 *  PD - Process Descriptor
 */

#ifndef PD
#define PD struct _pd

PD
{
    /* 0x00 */
    long        p_lowtpa;
    long        p_hitpa;
    long        p_tbase;
    long        p_tlen;
    /* 0x10 */
    long        p_dbase;
    long        p_dlen;
    long        p_bbase;
    long        p_blen;
    /* 0x20 */
    long        p_0fill[3] ;
    char        *p_env;
    /* 0x30 */
    long        p_1fill[20] ;
    /* 0x80 */
    char        p_cmdlin[0x80];
} ;
#endif



/*
 *  BPB - Bios Parameter Block
 */

#ifndef BPB
#define BPB struct _bpb

BPB /* bios parameter block */
{
    short recsiz;         /* sector size in bytes */
    short clsiz;          /* cluster size in sectors */
    short clsizb;         /* cluster size in bytes */
    short rdlen;          /* root directory length in records */
    short fsiz;           /* fat size in records */
    short fatrec;         /* first fat record (of last fat) */
    short datrec;         /* first data record */
    short numcl;          /* number of data clusters available */
    short b_flags;
} ;
#endif

/*
 *  flags for BPB
 */

#define B_16    1                       /* device has 16-bit FATs       */
#define B_FIX   2                       /* device has fixed media       */

/*
 *  BCB - Buffer Control Block
 */

#ifndef BCB
#define BCB struct _bcb


BCB
{
    BCB *b_link;        /*  next bcb                    */
    short b_bufdrv;     /*  unit for buffer             */
    short b_buftyp;     /*  buffer type                 */
    short b_bufrec;     /*  record number               */
    BOOL b_dirty;       /*  true if buffer dirty        */
    long b_dm;          /*  reserved for file system    */
    char *b_bufr;       /*  pointer to buffer           */
} ;

/*
 *  buffer type values
 */

//#define BT_FAT          0               /*  fat buffer                  */
//#define BT_ROOT         1               /*  root dir buffer             */
//#define BT_DIR          2               /*  other dir buffer            */
//#define BT_DATA         3               /*  data buffer                 */

/*
 *  buffer list indexes
 */

#define BI_FAT          0               /*  fat buffer list             */
//#define BI_ROOT         1               /*  root dir buffer list        */
//#define BI_DIR          1               /*  other dir buffer list       */
#define BI_DATA         1               /*  data buffer list            */


#endif


/*
 *  MD - Memory Descriptor
 */

#define MD struct _md

MD
{
    MD  *m_link;
    long        m_start;
    long        m_length;
    PD  *m_own;
} ;

/*
 *  fields in Memory Descriptor
 */

//#define MF_FREE 1


/*
 *  MPB - Memory Partition Block
 */

#define MPB struct _mpb

MPB
{
    MD  *mp_mfl;
    MD  *mp_mal;
    MD  *mp_rover;
} ;



#endif /* BIOS_H */
