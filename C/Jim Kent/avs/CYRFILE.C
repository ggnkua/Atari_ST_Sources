/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */



#include <stdio.h>
#include <ctype.h>
#include "flicker.h"

extern struct tlib * get_tlib();

extern char *qfile();
extern char keep_path;
int line_count;
char line_buf[256];
char word_buf[256];
FILE *in;

mangled(name)
char *name;
{
char *buf[3];

buf[0] = "Sorry, file damaged:";
buf[1] = name;
buf[2] = NULL;
continu_from(buf);
}

file_truncated(name)
char *name;
{
char *buf[3];

buf[0] = "Sorry, file truncated or damaged:";
buf[1] = name;
buf[2] = NULL;
continu_from(buf);
}

couldnt_find(name)
char *name;
{
char *buf[3];

buf[0] = "Sorry, AVS couldn't find";
buf[1] = name;
buf[2] = NULL;
continu_from(buf);
}

couldnt_make(name)
char *name;
{
char *buf[3];

buf[0] = "Sorry, AVS couldn't make";
buf[1] = name;
buf[2] = NULL;
continu_from(buf);
}

char *
get_line()
{
if (fgets(line_buf, sizeof(line_buf), in) == NULL)
	return(NULL);
line_count++;
return(line_buf);
}


/* chop word ... put the next word (separated by white space) in line
   into the buffer word points to, return what's left of the line, or
   NULL if at end of line */
char *
chop_word(line, word)
register char *line, *word;
{
register char c;

while (isspace(*line) )
	line++;
if (*line == 0)
	return(NULL);
for (;;)
	{
	c = *line++;
	if (isspace(c))
		{
		*word = 0;
		return(line);
		}
	if (c == 0)
		{
		*word = 0;
		return(--line);  /*so catch end of string next call...*/
		}
	*word++ = c;
	}
}

char *qltitle;

qlerror(type)
char *type;
{
char *bufs[3];
char buf[80];

sprintf(buf, "%s : line %d", qltitle, line_count);
bufs[0] = buf;
bufs[1] = type;
bufs[2] = NULL;
continu_from(bufs);
}

char *
getend(name)
char *name;
{
char *wend;
char c;

wend = name;
for (;;)
	{
	if ((c = *name++) == 0)
		break;
	if (c == ':')
		wend = name;
	if (c == '\\')
		wend = name;
	}
return(wend);
}

static int ttix;

cyr_name(prompt)
char *prompt;
{
if (qltitle = qfile(prompt, "AVS"))
	{
	if (!suffix_in(qltitle, ".AVS"))
		strcat(qltitle, ".AVS");
	}
return(qltitle != NULL);
}

qload()
{
if (!cyr_name("Load AVS File"))
	{
	goto OUT;
	}
clear_tracks();
qld(tracks);
/* reset where to load tracks */
video_ticks = sound_ticks = time_ticks = ttix;
OUT:
hide_mouse();
redraw_frame();
show_mouse();
}


qld(trk)
struct track **trk;
{
register char *line;
int tix;
int type;
struct track *t;
struct tlib *tl;

ttix = time_ticks; /* for smoother error recovery */

if ((in = fopen(qltitle, "r")) == NULL)
	{
	couldnt_find(qltitle);
	goto OUT;
	}
line_count = 0;
for (;;)
	{
	if ((line = get_line()) == NULL)
		{
		qlerror("No TICKS, sorry");
		fclose(in);
		goto OUT;
		}
	if ((line = chop_word(line, word_buf)) == NULL)
		continue;
	if (strcmp("TICKS", word_buf) != 0)
		continue;
	if ((line = chop_word(line, word_buf)) == NULL)
		continue;
	ttix = atoi(word_buf);
	break;
	}
for (tix = 0; tix<TRACKS; tix++)
	{
	if ((line = get_line()) == NULL)
		break;
	if ((line = chop_word(line, word_buf)) == NULL)
		continue;
	if (strcmp(word_buf, "SEQ") == 0)
		{
		type = TR_SEQ;
		}
	else if (strcmp(word_buf, "SPL") == 0)
		{
		type = TR_SPL;
		}
	else
		{
		qlerror("Line without SEQ or SPL");
		continue;
		}
	if ((line = chop_word(line, word_buf)) == NULL)
		continue;
	t = trk[tix];
	if (tl = get_tlib(word_buf, type) )
		{
		attatch_tlib(t, tl, getend(word_buf));
		}
	else
		continue;
	if ((line = chop_word(line, word_buf)) == NULL || !isdigit(word_buf[0]))
		{
		qlerror("No start time.");
		continue;
		}
	t->start = atoi(word_buf);
	if ((line = chop_word(line, word_buf)) == NULL || !isdigit(word_buf[0]))
		{
		qlerror("No speed");
		continue;
		}
	t->speed = atoi(word_buf);
	if ((line = chop_word(line, word_buf)) == NULL || !isdigit(word_buf[0]))
		{
		qlerror("No loops");
		continue;
		}
	t->loops = atoi(word_buf);
	set_duration(t);
	}
fclose(in);
OUT:
return(tix);
}

find_last_track()
{
register int i, last;
register struct track **ts, *t;

last = 0;
ts = tracks;
for (i=1; i<=TRACKS; i++)
	{
	t = *ts++;
	if (t->type != TR_NONE)
		{
		last = i;
		}
	}
return(last);
}

qsave()
{
char *title;
int i;
int last;
FILE *f;
struct track *t;
struct tlib *tl;
char *name;

if (title = qfile("Save AVS File", "AVS"))
	{
	if (!suffix_in(title, ".AVS"))
		strcat(title, ".AVS");
	if ((f = fopen(title, "w")) == NULL)
		{
		couldnt_make(title);
		goto OUT;
		}
	fprintf(f, "TICKS %d\n", time_ticks);
	last = find_last_track();
	for (i=0; i<last; i++)
		{
		t = tracks[i];
		name = t->name;
		if (tl = t->lib)
			if (keep_path)
				name = tl->name;
		switch (t->type)
			{
			case TR_SEQ:
				fprintf(f, "SEQ %s %d %d %d\n",
					name, t->start, t->speed, t->loops);
				break;
			case TR_SPL:
				fprintf(f, "SPL %s %d %d %d\n",
					name, t->start, t->speed, t->loops);
				break;
			default:
				fprintf(f, "\n");
				break;
			}
		}
	fclose(f);
	}
OUT:
hide_mouse();
redraw_frame();
show_mouse();
}

