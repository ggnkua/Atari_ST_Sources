
int trap_1_wwlll(args)
long args;
{
/* arg[0] is at a6@(8) */

  asm("movel a6@(24),sp@-");		/* copy l3 */
  asm("movel a6@(20),sp@-");		/* copy l2 */
  asm("movel a6@(16),sp@-");		/* copy l1 */
  asm("movel a6@(12),d0");		/* copy w2 */
  asm("movew d0,sp@-");
  asm("movel a6@(8),d0");		/* copy w1 */
  asm("movew d0,sp@-");
  asm("trap #1");			/* do the trap */
  asm("addl #12,sp");			/* pop junk off stack */
}

int trap_1_wlww(args)
long args;
{
  asm("movel a6@(20),d0");		/* copy w3 */
  asm("movew d0,sp@-");
  asm("movel a6@(16),d0");		/* copy w2 */
  asm("movew d0,sp@-");
  asm("movel a6@(12),sp@-");		/* copy l1 */
  asm("movel a6@(8),d0");		/* copy w1 */
  asm("movew d0,sp@-");
  asm("trap #1");			/* do the trap */
  asm("addl #10,sp");			/* pop junk off stack */
}

