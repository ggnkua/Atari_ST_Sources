/*
 *  .GOTO <label>
 *
 *  The label is searched for starting from the first line of
 *  the current, enclosing macro definition.  If no enclosing
 *  macro exists, an error is generated.
 *
 *  A label is of the form:
 *
 *	:<name><whitespace>
 *
 *  The colon must appear in column 1.  The label is stripped prior
 *  to macro expansion, and is NOT subject to macro expansion.  The
 *  whitespace may also be EOL.
 *
 */
d_goto(siz)
     WORD siz;
{
    char *sym;
    register LONG *defln;
    register char *s1;
    register char *s2;
    IMACRO *imacro;		/* -> macro invocation block */

    if (*tok != SYMBOL) return error("missing label");
    if (cur_inobj->in_type != IMACRO) return error("goto not in macro");
    imacro = cur_inobj->in_inobj.imacro;
    defln = (LONG *)imacro->im_macro->svalue;

    /*
     *  Find the label
     */
    for (; defln != NULL; defln = (LONG *)*defln)
      if (*(char *)(defln + 1) == ':') {
	  /*
	   *  Compare names (sleazo string compare)
	   */
	  s1 = sym;
	  s2 = (char *)(defln + 1) + 1;
	  while (*s1 == *s2)
	    if (*s1 == EOS) break;
	    else {
		++s1;
		++s2;
	    }

	  /*
	   *  Found label,
	   *   set new macro next-line and return.
	   */
	  if (*s2 == EOS || chrtab[*s2] & WHITE) {
	      imacro->im_next = defln;
	      return;
	  }
      }

    return error("goto label not found");
}
