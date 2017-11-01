
/* Creature.c - the parts of Pogo that take care of spawning and 
  evolving and killing creatures.  Also the routines for creatures to
  find other creatures.
  */

#include <stdio.h>
#include "pogo.h"
#include "dlist.h"

#define CMAX 256

extern void *askmem();
extern int creature_count;

struct pogo_op *cr_code[CMAX];
union pt_int *cr_data[CMAX];
int cr_datasize[CMAX];
char cr_state[CMAX];
struct func_frame *cr_fuf[CMAX];
Tlist **type_alive;
Tlist *cr_tels;
int get_ta;
int cur_pid;

#define CR_EMPTY 0
#define CR_KILLING 1
#define CR_RUNNING 2

int cr_count;
int cr_hi = 1;

void *
linkt(list, t)
Tlist *list, *t;
{
if (list == NULL)
	{
	t->next = t;
	t->prev = t;
	return(t);
	}
else
	{
	list->prev->next = t;
	t->prev = list->prev;
	list->prev = t;
	t->next = list;
	return(list);
	}
}

void *
unlinkt(list, t)
Tlist *list;
register Tlist *t;
{
if (t == list)	/* remove head ... it's easy */
	{
	if (t->next == t)		/* all alone in the world??? */
		return(NULL);
	t->next->prev = t->prev;
	t->prev->next = t->next;
	return(t->next);
	}
else	/* remove non-head (so can assume at least 2 els in list */
	{
	t->next->prev = t->prev;
	t->prev->next = t->next;
	return(list);
	}
}

add_type(type, id)
int type, id;
{
register Tlist *t;

t = cr_tels+id;
t->id = id;
type_alive[type] = linkt(type_alive[type], t);
}


free_type(type, id)
int type,id;
{
Tlist *t;

type_alive[type] = unlinkt(type_alive[type], cr_tels+id);
}

alloc_type_alive()
{
if (get_ta && creature_count)
	{
	if ((type_alive = beg_zero(creature_count*sizeof(Tlist *))) == NULL)
		return(0);
	if ((cr_tels = beg_mem(CMAX*sizeof(Tlist))) == NULL)
		{
		freemem(type_alive);
		type_alive = NULL;
		return(0);
		}
	}
return(1);
}


go_spawn(p)
union pt_int *p;
{
int i, dsize, dbsize;
union pt_int *data;
struct func_frame *fuf;

if (cr_count >= CMAX-1)
	return(0);
for (i=1; i<CMAX; i++)
	{
	if (cr_state[i] == CR_EMPTY)
		{
		fuf = p[-5].p;
		cr_datasize[i] = dsize = fuf->dcount + SECRETS;
		dbsize = (dsize * sizeof(union pt_int)); 
		if ((cr_data[i] = data = askmem(dbsize)) == NULL)
			return(-1);
		zero_bytes(data, dbsize);
		data[CID].i = i;	/* Set id */
		data[CNEW].i = 1;	/* Set NewBorn */
		data[CNAME].p = fuf->name;	/* Set MyName */
		data[CTYPE].i = fuf->crtype;
		if (get_ta)
			add_type(fuf->crtype, i);
		copy_pts(p-4, data+4, 4);	/* copy over x, y, dx, dy */
		cr_code[i] = fuf->code;
		cr_state[i] = CR_RUNNING;
		cr_fuf[i] = fuf;
		if (i >= cr_hi)
			cr_hi = i+1;
		cr_count++;
		return(i);
		}
	}
}




static
free_cr_strings(dd, sym)
union pt_int *dd;
Symbol *sym;
{
while (sym != NULL)
	{
	if (sym->type == STRING)
		gentle_free(dd[sym->doff].p);
	sym = sym->next;
	}
}

static killi(i)
int i;
{
union pt_int *dd;
struct func_frame *fuf;


cr_code[i] = NULL;
dd = cr_data[i];
fuf = cr_fuf[i];
if (fuf->got_strings)
	{
	free_cr_strings(dd+SECRETS, fuf->symbols);
	}
if (get_ta)
	free_type(dd[CTYPE].i, i);
freemem(dd);
cr_data[i] = NULL;	/* flushes out bugs */
cr_count -= 1;
cr_state[i] = CR_EMPTY;
if (i == cr_hi-1)
	{
	cr_hi -= 1;
	}
}

go_evolve(dstack)
union pt_int *dstack;
{
union pt_int *dd;
int dsize;
int i;


for (i=1; i<cr_hi; i++)
	{
	cur_pid = i;
	switch (cr_state[i])
		{
		case CR_KILLING:
			{
			killi(i);
			}
			break;
		case CR_RUNNING:
			{
			dd = cr_data[i];
#ifdef DEBUG
			if (dd[0].i != i)
				{
				puts("Creature id fucked up");
				printf("should be %d but is %d\n", i, dd[0].i);
				run_abort = 1;
				return;
				}
#endif DEBUG
			dsize = cr_datasize[i];
			copy_pts(dd, dstack, dsize);
			run_ops(cr_code[i], dstack+SECRETS);
			copy_pts(dstack, dd, dsize);
			dd[1].i++;
			dd[2].i = 0;
			if (run_abort)
				break;
			}
		}
	}
cur_pid = 0;
}

/* This code breaks here if sizeof(pt_int) != sizeof(long) */
copy_pts(s, d, count)
register long *s, *d;
register int count;
{
while (--count >= 0)
	*d++ = *s++;
}

cexists(cr)
int cr;
{
return (cr > 0 && cr <= cr_hi && cr_state[cr] == CR_RUNNING);
}

check_valid_creature(s, cr)
char *s;
int cr;
{
if (cexists(cr) )
	return(1);
else
	{
	no_such_creature(s, cr);
	return(0);
	}
}


