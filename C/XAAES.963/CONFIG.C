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

#include <string.h>
#include <ctype.h>			/* We use the version without macros!! */
#include <mintbind.h>
#include "xa_types.h"
#include "xa_globl.h"
#include "xa_shel.h"

#include "xalloc.h"
#include "config.h"
#include "taskman.h"
#include "xa_fsel.h"
#include "matchpat.h"

#include "ipff.h"

static
APP_LIST *local_list;

global
OPT default_options, local_options;

global
LCFG lcfg = {WIDGNAME,RSCNAME,0,0,0,DOUBLE_CLICK_TIME,false,false,false,false};

/* HR: find a xaaes file. When the cd command to XaAES load directory is
       missing in mint.cnf (which is likely for inexperienced mint users. ;-) 
       XaAES wont fail completely.
*/
static
char **aes_path,
	 *dirs[] =
{
	"",					/* plain name only */
	Aes_home_path,				/* Dont forget to fill. */
	"c:" sbslash "gemsys" sbslash,
	"c:" sbslash "gemsys" sbslash "xaaes" sbslash,
	"c:" sbslash "aes" sbslash,
	"c:" sbslash "aes" sbslash "xaaes" sbslash,
	"c:" sbslash "mint" sbslash,
	"c:" sbslash "mint" sbslash "xaaes" sbslash,
	"c:" sbslash "multitos" sbslash,
	"c:" sbslash "multitos" sbslash "xaaes" sbslash,
	"c:" sbslash,
	"c:" sbslash "xaaes" sbslash,
	nil
};

/* HR: last resort if shell_find fails. */
global
char *xa_find(char *fn)
{
	long h;
	char *f;
	static char p[200];

	DIAGS(("xa_find '%s'\n", fn ? fn : "~"));

	f = shell_find(NOLOCKING, C.Aes, fn);		/* HR 020402: combined shell_find & xa_find permanently. */
	if (f)
		return f;
	else
	{
		aes_path = dirs;
		while (*aes_path)
		{
			char *pad = *aes_path;
			sdisplay(p,"%s%s", pad, fn);
	#if GENERATE_DIAGS
			if (lcfg.booting)
				display("try open '%s'\n", p);
			else
				DIAGS(("%s\n", p));
	#endif
			h = Fopen(p,0);
			if (h > 0)
			{
				Fclose(h);
				return p;
			}
			aes_path++;
		}
	}

	DIAGS((" - nil\n"));
	return nil;
}

enum
{
	ODEBUG,
	ONA12,
	ONA,
	ONOH,
	ONOL,
	OFRAME,
	OTHINW,
	OLIVE,
	OXNOH,
	OXNOM,
	OXNON,
	OWOWN,
	OHALF,
	OWHEEL,
	OWHLPAGE
};

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

void set_option(OPT *cur, int which)
{
	APP_LIST *loc = local_list;

	while (loc)
	{
		OPT_LIST *glo = S.app_options;

		while (glo)
		{
			if (stricmp(loc->name, glo->name) eq 0)
				break;
			glo = glo->next;
		}

		if (glo)
		{
			int i;
			OPT *o = &glo->options;

			switch (which)
			{
#if GENERATE_DIAGS
				case ODEBUG:
					for (i=0; i < D_max; i++)
					{
						o->point[i] |= cur->point[i];
						 D.point[i] |= cur->point[i];
					}
				break;
#endif
#if NAES12
				case ONA12:
					o->naes12 = cur->naes12;
				break;
#endif
#if NAES3D
				case ONA:
					o->naes = cur->naes;
				break;
#endif
				case ONOH:
					o->nohide = cur->nohide;
				break;
				case ONOL:
					o->noleft = cur->noleft;
				break;
				case OFRAME:
					o->thinframe = cur->thinframe;
				break;
				case OTHINW:
					o->thinwork = cur->thinwork;
				break;
				case OLIVE:
					o->live = cur->live;
				break;
				case OXNOM:
					o->xa_nomove = cur->xa_nomove;	/* fall thru is OK */
				case OXNOH:
					o->xa_nohide = cur->xa_nohide;
				break;
				case OXNON:
					o->xa_none = cur->xa_none;
				case OWOWN:
					o->windowner = cur->windowner;
				break;
				case OHALF:
					o->half_screen = cur->half_screen;
				break;
				case OWHEEL:
					o->wheel_reverse = cur->wheel_reverse;	/* HR 111002 */
				break;
				case OWHLPAGE:
					o->wheel_page = cur->wheel_page;	/* HR 111002 */
				break;
			}
		}
		loc = loc->next;
	}
}

