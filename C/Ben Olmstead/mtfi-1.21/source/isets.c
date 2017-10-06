/**********************************************************************/
/* MTFI 1.21: isets.c

 This code is Copyright 1998 Ben Olmstead.  Distribute according
 to the GNU Copyleft (see the file COPYING in the archive from which
 this file was pulled).  Considering the coding standards that the FSF
 demands for anything written for them, this probably is making them
 have fits, but then, FSF code looks like trash, even if it is easy to
 understand.
*/

#include "mtfi.h"
#include "idefs.h"
#include "ifacei.h"

     /*  ---          !     "     #     $     %     &     '     (   */
     /*   )     *     +     ,     -     .     /     0     1     2   */
     /*   3     4     5     6     7     8     9     :     ;     <   */
     /*   =     >     ?     @     A     B     C     D     E     F   */
     /*   G     H     I     J     K     L     M     N     O     P   */
     /*   Q     R     S     T     U     V     W     X     Y     Z   */
     /*   [     \     ]     ^     _     `     a     b     c     d   */
     /*   e     f     g     h     i     j     k     l     m     n   */
     /*   o     p     q     r     s     t     u     v     w     x   */
     /*   y     z     {     |     }     ~                           */

const struct insset isets[] =
{
  {
    1,
    {
      {
        NULL, NULL, lnot, strm, skip, popn, modn, inum, NULL, NULL,
        NULL, muln, addn, ochr, subn, onum, divn, pshn, pshn, pshn,
        pshn, pshn, pshn, pshn, pshn, pshn, pshn, dupl, NULL, west,
        NULL, east, rndd, kill, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, swap, NULL, nort, hzif, gret, NULL, NULL, NULL, NULL,
        NULL, NULL, geta, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, pt93, NULL, NULL, NULL, NULL, NULL, sout, NULL, NULL,
        NULL, NULL, NULL, vtif, NULL, ichr
      },
      {
        pshs, pshs, pshs, norm, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs
      }
    }
  },
  {
    4,
    {
      {
        NULL, nop0, lnot, strm, skip, popn, modn, inum, chrm, NULL,
        NULL, muln, addn, ochr, subn, onum, divn, pshn, pshn, pshn,
        pshn, pshn, pshn, pshn, pshn, pshn, pshn, dupl, comm, west,
        NULL, east, rndd, kill, revr, NULL, NULL, NULL, endp, file,
        getr, NULL, NULL, jump, NULL, NULL, NULL, NULL, NULL, putr,
        NULL, repo, NULL, newt, NULL, NULL, NULL, absd, pshd, NULL,
        NULL, swap, NULL, NULL, hzif, gret, pshx, pshx, pshx, pshx,
        pshx, pshx, geta, NULL, invm, skpn, NULL, NULL, NULL, clst,
        nop1, puta, quem, roll, NULL, NULL, NULL, NULL, NULL, NULL,
        ybsc, jmpz, NULL, NULL, NULL, ichr
      },
      {
        pshs, sbsm, pshs, norm, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs
      },
      {
        ussm, nop0, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm
      },
      {
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc
      },
      {
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, norm, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0
      }
    }
  },
  {
    4,
    {
      {
        NULL, nop0, lnot, strm, skip, popn, modn, inum, chrm, lget,
        rget, muln, addn, ochr, subn, onum, divn, pshn, pshn, pshn,
        pshn, pshn, pshn, pshn, pshn, pshn, pshn, dupl, comm, west,
        NULL, east, rndd, kill, revr, NULL, NULL, NULL, endp, file,
        getr, NULL, NULL, jump, NULL, NULL, NULL, NULL, NULL, putr,
        tiqm, repo, NULL, newt, NULL, test, NULL, absd, pshd, NULL,
        trnl, swap, trnr, nort, hzif, gret, pshx, pshx, pshx, pshx,
        pshx, pshx, geta, NULL, invm, skpn, NULL, NULL, NULL, clst,
        nop1, puta, quem, roll, swim, NULL, NULL, sout, swit, NULL,
        ybsc, jmpz, lput, vtif, rput, ichr
      },
      {
        pshs, sbsm, pshs, norm, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs
      },
      {
        ussm, nop0, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm
      },
      {
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc
      },
      {
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, norm, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0
      }
    }
  },
  {
    4,
    {
      {
        NULL, nop0, lnot, strm, skip, popn, modn, inum, chrm, lget,
        rget, muln, addn, ochr, subn, onum, divn, pshn, pshn, pshn,
        pshn, pshn, pshn, pshn, pshn, pshn, pshn, dupl, comm, west,
        NULL, east, rndd, kill, revr, NULL, NULL, dest, endp, file,
        getr, ppif, NULL, jump, NULL, NULL, NULL, NULL, NULL, putr,
        tiqm, repo, NULL, newt, asct, test, NULL, absd, pshd, NULL,
        trnl, swap, trnr, nort, hzif, gret, pshx, pshx, pshx, pshx,
        pshx, pshx, geta, NULL, invm, skpn, NULL, NULL, NULL, clst,
        nop1, puta, quem, roll, swim, NULL, NULL, sout, swit, NULL,
        ybsc, jmpz, lput, vtif, rput, ichr
      },
      {
        pshs, sbsm, pshs, norm, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs, pshs,
        pshs, pshs, pshs, pshs, pshs, pshs
      },
      {
        ussm, nop0, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm, ussm,
        ussm, ussm, ussm, ussm, ussm, ussm
      },
      {
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc, pshc,
        pshc, pshc, pshc, pshc, pshc, pshc
      },
      {
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, norm, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0, nop0,
        nop0, nop0, nop0, nop0, nop0, nop0
      }
    }
  }
#ifdef BEFUNGE96
  ,{
    2,
    {
      {
        NULL, nop0, ln96, strm, skip, po96, md96, in96, cm96, lg96,
        rg96, ml96, ad96, oc96, sb96, on96, dv96, pn96, pn96, pn96,
        pn96, pn96, pn96, pn96, pn96, pn96, pn96, du96, NULL, west,
        NULL, east, rndd, kill, NULL, NULL, NULL, NULL, NULL, NULL,
        gr96, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, pr96,
        NULL, NULL, NULL, newt, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, sw96, NULL, nort, hi96, gt96, NULL, NULL, NULL, NULL,
        NULL, NULL, ga96, hd96, im96, sk96, NULL, NULL, NULL, NULL,
        NULL, pa96, NULL, NULL, NULL, NULL, NULL, sout, NULL, NULL,
        NULL, NULL, lp96, vi96, rp96, ic96
      },
      {
        ps96, ps96, ps96, norm, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96, ps96,
        ps96, ps96, ps96, ps96, ps96, ps96
      },
      {
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96, pc96,
        pc96, pc96, pc96, pc96, pc96, pc96
      },
    }
  }
#endif
};

