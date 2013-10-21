/*
 * XaAES - XaAES Ain't the AES (c) 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <prelude.h>
#include <mintbind.h>

#include <string.h>
#include <ctype.h>			/* We use the version without macros!! */

#include MEMORY_HNAME

#define XA_SCL 1
#include "xa_types.h"
#include "xa_fsel.h"
#include "matchpat.h"
#include "ipff.h"


#include "xalloc.h"

long fl;

static
APP_LIST *local_list;

static
OPT default_options, local_options;

static
OPT_LIST *app_options;

static int pid, AESpid = -1, AESversion;

static
GetSym get_outer_sym
{
	static SYMBOL t;
	MSG_BUF m = {XA_M_GETSYM};
	m.s.src = pid;
	m.s.p1 = &t;
	m.s.p2 = name;
	appl_write(AESpid, 16, &m);
	evnt_mesag(m.m);
	if (m.s.msg == XA_M_OK)
		return &t;
	return nil;
}

static
void send_exec(char *p)
{
	MSG_BUF m = {XA_M_EXEC};
	m.s.src = pid;
	m.s.p2 = p;
	appl_write(AESpid, 16, &m);
	evnt_mesag(m.m);
}

static
bool inq_xfs(char *p, char *dsep)		/* yields true if case sensitive */
{
	long c,t;
	c = Dpathconf(p,DP_CASE);
	t = Dpathconf(p,DP_TRUNC);

	if (dsep)
	{
		* dsep    = bslash;
		*(dsep+1) = 0;
	}
	return !(c eq 1 and t eq 2);
}

static
void add_slash(char *p)
{
	char *pl = p + strlen(p) - 1;

	if (*pl != slash and *pl != bslash)
		strcat(p, sbslash);
}

static
bool is_wild(int c)
{
	switch (c)
	{
		case '*': break;
		case ']': break;
		case '?': break;
		case '!': break;
		case '[': break;
/*		case '': break;
		case '': break;
		case '': break;
		case '': break;
		case '': break;
		case '': break;
*/		default:
		return false;
	}
	return true;
}
static
bool have_wild(char *s)
{
	char *t = s + strlen(s);
	while (--t > s)
	{
		if (*t == '\\' or *t == ':' or *t == '/')
			break;
		if (is_wild(*t))
			return true;
	}
	return false;
}

