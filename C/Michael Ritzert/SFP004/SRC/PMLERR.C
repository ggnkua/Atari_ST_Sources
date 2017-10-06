/************************************************************************
 *									*
 *				N O T I C E				*
 *									*
 *			Copyright Abandoned, 1987, Fred Fish		*
 *									*
 *	This previously copyrighted work has been placed into the	*
 *	public domain by the author (Fred Fish) and may be freely used	*
 *	for any purpose, private or commercial.  I would appreciate	*
 *	it, as a courtesy, if this notice is left in all copies and	*
 *	derivative works.  Thank you, and enjoy...			*
 *									*
 *	The author makes no warranty of any kind with respect to this	*
 *	product and explicitly disclaims any implied warranties of	*
 *	merchantability or fitness for any particular purpose.		*
 *									*
 ************************************************************************
 */


/************************************************************************
 *									*
 *		PORTABLE MATH LIBRARY -- ERROR HANDLER			*
 *									*
 *	This is a sample PML library error handler.			*
 *	It may be used as is, or another of the user's choice		*
 *	substituted.							*
 *									*
 *	In any case, the global "pmlerr" must be defined somewhere	*
 *	in the user task, since many Portable Math Library routines	*
 *	reference it.  The other routines in this file are not called	*
 *	by any library routines and may be omitted.			*
 *									*
 ************************************************************************
 */

# include <stdio.h>
# include <pmluser.h>
# include "pml.h"

static struct pml_err {
    int flags;			/* Flag word; bits defined in pml.h	*/
    char *msg;			/* Error message			*/
    char *func;			/* Function in which error occured	*/
};

static struct pml_err pml_errs[] = {
    CONTINUE | COUNT | LOG, "overflow", "exp",
    CONTINUE | COUNT | LOG, "underflow", "exp",
    CONTINUE | COUNT | LOG, "exponent overflow", "scale",
    CONTINUE | COUNT | LOG, "negative argument", "sqrt",
    CONTINUE | COUNT | LOG, "zero argument", "log",
    CONTINUE | COUNT | LOG, "negative argument", "log",
    CONTINUE | COUNT | LOG, "argument magnitude greater than 1.0", "acos",
    CONTINUE | COUNT | LOG, "argument magnitude greater than 1.0", "asin",
    CONTINUE | COUNT | LOG, "overflow", "tan",
    CONTINUE | COUNT | LOG, "overflow", "cosh",
    CONTINUE | COUNT | LOG, "underflow", "cosh",
    CONTINUE | COUNT | LOG, "overflow", "sinh",
    CONTINUE | COUNT | LOG, "underflow", "sinh",
    CONTINUE | COUNT | LOG, "overflow", "asinh",
    CONTINUE | COUNT | LOG, "argument less than 1.0", "acosh",
    CONTINUE | COUNT | LOG, "overflow", "acosh",
    CONTINUE | COUNT | LOG, "argument magnitude not  < 1.0", "atanh",
    CONTINUE | COUNT | LOG, "underflow", "atan",
    CONTINUE | COUNT | LOG, "complex division by zero", "cdiv",
    CONTINUE | COUNT | LOG, "complex reciprocal of zero", "crcp",
    CONTINUE | COUNT | LOG, "exponent underflow", "scale",
    CONTINUE | COUNT | LOG, "argument has no fractional part", "dint",
};

static int err_count = 0;		/* Counter for PML errors */
static int err_limit = MAX_ERRORS;	/* PML error limit */

/*
 *  FUNCTION
 *
 *	pmlcfs   Clear specified PML error handler flags
 *
 *  KEY WORDS
 *
 *	pmlcfs
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Clear the specified PML error handler flags for the
 *	specified error.  Two or more flags may be cleared simultaneously
 *	by "or-ing" them in the call, for example "LOG | CONTINUE".
 *	The manifest constants for the flags and error codes are
 *	defined in <pmluser.h>.
 *
 *  USAGE
 *
 *	pmlcfs(err_code,flags)
 *	int err_code;
 *	int flags;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *	(602) 966-8871
 *
 */

