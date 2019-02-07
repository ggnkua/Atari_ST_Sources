/*******************************************************************************
*	This file contains general low-level utilities for the G-PROLOG interp-  *
* reter.							               *
* 									       *
* Author: Gene Weiss                                                           *
*	Copyright (c) 1988, by Antic Publishing Inc.        			       *
*	All Rights Reserved                                                    *
*	Permission is granted for private, non-commercial use only	       *
*******************************************************************************/

#include <stdio.h>
#include <ctype.h>


/*******************************************************************************
* #define statements                                                           *
*******************************************************************************/
#define	TRUE	1
#define	FALSE	0
#define	AND	&&
#define	OR	||
#define	NOT	!
#define	BAND	&
#define	BOR	|
#define	BXOR	^
#define	BNOT	~
#define	SHL	<<
#define	SHR	>>
#define	MOD	%
#define NIL	0
#define TAB	9
#define CR	14
#define SP	32
#define RESET	0
#define SET	1
#define CUTEX	2
#define CRT	0

/*******************************************************************************
* File variables
*******************************************************************************/
unsigned int	unify_nums_index = 0;
int		variable_index = 0,
		search_start,
		value_index = 1;

unsigned int	unify_nums[4096];

extern int	line_index,
		trace,
		clause_index,
		clauses[1000],
		biggest_hash,
		cons_cell_index;

extern FILE	*db_file;

static char	*variables[100],
		line[120];

extern char    	value[10000];

extern struct {
	unsigned int	value;
	int	link;
       } cons_cell[5000];

struct {	
	int	v;
	unsigned int	c1;
	unsigned int	c2;
	unsigned int	c3;
	int	t;
	} hash[3200];

/*******************************************************************************
*	function indent									       *
*******************************************************************************/
indent(level)
int level;
{
int i;

printf("\33f");
for (i = 0;i < level;++i)
	printf("  ");
printf("\33e");
}

/*******************************************************************************
*	get_setting function - returns TRUE if the context number entered is 
* set, FALSE otherwise
*******************************************************************************/
get_setting(bit_num)
unsigned int bit_num;
{

return (unify_nums[bit_num / 16] SHR (bit_num MOD 16)) BAND 0x1;

}

/*******************************************************************************
*	get_term function if v,c1 is in the hash table, returns term; returns
* FALSE otherwise
*******************************************************************************/
unsigned int get_term(v,c1)
unsigned int	v;
unsigned int c1;
{
int i;

for (i = (((v BAND 0x7FFF) MOD 30) * 100) + (c1 MOD 100);
				get_setting(hash[i].c2);
				i = (i + 1) MOD 3200)
{
	if ((hash[i].v == v) AND (hash[i].c1 == c1) AND   
			(get_setting(hash[i].c2) == SET))
		return hash[i].t;
}
return FALSE;

}

/*******************************************************************************
*	get_c3 function - if v,c1 is in the hash table, returns c3; returns
* FALSE otherwise
*******************************************************************************/
unsigned int get_c3(v,c1)
unsigned int	v;
unsigned int c1;
{
int i;

for (i = (((v BAND 0x7FFF) MOD 30) * 100) + (c1 MOD 100);
				get_setting(hash[i].c2);
				i = (i + 1) MOD 3200)
	if ((hash[i].v == v) AND (hash[i].c1 == c1) AND
			(get_setting(hash[i].c2) == SET))
		return hash[i].c3;

return FALSE;

}
/*******************************************************************************
*	function print_atom - prints out the valueo of one atom
*******************************************************************************/
print_atom(name)
int name;
{
int i;

i = 0;
name = (name BAND 0x7FFF);
while (value[name + i] != NIL)
{
	if (value[name + i] == '\\') /*this is an escape sequence*/
	{
		++i;
		if (isdigit(value[i + 1])) /*put out a number*/
			putchar(atoi(value[i + 1]));
		else
			switch (value[name + i])
			{
				case 'a':	putchar('\a');
						break;
				case 'b':	putchar('\b');
						break;
				case 't':	putchar('\t');
						break;
				case 'n':	putchar('\n');
						break;
				case 'v':	putchar('\v');
						break;
				case 'f':	putchar('\f');
						break;
				case 'r':	putchar('\r');
						break;
				case 34:	putchar('\"');
						break;
				case 39:	putchar('\'');
						break;
				case 28:	putchar('\\');
							break;
				default:	putchar(NIL);
			}			
	}
	else
		putchar(value[name + i]);

	++i;

}
}


