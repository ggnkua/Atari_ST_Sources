	/***************************************************************\
	*								*
	*  PDMAKE, Atari ST version					*
	*								*
	*  Adapted from mod.sources Vol 7 Issue 71, 1986-12-03.		*
	*								*
	*  This port makes extensive use of the original net.sources	*
	*  port by Jwahar Bammi.					*
	*								*
	*      Ton van Overbeek						*
	*      Email: TPC862@ESTEC.BITNET				*
	*             TPC862%ESTEC.BITNET@WISCVM.WISC.EDU    (ARPA)	*
	*             ...!mcvax!tpc862%estec.bitnet   (UUCP Europe)	*
	*             ...!ucbvax!tpc862%estec.bitnet  (UUCP U.S.A.)	*
	*             71450,3537  (CompuServe)				*
	*								*
	\***************************************************************/

/*
 *    Control of the implicit suffix rules
 */


#include "h.h"


/*
 *    Return a pointer to the suffix of a name
 */
char *
suffix(name)
char *	name;
{
    return rindex(name, '.');
}


/*
 *    Dynamic dependency.  This routine applies the suffix rules
 *    to try and find a source and a set of rules for a missing
 *    target.  If found, np is made into a target with the implicit
 *    source name, and rules.  Returns TRUE if np was made into
 *    a target.
 */
bool
dyndep(np)
struct name *	np;
{
    register char *	p;
    register char *	q;
    register char *	suff;		/*  Old suffix  */
    register char *	basename;	/*  Name without suffix  */
    struct name *	op;		/*  New dependent  */
    struct name *	sp;		/*  Suffix  */
    struct line *	lp;
    struct depend *	dp;
    char *		newsuff;


    p = str1;
    q = np->n_name;
    if (!(suff = suffix(q)))
        return FALSE;			/* No suffix */
    while (q < suff)
        *p++ = *q++;
    *p = '\0';
    basename = setmacro("*", str1)->m_val;

    if (!((sp = newname(".SUFFIXES"))->n_flag & N_TARG))
        return FALSE;

    for (lp = sp->n_line; lp; lp = lp->l_next)
        for (dp = lp->l_dep; dp; dp = dp->d_next)
        {
            newsuff = dp->d_name->n_name;
            if (strlen(suff)+strlen(newsuff)+1 >= LZ)
                fatal("Suffix rule too long");
            p = str1;
            q = newsuff;
            while (*p++ = *q++)
                ;
            p--;
            q = suff;
            while (*p++ = *q++)
                ;
            sp = newname(str1);
            if (sp->n_flag & N_TARG)
            {
                p = str1;
                q = basename;
                if (strlen(basename) + strlen(newsuff)+1 >= LZ)
                    fatal("Implicit name too long");
                while (*p++ = *q++)
                    ;
                p--;
                q = newsuff;
                while (*p++ = *q++)
                    ;
                op = newname(str1);
                if (!op->n_time)
                    modtime(op);
                if (op->n_time)
                {
                    dp = newdep(op, (struct depend *) 0);
                    newline(np, dp, sp->n_line->l_cmd, 0);
                    setmacro("<", op->n_name);
                    return TRUE;
                }
            }
        }
    return FALSE;
}


/*
 *    Make the default rules
 */
