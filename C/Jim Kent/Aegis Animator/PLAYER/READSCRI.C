

overlay "reader"


#include <stdio.h>
#include "..\\include\\lists.h" 
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\symbol.h"
#include "..\\include\\raster.h"
#include "..\\include\\format.h"
#include "..\\include\\animath.h"
#include "..\\include\\perspect.h"
#include "..\\include\\menu.h"


extern Script *convert();
extern char *make_file_name();
extern struct poly_list *empty_poly_list();
extern char dot_pic[];
extern char dot_win[];
extern char dot_msk[];
extern WORD cl_replay;

extern struct raster_list *raster_master;

extern struct raster_list *add_new_raster();
extern struct byte_plane *dummy_byte_plane();
extern struct byte_bit_plane *byte_bit_from_byte();

extern WORD *check_act();

static
add_to_usr_list(t, val)
struct token *t;
struct raster_list *val;
{
Symbol *symbol;

if (!in_name_list(t->name, t->usr_list))
	{
	symbol = install(t->name, t->usr_list);
	if (symbol)
		{
		t->usr_list = symbol;
		symbol->token = RASTER_TOKEN;
		symbol->value = (struct symbol *)val;
		}
	}
}

add_raster_to_script(raster, script, name)
struct raster_list *raster;
Script *script;
char *name;
{
Name_list *raster_item;

#ifdef DEBUG
printf("add_raster_to_script(%lx %lx %s)\n", raster, script, name);
#endif DEBUG

if (raster)
	{
	register struct item_list *script_rasters;

	raster_item = in_name_list(name, raster_master);
	if (!in_item_list(raster_item, script->script_rasters) )
		{
		script_rasters = (Item_list *)alloc(sizeof(Item_list) );
		script_rasters->next = script->script_rasters;
		script_rasters->item = (POINTER)raster;
		script->script_rasters = script_rasters;
		raster->links++;
		}
	}
}

static
read_define(f, t, script)
FILE *f;
Token *t;
Script *script;
{
struct raster_list *next_raster;
char *name;
extern struct BitMap *bbm;
WORD x0, y0, x1, y1;

	
#ifdef DEBUG
printf("read_define(%lx %lx)\n", f, script);
#endif DEBUG

next_token(f, t);
if (t->token != TYPE_TOKEN)
	{
	lprintf("define without a type line %d\n", t->lines);
	pushback_token(t);
	return;
	}
switch ((int) t->value)
	{
	case ANI_STRIP:
	next_token(f, t);
	next_raster = (struct raster_list *)in_name_list(t->name,raster_master);
	if (!next_raster)
		{
		Script *s;

		s = ld_scr(t->name);
		if (s == NULL)
		{
		cant_find(t->name);
		t->fatal += 1;
		}
		else
		{
		next_raster = add_new_raster(s, ANI_STRIP, t->name, 0, 0);
		}
		}
	if (next_raster)
		{
		add_raster_to_script(next_raster, script, t->name);
		add_to_usr_list(t, next_raster);
		}
	break;
	case BITPLANE_RASTER:
		next_token(f, t);
		if (t->token == UNDEF_TOKEN)
			{
			if ( !suffix_in( t->name, dot_msk) )
				lprintf("file not a .msk file line %d\n", 
					t->lines);
			else
			{
			next_raster = (struct raster_list *)
				in_name_list(t->name, raster_master);
			if (!next_raster)
				{
				register struct bit_plane *rp; 
				rp = load_msk(t->name, &x0, &y0, &x1, &y1);
				if (!rp)
#ifdef AMIGA
				rp = dummy_bitplane(t->name);
#endif AMIGA
#ifdef ATARI
				{
				cant_find(t->name);
				t->fatal += 1;
				}
#endif ATARI
			if (rp)
				next_raster = 
				add_new_raster(rp, BITPLANE_RASTER,
					 t->name, x0, y0);
			}
			add_raster_to_script(next_raster, script, t->name);
			add_to_usr_list(t, next_raster);
			}
		}
	break;
#ifdef AMIGA
	case AMIGA_BITMAP:
		next_token(f, t);
		if (t->token == UNDEF_TOKEN)
			{
			if ( !suffix_in( t->name, dot_win) )
				lprintf("file not a .cel file line %d\n",
					 t->lines);
			else
				{
				next_raster = (struct raster_list *)
					in_name_list(t->name, raster_master);
				if (!next_raster)
					{
					register struct BitMap *rp; 
					rp = load_window(t->name, &x0, &y0,
					 &x1, &y1);
					if (!rp)
					rp = dummy_BitMap(t->name);
					if (rp)
					next_raster = 
					add_new_raster(rp, 
					AMIGA_BITMAP, t->name, x0, y0);
					}
				add_raster_to_script(next_raster, script,
					 t->name);
				add_to_usr_list(t, next_raster);
				}
			}
		break;
#endif AMIGA
#ifdef ATARI
	case ATARI_CEL:
		next_token(f, t);
		if (t->token == UNDEF_TOKEN)
			{
			if ( !suffix_in( t->name, dot_win) )
				lprintf("file not a %s file line %d\n",
					dot_win, t->lines);
			else
				{
				next_raster = (struct raster_list *)
					in_name_list(t->name, raster_master);
				if (!next_raster)
					{
					register struct atari_cel *rp; 
					rp = load_window(t->name,
					 &x0, &y0, &x1, &y1);
					if (!rp)
					{
						cant_find(t->name);
					t->fatal += 1;
					}
					if (rp)
					next_raster = 
						add_new_raster(rp, ATARI_CEL,
						t->name, x0, y0);
					}
				add_raster_to_script(next_raster, script, 
					t->name);
				add_to_usr_list(t, next_raster);
				}
			}
		break;
#endif ATARI
	default:
#ifdef PARANOID
		lprintf("unknown type %d in read_define line %d\n", 
			t->value, t->lines);
#endif PARANOID
		break;
	}
}

