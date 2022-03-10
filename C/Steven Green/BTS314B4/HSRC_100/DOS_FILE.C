/*=============================================================================

                              HydraCom Version 1.00

                         A sample implementation of the
                   HYDRA Bi-Directional File Transfer Protocol

                             HydraCom was written by
                   Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED

                       The HYDRA protocol was designed by
                 Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT and
                             Joaquim H. Homrighausen
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED


  Revision history:
  06 Sep 1991 - (AGL) First tryout
  .. ... .... - Internal development
  11 Jan 1993 - HydraCom version 1.00, Hydra revision 001 (01 Dec 1992)


  For complete details of the Hydra and HydraCom licensing restrictions,
  please refer to the license agreements which are published in their entirety
  in HYDRACOM.C and LICENSE.DOC, and also contained in the documentation file
  HYDRACOM.DOC

  Use of this file is subject to the restrictions contained in the Hydra and
  HydraCom licensing agreements. If you do not find the text of this agreement
  in any of the aforementioned files, or if you do not have these files, you
  should immediately contact LENTZ SOFTWARE-DEVELOPMENT and/or Joaquim
  Homrighausen at one of the addresses listed below. In no event should you
  proceed to use this file without having accepted the terms of the Hydra and
  HydraCom licensing agreements, or such other agreement as you are able to
  reach with LENTZ SOFTWARE-DEVELOMENT and Joaquim Homrighausen.


  Hydra protocol design and HydraCom driver:         Hydra protocol design:
  Arjen G. Lentz                                     Joaquim H. Homrighausen
  LENTZ SOFTWARE-DEVELOPMENT                         389, route d'Arlon
  Langegracht 7B                                     L-8011 Strassen
  3811 BT  Amersfoort                                Luxembourg
  The Netherlands
  FidoNet 2:283/512, AINEX-BBS +31-33-633916         FidoNet 2:270/17
  arjen_lentz@f512.n283.z2.fidonet.org               joho@ae.lu

  Please feel free to contact us at any time to share your comments about our
  software and/or licensing policies.

=============================================================================*/

#include "hydracom.h"
#ifdef __MSDOS__
#include <fcntl.h>
#include <share.h>
#include <io.h>
#endif


static boolean dos_sharing = false;


void dos_sharecheck (void)    /* SHARE installed? set dos_sharing true/false */
{
#if __MSDOS__
        union REGS regs;

        regs.x.ax = 0x1000;                             /* DOS Multiplexer   */
        int86(0x2f,&regs,&regs);                        /* INT 2Fh sub 1000h */
        dos_sharing = (regs.h.al == 0xff) ? true : false;
#endif
}/*dos_sharecheck()*/


int dos_open (char *pathname, byte create)
{
        register int access;

#ifdef __MSDOS__
        access = O_RDWR | O_BINARY;
        if (create) {
           access |= O_CREAT;
           if (create == 2)
              access |= O_TRUNC;
        }

        return (open(pathname, access,
                     create ? S_IREAD | S_IWRITE : 0));
#endif
#ifdef __TOS__
        access = O_RDWR;
        if (create) {
           access |= O_CREAT;
           if (create == 2)
              access |= O_TRUNC;
        }

        return (open(pathname, access, 0));
#endif
}/*dos_open()*/


int dos_sopen (char *pathname, byte create)
{
        register int access;

#ifdef __MSDOS__
        access = O_RDWR | O_BINARY;
        if (create) {
           access |= O_CREAT;
           if (create == 2)
              access |= O_TRUNC;
        }

        return (sopen(pathname, access,
                   dos_sharing ? SH_DENYWR : 0,
                   create ? S_IREAD | S_IWRITE : 0));
#endif
#ifdef __TOS__
        access = O_RDWR;
        if (create) {
           access |= O_CREAT;
           if (create == 2)
              access |= O_TRUNC;
        }

        return (open(pathname, access, 0));
#endif
}/*dos_sopen()*/


