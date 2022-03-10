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

/*      variable initialization         */

enum e_gt { nogen, bytegen, wordgen, longgen };
enum e_sg { noseg, codeseg, dataseg };

int	       gentype = nogen;
int	       curseg = noseg;
int        outcol = 0;

struct oplst {
        char    *s;
        int     ov;
        }       opl[] =
        {       {"MOVE",op_move}, {"MOVE",op_moveq}, {"ADD",op_add},
                {"ADD",op_addi}, {"ADD",op_addq}, {"SUB",op_sub},
                {"SUB",op_subi}, {"SUB",op_subq}, {"AND",op_and},
                {"OR",op_or}, {"EOR",op_eor}, {"MULS",op_muls},
                {"DIVS",op_divs}, {"SWAP",op_swap}, {"BEQ",op_beq},
                {"BHI",op_bhi}, {"BHS",op_bhs}, {"BLO",op_blo},
                {"BLS",op_bls}, {"MULU",op_mulu}, {"DIVU",op_divu},
                {"BNE",op_bne}, {"BLT",op_blt}, {"BLE",op_ble},
                {"BGT",op_bgt}, {"BGE",op_bge}, {"NEG",op_neg},
                {"NOT",op_not}, {"CMP",op_cmp}, {"EXT",op_ext},
                {"JMP",op_jmp}, {"JSR",op_jsr}, {"RTS",op_rts},
                {"LEA",op_lea}, {"ASR",op_asr}, {"ASL",op_asl},
                {"CLR",op_clr}, {"LINK",op_link}, {"UNLK",op_unlk},
                {"BRA",op_bra}, {"MOVEM",op_movem}, {"PEA",op_pea},
                {"CMP",op_cmpi}, {"TST",op_tst}, {"DC",op_dc},
                {0,0} };

putop(op)
int     op;
{       int     i;
        i = 0;
        while( opl[i].s )
                {
                if( opl[i].ov == op )
                        {
                        fprintf(output,"\t%s",opl[i].s);
                        return;
                        }
                ++i;
                }
        printf("DIAG - illegal opcode.\n");
}

putconst(offset)
/*
 *      put a constant to the output file.
 */
struct enode    *offset;
{
   char su[80];

       switch( offset->nodetype )
                {
                case en_autocon:
                case en_icon:
                        fprintf(output,"%d",offset->v.i);
                        break;
                case en_labcon:
                        fprintf(output,"L.%d",offset->v.i);
                        break;
                case en_nacon:
                        strcpy(su,offset->v.p[0]);    /* copy labels str */
                        upcase(su);		      /* Transform to upper */
                        fprintf(output,"%s",su);
                        break;
                case en_add:
                        putconst(offset->v.p[0]);
                        fprintf(output,"+");
                        putconst(offset->v.p[1]);
                        break;
                case en_sub:
                        putconst(offset->v.p[0]);
                        fprintf(output,"-");
                        putconst(offset->v.p[1]);
                        break;
                case en_uminus:
                        fprintf(output,"-");
                        putconst(offset->v.p[0]);
                        break;
                default:
                        printf("DIAG - illegal constant node.\n");
                        break;
                }
}

putlen(l)
/*
 *      append the length field to an instruction.
 */
int     l;
{       switch( l )
                {
                case 0:
                        break;  /* no length field */
                case 1:
                        fprintf(output,".B");
                        break;
                case 2:
                        fprintf(output,".W");
                        break;
                case 4:
                        fprintf(output,".L");
                        break;
                default:
                        printf("DIAG - illegal length field.\n");
                        break;
                }
}

putamode(ap)
/*
 *      output a general addressing mode.
 */
struct amode    *ap;
{       switch( ap->mode )
                {
                case am_immed:
                        fprintf(output,"#");
                case am_direct:
                        putconst(ap->offset);
                        break;
                case am_areg:
                        fprintf(output,"A%d",ap->preg);
                        break;
                case am_dreg:
                        fprintf(output,"D%d",ap->preg);
                        break;
                case am_ind:
                        fprintf(output,"(A%d)",ap->preg);
                        break;
                case am_ainc:
                        fprintf(output,"(A%d)+",ap->preg);
                        break;
                case am_adec:
                        fprintf(output,"-(A%d)",ap->preg);
                        break;
                case am_indx:
                        putconst(ap->offset);
                        fprintf(output,"(A%d)",ap->preg);
                        break;
                case am_xpc:
                        putconst(ap->offset);
                        fprintf(output,"(D%d,PC)",ap->preg);
                        break;
                case am_indx2:
                        putconst(ap->offset);
                        fprintf(output,"(A%d,D%d.L)",ap->preg,ap->sreg);
                        break;
                case am_indx3:
                        putconst(ap->offset);
                        fprintf(output,"(A%d,A%d.L)",ap->preg,ap->sreg);
                        break;
                case am_mask:
                        put_mask(ap->offset);
                        break;
                default:
                        printf("DIAG - illegal address mode.\n");
                        break;
                }
}

put_code(op,len,aps,apd)
/*
 *      output a generic instruction.
 */
