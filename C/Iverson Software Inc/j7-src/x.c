/* ----------------------------------------------------------------------- */
/* J-Source Version 7 - COPYRIGHT 1993 Iverson Software Inc.               */
/* 33 Major Street, Toronto, Ontario, Canada, M5S 2K9, (416) 925 6096      */
/*                                                                         */
/* J-Source is provided "as is" without warranty of any kind.              */
/*                                                                         */
/* J-Source Version 7 license agreement:  You may use, copy, and           */
/* modify the source.  You have a non-exclusive, royalty-free right        */
/* to redistribute source and executable files.                            */
/* ----------------------------------------------------------------------- */
/*                                                                         */
/* External, Experimental, & Extra                                         */

#include "j.h"
#include "a.h"
#include "x.h"


F2(foreign){I p=i0(a),q=i0(w);
 switch(XC(p,q)){
  case XC(0,0):   R CDERIV(CIBEAM, host,    0L,       1L,   0L,   0L   );
  case XC(0,1):   R CDERIV(CIBEAM, hostne,  0L,       1L,   0L,   0L   );
  case XC(0,2):   R CDERIV(CIBEAM, script1, script2,  0L,   0L,   0L   );
  case XC(0,3):   R CDERIV(CIBEAM, sscript1,sscript2, 0L,   0L,   0L   );
  case XC(0,4):   R CDERIV(CIBEAM, line1,   line2,    1L,   0L,   1L   );
  case XC(0,5):   R CDERIV(CIBEAM, sline1,  sline2,   1L,   0L,   1L   );
  case XC(0,55):  R CDERIV(CIBEAM, joff,    0L,       RMAXL,0L,   0L   );
  case XC(1,0):   R CDERIV(CIBEAM, jfdir,   0L,       RMAXL,0L,   0L   );
  case XC(1,1):   R CDERIV(CIBEAM, jfread,  0L,       0L,   0L,   0L   );
  case XC(1,2):   R CDERIV(CIBEAM, 0L,      jfwrite,  0L,   RMAXL,0L   );
  case XC(1,3):   R CDERIV(CIBEAM, 0L,      jfappend, 0L,   RMAXL,0L   );
  case XC(1,4):   R CDERIV(CIBEAM, jfsize,  0L,       0L,   0L,   0L   );
  case XC(1,11):  R CDERIV(CIBEAM, jiread,  0L,       1L,   0L,   0L   );
  case XC(1,12):  R CDERIV(CIBEAM, 0L,      jiwrite,  0L,   RMAXL,1L   );
  case XC(1,55):  R CDERIV(CIBEAM, jferase, 0L,       0L,   0L,   0L   );
  case XC(2,0):   R CDERIV(CIBEAM, 0L,      wnc,      0L,   0L,   0L   );
  case XC(2,1):   R CDERIV(CIBEAM, wnl,     0L,       0L,   0L,   0L   );
  case XC(2,2):   R CDERIV(CIBEAM, save1,   save2,    0L,   0L,   0L   );
  case XC(2,3):   R CDERIV(CIBEAM, psave1,  psave2,   0L,   0L,   0L   );
  case XC(2,4):   R CDERIV(CIBEAM, copy1,   copy2,    0L,   0L,   0L   );
  case XC(2,5):   R CDERIV(CIBEAM, pcopy1,  pcopy2,   0L,   0L,   0L   );
  case XC(2,55):  R CDERIV(CIBEAM, 0L,      wex,      0L,   0L,   0L   );
  case XC(3,0):   R CDERIV(CIBEAM, stype,   0L,       RMAXL,0L,   0L   );
  case XC(3,1):   R CDERIV(CIBEAM, ir,      0L,       RMAXL,0L,   0L   );
  case XC(3,2):   R CDERIV(CIBEAM, ri,      0L,       1L,   0L,   0L   );
  case XC(4,0):   R CDERIV(CIBEAM, ncx,     0L,       0L,   0L,   0L   );
  case XC(4,1):   R CDERIV(CIBEAM, nl1,     nl2,      RMAXL,RMAXL,RMAXL);
  case XC(4,55):  R CDERIV(CIBEAM, ex55,    0L,       0L,   0L,   0L   );
  case XC(4,56):  R CDERIV(CIBEAM, ex56,    0L,       0L,   0L,   0L   );
  case XC(5,0):   R fdef(CIBEAM,ADV, fxx,0L, a,w,0L, 0L, 0L,0L,0L);
  case XC(5,1):   R CDERIV(CIBEAM, arx,     0L,       0L,   0L,   0L   );
  case XC(5,2):   R CDERIV(CIBEAM, drx,     0L,       0L,   0L,   0L   );
  case XC(5,3):   R CDERIV(CIBEAM, srx,     0L,       0L,   0L,   0L   );
  case XC(5,4):   R CDERIV(CIBEAM, trx,     0L,       0L,   0L,   0L   );
  case XC(5,5):   R CDERIV(CIBEAM, lrx,     0L,       0L,   0L,   0L   );
  case XC(6,0):   R CDERIV(CIBEAM, ts,      0L,       RMAXL,0L,   0L   );
  case XC(6,1):   R CDERIV(CIBEAM, tss,     0L,       RMAXL,0L,   0L   );
  case XC(6,2):   R CDERIV(CIBEAM, tsit1,   tsit2,    1L,   0L,   1L   );
  case XC(6,3):   R CDERIV(CIBEAM, dl,      0L,       0L,   0L,   0L   );
  case XC(7,0):   R CDERIV(CIBEAM, sp,      0L,       RMAXL,0L,   0L   );
  case XC(7,1):   R CDERIV(CIBEAM, sps,     0L,       RMAXL,0L,   0L   );
  case XC(7,2):   R CDERIV(CIBEAM, spit,    0L,       1L,   0L,   0L   );
#if (SYS_SESM && SYS & SYS_PC+SYS_PC386)
  case XC(8,0):   R CDERIV(CIBEAM, cgaq,    0L,       RMAXL,0L,   0L   );
  case XC(8,1):   R CDERIV(CIBEAM, cgas,    0L,       RMAXL,0L,   0L   );
  case XC(8,4):   R CDERIV(CIBEAM, colorq,  0L,       RMAXL,0L,   0L   );
  case XC(8,5):   R CDERIV(CIBEAM, colors,  0L,       RMAXL,0L,   0L   );
  case XC(8,7):   R CDERIV(CIBEAM, refresh, 0L,       RMAXL,0L,   0L   );
  case XC(8,9):   R CDERIV(CIBEAM, edit,    0L,       RMAXL,0L,   0L   );
#else
  case XC(8,0):   R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
  case XC(8,1):   R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
  case XC(8,4):   R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
  case XC(8,5):   R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
  case XC(8,7):   R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
  case XC(8,9):   R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
#endif
#if (SYS & SYS_MACINTOSH)
  case XC(8,16):  R CDERIV(CIBEAM, fontq,   0L,       RMAXL,0L,   0L   );
  case XC(8,17):  R CDERIV(CIBEAM, fonts,   0L,       RMAXL,0L,   0L   );
  case XC(8,19):  R CDERIV(CIBEAM, prtscr,  0L,       RMAXL,0L,   0L   );
#else
  case XC(8,16):  R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
  case XC(8,17):  R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
  case XC(8,19):  R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
#endif
  case XC(9,0):   R CDERIV(CIBEAM, rlq,     0L,       RMAXL,0L,   0L   );
  case XC(9,1):   R CDERIV(CIBEAM, rls,     0L,       RMAXL,0L,   0L   );
  case XC(9,2):   R CDERIV(CIBEAM, dispq,   0L,       RMAXL,0L,   0L   );
  case XC(9,3):   R CDERIV(CIBEAM, disps,   0L,       RMAXL,0L,   0L   );
  case XC(9,4):   R CDERIV(CIBEAM, promptq, 0L,       RMAXL,0L,   0L   );
  case XC(9,5):   R CDERIV(CIBEAM, prompts, 0L,       RMAXL,0L,   0L   );
  case XC(9,6):   R CDERIV(CIBEAM, boxq,    0L,       RMAXL,0L,   0L   );
  case XC(9,7):   R CDERIV(CIBEAM, boxs,    0L,       RMAXL,0L,   0L   );
  case XC(9,8):   R CDERIV(CIBEAM, evmq,    0L,       RMAXL,0L,   0L   );
  case XC(9,9):   R CDERIV(CIBEAM, evms,    0L,       RMAXL,0L,   0L   );
#if (SYS & SYS_PCWIN)
  case XC(11,0):  R CDERIV(CIBEAM, wd,      0L,       RMAXL,0L,   0L   );
  case XC(11,1):  R CDERIV(CIBEAM, wdvedit, 0L,       RMAXL,0L,   0L   );
#else
  case XC(11,0):  R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
  case XC(11,1):  R CDERIV(CIBEAM, 0L,      0L,       RMAXL,0L,   0L   );
#endif
/*case XC(12,*):      reserved for D.H. Steinbrook tree stuff         */
  case XC(13,0):  R CDERIV(CIBEAM, dbr,     0L,       RMAXL,0L,   0L   );
  case XC(13,1):  R CDERIV(CIBEAM, dbs,     0L,       RMAXL,0L,   0L   );
  case XC(13,2):  R CDERIV(CIBEAM, dbsq,    0L,       RMAXL,0L,   0L   );
  case XC(13,3):  R CDERIV(CIBEAM, dbss,    0L,       RMAXL,0L,   0L   );
  case XC(13,4):  R CDERIV(CIBEAM, dbrun,   0L,       RMAXL,0L,   0L   );
  case XC(13,5):  R CDERIV(CIBEAM, dbnxt,   0L,       RMAXL,0L,   0L   );
  case XC(13,6):  R CDERIV(CIBEAM, dbret,   0L,       RMAXL,0L,   0L   );
  case XC(13,7):  R CDERIV(CIBEAM, dbpop,   0L,       RMAXL,0L,   0L   );
  case XC(128,0): R CDERIV(CIBEAM, qr,      0L,       2L,   0L,   0L   );
  case XC(128,1): R CDERIV(CIBEAM, rinv,    0L,       2L,   0L,   0L   );
 }
 if(10==p){AF*f1,*f2;
  ASSERT(jc(q,&f1,&f2),EVDOMAIN);
  R CDERIV(CIBEAM, f1,f2, RMAXL,RMAXL,RMAXL);
 }
 ASSERT(0,EVDOMAIN);
}
