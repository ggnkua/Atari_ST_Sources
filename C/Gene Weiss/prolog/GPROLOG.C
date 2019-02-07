/*******************************************************************************
* 	This is G-PROLOG, a simplified version of a PROLOG interpreter         *
* written principally for educational purposes.				       *
*	It was inspired by the article "Associative Evaluation of PROLOG 	*
* programs," by K. Nakamura, in *Implementations of PROLOG.*  This method diff-*
* from most in that it maintains variable bindings in a hash table.  Each unif-*
* ication is given a unique number, called a "context," and a binding has the  *
* form 
*	v,c1,c2,c3,t							       *
* where v is a pointer to the variable which is bound, c1 is its context, t is *
* the term it is bound to, and c3 is that term's context.  C2 is the context of *
* the unification that created this binding.					*
*	Clauses are stored as lists, where the CAR of a list is the head, the  *
* CDR is the body, and the CAR of a sublist is the predicate.			*
* 									       *
* Author: Gene Weiss                                                           *
*	Copyright (c) 1988, by Antic Publishing Inc.        			       *
*	All Rights Reserved                                                    *
*	Permission is granted for private, non-commercial use only	       *
*******************************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <ctype.h>
#include <aesbind.h>

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
#define DATA_FILE 1
#define NUM_BUILTINS 20

/*******************************************************************************
* File variables
*******************************************************************************/
char dirpath[80] = "a:\\*.PRO";
static char *string = "[2][CANNOT OPEN FILE][QUIT|TRY AGAIN]";

long 	stack_max = 0,
	_stksize = 10000;
long	stack_top;
int	copy,
	search_start,
	level = 0,
	line_index = 0,
	trace = 0,
	cons_cell_index = 0,
	biggest_hash = 0,
	clause_index = 0,
	current_cons_cell,
	clauses[1000],
	file_finished = FALSE,
	goals_to_prove1,
	built_in_type;

unsigned int	cut_at,
		cx;

FILE	*db_file;

char	succeeded,
	value[10000];

extern struct {	
	int	v;
	unsigned int	c1;
	unsigned int	c2;
	unsigned int	c3;
	int	t;
	} hash[3200];

struct {
	unsigned int	value;
	int	link;
       } cons_cell[5000];

extern int	value_index;
extern unsigned int	unify_nums_index;

extern unsigned int	unify_nums[4096];

extern char *built_ins[NUM_BUILTINS];

/*******************************************************************************
stack function - this simply looks out for stack overflow
*******************************************************************************/
stack()
{
int current_location;

if ((long)&current_location <= _stksize) /*we've got trouble*/
{
	printf("stack overflow!!! - stack location is %D\n",(long)&current_location);
	pause();
	exit(1);
}
if ((_stksize + 10000L) - ((long)&current_location) > stack_max)
	stack_max = (_stksize + 10000L) - ((long)&current_location);
}

