/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */
#include "top.h"

BLOCK	*fhead;		/* head of the current function */

/*
 * dofunc() - process one function
 *
 * Returns FALSE on end of file
 */
bool
dofunc()
{
	BLOCK	*getfunc();

	clrvar();

#ifdef	DEBUG
	if (debug)
		fprintf(stderr, "dofunc() - calling getfunc()\n");
#endif
	if ((fhead = getfunc()) == NULL)
		return FALSE;

	/*
	 * Process the function we just read
	 */
	bopt(fhead);		/* perform branch optimization */

	if (do_regs)
		setreg(fhead);	/* try to assign locals to registers */

	if (do_peep) {
		rhealth(fhead, TRUE);	/* live/dead register analysis */
		peep(fhead);		/* peephole optimizations */
	}

	/*
	 * Now dump out the modified tree
	 */
#ifdef	DEBUG
	if (debug)
		fprintf(stderr, "dofunc() - calling putfunc()\n");
#endif
	putfunc(fhead);

	freesym();		/* free the symbol table */

	return TRUE;
}

static	bool	saw_eof = FALSE;

/*
 * getfunc() - get a function and return a pointer to its starting block
 *
 * Returns NULL on end of file.
 */
BLOCK *
getfunc()
{
	register BLOCK	*head;	/* starting block for this function */
	register BLOCK	*cb;	/* the block we're currently reading */
	register BLOCK	*ob;	/* the last block we read */

	if (saw_eof)
		return NULL;

	head = NULL;

	/*
	 * Starting a global function
	 */
	if (strcmp(t_op, ".globl") == 0) {
		/*
		 * Enter the symbol and mark it global.
		 */
		head = mksym(t_arg);
		head->flags |= B_GLOBAL;
	
		readline();
	}

	ob = NULL;

	for (;;) {
		if (ob == NULL) {
			if (t_lab[0] != '_') {
				fprintf(stderr, "top: expected function label\n");
				exit(1);
			}
			if (head == NULL)
				head = mksym(t_lab);

		} else if (t_lab[0] == '\0') {
			fprintf(stderr, "top: expected block label\n");
			exit(1);
		}

		if ((cb = getsym(t_lab)) == NULL)
			cb = mksym(t_lab);

		/*
		 * The last block falls through to this one.
		 */
		if (ob != NULL) {
			ob->chain = cb;
			ob->next = cb;
			ob->bfall = cb;
		}

		t_lab[0] = '\0';

		/*
		 * Now read lines until we hit a new block or another
		 * function.
		 */
		for (;;) {
			/*
			 * If we see a global, we're done with the function
			 */
			if (strcmp(t_op, ".globl") == 0)
				return head;
			/*
			 * If we see a function label, we're done too.
			 */
			if (t_lab[0] == '_')
				return head;
			/*
			 * If we see any other label, we're done with the block.
			 */
			if (t_lab[0])
				break;

			addinst(cb, t_op, t_arg);

			/*
			 * If we're at EOF, note that we've hit the end of
			 * file, but return the function we just read.
			 */
			if (!readline()) {
				saw_eof = TRUE;
				return head;
			}
		}
		ob = cb;
	}
}

/*
 * putfunc(sb) - print out the function starting at block 'sb'
 *
 * The 'next' pointers determine the order in which things are placed
 * in the file. Branch instructions have been removed so they need to
 * be replaced here on output. Conditional branches are generated if
 * indicated (by non-null 'bcond'). Unconditional branches are generated
 * at the end of a block if it's "fall through" block isn't going to
 * be the next thing in the file.
 */
putfunc(sb)
register BLOCK	*sb;
{
	register BLOCK	*cb;
	register INST	*ci;

	fprintf(ofp, "\t.text\n");

	for (cb = sb; cb != NULL ;cb = cb->next) {
		if (cb->flags & B_GLOBAL)
			fprintf(ofp, "\t.globl\t%s\n", cb->name);

		if (*cb->name == '_')
			fprintf(ofp, "%s:\n", cb->name);

		else if (cb->flags & B_LABEL)
			fprintf(ofp, "%s:\n", cb->name);
#ifdef	DEBUG
		if (debug) {
			fprintf(ofp, "*\n");
			fprintf(ofp, "* %s, ref:%04x  set:%04x\n",
				cb->name, cb->rref, cb->rset);
			fprintf(ofp, "*\n");
		}
#endif

		for (ci = cb->first; ci != NULL ;ci = ci->next)
			putinst(ci);
		/*
		 * If there's a conditional branch, put out the
		 * appropriate instruction for it.
		 */
		if (cb->bcond != NULL && cb->bcode >= 0)
			fprintf(ofp, "\t%s\t%s\n",
				opnames[cb->bcode], cb->bcond->name);
		/*
		 * If there's a "fall through" label, and the destination
		 * block doesn't come next, put out a branch.
		 */
		if (cb->bfall != NULL && cb->bfall != cb->next) {
			s_badd++;
			fprintf(ofp, "\tbra\t%s\n", cb->bfall->name);
		}
	}
}
