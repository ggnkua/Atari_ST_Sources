
int trap_13_www(args)
long args;
{
/* arg[0] is at a6@(8) */
/* push w, w, w.  more later? */

  asm("moveml #0x3FFC,sp@-");		/* save all regs... */
  asm("movel a6@(16),d0");		/* copy w1 */
  asm("movew d0,sp@-");
  asm("movel a6@(12),d0");		/* copy w2 */
  asm("movew d0,sp@-");
  asm("movel a6@(8),d0");		/* copy w1 */
  asm("movew d0,sp@-");
  asm("trap #13");			/* do the trap */
  asm("addl #6,sp");			/* pop junk off stack */
  asm("moveml sp@+,#0x3FFC");		/* restore regs */
}


int trap_13_wwl(args)
long args;
{
/* arg[0] is at a6@(8) */
/* push w, w, l.  more later? */

  asm("moveml #0x3FFC,sp@-");		/* save all regs... */
  asm("movel a6@(16),sp@-");		/* copy l1 */
  asm("movel a6@(12),d0");		/* copy w2 */
  asm("movew d0,sp@-");
  asm("movel a6@(8),d0");		/* copy w1 */
  asm("movew d0,sp@-");
  asm("trap #13");			/* do the trap */
  asm("addl #8,sp");			/* pop junk off stack */
  asm("moveml sp@+,#0x3FFC");		/* restore regs */
}

