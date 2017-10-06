
/* predefs.c - Stuff to bind build in C and ASM functions to pogo, and
  some of the smaller functions themselves. */

#include <stdio.h>
#include "pogo.h"

/* file functions */
extern popen(), pclose(), pgetchar();
extern char *pgetword(), *pgetline();
extern pputchar(), pputs(), pputline();

/* screen oriented functions */
extern pscreen(), palloc_screen(), pfree_screen(), pcopy_screen(),
	puse_screen(), pblit(), ptblit(), pload_pic(), psave_pic();

/* fli functions */
extern create_fli(), save_next_fli(), end_fli();

/* input functions */
extern inkey(), rawkey(), waitkey(), mouse_x(), mouse_y(),
	joystick(), use_mouse(), use_joy(),
	mouse_left(), mouse_right(), get_clock();

/* graphics functions */
extern to_text(), to_graphics(), clear_screen(),
	pgtext(), pgnumber(),
	pline(), pputdot(), disk(), circle();

/* "Turtle" functions */
extern right(), left(), penup(), pendown(), pencolor(), forward(),
	closest_type(),	reverse();

/* double-buffering animation functions */
extern swap(), de_swap(), pre_swap(), vsync();

/* Creature finding functions */
extern closest_creature(), named_creature(), exists_creature();

extern kill_all();

/* Creature information function */
extern creature_x(), creature_y(), creature_age(), creature_newborn();
extern char *creature_name();

extern int in_graphics;

int randseed;

parctan(p)
union pt_int *p;
{
return(arctan(p[-2].i, p[-1].i));
}

extern char *add_cr_string();

pstrlen(p)
union pt_int *p;
{
char *s;

s = p[-1].p;
if (s == NULL)
	return(-1);
else
	return(strlen(s));
}

pcharat(p)
union pt_int *p;
{
register char *n;
int count;
char c;

if ((n = p[-2].p) == NULL)
	return(0);
count = p[-1].i;
for (;;)
	{
	if ((c = *n++) == 0)
		break;
	if (--count < 0)
		break;
	}
return(c);
}

pcharto(p)
union pt_int *p;
{
register char *n;
int count;
char data;
char c;

if ((n = p[-3].p) == NULL)
	return(0);
count = p[-2].i;
for (;;)
	{
	if ((c = *n) == 0)
		return(0);
	if (--count < 0)
		{
		*n = p[-1].i;
		break;
		}
	n++;
	}
return(c);
}


char *
pstrnum(p)
union pt_int *p;
{
char buf[10];
char *s;

sprintf(buf, "%d", p[-1].i);
s = clone_string(buf);
add_cr_string(s);
return(s);
}

char *
pstrchar(p)
union pt_int *p;
{
static char buf[2];
char *s;

buf[0] = p[-1].i;
s = clone_string(buf);
add_cr_string(s);
return(s);
}


psquare_root(p)
union pt_int *p;
{
long x;

if ((x = p[-1].i) < 0)
	return(-1);
return(sqr_root( x ));
}

psamename(p)
union pt_int *p;
{
return(jstrcmp(p[-1].p, p[-2].p) == 0);
}

pstrcmp(p)
union pt_int *p;
{
return(jstrcmp(p[-1].p, p[-2].p));
}

parcx(p)
union pt_int *p;
{
return(itmult(icos(sscale_by(p[-2].i, 1024, 360)),p[-1].i));
}

parcy(p)
union pt_int *p;
{
return(itmult(isin(sscale_by(p[-2].i, 1024, 360)),p[-1].i));
}

pdisk(p)
union pt_int *p;
{
if (!in_graphics)
	to_graphics();
p -= 4;		/* move p to first parameter */
disk(p[0].i, p[1].i, p[2].i, p[3].i);
}

pcircle(p)
union pt_int *p;
{
if (!in_graphics)
	to_graphics();
p -= 4;		/* move p to first parameter */
circle(p[0].i, p[1].i, p[2].i, p[3].i);
}

