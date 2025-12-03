*** dvidvi.org	Mon Jun 17 17:23:26 1991
--- dvidvi.c	Mon Jun 17 18:05:50 1991
***************
*** 8,14 ****
   *                                   4:1,-2(5.5in,0in)
   *      etc.
   */
! #include "stdio.h"
  #define MAXPPERP (32)
  /*
   *   Some globals to keep everyone happy.
--- 8,19 ----
   *                                   4:1,-2(5.5in,0in)
   *      etc.
   */
! #include <stdio.h>
! #include <stdlib.h>
! #include <string.h>
! #pragma warn -rvl
! #pragma warn -pia
! #pragma warn -pro
  #define MAXPPERP (32)
  /*
   *   Some globals to keep everyone happy.
***************
*** 24,30 ****
  } pages[MAXPPERP] ;  /* the organization of the pages on output */
  int pagesperpage ;   /* how many pages crammed onto each page? */
  FILE *infile ;       /* input dvi file (cannot be a stream) */
! char *temp[255] ;    /* a temporary place to put things */
  unsigned char *dvibuf ; /* our entire dvi file */
  long inlength ;      /* the length of the input dvi file */
  long postloc ;       /* location of the postamble */
--- 29,35 ----
  } pages[MAXPPERP] ;  /* the organization of the pages on output */
  int pagesperpage ;   /* how many pages crammed onto each page? */
  FILE *infile ;       /* input dvi file (cannot be a stream) */
! char temp[255] ;    /* a temporary place to put things */
  unsigned char *dvibuf ; /* our entire dvi file */
  long inlength ;      /* the length of the input dvi file */
  long postloc ;       /* location of the postamble */
***************
*** 41,50 ****
   */
  #define fontdeflen(p) (16L+dvibuf[(p)+14]+dvibuf[(p)+15])
  /*
-  *   Forward declarations.
-  */
- char *malloc() ;
- /*
   *   This array holds values that indicate the length of a command, if
   *   we aren't concerned with that command (which is most of them) or
   *   zero, if it is a special case.  This makes running through the
--- 46,51 ----
***************
*** 101,107 ****
   *      0 <= num < den <= 10000
   *      0 <= whole
   */
! long defaultscale = 4736286 ;
  long scale(whole, num, den, sf)
  long whole, num, den, sf ;
  {
--- 102,108 ----
   *      0 <= num < den <= 10000
   *      0 <= whole
   */
! long defaultscale = 4736286L;
  long scale(whole, num, den, sf)
  long whole, num, den, sf ;
  {
***************
*** 156,162 ****
  
  
  
!       if (result > 100000000)
           error("! arithmetic overflow in parameter") ;
        result = 10 * result + *p++ - '0' ;
     }
--- 157,163 ----
  
  
  
!       if (result > 100000000L)
           error("! arithmetic overflow in parameter") ;
        result = 10 * result + *p++ - '0' ;
     }
***************
*** 313,322 ****
   */
     argc-- ;
     argv++ ;
!    if ((infile=fopen(argv[0],"r"))==NULL) {
        strcpy(temp, argv[0]) ;
        strcat(temp, ".dvi") ;
!       if ((infile=fopen(temp,"r"))==NULL)
           error("! can't open input file") ;
     }
     argc-- ;
--- 314,323 ----
   */
     argc-- ;
     argv++ ;
!    if ((infile=fopen(argv[0],"rb"))==NULL) {
        strcpy(temp, argv[0]) ;
        strcat(temp, ".dvi") ;
!       if ((infile=fopen(temp,"rb"))==NULL)
           error("! can't open input file") ;
     }
     argc-- ;
***************
*** 330,336 ****
     if (q==NULL)
        strcat(temp, ".dvi") ;
     if (argc > 0) {
!       if (freopen(temp, "w", stdout)==NULL)
           error("! can't open output file") ;
     }
  }
--- 331,337 ----
     if (q==NULL)
        strcat(temp, ".dvi") ;
     if (argc > 0) {
!       if (freopen(temp, "wb", stdout)==NULL)
           error("! can't open output file") ;
     }
  }
