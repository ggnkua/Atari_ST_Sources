/*******************************************************************************
*	This module contains the code which detects and executes built-in       *
* predicates in the G-PROLOG interpreter								       *
* 									       *
* Author: Gene Weiss                                                           *
*	Copyright (c) 1988, Antic Publishing Inc.        			       *
*	All Rights Reserved                                                    *
*	Permission is granted for private, non-commercial use only	       *
*******************************************************************************/
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
#define HEAD	1
#define TAIL	2
#define NUM_BUILTINS 20
#define CRT	0

/******************************************************************************
	variables
******************************************************************************/
int	current_cons_cell;

extern int 	search_start,
		line_index,
		unify_nums_index,
		value_index,
		clause_index,
		clauses[500];
extern char    	value[1000];

extern struct {
	unsigned int	value;
	int	link;
       } cons_cell[5000];

char *built_ins[NUM_BUILTINS]= {NIL,
			"head",
			"tail",
			"read",
			"write",
			"true",
			"fail",
			"exit",
			"call",
			"=",
			"<",
			"<>",
			">",
			">=",
			"<=",
			"is",
			"cons",
			"same",
			"different",
			"list"};
	
char digits[12];

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

/*******************************************************************************
*	function is_built_in - returns true if the current goal is a built-in
*******************************************************************************/
int is_built_in(argument)
unsigned int argument;
{
int i;

if ((argument BAND 0x8000) != 0x8000) /*this isn't an atom*/
	return FALSE;

/*check each builtin in turn*/
for (i = 1;i < NUM_BUILTINS;++i)
{
	if (strncmp(built_ins[i],&value[(argument BAND 0x7FFF)],10) == 0)
		return i;
}

/*none of the built-ins matched; return FALSE*/
return FALSE;

}

/*******************************************************************************
*	long_to_ascii - turns a long number into an ASCII string
*******************************************************************************/
char *long_to_ascii(value)
long value;
{
int 	position;
long	divisor;

/*find out if the number is negative*/
if (value < 0L)
{
	digits[0] = '-';
	value = 0L - value;
	position = 1;
}
else
	position = 0;

for (divisor = 1000000000L;value < divisor;divisor = divisor/10L);

while (divisor >= 1)
{
	digits[position] = (value / divisor) BOR 0x30;
	++position;
	value = (value MOD divisor);
	divisor = (divisor/10L);
}
	
if (position == 0) /*the result was 0*/
	digits[position++] = '0';
digits[position] = NIL;

}

/*******************************************************************************
*	a_to_l function - turns an ASCII string into a long
*******************************************************************************/
long a_to_l(char_ptr)
char	*char_ptr;
{
long total = 0,
	divisor = 10;
char negative;

if (*char_ptr == '-') /*this number is negative*/
{
	negative = TRUE;
	++char_ptr;
}
else
	negative = FALSE;

while (isdigit(*(char_ptr)))
{
	total = (total * 10) + (*(char_ptr++) BAND 0x0F);
}

if (negative)
	return (0 - total);
else
	return total;

}

/*******************************************************************************
*	function arithmetic - this funtion handles the "is" buitins, which 
* makes assignments based on arithmetic
*******************************************************************************/
int arithmetic(expression,cv)
unsigned int expression,
	cv;
{
long	value1,value2,result;
int 	save,first_arg,second_arg,temp_term;
unsigned int temp_context;
char	operator;

/*find out if the first value is a bound variable*/
first_arg = car(cdr(expression));

temp_context = cv;
while ((is_var(first_arg)) AND (NOT unbound(first_arg,temp_context)))
{
	temp_term = first_arg;
	first_arg = get_term(temp_term,temp_context);
	temp_context = get_c3(temp_term,temp_context);

}

/*find out if the second value is a bound variable*/
second_arg = car(cdr(cdr(cdr(expression))));

temp_context = cv;
while ((is_var(second_arg)) AND (NOT unbound(second_arg,temp_context)))
{
	temp_term = second_arg;
	second_arg = get_term(temp_term,temp_context);
	temp_context = get_c3(temp_term,temp_context);

}

/*we've now determined the variables' ASCII strings - turn them into numbers*/
value1 = a_to_l(&value[first_arg BAND 0x7FFF]);
value2 = a_to_l(&value[second_arg BAND 0x7FFF]);
operator = value[car(cdr(cdr(expression))) BAND 0x7FFF];

/*now let the computer do the arithmetic, based on the type of operator*/
switch (operator)
{
	case '+':	result = value1 + value2;
			break;
	case '-':	result = value1 - value2;
			break;
	case '*':	result = value1 * value2;
			break;
	case '/':	result = value1 / value2;
			break;
	case '%':	result = value1 % value2;
			break;
	default:	printf("illegal operator in expression\n");
}

/*make the result an ASCII string*/
long_to_ascii(result);

/*make an atom out of the number*/
strncpy(&value[value_index],digits,12);
value[value_index + strlen(digits)] = NIL;
save = value_index;
value_index = value_index + strlen(digits) + 1;

return (save BOR 0x8000);

}

