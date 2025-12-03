/*
 *   This program converts dvi files to dvi files; it can be used
 *      reverse the pages            -
 *      select even                  2:1
 *      or odd                       2:0
 *      print both on same page      2:0,1(5.5in,0in)
 *      do folded brochures          4:-3,0(5.5in,0in)
 *                                   4:1,-2(5.5in,0in)
 *      etc.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#pragma warn -rvl
#pragma warn -pia
#pragma warn -pro
#define MAXPPERP (32)
/*
 *   Some globals to keep everyone happy.
 */
long **pagepos ;     /* an array holding the positions of each page. */
long numpages ;      /* the total number of pages in the dvi file. */
long TeXfonts[256] ; /* information about each font */
char fontseen[256] ; /* have we defined this font yet? */
int modulo ;         /* our mod value */
struct pagespec {
   int pageno, reversed ;
   long hoffset, voffset ; /* in scaled points */
} pages[MAXPPERP] ;  /* the organization of the pages on output */
int pagesperpage ;   /* how many pages crammed onto each page? */
FILE *infile ;       /* input dvi file (cannot be a stream) */
char temp[255] ;    /* a temporary place to put things */
unsigned char *dvibuf ; /* our entire dvi file */
long inlength ;      /* the length of the input dvi file */
long postloc ;       /* location of the postamble */
long mag ;           /* magnification factor */
long pagecount ;     /* number of actual pages */
long landscape ;     /* if landscape special, here it is! */
int rem0special ;    /* should we remove the first first-page special? */
long prevpp = -1 ;   /* previous page pointer on output */
long outputpages ;   /* number of pages output */
long dviloc ;        /* our position in the output file */
long pagefake ;      /* number of pages, rounded up to multiple of modulo */
/*
 *   Some def's to make things friendlier.
 */
#define fontdeflen(p) (16L+dvibuf[(p)+14]+dvibuf[(p)+15])
/*
 *   This array holds values that indicate the length of a command, if
 *   we aren't concerned with that command (which is most of them) or
 *   zero, if it is a special case.  This makes running through the
 *   dvi file a lot easier (and probably faster) than any form of
 *   dispatch table, especially since we really don't care what the
 *   pages are made of.
 */
short comlen[256] = {
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, /* 0-15 */
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, /* 16-31 */
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, /* 32-47 */
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, /* 48-63 */
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, /* 64-79 */
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, /* 80-95 */
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, /* 96-111 */
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, /* 112-127 */
   2, 3, 4, 5, 9, 2, 3, 4, 5, 9, 1, 0, 0, 1, 1, 2, /* 128-143 */
   3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 2, 3, 4, /* 144-159 */
   5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 0, 0, 0, 0, 0, /* 160-175 */
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, /* 176-191 */
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, /* 192-207 */
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, /* 208-223 */
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4, 5, 0, /* 224-239 */
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};/* 240-255 */
/*
 *   Print a usage error messsage, and quit.
 */
usage() {
   fprintf(stderr,
       "This is dvidvi 0.5, Copyright (C) 1988, Radical Eye Software\n") ;
   fprintf(stderr, "Usage:  dvidvi modulo:pagespecs input[.dvi] [output]\n") ;
   exit(1) ;
}
/*
 *   Print an error message, and exit if it is fatal.
 */
error(s)
char *s ;
{
   fprintf(stderr, "dvidvi: %s\n", s) ;
   if (*s == '!')
      exit(1) ;
}
/*
 *   This function calculates approximately (whole + num/den) * sf.
 *   No need for real extreme accuracy; one ten thousandth of an
 *   inch should be sufficient.
 *
 *   No `sf' parameter means to use an old one; inches are assumed
 *   originally.
 *
 *   Assumptions:
 *
 *      0 <= num < den <= 10000
 *      0 <= whole
 */