***************
*** 340,346 ****
  long u2(where)
  long where ;
  {
!    return((dvibuf[where] << 8) + dvibuf[where + 1]) ;
  }
  /*
   *   Grabs a longword from the file.
--- 341,347 ----
  long u2(where)
  long where ;
  {
!    return(((unsigned int)dvibuf[where] << 8) + dvibuf[where + 1]) ;
  }
  /*
   *   Grabs a longword from the file.
***************
*** 348,354 ****
  long quad(where)
  register long where ;
  {
!    return((u2(where) << 16) + u2(where+2)) ;
  }
  /*
   *   Grabs a pointer, and checks it for validity.
--- 349,355 ----
  long quad(where)
  register long where ;
  {
!    return(((unsigned long)u2(where) << 16) + u2(where+2)) ;
  }
  /*
   *   Grabs a pointer, and checks it for validity.
***************
*** 405,417 ****
     if (p < 10)
        error("! rather short dvi file, ain't it?") ;
     postloc = ptr(p - 4) ;
!    if (quad(postloc + 5) != 25400000 || quad(postloc + 9) != 473628672)
        error("! change this program to support non-TeX num/den values") ;
     mag = quad(postloc + 13) ;
!    if (mag < 1 || mag > 1000000)
        error("! impossible magnification value") ;
     pagecount = u2(postloc + 27) ;
!    if (pagecount < 1 || pagecount > 1000000)
        error("! impossible page count value") ;
  /*
   *   That's enough error checking; we probably have a correct dvi file.
--- 406,418 ----
     if (p < 10)
        error("! rather short dvi file, ain't it?") ;
     postloc = ptr(p - 4) ;
!    if (quad(postloc + 5) != 25400000L || quad(postloc + 9) != 473628672L)
        error("! change this program to support non-TeX num/den values") ;
     mag = quad(postloc + 13) ;
!    if (mag < 1 || mag > 1000000L)
        error("! impossible magnification value") ;
     pagecount = u2(postloc + 27) ;
!    if (pagecount < 1 || pagecount > 1000000L)
        error("! impossible page count value") ;
  /*
   *   That's enough error checking; we probably have a correct dvi file.
***************
*** 444,450 ****
     p = pageloc(0L) + 45 ;
     while (comlen[dvibuf[p]])
        p += comlen[dvibuf[p]] ;
!    if (dvibuf[p] == 239 && strncmp(dvibuf + p + 2, "landscape", 9)==0) {
        landscape = p ;
        rem0special = 1 ;
     }
--- 445,451 ----
     p = pageloc(0L) + 45 ;
     while (comlen[dvibuf[p]])
        p += comlen[dvibuf[p]] ;
!    if (dvibuf[p] == 239 && strncmp((char *)dvibuf + p + 2, "landscape", 9)==0) {
        landscape = p ;
        rem0special = 1 ;
     }
***************
*** 464,471 ****
  dvi2(v)
  long v ;
  {
!    dvibyte((unsigned char)(v >> 8)) ;
!    dvibyte((unsigned char)(v & 255)) ;
  }
  /*
   *   Send out a longword.
--- 465,472 ----
  dvi2(v)
  long v ;
  {
!    dvibyte((unsigned char)((v >> 8) & 255U)) ;
!    dvibyte((unsigned char)(v & 255U)) ;
  }
  /*
   *   Send out a longword.
***************
*** 473,480 ****
  dviquad(v)
  long v ;
  {
!    dvi2(v >> 16) ;
!    dvi2(v & 65535) ;
  }
  /*
   *   This routine just copies some stuff from the buffer on out.
--- 474,481 ----
  dviquad(v)
  long v ;
  {
!    dvi2((v >> 16) & 65535U) ;
!    dvi2(v & 65535U) ;
  }
  /*
   *   This routine just copies some stuff from the buffer on out.
***************
*** 601,607 ****
   *   Remove a landscape special on page 0, if one is found.
   */
                 if (num || ! rem0special ||
!                     strncmp(dvibuf + oldp + len - 237, "landscape", 9))
                    putbuf(oldp, v + len - 237) ;
                 p = oldp + v + len - 237 ;
                 break ;
--- 602,608 ----
   *   Remove a landscape special on page 0, if one is found.
   */
                 if (num || ! rem0special ||
!                     strncmp((char *)dvibuf + oldp + len - 237, "landscape", 9))
                    putbuf(oldp, v + len - 237) ;
                 p = oldp + v + len - 237 ;
                 break ;