int dos_sappend (char *pathname, byte create)
{
        register int access;

#ifdef __MSDOS__
        access = O_WRONLY | O_APPEND | O_TEXT;
        if (create) {
           access |= O_CREAT;
           if (create == 2)
              access |= O_TRUNC;
        }

        return (sopen(pathname, access,
                      dos_sharing ? SH_DENYWR : 0,
                      create ? S_IREAD | S_IWRITE : 0));
#endif
#ifdef __TOS__
        access = O_WRONLY | O_APPEND;
        if (create) {
           access |= O_CREAT;
           if (create == 2)
              access |= O_TRUNC;
        }

        return (open(pathname, access, 0));
#endif
}/*dos_sappend()*/


int dos_close (int handle)
{
        return (close(handle));
}/*dos_close()*/


int dos_lock (int handle, long offset, long len)
{
#ifdef __MSDOS__
        if (dos_sharing)
           while (!lock(handle,offset,len));
#endif

        return (0);
}/*dos_lock()*/


int dos_unlock (int handle, long offset, long len)
{
#ifdef __MSDOS__
        return (dos_sharing ? unlock(handle,offset,len) : 0);
#endif
#ifdef __TOS__
        return 0;
#endif
}/*dos_unlock()*/


long dos_seek (int handle, long offset, int fromwhere)
{
        return (lseek(handle,offset,fromwhere));
}/*dos_seek()*/


long dos_tell (int handle)
{
#ifdef __MSDOS__
        return (tell(handle));
#endif
#ifdef __TOS__
        return (lseek(handle,0L,SEEK_CUR));
#endif
}/*dos_tell()*/


int dos_read (int handle, void *buf, word len)
{
#ifdef __MSDOS__
        return (_read(handle,buf,len));
#endif
#ifdef __TOS__
        return ((int) read(handle,buf,len));
#endif
}/*dos_read()*/


int dos_write (int handle, void *buf, word len)
{
#ifdef __MSDOS__
        return (_write(handle,buf,len));
#endif
#ifdef __TOS__
        return ((int) write(handle,buf,len));
#endif
}/*dos_write()*/


/* ----------------------------------------------------------------------------
                        oflags                  mode
        r       O_RDONLY                        don't care
        w       O_CREAT | O_WRONLY | O_TRUNC    S_IWRITE
        a       O_CREAT | O_WRONLY | O_APPEND   S_IWRITE
        r+      O_RDWR                          don't care
        w+      O_RDWR | O_CREAT | O_TRUNC      S_IWRITE | S_IREAD
        a+      O_RDWR | O_CREAT | O_APPEND     S_IWRITE | S_IREAD
---------------------------------------------------------------------------- */
FILE *sfopen (char *name, char *mode, int shareflag)
{
#ifdef __MSDOS__
        int   fd, access, flags;
        char  *type = mode, c;
        FILE *fp;

        if ((c = *type++) == 'r') {
           access = O_RDONLY;
           flags = 0;
        }
        else if (c == 'w') {
           access = O_WRONLY | O_CREAT | O_TRUNC;
           flags = S_IWRITE;
        }
        else if (c == 'a') {
           access = O_RDWR   | O_CREAT | O_APPEND;
           flags = S_IWRITE;
        }
        else
           return (NULL);

        c = *type++;

        if (c == '+' || (*type == '+' && (c == 't' || c == 'b'))) {
           if (c == '+') c = *type;
           access = (access & ~(O_RDONLY | O_WRONLY)) | O_RDWR;
           flags = S_IREAD | S_IWRITE;
        }

        if      (c == 't') access |= O_TEXT;
        else if (c == 'b') access |= O_BINARY;
        else               access |= (_fmode & (O_TEXT | O_BINARY));

        if (dos_sharing)
           access |= shareflag;

        fd = open(name, access, flags);

        if (fd < 0) return (NULL);

        if ((fp = fdopen(fd,mode)) == NULL)
           close(fd);
        else if (setvbuf(fp,NULL,_IOFBF,BUFSIZ)) {
           fclose(fp);
           return (NULL);
        }

        return (fp);
#endif

#ifdef __TOS__
        char *p, *q, nm[10];

        strcpy(nm,mode);
        for(p=q=nm; *p; p++) if (*p!='t') *q++=*p;
        *q='\0';

        return (fopen(name,nm));
#endif
}/*sfopen()*/


/* end of dos_file.c */
