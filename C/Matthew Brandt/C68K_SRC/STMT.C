#include        <stdio.h>
#include        "c.h"
#include        "expr.h"
#include        "gen.h"
#include        "cglbdec.h"

/*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or questions
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

/*
 *      the statement module handles all of the possible c statements
 *      and builds a parse tree of the statements.
 *
 *      each routine returns a pointer to a statement parse node which
 *      reflects the statement just parsed.
 */

struct snode    *statement();   /* forward declaration */

struct snode    *whilestmt()
/*
 *      whilestmt parses the c while statement.
 */
{       struct snode    *snp;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_while;
        getsym();
        if( lastst != openpa )
                error(ERR_EXPREXPECT);
        else    {
                getsym();
                if( expression(&(snp->exp)) == 0 )
                        error(ERR_EXPREXPECT);
                needpunc( closepa );
                snp->s1 = statement();
                }
        return snp;
}

struct snode    *dostmt()
/*
 *      dostmt parses the c do-while construct.
 */
{       struct snode    *snp;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_do;
        getsym();
        snp->s1 = statement();
        if( lastst != kw_while )
                error(ERR_WHILEXPECT);
        else    {
                getsym();
                if( lastst != openpa )
                        error(ERR_EXPREXPECT);
                else    {
                        getsym();
                        if( expression(&(snp->exp)) == 0 )
                                error(ERR_EXPREXPECT);
                        needpunc(closepa);
                        }
                if( lastst != end )
                        needpunc( semicolon );
                }
        return snp;
}

struct snode    *forstmt()
{       struct snode    *snp;
        snp = xalloc(sizeof(struct snode));
        getsym();
        needpunc(openpa);
        if( expression(&(snp->label)) == 0 )
                snp->label = 0;
        needpunc(semicolon);
        snp->stype = st_for;
        if( expression(&(snp->exp)) == 0 )
                snp->exp = 0;
        needpunc(semicolon);
        if( expression(&(snp->s2)) == 0 )
                snp->s2 = 0;
        needpunc(closepa);
        snp->s1 = statement();
        return snp;
}

struct snode    *ifstmt()
/*
 *      ifstmt parses the c if statement and an else clause if
 *      one is present.
 */
{       struct snode    *snp;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_if;
        getsym();
        if( lastst != openpa )
                error(ERR_EXPREXPECT);
        else    {
                getsym();
                if( expression(&(snp->exp)) == 0 )
                        error(ERR_EXPREXPECT);
                needpunc( closepa );
                snp->s1 = statement();
                if( lastst == kw_else ) {
                        getsym();
                        snp->s2 = statement();
                        }
                else
                        snp->s2 = 0;
                }
        return snp;
}

struct snode    *casestmt()
/*
 *      cases are returned as seperate statements. for normal
 *      cases label is the case value and s2 is zero. for the
 *      default case s2 is nonzero.
 */
{       struct snode    *snp;
        struct snode    *head, *tail;
        snp = xalloc(sizeof(struct snode));
        if( lastst == kw_case ) {
                getsym();
                snp->s2 = 0;
                snp->stype = st_case;
                snp->label = intexpr();
                }
        else if( lastst == kw_default) {
                getsym();
                snp->s2 = 1;
                }
        else    {
                error(ERR_NOCASE);
                return 0;
                }
        needpunc(colon);
        head = 0;
        while( lastst != end &&
                lastst != kw_case &&
                lastst != kw_default ) {
                if( head == 0 )
                        head = tail = statement();
                else    {
                        tail->next = statement();
                        if( tail->next != 0 )
                                tail = tail->next;
                        }
                tail->next = 0;
                }
        snp->s1 = head;
        return snp;
}

int     checkcases(head)
/*
 *      checkcases will check to see if any duplicate cases
 *      exist in the case list pointed to by head.
 */
struct snode    *head;
{
	struct snode	*top, *cur;
	cur = top = head;
	while( top != 0 )
	{
		cur = top->next;
		while( cur != 0 )
		{
			if( (!(cur->s1 || cur->s2) && cur->label == top->label)
				|| (cur->s2 && top->s2) )
			{
				printf(" duplicate case label %d\n",cur->label);
				return 1;
			}
			cur = cur->next;
		}
		top = top->next;
	}
	return 0;
}

struct snode    *switchstmt()
{       struct snode    *snp;
        struct snode    *head, *tail;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_switch;
        getsym();
        needpunc(openpa);
        if( expression(&(snp->exp)) == 0 )
                error(ERR_EXPREXPECT);
        needpunc(closepa);
        needpunc(begin);
        head = 0;
        while( lastst != end ) {
                if( head == 0 )
                        head = tail = casestmt();
                else    {
                        tail->next = casestmt();
                        if( tail->next != 0 )
                                tail = tail->next;
                        }
                tail->next = 0;
                }
        snp->s1 = head;
        getsym();
        if( checkcases(head) )
                error(ERR_DUPCASE);
        return snp;
}