static
read_numbers(f, t, pt, count)
FILE *f;
Token *t;
WORD *pt;
WORD count;
{
while (--count >= 0)
	{
	next_token(f, t);
	if (t->token == NUMBER_TOKEN)
	*pt++ = (int)t->value;
	else
	{
	pushback_token(t);
	return(0);
	}
	}
return(1);
}

static
WORD *
read_tube(f, t)
FILE *f;
Token *t;
{
WORD *tube;
register WORD *word_list;
register int word_count = 0;
int word_alloc = 0;

#ifdef DEBUG
printf("read_tube(%lx)\n", f);
#endif DEBUG

for(;;)
	{
	if (word_count >= word_alloc)
		{
		register WORD *scratch;
		scratch = (WORD *)
			alloc( ((word_alloc<<1) + 50) * sizeof(WORD) );
		copy_structure( word_list, scratch,
			word_count * sizeof(WORD) );
		mfree(word_list, word_alloc * sizeof(WORD) );
		word_list = scratch;
		word_alloc <<= 1;
		word_alloc += 50;
		}
	next_token(f, t);
	if ( t->token == NUMBER_TOKEN)
		{
		word_list[word_count] = (int)t->value;
		word_count++;
		}
	else
		{
		pushback_token(t);
		break;
		}
	}
tube = (WORD *)alloc( (word_count + 1) * sizeof(WORD) );
if (tube)
	{
	tube[0] = word_count + 1;
	copy_structure( word_list, tube+1, word_count * sizeof(WORD));
	mfree(word_list, word_alloc * sizeof(WORD) );
	}
return(tube);
}

