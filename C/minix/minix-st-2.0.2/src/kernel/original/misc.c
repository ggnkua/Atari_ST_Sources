/* This file contains a collection of miscellaneous procedures:
 *	mem_init:	initialize memory tables.
 *	env_parse	parse environment variable.
 *	bad_assertion	for debugging
 *	bad_compare	for debugging
 */

#include "kernel.h"
#include "assert.h"
#include <stdlib.h>
#include <minix/com.h>

#if (CHIP == INTEL)

/* In real mode only 1M can be addressed, and in 16-bit protected mode 16M. */
#define MAX_86ADDR	0x00100000L
#define MAX_286ADDR	0x01000000L

/*=========================================================================*
 *				mem_init				   *
 *=========================================================================*/
PUBLIC void mem_init()
{
/* Initialize the free memory list from the 'memory' boot variable.  Translate
 * the byte offsets and sizes in this list to clicks, properly truncated.  Also
 * make sure that we don't exceed the maximum address space of the 286 or the
 * 8086, i.e. when running in 16-bit protected mode or real mode.
 */
  long base, size, limit;
  static char env[] = "memory";
  static char fmt[] = "x:x,\4";
  int i;
  struct memory *memp;
#if _WORD_SIZE == 2
  unsigned long max_address;
#endif

  tot_mem_size = 0;
  for (i = 0; i < NR_MEMS; i++) {
	memp = &mem[i];
	base = size = 0;
	env_parse(env, fmt, 2*i+0, &base, 0L, LONG_MAX);
	env_parse(env, fmt, 2*i+1, &size, 0L, LONG_MAX);
	limit = base + size;
#if _WORD_SIZE == 2
	max_address = protected_mode ? MAX_286ADDR : MAX_86ADDR;
	if (limit > max_address) limit = max_address;
#endif
	base = (base + CLICK_SIZE-1) & ~(long)(CLICK_SIZE-1);
	limit &= ~(long)(CLICK_SIZE-1);
	if (limit <= base) continue;
	memp->base = base >> CLICK_SHIFT;
	memp->size = (limit - base) >> CLICK_SHIFT;
	tot_mem_size += memp->size;
  }
}
#endif /* (CHIP == INTEL) */

/*=========================================================================*
 *				env_parse				   *
 *=========================================================================*/
PUBLIC int env_parse(env, fmt, field, param, min, max)
char *env;		/* environment variable to inspect */
char *fmt;		/* template to parse it with */
int field;		/* field number of value to return */
long *param;		/* address of parameter to get */
long min, max;		/* minimum and maximum values for the parameter */
{
/* Parse an environment variable setting, something like "DPETH0=300:3".
 * Panic if the parsing fails.  Return EP_UNSET if the environment variable
 * is not set, EP_OFF if it is set to "off", EP_ON if set to "on" or a
 * field is left blank, or EP_SET if a field is given (return value through
 * *param).  Commas and colons may be used in the environment and format
 * string, fields in the environment string may be empty, and punctuation
 * may be missing to skip fields.  The format string contains characters
 * 'd', 'o', 'x' and 'c' to indicate that 10, 8, 16, or 0 is used as the
 * last argument to strtol.  If the format string contains something like "\4"
 * then the string is repeated at 4 characters left.
 */

  char *val, *end;
  long newpar;
  int i = 0, radix, r;

  if ((val = k_getenv(env)) == NIL_PTR) return(EP_UNSET);
  if (strcmp(val, "off") == 0) return(EP_OFF);
  if (strcmp(val, "on") == 0) return(EP_ON);

  r = EP_ON;
  for (;;) {
	while (*val == ' ') val++;

	if (*val == 0) return(r);	/* the proper exit point */

	if (*fmt == 0) break;		/* too many values */

	if (*val == ',' || *val == ':') {
		/* Time to go to the next field. */
		if (*fmt == ',' || *fmt == ':') i++;
		if (*fmt++ == *val) val++;
		if (*fmt < 32) fmt -= *fmt;	/* step back? */
	} else {
		/* Environment contains a value, get it. */
		switch (*fmt) {
		case 'd':	radix =   10;	break;
		case 'o':	radix =  010;	break;
		case 'x':	radix = 0x10;	break;
		case 'c':	radix =    0;	break;
		default:	goto badenv;
		}
		newpar = strtol(val, &end, radix);

		if (end == val) break;	/* not a number */
		val = end;

		if (i == field) {
			/* The field requested. */
			if (newpar < min || newpar > max) break;
			*param = newpar;
			r = EP_SET;
		}
	}
  }
badenv:
  printf("Bad environment setting: '%s = %s'\n", env, k_getenv(env));
  panic("", NO_NUM);
  /*NOTREACHED*/
}

#if DEBUG
/*=========================================================================*
 *				bad_assertion				   *
 *=========================================================================*/
PUBLIC void bad_assertion(file, line, what)
char *file;
int line;
char *what;
{
  printf("panic at %s(%d): assertion \"%s\" failed\n", file, line, what);
  panic(NULL, NO_NUM);
}

/*=========================================================================*
 *				bad_compare				   *
 *=========================================================================*/
PUBLIC void bad_compare(file, line, lhs, what, rhs)
char *file;
int line;
int lhs;
char *what;
int rhs;
{
  printf("panic at %s(%d): compare (%d) %s (%d) failed\n",
	file, line, lhs, what, rhs);
  panic(NULL, NO_NUM);
}
#endif /* DEBUG */