long defaultscale = 4736286L;
long scale(whole, num, den, sf)
long whole, num, den, sf ;
{
   long v ;

   if (sf)
      defaultscale = sf ;
   else
      sf = defaultscale ;
   v = whole * sf + num * (sf / den) ;
   if (v / sf != whole || v < 0 || v > 0x40000000L)
      error("! arithmetic overflow in parameter") ;
   sf = sf % den ;
   v += (sf * num * 2 + den) / (2 * den) ;
   return(v) ;
}
/*
 *   Multiplies *p by 1000 and divides it by mag.  Avoiding overflow.
 *
 *   1 <= mag <= 1000000 ;
 *   0 <= *p <= 2^30
 *
 *   (Could blow up if a parameter * mag / 1000 > 2^30 sp.)
 */
scalemag(p)
long *p ;
{
   int negative ;

   negative = 0 ;
   if (*p < 0) {
      negative = 1 ;
      *p = - *p ;
   }
   *p = 1000 * (*p / mag) + (2000 * (*p % mag) + mag) / (2 * mag) ;
   if (negative)
      *p = - *p ;
}
/*
 *   Convert a sequence of digits into a long; return -1 if no digits.
 *   Advance the passed pointer as well.
 */
long myatol(s)
char **s ;
{
   register char *p ;
   register long result ;

   result = 0 ;
   p = *s ;
   while ('0' <= *p && *p <= '9') {



      if (result > 100000000L)
         error("! arithmetic overflow in parameter") ;
      result = 10 * result + *p++ - '0' ;
   }
   if (p == *s)
      usage() ;
   else {
      *s = p ;
      return(result) ;
   }
}
/*
 *   Get a dimension, allowing all the various extensions, and
 *   defaults.
 */
long myatodim(s)
char **s ;
{
   register long w, num, den ;
   register char *p ;
   int negative = 0 ;

   p = *s ;
   if (**s == '-') {
      (*s)++ ;
      negative = 1 ;
   }
   w = myatol(s) ;
   if (w < 0)
      usage() ;
   p = *s ;
   num = 0 ;
   den = 1 ;
   if (*p == '.') {
      p++ ;
      while ('0' <= *p && *p <= '9') {
         if (den < 1000) {
            den *= 10 ;
            num = num * 10 + *p - '0' ;
         }
         p++ ;
      }
   }
/*
 *   Allowed units are `in', `cm', `mm', `pt', `sp', `cc', `dd', and `pc';
 *   must be in lower case.
 */
   if (*p == 'c' && p[1] == 'm') {
/*  centimeters need to be multiplied by 72.27 * 2^16 / 2.54, or 1 864 680 */
      w = scale(w, num, den, 1864680L) ;
   } else if (*p == 'p' && p[1] == 't') {
/*  real points need to be multiplied by 2^16 */
      w = scale(w, num, den, 65536L) ;
   } else if (*p == 'p' && p[1] == 'c') {
/*  picas need to be multiplied by 65536 * 12, or 786 432 */
      w = scale(w, num, den, 786432L) ;
   } else if (*p == 'm' && p[1] == 'm') {
/*  millimeters need to be multiplied by 72.27 * 2^16 / 25.4, or 186 468 */
      w = scale(w, num, den, 186468L) ;
   } else if (*p == 's' && p[1] == 'p') {
/*  scaled points are already taken care of; simply round */
      w = scale(w, num, den, 1L) ;
   } else if (*p == 'b' && p[1] == 'p') {
/*  big points need to be multiplied by 72.27 * 65536 / 72, or 65782 */
      w = scale(w, num, den, 65782L) ;
   } else if (*p == 'd' && p[1] == 'd') {
/*  didot points need to be multiplied by 65536 * 1238 / 1157, or 70124 */
      w = scale(w, num, den, 70124L) ;
   } else if (*p == 'c' && p[1] == 'c') {
/*  cicero need to be multiplied by 65536 * 1238 / 1157 * 12, or 841 489 */
      w = scale(w, num, den, 841489L) ;
   } else if (*p == 'i' && p[1] == 'n') {
/*  inches need to be multiplied by 72.27 * 65536, or 4 736 286 */
      w = scale(w, num, den, 4736286L) ;
   } else {
/*  use default values */
      w = scale(w, num, den, 0L) ;
      p -= 2 ;
   }
   p += 2 ;
   *s = p ;
   return(negative?-w:w) ;
}
/*
 *   Parse the arguments to the routine, and stuff everything away
 *   into those globals above.
 */
