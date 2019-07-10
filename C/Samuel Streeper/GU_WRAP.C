/**************************************************
	If you run Gulam from within Gemini, you will
	find that you cannot run any programs from within
	Gemini after Gulam exits. The reason is that Gulam
	does not restore the shell pointer after it exits,
	and Gemini executes all its commands through the shell
	pointer, which is no longer valid. This program is a
	"Gulam wrapper." It saves the old shell pointer (which
	probably points to Mupfel) and then runs Gulam. When
	Gulam exits, it restores the shell pointer, and everything
	is hunky-dory. This program is not too smart... It doesn't
	pass command line args to Gulam, and it only looks for
	Gulam in the current directory. Thats fine for me and I wanted
	it to be small, but change it if you like...

	This program compiles with Laser C. It would be trivial to convert
	the assembly to other C's assembler, or just to C.

	-samuel streeper
****************************************************/
#include <osbind.h>

long old_shell_p;
extern int 	save_shell_p(), rest_shell_p();

asm{
	save_shell_p:
		move.l	0x4F6,old_shell_p
		rts

	rest_shell_p:
		move.l	old_shell_p,0x4F6
		rts
}

main()
{
	Supexec(save_shell_p);
	Cconws("_shell_p saved\r\n");

	Pexec(0,"GULAM.PRG","","");

	Supexec(rest_shell_p);
	Cconws("_shell_p restored\r\n");
}
