#include <lib.h>
#define sigaction _sigaction
#include <sys/sigcontext.h>
#include <signal.h>

_PROTOTYPE(int __sigreturn, (void));

#ifdef __MLONG__
/* Problem:
 * 16-bit Kernel ruft definierte Signalfunktionen mit 16-bit Signalnummer auf.
 * Eine 32-bit Programmfunktion faellt auf die Nase, wenn sie das Signal
 * auswerten moechte.
 * Neben der Signalnummer wird dem Signalhandler noch ein "int code" und
 * eine Struktur "struct sigcontext" uebergeben, was natuerlich auch
 * danebengeht.
 *
 * Ausweg:
 * Beim Aufruf von sigaction() wird der eigentliche Signalhandler gemerkt
 * und fuer den Kernel ersetzt durch eine Konvertierungsfunktion, die die
 * 16->32 bit Umwandlung vornimmt und dann den Signalhandler aufruft.
 * "Nettes" Beiwerk sind die Sonderfunktion SIG_DFL etc. und die Rueckgabe
 * des alten Signalhandlers (darf natuerlich nicht die Konvertierungsfunktion
 * sein, die der Kernel liefert).
 *
 * TODO: Prototype (const entfernen fuer __MLONG__) anpassen.
 *
 * Immerhin laufen die Tests durch!
 *
 * VS 10.07.2002
 *
 * VS 31.10.2005: `const' fuer Parameter `act' bei 32-bit ints umgangen
 */

#if defined(_ANSI)
typedef void (*__my_sighandler_t) (int, int, struct sigcontext *);
#else
typedef void (*__my_sighandler_t)();
#endif
PRIVATE _PROTOTYPE(void _x_sig_handler, \
		       (int sig_and_code, struct sigcontext *scp));

PRIVATE __my_sighandler_t _my_sig_handlers[_NSIG];
PRIVATE __my_sighandler_t _old_sig_handlers[_NSIG];
PRIVATE short initialized = 0;

/*
 * Dies ist der konvertierende Signalhandler
 */
PRIVATE void _x_sig_handler(sig_and_code, scp)
int sig_and_code;
struct sigcontext *scp;
{
  short realsig, realcode;

  realsig = (sig_and_code >> 16) & 0x0ffff;
  realcode = sig_and_code & 0x0ffff;
  (* _my_sig_handlers[realsig])(realsig, realcode, scp);
}
#endif /* __MLONG__ */

PUBLIC int sigaction(sig, act, oact)
int sig;
_CONST struct sigaction *act;
struct sigaction *oact;
{
  message m;

#ifdef __MLONG__
  int retval;

  if (sig <= 0 || sig > _NSIG) {
	errno = EINVAL;
	return (int) SIG_ERR;
  }

  if (initialized == 0) {
	register int i;
	for (i=0; i<_NSIG; i++) {
		_my_sig_handlers[i] = (__my_sighandler_t) SIG_DFL;
		_old_sig_handlers[i] = (__my_sighandler_t) SIG_DFL;
	}
	initialized = 1;
  }

  if (act != NULL) {
	__sighandler_t *not_const_handler = &act->sa_handler;
	_old_sig_handlers[sig] = _my_sig_handlers[sig];
	_my_sig_handlers[sig] = (__my_sighandler_t) act->sa_handler;
	switch ((int)act->sa_handler) {
	   case SIG_ERR:
	   case SIG_DFL:
	   case SIG_IGN:
	   case SIG_HOLD:
	   case SIG_CATCH:
		break;
	   default:
		/* replace by 16->32 bit function */
		*not_const_handler = (__sighandler_t) _x_sig_handler;
		break;
	}
  }
#endif /* __MLONG__ */

  m.m1_i2 = sig;

  /* XXX - yet more type puns because message struct is short of types. */
  m.m1_p1 = (char *) act;
  m.m1_p2 = (char *) oact;
  m.m1_p3 = (char *) __sigreturn;

#ifdef __MLONG__
  retval = _syscall(MM, SIGACTION, &m);
  if (retval == 0 && oact != NULL) {
	/* Signalhandler wurde zum wiederholten Mal eingetragen. */
	if (oact->sa_handler == (__sighandler_t) _x_sig_handler)
		oact->sa_handler = (__sighandler_t) _old_sig_handlers[sig];
	/* Signalhandler wurde zum ersten Mal gesetzt oder SIG_XXX. */
	else
		_old_sig_handlers[sig] = (__my_sighandler_t) oact->sa_handler;
  }
  return retval;
#else
  return(_syscall(MM, SIGACTION, &m));
#endif /* __MLONG__ */
}