/*******************************************************************************
*	function display - displays one list
*******************************************************************************/
void display(current_node,context)
int	current_node;
unsigned int context;
{
int	temp_term,
	v,not_null,predicate = TRUE;
unsigned int temp_context;

/*we are pointed at the head of a list; display it*/

while (current_node != NIL)
{

	if (atom(cons_cell[current_node].value)) /*display this atom*/
	{
		v = cons_cell[current_node].value;
	
		temp_context = context;

		while ((is_var(v)) AND (NOT unbound(v,temp_context)))
		{
			temp_term = v;
			v = get_term(temp_term,temp_context);
			temp_context = get_c3(temp_term,temp_context);
		}
			

		/*print out the characters*/
		if ((v BAND 0x8000) != 0x8000) /*this var is bound to a list*/
		{
			display(v,context);
		}
		else
		{
			print_atom(v);
			putchar(' ');
		}
		current_node = cons_cell[current_node].link;
	}
	else /*this is a list*/
	{
		not_null = ((cons_cell[current_node].value != NIL) OR
				(cons_cell[current_node].link != NIL));
		if (not_null)
		{
			putchar('(');
			display(cons_cell[current_node].value,context);
			printf(") ");
		}
		current_node = cons_cell[current_node].link;
	}

}
	
}

/*******************************************************************************
*	pause function
*******************************************************************************/
void pause(level)
int level;
{
char ch;

	indent(level);
	printf("CR to continue\n");
	ch = getchar();
}

/*******************************************************************************
*	get_hash function - returns a hash value based on v and c1
*******************************************************************************/
int get_hash(v,c1)
unsigned int v,c1;
{
int initial_hash,
	result;

initial_hash = result = (((v BAND 0x7FFF) MOD 30) * 100) + (c1 MOD 100);

/*now check for collisions*/
while (get_setting(hash[result].c2))
{
	result = (result + 1) MOD 3200;
	if (result == (initial_hash - 1))
	{
		printf("error! hash table overflow\n");
		exit(1);
	}
}

return result;

}

/*******************************************************************************
*	place function places an entry in the hash table based on the hash value
* of v and c1
*******************************************************************************/
void place(v,c1,c2,c3,t)
unsigned int	v,c1,c2,c3,t;
{
int hash_result;

hash_result = get_hash(v,c1);

hash[hash_result].v = v;
hash[hash_result].c1 = c1;
hash[hash_result].c2 = c2;
hash[hash_result].c3 = c3;
hash[hash_result].t = t;

}

/*******************************************************************************
*	get_c2 function if there is an entry in the hash table for v,c1, returns
* c2; returns FALSE otherwise
*******************************************************************************/
static unsigned int get_c2(v,c1)
unsigned int	v;
unsigned int c1;
{
int i;

for (i = (((v BAND 0x7FFF) MOD 30) * 100) + (c1 MOD 100);
				get_setting(hash[i].c2);
				i = (i + 1) MOD 3200)
{
	if ((hash[i].v == v) AND (hash[i].c1 == c1) AND 
				(get_setting(hash[i].c2) == SET))
		return hash[i].c2;
}

return FALSE;

}

/*******************************************************************************
*	reset function resets a context, thus rescinding any bindings made
* by the corresponding unification
*******************************************************************************/
void reset(t)
unsigned int	t;
{

unify_nums[t / 16] = (unify_nums[t / 16]) BAND (BNOT (0x1 SHL (t MOD 16)));

}

/*******************************************************************************
*	new_unify_num function returns the next available unify number (context)
*******************************************************************************/
unsigned int new_unify_num()
{

++unify_nums_index;
if (unify_nums_index >= 65535L)
{
	printf("error! context numbers overflowed!!\n");
	exit(1);
}

/*set the corresponding entry in the bit table*/
unify_nums[unify_nums_index / 16] = (unify_nums[unify_nums_index / 16]) BOR 
					(0x1 SHL (unify_nums_index MOD 16));
return unify_nums_index;
}

/*******************************************************************************
*	atom function returns TRUE if the term entered is an atom
*******************************************************************************/
int atom(term)
unsigned int term;
{
	return ((term BAND 0x8000) == 0x8000);
}


/*******************************************************************************
*	unbound function - returns TRUE if a term is unbound
*******************************************************************************/
int unbound(x,cx)
unsigned int x;
unsigned int    cx;
{
return (get_c2(x,cx) == FALSE) OR (get_setting(get_c2(x,cx)) == RESET);
}