pdistance(p)
union pt_int *p;
{
int dx, dy;

dx = p[-4].i - p[-2].i;
dy = p[-3].i - p[-1].i;
return(sqr_root(mult_to_long(dx,dx) + mult_to_long(dy,dy)));
}

pgetdot(p)
union pt_int *p;
{
if (!in_graphics)
	to_graphics();
p -= 2;		/* move p to first parameter */
return(getdot(p[0].i, p[1].i));
}

pputdot(p)
union pt_int *p;
{
if (!in_graphics)
	to_graphics();
p -= 3;		/* move p to first parameter */
putdot(p[1].i, p[2].i, p[0].i);	/* pogo want's color 1st, putdot last */
}


rectangle(p)
union pt_int *p;
{
if (!in_graphics)
	to_graphics();
p -= 5;
colblock(p[0].i, p[1].i, p[2].i, p[3].i, p[4].i);
}


random(p)
union pt_int *p;
{
p -= 1;		/* move p to first parameter */
randseed = randseed<<1;
if (randseed >= 0)
	randseed = randseed^0x2b41;
return((unsigned)randseed%(unsigned)p->i);
}


struct func_frame *
add_predef(name, code, pcount)
char *name;
function *code;
int pcount;
{
Symbol *ns;
struct func_frame *fuf;

upper_case(name);
if ((fuf = beg_zero(sizeof(*fuf))) == NULL)
	return(0);
fuf->pcount = pcount;
fuf->code = (struct pogo_op *)code;
dupe_bytes(fuf->ptypes, INT, pcount);
if ((ns = new_symbol(name, PREDEF, GLOBAL, rframe)) == NULL)
	{
	freemem(fuf);
	return(NULL);
	}
ns->symval.p = fuf;
return(fuf);
}

struct iconlist
	{
	char *name;
	int value;
	};

static struct iconlist iconsts[] =
{
{"SCREENW", XMAX},
{"SCREENH", YMAX},
{"CHARW", CH_WIDTH},
{"CHARH", CH_HEIGHT},
{"COLORS", COLORS},
};


init_constants()
{
int i;
char *name;
Symbol *ns;

for (i=0; i<Array_els(iconsts); i++)
	{
	name = iconsts[i].name;
	upper_case(name);
	if ((ns = new_symbol(name, CONSTANT, GLOBAL, rframe)) == NULL)
		return(0);
	ns->symval.i = iconsts[i].value;
	}
return(1);
}


struct kwlist
	{
	char *name;
	int token;
	};

struct kwlist kwds[] = 
{
{"NULL", TOK_NULL,},
{"Constant", TOK_CONSTANT,},
{"Cread", TOK_CREAD,},
{"Cwrite", TOK_CWRITE,},
{"not", TOK_LNOT,},
{"and", TOK_LAND,},
{"or", TOK_LOR,},
{"closestt", TOK_CLOSESTT,},
{"Spawn", TOK_SPAWN,},
{"Kill", TOK_KILL,},
{"CID", TOK_CID,},
{"CAGE", TOK_CAGE,},
{"CNEW", TOK_CNEW,},
{"CNAME", TOK_CNAME,},
{"CX", TOK_CX,},
{"CY", TOK_CY,},
{"CDX", TOK_CDX,},
{"CDY", TOK_CDY,},
{"Evolve", TOK_EVOLVE,},
{"else", TOK_ELSE,},
{"function", TOK_FUNCTION,},
{"creature", TOK_CREATURE,},
{"step", TOK_STEP,},
{"goto", TOK_GOTO,},
{"return", TOK_RETURN,},
{"to", TOK_TO,},
{"for", TOK_FOR,},
{"while", TOK_WHILE,},
{"loop", TOK_LOOP,},
{"break", TOK_BREAK,},
{"string", TOK_STRING,},
{"int", TOK_INT,},
{"if", TOK_IF,},
};


add_keyword(name, tok_type)
char *name;
int tok_type;
{
Symbol *ns;

upper_case(name);
if ((ns = new_symbol(name, BAD, 0, rframe)) == NULL)
	return(0);
ns->tok_type = tok_type;
return(1);
}