/*
 * Read & parse the '.scl' files.
 */
#if GENERATE_DIAGS
#define debugp(d,s) curopt->point[d] = s
char *truthvalue(bool b)
{
	return b == 0 ? "true" : "false";
}
#endif

/* HR 130402: since xa_scl, SCL needs lock */
global
void SCL(LOCK lock, int co, char *name, char *full, char *txt)
{
	extern bool naes12;
	bool iftruth = 0, ifexpr = 1;
	int inif = 0;
	Path parms;
	OPT *curopt = &default_options;			/* HR 240901: specify some options for some programs. */
	bool have_brace = false, have_opt = false;
	char *cnf; int fh, t;
	char *translation_table, *lb;
	long tl;
	int i, lnr = 0;

	if (lcfg.booting)
	{
		fdisplay(loghandle, false, "\n");
		fdisplay(loghandle, false, "**** Executing SCL phase %d from '%s' ****\n", co, name ? name : "string");
		fdisplay(loghandle, false, "\n");
	}

	if (name)
	{
		if (!full)
			full = xa_find(name);
		if (full)
			cnf = Fload(full,&fh,&tl);
		if (cnf eq nil)
		{
			display("SCL file '%s' absent\n", name);
			return;
		}
	}
	else
		cnf = txt;

	if (lcfg.booting)
		fdisplay(loghandle, false, "calling ipff_init\n");

	ipff_init(IPFF_L-1,sizeof(Path)-1,0,nil,cnf,&translation_table);	/* initialize */

	/* translate everything to lower case */
	for (t = 'A'; t <= 'Z'; t++)
		translation_table[t] = t - 'A' + 'a';

	if (lcfg.booting)
		fdisplay(loghandle, false, "using translation table\n");

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

		c = sk();	/* sk()  skip white space, return nonwhite character
		               skc() skip 1 character, then sk()
		               sk1() skip 1 character only return next character */
		/* '#' is a comment line */
		if (c and c ne '#')
		{
			ipff_trail(lb);	/* remove trailing spaces */

			if (lcfg.booting)
				fdisplay(loghandle, false, "%s%s\n", iftruth == 0 ? "" : "# ", ipff_getp());

			ide(rstr);		/* get a identifier */
			sk();			/* skip white space */

			if (inif eq 0)
			{
				if (strcmp(rstr, "if") eq 0)
				{
					SYMBOL *s;
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
				APP_LIST *loc = local_list;
				skc();
				curopt = &default_options;
				have_opt = false;
				have_brace = false;
				
				while (loc)
				{
					APP_LIST *nx = loc->next;
					free(loc);
					loc = nx;
				}
				local_list = nil;
	
				continue;			/* while lb = ipff_line */
			}
		
			if (*rstr eq 0)
			{
				err = 1;
				if (lcfg.booting)
					fdisplay(loghandle, true, "line %d: a line must start with a alphanumeric keyword\n", lnr);
			}
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

					new = S.app_options;
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
	
						new->next = S.app_options;
						S.app_options = new;
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
				curopt->naes12 = true,
				set_option(curopt, ONA12);
	#endif
	#if NAES3D
			elif (strcmp(rstr,"naes3d") eq 0)		/* HR 040801 */
				curopt->naes = true,
				set_option(curopt, ONA);
	#endif
			elif (strcmp(rstr,"open") eq 0)			/* HR 250102 */
			{
				if (co == 1)								/* HR 130302 */
				{
					ide(rstr);
					if (strncmp(rstr,"task",4) eq 0)
						open_taskmanager(lock, false);
				}
				else if (co == 2)
				{
					ide(rstr);
					if (strncmp(rstr,"task",4) eq 0)
						cfg.opentaskman = true;
				}
			}
			elif (strcmp(rstr,"windows") eq 0)		/* HR 200801 */
			{
				do {
					ide(rstr);
					if (strcmp(rstr,"nohide") eq 0)
						curopt->nohide = true,
						set_option(curopt, ONOH);
					elif (strcmp(rstr,"noleft") eq 0)		/* HR 250901 */
						curopt->noleft = true,
						set_option(curopt, ONOL);
					elif (strcmp(rstr,"thinframe") eq 0)	/* HR 270901 */
						curopt->thinframe = -1,
						set_option(curopt, OFRAME);
					elif (strcmp(rstr, "thickframe") eq 0)	/* HR 280102 */
						curopt->thinframe = 1,
						set_option(curopt, OFRAME);
					elif (strcmp(rstr,"frame_size") eq 0)
					{
						sk();
						curopt->thinframe = idec();
						set_option(curopt, OFRAME);
					}
					elif (strcmp(rstr,"thinwork") eq 0)	/* HR 270901 */
						curopt->thinwork = true,
						set_option(curopt, OTHINW);
					elif (strcmp(rstr,"live") eq 0)
						curopt->live = true,
						set_option(curopt, OLIVE);

					if (!infix())
						break;
					skc();
				} od
			}
			elif (strcmp(rstr,"wheel") eq 0)		/* HR 111002 */
			{
				do{
					ide(rstr);
					if (strcmp(rstr, "content") eq 0)
						curopt->wheel_reverse = 1,
						set_option(curopt, OWHEEL);
					elif (strcmp(rstr, "pagefactor") eq 0)
					{
						if (sk() eq '=')
							skc();
						curopt->wheel_page = idec();
						set_option(curopt, OWHLPAGE);
					}
					if (!infix())
						break;
					skc();
				} od
			}
			elif (strcmp(rstr,"xa_windows") eq 0)	/* HR 200801 */
			{
				do {
					ide(rstr);
					if (strcmp(rstr, "none") eq 0)
						curopt->xa_none = true,
						set_option(curopt, OXNON);
					elif (strcmp(rstr,"nohide") eq 0)
						curopt->xa_nohide = true,
						set_option(curopt, OXNOH);
					elif (strcmp(rstr,"nomove") eq 0)
						curopt->xa_nomove = true,
						curopt->xa_nohide = true,
						set_option(curopt, OXNOM);
					elif (strcmp(rstr,"noleft") eq 0)		/* HR 250901 */
						curopt->noleft = true,
						set_option(curopt, ONOL);
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
					curopt->windowner = 1,
					set_option(curopt, OWOWN);
				elif (strcmp(rstr,"long") eq 0)
					curopt->windowner = 2,
					set_option(curopt, OWOWN);
				/* default is zero anyway. */
			}
			elif (strcmp(rstr,"menu") eq 0)
			do
			{
				ide(rstr);
				if (strcmp(rstr,"pull") eq 0)
					cfg.menu_behave = PULL;
				elif (strcmp(rstr,"push") eq 0)
					cfg.menu_behave = PUSH;
				elif (strcmp(rstr,"leave") eq 0)
					cfg.menu_behave = LEAVE;
				elif (strcmp(rstr, "nolocking") eq 0)
					cfg.menu_locking = false;
				if (!infix())
					break;
				skc();
			}
			od
			elif (strcmp(rstr,"popscroll") eq 0)
				cfg.popscroll = idec();
			elif (strcmp(rstr,"priority") eq 0)
			{
				int prio = idec();
				if (prio >= -20 and prio <= 20)
					Psetpriority(0, C.AESpid, prio);
			}
			elif (strcmp(rstr,"usehome") eq 0)		/* HR 051002 */
				cfg.usehome = true;
			elif (strcmp(rstr,"font_id") eq 0)
				cfg.font_id = idec();
			elif (strcmp(rstr,"standard_point") eq 0)
				cfg.standard_font_point = idec();
			elif (strcmp(rstr,"medium_point") eq 0)
				cfg.medium_font_point = idec();
			elif (strcmp(rstr,"small_point") eq 0)
				cfg.small_font_point = idec();
	
	/* End of options. */
			elif (strcmp(rstr,"widgets") eq 0)
				fstr(lcfg.widg_name, 0, 0);
			elif (strcmp(rstr,"resource") eq 0)
				fstr(lcfg.rsc_name, 0, 0);
			elif (strcmp(rstr,"run") eq 0)
			{
				if (co)								/* HR 130302 */
				{
					Path path;
		
					fstr(path, 0, 0);
#if ! SEPARATE_SCL
					if (!have_wild(path))
#endif
					{
						sk();
						parms[0] = sdisplay(parms+1,"%s",ipff_getp());
						launch(lock, 0, 0, 0, path, parms, C.Aes);
					}
#if ! SEPARATE_SCL
					else
					{
						Path nm, pattern;
						char *pat, *pbt, fslash[4];
						long i,rep;				
						
						pattern[0] = '*';
						pattern[1] = '\0';
						pat = strrchr(path, bslash);
						pbt = strrchr(path, slash);
						if (!pat) pat = pbt;
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
										if (lcfg.booting)
											fdisplay(loghandle, false, "  --  '%s'\n", fulln);
										launch(lock, 0, 0, 0, fulln, parms, C.Aes);
									}
								}
							}
							Dclosedir(i);
						}
					}
#endif
				}
			}
			elif (   strcmp(rstr,"shell") eq 0
			      or strcmp(rstr,"desk" ) eq 0 )
			{
				if (co)								/* HR 130302 */
				{
					Path p;
		
					fstr(p, 0, 0);
					sk();
					parms[0] = sdisplay(parms+1,"%s",ipff_getp());
					C.DSKpid = launch(lock, 0, 0, 0, p, parms, C.Aes);
					if (C.DSKpid > 0)
						strcpy(C.desk, p);
				}
			}
			elif (strcmp(rstr,"launcher") eq 0)
				fstr(cfg.launch_path, 0, 0);
			elif (strcmp(rstr,"clipboard") eq 0)
				fstr(cfg.scrap_path, 0, 0);
			elif (strcmp(rstr,"accpath") eq 0)
				fstr(cfg.acc_path, 0, 0);
			elif (strcmp(rstr,"dc_time") eq 0)
				lcfg.double_click_time = idec();
