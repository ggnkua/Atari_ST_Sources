less v.97st

Ported to the Atari ST MiNT Operating System by David Megginson
5 January, 1991

This is less v.97, ported to the MiNT operating system using GCC
1.37.1. This version probably will not run under plain TOS, but if
you're using a cli, you probably should be using MiNT anyway! This
version will catch signals (you can use ^C to abort a long search, for
instance) and talk nicely to the operating system. There are two
archives supplied: lessbin.zoo, which contains the binaries for less and
lesskey and copies of the man pages and help file, and lesssrc.zoo,
which contains the source code and ST makefile. less accepts its input
from stdin gracefully, so you can put it in a pipe, ie.

	% cat myfile | sed -e 's/TOS/MiNT/g' | less


ENVIRONMENT VARIABLES

This version of less uses a few environment variables to find its
support files, rather than relying on absolute pathnames: 

	LESSHELP:	the pathname to the file less.help (it will
			show up as "less.hel" on the ST.
	EDITOR:		the default system editor to use with the 'v'
			command.
	SHELL:		the default system shell.
	TERM:		the current terminal type (atari, mgr, etc.)
	TERMCAP:	the absolute pathname to the termcap file (must
			begin with a forward slash, ie. 
			"/dev/E/etc/termcap") or the termcap itself.
	PAGER:		used by other programs to find less. Set to less's
			absolute pathname.

You might also want to type 'alias more less' in shells which support
aliases.


FILENAME CONVENTIONS

This version of less supports either forward or backward slashes in
filenames, as well as the /dev/<letter> convention for logical drives.
Thanks to Eric Smith's for MiNT and the GCC MiNT library, and to all the
others who have worked on GCC etc. -- they made this port trivial.

BTW, the makefile is already set up for the ST, as is the file
defines.h, so do not try to run linstall!!

- David
david@doe.utoronto.ca
