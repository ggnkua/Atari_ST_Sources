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

/*
 * Symbol table:
 *
 * For each symbol, contains a pointer to the block starting at the
 * given symbol, and a pointer to the next symbol in the symbol table.
 */
struct	sym {
	char	*name;
	BLOCK	*bp;
	struct	sym	*next;
};

struct	sym	*sfirst = NULL;
struct	sym	*slast  = NULL;

/*
 * newblock(name) - allocate a new block structure and initialize it
 */
BLOCK *
newblock(name)
register char	*name;
{
	register BLOCK	*bp;

	if ((bp = (BLOCK *) alloc(sizeof(BLOCK))) == NULL)
		return NULL;

	/*
	 * Initialize the allocated block structure.
	 */

	if ((bp->name = strsave(name)) == NULL) {
		free(bp);
		return NULL;
	}

	bp->flags = 0;
	bp->ref   = 0;
	bp->bcode = 0;
	bp->first = NULL;
	bp->last  = NULL;
	bp->bcond = NULL;
	bp->bfall = NULL;
	bp->chain = NULL;
	bp->next  = NULL;
	bp->rref = bp->rset = 0;

	return bp;
}

/*
 * mksym(name) - make a new symbol table entry
 *
 * mksym creates new symbol table entries, and allocates space for the
 * 'block' structure that will be used for the symbol. This can happen
 * when a reference to a block is detected, but before the block has
 * been encountered. Since we allocate the block structure here, other
 * blocks can reference it before we actually read it in.
 */
BLOCK *
mksym(name)
register char	*name;
{
	register struct	sym	*new;

	if ((new = (struct sym *) alloc(sizeof(struct sym))) == NULL)
		return NULL;

	if ((new->bp = newblock(name)) == NULL) {
		free(new);
		return NULL;
	}

	new->name = new->bp->name;
	new->next = NULL;

	if (sfirst == NULL)
		sfirst = slast = new;
	else {
		slast->next = new;
		slast = new;
	}

	return new->bp;
}

/*
 * getsym(name) - return a pointer to the block for symbol 'name'
 *
 * Scans the symbol table for the given symbol and returns a pointer
 * to its block, when found, or NULL if not present.
 */
BLOCK *
getsym(name)
register char	*name;
{
	register struct	sym	*sp;

	for (sp = sfirst; sp != NULL ;sp = sp->next) {
		if (strcmp(sp->name, name) == 0)
			return sp->bp;
	}
	return NULL;
}

/*
 * freeop() - free an operand
 */
void
freeop(op)
struct	opnd	*op;
{
	if (is_astr(op->amode) && op->astr != NULL)
		free(op->astr);
}

/*
 * freesym() - free all symbol table space
 */
void
freesym()
{
	register struct	sym	*sp, *nexts;
	register INST	*ip, *nexti;

	for (sp = sfirst; sp != NULL ;sp = nexts) {
		nexts = sp->next;
		for (ip = sp->bp->first; ip != NULL ; ip = nexti) {
			nexti = ip->next;

			freeop(&ip->src);
			freeop(&ip->dst);
			free(ip);
		}
		free(sp->name);
		free(sp->bp);
		free(sp);
	}
	sfirst = slast = NULL;
}

char *
mktmp()
{
	static	char	tname[32];
	static	int	tnum = 0;

	sprintf(tname, "T%d", tnum++);

	return tname;
}