static
WORD *
read_act(f, t, script)
FILE *f;
Token *t;
Script *script;
{
WORD *tube;
register WORD *word_list;
register int word_count = 0;
int word_alloc = 0;
WORD type;
extern WORD *clone_tube();
char **name;

#ifdef DEBUG
lprintf("read_act(%lx)\n",f);
#endif DEBUG

next_token(f, t);
if (t->token != OP_TOKEN) /*unrecognized op, ignore it if it's not INSERT_ */
	{
	lprintf("act - %s ??? line %d\n",t->name, t->lines);
	t->name[7] = 0;
	if (jstrcmp("INSERT_", t->name) == 0) /*inserting unknown type - fatal*/
	{
	t->fatal++;
	}
	return(NULL);
	}
type = (int)t->value;
switch (type)
	{
	case INSERT_RASTER:
		{
		tube = (WORD *)clone_zero( lof_type(type) * sizeof(WORD) );
		tube[0] = lof_type(type);
		tube[1] = type;
		tube[2] = 0;
		next_token(f, t);
		if ( t->token != NUMBER_TOKEN)
			{
			lprintf("insert raster where? line %d\n", t->lines);
			pushback_token(t);
			}
		else
			tube[2] = (int)t->value;
		next_token(f, t);
		if (t->token == RASTER_TOKEN)
			{
			struct raster_list *rl = (struct raster_list *)t->value;

			copy_structure(&t->value, tube+3, 
				sizeof(struct raster_list *) );
			}
		else
			{
			lprintf("INSERT_RASTER - not a raster line %d\n",t->lines);
			t->fatal++;
			pushback_token(t);
			free_tube(tube);
			return(NULL);
			}
		read_numbers(f, t, tube+5, 3);
		return(tube);
		}
	case INSERT_STENCIL:
		{
		tube = (WORD *)clone_zero( lof_type(type) * sizeof(WORD) );
		tube[0] = lof_type(type);
		tube[1] = type;
		tube[2] = 0;
		next_token(f, t);
		if ( t->token != NUMBER_TOKEN)
			{
			lprintf("insert stencil where? line %d\n", t->lines);
			pushback_token(t);
			}
		else
			tube[2] = (int)t->value;
		next_token(f, t);
		if (t->token == RASTER_TOKEN)
			{
			struct raster_list *rl = (struct raster_list *)t->value;

			copy_structure(&t->value,
				tube+3, sizeof(struct raster_list *) );
			read_numbers(f, t, tube+5, 4);
			return(tube);
			}
		else
			{
			lprintf("INSERT_STENCIL - not a raster line %d\n",t->lines);
			t->fatal++;
			pushback_token(t);
			free_tube(tube);
			return(NULL);
			}
		}
	case LOAD_BACKGROUND:
		{
		WORD tube_length;
		char *name;

		next_token(f, t);
		if (t->token == NUMBER_TOKEN)
			next_token(f, t);  /*skip over -2  "poly" number*/
		if (t->token != UNDEF_TOKEN)
			{
			lprintf("LOAD_BACKGROUND - no file name\n");
			return(NULL);
			}
		tube_length = 3 + (strlen(t->name)+2)/2;
		tube = (WORD *)clone_zero( tube_length * sizeof(WORD) );
		if (tube)
			{
			tube[0] = tube_length;
			tube[1] = LOAD_BACKGROUND;
			tube[2] = -2;
			strcpy(tube+3, t->name);
			}
		return(tube);
		}
	case INSERT_STRIP:
		{
		Script **sc;
		Script *child;
		WORD scount;

#ifdef DEBUG
		puts("INSERT_STRIP");
		lsleep(1);
#endif DEBUG
		tube = (WORD *)clone_zero( lof_type(type) * sizeof(WORD) );
		tube[0] = lof_type(type);
		tube[1] = type;
		tube[2] = 0;
		next_token(f, t);
		if ( t->token != NUMBER_TOKEN)
			{
			lprintf("insert strip where? line %d\n", t->lines);
			pushback_token(t);
			}
		else
			tube[2] = (int)t->value;
		next_token(f, t);
		if (t->token == RASTER_TOKEN)
			{
			struct raster_list *rl = (struct raster_list *)t->value;

			read_numbers(f, t, tube+4, 10);
			scount = script->child_count;
			sc = (Script **)
			alloc((scount+1) * sizeof(Script *));
			copy_structure(script->child_scripts, sc,
			scount * sizeof(Script *));
			sc[scount] = child = Clone_a(rl->raster, Script);
			child->next_poly_list = empty_poly_list();
			clone_kids(child, 1, 0);
			tube[3] = scount;
			mfree(script->child_scripts, scount *
			sizeof(Script *) );
			script->child_scripts = sc;
			script->child_count++;
			return(tube);
			}
		else
			{
			lprintf("INSERT_STRIP - %s not declared line %d\n",
			t->name, t->lines);
			pushback_token(t);
			t->fatal += 1;
			free_tube(tube);
			return(NULL);
			}
		}
	default:
		/*make type first number for tube to read*/
		t->token = NUMBER_TOKEN; 
		pushback_token(t);
		tube = read_tube(f,t);
		return(tube);
	}
}




