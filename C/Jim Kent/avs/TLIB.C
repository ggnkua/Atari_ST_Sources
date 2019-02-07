/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"

struct tlib *tlibrary;
extern char *getend();

free_slib(s)
struct seq_lib *s;
{
WORD **pt;
int i;

if (s != NULL)
	{
	gentle_free(s->first_frame);
	i = s->frames_read;
	if ((pt = s->deltas) != NULL)
		{
		while (--i >= 0)
			gentle_free(*pt++);
		freemem(s->deltas);
		}
	freemem(s);
	}
}

free_a_tlib(l)
register struct tlib *l;
{
switch (l->type)
	{
	case TR_SPL:
		gentle_free(l->image);
		break;
	case TR_SEQ:
		free_slib(l->image);
		break;
	}
gentle_free(l->name);
freemem(l);
}

clean_tlib()
{
register struct tlib *newlib, *l, *next;

newlib = NULL;
l = tlibrary;
while (l != NULL)
	{
	next = l->next;
	if (l->links <= 0)
		free_a_tlib(l);
	else
		{
		l->next = newlib;
		newlib = l;
		}
	l = next;
	}
tlibrary = newlib;
}

unlink_track(t)
struct track *t;
{
if (t && t->lib)
	{
	t->lib->links -= 1;
	t->lib = NULL;
	}
clean_tlib();
}

struct tlib *
in_tlibrary(name, type)
char *name;
WORD type;
{
register struct tlib *n;

n = tlibrary;
while (n != NULL)
	{
	if (strcmp(n->name, name) == 0 && n->type == type)
		return(n);
	n = n->next;
	}
return(NULL);
}

struct tlib *
get_tlib(name, type)
char *name;
WORD type;
{
register struct tlib *l;
int ok;
char buf[80];
char *lname;
int fd;

lname = getend(name);	/* get name without path stuff too */
if ((l = in_tlibrary(name, type)) != NULL)
	return(l);
if ((l = in_tlibrary(lname, type)) != NULL)
	return(l);
if ((fd = Fopen(name, 0)) < 0)
	name = lname;
else
	Fclose(fd);

if ((l = begzeros(sizeof(*l))) == NULL)
	return(NULL);
sprintf(buf, "Loading %s", name);
top_message(buf);
switch (type)
	{
	case TR_SEQ:
		ok = ld_seq(name, l);
		break;
	case TR_SPL:
		ok = ld_spl(name, l);
		break;
	}
if (!ok)
	{
	freemem(l);
	return(NULL);
	}
if ((l->name = clone_string(name)) == NULL)
	{
	outta_memory();
	freemem(l);
	return(NULL);
	}
l->type = type;
l->next = tlibrary;
tlibrary = l;
return(l);
}

int spl_speed[] = {5000, 7500, 10000, 15000, 20000, 31000 };

set_duration(t)
struct track *t;
{
switch (t->type)
	{
	case TR_SEQ:
		t->duration = t->speed*t->samples*t->loops;
		break;
	case TR_SPL:
		t->duration = t->samples*60/spl_speed[t->speed]*t->loops;
		break;
	}
}

attatch_tlib(t, tl, sname)
struct track *t;
struct tlib *tl;
char *sname;
{
tl->links++;
strcpy(t->name, sname);
t->type = tl->type;
t->speed = tl->default_speed;
t->samples = tl->samples;
t->lib = tl;
t->loops = 1;
set_duration(t);
}
