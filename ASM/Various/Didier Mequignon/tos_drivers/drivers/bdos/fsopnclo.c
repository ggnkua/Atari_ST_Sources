/*
 * fsopnclo.c - open/close/create/delete routines for file system       
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  xxx <xxx@xxx>
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



/*
** NOTE:
**      mods with "SCC.XX.NN" are mods which try to merge fixes to a special
**      post 1.0 / pre 1.1 version.  The notation refers to a DRI internal
**      document (see SCC), which is a change log.  SCC refers to the
**      originator of the fix.  The XX refers to the module in which the
**      fix was originally made, fs.c (FS), sup.c (SUP), etc.  The NN is
**      the fix number to that module as indicated on the change log.  For
**      the most part, these numbers are meaningless, and serve only to 
**      correspond code to particular problems.
**
**  mods
**     date     who mod                 fix/change/note
**  ----------- --  ------------------  -------------------------------
**  06 May 1986 ktb M01.01.SCC.FS.02    ixcreat(): rescan.
**  21 Jul 1986 ktb M01.01.0721.01      ixcreat(): check for bad chars
**  30 Jul 1986 ktb M01.01.0730.01      deleting entries from the sft had
**                                      problems if there were dup'd entries
**                                      pointing to the same OFD
**  15 Sep 1986 scc M01.01.0915.01      ixcreat(): disallow creation of subdir
**                                      if file by same name exists
**  22 Oct 1986 scc M01.01.1022.01      xclose(): range check the handle coming in
**  23 Oct 1986 scc M01.01.1023.01      xclose(): check for closing a standard handle
**                                      that was already closed
**  23 Oct 1986 scc M01.01.1023.03      sftdel() and sftosrch() erroneously used NULL
**                                      rather than NULLPTR.
**
**  12 Dec 1986 scc M01.01.1212.01      modified ixcreat(), ixopen(), and xunlink() to
**                                      check for a negative error return from findit().
**
**  14 Dec 1986 scc M01.01.1214.01      Further modification of M01.01.1212.01 to check
**                                      for 0 return (indicating BDOS level error).
*/


#include "portab.h"
#include "asm.h"
#include "fs.h"
#include "bios.h"
#include "gemerror.h"
#include "mem.h"
#include "time.h"

/*
 * forward prototypes
 */

extern void *memcpy(void *dst, const void *src, unsigned long len);

static long ixopen(char *name, short mod);
static long opnfil(FCB *f, DND *dn, short mod);
static long makopn(FCB *f, DND *dn, short h, short mod);
static FTAB *sftsrch(short field, char *ptr);
static void sftdel(FTAB *sftp);
static BOOL match1(char *ref, char *test);

/*
**  used in calls to sftsrch to distinguish which field we are matching on
*/

#define SFTOFD          0
#define SFTOWNER        1

/*
**  SFTOFDSRCH - search sft for entry with matching OFD ptr
**      call sftsrch with correct parms
*/

#define SFTOFDSRCH(o)   sftsrch( SFTOFD , (char *) o )

/*
**  SFTOWNSRCH - search sft for entry with matching PD
**      call sftsrch with correct parms
*/

#define SFTOWNSRCH(p)   sftsrch( SFTOWN , (char *) p )

/*
 * forward prototypes
 */

extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);

/*
**  xcreat -
**  create file with specified name, attributes
**
**      Function 0x3C   f_create
**
**      Error returns
**              EPTHNF
**              EACCDN
**              ENHNDL
**
**      Last modified   SCC     13 May 85
*/

long    xcreat(char *name, char attr) 
{
        return(ixcreat(name, attr & 0xEF));
}


/*      
**  ixcreat - internal routine for creating files
*/
/*  name: path name of file
 *  attr: atttributes
 */             
