/* ---------------- .stack, .push, .pop, .empty ---------------- */

extern SYM *lookup();
extern SYM *newsym();
extern VALUE expr();

#define STACK struct _stack
STACK {
    STACK *stk_next;		/* -> next stack element, or NULL */
    VALUE stk_value;		/* value pushed */
    WORD stk_attr;		/* value's attribute */
};


char need_symbol[] = "missing symbol";

/*
 *  .stack name [, name...]
 */
d_stack()
{
    int stack1();
    symlist(stack1);
}

static stack1(name)
     char *name;
{
    register SYM *sym;

    if ((sym = lookup(name, STKSYM, 0)) == NULL) {
	sym = newsym(name, STKSYM, 0);
	sym->svalue = (VALUE)NULL;
    }
}


/*
 *  .push name, value [, value...]
 */
d_push()
{
    VALUE eval;
    WORD eattr;

    if (expr(exprbuf, &eval, &eattr, NULL) != OK) return;
    if (!(eattr & DEFINED)) return error(undef_error);
}
