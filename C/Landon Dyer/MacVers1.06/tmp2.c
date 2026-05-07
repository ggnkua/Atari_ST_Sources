#define MAX_CALLARGS	32	/* maximum # of args to a .call directive */

/*
 *  .call thing [, arg1[.siz], arg2[.siz], ... ]
 *
 *	push argN
 *	.
 *	.
 *	push arg2
 *	push arg1
 *	call thing
 *	cleanup stack
 *
 *  The 'thing' is one of:
 *	#n	trap #n
 *	expr	a function to JSR
 *	expr.w	a function to BSR
 *
 */
d_call(siz)
     WORD siz;
{
  TOKEN *argbuf[MAX_CALLARGS];
  VALUE cleanamt = 0;
  int argno = 0;
  NOREG VALUE eval;
  NOREG WORD eattr;

  for (; *tok != EOL;)
    {
      if (argno >= MAX_CALLARGS)
	return error("too many .call arguments");

      argbuf[argno++] = tok;
      for (;;)
	switch (*tok)
	  {
	  case EOL:
	  case ',':
	    continue;

	  case ACONST:
	    ++tok;

	  case STRING:
	  case SYMBOL:
	    ++tok;

	  default:
	    ++tok;
	    break;
	  }
    }

  while (--argno > 0)
    {
      tok = argbuf[argno];
      if (amode(0) < 0)
	return;

    }
}