static
struct tween *
read_tween(f, t, script)
FILE *f;
Token *t;
Script *script;
{
register Tween *tween;
register WORD **act_list;
register int act_count = 0;
int act_alloc = 0;
register WORD *act;
WORD first_fall = 1;

#ifdef DEBUG
lprintf("read_tween(%lx %lx)\n", f, t);
#endif DEBUG

tween = (Tween *)clone_zero( sizeof(Tween) );

next_token(f, t);
tween->start_time = (int)t->value;
 
next_token(f, t);
tween->tweening = (int)t->value;
next_token(f, t);
tween->stop_time = (int)t->value;
next_token(f, t);
if (t->token != NUMBER_TOKEN)
	pushback_token(t);

act_count = 0;
for(;;)
	{
	for(;;)
		{
		next_token(f, t);
		if (t->token == OP_TOKEN)
			{
			pushback_token(t); 
			break;
			}
		else if (t->token == EOF_TOKEN ||
			(t->token == COMMAND_TOKEN && 
			(int)t->value != ACT_COM) )
			{
			pushback_token(t);
			goto end_tween;
			}
		}
	if (act_count >= act_alloc)
		{
		register WORD **scratch;
		scratch = (WORD **)
			alloc( ((act_alloc<<1) + 5) * sizeof(WORD *) );
		copy_structure( act_list, scratch,
			act_count * sizeof(WORD *) );
		mfree(act_list, act_alloc * sizeof(WORD *) );
		act_list = scratch;
		act_alloc <<= 1;
		act_alloc+=5;
		}
	act = read_act(f, t, script);
	if (act)
		{
		act = check_act(act,t->lines);
		if (function_type[ act[1]] == ROT_OP)
			{
			find_conjugates( act + op_offset(act) );
			}
#ifdef ATARI
		else if (act[1] == INSERT_POLY)
			{
			act[4] &= 15;
			}
#endif ATARI
		}
	if (act)
		{
		act_list[act_count] = act;
		act_count++;
		}
	}

end_tween:
tween->act_list = (WORD **)clone_structure(
		act_list, act_count * sizeof(WORD *) );
tween->act_count = act_count;
mfree(act_list, act_alloc * sizeof(WORD *) );
return(tween);
}

a_number(f, t)
FILE *f;
Token *t;
{
next_token(f, t);
if (t->token == NUMBER_TOKEN)
	return(1);
else
	{
	pushback_token(t);
	return(0);
	}
}

get_word(f, t, word)
FILE *f;
Token *t;
char *word;
{
for(;;)
	{
	next_token(f, t);
	if (t->token == EOF_TOKEN)
	{
	ldprintf("no %s",word);
	lsleep(1);
	return(0);
	}
	if (jstrcmp(word, t->name) == 0)
	return(1);
	}
}

sk_to_ast(f, t)
FILE *f;
Token *t;
{
for(;;)
	{
	next_token(f, t);
	if (t->token == EOF_TOKEN)
	return(0);
	if (t->name[0] == '*')
	return(1);
	}
}

get_header(f, t, s) 
FILE *f;
Token *t;
Script *s;
{
for (;;)
	{
	if (!sk_to_ast(f, t) )
	return(0);
	if (jstrcmp(t->name, "*tween") == 0)
	return(1);
	if (jstrcmp(t->name, "*define") == 0)
	return(1);
	if (jstrcmp(t->name, "*version") == 0)
	{
	if (a_number(f, t) )
		s->type = (WORD)t->value;
	}
	if (jstrcmp(t->name, "*ground_z") == 0)
	{
	if (a_number(f, t) )
		s->level_z = (WORD)t->value;
	}
	if (jstrcmp(t->name, "*speed") == 0)
	{
	if (a_number(f, t) )
		s->speed = (WORD)t->value;
	}
	}
}

