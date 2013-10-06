/* bobint.c - bytecode interpreter */
/*
	Copyright (c) 1991, by David Michael Betz
	All rights reserved
*/

#include <setjmp.h>
#include "bob.h"

#define iszero(x)	((x)->v_type == DT_INTEGER && (x)->v.v_integer == 0)
#define istrue(x)	((x)->v_type != DT_NIL && !iszero(x))

/* global variables */
unsigned char *cbase;	/* the base code address */
unsigned char *pc;		/* the program counter */
VECTOR *code;			/* the current code vector */
VALUE *stkbase;			/* the runtime stack */
VALUE *stktop;			/* the top of the stack */
VALUE *sp;				/* the stack pointer */
VALUE *fp;				/* the frame pointer */
int trace=0;			/* variable to control tracing */

/* external variables */
extern VALUE symbols;
extern jmp_buf error_trap;

/* forward declarations */
char *typename();

/* execute - execute a bytecode function */
int execute(name)
char *name;
{
    DICT_ENTRY *sym;
    
    if (setjmp(error_trap) != 0) /* setup an error trap handler */
		return (FALSE);

    if ((sym = findentry(&symbols,name)) == NULL) /* lookup the symbol */
		return (FALSE);

    switch (sym->de_value.v_type)  /* dispatch on its data type */
    {
    case DT_CODE:
		(*sym->de_value.v.v_code)(0);
		return (TRUE);
    case DT_BYTECODE:
		interpret(sym->de_value.v.v_vector);
		return (TRUE);
    }
    return (FALSE);
}