pmlcfs(err_code,flag_word)
register int err_code;
register int flag_word;
{
    if (err_code < 0 || err_code > ((int)sizeof(pml_errs)/(int)sizeof(struct pml_err))) {
	fprintf(stderr,"pmlcfs: invalid error code %d\n",err_code);
    } else {
	pml_errs[err_code].flags &= ~flag_word;
    }
}


/*
 *  FUNCTION
 *
 *	pmlcnt   get PML error count and reset it to zero
 *
 *  KEY WORDS
 *
 *	pmlcnt
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Returns the total number of PML errors seen
 *	prior to the call, and resets the error count to zero.
 *
 *  USAGE
 *
 *	int pmlcnt()
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *	(602) 966-8871
 *
 */

int pmlcnt()
{
    register int rtn_val;

    rtn_val = err_count;
    err_count = 0;
    return(rtn_val);
}


/*
 *  FUNCTION
 *
 *	pmlerr   Portable Math Library error handler
 *
 *  KEY WORDS
 *
 *	pmlerr
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Provides a sample PML error handler.  Does
 *	not use any available hardware "traps" so is machine
 *	independent.  Generally only called internally by the
 *	other PML routines.
 *
 *	There are currently three flags which control the
 *	response for specific errors:
 *
 *	 (1)  LOG      When set an error message is sent
 *	               to the user terminal.
 *
 *	 (2)  COUNT    When set the error is counted
 *	               against the PML error limit.
 *
 *	 (3) CONTINUE  When set the task continues
 *	               providing the error count has not
 *	               exceeded the PML error limit.
 *
 *	Each of these flags can be set or reset independently
 *	by "pmlsfs" or "pmlcfs" respectively.
 *
 *  USAGE
 *
 *	pmlerr(err_code)
 *	int err_code;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *	(602) 966-8871
 *
 */

pmlerr(err_code)
register int err_code;
{
    register struct pml_err *err;

    if (err_code < 0 || err_code > ((int)sizeof(pml_errs)/(int)sizeof(struct pml_err))) {
	fprintf(stderr,"pmlerr: invalid error code %d\n",err_code);
    } else {
	err = &pml_errs[err_code];
	if (err->flags & LOG) {
	    fprintf(stderr,"pml: %s in function \"%s\"\n",err->msg,err->func);
	}
	if (err->flags & COUNT) {
	    err_count++;
	}
	if ((err->flags & CONTINUE) && (err_count <= err_limit)) {
	    return;
	} else {
	    fprintf(stderr,"pml: error limit exceeded\n");
	    fprintf(stderr,"pml: task aborted with %d error(s)\n",
		err_count);
	    exit(-1);
	}
    }
}


/*
 *  FUNCTION
 *
 *	pmllim   Set Portable Math Library error limit
 *
 *  KEY WORDS
 *
 *	pmllim
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Sets the PML error limit to the specified value
 *	and returns it previous value.
 *	Does not affect the current error count (which may be reset
 *	to zero by a call to "pmlcnt").  Note that the default error
 *	limit is set at compile time by the value in "pml.h".
 *
 *  USAGE
 *
 *	int pmllim(limit)
 *	int limit;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *	(602) 966-8871
 *
 */

int pmllim(limit)
register int limit;
{
    register int rtn_val;

    rtn_val = err_limit;
    err_limit = limit;
    return(rtn_val);
}


/*
 *  FUNCTION
 *
 *	pmlsfs   Set specified PML error handler flags
 *
 *  KEY WORDS
 *
 *	pmlsfs
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Set the specified PML error handler flags for the
 *	specified error.  Two or more flags may be set simultaneously
 *	by "or-ing" them in the call, for example "LOG | CONTINUE".
 *	The manifest constants for the flags and error codes are
 *	defined in <pmluser.h>.
 *
 *  USAGE
 *
 *	pmlsfs(err_code,flags)
 *	int err_code;
 *	int flags;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *	Tempe, Az 85281
 *
 */

pmlsfs(err_code,flag_word)
register int err_code;
register int flag_word;
{
    if (err_code < 0 || err_code > ((int)sizeof(pml_errs)/(int)sizeof(struct pml_err))) {
	fprintf(stderr,"? pmlsfs --- invalid error code %d.\n",err_code);
    } else {
	pml_errs[err_code].flags |= flag_word;
    }
}