struct s_sequence *
ld_scr(title)
char *title;
{
struct s_sequence *script;
FILE *f;
Token push_back;
Token token;
Tween *tween;
Tween **tween_list;
int tween_count = 0;
int tween_alloc = 0;
long maxt =  0;
WORD version = 0;
extern struct n_slider clock_sl;
extern char *str_num();
WORD xdim, ydim;
WORD view_z;
struct s_sequence *make_empty_script();

#ifdef DEBUG
printf("ld_scr(%s)\n", title);
#endif DEBUG

token.fatal = token.lines = token.push_back = 0;
token.look_ahead = &push_back;
token.usr_list = NULL;

title = make_file_name(title);
script = make_empty_script();
f = fopen(title, "r");

if ( f == NULL)
	{
	ldprintf("can't open %s\n",title);
	free_s_sequence(script);
	free_usr_symbols(&token);
	return(NULL);
	}
#ifdef EDITOR
if (!cl_replay)
	ldprintf("loading %s",title);
#endif EDITOR



if (!get_word(f, &token, "*script") )
		{
		fclose(f);
		free_s_sequence(script);
		free_usr_symbols(&token);
		return(NULL);
		}

if (!get_header(f, &token, script) )
		{
		fclose(f);
		free_s_sequence(script);
		free_usr_symbols(&token);
		return(NULL);
		}
pushback_token(&token);

for (;;)
	{
	if (!sk_to_ast(f, &token) )
	{
	ldprintf("no tweens in %s", title);
	lsleep(1);
	fclose(f);
	free_s_sequence(script);
	free_usr_symbols(&token);
	return(NULL);
	}
	if (jstrcmp(token.name, "*tween") == 0)
	break;
	if (jstrcmp(token.name, "*define") == 0)
	{
	read_define(f, &token, script);
	if (token.fatal > 5)
		break;
	}
	}
pushback_token(&token);
if (token.fatal)
	{
	fclose(f);
	free_s_sequence(script);
	free_usr_symbols(&token);
	return(NULL);
	}

for (;;)
	{
	if (!sk_to_ast(f, &token) )
	break;
	if (jstrcmp(token.name, "*tween") == 0)
	{
	if (tween_count >= tween_alloc)
		{
		register Tween **scratch;
		scratch = (Tween **)
			alloc( ((tween_alloc<<1)  + 5) * sizeof(Tween *) );
		copy_structure( tween_list, scratch,
			tween_count * sizeof(Tween *) );
		mfree(tween_list, tween_alloc * sizeof(Tween *) );
		tween_list = scratch;
		tween_alloc <<= 1;
		tween_alloc+=5;
		}
	tween_list[tween_count] = tween = 
	read_tween(f, &token, script);
	tween_count++;
	}
	}

if (token.fatal)
	{
	fclose(f);
	free_s_sequence(script);
	free_usr_symbols(&token);
	return(NULL);
	}


script->next_tween = script->tween_list = (Tween **)clone_structure(tween_list,
		tween_count * sizeof(Tween *) );
script->tween_count = script->tween_alloc = tween_count;
mfree(tween_list, tween_alloc * sizeof(Tween *) );
if (script->tween_count == 0)
	make_first_tween(script);
script->name = clone_string(title);
script = convert(script);
tween_poly_list(script);
loop_around_script(script);

fclose(f);
free_usr_symbols(&token);
return(script);
}

#ifdef EDITOR
Poly *
load_poly(title, sscript)
char *title;
Script *sscript;
{
FILE *f;
Token token, push_back;
WORD *act;
Poly *poly;
extern Poly *poly_from_act();

token.fatal = token.lines = token.push_back = 0;
token.look_ahead = &push_back;
token.usr_list = NULL;


title = make_file_name(title);
f = fopen(title, "r");
if ( f <= 0)
	{
	ldprintf("can't open %s\n",title);
	return(NULL);
	}
if (!cl_replay)
	ldprintf("loading %s",title);

for(;;)
	{
	next_token(f, &token);
	if (token.token == EOF_TOKEN)
		{
		ldprintf("no *act in file %s\n",title);
		fclose(f);
		free_usr_symbols(&token);
		return(NULL);
		}
	if (token.token == BIN_TOKEN)
		{
		ldprintf("%s is not an ascii file\n",title);
		fclose(f);
		free_usr_symbols(&token);
		return(NULL);
		}
	if (token.token == COMMAND_TOKEN && (int)token.value == ACT_COM)
		{
		break;
		}
	}
next_token(f, &token);
if (token.token != NUMBER_TOKEN)
	pushback_token(&token);  /*skip size buziness*/
act = read_act(f, &token, sscript);
if (act)
	{
	act = check_act(act,token.lines);
	poly = poly_from_act(act);
	free_tube(act);
	next_token(f, &token);  /* just to clear EOF for next time*/
	}
else
	poly = NULL;
fclose(f);
free_usr_symbols(&token);
return(poly);
}
#endif EDITOR