long ixcreat(char *name, char attr)
{
        register DND *dn;
        register OFD *fd;
        FCB *f;
        char *s,n[2],a[12];                     /*  M01.01.03   */
        short i,f2;                               /*  M01.01.03   */
        long pos,rc;

        n[0] = 0xe5; n[1] = 0;

        /* first find path */

        if ((long)(dn = findit(name,&s,0)) < 0)                 /* M01.01.1212.01 */
                return( (long)dn );
        if (!dn)                                                /* M01.01.1214.01 */
                return( EPTHNF );

        if (!*s || (*s == '.'))         /*  no file name || '.' || '..' */
                return(EPTHNF);

        /*  M01.01.0721.01  */
        if( match1(" '*+,:;<=>?[]^`|",s) )
                return( EACCDN ) ;

        if (!(fd = dn->d_ofd))
                if (!(dn->d_ofd = (fd = makofd(dn))))
                        /*  no ofd for dir file, no space for one       */
                        return (ENSMEM);

        /* is it already there ? */

        pos = 0;
        if ( (f = scan(dn,s,-1,&pos)) )
        {
                                                         /* M01.01.0730.01   */
                if ( (f->f_attrib & (FA_SUBDIR | FA_RO)) || (attr == FA_SUBDIR) )
                        /*  subdir or read only  */
                        return(EACCDN);

                pos -= 32;
                ixdel(dn,f,pos);
        }
        else
                pos = 0;

 /* now scan for empty space */

        /*  M01.01.SCC.FS.02  */
        while( !( f = scan(dn,n,-1,&pos) ) )
        {
                /*  not in current dir, need to grow  */
                if( (short)( fd->o_curcl ) < 0 )
                        /*  but can't grow root  */
                        return( EACCDN ) ;

                if( nextcl( fd, 1 ) )
                        return( EACCDN ) ;

                f = dirinit(dn) ;
                pos = 0 ;
        }

        builds(s,a);
        pos -= 32;
        f->f_attrib = attr;
        for (i=0; i<10; i++)
                f->f_fill[i] = 0;
        f->f_time = time;
        swpw(f->f_time);
        f->f_date = date;
        swpw(f->f_date);
        f->f_clust = 0;
        f->f_fileln = 0;
        ixlseek(fd,pos);
        ixwrite(fd,11L,a);      /* write name, set dirty flag */
        ixclose(fd,CL_DIR);     /* partial close to flush */
        ixlseek(fd,pos);
        
        s = (char*) ixread(fd,32L,NULLPTR);

        f2 = rc = opnfil((FCB*)s,dn, ((attr & FA_RO) ? 0 : 2));

        if (rc < 0)
                return(rc);

        getofd(f2)->o_flag |= O_DIRTY;

        return(f2);
}


/*      
**  xopen - open a file (path name)
**
**  returns
**      <0 = error
**      >0 = file handle
**
**      Function 0x3D   f_open
**
**      Error returns
**              EFILNF
**              opnfil()
**
**      Last modified   SCC     5 Apr 85
*/

long    xopen(char *name, short mod) 
{
        return (ixopen (name, mod));
}

/*
**  ixopen - open a file 
**
**  returns
**      <0 = error
**      >0 = file handle
*/

static long 
ixopen(char *name, short mod)
{
        FCB *f;
        DND *dn;
        char *s;
        long pos;

        /* first find path */
        if ((long)(dn = findit(name,&s,0)) < 0)                 /* M01.01.1212.01 */
                return( (long)dn );
        if (!dn)                                                /* M01.01.1214.01 */
                return( EFILNF );

        /* 
        **  now scan the directory file for a matching filename 
        */
        
        pos = 0;
        if (!(f = scan(dn,s,FA_NORM,&pos)))
                return(EFILNF);

        /* Check to see if the file is read only*/
        if ((f -> f_attrib & 1) && (mod != 0))
                return (EACCDN);

        return (opnfil (f, dn, mod));
}


/*
**  makopn - make an open file for sft handle h 
**
**      Last modified   SCC     8 Apr 85
*/

static long makopn(FCB *f, DND *dn, short h, short mod) 
{
        register OFD *p;
        register OFD *p2;
        DMD *dm;                        /*  M01.01.03   */

        dm = dn->d_drv;

        if (!(p = MGET(OFD))) 
                return(ENSMEM);

        p->o_mod = mod;                 /*  set mode                    */
        p->o_dmd = dm;                  /*  link OFD to media           */
        sft[h-NUMSTD].f_ofd = p;
        p->o_usecnt = 0;                /*  init usage                  */
        p->o_curcl = 0;                 /*  init file pointer info      */
        p->o_curbyt = 0;                /*  "                           */
        p->o_dnode = dn;                /*  link to directory           */
        p->o_dirfil = dn->d_ofd;        /*  link to dir's ofd           */
        p->o_dirbyt = dn->d_ofd->o_bytnum - 32; /*  offset of fcb in dir*/

        for (p2 = dn->d_files; p2; p2 = p2->o_link)
                if (p2->o_dirbyt == p->o_dirbyt)
                        break; /* same dir, same dcnt */

        p->o_link = dn->d_files;
        dn->d_files = p;

        if (p2)
        {       /* steal time,date,startcl,fileln */
                memcpy(&p->o_time, &p2->o_time, 12);
                /* not used yet... TBA *********/      
                p2->o_thread = p; 
        }
        else
        {
                p->o_strtcl = f->f_clust;       /*  1st cluster of file */
                swpw(p->o_strtcl);
                p->o_fileln = f->f_fileln;      /*  init length of file */
                swpl(p->o_fileln);
                p->o_date = f->f_date;
                p->o_time = f->f_time;
        }

        return(h);
}