#if GENERATE_DIAGS
			elif (strcmp(rstr,"debug_lines") eq 0)
				D.debug_lines = dec();
			elif (strcmp(rstr,"debug") eq 0)
			{
				if (isdigit(sk()))
					D.debug_level = idec();
				else
				{
					char *p = ipff_getp();
					ide(rstr);
					if (strcmp(rstr,"off") eq 0)
						D.debug_level = 0;
					elif (strcmp(rstr,"on") eq 0)
						D.debug_level = 1;		/* This means only the DIAGS macro's (the old ones) */
					elif (strcmp(rstr,"all") eq 0)
					{
						for (i = 0; i < D_max; i++)
							curopt->point[i] = 1;
						if (D.debug_level < 2)
							D.debug_level = 2;
					}
					elif (!D.debug_file)
					{
						ipff_putp(p);
						fstr(D.debug_path, 0, 0);
						if (strnicmp(D.debug_path, "screen", 6) != 0)
						{
							if (lcfg.booting)
								fdisplay(loghandle, true, "Debug to %s\n", D.debug_path);
					
						#if 1		/* HR: Want to see session date / time */
							D.debug_file = (int)Fcreate(D.debug_path, 0);
						#else
							D.debug_file = (int)Fopen(D.debug_path, O_CREAT|O_WRONLY);
						#endif
							Fforce(1, D.debug_file);
						}
					}
				}

				set_option(curopt, ODEBUG);
				if (curopt eq &default_options)
					memmove(D.point, curopt->point, sizeof(D.point));
			}
			/* If specified together with debug all, the meaning is reversed. */