/*******************************************************************************
*	function list - lists all the clauses in the database
*******************************************************************************/
list()
{
int clause_num;

for (clause_num = 1;clause_num <= clause_index;++clause_num)
{
	display(clauses[clause_num],-1);
	putchar('\n');
}
}

/*******************************************************************************
*	function compare_lists - returns TRUE if the two lists are identical
*******************************************************************************/
compare_lists(list1,list2)
int list1,list2;
{

if ((list1 == NIL) OR (list2 == NIL))
	return (list1 == list2);

if (atom(list1) OR atom(list2))
	return (strcmp(&value[list1 BAND 0x7FFF],
			&value[list2 BAND 0x7FFF]) == 0);

return (compare_lists(car(list1),car(list2)) AND 
	compare_lists(cdr(list1),cdr(list2)));
}

/*******************************************************************************
*	function assign_or_compare - handles builtins which make assignments -
* if the first argument is an unbound variable, it is assigned the result of
* the computataion bases on the desired operation; if it is bound, the binding 
* is compared to the result
*******************************************************************************/
int assign_or_compare(body,c,cv,type)
unsigned  body,
	c,cv,type;
{
unsigned int 	variable,variable_context;
int temp_term,result;

/*find out if the variable is a bound variable*/
if (atom(car(body)))
{
	variable = car(body);
	
	if (is_var(variable))
	{
		variable_context = cv;
		while (NOT unbound(variable,variable_context))
		{
			temp_term = variable;
			variable = get_term(temp_term,variable_context);
			variable_context = get_c3(temp_term,variable_context);
		}
		
	}
}
else
	printf("error - tried to bind body to non-atom\n");

/*get the result of the second part of the clause*/
switch (type)
{

	case 1: 	/*head*/
			result = process_list(body,cv,HEAD);
			if (result == NIL)
				return FALSE;
			break;
	
	case 2: 	/*tail*/
			result = process_list(body,cv,TAIL);
			break;
			
	case 3: 	/*read*/
			result = con_read();
			break;
			
	case 16: 	/*is*/
			result = arithmetic(body,cv);
			break;

	case 17:	/*cons*/
			result = cons(body,cv);
			break;

}

if (unbound(variable,variable_context) AND is_var(variable)) /*make the binding*/
{
	/*make the binding*/
	place(variable,variable_context,c,cv,result);
	return TRUE;
}
else /*variable is already bound*/
{

	return compare_lists(variable,result);
}

}

/*******************************************************************************
*	function call - calls a goal to be proved
*******************************************************************************/
call(body,cv)
unsigned int body,cv;
{
unsigned int goal,temp_context,temp_term;

/*find out if the first value is a bound variable*/
goal = car(body);

temp_context = cv;
while ((is_var(goal)) AND (NOT unbound(goal,temp_context)))
{
	temp_term = goal;
	goal = get_term(temp_term,temp_context);
	temp_context = get_c3(temp_term,temp_context);

}

temp_term = prove(goal,0);

return temp_term;

}

/*******************************************************************************
*	function compare - compares two numbers and returns the result of the
* comparison, based on the typ of cmpareison desired (=,>,etc)
*******************************************************************************/
int compare(expression,cv,type)
unsigned int expression,type,
	cv;
{
unsigned int 	second_arg,first_arg,temp_term,temp_context;
long value1,value2;

/*find out if the first value is a bound variable*/
first_arg = car(expression);

temp_context = cv;
while ((is_var(first_arg)) AND (NOT unbound(first_arg,temp_context)))
{
	temp_term = first_arg;
	first_arg = get_term(temp_term,temp_context);
	temp_context = get_c3(temp_term,temp_context);

}

/*now find out if the second value is a bound variable*/
second_arg = car(cdr(expression));

temp_context = cv;
while ((is_var(second_arg)) AND (NOT unbound(second_arg,temp_context)))
{
	temp_term = second_arg;
	second_arg = get_term(temp_term,temp_context);
	temp_context = get_c3(temp_term,temp_context);

}

/*turn the strings into numbers*/
value1 = a_to_l(&value[first_arg BAND 0x7FFF]);
value2 = a_to_l(&value[second_arg BAND 0x7FFF]);

switch(type)
{

	case 10: 	/*equals*/
			return (value1 == value2);
						
	case 11: 	/*less than*/
			return (value1 < value2);
								
	case 12: 	/*not equal*/
			return (value1 != value2);
								
	case 13: 	/*greater than*/
			return (value1 > value2);
								
	case 14: 	/*greater than or equal to*/
			return (value1 >= value2);
					
	case 15: 	/*less than or equal to*/
			return (value1 <= value2);
					
	case 18: 	/*list equality*/
			return compare_lists(first_arg,second_arg);
					
	case 19: 	/*list inequality*/
			return NOT compare_lists(first_arg,second_arg);
					
}

}