/*******************************************************************************
*									       *
*									       *
*	unify function - this is where the real action is -- the unification   *
* algorithm follows closely that outlined in my article			       *
*									       *
*									       *
*******************************************************************************/
static int unify(term1,term2,context1,context2,c)
int term1,term2;
unsigned int context1,context2,c;
{
int temp;

stack();
Label:

/*******************************************************************
first of all, if one or both terms are NIL, unification returns
their equality 
********************************************************************/
if ((term1 == NIL) OR (term2 == NIL))
	return (term1 == term2);

/************************************************************************
at least one of the terms is non-NIL; find out if the first is a variable
************************************************************************/
if (is_var(term1))
{
	/*
	* it's a variable - is it unbound?
	*/
	if (unbound(term1,context1))
	{
		/*
		* At this point, we know that term1 is going to be bound to term2;
		* however, term2 could in turn be bound to another variable (which
		* could be bound to another variable...).  So we'll trace
		* back in the hash table until a ground fact or unbound variable
		* is found.
		*/

		while (is_var(term2) AND (NOT unbound(term2,context2)))
		{
			temp = term2;
			term2 = get_term(temp,context2);
			context2 = get_c3(temp,context2);
		}

		/********************************
		now we can make the binding...
		********************************/
		place(term1,context1,c,context2,term2);
		
		/*****************************************
		..and return true, since the terms unified
		*****************************************/
		return TRUE;
	}
	else /*
	     * term1 is already bound; find out what it's bound to and continue
	     */
	{
		temp = term1;
		term1 = get_term(temp,context1);
		context1 = get_c3(temp,context1);
		goto Label;
	}
}
else /*
     * term1 is not a variable - how about term2?
     */
while (is_var(term2))
{
	if (unbound(term2,context2))
	{
		/*
		* term2 is unbound - bind it to term1
		*/

		place(term2,context2,c,context1,term1);
		return TRUE;
	}
	else /*
	     * term2 is bound - find out what it's bound to and continue
	     */
	{
		temp = term2;
		term2 = get_term(temp,context2);
		context2 = get_c3(temp,context2);
	}
}

/*****************************************************
at this point, we know that neither term is a variable;
we now check to see if they are atoms
*****************************************************/
if ((atom(term1)) OR (atom(term2))) 
{

	/*********************************************************
	at least one of the terms is an atom, so compare the terms
	*********************************************************/
	return (strcmp(&value[term1 BAND 0x7FFF],&value[term2 BAND 0x7FFF]) == 0);
}
else /*try to unify the head...*/
{
	/*...and if that works...*/
	if (unify(car(term1),car(term2),context1,context2,c)) 
	{ 
		/*...try to unify the tail*/
		term1 = cdr(term1);
		term2 = cdr(term2);
		goto Label;
	}
	else /*forget it - the unification failed*/
		return FALSE;
}

}


/*******************************************************************************
*									       *
*									       *
*	prove function - this is the heart of the interpreter
*									       *
*									       *
*									       *
*******************************************************************************/
int prove(goals_to_prove,c)
int	goals_to_prove;
unsigned int c;
{
int	first_goal,
	match_try,
	p;
unsigned int this_unification;

stack();
Start:


/***************************************************
our first task is to find a goal that needs proving:
***************************************************/
while (goals_to_prove == NIL)
{
	/*no goals to prove at this level; step back to the last unification*/

	/*
	* if c != 0, this isn't the top level, so
	*we need to keep looking for goals; otherwise...	
	*/
	if (c != 0)
	{
		--level;
		goals_to_prove = get_term(NIL,c);
		c = get_c3(NIL,c);
	}
	else /*...we're done!!*/
	{
		return TRUE;
	}

}

/*************************************************************
at this point, we've found a goal, so it's time to get to work
*************************************************************/
if (trace)
{
	indent(level);
	printf("goals: ");
	display(goals_to_prove,c);
	putchar('\n');
	pause(level);	
}

/***********************************************************************
get the head of the list of goals to prove
***********************************************************************/
first_goal = car(goals_to_prove);

/***********************************************************************
before doing anything else, make sure this goal isn't a cut
***********************************************************************/
if (strcmp(&value[(first_goal BAND 0x7FFF)],"!") == 0) /*this is a cut*/
{
	if (trace)
	{
		indent(level);
		printf("cut detected\n");
	}
	goals_to_prove1 = cdr(goals_to_prove);
	cut_at = c;
	return CUTEX; /*cuts never fail*/
}

else /*this goal is not a cut; it must be a user-defined goal or a built-in*/
{

	/*********************************************************************
	now we'll find the first clause that unifies with the goal (if there
	is one)
	*********************************************************************/
	match_try = 1;
	while (match_try <= clause_index)
	{
		/*
		*get a label for this unification
		*/
		this_unification = new_unify_num();

		/*
		check for built-ins
		*/
		if (atom(first_goal)) /*this is a predicate with no arguments*/

			built_in_type = is_built_in(first_goal);	
		else
			built_in_type = is_built_in(car(first_goal));	
			
		if (built_in_type != FALSE) /*this is a builtin - process it*/
		{
			succeeded = process_built_in(built_in_type,
						cdr(first_goal),
						c,
						this_unification);
			
			/*don't try any more unifications*/
			match_try = clause_index;
		}
		else /*this goal is user-defined*/
		/*
		*try to unify with the first clause
		*/
		{
			succeeded = unify(car(clauses[match_try]),
				first_goal,
				this_unification,
				c,
				this_unification); /*if we found a match*/
		}

		if (succeeded)
		{
			if (trace)
			{
				indent(level);
				printf("unified w/ ");
				if (built_in_type)
					printf("built-in %s\n",
							built_ins[built_in_type]);
				else
					display(clauses[match_try],this_unification);
				putchar('\n');
			}
	
			/*************************************************
			at this point, a unification succeeded; if the 
			clause it unified with was a fact...
			*************************************************/
			if ((cdr(clauses[match_try]) == NIL) OR 
				(built_in_type != FALSE))
			{
				/*
				*...we go on to prove the next goal...
				*/
				p = prove(cdr(goals_to_prove),c);
			}
			else /*
			      *...otherwise this is a rule,so in the spirit of
			      *depth-first searching, we record the
			      *goals remaining at this level and try to prove
			      *goals generated by the new rule
			      */
			{
				/*record the goals left in the hash table*/
				place(NIL,
					this_unification,
					this_unification,
					c,
					cdr(goals_to_prove));
				
				++level;
				
				/*try to prove the next level of goals*/
				p = prove(cdr(clauses[match_try]),this_unification);	
			}

		

			if (p != CUTEX)
				reset(this_unification);
			
			/*****************************************************
			now we examine the result of the previous proof attempt
			******************************************************/
			switch (p)
			{
				case TRUE:	return TRUE;
					
				case CUTEX:	if (cut_at == this_unification)
						{
							goals_to_prove = goals_to_prove1;
							c = this_unification;
							goto Start;
						}
						else
						{
							return CUTEX;
						}
	
				case FALSE:	;
			}

			/*
			*if we made it this far, the previous proofs failed
			*somewhere, and we need to try the next call
			*/
			++match_try;
		}
		else
		{
			/*
			* this clause refused to unify, so we'll try the next 
			* (if there is one)
			*/
			
			/*
			* but first, reset this_unicication to rescind any 
			* bindings that were made
			*/
			reset(this_unification);
			++match_try;
		}
	} /*end while*/
	/**************************************************************
	no go - none of the clauses unified; we've reached a dead end, so
	it's time to backtrack
	**************************************************************/
	if (trace)
	{
		indent(level);
		printf("backtracking\n");
	}

	return FALSE;
}

}

