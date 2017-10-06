/*
 *  Part of WinDom by D. B‚r‚ziat
 *	Module: fsel.h
 *	Tir‚ de fsel_input.h pour Selectric ((c) 1992 by Oliver Scheel)
 */

#ifndef __FSELLIB__
#define __FSELLIB__

#ifdef __GNUC__
	#define DTA	_DTA
#endif

/* Selectric */

#define CMD_FILES_OUT   0x01     /* return filelist */
#define CFG_ONESTRING   0x02     /* return list in one string */
#define CFG_FIRSTNEXT   0x08

#define FSEL_COOKIE		0x4653454CL		/* 'FSEL' */
#define SLCT_COOKIE		0x534C4354L		/* 'SLCT' */

typedef struct muf {
   ULONG   id;      			/* Selectric ID (SLCT)     */
   UWORD   version; 			/* version (BCD-Format)    */
   struct {
      UWORD resved : 8;  		/* reserved       */
      UWORD pthsav : 1; 		/* save GEMDOS paths    */
      UWORD stdest : 1; 		/* stay in destination path   */
      UWORD autloc : 1; 		/* auto-locator         */
      UWORD numsrt : 1;  		/* numsort        */
      UWORD lower  : 1;  		/* use lowercase letters   */
      UWORD dclick : 1;  		/* open folder on dclick   */
      UWORD hidden : 1; 		/* show hidden files    */
      UWORD bypass : 1; 		/* Selectric ON/OFF     */
   } config;
   WORD   sort;       			/* sort-mode (neg. = rev.) */
   WORD   num_ext;    			/* number of extensions    */
   BYTE  *(*ext)[];     		/* preset extensions    */
   WORD   num_paths;     		/* number of paths      */
   BYTE  *(*paths)[];      		/* preset paths         */
   WORD   comm;       			/* communication word      */
   WORD   in_count;      		/* input counter     */
   void  *in_ptr;    			/* input pointer     */
   WORD   out_count;     		/* output counter    */
   void  *out_ptr;      		/* output pointer    */
   WORD   __CDECL (*get_first)  ( DTA *dta, WORD attrib);
   WORD   __CDECL (*get_next)   ( DTA *dta);
   WORD   __CDECL (*release_dir)( void); 
} SLCT_STR;

extern SLCT_STR   *slct;

/* BoxKite 2.00 */

#define HBFS_COOKIE	0x48424653L /* 'HBFS' */
#define HBFS_MAGIC	0x42784B74L /* 'BxKt' */

typedef struct {
	unsigned int    branch;     /* Sprungbefehl um den struct herum */
    unsigned long   magic;      /* doit valoir 'BxKt' */
    unsigned int    version;    /* Num‚ro de version (BCD format) */
    long            resvd1;     /* reserviert */
    long            resvd2;     /* reserviert */
    long            resvd3;     /* reserviert */
    long            resvd4;     /* reserviert */
} BXKT_STR;


#endif /* __FSELLIB__ */