static
int SCL(char *txt)
{
	extern bool naes12;
	bool iftruth = 0, ifexpr = 1;
	int inif = 0;
	Path parms;
	OPT *curopt = &default_options;			/* HR 240901: specify some options for some programs. */
	bool have_brace = false, have_opt = false;
	int fh, t;
	char *translation_table, *lb;
	long tl, err = 0; int lnr = 0;

	ipff_init(IPFF_L-1,sizeof(Path)-1,0,nil,txt,&translation_table);	/* initialize */

	/* translate identifiers to lower case */
	for (t = 'A'; t <= 'Z'; t++)
		translation_table[t] = t - 'A' + 'a';

/*	HR:
	 It is not obligatory to do line based parsing;
	ipff_line zeroizes \r & \n,
	\r & \n are otherwise treated as white space,
	alternative:
		replace lb by cnf,
		dont use ipff_line and loop around anyway you like.
		pe: while(is_keyword(rstr))	or something like that.
		Comment must be enclosed then I suppose. :-)
*/

	while((lb = ipff_line(&tl)) ne nil)
	{
		int c;
		char rstr[IPFF_L];

		lnr++;

		if (tl eq 0)
			continue;

		c = sk();	/* skip white space, return nonwhite character */
		/* '#' is a comment line */
		if (c and c ne '#')
		{
			ipff_trail(lb);	/* remove trailing spaces */

			fdisplay(fl, false, "%s%s\n", iftruth == 0 ? "" : "# ", ipff_getp());

			ide(rstr);		/* get a identifier */
			sk();			/* skip white space */

			if (inif eq 0)
			{
				if (strcmp(rstr, "if") eq 0)
				{
					sk();
					inif = 1;
					ifexpr = truth();
					iftruth = 1;
					continue;
				}
			}
			else
			{
				if (inif eq 1)		/* in if but not yet then */
				{
					if (strcmp(rstr, "then") eq 0)
					{
						iftruth = ifexpr;
						inif = 2;
						continue;
					}
				} else				/* in then or else */
				{
					if (    inif eq 2		/* in then */
					    and strcmp(rstr, "else") eq 0
					   )
					{
						iftruth ^= 1;
						inif = 3;
						continue;
					}
	
					if (strcmp(rstr, "fi") eq 0)
					{
						iftruth = 0;
						inif = 0;
						continue;
					}
				}

				if (iftruth == 1)
					continue;
			}

			if (have_opt and !have_brace and c eq '{')
			{
				skc();
				have_brace = true;
				continue;			/* while lb = ipff_line */
			}
			if (have_brace and c eq '}')
			{
				MSG_BUF m = {XA_M_OPT};
				APP_LIST *loc = local_list;
				skc();
				curopt = &default_options;
				have_opt = false;
				have_brace = false;
				m.s.src = pid;
				while (loc)
				{
					APP_LIST *nx = loc->next;
					m.s.p1 = loc->name;
					m.s.p2 = curopt;
					appl_write(AESpid, 16, &m);
					evnt_mesag(m.m);
					
					free(loc);
					loc = nx;
				}

				continue;			/* while lb = ipff_line */
			}
		
			if (*rstr eq 0)
				err = fdisplay(fl, false, "line %d: a line must start with a alphanumeric keyword\n", lnr);
	
	/* Begin of options. */
			elif (    !have_opt
			      and strcmp(rstr,"options") eq 0)
			{
				have_opt = true;
				fstr(parms, 0, 0);
/* HR 140402: rorganization of options database. Make it more work as the syntax suggests. */

				if (strcmp(parms,"default") eq 0)
					curopt = &default_options;
				else
					curopt = &local_options,

				local_list = nil;

				do
				{
					OPT_LIST *new;
					APP_LIST *loc;

					new = app_options;
					while (new)
					{
						if (stricmp(new->name, parms) == 0)
							break;
						new = new->next;
					}

					if (!new)
					{
						new = xcalloc(1, sizeof(*new), 2002);
						if (new eq nil)
							break;
	
						new->next = app_options;
						app_options = new;
						strcpy(new->name, parms);
						new->options = default_options;
					}

					if (new eq nil)
						break;

					loc = xcalloc(1, sizeof(*loc), 2003);
					if (loc eq nil)
						break;

					loc->next = local_list;
					local_list = loc;
					strcpy(loc->name, parms);

					if (!infix())
						break;
					skc();
					fstr(parms, 0, 0);
				}
				od
			}
	#if NAES12
			elif (strcmp(rstr,"naes12") eq 0)
				curopt->naes12 = true;
	#endif
	#if NAES3D
			elif (strcmp(rstr,"naes3d") eq 0)		/* HR 040801 */
				curopt->naes = true;
	#endif
			elif (strcmp(rstr,"open") eq 0)			/* HR 250102 */
				send_exec(lb);
			elif (strcmp(rstr,"windows") eq 0)		/* HR 200801 */
			{
				do {
					ide(rstr);
					if (strcmp(rstr,"nohide") eq 0)
						curopt->nohide = true;
					elif (strcmp(rstr,"noleft") eq 0)		/* HR 250901 */
						curopt->noleft = true;
					elif (strcmp(rstr,"thinframe") eq 0)	/* HR 270901 */
						curopt->thinframe = -1;
					elif (strcmp(rstr, "thickframe") eq 0)	/* HR 280102 */
						curopt->thinframe = 1;
					elif (strcmp(rstr,"thinwork") eq 0)	/* HR 270901 */
						curopt->thinwork = true;
					elif (strcmp(rstr,"live") eq 0)
						curopt->live = true;
					if (!infix())
						break;
					skc();
				} od
			}
			elif (strcmp(rstr,"xa_windows") eq 0)	/* HR 200801 */
			{
				do {
					ide(rstr);
					if (strcmp(rstr,"nohide") eq 0)
						curopt->xa_nohide = true;
					elif (strcmp(rstr,"nomove") eq 0)
					{
						curopt->xa_nomove = true;
						curopt->xa_nohide = true;
					}
					elif (strcmp(rstr,"noleft") eq 0)		/* HR 250901 */
						curopt->noleft = true;
					if (!infix())
						break;
					skc();
				} od
			}
			elif (   strcmp(rstr,"windowner") eq 0
			      or strcmp(rstr,"winowner" ) eq 0 
			     )
			{
				ide(rstr);
				if (strcmp(rstr,"true") eq 0 or strcmp(rstr,"short") eq 0)
					curopt->windowner = 1;
				elif (strcmp(rstr,"long") eq 0)
					curopt->windowner = 2;
				/* default is zero anyway. */
			}
			elif (strcmp(rstr,"menu") eq 0)
				send_exec(lb);
			elif (strcmp(rstr,"popscroll") eq 0)
				send_exec(lb);
	/* End of options. */
			elif (strcmp(rstr,"priority") eq 0)
				send_exec(lb);
			elif (   strcmp(rstr,"desk" ) eq 0
			      or strcmp(rstr,"shell") eq 0
			     )
			{
				int deskpid;
				Path p;
				MSG_BUF m = {XA_M_DESK};
	
				fstr(p, 0, 0);
				sk();
				parms[0] = sdisplay(parms+1,"%s",ipff_getp());
				deskpid = shel_write(0, 0, 0, p, parms);
				if (deskpid)
				{
					m.s.src = pid;
					m.s.p2 = p;
					m.s.m3 = deskpid;
					appl_write(AESpid, 16, &m);
					evnt_mesag(m.m);
				}
			}
			elif (strcmp(rstr,"run") eq 0)
			{
				Path path;
	
				fstr(path, 0, 0);
				if (!have_wild(path))
				{
					sk();
					parms[0] = sdisplay(parms+1,"%s",ipff_getp());
					shel_write(0, 0, 0, path, parms);
				} else
				{
					static long rep;
					Path nm, pattern;

					char *pat, *pbt, fslash[4];
					long i;				
					
					pattern[0] = '*';
					pattern[1] = '\0';
					pat = strrchr(path, bslash);
					pbt = strrchr(path, slash);
					if (!pat)
					{
						pat = pbt;
					}
					if (pat)
					{
						strcpy(pattern, pat + 1);
						*(pat + 1) = 0;
						if (strcmp(pattern, "*.*") == 0)
							*(pattern + 1) = 0;
					}
				
					add_slash(path);
				
					i = Dopendir(path, 0);

					if (i > 0)
					{
						XATTR xat;
						long j;

						while (Dxreaddir(NAME_MAX,i,nm,(long)&xat,&rep) eq 0)
						{
							char fulln[NAME_MAX+2];
							char *nam = nm+4;
							bool dir = (xat.mode&0xf000) == S_IFDIR,
							     sln = (xat.mode&0xf000) == (G_u)S_IFLNK,
							     match = false;
							strcpy(fulln,path);
							strcat(fulln,nam);

							if (sln) 
							{
								Fxattr(0,fulln,&xat);
								dir = (xat.mode&0xf000) == S_IFDIR;
							}
							if (!dir)
							{
								match = match_pattern(nam, pattern);
								if (match)
								{
									parms[0] = 0;
									fdisplay(fl, false, "  --  '%s'\n", fulln);
									shel_write(0, 0, 0, fulln, parms);
								}
							}
						}

						Dclosedir(i); 
					}
				}
			}
#if 0
			elif (strcmp(rstr,"launcher") eq 0)
				send_exec(lb);
			elif (strcmp(rstr,"clipboard") eq 0)
				send_exec(lb);
#endif
			elif (strncmp(rstr, "half_scr",8) eq 0)
				curopt->half_screen = dec();				/* HR 170102 */ 
			elif (strcmp(rstr,"cancel") eq 0)
				send_exec(lb);
			elif (   strcmp(rstr,"string"  ) eq 0
			      or strcmp(rstr,"int"     ) eq 0
			      or strcmp(rstr,"integral") eq 0
			      or strcmp(rstr,"integer" ) eq 0
			      or strcmp(rstr,"bool"    ) eq 0
			      or strcmp(rstr,"boolean" ) eq 0		/* integer, integral, boolean */
			     )
			{
				Path ident, p;
				ide(ident);
				if (*ident)
				{
					int atok = assign();			/* 0 'is' constant, 1 ':=' variable */

					sk();
					if (atok < 0)
					{
						err = fdisplay(fl, false, "needs ':=' or 'is', assume 'is'\n");
						atok = 0;
					}
					if (*rstr eq 'i')			/* int */
						new_sym(ident, atok, Number, nil, dec());
					elif (*rstr eq 'b')
						new_sym(ident, atok, Bit, nil, truth());
					else
					{
						fstr(p, 0, 0);
						new_sym(ident, atok, String, p, 0);
					}
				}
			}
			elif (   strcmp (rstr,"setenv") eq 0
			      or strcmp (rstr,"export") eq 0
			      )
			{
				Path ident;
				char p[512], *isp, *q;
				SYMBOL *s;

				q = ipff_getp();
				
/* HR 020402: just replace the first occurrence of = in the source by space. */
				isp = strstr(q, "=");
				if (isp)
					*isp = ' ';

				s = fstr(ident, 0, Lval);

				if (*ident)
				{
					int c = sk();

					strcpy(p,ident);
					strupr(p);
					strcat(p,"=");

					if (s and (c eq 0 or c ne '=' or c eq ';') )
					{
						/* pattern 'export var' */
						if (s->mode eq String)
							strcat(p, s->s);
						else
							sdisplay(p + strlen(p), "%ld", s->val);
					othw
						if (c eq '=')
							skc();
						fstr(p + strlen(p), 0, 0);
					}
					shel_write(8, 1, 0, p, nil);
				}
			}
#if 0
			elif (strcmp(rstr,"filters") eq 0)
				send_exec(lb);
#endif
			else
				err = fdisplay(fl, false, "line %d: unimplemented keyword '%s'\n", lnr, rstr);
		}
	}

	return err;
}

int main(int argc, char **argv, char **envp)
{	
	int ret = 0;

	memset(&default_options, 0, sizeof(default_options));

	pid = appl_init();

	AESpid = appl_find("AESSYS  ");

	if (AESpid < 0)
		ret = form_alert(1, "[3][ | No suitable AES present ][ Ok ]");
	else if (wind_get(0, 'XA', &AESversion) != 'XA')
		ret = form_alert(1, "[3][ | XA_SCL is for XaAES ][ Ok ]");
	else if (argv[1] == nil)
		ret = form_alert(1, "[3][ | XA_SCL needs a scl file ][ Ok ]");
	else
	{
		long l;
		int lol;

		char *cnf = Fload(argv[1], &lol, &l);
		if (cnf)
		{
			fl = Fcreate("xa_scl.log", 0);
			outer_sym = get_outer_sym;
			fdisplay(fl, false, "# XA_SCL v0.1 executing '%s'\n", argv[1]);
			fdisplay(fl, false, "\n");
			ret = SCL(cnf);
			free(cnf);
			Fclose(fl);
		}
	}
	
	appl_exit();
	return ret;
}