void
makerules()
{
    struct cmd *	cp;
    struct name *	np;
    struct depend *	dp;


#ifdef eon
    setmacro("BDSCC", "asm");
    /*    setmacro("BDSCFLAGS", "");    */
    cp = newcmd("$(BDSCC) $(BDSCFLAGS) -n $<", (struct cmd *) 0);
    np = newname(".c.o");
    newline(np, (struct depend *) 0, cp, 0);

    setmacro("CC", "c");
    setmacro("CFLAGS", "-O");
    cp = newcmd("$(CC) $(CFLAGS) -c $<", (struct cmd *) 0);
    np = newname(".c.obj");
    newline(np, (struct depend *) 0, cp, 0);

    setmacro("M80", "asm -n");
    /*    setmacro("M80FLAGS", "");    */
    cp = newcmd("$(M80) $(M80FLAGS) $<", (struct cmd *) 0);
    np = newname(".mac.o");
    newline(np, (struct depend *) 0, cp, 0);


    setmacro("AS", "zas");
    /*    setmacro("ASFLAGS", "");    */
    cp = newcmd("$(ZAS) $(ASFLAGS) -o $@ $<", (struct cmd *) 0);
    np = newname(".as.obj");
    newline(np, (struct depend *) 0, cp, 0);

    np = newname(".as");
    dp = newdep(np, 0);
    np = newname(".obj");
    dp = newdep(np, dp);
    np = newname(".c");
    dp = newdep(np, dp);
    np = newname(".o");
    dp = newdep(np, dp);
    np = newname(".mac");
    dp = newdep(np, dp);
    np = newname(".SUFFIXES");
    newline(np, (struct depend *) 0, cp, 0);
#endif

/*
 *    Some of the UNIX implicit rules
 */
#ifdef unix
    setmacro("CC", "cc");
    setmacro("CFLAGS", "-O");
    cp = newcmd("$(CC) $(CFLAGS) -c $<", (struct cmd *) 0);
    np = newname(".c.o");
    newline(np, (struct depend *) 0, cp, 0);

    setmacro("AS", "as");
    cp = newcmd("$(AS) -o $@ $<", (struct cmd *) 0);
    np = newname(".s.o");
    newline(np, (struct depend *) 0, cp, 0);

    setmacro("YACC", "yacc");
    /*    setmacro("YFLAGS", "");    */
    cp = newcmd("$(YACC) $(YFLAGS) $<", (struct cmd *) 0);
    cp = newcmd("mv y.tab.c $@", cp);
    np = newname(".y.c");
    newline(np, (struct depend *) 0, cp, 0);

    cp = newcmd("$(YACC) $(YFLAGS) $<", (struct cmd *) 0);
    cp = newcmd("$(CC) $(CFLAGS) -c y.tab.c", cp);
    cp = newcmd("rm y.tab.c", cp);
    cp = newcmd("mv y.tab.o $@", cp);
    np = newname(".y.o");
    newline(np, (struct depend *) 0, cp, 0);

    np = newname(".s");
    dp = newdep(np, 0);
    np = newname(".o");
    dp = newdep(np, dp);
    np = newname(".c");
    dp = newdep(np, dp);
    np = newname(".y");
    dp = newdep(np, dp);
    np = newname(".SUFFIXES");
    newline(np, (struct depend *) 0, cp, 0);
#endif
#ifdef os9
/*
 *    Fairlight use an enhanced version of the C sub-system.
 *    They have a specialised macro pre-processor.
 */
    setmacro("CC", "cc");
    setmacro("CFLAGS", "-z");
    cp = newcmd("$(CC) $(CFLAGS) -r $<", (struct cmd *) 0);

    np = newname(".c.r");
    newline(np, (struct depend *) 0, cp, 0);
    np = newname(".ca.r");
    newline(np, (struct depend *) 0, cp, 0);
    np = newname(".a.r");
    newline(np, (struct depend *) 0, cp, 0);
    np = newname(".o.r");
    newline(np, (struct depend *) 0, cp, 0);
    np = newname(".mc.r");
    newline(np, (struct depend *) 0, cp, 0);
    np = newname(".mca.r");
    newline(np, (struct depend *) 0, cp, 0);
    np = newname(".ma.r");
    newline(np, (struct depend *) 0, cp, 0);
    np = newname(".mo.r");
    newline(np, (struct depend *) 0, cp, 0);

    np = newname(".r");
    dp = newdep(np, 0);
    np = newname(".mc");
    dp = newdep(np, dp);
    np = newname(".mca");
    dp = newdep(np, dp);
    np = newname(".c");
    dp = newdep(np, dp);
    np = newname(".ca");
    dp = newdep(np, dp);
    np = newname(".ma");
    dp = newdep(np, dp);
    np = newname(".mo");
    dp = newdep(np, dp);
    np = newname(".o");
    dp = newdep(np, dp);
    np = newname(".a");
    dp = newdep(np, dp);
    np = newname(".SUFFIXES");
    newline(np, dp, (struct cmd *) 0, 0);
#endif

#ifdef ATARIST
    /* Atari special internal (to make) commands */
    setmacro("RM","%r");	/* Remove, any number of args, Wildcards OK */
    setmacro("CP","%c");	/* Copy file to file only     */
    setmacro("ECHO","%e");	/* Echo Argument          */

#ifndef MEGRULES
    /* Alcyon C and AS68 rules */

    /* Path to the Alcyon C executables */
    setmacro("CPATH","a:");

    /* C preprocessor       */
    setmacro("CP68", "cp68.prg");
    /* C preprocessor flags    */
    setmacro("CPFLAGS", "-i a:\\include\\");

    /* Pass 1 of the C compiler */
    setmacro("C068", "c068.prg");
    /* Pass 1 flags           */
    setmacro("C0FLAGS", "-f");	/* change to "" if you want to use IEEE
				 * floating point and libm instead of libf
				 * by Default. Otherwise simply redefine
				 * C0FLAGS in your makefile to get the
				 * IEEE floating option.
				 */

    /* Pass 2 of the C compiler */
    setmacro("C168","c168.prg");
    /* Pass 2  flags        */
    /* setmacro("C1FLAGS", ""); */    /* Save ourselves some space */

    /* Assembler            */
    setmacro("AS","as68.prg");
    /* Assembler flags        */
    setmacro("ASFLAGS","-l -u -s a:\\ -f d:\\");

    /* Now make up the command lines */
    cp = newcmd("$(CPATH)\\$(CP68) $(CPFLAGS) $< $*.i", (struct cmd *) 0);
    cp = newcmd("$(CPATH)\\$(C068) $*.i $*.1 $*.2 $*.3 $(C0FLAGS)", cp);
    cp = newcmd("$(RM) $*.i", cp);
    cp = newcmd("$(CPATH)\\$(C168) $*.1 $*.2 $*.s $(C1FLAGS)", cp);
    cp = newcmd("$(RM) $*.1 $*.2",cp);
    cp = newcmd("$(CPATH)\\$(AS) $(ASFLAGS) $*.s", cp);
    cp = newcmd("$(RM) $*.s", cp);
    np = newname(".c.o");
    newline(np, (struct depend *) 0, cp, 0);

    /* Rules for Alcyon Assembler */
    cp = newcmd("$(CPATH)\\$(AS) $(ASFLAGS) $<", (struct cmd *) 0);
    np = newname(".s.o");
    newline(np, (struct depend *) 0, cp, 0);

    /* Linker of choice */
    setmacro("LINKER", "a:\\link68.prg");

    /* Relmod */
    setmacro("RELMOD", "a:\\relmod.prg");

#else
    /* Megamax C Rules default */

    /* Path to the Megamax C executables */
    setmacro("CPATH","a:");


    /* C Compiler       */
    setmacro("MMCC", "mmcc.ttp");

    /* Code Optimizer        */
    setmacro("MMIMP","mmimp.ttp");

    /* Now make up the command lines */
    cp = newcmd("$(CPATH)\\$(MMCC) $<", (struct cmd *) 0);
    cp = newcmd("$(CPATH)\\$(MMIMP) $*.o", cp);
    np = newname(".c.o");
    newline(np, (struct depend *) 0, cp, 0);

    /* Linker of choice */
    setmacro("LINKER", "$(CPATH)\\mmlink.ttp");

#endif /* MEGRULES */

    /* Predefined suffixes */
    np = newname(".prg");
    dp = newdep(np, NULL);
    np = newname(".68k");
    dp = newdep(np, dp);
    np = newname(".o");
    dp = newdep(np, dp);
    np = newname(".bin");
    dp = newdep(np, dp);
    np = newname(".s");
    dp = newdep(np, dp);
    np = newname(".c");
    dp = newdep(np, dp);
    np = newname(".pas");
    dp = newdep(np, dp);
    np = newname(".SUFFIXES");
    newline(np, dp, (struct cmd *) 0, 0);
#endif  /*  ATARIST  */
}