processargs(argc, argv)
int argc ;
char *argv[] ;
{
   char *p, *q ;
   int pageno ;
   long hoffset, voffset ;
   int reversed ;

   if (argc < 3 || argc > 4)
      usage() ;
   modulo = 1 ;
   argv++ ;
   argc-- ;
   p = argv[0] ;
/*
 *   Is there a modulo supplied?  Grab it if so; otherwise default to 1.
 */
   for (q=p; *q != 0; q++)
      if (*q == ':')
         break ;
   if (*q == ':') {
      modulo = myatol(&p) ;
      if (*p != ':')
         usage() ;
      if (modulo < 1 || modulo > MAXPPERP)
         error("! modulo must lie between 1 and 32") ;
      p++ ;
   }
/*
 *   This loop grabs all of the page specifications.
 */
   pagesperpage = 0 ;
   while (*p != 0) {
      if (pagesperpage >= MAXPPERP)
         error("! too many page specifications") ;
      if (*p == '-') {
         reversed = 1 ;
         p++ ;
      } else
         reversed = 0 ;
      if (*p == 0 || *p == '(' || *p == ',')
         pageno = 0 ;
      else
         pageno = myatol(&p) ;
      if (*p == '(') {
         p++ ;
         hoffset = myatodim(&p) ;
         if (*p++ != ',')
            usage() ;
         voffset = myatodim(&p) ;
         if (*p++ != ')')
            usage() ;
      } else {
         hoffset = 0 ;
         voffset = 0 ;
      }
      pages[pagesperpage].hoffset = hoffset ;
      pages[pagesperpage].voffset = voffset ;
      pages[pagesperpage].pageno = pageno ;
      pages[pagesperpage].reversed = reversed ;
      pagesperpage++ ;
      if (*p == ',')
         p++ ;
   }
/*
 *   Finally we get around to opening our input and output files.
 */
   argc-- ;
   argv++ ;
   if ((infile=fopen(argv[0],"rb"))==NULL) {
      strcpy(temp, argv[0]) ;
      strcat(temp, ".dvi") ;
      if ((infile=fopen(temp,"rb"))==NULL)
         error("! can't open input file") ;
   }
   argc-- ;
   argv++ ;
   for (q=NULL, p=argv[0]; *p; p++)
      if (*p == '.')
         q = p ;
      else if (*p == '/' || *p == ':')
         q = NULL ;
   strcpy(temp, argv[0]) ;
   if (q==NULL)
      strcat(temp, ".dvi") ;
   if (argc > 0) {
      if (freopen(temp, "wb", stdout)==NULL)
         error("! can't open output file") ;
   }
}
/*
 *   Grabs an unsigned two bytes.
 */
long u2(where)
long where ;
{
   return(((unsigned int)dvibuf[where] << 8) + dvibuf[where + 1]) ;
}
/*
 *   Grabs a longword from the file.
 */
long quad(where)
register long where ;
{
   return(((unsigned long)u2(where) << 16) + u2(where+2)) ;
}
/*
 *   Grabs a pointer, and checks it for validity.
 */
long ptr(where)
register long where ;
{
   where = quad(where) ;
   if (where < -1L || where > inlength)
      error("! dvi file malformed; impossible pointer") ;
   return(where) ;
}
/*
 *   This routine finds a particular page, numbered sequentially
 *   from the beginning, by tracing the pointers backwards.
 */
long pageloc(num)
long num ;
{
   long p ;

   if (num >= pagecount)
      return(0L) ;
   num++ ;
   for (p = ptr(postloc+1); num < pagecount; num++)
      p = ptr(p+41) ;
   if (dvibuf[p] != 139)
      error("! missed a bop somehow") ;
   return(p) ;
}
/*
 *   This routine simply reads the entire dvi file, and then initializes
 *   some values about it.
 */
