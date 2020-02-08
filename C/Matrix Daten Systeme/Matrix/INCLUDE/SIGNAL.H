/*      SIGNAL.H

        Signal Definitions

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if  !defined( __SIGNAL__ )
#define __SIGNAL__


#define SIGABRT         80      /* ANSI, abort */
#define SIGTERM         81      /* ANSI, termination */
#define SIGFPE          82      /* ANSI, floating point error */
#define SIGINT          83      /* ANSI, break request: ^d */
#define SIGALRM         84      /* UNIX, Alarm clock */
#define SIGKILL         85      /* UNIX, Kill Process */
#define SIGUSR1         88      /* UNIX, User defined Signal 1 */
#define SIGUSR2         89      /* UNIX, User defined Signal 2 */

#define SIGSEGV          2      /* ANSI, bus error (segment violation) */
#define SIGADR           3      /* adress error */
#define SIGILL           4      /* ANSI, illegal instruction */
#define SIGDIV0          5      /* division by zero */
#define SIGCHK           6      /* CHK */
#define SIGTRAPV         7      /* TRAPV */
#define SIGPRIV          8      /* privilege violation */
#define SIGTRACE         9      /* TRACE */
#define SIGLINEA        10      /* LINEA */
#define SIGLINEF        11      /* LINEF */
#define SIGCPVIO        13      /* Coprocessor Protocol Violation (resd.) */
#define SIGFORMAT       14      /* Format Error (reserved) */
#define SIGUNINT        15      /* Uninitialized Interrupt (reserved) */
#define SIGSPURI        24      /* spurious interrupt */
#define SIGAUTO1        25      /* auto interrupt #1 */
#define SIGAUTO2        26      /* auto interrupt #2, Hblank */
#define SIGAUTO3        27      /* auto interrupt #3 */
#define SIGAUTO4        28      /* auto interrupt #4, Vblank */
#define SIGAUTO5        29      /* auto interrupt #5 */
#define SIGAUTO6        30      /* auto interrupt #6 */
#define SIGAUTO7        31      /* auto interrupt #7 */
#define SIGTRAP0        32      /* TRAP # 0 */
#define SIGTRAP1        33      /* TRAP # 1, GEMDOS */
#define SIGTRAP2        34      /* TRAP # 2, AES/VDI */
#define SIGTRAP3        35      /* TRAP # 3 */
#define SIGTRAP4        36      /* TRAP # 4 */
#define SIGTRAP5        37      /* TRAP # 5 */
#define SIGTRAP6        38      /* TRAP # 6 */
#define SIGTRAP7        39      /* TRAP # 7 */
#define SIGTRAP8        40      /* TRAP # 8 */
#define SIGTRAP9        41      /* TRAP # 9 */
#define SIGTRAP10       42      /* TRAP #10 */
#define SIGTRAP11       43      /* TRAP #11 */
#define SIGTRAP12       44      /* TRAP #12 */
#define SIGTRAP13       45      /* TRAP #13, BIOS */
#define SIGTRAP14       46      /* TRAP #14, XBIOS */
#define SIGTRAP15       47      /* TRAP #15 */
#define SIGFPU0         48      /* FPU Unordered Condition (reserved) */
#define SIGFPU1         49      /* FPU Inexact result (reserved) */
#define SIGFPU2         50      /* FPU Divide by zero (reserved) */
#define SIGFPU3         51      /* FPU Underflow (reserved) */
#define SIGFPU4         52      /* FPU Operand Error (reserved) */
#define SIGFPU5         53      /* FPU Overflow (reserved) */
#define SIGFPU6         54      /* FPU Signaling NaN (reserved) */
#define SIGMMU0         56      /* MMU Configuration Error (reserved) */
#define SIGMMU1         57      /* MMU (reserved) */
#define SIGMMU2         58      /* MMU (reserved) */
#define SIGMFP0         64      /* MFP  0, CENTRONICS (disabled) */
#define SIGMFP1         65      /* MFP  1, RS232 CD (disabled) */
#define SIGMFP2         66      /* MFP  2, RS232 CTS (disabled) */
#define SIGMFP3         67      /* MFP  3, Blitter (disabled) */
#define SIGMFP4         68      /* MFP  4, RS232 Baud Rate (disabled) */
#define SIGMFP5         69      /* MFP  5, 200Hz Clock (enabled) */
#define SIGMFP6         70      /* MFP  6, KEYBD, MIDI (enabled) */
#define SIGMFP7         71      /* MFP  7, FDC/HDC (disabled) */
#define SIGMFP8         72      /* MFP  8, Hsync (disabled) */
#define SIGMFP9         73      /* MFP  9, RS232 transmit error */
#define SIGMFP10        74      /* MFP 10, RS232 transmit buffer empty */
#define SIGMFP11        75      /* MFP 11, RS232 receive error */
#define SIGMFP12        76      /* MFP 12, RS232 receive buffer full */
#define SIGMFP13        77      /* MFP 13, Timer A (disabled) */
#define SIGMFP14        78      /* MFP 14, RS232 RI (disabled) */
#define SIGMFP15        79      /* MFP 15, Monitor (disabled) */

typedef void (*sigfunc_t)( int );

#define SIG_SYS         (sigfunc_t)0L
#define SIG_DFL         (sigfunc_t)-1L
#define SIG_IGN         (sigfunc_t)-2L
#define SIG_ERR         (sigfunc_t)-3L

sigfunc_t signal( int sig, sigfunc_t func );
int raise( int sig );
void signal_mode( int mode );

typedef int sig_atomic_t;

#endif

/************************************************************************/
