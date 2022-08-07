
overlay "reader"


#include <stdio.h>
#include "..\\include\\lists.h"
#include "..\\include\\acts.h"
#include "..\\include\\poly.h"
#include "..\\include\\symbol.h"

char *op_name[] =
	{
	"MOVE_POINT",
	"ROTATE_POINT",
	"INSERT_POINT",
	"KILL_POINT",

	"MOVE_POLY_PTS",
	"ROTATE_SEGMENT",

	"MOVE_POLY",
	"ROTATE_POLY",
	"INSERT_POLY",
	"KILL_POLY",
	"CHANGE_COLOR",

	"MOVE_POLYS",
	"ROTATE_POLYS",
	"SIZE_POLYS",
	"REDO_POLYS",

	"SIZE_POINT",
	"SIZE_SEGMENT",
	"SIZE_POLY",

	"CHANGE_TYPE",
	"MOVE_SEGMENT",

	"PATH_POINT",
	"PATH_POLY",
	"PATH_POLY_PTS",
	"PATH_SEGMENT",
	"PATH_POLYS",

	"INIT_COLORS",
	"INSERT_RASTER",
	"INSERT_STENCIL",

	"LOAD_BACKGROUND",
	"REMOVE_BACKGROUND",
	"TWEEN_COLOR",
	"CYCLE_COLORS",

	"INSERT_CBLOCK",
	"TWEEN_TO_COLORS",
	"INSERT_STRIP",
	"CHANGE_OCOLOR",
	"CHANGE_FCOLOR",
	};

Symbol kw_table[] =
	{
	kw_table+1,		"*act",		COMMAND_TOKEN,	ACT_COM,
	kw_table+2,		"*tween",	COMMAND_TOKEN,	TWEEN_COM,
	kw_table+3,		"*script",	COMMAND_TOKEN,	SCRIPT_COM,

	kw_table+4,		"MOVE_POINT",	OP_TOKEN,	MOVE_POINT,
	kw_table+5,		"ROTATE_POINT",	OP_TOKEN,	ROT_POINT,
	kw_table+6,		"INSERT_POINT",	OP_TOKEN,	INSERT_POINT,
	kw_table+7,		"KILL_POINT",	OP_TOKEN,	KILL_POINT,
	kw_table+8,		"MOVE_POLY_PTS", OP_TOKEN,	MOVE_POLY_PTS,
	kw_table+9,		"ROTATE_SEGMENT", OP_TOKEN,	ROT_SEGMENT,
	kw_table+10,	"MOVE_POLY",	OP_TOKEN,	MOVE_POLY,
	kw_table+11,	"ROTATE_POLY",	OP_TOKEN,	ROT_POLY,
	kw_table+12,	"INSERT_POLY",	OP_TOKEN,	INSERT_POLY,
	kw_table+13,	"KILL_POLY",	OP_TOKEN,	KILL_POLY,
	kw_table+14,	"CHANGE_COLOR",	OP_TOKEN,	CHANGE_COLOR,
	kw_table+15,	"MOVE_POLYS",	OP_TOKEN,	MOVE_POLYS,
	kw_table+16,	"ROTATE_POLYS",	OP_TOKEN,	ROT_POLYS,
	kw_table+17,	"SIZE_POLYS",	OP_TOKEN,	SIZE_POLYS,
	kw_table+18,	"REDO_POLYS",	OP_TOKEN,	REDO_POLYS,
	kw_table+19,	"SIZE_POINT",	OP_TOKEN,	SIZE_POINT,
	kw_table+20,	"SIZE_SEGMENT",	OP_TOKEN,	SIZE_SEGMENT,
	kw_table+21,	"SIZE_POLY",	OP_TOKEN,	SIZE_POLY,
	kw_table+22,	"CHANGE_TYPE",	OP_TOKEN,	CHANGE_TYPE,
	kw_table+23,	"MOVE_SEGMENT",	OP_TOKEN,	MOVE_SEGMENT,
	kw_table+24,	"PATH_POINT",	OP_TOKEN,	PATH_POINT,
	kw_table+25,	"PATH_POLY",	OP_TOKEN,	PATH_POLY,
	kw_table+26,	"PATH_POLY_PTS", OP_TOKEN,	PATH_POLY_PTS,
	kw_table+27,	"PATH_SEGMENT",	OP_TOKEN,	PATH_SEGMENT,
	kw_table+28,	"PATH_POLYS",	OP_TOKEN,	PATH_POLYS,
	kw_table+29,	"INIT_COLORS",	OP_TOKEN,	INIT_COLORS,
	kw_table+30,	"INSERT_RASTER", OP_TOKEN,	INSERT_RASTER,
	kw_table+31,	"INSERT_STENCIL", OP_TOKEN,	INSERT_STENCIL,
	kw_table+32,	"LOAD_BACKGROUND", OP_TOKEN,	LOAD_BACKGROUND,
	kw_table+33,	"REMOVE_BACKGROUND", OP_TOKEN,	REMOVE_BACKGROUND,
	kw_table+34,	"TWEEN_COLOR",	OP_TOKEN,	TWEEN_COLOR,
	kw_table+35,	"CYCLE_COLORS",	OP_TOKEN,	CYCLE_COLORS,
	kw_table+36,	"INSERT_CBLOCK",OP_TOKEN,	INSERT_CBLOCK,
	kw_table+37,	"TWEEN_TO_COLORS",OP_TOKEN,	TWEEN_TO_COLORS,
	kw_table+38,	"INSERT_STRIP",	OP_TOKEN,	INSERT_STRIP,
	kw_table+39,	"CHANGE_OCOLOR", OP_TOKEN,	CHANGE_OCOLOR,
	kw_table+40,	"CHANGE_FCOLOR", OP_TOKEN,	CHANGE_FCOLOR,

	kw_table+41,	"BACKGROUND",	TYPE_TOKEN,	BACKGROUND,
	kw_table+42,	"BYTEPLANE_RASTER",  TYPE_TOKEN, BYPLANE_RASTER,
	kw_table+43,	"BITPLANE_RASTER", TYPE_TOKEN,	BITPLANE_RASTER,
	kw_table+44,	"AMIGA_BITMAP",	TYPE_TOKEN,	AMIGA_BITMAP,
	kw_table+45,	"BYTEPLANE_STENCIL", TYPE_TOKEN, BYPLANE_STENCIL,
	kw_table+46,	"ATARI_CEL", TYPE_TOKEN, ATARI_CEL,
	kw_table+47,	"ANI_STRIP", TYPE_TOKEN, ANI_STRIP,

	kw_table+48,	"*define",	COMMAND_TOKEN,	DEFINE_COM,
	kw_table+49,	"act*",		COMMAND_TOKEN,	ACT_COM,
	kw_table+50,	"tween*",	COMMAND_TOKEN,	TWEEN_COM,
	kw_table+51,	"script*",	COMMAND_TOKEN,	SCRIPT_COM,
	NULL,		"*end",		EOF_TOKEN,	0,
	} ;



