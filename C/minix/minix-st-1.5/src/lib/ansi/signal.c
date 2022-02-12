#include <lib.h>
#include <signal.h>

extern void (*__vectab[_NSIG]) ();	/* array of funcs to catch signals */

/* The definition of signal really should be
 *  PUBLIC void (*signal(signr, func))()
 * but some compilers refuse to accept this, even though it is correct.
 * The only thing to do if you are stuck with such a defective compiler is
 * change it to
 *  PUBLIC void *signal(signr, func)
 * and change ../h/signal.h accordingly.
 */

PUBLIC void (*signal(signr, func)) ()
int signr;			/* which signal is being set */
void (*func) ();			/* pointer to function that catches signal */
{
  int r;
  void (*old) ();

  old = __vectab[signr - 1];
  _M.m6_i1 = signr;
  if (func == SIG_IGN || func == SIG_DFL)
	/* Keep old signal catcher until it is completely de-installed */
	_M.m6_f1 = (void (*)())func;
  else {
	/* Use new signal catcher immediately (old one may not exist) */
	__vectab[signr - 1] = func;
	_M.m6_f1 = begsig;
  }
  r = callx(MM, SIGNAL);
  if (r < 0) {
	__vectab[signr - 1] = old;/* undo any pre-installation */
	return((void (*) ()) r);
  }
  __vectab[signr - 1] = func;	/* redo any pre-installation */
  if (r == 1) return(SIG_IGN);
  return(old);
}
