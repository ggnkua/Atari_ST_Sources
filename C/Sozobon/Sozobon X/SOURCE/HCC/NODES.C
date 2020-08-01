/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	nodes.c
 *
 *	Node allocation, deallocation, searching, printing
 *	and other node handling
 */

#include <stdio.h>
#include "param.h"
#include "nodes.h"

extern FILE *output;
NODE *freelist;

#define NODEINCR	100

extern int oflags[];
#define debug oflags['n'-'a']

#define NODELEN	(sizeof(NODE)/4)

int nodesmade, nodesavail;

NODE *
allocnode()
{
	char *calloc();
	NODE *t;
	int i;

retry:
	if (freelist != 0) {
		t = freelist;
		freelist = t->n_next;
		lclr(t, NODELEN);
		nodesavail--;
		if (debug)
			printf("%lx+ ", t);
		return t;
	}
	t = (NODE *)calloc(NODEINCR, sizeof(NODE));
	if (t == 0) {
		printf("malloc failure\n");
		exit(1);
	}
	nodesmade += NODEINCR;
	nodesavail += NODEINCR;
	for (i=0; i<NODEINCR; i++)
		t[i].n_next = &t[i+1];
	t[NODEINCR-1].n_next = 0;
	freelist = t;
	goto retry;
}

freeunit(t)
NODE *t;
{
	if (t->n_flags & N_ISFREE) {
		printf("%lx ", t);
		error("Freeing free node");
		exit(1);
	} else
		t->n_flags |= N_ISFREE;
	t->n_next = freelist;
	freelist = t;
	nodesavail++;
	if (debug)
		printf("%lx- ", t);
}

freenode(t)
NODE *t;
{
	register NODE *nxt;

	if (t == NULL) return;
again:
	if (t->n_right)
		freenode(t->n_right);
	if (t->n_nmx)
		freenode(t->n_nmx);
	if (t->n_tptr && (t->n_flags & N_COPYT) == 0)
		freenode(t->n_tptr);
	nxt = t->n_left;
	freeunit(t);
	if (nxt) {
		t = nxt;
		goto again;	/* minimize left recursion */
	}
}

put_nnm(t)
NODE *t;
{
	printf("%s", t->n_name);
	while (t->n_nmx) {
		t = t->n_nmx;
		printf("%s", t->n_name);
	}
}

qput_nnm(t, fd)
NODE *t;
FILE *fd;
{
	fprintf(fd, "%s", t->n_name);
	while (t->n_nmx) {
		t = t->n_nmx;
		fprintf(fd, "%s", t->n_name);
	}
}

fput_nnm(t)
NODE *t;
{
	fprintf(output, "%s", t->n_name);
	while (t->n_nmx) {
		t = t->n_nmx;
		fprintf(output, "%s", t->n_name);
	}
}

/* add a short string (less than NMXSIZE) to front of name */
nnmins(t, s)
NODEP t;
char *s;
{
	register i, j;
	char tbuf[NMSIZE];
	NODEP n;

	i = strlen(t->n_name);
	j = strlen(s);
	if (j > NMSIZE-1)
		return;		/* compiler error */
	if (i+j <= NMSIZE-1) {		/* fits in node */
		strcpy(tbuf, t->n_name);
		strcpy(t->n_name, s);
		strcpy(t->n_name+j, tbuf);
	} else {
		n = allocnode();
		n->n_nmx = t->n_nmx;
		t->n_nmx = n;
		strcpy(n->n_name, t->n_name);
		strcpy(t->n_name, s);
	}
}

/* add a short string (less than NMXSIZE) to end of name */
nnmadd(t, s)
NODE *t;
char *s;
{
	register i,j;
	int sizeb;
	NODEP n;

	/* find last node */
	sizeb = NMSIZE;
	while (t->n_nmx) {
		t = t->n_nmx;
		sizeb = NMXSIZE;
	}
	/* fits in current last node? */
	i = strlen(s);
	j = strlen(t->n_name);
	if (i < sizeb-j) {
		strcat(t->n_name, s);
		return;
	}
	/* put all of s in new node */
	n = allocnode();
	t->n_nmx = n;
	t = n;
	strncpy(t->n_name, s, NMXSIZE-1);
	t->n_name[NMXSIZE-1] = 0;
}