/*******************************************************************************
*	get_value function - returns the value of a cell
*******************************************************************************/
int get_value(term)
unsigned int term;
{

	if ((cons_cell[term].value BAND 0x8000) == 0) /*this is a list link*/
		return NIL;
	else
		return cons_cell[term].value BAND 0x7FFF;
	
}

/*******************************************************************************
*	is_var function - returns true if the term entered is a variable
*******************************************************************************/
int is_var(term)
unsigned int	term;
{
int	i;

if (NOT atom(term))
	return FALSE;

/*atoms beginning with a '_' are always variables*/
if (value[(term BAND 0x7FFF)] == '_')
	return TRUE;

/*check for atoms defined as variables with the "VARIABLES" directive*/
for (i = 1;i <= variable_index;++i)
	if (strcmp(variables[i],
			&value[(term BAND 0x7FFF)]) == 0)
		return TRUE;

return FALSE;
}

	
/*******************************************************************************
*	fatal procedure
*******************************************************************************/
void fatal(s)
char *s;
{
	printf("%s\n",s);
	exit(1);
}

/*******************************************************************************
*	open_db_file procedure
*******************************************************************************/
void open_db_file(file_name)
char *file_name;
{
	if ((db_file = fopen(file_name,"r")) == NULL)
		fatal("Error -- cannot open db file");
	
}

/*******************************************************************************
*	Read_line procedure
*******************************************************************************/
int read_line(source)
int source;
{
char	ch,
	i;

if (source == CRT) /*issue a prompt*/
	printf("\n?");

i = 0;
do
{
	if (source == CRT)
		ch = getchar();
	else
		ch = fgetc(db_file);
	if (ch == EOF)
		return TRUE;
	line[i] = ch;
	++ i;
} while (ch != '\n');

return FALSE;
}

/*******************************************************************************
*	function new_cons_cell - returns the next available cons cell
*******************************************************************************/
int new_cons_cell()
{
	if (cons_cell_index >= (sizeof(cons_cell)/4 - 5))
	{
		printf("error - cons_cell overflow!!\n");
		exit(1);
	}
	return ++cons_cell_index;
}

/*******************************************************************************
*	function string_compare
*******************************************************************************/
string_compare(string1,string2)
char *string1,*string2;
{
int i = 0;

for (i = 0;*(string1 + i) == *(string2 + i);++i);

return ((*(string1 + i) == SP OR 
	 *(string1 + i) == ',' OR 
	 *(string1 + i) == TAB OR 
	 *(string1 + i) == ']' OR 
	 *(string1 + i) == ')') AND (*(string2 + i) == NIL));

}

/*******************************************************************************
*	function already_used_string - returns true if the atom entered has
* already been detected in this clause
*******************************************************************************/
static unsigned int already_used_string(line_index)
int line_index;
{
char	*this_string;
int i;

i = search_start;
while (i < value_index)
{
	this_string = &value[i];
	if (string_compare(&line[line_index],this_string))
	{
		return i;
	}
	i = i + strlen(this_string) + 1;
}
return FALSE;
	
}

/******************************************************************************
*	function skip_to_next_char - skips past delimiters and white space,
* and reads in another line if necessary
******************************************************************************/
static int skip_to_next_char(index,source)
int index,
	source;
{
char comma;
char file_finished;

comma = FALSE;

/*move past TABs, spaces, and commas*/
while ((line[index] == '\t') OR 
	(line[index] == ' ') OR 
	(line[index] == '\n') OR 
	(line[index] == ',') OR
	(line[index] == ':' AND line[index + 1] == '-')) 
{
	if (line[index] == '\n') /*read in a new line*/
	{
		file_finished = read_line(source);
		if (file_finished)
		{
			printf("error - premature end of file in source\n");
			exit(1);
		}
		index = 0;
	}
	else
	{
		if (line[index] == ',')
			comma = TRUE;
		if (line[index] == ':')
			++ index;
		++ index;
	}
}

return index;
}
/*******************************************************************************
*	function is_predicate - returns true if this atom is a predicate
*******************************************************************************/
int is_predicate(line_index)
int line_index;
{
while ((line[line_index] != ')') AND 
	(line[line_index] != SP) AND 
	(line[line_index] != '\t') AND 
	(line[line_index] != CR) AND 
	(line[line_index] != ','))
{
	if (line[line_index] == '(')
	{
		line[line_index] = SP;
		return TRUE;
	}
	else
		++line_index;
}

return FALSE;
}

