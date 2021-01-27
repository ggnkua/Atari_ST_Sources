/* Copyright (c) 1990 - present by H. Robbers.   
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

/*
 *	pmod.h     handle function modifiers 
 */
	if (cur->cat0 & PMOD)		/* cdecl, pascal, __asm__, __syscall */
	{
		short tok = cur->token;
		fadvnode();
		switch (tok)
		{

		case K_CDECL:
			e1 = declarator();
			kp = yields_ty(e1, T_PROC);
			if (kp)
				kp->cflgs.f.cdec = 1;
			else
				warn_func_modifier(e1, K_CDECL);
			return e1;
		case K_PAS:
			e1 = declarator();
			kp = yields_ty(e1, T_PROC);
			if (!kp)
				warn_func_modifier(e1, K_PAS);
			return e1;
#if BIP_ASM
		case K_ASM:
			e1 = declarator();
			kp = yields_ty(e1, T_PROC);
			if (kp)
				kp->tflgs.f.asm_func = 1;
			else
				warn_func_modifier(e1, K_ASM);
			return e1;
#endif
		case K_SYSC:				/* __syscall__ (currentlly used for generating trap instruction) */
			e2 = get_expr();
			e2 = check_syscall(e2);
			e1 = declarator();
			if (e1 eq nil or (e1 and e1->token ne T_PROC))
				warn_func_modifier(e1, K_SYSC);
			elif (e2)
			{
				if (e2->token eq ICON)
					e1->fld.offset = e2->val.i,
					e1->lbl  = -1;
				else
					e1->fld.offset = e2->left ->val.i,
					e1->lbl  = e2->right->val.i;
				e1->cflgs.f.sysc = 1;
				freenode(e2);
			}
	
	
			return e1;
		}
	}
