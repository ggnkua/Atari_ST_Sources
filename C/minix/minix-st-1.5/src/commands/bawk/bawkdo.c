/*
 * Bawk C actions interpreter
 */
#include <stdio.h>
#include "bawk.h"

INT dopattern( pat )
char *pat;
{
        Where = PATTERN;
        if ( (Actptr = pat) != (char *)NULL ) {
	        getoken();
        	expression();
	        return popint();
	} else
		return 1;
}

doaction( act )
char *act;
{
        Where = ACTION;
        if ( (Actptr = act) != (char *)NULL ) {
	        getoken();
        	while ( Token!=T_EOF )
                	statement();
        } else
        	printf( "%s\n", Linebuf );
}

expression()
{
        expr1();

        if ( Token==T_ASSIGN )
        {
                getoken();
		expression();
                assignment();
        }
}

expr1()
{
        INT ival;

        expr2();
        for ( ;; )
        {
                if ( Token==T_LIOR )
                {
                        getoken();
                        ival = popint();
                        expr2();
                        pushint( (INT)(popint() || ival) );
                }
                else
                        return;
        }
}

expr2()
{
        INT ival;

        expr3();
        for ( ;; )
        {
                if ( Token==T_LAND )
                {
                        getoken();
                        ival = popint();
                        expr3();
                        pushint( (INT)(popint() && ival) );
                }
                else
                        return;
        }
}

expr3()
{
        INT ival;

        expr4();
        for ( ;; )
        {
                if ( Token==T_IOR )
                {
                        getoken();
                        ival = popint();
                        expr4();
                        pushint( popint() | ival );
                }
                else
                        return;
        }
}


expr4()
{
        INT ival;

        expr5();
        for ( ;; )
        {
                if ( Token==T_AND )
                {
                        getoken();
                        ival = popint();
                        expr5();
                        pushint( popint() & ival );
                }
                else
                        return;
        }
}

expr5()
{
        INT ival;

        expr6();
        for ( ;; )
        {
                if ( Token==T_XOR )
                {
                        getoken();
                        ival = popint();
                        expr6();
                        pushint( popint() ^ ival );
                }
                else
                        return;
        }
}

expr6()
{
        INT ival;

        expr7();
        for ( ;; )
        {
                if ( Token==T_EQ )
                {
                        getoken();
                        ival = popint();
                        expr7();
                        pushint( (INT)(ival == popint()) );
                }
                else if ( Token==T_NE )
                {
                        getoken();
                        ival = popint();
                        expr7();
                        pushint( (INT)(ival != popint()) );
                }
                else
                        return;
        }
}

expr7()
{
        INT ival;

        expr8();
        for ( ;; )
        {
                if ( Token==T_LE )
                {
                        getoken();
                        ival = popint();
                        expr8();
                        pushint( (INT)(ival <= popint()) );
                }
                else if ( Token==T_GE )
                {
                        getoken();
                        ival = popint();
                        expr8();
                        pushint( (INT)(ival >= popint()) );
                }
                else if ( Token==T_LT )
                {
                        getoken();
                        ival = popint();
                        expr8();
                        pushint( (INT)(ival < popint()) );
                }
                else if ( Token==T_GT )
                {
                        getoken();
                        ival = popint();
                        expr8();
                        pushint( (INT)(ival > popint()) );
                }
                else
                        return;
        }
}

expr8()
{
        INT ival;

        expr9();
        for ( ;; )
        {
                if ( Token==T_SHL )
                {
                        getoken();
                        ival = popint();
                        expr9();
                        pushint( ival << popint() );
                }
                else if ( Token==T_SHR )
                {
                        getoken();
                        ival = popint();
                        expr9();
                        pushint( ival >> popint() );
                }
                else
                        return;
        }
}

expr9()
{
        INT ival;

        expr10();
        for ( ;; )
        {
                if ( Token==T_ADD )
                {
                        getoken();
                        ival = popint();
                        expr10();
                        pushint( ival + popint() );
                }
                else if ( Token==T_SUB )
                {
                        getoken();
                        ival = popint();
                        expr10();
                        pushint( ival - popint() );
                }
                else
                        return;
        }
}