/* interpret - interpret bytecode instructions */
int interpret(fcn)
VECTOR *fcn;
{
    register int pcoff,n;
    register OBJECT *obj;
    VALUE *topframe,val;
    STRING *s1,*s2,*sn;
    
    sp = fp = stktop;			 /* initialize */
    cbase = pc = fcn->vec_data[0].v.v_string->str_data;
    code = fcn;

    check(4);					 /* make a dummy call frame */
    push_bytecode(code);
    push_integer(0);
    push_integer(0);
    push_integer(0);
    fp = topframe = sp;
    
    for (;;) 				 /* execute each instruction */
    {
		if (trace) 
		{
			check(1);
			push_bytecode(code);
			decode_instruction(sp,pc-strgetdata(vecgetelement(sp,0)));
			++sp;
		}
		switch (*pc++) 
		{
		case OP_CALL:
			n = *pc++;
			switch (sp[n].v_type) 
			{
			case DT_CODE:
				(*sp[n].v.v_code)(n);
				break;
			case DT_BYTECODE:
				check(3);
				code = sp[n].v.v_vector;
				push_integer(n);
				push_integer(stktop - fp);
				push_integer(pc - cbase);
				cbase = pc = code->vec_data[0].v.v_string->str_data;
				fp = sp;
				break;
			default:
				error("Call to non-procedure, Type %s",
				typename(sp[n].v_type));
				return;
			}
			break;
		case OP_RETURN:
			if (fp == topframe) 
				return;
			val = *sp;
			sp = fp;
			pcoff = fp[0].v.v_integer;
			n = fp[2].v.v_integer;
			fp = stktop - fp[1].v.v_integer;
			code = fp[fp[2].v.v_integer+3].v.v_vector;
			cbase = code->vec_data[0].v.v_string->str_data;
			pc = cbase + pcoff;
			sp += n + 3;
			*sp = val;
			break;
		case OP_REF:
			*sp = code->vec_data[*pc++].v.v_var->de_value;
			break;
		case OP_SET:
			code->vec_data[*pc++].v.v_var->de_value = *sp;
			break;
		case OP_VREF:
			chktype(0,DT_INTEGER);
			switch (sp[1].v_type) 
			{
			case DT_VECTOR: 
				vectorref(); 
				break;
			case DT_STRING: 
				stringref(); 
				break;
			default:	
				badtype(1,DT_VECTOR); 
				break;
			}
			break;
		case OP_VSET:
			chktype(1,DT_INTEGER);
			switch (sp[2].v_type) 
			{
			case DT_VECTOR: 
				vectorset(); 
				break;
			case DT_STRING: 
				stringset(); 
				break;
			default:	
				badtype(1,DT_VECTOR); 
				break;
			}
			break;
		case OP_MREF:
			obj = fp[fp[2].v.v_integer+2].v.v_object;
			*sp = obj->obj_members[*pc++];
			break;
		case OP_MSET:
			obj = fp[fp[2].v.v_integer+2].v.v_object;
			obj->obj_members[*pc++] = *sp;
			break;
		case OP_AREF:
			n = *pc++;
			if (n >= fp[2].v.v_integer)
				error("Too few arguments");
			*sp = fp[n+3];
			break;
		case OP_ASET:
			n = *pc++;
			if (n >= fp[2].v.v_integer)
				error("Too few arguments");
			fp[n+3] = *sp;
			break;
		case OP_TREF:
			n = *pc++;
			*sp = fp[-n-1];
			break;
		case OP_TSET:
			n = *pc++;
			fp[-n-1] = *sp;
			break;
		case OP_TSPACE:
			n = *pc++;
			check(n);
			while (--n >= 0) 
			{
				--sp;
				set_nil(sp);
			}
			break;
		case OP_BRT:
			if (istrue(sp))
				pc = cbase + getwoperand();
			else
				pc += 2;
			break;
		case OP_BRF:
			if (istrue(sp))
				pc += 2;
			else
				pc = cbase + getwoperand();
			break;
		case OP_BR:
			pc = cbase + getwoperand();
			break;
		case OP_NIL:
			set_nil(sp);
			break;
		case OP_PUSH:
			check(1);
			push_integer(FALSE);
			break;
		case OP_NOT:
			if (istrue(sp))
				set_integer(sp,FALSE);
			else
				set_integer(sp,TRUE);
			break;
		case OP_NEG:
			chktype(0,DT_INTEGER);
			sp->v.v_integer = -sp->v.v_integer;
			break;
		case OP_ADD:
			switch (sp[1].v_type) 
			{
			case DT_INTEGER:
				switch (sp[0].v_type) 
				{
				case DT_INTEGER:
					sp[1].v.v_integer += sp->v.v_integer;
					break;
				case DT_STRING:
					sn = newstring(1 + sp[0].v.v_string->str_size);
					s2 = sp[0].v.v_string;
					sn->str_data[0] = sp[1].v.v_integer;
					memcpy(&sn->str_data[1],
					s2->str_data,
					s2->str_size);
					set_string(&sp[1],sn);
					break;
				default:
					break;
				}
				break;
			case DT_STRING:
				switch (sp[0].v_type) 
				{
				case DT_INTEGER:
					sn = newstring(sp[1].v.v_string->str_size + 1);
					s1 = sp[1].v.v_string;
					memcpy(sn->str_data,
					s1->str_data,
					s1->str_size);
					sn->str_data[s1->str_size] = sp[0].v.v_integer;
					set_string(&sp[1],sn);
					break;
				case DT_STRING:
					sn = newstring(sp[1].v.v_string->str_size
							+ sp[0].v.v_string->str_size);
					s1 = sp[1].v.v_string;
					s2 = sp[0].v.v_string;
					memcpy(sn->str_data,
					s1->str_data,s1->str_size);
					memcpy(&sn->str_data[s1->str_size],
					s2->str_data,s2->str_size);
					set_string(&sp[1],sn);
					break;
				default:
					break;
				}
				break;
			default:
				badtype(1,DT_VECTOR);
				break;
			}
			++sp;
			break;
		case OP_SUB:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			sp[1].v.v_integer -= sp->v.v_integer;
			++sp;
			break;
		case OP_MUL:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			sp[1].v.v_integer *= sp->v.v_integer;
			++sp;
			break;
		case OP_DIV:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			if (sp->v.v_integer != 0) 
			{
				int x=sp->v.v_integer;
				sp[1].v.v_integer /= x;
			}
			else
				sp[1].v.v_integer = 0;
			++sp;
			break;
		case OP_REM:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			if (sp->v.v_integer != 0) 
			{
				int x=sp->v.v_integer;
				sp[1].v.v_integer %= x;
			}
			else
				sp[1].v.v_integer = 0;
			++sp;
			break;
		case OP_INC:
			chktype(0,DT_INTEGER);
			++sp->v.v_integer;
				break;
		case OP_DEC:
			chktype(0,DT_INTEGER);
			--sp->v.v_integer;
			break;
		case OP_BAND:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			sp[1].v.v_integer &= sp->v.v_integer;
			++sp;
			break;
		case OP_BOR:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			sp[1].v.v_integer |= sp->v.v_integer;
			++sp;
			break;
		case OP_XOR:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			sp[1].v.v_integer ^= sp->v.v_integer;
			++sp;
			break;
		case OP_BNOT:
			chktype(0,DT_INTEGER);
			sp->v.v_integer = ~sp->v.v_integer;
			break;
		case OP_SHL:
			switch (sp[1].v_type) 
			{
			case DT_INTEGER:
				chktype(0,DT_INTEGER);
				sp[1].v.v_integer <<= sp->v.v_integer;
				break;
			case DT_FILE:
				print1(sp[1].v.v_fp,FALSE,&sp[0]);
				break;
			default:
				break;
			}
			++sp;
			break;
		case OP_SHR:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			sp[1].v.v_integer >>= sp->v.v_integer;
			++sp;
			break;
		case OP_LT:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			n = sp[1].v.v_integer < sp->v.v_integer;
			++sp;
			set_integer(sp,n ? TRUE : FALSE);
			break;
		case OP_LE:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			n = sp[1].v.v_integer <= sp->v.v_integer;
			++sp;
			set_integer(sp,n ? TRUE : FALSE);
			break;
		case OP_EQ:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			n = sp[1].v.v_integer == sp->v.v_integer;
			++sp;
			set_integer(sp,n ? TRUE : FALSE);
			break;
		case OP_NE:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			n = sp[1].v.v_integer != sp->v.v_integer;
			++sp;
			set_integer(sp,n ? TRUE : FALSE);
			break;
		case OP_GE:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			n = sp[1].v.v_integer >= sp->v.v_integer;
			++sp;
			set_integer(sp,n ? TRUE : FALSE);
			break;
		case OP_GT:
			chktype(0,DT_INTEGER);
			chktype(1,DT_INTEGER);
			n = sp[1].v.v_integer > sp->v.v_integer;
			++sp;
			set_integer(sp,n ? TRUE : FALSE);
			break;
		case OP_LIT:
			*sp = code->vec_data[*pc++];
			break;
		case OP_SEND:
			n = *pc++;
			chktype(n,DT_OBJECT);
			chktype(n-1,DT_STRING);
			send(n);
			break;
		case OP_DUP2:
			check(2);
			sp -= 2;
			*sp = sp[2];
			sp[1] = sp[3];
			break;
		case OP_NEW:
			chktype(0,DT_CLASS);
			set_object(sp,newobject(sp));
			break;
		default:
			error("Bad opcode %02x",pc[-1]);
			break;
		}
    }
}