go_kill(cr)
int cr;
{
union pt_int *data;

if (!check_valid_creature("Kill", cr))
	return;
cr_state[cr] = CR_KILLING;
}

kill_all()
{
int i;
union pt_int *dd;

for (i=1; i<CMAX; i++)
	{
	if (cr_state[i] != CR_EMPTY)
		{
		killi(i);
		}
	}
cr_hi = 1;
cr_count = 0;
}

fclosestt(p)
union pt_int *p;
{
Tlist *dd, *head;
int i, x, y;
register int dx, dy;
int closest;
long distance, d;
union pt_int *cdata;
int me;
int cix;

distance = 1L<<30;
closest = 0;
me = p[-3].i;
x = p[-2].i;
y = p[-1].i;
head = dd = type_alive[me];
if (dd != NULL)
	{
	for (;;)
		{
		cix = dd->id;
		if (cr_state[cix] == CR_RUNNING)
			{
			cdata = cr_data[cix];
			dx = x - cdata[CX].i;
			dy = y - cdata[CY].i;
			if (dx < 0)
				dx = -dx;
			if (dy < 0)
				dy = -dy;
			d = dx + dy;
			if (d < distance)
				{
				closest = cix;
				distance = d;
				}
			}
		dd = dd->next;
		if (dd == head)
			break;
		}
	}
return(closest);
}

void *
do_cread(p)
union pt_int *p;
{
int cr,type,doff;

type = p[-3].i;
doff = p[-2].i;
cr = p[-1].i;
#ifdef DEBUG
printf("cr %d type %d doff %d\n", cr, type, doff);
#endif DEBUG
if (!check_valid_creature("Cread", cr))
	return(NULL);
p = cr_data[cr];
if (type != p[CTYPE].i)
	{
	runtime_err("Trying to read wrong type of creature");
	}
return(p[doff+SECRETS].p);
}

do_cwrite(p)
union pt_int *p;
{
int cr,type,doff;
union pt_int *d;

type = p[-4].i;
doff = p[-3].i;
cr = p[-2].i;
#ifdef DEBUG
printf("cr %d type %d doff %d data\n", cr, type, doff, p[-1].i);
#endif DEBUG
if (!check_valid_creature("Cwrite", cr))
	return(NULL);
d = cr_data[cr];
if (type != d[CTYPE].i)
	{
	runtime_err("Trying to write wrong type of creature");
	}
d[doff+SECRETS].p = p[-1].p;
}


closest_type(p)
union pt_int *p;
{
int i, x, y;
register int dx, dy;
int closest;
long distance, d;
union pt_int *cdata;
char *me;

distance = 1L<<30;
closest = 0;
me = p[-3].p;
x = p[-2].i;
y = p[-1].i;
for (i=1; i<=cr_hi; i++)
	{
	if (cr_state[i] == CR_RUNNING)
		{
		cdata = cr_data[i];
		if (strcmp(me, cdata[CNAME].p) == 0)
			{
			dx = x - cdata[CX].i;
			dy = y - cdata[CY].i;
			if (dx < 0)
				dx = -dx;
			if (dy < 0)
				dy = -dy;
			d = dx + dy;
			if (d < distance)
				{
				closest = i;
				distance = d;
				}
			}
		}
	}
return(closest);
}

closest_creature(p)
union pt_int *p;
{
int i, x, y;
int dx, dy;
int closest;
long distance, d;
union pt_int *cdata;
int me;

distance = 1L<<30;
closest = 0;
me = p[-3].i;
x = p[-2].i;
y = p[-1].i;
for (i=1; i<=cr_hi; i++)
	{
	if (me != i)
		{
		if (cr_state[i] == CR_RUNNING)
			{
			cdata = cr_data[i];
			dx = x - cdata[CX].i;
			dy = y - cdata[CY].i;
			d = mult_to_long(dx,dx) + mult_to_long(dy,dy);
			if (d < distance)
				{
				closest = i;
				distance = d;
				}
			}
		}
	}
return(closest);
}

named_creature(p)
union pt_int *p;
{
char *name;
union pt_int *cdata;
int i;

name = p[-1].p;
for (i=1; i<cr_hi; i++)
	{
	if (cr_state[i] == CR_RUNNING)
		{
		cdata = cr_data[i];
		if (strcmp(name, cdata[CNAME].p) == 0)
			return(i);
		}
	}
return(0);
}

exists_creature(p)
union pt_int *p;
{
return(cexists(p[-1].i) );
}


creature_age(p)
union pt_int *p;
{
int cr;

cr = p[-1].i;
if (check_valid_creature("CreatureAge", cr) )
	{
	p = cr_data[cr];
	return(p[CAGE].i);
	}
}


creature_newborn(p)
union pt_int *p;
{
int cr;

cr = p[-1].i;
if (check_valid_creature("CreatureNewBorn", cr) )
	{
	p = cr_data[cr];
	return(p[CNEW].i);
	}
}

creature_x(p)
union pt_int *p;
{
int cr;

cr = p[-1].i;
if (check_valid_creature("CreatureX", cr) )
	{
	p = cr_data[cr];
	return(p[CX].i);
	}
}

creature_y(p)
union pt_int *p;
{
int cr;

cr = p[-1].i;
if (check_valid_creature("CreatureY", cr) )
	{
	p = cr_data[cr];
	return(p[CY].i);
	}
}

char *
creature_name(p)
union pt_int *p;
{
int cr;

cr = p[-1].i;
if (check_valid_creature("CreatureName", cr) )
	{
	p = cr_data[cr];
	return(p[CNAME].p);
	}
}