nscpy(t, s)
NODE *t;
char *s;
{
	register i;
	NODEP n;

	i = strlen(s);
	strncpy(t->n_name, s, NMSIZE-1);
	t->n_name[NMSIZE-1] = 0;
	i -= NMSIZE-1;
	s += NMSIZE-1;
	while (i > 0) {
		n = allocnode();
		t->n_nmx = n;
		t = n;
		strncpy(t->n_name, s, NMXSIZE-1);
		t->n_name[NMXSIZE-1] = 0;
		i -= NMXSIZE-1;
		s += NMXSIZE-1;
	}
}

putlist(head, np)
NODE **head, *np;
{
	np->n_next = *head;
	*head = np;
}

puthlist(head, np)
NODE *head[], *np;
{
	putlist(&head[hash(np->n_name)], np);
}

NODE *
llook(head, np)
NODE *head, *np;
{
	register NODEP p;

	for (p=head; p != NULL; p = p->n_next)
		if (xstrcmp(p, np) == 0) {
			return p;
		}
	return NULL;
}

NODE *
hlook(head, np)
NODE *head[], *np;
{
	register NODEP p;

	p = head[hash(np->n_name)];
	return llook(p, np);
}

hash(s)
register char *s;
{
	register hval;

	hval = 0;
	while (*s)
		hval += *s++;
	return hval & (NHASH-1);
}

xstrcmp(p1, p2)
NODE *p1, *p2;
{
	int rv;

	if ((rv = strcmp(p1->n_name, p2->n_name)) != 0)
		return rv;
	if (p1->n_nmx == NULL) {
		if (p2->n_nmx == NULL)
			return 0;
		return -1;
	}
	if (p2->n_nmx == NULL)
		return 1;
	return xstrcmp(p1->n_nmx, p2->n_nmx);
}

char *
scopy(s)
char *s;
{
	int i;
	char *p;

	i = strlen(s)+1;
	if (i > sizeof(NODE)) {
		error("preproc name too big");
		i = sizeof(NODE);
		s[i-1] = 0;
	}
	p = (char *)allocnode();
	strcpy(p, s);
	return p;
}

sfree(s)
char *s;
{
	NODEP np;

	np = (NODEP)s;
	np->n_flags = 0;
	freeunit(np);
}

printlist(np)
NODE *np;
{
	putchar('\n');
	prln(np, 2);
}

prln(np, indent)
NODE *np;
{
	register NODE *svl, *nxtl;

	for (svl=np; svl != NULL; svl = nxtl) {
		nxtl = svl->n_next;
		svl->n_next = NULL;
		prnode(svl,indent);
		svl->n_next = nxtl;
		/* special hack for tag list */
		if ((svl->n_flags & N_BRKPR) && svl->n_right)
			prln(svl->n_right, indent+2);
	}
}

codeprint(np)
NODEP np;
{
	putchar('\n');
	cprnode(np,0);
}

cprnode(np,indent)
NODE *np;
{
	int ni;
	NODEP tp;

	ni = indent+1;
	while (indent--)
		putchar(' ');
	if (np == NULL) {
		printf("<NULL>\n");
		return;
	}
	put_nnm(np);	/* Note: BRKPR doesnt break long names */
	if (np->g_offs)
		printf(" o%ld ", np->g_offs);
	if (np->g_rno)
		printf(" r%d ", np->g_rno);
	if (np->g_needs)
		printf(" n%o ", np->g_needs);
	if (debug) {
		printf("@%lx ", np);
		if (np->n_flags & N_COPYT)
			printf("C ");
		if (np->n_flags & N_BRKPR)
			printf("B ");
	}
	if (np->n_flags & N_BRKPR) {
		putchar('\n');
		return;
	}
	if (np->g_betw)
		printf(" {%s}", np->g_betw);
	if (np->g_code) {
		if (np->n_flags & N_COPYT)
			printf(" <%s>", np->g_code);
		else
			for (tp=np->g_code; tp; tp = tp->g_code)
				printf(" <%s>", tp->n_name);
	}
	putchar(' ');
	out_a(np, stdout);
	putchar('\n');
	if (np->n_left) {
		cprnode(np->n_left,ni);
	} else if (np->n_right)
		cprnode(NULL, ni);
	if (np->n_right) {
		cprnode(np->n_right,ni);
	}
}

