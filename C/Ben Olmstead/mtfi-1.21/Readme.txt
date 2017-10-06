MTFI 1.21 (Magus Technica Funge Interpreter)
Copyright 1998 Ben Olmstead

This program is distributed under the terms of the GNU copyleft.  See
the file COPYING that should have come in this archive for details, but
you may freely copy this program.

This is the Magus Technica Funge Interpreter.  It interprets Befunge-93,
Befunge-96, and all Funge-97s.  It is written in portable ANSI C, though
it is ASCII-dependant.  To invoke it, use:

    mtfi [switches] [program] [more switches] [--] [program]

No more than one program may be specified on the command line, and the
special argument '--' forces everything to follow to be treated as a
program name, even if it's in the right format to be an argument.
Otherwise, the order of switches and program does not matter.  Giving
MTFI no program name or the special name '-' causes it to read from
standard input.  All long switches (those beginning with '--') may be
abbreviated, as long as they are abbreviated uniquely.  For example,
'--help' may be abbreviated '--h' since there is no other switch that
starts with '--h', but you cannot abbreviate '--directive-97' at all,
because then MTFI can't tell if you meant '--directive-96'.

  -h, --help:
    Print a brief usage summary.

  -v, --version:
    Print version information.

  -3, --befunge-93:
    Enforce strict Befunge-93 compliance, including indifference to
    Funge-97-style directives.

  -6, --befunge-96:
    Enable Befunge-96 compatibility.

  -7, --funge-97:
    Assume that the code is written in Funge-97.

    The interpreter defaults to using Befunge-93 unless there are
    Befunge-97-style directives in the file other than == and =l b93,
    one of the dimensionality switches other than --befunge was used,
    or the source more than 25 lines or 80 columns.  -3 forces strict
    Befunge-93 compatibility, and will not differentiate directives
    from normal program source, but will generate an error if you try
    to use more or less than two dimensions or have a program source
    which is too long (extra whitespace at the end of the file is not
    counted).  -7 assumes that the language in use is Befunge-97, but
    does not specify how many dimensions to use.

  --unefunge:
  --befunge:
  --trefunge:
  --quadrefunge:
  --quintefunge:
  --dimensions=n:
    These specify how many dimensions to use.  Note that using any
    number of dimensions other than 2 is invalid for Befunge-93, and
    will generate an error.  If any of these are specified on the
    command line (other than --befunge), the source file is assumed to
    be Funge-97.

  -=, --directive-97:
    This takes a single argument, which is a directive which will be
    parsed as if it were at the top of the source file.  You should
    enclose the directive in quotes, like:

      -= "l b97"

    If you don't, mtfi think that 'b97' is a name of a file for it to
    load.

    You should also leave off the directive character.  The '=' (change
    directive character) directive *is* available on the command line,
    and subsequent command-line directives are treated as if they start
    with that character.  You may also specify more than one directive:

      -= "l b97" -= "= -"

    Directives are parsed in order, though this should not matter.  Note
    that the # comment 'directive' is supported as well, though the
    usefulness of this is questionable.

  -;, --directive-96:
    This is pretty much exactly like -=, except that it doesn't complain
    if you use it with the -6 switch, it implicitly specifies -6, and it
    automatically prefixes the stuff in quotes with ';$'.

  -p, --preprocess
    If one of these is specified, the input file is preprocessed only--
    it is not executed.  The preprocessed file is printed on stdout.

The core is written in ANSI C and should be comparatively easy to move
to a new interface, such as a Windows one.  Write to me if you'd like
to.

Unix users and people with C compilers may recompile with Befunge-96
support OFF.  To do so, comment out the line '#define BEFUNGE96' in
iface.h.

Questions, comments, and bug reports welcome.

                                                   Ben Olmstead
                                                   bem@mad.scientist.com

Revision history:

1.21: Fixed small 32-bit vs 16-bit portability bugs; released 16-bit
8086 binary version of compiler; made NMAKE makefile.

1.20: Added frame cacheing to get() and put() functions; runs
approximately twice as fast.  Now comparable (though not quite as fast
as) Chris Pressey's bef.

1.10: Added support for Befunge-96.  Fixed a bug with extra IPs being
added when =i was used.

1.00: Complete rewrite of the command-line interface; brought the
interpreter into complete compliance with both the Befunge-93 and the
Funge-97 standards.

0.99.1: Fixed two small bugs.

0.99: Complete rewrite; now supports (almost) the Funge-97 standard