free_symbols(list)
register Symbol *list;
{
register Symbol *last;
while (list)
	{
	free_string(list->name);
	last = list;
	list = list->next;
	mfree(last, sizeof(Symbol) );
	}
}

free_usr_symbols(t)
Token *t;
{
free_symbols(t->usr_list);
t->usr_list = NULL;
}


Symbol *
install(name, table)
char *name;
register Symbol *table;
{
register Symbol *symbol;

#ifdef DEBUG
if (!table)
	printf("\ninstalling %s first element of Symbol list",name);
else
	printf("\ninstalling %s ahead of %s",name, table->name);
#endif DEBUG


symbol = (Symbol *)alloc(sizeof(Symbol) );
if (symbol)
	{
	symbol->next = table;
	symbol->name = clone_string(name);
	}
return(symbol);
}


pushback_token(token)
Token *token;
{
#ifdef DEBUG
printf("pushback_token(%lx\n)", token);
#endif DEBUG
#ifdef PARANOID
if (token->push_back)
	ldprintf("\npushback_token without next_token()");
else
#endif PARANOID
	{
	copy_structure( token, token->look_ahead, sizeof(Token) );
	token->push_back = 1;
	}
}


next_token(fp, token)
register FILE *fp;
register Token *token;
{
register char c;
Symbol *pre_def;

#ifdef DEBUG
printf("next_token(%lx %lx)\n", fp, token);
#endif DEBUG

if (token->push_back)
	{
	copy_structure( token->look_ahead, token, sizeof(Token) );
	token->push_back = 0;
	return;
	}
for(;;) /*this little guy loops around until eof or until he gets something he
	recognizes - a number or a symbol thats pre-defined*/
	{ 
	for(;;) /*this is the white space loop.  Parenthesis are considered
		  whitespace*/
		{
		c = getc(fp);
		if (c == ' ' || c== '\t' || c=='(' || c==')'  || c== '\r' )
			continue;   /* WORD white space loop*/
		if (c == '\n')
			{
			token->lines++;
			c = getc(fp);
			if (c == '#') /*skip line if first character is '#' */
			{
			while (c != '\n')
				{
				c = getc(fp);
				if (c == EOF)
					{
					token->token = EOF_TOKEN;
					return;
					}
				}
			}
			ungetc(c, fp);
			continue;
			}
		break;
		}
	if (c < EOF)
		{
		token->token = BIN_TOKEN;
		return;
		}
	if (c == EOF)
		{
		token->token = EOF_TOKEN;
		return;
		}
	token->name = token->buffer;
	if ( c == '-' || ( c >= '0' && c <= '9'))
		{
		register char *pt = token->buffer;
		WORD limit = 80 - 1;

		do
			{
			*pt++ = c;
			c = getc(fp);
			}
		while ( c >= '0' && c <= '9' && --limit>0);
			*pt = 0;
		token->token = NUMBER_TOKEN;
		token->value = (struct symbol *)atoi(token->buffer);
#ifdef DEBUG
		puts(token->buffer);
#endif DEBUG
		return;
		}
	else 
		{
		register char *pt = token->buffer;
		WORD limit = 80 - 1;
		while ( c != ' ' && c != '\t' && c != '\n' && c!= '\r' && c!= EOF
			&& limit>0)
			{
			*(pt++)= c;
			c = getc(fp);
			--limit;
			}
		*pt = 0;
		pt = token->buffer;
#ifdef DEBUG
		puts(pt);
#endif DEBUG

		pre_def = (Symbol *)in_name_list( pt,
			kw_table);
		if (!pre_def)
			pre_def = (Symbol *)in_name_list(pt, 
			token->usr_list);
		if (pre_def)
			{
			copy_structure(pre_def, token, sizeof(Symbol) );
			return;
			}
		else 
			{
			c = pt[0];
			if (( c >= 'a' && c <= 'z')  || (c >= 'A' && c <= 'Z') || c == '*')
				{
				token->token = UNDEF_TOKEN;
				token->name = token->buffer;
				return;
				}
#ifdef PARANOID
			else
				ldprintf("\ngarbage line %d - %s ",
				  token->lines, token->buffer);
#endif PARANOID
			}
		}
	}
}