/*
**  opnfil - does the real work in opening a file
**
**      Error returns
**              ENHNDL
**
**      NOTES:
**              make a pointer to the ith entry of sft 
**              make i a register int.
*/

static long opnfil(FCB *f, DND *dn, short mod)
{
        register short i;
        short h;

        /* find free sft handle */
        for (i = 0; i < OPNFILES; i++)
                if( !sft[i].f_own )
                        break;

        if (i == OPNFILES)
                return(ENHNDL);

        sft[i].f_own = run;
        sft[i].f_use = 1;
        h = i+NUMSTD;

        return(makopn(f, dn, h, mod));
}



/*
**  sftosrch - search the sft for an entry with the specified OFD
**  returns:
**      ptr to the matching sft, or
**      NULL
*/

/* field: which field to match on 
 * ptr: ptr to match on 
 */

static FTAB *sftsrch(short field, char *ptr)
{
        register FTAB   *sftp ; /*  scan ptr for sft                    */
        register short    i ;
        register OFD    *ofd ;
        register PD             *pd ;

        switch( field )
        {
                case SFTOFD:
                        for( i = 0 , sftp = sft , ofd = (OFD *) ptr ;
                             i < OPNFILES  &&  sftp->f_ofd != ofd ; 
                             ++i, ++sftp ) 
                                ;
                        break ;
                case SFTOWNER:
                        for( i = 0 , sftp = sft , pd = (PD *) ptr ;
                             i < OPNFILES  &&  sftp->f_own != pd ; 
                             ++i, ++sftp ) 
                                ;
                        break ;
                default:
                        return (FTAB *)NULLPTR;
        }
        return( i >= OPNFILES ? (FTAB *)NULLPTR : sftp ) ;      /* M01.01.1023.03 */
}
/*
**  sftdel - delete an entry from the sft
**      delete the entry from the sft.  If no other entries in the sft
**      have the same ofd, free up the OFD, also.
*/

static void sftdel( FTAB *sftp )
{
        register FTAB   *s ;
        register OFD    *ofd ;

        /*  clear out the entry  */

        ofd = (s=sftp)->f_ofd ;

        s->f_ofd = 0 ;
        s->f_own = 0 ;
        s->f_use = 0 ;

        /*  if no other sft entries with same OFD, delete ofd  */

        if( SFTOFDSRCH( ofd ) == (FTAB *)NULLPTR )      /* M01.01.1023.03 */
                xmfreblk( (short *) ofd ) ;
}



/*
**  xclose - Close a file.
**
**      Function 0x3E   f_close
**
**      Error returns
**              EIHNDL
**              ixclose()
**
**      SCC:    I have added 'rc' to allow return of status from ixclose().  I 
**              do not yet know whether it is appropriate to perform the 
**              operations inside the 'if' statement following the invocation 
**              of ixclose(), but I am leaving the flow of control intact.
*/

long xclose(short h)
{
        short h0;
        OFD *fd;
        long rc;

        if (h < 0)
                return(E_OK);   /* always a good close on a character device */

        if ( h > (OPNFILES+NUMSTD-1) )  /* M01.01.1022.01 */
                return( EIHNDL );

        if ((h0 = h) < NUMSTD)
        {
                h = run->p_uft[h];
                run->p_uft[h0] = 0;     /* mark std dev as not in use */
                if (h <= 0)             /* M01.01.1023.01 */
                        return(E_OK);
        }
        else if (((long) sft[h-NUMSTD].f_ofd) < 0L)
        {
                if (!(--sft[h-NUMSTD].f_use))
                {
                        sft[h-NUMSTD].f_ofd = 0;
                        sft[h-NUMSTD].f_own = 0;
                }
                return(E_OK);
        }

        if (!(fd = getofd(h)))
                return(EIHNDL);

        rc = ixclose(fd,0);

        if (!(--sft[h-NUMSTD].f_use))
                sftdel(&sft[h-NUMSTD]) ;

        return(rc);
}


/*
**  ixclose -
**
**      Error returns
**              EINTRN
**
**      Last modified   SCC     10 Apr 85
**
**      NOTE:   I'm not sure that returning immediatly upon an error from 
**              ixlseek() is the right thing to do.  Some data structures may 
**              not be updated correctly.  Watch out for this!
**              Also, I'm not sure that the EINTRN return is ok.
*/

#define CL_DIR 0x0002   /* this is a directory file, flush, do not free */
#define CL_FULL 0x0004  /* even though its a directory, full close */