expr10()
{
        INT ival;

        primary();
        for ( ;; )
        {
                if ( Token==T_MUL )
                {
                        getoken();
                        ival = popint();
                        primary();
                        pushint( ival * popint() );
                }
                else if ( Token==T_DIV )
                {
                        getoken();
                        ival = popint();
                        primary();
                        pushint( ival / popint() );
                }
                else if ( Token==T_MOD )
                {
                        getoken();
                        ival = popint();
                        primary();
                        pushint( ival % popint() );
                }
                else
                        return;
        }
}

primary()
{
        INT index;
        DATUM data;
        VARIABLE *pvar;

        switch ( Token )
        {
        case T_LPAREN:
                /*
                 * it's a parenthesized expression
                 */
                getoken();
                expression();
                if ( Token!=T_RPAREN )
                        error( "missing ')'", ACT_ERROR );
                getoken();
                break;
        case T_LNOT:
                getoken();
                primary();
                pushint( (INT)(! popint()) );
                break;
        case T_NOT:
                getoken();
                primary();
                pushint( ~ popint() );
                break;
        case T_ADD:
                getoken();
                primary();
                break;
        case T_SUB:
                getoken();
                primary();
                pushint( - popint() );
                break;
        case T_INCR:
        case T_DECR:
                preincdec();
                break;
        case T_MUL:
                getoken();
                primary();
                /*
                 * If item on stack is an LVALUE, do an extra level of
                 * indirection before changing it to an LVALUE.
                 */
                if ( Stackptr->lvalue )
                        Stackptr->value.dptr = *Stackptr->value.ptrptr;
                Stackptr->lvalue = 1;
                --Stackptr->class;
                break;
        case T_AND:
                getoken();
                primary();
                if ( Stackptr->lvalue )
                        Stackptr->lvalue = 0;
                else
                        error( "'&' operator needs an lvalue", ACT_ERROR );
                break;
        case T_CONSTANT:
                pushint( Value.ival );
                getoken();
                break;
        case T_REGEXP:
                /*
                 * It's a regular expression - parse it and compile it.
                 */
                if ( Where == PATTERN )
                {
                        /*
                         * We're processing a pattern right now - perform a
                         * match of the regular expression agains input line.
                         */
                        unparse( Fields, Fieldcount, Linebuf, Fieldsep );
                        pushint( (INT)match( Linebuf, Value.dptr ) );
                }
                else
                        push( 1, ACTUAL, BYTE, &Value );
                getoken();
                break;
        case T_NF:
                pushint( (INT)Fieldcount );
                getoken();
                break;
        case T_NR:
                pushint( (INT)Recordcount );
                getoken();
                break;
        case T_FS:                         /* multiple separators allowed */
                data.dptr = Fieldsep;
                push( 1, ACTUAL, BYTE, &data ); /* string input, not char */
                getoken();
                break;
        case T_RS:
                Recordsep[1] = 0;      /* multiple separators not allowed */
                data.dptr = Recordsep;
                push( 1, ACTUAL, BYTE, &data ); /* string input, not char */
                getoken();
                break;
        case T_FILENAME:
                data.dptr = Filename;
                push( 1, ACTUAL, BYTE, &data );
                getoken();
                break;
        case T_DOLLAR:
                /*
                 * It's a reference to one (or all) of the words in Linebuf.
                 */
                getoken();
                primary();
                if ( index = popint() )
                {
                        if ( index > Fieldcount )
                                index = Fieldcount;
                        else if ( index < 1 )
                                index = 1;
                        data.dptr = Fields[ index-1 ];
                }
                else
                {
                        /*
                         * Reconstitute the line buffer in case any of the
                         * fields have been changed.
                         */
                        unparse( Fields, Fieldcount, Linebuf, Fieldsep );
                        data.dptr = Linebuf;
                }
                /*
                 * $<expr>'s are treated the same as string constants:
                 */
                push( 1, ACTUAL, BYTE, &data );
                break;
        case T_STRING:
                push( 1, ACTUAL, BYTE, &Value );
                getoken();
                break;
        case T_FUNCTION:
                /*
                 * Do a built-in function call
                 */
                index = Value.ival;
                getoken();
                function( (int)index );
                break;
        case T_VARIABLE:
                pvar = (VARIABLE *)Value.dptr;
                getoken();
                /*
                 * it's a plain variable. The way a variable is
                 * represented on the stack depends on its type:
                 *      lvalue class value.dptr
                 * vars:  1      0   address of var
                 * ptrs:  1      1   ptr to address of ptr
                 * array: 0      1   address of var
                 */
                if ( pvar->vclass && !pvar->vlen )
                        /* it's a pointer */
                        data.ptrptr = &pvar->vptr;
                else
                        /* an array or simple variable */
                        data.dptr = pvar->vptr;
                /*
                 * If it's an array it can't be used as an LVALUE.
                 */
                push( pvar->vclass, !pvar->vlen, pvar->vsize, &data );
                break;
        case T_EOF:
                break;
        default:
                syntaxerror();
        }
        /*
         * a "[" means it's an array reference
         */
        if ( Token==T_LBRACKET )
        {
                getoken();
                if ( ! Stackptr->class )
                        error( "'[]' needs an array or pointer", ACT_ERROR );
                /*
                 * compute the subscript
                 */
                expression();
                if ( Token!=T_RBRACKET )
                        error( "missing ']'", ACT_ERROR );
                getoken();
                index = popint();
                /*
                 * compute the offset (subscript times two for int arrays)
                 * and then the effective address.
                 */
                index *= Stackptr->size;
                if ( Stackptr->lvalue )
                        /*
                         * It's a pointer - don't forget that the stack top
                         * item's value is the address of the pointer so we
                         * must do another level of indirection.
                         */
                        Stackptr->value.dptr = *Stackptr->value.ptrptr+index;
                else
                        /*
                         * It's a plain array - the stack top item's value is
                         * the address of the first element in the array.
                         */
                        Stackptr->value.dptr += index;

                /*
                 * The stack top item now becomes an LVALUE, but we've
                 * reduced the indirection level.
                 */
                Stackptr->lvalue = 1;
                --Stackptr->class;
        }

        if ( Token==T_INCR || Token==T_DECR )
                postincdec();
}