/* send - send a message to an object */
static send(n)
int n;
{
	char selector[TKNSIZE+1];
	DICT_ENTRY *de;
	VALUE *class;
	
	class = objgetclass(&sp[n]);
	getcstring(selector,sizeof(selector),&sp[n-1]);
	sp[n-1] = sp[n];
	do 
	{
		if ((de = findentry(clgetfunctions(class),selector)) != NULL) 
		{
			switch (de->de_value.v_type) 
			{
			case DT_CODE:
				(*de->de_value.v.v_code)(n);
				return;
			case DT_BYTECODE:
				check(3);
				code = de->de_value.v.v_vector;
				set_bytecode(&sp[n],code);
				push_integer(n);
				push_integer(stktop - fp);
				push_integer(pc - cbase);
				cbase = pc = code->vec_data[0].v.v_string->str_data;
				fp = sp;
				return;
			default:
				error("Bad method, Selector '%s', Type %d",
				  selector, de->de_value.v_type);
			}
		}
		class = clgetbase(class);
	} while (!isnil(class));
    nomethod(selector);
}

/* vectorref - load a vector element */
static vectorref()
{
	VECTOR *vect;
	int i;

	vect = sp[1].v.v_vector;
	i = sp[0].v.v_integer;
	if (i < 0 || i >= vect->vec_size)
		error("subscript out of bounds: %d",i);
	sp[1] = vect->vec_data[i];
	++sp;
}

/* vectorset - set a vector element */
static vectorset()
{
	VECTOR *vect;
	int i;
	
	vect = sp[2].v.v_vector;
	i = sp[1].v.v_integer;
	if (i < 0 || i >= vect->vec_size)
	error("subscript out of bounds: %d",i);
	vect->vec_data[i] = sp[2] = *sp;
	sp += 2;
}

/* stringref - load a string element */
static stringref()
{
	STRING *str;
	int i;
	
	str = sp[1].v.v_string;
	i = sp[0].v.v_integer;
	if (i < 0 || i >= str->str_size)
		error("subscript out of bounds: %d",i);
	set_integer(&sp[1],str->str_data[i]);
	++sp;
}

/* stringset - set a string element */
static stringset()
{
	STRING *str;
	int i;
	
	chktype(0,DT_INTEGER);
	str = sp[2].v.v_string;
	i = sp[1].v.v_integer;
	if (i < 0 || i >= str->str_size)
		error("subscript out of bounds: %d",i);
	str->str_data[i] = sp[0].v.v_integer;
	set_integer(&sp[2],str->str_data[i]);
	sp += 2;
}

/* getwoperand - get data word */
static int getwoperand()
{
	int b;
	b = *pc++;
	
	return ((*pc++ << 8) | b);
}

/* type names */
static char *tnames[] = 
{
	"NIL","CLASS","OBJECT","VECTOR","INTEGER","STRING","BYTECODE",
	"CODE","DICTIONARY","VAR","FILE"
};

/* typename - get the name of a type */
static char *typename(type)
int type;
{
	static char buf[20];
	
	if (type >= _DTMIN && type <= _DTMAX)
		return (tnames[type]);
	sprintf(buf,"(%d)",type);
	return (buf);
}

/* badtype - report a bad operand type */
badtype(off,type)
int off,type;
{
	char tn1[20];
	strcpy(tn1,typename(sp[off].v_type));
	info("PC: %04x, Offset %d, Type %s, Expected %s",
					pc-cbase,off,tn1,typename(type));
	error("Bad argument type");
}

/* nomethod - report a failure to find a method for a selector */
static nomethod(selector)
char *selector;
{
	error("No method for selector '%s'",selector);
}

/* stackover - report a stack overflow error */
stackover()
{
		error("Stack overflow");
}