struct amode    *aps, *apd;
int             op, len;
{       if( op == op_dc )
		{
		switch( len )
			{
			case 1: fprintf(output,"\tDC.B"); break;
			case 2: fprintf(output,"\tDC.W"); break;
			case 4: fprintf(output,"\tDC.L"); break;
			}
		}
	else
		{
		putop(op);
        	putlen(len);
		}
        if( aps != 0 )
                {
                fprintf(output,"\t");
		putamode(aps);
                if( apd != 0 )
                        {
                        fprintf(output,",");
                       	putamode(apd);
                        }
                }
        fprintf(output,"\n");
}

put_mask(mask)
/*
 *      generate a register mask for restore and save.
 */
int     mask;
{       int     i;
        int     notfirst;
/*        fprintf(output,"#$%04X",mask);	*/

        notfirst = 0;
        for(i=0; i< 16; i++)
        {  if((mask & (1 << (15-i))) != 0)
           { if( notfirst ) fprintf(output,"/");
             notfirst=1;
             putreg(i);
           }
        }


}

putreg(r)
/*
 *      generate a register name from a tempref number.
 */
int     r;
{       if( r < 8 )
                fprintf(output,"D%d",r);
        else
                fprintf(output,"A%d",r - 8);
}

gen_strlab(s)
/*
 *      generate a named label.
 */
char    *s;
{
  char su[80];
  strcpy(su,s);			/* Copy the label... */
  upcase(su);			/* Convert to upper case */
       fprintf(output,"%s:\n",su);
}

put_label(lab)
/*
 *      output a compiler generated label.
 */
int     lab;
{       fprintf(output,"L.%d:\n",lab);
}

genbyte(val)
int     val;
{       if( gentype == bytegen && outcol < 60) {
                fprintf(output,",%d",val & 0x00ff);
                outcol += 4;
                }
        else    {
                nl();
                fprintf(output,"\tDC.B\t%d",val & 0x00ff);
                gentype = bytegen;
                outcol = 19;
                }
}

genword(val)
int     val;
{       if( gentype == wordgen && outcol < 58) {
                fprintf(output,",%d",val & 0x0ffff);
                outcol += 6;
                }
        else    {
                nl();
                fprintf(output,"\tDC.W\t%d",val & 0x0ffff);
                gentype = wordgen;
                outcol = 21;
                }
}

genlong(val)
int     val;
{       if( gentype == longgen && outcol < 56) {
                fprintf(output,",%d",val);
                outcol += 10;
                }
        else    {
                nl();
                fprintf(output,"\tDC.L\t%d",val);
                gentype = longgen;
                outcol = 25;
                }
}

genref(sp,offset)
SYM     *sp;
int     offset;
{       char    sign;
        if( offset < 0) {
                sign = '-';
                offset = -offset;
                }
        else
                sign = '+';
        if( gentype == longgen && outcol < 55 - strlen(sp->name)) {
                if( sp->storage_class == sc_static)
                        fprintf(output,",L.%d%c%d",sp->value.i,sign,offset);
                else
                        fprintf(output,",%s%c%d",sp->name,sign,offset);
                outcol += (11 + strlen(sp->name));
                }
        else    {
                nl();
                if(sp->storage_class == sc_static)
                    fprintf(output,"\tlong\tL.%d%c%d",sp->value.i,sign,offset);
                else
                    fprintf(output,"\tlong\t%s%c%d",sp->name,sign,offset);
                outcol = 26 + strlen(sp->name);
                gentype = longgen;
                }
}

genstorage(nbytes)
int     nbytes;
{       nl();
        fprintf(output,"\tDS.B\t%d\n",nbytes);
}

gen_labref(n)
int     n;
{       if( gentype == longgen && outcol < 58) {
                fprintf(output,",L.%d",n);
                outcol += 6;
                }
        else    {
                nl();
                fprintf(output,"\tlong\tL.%d",n);
                outcol = 22;
                gentype = longgen;
                }
}

int     stringlit(s)
/*
 *      make s a string literal and return it's label number.
 */
char    *s;
{       struct slit     *lp;
        ++global_flag;          /* always allocate from global space. */
        lp = xalloc(sizeof(struct slit));
        lp->label = nextlabel++;
        lp->str = litlate(s);
        lp->next = strtab;
        strtab = lp;
        --global_flag;
        return lp->label;
}

dumplits()
/*
 *      dump the string literal pool.
 */
{       char            *cp;
        while( strtab != 0) {
                cseg();
                nl();
                put_label(strtab->label);
                cp = strtab->str;
                while(*cp)
                        genbyte(*cp++);
                genbyte(0);
                strtab = strtab->next;
                }
        nl();
}

nl()
{       if(outcol > 0) {
                fprintf(output,"\n");
                outcol = 0;
                gentype = nogen;
                }
}

cseg()
{       if( curseg != codeseg) {
                nl();
                fprintf(output,"\tSECTION\t9\n");
                curseg = codeseg;
                }
}

dseg()
{       if( curseg != dataseg) {
                nl();
                fprintf(output,"\tSECTION\t15\n");
                curseg = dataseg;
                }
}
upcase(stg)				/* Convert string to upper case */
char stg[];
{
  int i;
  char toupper();

  i=0;
  while(stg[i])
  {
    stg[i]=toupper(stg[i]);
    i++;
  }
}