readdvifile() {
   long p ;

   fseek(infile, 0L, 2) ;
   inlength = ftell(infile) ;
   fseek(infile, 0L, 0) ;
   dvibuf = (unsigned char *)malloc(inlength) ;
   if (dvibuf == NULL)
      error("! not enough memory to hold input dvi file") ;
   if (fread(dvibuf, 1, inlength, infile) != inlength)
      error("! problem reading entire file into memory") ;
   fclose(infile) ;
   infile = NULL ;
   if (inlength < 10)
      error("! dvi file too short") ;
   for (p=inlength - 3; p > 0; p--)
      if (dvibuf[p] == 2 && dvibuf[p+1] == 0xdf /* dave fuchs */ && 
                            dvibuf[p+2] == 0xdf)
         break ;
   if (p < 10)
      error("! rather short dvi file, ain't it?") ;
   postloc = ptr(p - 4) ;
   if (quad(postloc + 5) != 25400000L || quad(postloc + 9) != 473628672L)
      error("! change this program to support non-TeX num/den values") ;
   mag = quad(postloc + 13) ;
   if (mag < 1 || mag > 1000000L)
      error("! impossible magnification value") ;
   pagecount = u2(postloc + 27) ;
   if (pagecount < 1 || pagecount > 1000000L)
      error("! impossible page count value") ;
/*
 *   That's enough error checking; we probably have a correct dvi file.
 *   Let's convert all the values we got from the command line into
 *   units that we can actually use in the dvi file.
 */
   for (p=0; p<pagesperpage; p++) {
      scalemag(&(pages[p].hoffset)) ;
      scalemag(&(pages[p].voffset)) ;
   }
/*
 *   Now let's grab us some font pointers.
 */
   p = postloc + 29 ;
   while (1) {
      if (dvibuf[p] == 249)
         break ;
      if (dvibuf[p] == 138)
         p++ ;
      else if (dvibuf[p] == 243) {
         TeXfonts[dvibuf[p+1]] = p ;
         p += fontdeflen(p) ;
      } else
         error("! only nop's and font def's allowed in postamble") ;
   }
/*
 *   Now we check for a landscape special.  It should be the
 *   *first* thing in the page that is at all complicated.
 */
   p = pageloc(0L) + 45 ;
   while (comlen[dvibuf[p]])
      p += comlen[dvibuf[p]] ;
   if (dvibuf[p] == 239 && strncmp((char *)dvibuf + p + 2, "landscape", 9)==0) {
      landscape = p ;
      rem0special = 1 ;
   }
}
/*
 *   Output a single byte, keeping track of where we are.
 */
dvibyte(c)
unsigned char c ;
{
   putc(c, stdout) ;
   dviloc++ ;
}
/*
 *   Send out two bytes.
 */
dvi2(v)
long v ;
{
   dvibyte((unsigned char)((v >> 8) & 255U)) ;
   dvibyte((unsigned char)(v & 255U)) ;
}
/*
 *   Send out a longword.
 */
dviquad(v)
long v ;
{
   dvi2((v >> 16) & 65535U) ;
   dvi2(v & 65535U) ;
}
/*
 *   This routine just copies some stuff from the buffer on out.
 */
putbuf(where, length)
long where, length ;
{
   register unsigned char *p ;

   for (p=dvibuf + where; length > 0; p++, length--)
      dvibyte(*p) ;
}
/*
 *   This routine outputs a string, terminated by null.
 */
putstr(s)
register unsigned char *s ;
{
   while (*s)
      dvibyte(*s++) ;
}
/*
 *   Here we write the preamble to the dvi file.
 */
writepreamble() {
/*   just copy the first 14 bytes of the file */
   putbuf(0L, 14L) ;
/*   and put our identifier. */
   putstr("\015dvidvi output") ;
}
/*
 *   This routine writes out a font definition.
 */
putfontdef(f)
int f ;
{
   long p ;

   p = TeXfonts[f] ;
   putbuf(p, fontdeflen(p)) ;
}
/*
 *   The postamble is next.
 */
