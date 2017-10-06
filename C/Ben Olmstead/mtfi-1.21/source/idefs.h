/**********************************************************************/
/* MTFI 1.21: idefs.h

 This file is not truly a part of either the interface or the core.
 It is a part of the instruction set definition for Funge-93 and
 Funge-97.  It is most appropriately called a part of the core,
 however, since adding a new funge may require changing mtfi.c, which
 is *definitely* a core file.  (mtfi.c needs to be changed if the new
 funge is more than just a new instruction set--if it has different
 space (God help you if that's the case; messing with get() and put()
 is a nightmare) layout, or if it has a different method of wrapping,
 or whatever.  (movewithwrap() is a little easier, though still not
 simple, to modify.))

 Anyway, this file just typedefs all the functions in idefs.c.  That's
 it.  Honest.

     This code is Copyright 1998 Ben Olmstead.  Distribute according
 to the GNU Copyleft (see the file COPYING in the archive from which
 this file was pulled).  Considering the coding standards that the FSF
 demands for anything written for them, this probably is making them
 have fits, but then, FSF code looks like trash, even if it is easy to
 understand.
*/

#ifndef IDEFS_H_INCLUDED
#define IDEFS_H_INCLUDED

int absd( struct thread**, fdat, struct fmach* );                /* X */
int ad96( struct thread**, fdat, struct fmach* );                /* + */
int addn( struct thread**, fdat, struct fmach* );                /* + */
int asct( struct thread**, fdat, struct fmach* );                /* U */
int chrm( struct thread**, fdat, struct fmach* );                /* ' */
int clst( struct thread**, fdat, struct fmach* );                /* n */
int cm96( struct thread**, fdat, struct fmach* );                /* ' */
int comm( struct thread**, fdat, struct fmach* );                /* ; */
int dest( struct thread**, fdat, struct fmach* );                /* D */
int divn( struct thread**, fdat, struct fmach* );                /* / */
int du96( struct thread**, fdat, struct fmach* );                /* : */
int dupl( struct thread**, fdat, struct fmach* );                /* : */
int dv96( struct thread**, fdat, struct fmach* );                /* / */
int east( struct thread**, fdat, struct fmach* );                /* > */
int endp( struct thread**, fdat, struct fmach* );                /* E */
int file( struct thread**, fdat, struct fmach* );                /* F */
int ga96( struct thread**, fdat, struct fmach* );                /* g */
int geta( struct thread**, fdat, struct fmach* );                /* g */
int getr( struct thread**, fdat, struct fmach* );                /* G */
int gr96( struct thread**, fdat, struct fmach* );                /* G */
int gret( struct thread**, fdat, struct fmach* );                /* ` */
int gt96( struct thread**, fdat, struct fmach* );                /* ` */
int hd96( struct thread**, fdat, struct fmach* );                /* h */
int hi96( struct thread**, fdat, struct fmach* );                /* _ */
int hzif( struct thread**, fdat, struct fmach* );                /* _ */
int ic96( struct thread**, fdat, struct fmach* );                /* ~ */
int ichr( struct thread**, fdat, struct fmach* );                /* ~ */
int im96( struct thread**, fdat, struct fmach* );                /* i */
int in96( struct thread**, fdat, struct fmach* );                /* & */
int inum( struct thread**, fdat, struct fmach* );                /* & */
int invm( struct thread**, fdat, struct fmach* );                /* i */
int jmpz( struct thread**, fdat, struct fmach* );                /* z */
int jump( struct thread**, fdat, struct fmach* );                /* J */
int kill( struct thread**, fdat, struct fmach* );                /* @ */
int lg96( struct thread**, fdat, struct fmach* );                /* ( */
int lget( struct thread**, fdat, struct fmach* );                /* ( */
int ln96( struct thread**, fdat, struct fmach* );                /* ! */
int lnot( struct thread**, fdat, struct fmach* );                /* ! */
int lp96( struct thread**, fdat, struct fmach* );                /* { */
int lput( struct thread**, fdat, struct fmach* );                /* { */
int md96( struct thread**, fdat, struct fmach* );                /* % */
int ml96( struct thread**, fdat, struct fmach* );                /* * */
int modn( struct thread**, fdat, struct fmach* );                /* % */
int muln( struct thread**, fdat, struct fmach* );                /* * */
int newt( struct thread**, fdat, struct fmach* );                /* T */
int nop0( struct thread**, fdat, struct fmach* );                /*   */
int nop1( struct thread**, fdat, struct fmach* );                /* o */
int norm( struct thread**, fdat, struct fmach* );             /* "";; */
int nort( struct thread**, fdat, struct fmach* );                /* ^ */
int oc96( struct thread**, fdat, struct fmach* );                /* , */
int ochr( struct thread**, fdat, struct fmach* );                /* , */
int on96( struct thread**, fdat, struct fmach* );                /* . */
int onum( struct thread**, fdat, struct fmach* );                /* . */
int pa96( struct thread**, fdat, struct fmach* );                /* p */
int pc96( struct thread**, fdat, struct fmach* );                /* ' */
int pn96( struct thread**, fdat, struct fmach* );              /* 0-9 */
int po96( struct thread**, fdat, struct fmach* );                /* $ */
int popn( struct thread**, fdat, struct fmach* );                /* $ */
int ppif( struct thread**, fdat, struct fmach* );                /* H */
int pr96( struct thread**, fdat, struct fmach* );                /* p */
int ps96( struct thread**, fdat, struct fmach* );                /* " */
int pshc( struct thread**, fdat, struct fmach* );                /* ' */
int pshd( struct thread**, fdat, struct fmach* );                /* Y */
int pshn( struct thread**, fdat, struct fmach* );              /* 0-9 */
int pshs( struct thread**, fdat, struct fmach* );                /* " */
int pshx( struct thread**, fdat, struct fmach* );              /* a-f */
int pt93( struct thread**, fdat, struct fmach* );                /* p */
int pu96( struct thread**, fdat, struct fmach* );          /* special */
int puta( struct thread**, fdat, struct fmach* );                /* p */
int putr( struct thread**, fdat, struct fmach* );                /* P */
int quem( struct thread**, fdat, struct fmach* );                /* q */
int repo( struct thread**, fdat, struct fmach* );                /* R */
int revr( struct thread**, fdat, struct fmach* );                /* A */
int rg96( struct thread**, fdat, struct fmach* );                /* ) */
int rget( struct thread**, fdat, struct fmach* );                /* ) */
int rndd( struct thread**, fdat, struct fmach* );                /* ? */
int roll( struct thread**, fdat, struct fmach* );                /* r */
int rp96( struct thread**, fdat, struct fmach* );                /* } */
int rput( struct thread**, fdat, struct fmach* );                /* } */
int sb96( struct thread**, fdat, struct fmach* );                /* - */
int sbsm( struct thread**, fdat, struct fmach* );                /*   */
int sk96( struct thread**, fdat, struct fmach* );                /* j */
int skip( struct thread**, fdat, struct fmach* );                /* # */
int skpn( struct thread**, fdat, struct fmach* );                /* j */
int sout( struct thread**, fdat, struct fmach* );                /* v */
int strm( struct thread**, fdat, struct fmach* );                /* " */
int subn( struct thread**, fdat, struct fmach* );                /* - */
int sw96( struct thread**, fdat, struct fmach* );                /* \ */
int swap( struct thread**, fdat, struct fmach* );                /* \ */
int swim( struct thread**, fdat, struct fmach* );                /* s */
int swit( struct thread**, fdat, struct fmach* );                /* w */
int test( struct thread**, fdat, struct fmach* );                /* V */
int tiqm( struct thread**, fdat, struct fmach* );                /* Q */
int trnl( struct thread**, fdat, struct fmach* );                /* [ */
int trnr( struct thread**, fdat, struct fmach* );                /* ] */
int ussm( struct thread**, fdat, struct fmach* );                /*   */
int vi96( struct thread**, fdat, struct fmach* );                /* | */
int vtif( struct thread**, fdat, struct fmach* );                /* | */
int west( struct thread**, fdat, struct fmach* );                /* < */
int ybsc( struct thread**, fdat, struct fmach* );                /* y */

#endif