/*******************************************************************************
*	function parse_quote
*******************************************************************************/
parse_quote(line_index_ptr,current_cons_cell)
int *line_index_ptr,
	current_cons_cell;
{

/*move past the '"'*/
++(*line_index_ptr);

/*set a pointer to the value */
cons_cell[current_cons_cell].value = 
	(value_index BOR 0x8000);

/*set the value*/
while (line[(*line_index_ptr)] != '"')
	value[value_index++] = line[(*line_index_ptr)++];

/*terminate the value string*/
value[value_index++] = NIL;
				
/*move past the '"'*/
++(*line_index_ptr);

}		
/*******************************************************************************
*	parse_list procedure
*******************************************************************************/
int parse_list(current_cons_cell,source)
int current_cons_cell,
	source;
{
int old_cons_cell;
unsigned int result;

if ((line_index == 0) AND (line[line_index] == '\n')) /*this is a null line*/
	return FALSE;

line_index = skip_to_next_char(line_index,source);

if (line[line_index] == '%') /*this is a comment*/
{
	++line_index;
	return FALSE;
}

/*this line may contain a control word:*/
if (strncmp("VARIABLES",&line[line_index],9) == 0)
{
	line_index = line_index + 9;
	line_index = skip_to_next_char(line_index,source);

	/*move past the '('*/
	++line_index;
	line_index = skip_to_next_char(line_index,source);
	while (line[line_index] != ')')
	{
		/*set a pointer to the variable*/
		variables[++variable_index] = &value[value_index];
		
		/*set the value*/
		while ((line[line_index] != ')') AND 
				(line[line_index] != SP) AND 
				(line[line_index] != '\t') AND 
				(line[line_index] != ','))
			value[value_index++] = line[line_index++];
		
		/*terminate the value string*/
		value[value_index++] = NIL;
		
		line_index = skip_to_next_char(line_index,source);

	}
	
	return FALSE;
}
else if (strncmp("TRACE",&line[line_index],5) == 0)
{
	trace = TRUE;
	return FALSE;
}

/*we are pointed at the head of a list; process it*/

else
{
	while ((line[line_index] != ')') AND
		(line[line_index] != '.') AND
		(line[line_index] != ']'))/*process this list*/
	{
		/*move to the next item*/
		line_index = skip_to_next_char(line_index,source);
	
		if (line[line_index] == '"') /*this is a quote*/
			parse_quote(&line_index,current_cons_cell);
	
		else /*this is a clause*/
		{
			if ((NOT is_predicate(line_index)) AND
				(line[line_index] != '[')) /*this is an argument*/
			{
				result = already_used_string(line_index);
				if (result != FALSE)
				{
					/*set a pointer to location used*/
					cons_cell[current_cons_cell].value = 
								(result BOR 0x8000);
		
					/*move past the string*/
					line_index = line_index + strlen(&value[result]);
				}
				else /*this is a new token*/
				{
					/*set a pointer to the value */
					cons_cell[current_cons_cell].value = 
						(value_index BOR 0x8000);
	
					/*set the value*/
					while ((line[line_index] != ')') AND 
							(line[line_index] != SP) AND 
							(line[line_index] != ']') AND 
							(line[line_index] != CR) AND 
							(line[line_index] != ',') AND
							(line[line_index] != '\t') AND
							(line[line_index] != '.'))
						value[value_index++] = line[line_index++];
			
					/*terminate the value string*/
					value[value_index++] = NIL;
				
				}
				/*move to the next item*/
				line_index = skip_to_next_char(line_index,source);
			}
			else /*this list item is another clause*/
			{
			
				if (line[line_index] == '[') /*move past '['*/
					++line_index;
				
				/*get the next cons_cell cell and link to it*/
				cons_cell[current_cons_cell].value = new_cons_cell();
	
				parse_list(cons_cell[current_cons_cell].value);	
			}
	
		}
	
		/*this list item is finished; if the list is not complete,
			create a new cell and link to it*/
		if ((line[line_index] != ')') AND 
			(line[line_index] != '.') AND
			(line[line_index] != ']'))
		{
			/*get a new cons_cell cell and link to it*/
			old_cons_cell = current_cons_cell;
			current_cons_cell = new_cons_cell();
			cons_cell[old_cons_cell].link = current_cons_cell;
		}
	}

	/*the list is finished; terminate list*/
	cons_cell[current_cons_cell].link = NIL;

	/*move past the ')'*/
	++line_index;

}

return TRUE;

}

/*******************************************************************************
*	function car
*******************************************************************************/
int car(list)
int	list;
{
	return cons_cell[list].value;

}

/*******************************************************************************
*	function cdr
*******************************************************************************/
int cdr(list)
int list;
{

	if (atom(list))
		return NIL;
	else
		return cons_cell[list].link;
}


