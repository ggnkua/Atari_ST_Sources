After putting an unreasonable amount of effort into debugging this beast, I
feel entitled to add a few words to what's already in the .man file.

The main reason I wanted sed was to help distinguish defining and referencing 
declarations of external variables in C.  Andy Tanenbaum got me started on
this in his Operating Systems, Design and Implementation (the MINIX book).
Anyway, I adopted his idea of a pre-processor macro that expands to a 
gramatically proper referencing declaration everywhere except in one file,
where it is redefined to expand to a proper defining declaration.  This does
not serve for initialized external variables, however.  My solution follows:

The macros EXTERN add Initialize are defined as

#define EXTERN extern
#define INITIALIZE(type, name, value) extern type name

except in one file, which says

#undef EXTERN
#undef INITIALIZE
#define EXTERN
#define INITIALIZE(type, name, value) type name = (value)

This allows things like

INITIALIZE(double, imagintvl, -.0125);
EXTERN double reintmp, imintmp;
EXTERN struct complex upleft, center;
INITIALIZE(int, drawarray[4], ({0, 9, 0, 0}));

Fine so far.  But that initializer {0. 9, 0, 0} really does need to be 
enclosed in parentheses, because only parentheses can protect a comma from
being taken as a token delimiter by the C pre-processor.  Similarly,
the INITIALIZE macro really should put the initializer in parentheses
to avoid unpleasant surprises.  Imagine my surprise when C compilers 
rejected "int drawarray[4] = (({0, 9, 0, 0}));".  It seems that the syntax
of a multi-value initializer requires " = <optional whitespace> {".  Damn.

Sed to the rescue!! My makefile for a complex program now includes


expanded.c:  defines.c
	cc -E defines.c > $(TMPDIR)\expanded
	sed -e '/=/s/(\([{"].*\));/\1;/' $(TMPDIR)\expanded > $(TMPDIR)\filtered
	sed -e '/=/s/(\([{"].*\));/\1;/' $(TMPDIR)\filtered > expanded.c

Ta daaa!
				Stephen Jacobs (saj@chinet.chi.il.us)
