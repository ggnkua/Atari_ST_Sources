/************************************************************************
*************************************************************************
** NOTE:                                                               **
**   This Module is part of the ATARI ST Implementation of Parselst    **
**   It should NOT be used for general reference. Please read the com- **
**   plete Disclaimer either at the TOP of PARSELST.C.                 **
**   Peter Glasmacher at 1:143/9  Ph (408)985-1538                     **
*************************************************************************
*************************************************************************/

/*----------------------------------------------------------------------*
*                              Nodelist Parser                          *
*                                                                       *
*              This module was originally written by Bob Hartman        *
*                       Sysop of FidoNet node 1:132/101                 *
*                                                                       *
* Spark Software, 427-3 Amherst St, CS 2032, Suite 232, Nashua, NH 03061*
*                                                                       *
* This program source code is being released with the following         *
* provisions:                                                           *
*                                                                       *
* 1.  You are  free to make  changes to this source  code for use on    *
*     your own machine,  however,  altered source files may not be      *
*     distributed without the consent of Spark Software.                *
*                                                                       *
* 2.  You may distribute "patches"  or  "diff" files for any changes    *
*     that you have made, provided that the "patch" or "diff" files are *
*     also sent to Spark Software for inclusion in future releases of   *
*     the entire package.   A "diff" file for the source archives may   *
*     also contain a compiled version,  provided it is  clearly marked  *
*     as not  being created  from the original source code.             *
*     No other  executable  versions may be  distributed without  the   *
*     consent of Spark Software.                                        *
*                                                                       *
* 3.  You are free to include portions of this source code in any       *
*     program you develop, providing:  a) Credit is given to Spark      *
*     Software for any code that may is used, and  b) The resulting     *
*     program is free to anyone wanting to use it, including commercial *
*     and government users.                                             *
*                                                                       *
* 4.  There is  NO  technical support  available for dealing with this  *
*     source code, or the accompanying executable files.  This source   *
*     code  is provided as is, with no warranty expressed or implied    *
*     (I hate legalease).   In other words, if you don't know what to   *
*     do with it,  don't use it,  and if you are brave enough to use it,*
*      you're on your own.                                              *
*                                                                       *
* Spark Software may be contacted by modem at (603) 888-8179            *
* (node 1:132/101)                                                      *
* on the public FidoNet network, or at the address given above.         *
*                                                                       *
*-----------------------------------------------------------------------*/


/*   edit.c   */

unsigned crcstr (char *buf,unsigned);
void fix_up (char *);
void edit (void);
void add_files (void);
void close_files (void);
int open_infiles (char *, char *);
void get_old_name (char *);
int get_diff_name (char *);

/*              parsecfg.c              */

/*void parse_config (char *, char *,char *);*/

/*  names.c  */
void do_names (void);
void how_likely (char *,int,int *,int,int);

/* misc.c  */

int cmp (struct nidxs *,struct nidxs *);
char *nextfield (char *,char *);
void spec_word (char *);
char *mymalloc(unsigned int);
void nfile_name (char **);
void undash (char *);
void get_nl_list (void);
filedir (char *,int,char *,int);
void get_addr (char *, int *, int *, int *);

/*   parselst.c   */

void open_outfiles (void);
void process_file (int );
void header (int );

/*   report.h   */

void size_report (void);

/*   stdio.c   */

int fast_open (char *,int);
int fast_close (int);
int fast_write (int ,void *,unsigned int);
int fast_read (int,void *,unsigned int);
#ifdef ST
#  define exit stexit
#endif
void stexit(int);