/* HR 081102: Increased intuitivity of debugpoint all except|but x,x,x,x,x,x */

			elif (strcmp(rstr,"debugpoint") eq 0)
			{
				int state = 1;

				if (D.debug_level < 2)
					D.debug_level = 2;
				ide (rstr);
				if (strcmp (rstr,"all"    ) eq 0 )
				{
					state = 1;
					for (i = 0; i < D_max; i++)
						curopt->point[i] = 1;
					sk();
					ide(rstr);
					if (   strcmp (rstr, "except" ) eq 0
					    or strcmp (rstr, "but"    ) eq 0
					   )
					{
						state ^= 1;
						sk();
						ide(rstr);
					}
				}

				do{
					if (strlen(rstr) eq 1 and isalpha(*rstr))
						debugp(D_a + (tolower(*rstr)-'a'),state);
					elif (strncmp(rstr,"appl", 4) eq 0 ) debugp(D_appl, state);
					elif (strcmp (rstr,"evnt"   ) eq 0 ) debugp(D_evnt, state);
					elif (strncmp(rstr,"mult", 4) eq 0 ) debugp(D_multi, state);
					elif (strncmp(rstr,"form", 4) eq 0 ) debugp(D_form, state);
					elif (strncmp(rstr,"fsel", 4) eq 0 ) debugp(D_fsel, state);
					elif (strncmp(rstr,"graf", 4) eq 0 ) debugp(D_graf, state);
					elif (strncmp(rstr,"menu", 4) eq 0 ) debugp(D_menu, state);
					elif (strcmp (rstr,"objc"   ) eq 0 ) debugp(D_objc, state);
					elif (strcmp (rstr,"rsrc"   ) eq 0 ) debugp(D_rsrc, state);
					elif (strcmp (rstr,"scrp"   ) eq 0 ) debugp(D_scrp, state);
					elif (strncmp(rstr,"shel", 4) eq 0 ) debugp(D_shel, state);
					elif (strncmp(rstr,"wind", 4) eq 0 ) debugp(D_wind, state);
					elif (strncmp(rstr,"widg", 4) eq 0 ) debugp(D_widg, state);
					elif (strncmp(rstr,"mous", 4) eq 0 ) debugp(D_mouse,state);
					elif (strncmp(rstr,"butt", 4) eq 0 ) debugp(D_button, state);
					elif (strncmp(rstr,"keyb", 4) eq 0 ) debugp(D_keybd, state);
					elif (strncmp(rstr,"sema", 4) eq 0 ) debugp(D_sema, state);
					elif (strncmp(rstr,"rect", 4) eq 0 ) debugp(D_rect, state);
					elif (strncmp(rstr,"pipe", 4) eq 0 ) debugp(D_pipe, state);
					elif (strncmp(rstr,"trap", 4) eq 0 ) debugp(D_trap, state);
					elif (strncmp(rstr,"kern", 4) eq 0 ) debugp(D_kern, state);
#if WDIAL
					elif (strcmp (rstr,"wdlg"   ) eq 0 ) debugp(D_wdlg, state);
					elif (strncmp(rstr,"lbox", 4) eq 0 ) debugp(D_lbox, state);
#endif
					elif (strcmp (rstr,"this"   ) eq 0 ) debugp(D_this, state);

					if (!infix())
						break;

					skc();
					ide(rstr);
				}od

				set_option(curopt, ODEBUG);
				if (curopt eq &default_options)
					memmove(D.point, curopt->point, sizeof(D.point));

			}