init_keywords()
{
int i;

for (i=0; i<Array_els(kwds); i++)
	if (!add_keyword(kwds[i].name, kwds[i].token))
		return(0);
return(1);
}

pset_color(p)
union pt_int *p;
{
if (!in_graphics)
	to_graphics();
p -= 4;
set_color(p[0].i, p[1].i, p[2].i, p[3].i);
}


pcreate_fli(p)
union pt_int *p;
{
if (!in_graphics)
	to_graphics();
return(create_fli(p[-2].p, p[-1].i));
}


char *
nullstring(p)
union pt_int *p;
{
char *n;

n = p[-1].p;
if (n == NULL)
	n = "(NULL)";
return(n);
}

ptext(p)
union pt_int *p;
{
printf("%s", nullstring(p));
}

pprint(p)
union pt_int *p;
{
printf("%d\n", p[-1].i);
}

psprint(p)
union pt_int *p;
{
puts(nullstring(p));
}

int grav[2];

pgravityx(p)
union pt_int *p;
{
int dxy[2];

dxy[0] = p[-3].i;
dxy[1] = p[-2].i;
calc_grav(dxy, grav, p[-1].i);
return(grav[0]);
}

pgravityy()
{
return(grav[1]);
}


init_predefs()
{
struct func_frame *fuf;

/* File functions */
if ((fuf = add_predef("fopen", popen, 2)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
fuf->ptypes[1] = STRING;
if (!add_predef("fclose", pclose, 1))
	return(0);
if (!add_predef("GetChar", pgetchar, 1))
	return(0);
if ((fuf = add_predef("GetWord", pgetword, 1)) == NULL)
	return(0);
fuf->ret_type = STRING;
if ((fuf = add_predef("GetLine", pgetline, 1)) == NULL)
	return(0);
fuf->ret_type = STRING;
if (!add_predef("PutChar", pputchar, 2))
	return(0);
if ((fuf = add_predef("PutLine", pputline, 2)) == NULL)
	return(0);
fuf->ptypes[1] = STRING;
if ((fuf = add_predef("PutString", pputs, 2)) == NULL)
	return(0);
fuf->ptypes[1] = STRING;

/* Fli functions */
if ((fuf = add_predef("CreateFli", pcreate_fli, 2)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
if (!add_predef("FliNext", save_next_fli, 0))
	return(0);
if (!add_predef("EndFli", end_fli, 0))
	return(0);
/* pic functions */
if (!add_predef("Pscreen", pscreen, 0))
	return(0);
if (!add_predef("AllocScreen", palloc_screen, 0))
	return(0);
if (!add_predef("UseScreen", puse_screen, 1))
	return(0);
if (!add_predef("FreeScreen", pfree_screen, 1))
	return(0);
if (!add_predef("CopyScreen", pcopy_screen, 2))
	return(0);
if (!add_predef("Blit", pblit, 8))
	return(0);
if (!add_predef("TBlit", ptblit, 8))
	return(0);
if ((fuf = add_predef("LoadPic", pload_pic, 1)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
if ((fuf = add_predef("SavePic", psave_pic, 1)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;

/* Creature finding functions */
if (!add_predef("ClosestCreature", closest_creature, 3))
	return(0);
if ((fuf = add_predef("ClosestType", closest_type, 3)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
if ((fuf = add_predef("NamedCreature", named_creature, 1)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
if (!add_predef("ExistsCreature", exists_creature, 1))
	return(0);
/* Creature information function */
if (!add_predef("CreatureX", creature_x, 1))
	return(0);
if (!add_predef("CreatureY", creature_y, 1))
	return(0);
if (!add_predef("CreatureAge", creature_age, 1))
	return(0);
if (!add_predef("CreatureNewBorn", creature_newborn, 1))
	return(0);
if ((fuf = add_predef("CreatureName", creature_name, 1)) == NULL)
	return(0);
fuf->ret_type = STRING;
if (!add_predef("KillAll", kill_all, 0))
	return(0);

/* input functions */
if (!add_predef("UseMouse", use_mouse, 0))
	return(0);
if (!add_predef("UseJoystick", use_joy, 0))
	return(0);
if (!add_predef("Joystick", joystick, 0))
	return(0);
if (!add_predef("Clock", get_clock, 0))
	return(0);
if (!add_predef("InKey", inkey, 0))
	return(0);
if (!add_predef("Keyboard", rawkey, 0))
	return(0);
if (!add_predef("WaitKey", waitkey, 0))
	return(0);
if (!add_predef("MouseX", mouse_x, 0))
	return(0);
if (!add_predef("MouseY", mouse_y, 0))
	return(0);
if (!add_predef("MouseLeft", mouse_left, 0))
	return(0);
if (!add_predef("MouseRight", mouse_right, 0))
	return(0);
/* Math functions */
if (!add_predef("Random", random, 1))
	return(0);
if (!add_predef("GravityX", pgravityx, 3))
	return(0);
if (!add_predef("GravityY", pgravityy, 0))
	return(0);
if (!add_predef("XYangle", parctan, 2))
	return(0);
if (!add_predef("SquareRoot", psquare_root, 1))
	return(0);
if (!add_predef("Distance", pdistance, 4))
	return(0);
if (!add_predef("ArcX", parcx, 2))
	return(0);
if (!add_predef("ArcY", parcy, 2))
	return(0);
/* Graphics functions */
if (!add_predef("ToText", to_text, 0))
	return(0);
if (!add_predef("ToGraphics", to_graphics, 0))
	return(0);
if (!add_predef("GNumber", pgnumber, 5))
	return(0);
if ((fuf = add_predef("Gtext", pgtext, 4)) == NULL)
	return(0);
fuf->ptypes[3] = STRING;
if (!add_predef("PutDot", pputdot, 3))
	return(0);
if (!add_predef("GetDot", pgetdot, 2))
	return(0);
if (!add_predef("Rectangle", rectangle, 5))
	return(0);
if (!add_predef("Disk", pdisk, 4))
	return(0);
if (!add_predef("Circle", pcircle, 4))
	return(0);
if (!add_predef("SetColor", pset_color, 4))
	return(0);
if (!add_predef("Line", pline, 5))
	return(0);
if (!add_predef("ClearScreen", clear_screen, 0))
	return(0);
/* "Turtle" functions */
if (!add_predef("Right", right, 1))
	return(0);
if (!add_predef("Left", left, 1))
	return(0);
if (!add_predef("PenUp", penup, 0))
	return(0);
if (!add_predef("PenDown", pendown, 0))
	return(0);
if (!add_predef("PenColor", pencolor, 1))
	return(0);
if (!add_predef("Forward", forward, 1))
	return(0);
if (!add_predef("Reverse", reverse, 1))
	return(0);
/* Animation function */
if (!add_predef("PreSwap", pre_swap, 0))
	return(0);
if (!add_predef("DeSwap", de_swap, 0))
	return(0);
if (!add_predef("Swap", swap, 0))
	return(0);
if (!add_predef("Vsync", vsync, 0))
	return(0);
if ((fuf = add_predef("Text", ptext, 1)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
if ((fuf = add_predef("PrintS", psprint, 1)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
if (!add_predef("Print", pprint, 1))
	return(0);
if ((fuf = add_predef("StrChar", pstrchar, 1)) == NULL)
	return(0);
fuf->ret_type = STRING;
if ((fuf = add_predef("StrNum", pstrnum, 1)) == NULL)
	return(0);
fuf->ret_type = STRING;
if ((fuf = add_predef("itoa", pstrnum, 1)) == NULL)
	return(0);
fuf->ret_type = STRING;
if ((fuf = add_predef("StrLen", pstrlen, 1)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
if ((fuf = add_predef("CharAt", pcharat, 2)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
if ((fuf = add_predef("CharTo", pcharto, 3)) == NULL)
	return(0);
fuf->ptypes[0] = STRING;
return(1);
}