/*******************************************************************************
*	function process_list - handles the list built-ins, head and tail
*******************************************************************************/
int process_list(body,cv,operation)
unsigned int body,
	cv,
	operation;
{
int list;

/*find out what the list is bound to*/
list = car(cdr(body));

while ((is_var(list)) AND (NOT unbound(list,cv)))
{
	list = get_term(list,cv);
	cv = get_c3(list,cv);
}

if (operation == HEAD)
{
	if ((list == NIL) OR (atom(list)))
		return NIL;
	else
	 	return car(list);
}
else
{

	if (atom(list))
	{
		return NIL;
	}
	else
		return cdr(list);
}
}

/*******************************************************************************
*	function cons - handles the cons built-in
*******************************************************************************/
int cons(body,cv)
unsigned int body,
	cv;
{
int list1,list2,temp,
	new_cell;

unsigned int temp_term,temp_context;

/*find out what the first list is bound to*/
list1 = car(cdr(body));

while ((is_var(list1)) AND (NOT unbound(list1,cv)))
{
	temp_term = list1;
	temp_context = cv;
	list1 = get_term(temp_term,temp_context);
	temp_context = get_c3(temp_term,temp_context);
}

/*find out what the second list is bound to*/
list2 = car(cdr(cdr(body)));
while ((is_var(list2)) AND (NOT unbound(list2,cv)))
{
	temp_term = list2;
	temp_context = cv;
	list2 = get_term(temp_term,temp_context);
	temp_context = get_c3(temp_term,temp_context);
}

if (atom(list1))
{
	new_cell = new_cons_cell();
	cons_cell[new_cell].link = NIL;
	cons_cell[new_cell].value = list1;
	list1 = new_cell;
}
if (atom(list2))
{
	new_cell = new_cons_cell();
	cons_cell[new_cell].link = NIL;
	cons_cell[new_cell].value = list2;
	list2 = new_cell;
}

new_cell = new_cons_cell();
cons_cell[new_cell].value = cons_cell[list1].value;
cons_cell[new_cell].link = list2;

return new_cell;

}

/*******************************************************************************
*	con_write function - writes a string to the console
*******************************************************************************/
con_write(expression,cv)
unsigned int expression;
{

display(expression,cv);

}

/*******************************************************************************
*	con_read function - reads a string from the console
*******************************************************************************/
con_read()
{
int was_clause;

current_cons_cell = new_cons_cell();
clauses[++clause_index] = current_cons_cell;
line_index = 0;
search_start = value_index;
read_line(CRT);

was_clause = parse_list(current_cons_cell,CRT);
if (NOT was_clause)
	--clause_index;

return cons_cell[current_cons_cell].value;

}
/*******************************************************************************
*	process_builtin - the processing of built-ins starts here
*******************************************************************************/
int process_built_in(type,body,cv,c)
unsigned int type,
	body,
	cv,
	c;
{

switch (type)
{

	case 1: 	/*head*/
			return assign_or_compare(body,c,cv,1);
			
	case 2: 	/*tail*/
			return assign_or_compare(body,c,cv,2);
			
	case 3: 	/*read*/
			return assign_or_compare(body,c,cv,3);
	
	case 4: 	/*write*/
			con_write(body,cv);
			return TRUE;
			
	case 5: 	/*true*/
			return TRUE;
			
	case 6: 	/*fail*/
			return FALSE;
			
	case 7: 	/*exit*/
			exit(1);
			
	case 8: 	/*call*/
			return call(body,cv);
			
	case 9: 	/*equals*/
			return compare(body,cv,10);
			
	case 10: 	/*less than*/
			return compare(body,cv,11);
					
	case 11: 	/*not equal*/
			return compare(body,cv,12);
					
	case 12: 	/*greater than*/
			return compare(body,cv,13);
					
	case 13: 	/*greater than or equal to*/
			return compare(body,cv,14);
		
	case 14: 	/*less than or equal to*/
			return compare(body,cv,15);
		
	case 15: 	/*is*/
			return assign_or_compare(body,c,cv,16);

	case 16: 	/*cons*/
			return assign_or_compare(body,c,cv,17);

	case 17: 	/*same*/
			return compare(body,cv,18);

	case 18: 	/*different*/
			return compare(body,cv,19);

	case 19: 	/*list*/
			list();
			return TRUE;

	default:	printf("error - illegal builtin\n");
}
}