struct snode    *retstmt()
{       struct snode    *snp;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_return;
        getsym();
        expression(&(snp->exp));
        if( lastst != end )
                needpunc( semicolon );
        return snp;
}

struct snode    *breakstmt()
{       struct snode    *snp;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_break;
        getsym();
        if( lastst != end )
                needpunc( semicolon );
        return snp;
}

struct snode    *contstmt()
{       struct snode    *snp;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_continue;
        getsym();
        if( lastst != end )
                needpunc( semicolon );
        return snp;
}

struct snode    *exprstmt()
/*
 *      exprstmt is called whenever a statement does not begin
 *      with a keyword. the statement should be an expression.
 */
{       struct snode    *snp;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_expr;
        if( expression(&(snp->exp)) == 0 ) {
                error(ERR_EXPREXPECT);
                getsym();
                }
        if( lastst != end )
                needpunc( semicolon );
        return snp;
}

struct snode    *compound()
/*
 *      compound processes a block of statements and forms a linked
 *      list of the statements within the block.
 *
 *      compound expects the input pointer to already be past the
 *      begin symbol of the block.
 */
{       struct snode    *head, *tail;
        head = 0;
        while( lastst != end ) {
                if( head == 0 )
                        head = tail = statement();
                else    {
                        tail->next = statement();
                        if( tail->next != 0 )
                                tail = tail->next;
                        }
                }
        getsym();
        return head;
}

struct snode    *labelstmt()
/*
 *      labelstmt processes a label that appears before a
 *      statement as a seperate statement.
 */
{       struct snode    *snp;
        SYM             *sp;
        snp = xalloc(sizeof(struct snode));
        snp->stype = st_label;
        if( (sp = search(lastid,lsyms.head)) == 0 ) {
                sp = xalloc(sizeof(SYM));
                sp->name = litlate(lastid);
                sp->storage_class = sc_label;
                sp->tp = 0;
                sp->value.i = nextlabel++;
                insert(sp,&lsyms);
                }
        else    {
                if( sp->storage_class != sc_ulabel )
                        error(ERR_LABEL);
                else
                        sp->storage_class = sc_label;
                }
        getsym();       /* get past id */
        needpunc(colon);
        if( sp->storage_class == sc_label ) {
                snp->label = sp->value.i;
                snp->next = 0;
                return snp;
                }
        return 0;
}

struct snode    *gotostmt()
/*
 *      gotostmt processes the goto statement and puts undefined
 *      labels into the symbol table.
 */
{       struct snode    *snp;
        SYM             *sp;
        getsym();
        if( lastst != id ) {
                error(ERR_IDEXPECT);
                return 0;
                }
        snp = xalloc(sizeof(struct snode));
        if( (sp = search(lastid,lsyms.head)) == 0 ) {
                sp = xalloc(sizeof(SYM));
                sp->name = litlate(lastid);
                sp->value.i = nextlabel++;
                sp->storage_class = sc_ulabel;
                sp->tp = 0;
                insert(sp,&lsyms);
                }
        getsym();       /* get past label name */
        if( lastst != end )
                needpunc( semicolon );
        if( sp->storage_class != sc_label && sp->storage_class != sc_ulabel)
                error( ERR_LABEL );
        else    {
                snp->stype = st_goto;
                snp->label = sp->value.i;
                snp->next = 0;
                return snp;
                }
        return 0;
}

struct snode    *statement()
/*
 *      statement figures out which of the statement processors
 *      should be called and transfers control to the proper
 *      routine.
 */
{       struct snode    *snp;
        switch( lastst ) {
                case semicolon:
                        getsym();
                        snp = 0;
                        break;
                case begin:
                        getsym();
                        snp = compound();
                        return snp;
                case kw_if:
                        snp = ifstmt();
                        break;
                case kw_while:
                        snp = whilestmt();
                        break;
                case kw_for:
                        snp = forstmt();
                        break;
                case kw_return:
                        snp = retstmt();
                        break;
                case kw_break:
                        snp = breakstmt();
                        break;
                case kw_goto:
                        snp = gotostmt();
                        break;
                case kw_continue:
                        snp = contstmt();
                        break;
                case kw_do:
                        snp = dostmt();
                        break;
                case kw_switch:
                        snp = switchstmt();
                        break;
                case id:
                        while( isspace(lastch) )
                                getch();
                        if( lastch == ':' )
                                return labelstmt();
                        /* else fall through to process expression */
                default:
                        snp = exprstmt();
                        break;
                }
        if( snp != 0 )
                snp->next = 0;
        return snp;
}