#else
			elif (   strcmp(rstr,"debug") eq 0
			      or strcmp(rstr,"debugpoint") eq 0
			      or strcmp(rstr,"debug_lines") eq 0
			      )
				;		/* Do nothing with this line */
#endif
#if USE_CALL_DIRECT
			elif (strcmp(rstr,"direct") eq 0)
			{
				ide(rstr);
				if (strcmp(rstr,"on") eq 0)
					cfg.direct_call = true;
				else
					cfg.direct_call = false;
			}
#endif
			elif (strncmp(rstr, "half_scr",8) eq 0)
				curopt->half_screen = dec(),				/* HR 170102 */ 
				set_option(curopt, OHALF);
			elif (strcmp(rstr,"cancel") eq 0)
			{
				t = 0;
				do{
					ide(rstr);
					if (strlen(rstr) >= NUM_CB)
						rstr[CB_L - 1] = 0;
					strcpy(cfg.cancel_buttons[t++],rstr);
					if (infix() and t < NUM_CB - 1) skc();	/* last entry kept clear as a stopper */
					else break;
				}od
			}
			elif (strcmp(rstr,"toppage") eq 0)
			{
				ide(rstr);
				if (strcmp(rstr,"bold") eq 0)
					cfg.topname = BOLD, cfg.backname = 0;
				elif (strcmp(rstr,"faint") eq 0)
					cfg.topname = 0,    cfg.backname = FAINT;
			}
			elif (strcmp(rstr,"superprogdef") eq 0)
				cfg.superprogdef = true;
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
					int atok = 0;			/* 0 'is' constant, 1 ':=' variable */
					if (co eq 1)
					{
						atok = assign();
						sk();
						if (atok < 0)
						{
							err = display("needs ':=' or 'is'\n");
							atok = 0;
						}
					} else
					{
						if (sk() eq '=')
							skc();
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
					put_env(lock, 1, 0, p);
				}
			}
#if POINT_TO_TYPE
			elif (strcmp(rstr,"focus") eq 0)
			{
				ide(rstr);
				cfg.point_to_type = strcmp(rstr,"point") eq 0;
			}
#endif
#if FILESELECTOR and defined(FSEL_MENU)
			elif (strcmp(rstr,"filters") eq 0)
			{
				int i = 0;
				while (i < 23)
				{
					fstr(parms, 0, 0);	/* get string */
					parms[15] = 0;
					strcpy(cfg.Filters[i++],parms);
					if (!infix())
						break;
					skc();
				}
			}
#endif
			else
			{
				err = 1;
				if (!co)
					display("line %d: unimplemented keyword '%s'\n", lnr, rstr);
			}
		}
	}


#if GENERATE_DIAGS
	{
		OPT_LIST *op = S.app_options;
		int i;

		err = 1;

		display("Options for:\n");
		while (op)
		{
			display("    '%s'\n", op->name);
			op = op->next;
		}

		list_sym();
	}
#endif

	if (err and co ne 1
		IFDIAG (and !D.debug_file)
		)
	{
		display("hit any key\n");
		bios(2,2);
	}

	if (txt == nil)
		free(cnf);
}
