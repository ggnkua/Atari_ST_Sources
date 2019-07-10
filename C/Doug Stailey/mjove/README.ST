Dear MiNT User:

The good news is that all of the process control and job control features
work, and that the ptys are implemented, allowing an interactive shell
window.  The commands for compiling and interactively linting your source
code are available (M-X compile-it and M-X next-error).  Other process
control functions include:

shell-command (non-interactive)
i-shell-command (interactive, asynchronous, and multiple i-shell-commands
		 run at the same time)
shell-command-to-typeout (non-interactive, doesn't send output to a text
			  buffer, but writes directly to the screen, using
			  a pager)
shell (interactive shell of your choice.  Make sure SHELL environment
       variable is set)

JOVE uses termcap, and will run from the console or under TOSWIN or MGR.
The special keys are implemented (function keys, etc.), but in a kludgy
way that breaks under MGR.  This port would vastly benefit from the addition
of MiNT's xkeys feature.

The F2 key is bound to display-bindings.  F1 is the help key, and it
requires that cmds.doc be in c:\jove\lib, or you will have to fix the
environment.

When reporting problems, remember that I have been using JOVE for a year,
and so I am aware of most of the problems.  Sorry about the ^Ms showing
up in all the interactive process windows.  Source is provided for the
adventurous.  I have ifdef'd all of my modifications.  getch.c is a 
complete rewrite, to implement the special keys.  The quadruple backslashes
are used in the makefile, because the lines get fed through sed.
Aren't they gross?

Oh, yes, one other thing.  Make sure that you use the drive u: notation
when changing directories or referring to files on other drives.
Otherwise, the readline emulation breaks.

Believe me, with all of it's shortcomings JOVE is still an extremely
useful programming environment.

(And the memory usage is minimal, especially compared with emacs.)

       Doug

--
dstailey@leidecker.gsfc.nasa.gov
Try running two greps at once.  That's
M-X i-shell-process grep -n MiNT *.[ch]
M-X i-shell-process grep -n DoShell *.c
