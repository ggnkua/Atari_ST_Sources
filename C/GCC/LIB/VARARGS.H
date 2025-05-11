
/* I'm not sure this is right.  These apparently are all supposed to be
   defines; doesn't seem to make much sense to make them functions.
   There may be some missing from this list; these are the ones I found
   by grepping around in code...
*/

/* a va_list is a list of random frobules */
typedef char * va_list;

/* the address of the list??? don't we already have that???  C programmers
   pick the wierdest times to start worrying about abstractions! */
#define va_start(args) args = (char * ) &va_alist

/* is this supposed to do anything??? */
#define va_end(args)

/* This is apparently a general purpose accessor, used for storing, as 
   well as snarfing.  This is the only way I could think of to make it
   work that way.  Please, somebody, re-write this! */
#define va_arg(args, elt_type) ((elt_type * ) (args += sizeof(elt_type)))[-1]

#define va_dcl	va_alist va_alist