preincdec()
{
        /*
         * Pre increment/decrement
         */
        int incr;

        incr = Token==T_INCR ? 1 : -1;
        getoken();
        primary();
        if ( Stackptr->lvalue )
        {
                if ( Stackptr->class )
                        incr *= Stackptr->size;
                *Stackptr->value.ptrptr += incr;
        }
        else
                error( "pre '++' or '--' needs an lvalue", ACT_ERROR );
}

postincdec()
{
        /*
         * Post increment/decrement
         */
        char *p;
        int i, incr;

        incr = Token==T_INCR ? 1 : -1;
        getoken();
        if ( Stackptr->lvalue )
        {
                if ( Stackptr->class )
                {
                        /*
                         * It's a pointer - save its old value then
                         * increment/decrement the pointer.  This makes the
                         * item on top of the stack look like an array, which
                         * means it can no longer be used as an LVALUE. This
                         * doesn't really hurt, since it doesn't make much
                         * sense to say:
                         *   char *cp;
                         *   cp++ = value;
                         */
                        p = *Stackptr->value.ptrptr;
                        *Stackptr->value.ptrptr += incr * Stackptr->size;
                        Stackptr->value.dptr = p;
                }
                else
                {
                        /*
                         * It's a simple variable - save its old value then
                         * increment/decrement the variable.  This makes the
                         * item on top of the stack look like a constant,
                         * which means it can no longer be used as an LVALUE.
                         * Same reasoning as above.
                         */
                        if ( Stackptr->size == BYTE )
                                i = *Stackptr->value.dptr;
                        else
                                i = *(( int * ) Stackptr->value.dptr);
                        *Stackptr->value.ptrptr += incr;
                        Stackptr->value.ival = i;
                }
                Stackptr->lvalue = 0;
        }
        else
                error( "post '++' or '--' needs an lvalue", ACT_ERROR );
}

