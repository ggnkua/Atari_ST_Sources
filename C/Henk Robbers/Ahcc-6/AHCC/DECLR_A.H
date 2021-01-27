/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* declr_a.h
 */

/* tag name space abolished, tags to the symbol tables as typedefs.
	Makes the following possible (as in C++):
	struct TAG (.....);				definition of struct

	struct TAG (... ref TAG myself; ... );   selfref in struct
	...
	TAG a, b[e], c;			declarations of instances of struct
*/
static
TP decl_su(short isstruct)
{
	TP rv = nil, tagp = nil, kp;
	TP *attab;
	short stok;

	D_(D, "decl_su");

	fadvnode();		/* skip 'struct' or 'union' */

/*	HR: not such a good idee when converting C code to A :-)
		should make it a option.
	Besides, it looks like some code is just wrong. :-(
	if (G.lang eq 'a')
		attab = G.prtab->level ? &G.scope->b_syms : symtab;
	else
*/		attab = G.prtab->level ? &G.scope->b_tags : &G.tagtab;

	if (cur->token eq ID)
		tagp = tpcur(), advnode();	/* hold on to ID node */

	stok = cur->token eq BLOCK ? KCOLB
			: (cur->token eq PAREN ? NERAP : 0 );
	if (stok eq KCOLB or stok eq NERAP)
	{							/* new declaration */
		if (tagp eq nil)
		{
			tagp = make_type(ID,-1,nil,nil);
	/* Using line nr in dummy names is not a good idee,
	 * U can have any number of structs without tagname in 1 line.
	 */		new_name(tagp, "__%d", new_lbl());
		}
		fadvnode();

	/* Because the symtab uses next for chaining,
		we must make a extra node for the symbol table entry.
		 It happens to be of convenience to make this a K_TYPE node.
		  See 'derived_type()', which need not be changed.
	*/
		kp = copyTone(tagp);
		kp->token = ID;
		kp->sc = K_TYPE;
		kp->type = tagp;

		if (attab eq symtab)
		{
			if ((rv = tlook(symtab[hash(kp->name)], kp)) ne nil )
			{
				freeTn(kp);
				rv = rv->type;
				if (rv->list)
				{
					errorn(rv, "redefinition of %s", graphic[rv->token]);
					freeTn(rv->list);
					rv->list = nil;
				}
			othw					/* new defn */
				rv = tagp;
				to_type(rv, isstruct);
				globl_sym(kp,0);
			}
		othw
			if ((rv = tlook(*attab, kp)) ne nil )
			{
				freeTn(kp);
				rv = rv->type;
				if (rv->list)
				{
					errorn(rv, "redefinition of %s", graphic[rv->token]);
					freeTn(rv->list);
					rv->list = nil;
				}
			othw					/* new defn */
				rv = tagp;
				to_type(rv, isstruct);
				putt_lifo(attab, kp);
			}
		}
		su_decls(&rv->list, isstruct, &rv->size, &rv->aln);
		while (rv->size & ALN_A) rv->size++;		/* 01'14 HR v5.1 */
		eat(stok);
	othw						/* reference to allready defined */
		if ( tagp eq nil )
			error("nonsense %s", graphic[isstruct]);
		else
		{
			kp = copyTone(tagp);
			kp->token = ID;
			kp->sc = K_TYPE;
			kp->type = tagp;

			if (attab eq symtab)
			{
				rv = tlook(symtab[hash(kp->name)], kp);
				if (rv eq nil)
				{						/* delayed tag */
					rv = tagp;
					to_type(rv, isstruct);
					globl_sym(kp,0);
				othw
					rv = rv->type;
					freeTn(kp);
				}
			othw
				/* ANSI special decl
					struct <tag> ;
				   for hiding old tag within block */
				if (cur->token eq ENDS and G.prtab->level)
					rv = tlook(*attab, kp);
				else
					rv = alltags(kp);
				if (rv eq nil)
				{						/* delayed tag */
					rv = tagp;
					to_type(rv, isstruct);
					putt_lifo(attab, kp);
				othw
					rv = rv->type;
					freeTn(kp);
				}
			}
		}
	}
	return rv;	/* the type itself */
}

/* zoals het door ANSI eigenlijk voorgeschreven had moeten worden */
/* This is a restricted form of struct declaration */
/* For Algol 68 fans: the stuff between the () of a call is a structure display */
static void A_args(TP *listpp,long *sizep)
{
	TP head, xp;
	short parnr, sclass;
	bool iscomma, isends, isvargl, declty;

	*sizep = 0;
	parnr = 1;

	do
	{
		iscomma = 0;
		isends  = 0;
		sclass = 0;

		head = Declarer(false, nil, &sclass, &declty);		/* sclass --> declarer (K&R all editions) */
		if ( ok_prh (sclass, head) eq 0 )
			sclass = 0;
		do
		{
			xp = Declare(head, FUNC);	 	/* FUNC: for proc param ID not required */
			xp = dummy_id(xp, head, parnr);

			if (ok_prx(xp, head))
			{
#if USAGE
				xp->tflgs.f.isarg = 1;
#endif
				regvar_options(xp, sclass);
				arg_size(sizep, xp);
				list_sym(listpp, xp);
				listpp = &xp->next;
				isvargl = xp->type->token eq T_VARGL;
				parnr++;
			}

			iscomma = cur->token eq COMMA;
			if (iscomma) fadvnode();
			if (isvargl) break;
		}
		while (iscomma);

		isends = cur->token eq ENDS;
		if (isends) fadvnode();
		if (isvargl) break;
	}
	while (isends);

	while (STACKALN & *sizep)
		*sizep += 1;
	return;
}

NP check_syscall(NP np);

static void proc_modifier(TP kp)	/* cdecl, pascal, __asm__, __syscall__ */
{
	NP e2;
	while (cur->cat0 & PMOD)
	{
		short tok = cur->token;
		fadvnode();
		switch (tok)
		{

		case K_CDECL:
			kp->cflgs.f.cdec = 1;
		break;

		case K_PAS:		/* dummy for now */
		break;

#if BIP_ASM
		case K_ASM:
			kp->tflgs.f.asm_func = 1;
		break;
#endif

		case K_SYSC:				/* __syscall__ (currentlly used for generating trap instruction) */
			e2 = get_expr();
			e2 = check_syscall(e2);
			if (e2)
			{
				if (e2->token eq ICON)
				{
					kp->fld.offset = e2->val.i;
					kp->lbl  = -1;
				othw
					kp->fld.offset = e2->left ->val.i;
					kp->lbl  = e2->right->val.i;
				}
				kp->cflgs.f.sysc = 1;
				freenode(e2);
			}
		}
	}
}

static TP decl_proc(void)
{
	TP rv;

	D_(D, "decl_proc");

	rv = tpcur(); advnode();
	rv->token = T_PROC;
	rv->tflgs.f.ans_args = 1;

	if (cur->token eq PAREN)
	{
		fadvnode();
		A_args(&rv->list, &rv->size);
		eat(NERAP);
	}

	proc_modifier(rv);		/* check before ':' */

	if (cur->token ne LABEL)
		d_to_dt(rv, basic_type(T_VOID,0));
	else
	{
		short sclass = -1; bool declty;
		fadvnode();
		d_to_dt(rv, Declarer(false, nil, &sclass, &declty));
	}
	return rv;
}