/*******************************************************************************
*******************************************************************************/
FILE *open_file()
{
	char name[80];
	int button;

	name[0] = '\0';
	if (fsel_input(dirpath,name,&button) == 0)
		alert();
	else
		return(fopen(name,"r"));
}

alert()
{
	int button = 1;

	if (form_alert(button,string) == 2)
		return;
	appl_exit();
	exit(1);
}

/*******************************************************************************
	This is the body of the program
*******************************************************************************/
main(argc,argv)
{
char ch;
int i,result;
int was_clause;

/*clear the screen and home the xcursor*/
printf("\33E");

/*make text wrap around*/
printf("\33v");

/*NIL-fill some arrays*/
for (i = 0;i < sizeof(value);++i)
	value[i] = NIL;
for (i = 0;i < sizeof(unify_nums)/2;++i)
	unify_nums[i] = NIL;
for (i = 0;i < sizeof(hash)/10;++i)
	hash[i].c2 = NIL;

appl_init();

while ((db_file = open_file()) == NULL)
	alert();

while (NOT file_finished)
{
	file_finished = read_line(DATA_FILE);

	if (NOT file_finished)
	{
		current_cons_cell = new_cons_cell();
		clauses[++clause_index] = current_cons_cell;
		line_index = 0;
		search_start = value_index;
		
		was_clause = parse_list(current_cons_cell,DATA_FILE);
		if (NOT was_clause) /*this lne wasn't a clause; ignore it*/
			--clause_index;
	}
}				
	
result = prove(cdr(clauses[1]),0);
if (result)
{
	printf("succeeded\n");
}
else
	printf("failed\n");


printf("Hit <CR> to exit\n");
getchar(i);

exit(0);

}