long    ixclose(OFD *fd, short part)
{                                       /*  M01.01.03                   */
        OFD *p,**q;
        long tmp;
        register short i;                 /*  M01.01.03                   */
        BCB *b;


        if (fd->o_flag & O_DIRTY)
        {
                ixlseek(fd->o_dirfil,fd->o_dirbyt+22);

                swpw(fd->o_strtcl);
                swpl(fd->o_fileln);

                if (part & CL_DIR)
                {
                        tmp = fd->o_fileln;             /* [1] */
                        fd->o_fileln = 0;
                        ixwrite(fd->o_dirfil,10L,(char *)&fd->o_time);
                        fd->o_fileln = tmp;
                }
                else
                        ixwrite(fd->o_dirfil,10L,(char *)&fd->o_time);

                swpw(fd->o_strtcl);
                swpl(fd->o_fileln);

        }

        if ((!part) || (part & CL_FULL))
        {
                q = &fd->o_dnode->d_files;

                for (p = *q; p ; p = *(q = &p->o_link))
                        if (p == fd)
                                break;

                 /* someone else has this file open **** TBA */

                if (p)
                        *q = p->o_link;
                else
                        return(EINTRN); /* some kind of internal error */
        }
        
        /* only flush to appropriate drive ***** TBA ******/

        for (i=0; i<2; i++)
                for (b = bufl[i]; b; b = b->b_link)
                        flush(b);

        return(E_OK);
}

/*
** [1]  We play games here (thanx, Jason).  The ixwrite() call will essentially
**      copy the time, date, cluster, and length fields from the OFD of the
**      (dir) file we are closeing to the FCB for this (dir) file in the 
**      parent dir.  The fileln field of this dir is thus set to 0.  But if 
**      this is a directory we are closing (path & CL_DIR), shouldn't the 
**      fileln be zero anyway?  I give up.
**                                      - ktb
*/



/*      
**  xunlink - unlink (delete) a file
**
**      Function 0x41   f_delete
**
**  returns
**      EFILNF  file not found
**      EACCDN  access denied
**      ixdel()
**
*/

long xunlink(char *name) 
{
        register DND *dn;
        register FCB *f;
        char *s;
        long pos;

 /* first find path */

        if ((long)(dn = findit(name,&s,0)) < 0)                 /* M01.01.1212.01 */
                return( (long)dn );
        if (!dn)                                                /* M01.01.1214.01 */
                return( EFILNF );

 /* now scan for filename */

        pos = 0;
        if (!(f = scan(dn,s,FA_NORM,&pos)))
                return(EFILNF);

        if (f->f_attrib & FA_RO)
                return(EACCDN);

        pos -= 32;

        return(ixdel(dn,f,pos));
}


/*
**  ixdel - internal delete file.
**
**  Traverse the list of files open for this directory node.
**  If a file is found that has the same position in the directory as the one 
**  we are to delete, then scan the system file table to see if this process is 
**  then owner.  If so, then close it, otherwise abort.
**  
**  NOTE:       both 'for' loops scan for the entire length of their 
**              respective data structures, and do not drop out of the loop on 
**              the first occurence of a match.
**      Used by
**              ixcreat()
**              xunlink()
**              xrmdir()
** 
*/

long ixdel(DND *dn, FCB *f, long pos)
{
        register OFD *fd;
        DMD *dm;
        register short n2;
        short n;
        char c;


        for (fd = dn->d_files; fd; fd = fd->o_link)
                if (fd->o_dirbyt == pos)
                        for (n = 0; n < OPNFILES; n++)
                                if (sft[n].f_ofd == fd)
                                {
                                        if (sft[n].f_own == run)
                                                ixclose(fd,0);
                                        else
                                                return(EACCDN);
                                }
/*
 * Traverse this file's chain of allocated clusters, freeing them.
 */

        dm = dn->d_drv;
        n = f->f_clust;
        swpw(n);

        while (n && (n != -1))
        {
                n2 = getcl(n,dm);
                clfix(n,0,dm);
                n = n2;
        }

/*
 * Mark the directory entry as erased.
 */

        fd = dn->d_ofd;
        ixlseek(fd,pos);
        c = 0xe5;
        ixwrite(fd,1L,&c);
        ixclose(fd,CL_DIR);

/*
**      NOTE    that the preceding routines that do physical disk operations 
**      will 'longjmp' on failure at the BIOS level, thereby allowing us to 
**      simply return with E_OK.
*/

        return(E_OK);
}


/*
**  match1 - check for bad chars in path name
**      check thru test string to see if any character in the ref str is found
**      (utility routine for ixcreat())
**      by scc
*/

static BOOL match1(char *ref, char *test)
{
        register char   *t ;

        while( *ref )
        {
                for( t = test; *t ; t++ )
                        if( *t == *ref )
                                return( TRUE ) ;
                ref++ ;
        }

        return( FALSE ) ;
}




