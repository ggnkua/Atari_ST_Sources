@part(gsfive.mss,root='sysroot.mss')
@chapter<Character Device I/0>

@section(Normal Character I/O)

In GEM DOS the normal character I/O calls, and those file I/O calls mapped onto
character devices, work in a polled manner.  If a character is not
available, the BIOS routine waits until a character
becomes available.  To avoid this lockup, separate status calls are provided to
inform the calling application of the presence or absence of available 
characters.

In actual BIOS implementations, however, this polled interface may reside over 
an interrupt driven set of character I/O routines that allow the BIOS to buffer
characters.  If handshaking is present, receiver over-run problems can be 
avoided or at least minimized.

@section(Interrupt Driven Character I/O)

Using the "Exchange Character Vector" subfunction 
of the GEM DOS I/O Control call
(F_IOCtl), applications can tie into interrupt-driven I/O for character devices.
The stack format for the invocation of the character device logical interrupt 
handler is described in Section 3.  

Any application may install its own handler for a character device and receive 
characters from, for instance, the AUX:
port asynchronously.  This capability allows portable communication 
programs to be written, and isolates the application from 
a machine's particular physical I/O operations.

@b(Note:) It is the responsibility of the application to restore 
any vectors that it took over before terminating.

The following C program provides an example 
of the use of the "Exchange Character
Vector" subfunction (in this case, for the MOUSE: device) to receive mouse data
asynchronously, and report that information to the screen.

@newpage
@verbatim'
@rule(-----------------------------------------------------)
**
** rat.c - Tattle on mouse packets
**
** CREATED
**  4 oct 85 scc
**
@rule(-----------------------------------------------------)
*/

#include <mini.h>

struct rat_buffer
{
	char	buttons;
	char	delta_x;
	char	delta_y;
} rat_pack;

int	got_one;

rat_isr(flags, rat_pointer)
	long				flags;
	register struct rat_buffer *rat_pointer;
{
	if (flags & 1)
	{
          rat_pack.buttons = rat_pointer->buttons;
	  rat_pack.delta_x = rat_pointer->delta_x;
	  rat_pack.delta_y = rat_pointer->delta_y;
	}
	got_one = 1;
}

main()
{
	int	mouse;
	long	old_isr;

	mouse = F_Open("mouse:", 0);
	old_isr = F_IOCtl(-1, mouse, 0, &rat_isr);
	C_ConWS("\033H\033J");  /* Home, clear */
	tattle();

	while (!C_RawIO(0xFF)) /*term on keypress*/
	{
		if (got_one)
		{
			C_ConWS("\033H"); /* Home */
			tattle();
		}
	}

	F_IOCtl(-1, mouse, 0, old_isr);
}

tattle()
{
	C_ConWS("buttons = ");
	PutByte(rat_pack.buttons);
	C_ConWS("\r\ndelta_x = ");
	PutByte(rat_pack.delta_x);
	C_ConWS("\r\ndelta_y = ");
	PutByte(rat_pack.delta_y);
	C_ConWS("\r\n");

	got_one = 0;
}
'
@rule(---------------------------------------------------------)
@center[Listing 7.  Exchange Character Vector for Mouse Data]


@eos()