printnode(np)
NODE *np;
{
	putchar('\n');
	prnode(np,0);
}

prnode(np,indent)
NODE *np;
{
	int ni;

	ni = indent+1;
	while (indent--)
		putchar(' ');
	if (np == NULL) {
		printf("<NULL>\n");
		return;
	}
	put_nnm(np);	/* Note: BRKPR doesnt break long names */
	if (np->e_offs)
		printf(" o%ld ", np->e_offs);
	if (np->e_rno)
		printf(" r%d ", np->e_rno);
	if (np->e_fldw)
		printf(" (%d,%d) ", np->e_fldw, np->e_fldo);
	if (debug) {
		printf("@%lx ", np);
		if (np->n_flags & N_COPYT)
			printf("C ");
		if (np->n_flags & N_BRKPR)
			printf("B ");
	}
	if (np->n_flags & N_BRKPR) {
		putchar('\n');
		return;
	}
	if (np->n_tptr) {
		if (np->e_flags & 256)	/* IMMEDID */
			printf(" $$$ ");
		tprint(np->n_tptr);
	}
	putchar('\n');
	if (np->n_left) {
		prnode(np->n_left,ni);
	} else if (np->n_right)
		prnode(NULL, ni);
	if (np->n_right) {
		prnode(np->n_right,ni);
	}
}

tprint(np)
NODEP np;
{
	while (np != NULL) {
		putchar(' ');
		put_nnm(np);
#ifdef HANS
		if (np->t_size)
			printf(" s%ld", np->t_size);
		if (np->t_aln)
			printf(" a%d", np->t_aln);
#endif
		if (debug)
			printf("@%lx", np);
		np = np->n_tptr;
	}
}

NODEP
copynode(op)
NODEP op;
{
	NODEP np;

	if (op == NULL) return NULL;
	np = allocnode();
	lcpy(np, op, NODELEN);
	if (np->n_nmx)
		np->n_nmx = copynode(np->n_nmx);
	if (np->n_right)
		np->n_right = copynode(np->n_right);
	if (np->n_left)
		np->n_left = copynode(np->n_left);
	if (np->n_tptr)
		np->n_flags |= N_COPYT;
	return np;
}

NODEP
copyone(op)
NODEP op;
{
	NODEP np;

	if (op == NULL) return NULL;
	np = allocnode();
	lcpy(np, op, NODELEN);
	if (np->n_nmx)
		np->n_nmx = copyone(np->n_nmx);
	if (np->n_right)
		np->n_right = NULL;
	if (np->n_left)
		np->n_left = NULL;
	if (np->n_tptr)
		np->n_flags |= N_COPYT;
	return np;
}

NODEP
copy_nol(op)
NODEP op;
{
	NODEP np;

	if (op == NULL) return NULL;
	np = allocnode();
	lcpy(np, op, NODELEN);
	if (np->n_nmx)
		np->n_nmx = copynode(np->n_nmx);
	if (np->n_right) /* break right links */
		np->n_right = NULL;
	if (np->n_tptr)
		np->n_flags |= N_COPYT;
	return np;
}

NODEP
copylist(np, tailp)
NODE *np, **tailp;
{
	NODEP rv, nx;
	register NODEP tail;

	if (np == NULL) {
		*tailp = NULL;
		return NULL;
	}
	rv = copy_nol(np);
	tail = rv;
	while (tail->n_left) {
		nx = copy_nol(tail->n_left);
		tail->n_left = nx;
		tail = nx;
	}
	*tailp = tail;
	return rv;
}

NODE *
nthnode(np, n)
NODE *np;
{
	while (n--)
		if (np == NULL)
			return NULL;
		else
			np=np->n_next;
	return np;
}

NODE *
rthnode(np, n)
NODE *np;
{
	while (n--)
		if (np == NULL)
			return NULL;
		else
			np=np->n_right;
	return np;
}
