
/* xbios trap */

trap_14_wwll(w1, w2, l1, l2)
long w1, w2, l1, l2;
{
  asm("moveml #0x3FFC,sp@-");
  asm("movel a6@(20),sp@-");
  asm("movel a6@(16),sp@-");
  asm("movel a6@(12),d0");
  asm("movew d0,sp@-");
  asm("movel a6@(8),d0");
  asm("movew d0,sp@-");
  asm("trap #14");
  asm("addl #12,sp");
  asm("moveml sp@+,#0x3FFC");
}

trap_14_wllw(w1, l1, l2, w2)
long w1, l1, l2, w2;
{
  asm("moveml #0x3FFC,sp@-");
  asm("movel a6@(20),d0");
  asm("movew d0,sp@-");
  asm("movel a6@(16),sp@-");
  asm("movel a6@(12),sp@-");
  asm("movel a6@(8),d0");
  asm("movew d0,sp@-");
  asm("trap #14");
  asm("addl #12,sp");
  asm("moveml sp@+,#0x3FFC");
}

trap_14_wlll(w1, l1, l2, l3)
long w1, l1, l2, l3;
{
  asm("moveml #0x3FFC,sp@-");
  asm("movel a6@(20),sp@-");
  asm("movel a6@(16),sp@-");
  asm("movel a6@(12),sp@-");
  asm("movel a6@(8),d0");
  asm("movew d0,sp@-");
  asm("trap #14");
  asm("addl #14,sp");
  asm("moveml sp@+,#0x3FFC");
}

trap_14_www(w1, w2, w3)
long w1, w2, w3;
{
  asm("moveml #0x3FFC,sp@-");
  asm("movel a6@(16),d0");
  asm("movew d0,sp@-");
  asm("movel a6@(12),d0");
  asm("movew d0,sp@-");
  asm("movel a6@(8),d0");
  asm("movew d0,sp@-");
  asm("trap #14");
  asm("addl #6,sp");
  asm("moveml sp@+,#0x3FFC");
}