statement()
{
        /*
         * Evaluate a statement
         */
        char *repeat, *body;

        switch ( Token )
        {
        case T_EOF:
                break;
        case T_CHAR:
        case T_INT:
                declist();
                break;
        case T_LBRACE:
                /*
                 * parse a compound statement
                 */
                getoken();
                while ( !Saw_break && Token!=T_RBRACE )
                        statement();

                if ( Token==T_RBRACE )
                        getoken();
                break;
        case T_IF:
                /*
                 * parse an "if-else" statement
                 */
                if ( getoken() != T_LPAREN )
                        syntaxerror();
                getoken();
                expression();
                if ( Token!=T_RPAREN )
                        syntaxerror();
                getoken();
                if ( popint() )
                {
                        statement();
                        if ( Token==T_ELSE )
                        {
                                getoken();
                                skipstatement();
                        }
                }
                else
                {
                        skipstatement();
                        if ( Token==T_ELSE )
                        {
                                getoken();
                                statement();
                        }
                }
                break;
        case T_WHILE:
                /*
                 * parse a "while" statement
                 */
                repeat = Actptr;
                for ( ;; )
                {
                        if ( getoken() != T_LPAREN )
                                syntaxerror();

                        getoken();
                        expression();
                        if ( Token!=T_RPAREN )
                                syntaxerror();

                        if ( popint() )
                        {
                                body = Actptr;
                                getoken();
                                statement();
                                if ( Saw_break )
                                {
                                        Actptr = body;
                                        Saw_break = 0;
                                        break;
                                }
                                Actptr = repeat;
                        }
                        else
                                break;
                }
                getoken();
                skipstatement();
                break;
        case T_BREAK:
                /*
                 * parse a "break" statement
                 */
                getoken();
                Saw_break = 1;
                break;
        case T_SEMICOLON:
                break;
        default:
                expression();
                popint();
        }

        if ( Token==T_SEMICOLON )
                getoken();
}

skipstatement()
{
        /*
         * Skip a statement
         */

        switch ( Token )
        {
        case T_LBRACE:
                /*
                 * skip a compound statement
                 */
                skip( T_LBRACE, T_RBRACE );
                break;
        case T_IF:
                /*
                 * skip an "if-else" statement
                 */
                getoken();      /* skip 'if' */
                skip( T_LPAREN, T_RPAREN );
                skipstatement();
                if ( Token==T_ELSE )
                {
                        getoken();      /* skip 'else' */
                        skipstatement();
                }
                break;
        case T_WHILE:
                /*
                 * skip a "while" statement
                 */
                getoken();      /* skip 'while' */
                skip( T_LPAREN, T_RPAREN );
                skipstatement();
                break;
        default:
                /*
                 * skip a one-liner
                 */
                while (Token!=T_SEMICOLON && Token!=T_RBRACE && Token!=T_EOF)
                        getoken();
                if ( Token==T_EOF )
                        error( "unexpected end", ACT_ERROR );
                if ( Token==T_SEMICOLON )
                        getoken();
        }
}

skip( left, right )
char left, right;
{
        /*
         * Skip matched left and right delimiters and everything in between
         */
        int parity;
        char *save, errmsg[ 80 ];

        parity = 1;
        save = Actptr;
        while ( getoken() != T_EOF )
        {
                if ( Token == left )
                {
                        save = Actptr;
                        ++parity;
                }
                else if ( Token == right )
                        --parity;
                if ( !parity )
                {
                        getoken();
                        return;
                }
        }
        Actptr = save;

        sprintf( errmsg, "mismatched '%c' and '%c'", left, right );
        error( errmsg, ACT_ERROR );
}

syntaxerror()
{
        error( "syntax error", ACT_ERROR );
}