writepostamble() {
   int i ;
   long p ;

   p = dviloc ;
   dvibyte(248) ;
   dviquad(prevpp) ;
   putbuf(postloc+5, 20) ;
   dvi2(u2(postloc+25)+1L) ; /* increase stack depth by 1 */
   dvi2(outputpages) ;
   for (i=0; i<256; i++)
      if (fontseen[i])
         putfontdef(i) ;
   dvibyte(249) ;
   dviquad(p) ;
   dvibyte(2) ;
   dviquad(0xdfdfdfdfL) ;
   while (dviloc & 3)
      dvibyte(0xdf) ;
   fclose(stdout) ;
}
/*
 *   This routine starts a page, by writing out a bop command.
 */
beginpage() {
   int i ;
   long p ;

   p = dviloc ;
   dvibyte(139) ;
   dviquad(outputpages) ;
   for (i=0; i<9; i++)
      dviquad(0L) ;
   dviquad(prevpp) ;
   prevpp = p ;
}
/*
 *   This routine sends out a page.  We need to handle the
 *   landscape special, though.
 */
dopage(num)
long num ;
{
   register long p ;
   register int len ;
   long v, oldp ;

   p = pageloc(num) + 45 ;
   while (dvibuf[p] != 140) {
      if (len=comlen[dvibuf[p]]) {    /* most commands are simple */
         putbuf(p, (long)len) ;
         p += len ;
      } else {   /* but there are a few we need to treat specially */
         len = dvibuf[p] ;
         if (171 <= len && len <= 235) {
            p++ ;
            if (len == 235)
               len = dvibuf[p++] ;
            else
               len -= 171 ;
            if (!fontseen[len]) {
               putfontdef(len) ;
               fontseen[len] = 1 ;
            }
            if (len < 64)
               dvibyte(171 + len) ;
            else {
               dvibyte(235) ;
               dvibyte(len) ;
            }
         } else {
            v = 0 ;
            oldp = p++ ;
            switch(len) {
case 242:      v = dvibuf[p++] ;
case 241:      v = (v << 8) + dvibuf[p++] ;
case 240:      v = (v << 8) + dvibuf[p++] ;
case 239:      v = (v << 8) + dvibuf[p++] ;
/*
 *   Remove a landscape special on page 0, if one is found.
 */
               if (num || ! rem0special ||
                    strncmp((char *)dvibuf + oldp + len - 237, "landscape", 9))
                  putbuf(oldp, v + len - 237) ;
               p = oldp + v + len - 237 ;
               break ;
case 243: case 244: case 245: case 246:
               p += len - 230 ;
               p += dvibuf[p] + dvibuf[p+1] + 2 ;
               break ;
default:       fprintf(stderr, "Bad dvi command was %d at %ld\n", len, p) ;
               error("! lost sync dvi in file lost dvi sync file in") ;
            }
         }
      }
   }
}
/*
 *   Here we end a page.  Simple enough.
 */
endpage() {
   outputpages++ ;
   dvibyte(140) ;
}
/*
 *   This is our main routine for output, which runs through all the
 *   pages we need to output.
 */
writedvifile() {
   long pagenum ;
   int ppp ;
   long actualpageno ;
   struct pagespec *ps ;
   long p ;

   writepreamble() ;
   pagefake = (pagecount + modulo - 1) / modulo * modulo ;
   for (pagenum = 0; pagenum < pagefake; pagenum += modulo) {
      beginpage() ;
      for (ppp = 0, ps=pages; ppp < pagesperpage; ppp++, ps++) {
         if (landscape) {
            putbuf(landscape, dvibuf[landscape+1]+2L) ;
            landscape = 0 ;
         }
         if (ps->reversed)
            actualpageno = pagefake - pagenum - modulo + ps->pageno ;
         else
            actualpageno = pagenum + ps->pageno ;
         if (actualpageno < pagecount) {
            if (pagesperpage)
               dvibyte(141) ;
            if (ps->hoffset) {
               dvibyte(146) ;
               dviquad(ps->hoffset) ;
            }
            if (ps->voffset) {
               dvibyte(160) ;
               dviquad(ps->voffset) ;
            }
            dopage(actualpageno) ;
            if (pagesperpage)
               dvibyte(142) ;
         }
      }
      endpage() ;
   }
   writepostamble() ;
}
main(argc, argv)
int argc ;
char *argv[] ;
{
   processargs(argc, argv) ;
   readdvifile() ;
   writedvifile() ;
}
