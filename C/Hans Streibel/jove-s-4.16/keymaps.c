/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "list.h"
#include "fp.h"
#include "jctype.h"
#include "chars.h"
#include "disp.h"
#include "re.h"
#include "ask.h"
#include "commands.h"
#include "macros.h"
#include "extend.h"
#include "fmt.h"
#include "screen.h"		/* for Placur */
#include "vars.h"

#ifdef IPROCS
# include "sysprocs.h"	/* this and below ... */
# include "iproc.h"	/* ... for definition of ProcNewline() */
#endif

#ifdef PCNONASCII
private const char *const altseq[] = {
/*000*/NULL, "Alt Esc", NULL, "Ctl-@", NULL, NULL, NULL, "Ctl-^",
/*010*/NULL, NULL, NULL, NULL, "Ctl-_", "Enter", "Alt-Bksp", "Left",
/*020*/"Alt-Q", "Alt-W", "Alt-E", "Alt-R", "Alt-T", "Alt-Y", "Alt-U", "Alt-I",
/*030*/"Alt-O", "Alt-P", "Alt-[", "Alt-]", "Alt-Enter", NULL, "Alt-A", "Alt-S",
/*040*/"Alt-D", "Alt-F", "Alt-G", "Alt-H", "Alt-J", "Alt-K", "Alt-L", "Alt-;",
/*050*/"Alt-'", "Alt-~", NULL, "Alt-\\", "Alt-Z", "Alt-X", "Alt-C", "Alt-V",
/*060*/"Alt-B", "Alt-N", "Alt-M", "Alt-,", "Alt-.", "Alt-/", NULL, "Alt KP-",
/*070*/NULL, NULL, NULL, "F1", "F2", "F3", "F4", "F5",
/*100*/"F6", "F7", "F8", "F9", "F10", NULL, NULL, "Home",
/*110*/"Up", "PgUp", "Alt KP-", "Left", "Shift KP5", "Right", "Alt KP+", "End",
/*120*/"Down", "PgDn", "Ins", "Del", "Shift F1", "Shift F2", "Shift F3", "Shift F4",
/*130*/"Shift F5", "Shift F6", "Shift F7", "Shift F8", "Shift F9", "Shift F10", "Ctl F1", "Ctl F2",
/*140*/"Ctl F3", "Ctl F4", "Ctl F5", "Ctl F6", "Ctl F7", "Ctl F8", "Ctl F9", "Ctl F10",
/*150*/"Alt F1", "Alt F2", "Alt F3", "Alt F4", "Alt F5", "Alt F6", "Alt F7", "Alt F8",
/*160*/"Alt F9", "Alt F10", "Ctl PrtSc", "Ctl Left", "Ctl Right", "Ctl End", "Ctl PgDn", "Ctl Home",
/*170*/"Alt 1", "Alt 2", "Alt 3", "Alt 4", "Alt 5", "Alt 6", "Alt 7", "Alt 8",
/*200*/"Alt 9", "Alt 0", "Alt Minus", "Alt Equals", "Ctl PgUp", "F11", "F12", "Shift F11",
/*210*/"Shift F12", "Ctl F11", "Ctl F12", "Alt F11", "Alt F12", "Ctl Up", "Ctl KP-", "Ctl KP5",
/*220*/"Ctl KP+", "Ctl Down", "Ctl Ins", "Ctl Del", "Ctl Tab", "Ctl KP/", "Ctl KP*", "Alt Home",
/*230*/"Alt Up", "Alt PgUp", NULL, "Alt Left", NULL, "Alt Right", NULL, "Alt End",
/*240*/"Alt Down", "Alt PgDn", "Alt Ins", "Alt Del", "Alt KP/", "Alt Tab", "Alt KP Enter", NULL,
/*250*/NULL, NULL, NULL, "Shift Home", "Shift Up", "Shift PgUp", "Shift Alt KP-", "Shift Left",
/*260*/"Shift KP5", "Shift Right", "Shift Alt KP+", "Shift End", "Shift Down", "Shift PgDn", "Shift Ins", "Shift Del"
};
#endif	/* PCNONASCII */

int this_cmd, last_cmd;

/*
 * A data_obj can be a command, a macro, a variable or a keymap. So a keymap
 * can be bound to a key just like commands, macros and variables can.  Users
 * don't bind keymaps to keys, though, they just bind the other things to
 * keys, and this package automatically creates keymaps as they are needed to
 * accomodate the specified key sequences.
 *
 * NOTE: Since users don't bind keymaps to keys, there is no reason for keymaps
 * to have names.  Right now they do, but perhaps that can be fixed later. At
 * least the names need not be made visible.
 */

/*
 * A keymap is either a sparse keymap or a full keymap.  The main keymap as
 * well as escape and control X maps are full maps, because they are almost
 * full.  All other keymaps that the system creates on behalf of users in
 * order to accomodate an arbitrary key binding will be sparse maps, on the
 * theory that they will be pretty small.  Sparse keymaps are sorted.
 */

#define	KEYMAP_QUANTUM	8	/* sparse keymap allocation batch size */
#define	SPARSE_LIMIT	(NCHARS/3 - KEYMAP_QUANTUM)	/* threshold for conversion */

struct keybinding {
	ZXchar	key;
	data_obj	*value;
};

struct keymap {
	int	Type;		/* keymap type (sparse or full) */
	char	*Name;		/* keymap name */
	struct keymap	*next_map;
	bool	unfreeable;
	bool	mark;	/* used for cycle avoidance */
	union {
		struct {
			data_obj **map;	/* keys array indexed by key */
		} full;
		struct {
			struct keybinding	*bindings;
			short nused;	/* number of keybindings used */
			short nalloc;	/* number of keybindings allocated */
		} sparse;
	} u;
};

#define IsKeymap(/* data_obj* */ o)	((o) != NULL && \
			 ((o)->Type == FULL_KEYMAP || \
			  (o)->Type == SPARSE_KEYMAP))

private struct keymap	*keymaps = NULL;		/* list of all keymaps */

private struct keymap *mainmap;

#ifdef IPROCS
private struct keymap *procsmap;
#endif

/*
 * Make a new keymap.  Type is either FULL_KEYMAP or SPARSE_KEYMAP. If it's
 * full, the keys is either NULL or a pointer to a valid keymap of length
 * NCHARS.
 */

private void
km_init(km, kind, keys)
struct keymap *km;
int kind;
data_obj **keys;
{
	byte_zero((UnivPtr) &km->u, sizeof(km->u));	/* zero integral fields */
	if ((km->Type = kind) == FULL_KEYMAP) {
		if (keys == NULL) {
			data_obj	**p;

			keys = (data_obj **) emalloc(NCHARS * sizeof(data_obj *));
			p = &keys[NCHARS];
			do *--p = NULL; while (p != keys);
		} else {
			km->unfreeable = YES;
		}
		km->u.full.map = keys;
	} else {
		km->u.sparse.bindings = NULL;
	}
}

private struct keymap *
km_new(kind, keys, name)
int kind;
data_obj **keys;
char	*name;
{
	struct keymap	*km = (struct keymap *) emalloc(sizeof(struct keymap));

	km->Name = name;
	km->next_map = keymaps;
	keymaps = km;
	km->unfreeable = NO;	/* provisional */
	km_init(km, kind, keys);
	return km;
}

/* km_getkey: look up key in keymap
 *
 * If the keymap is sparse, km_getkey sets km_sparsepos to the index
 * of the entry found (if any), or the index of the entry which would
 * be its successor (if not found).
 */

private int	km_sparsepos;

private data_obj *
km_getkey(km, key)
struct keymap *km;
ZXchar key;
{
	if (km->Type == FULL_KEYMAP) {
		return (km->u.full.map[key]);
	} else {
		struct keybinding	*b = km->u.sparse.bindings;
		int	lwb = 0;	/* closed lower bound */
		int upb = km->u.sparse.nused;	/* open upper bound */

		for (;;) {
			int mid = (lwb + upb) >> 1;	/* fast average */

			if (mid == lwb)
				break;
			if (b[mid].key <= key)
				lwb = mid;
			else
				upb = mid;
		}
		if (lwb != upb) {
			if (b[lwb].key == key) {
				/* found */
				km_sparsepos = lwb;
				return b[lwb].value;
			}
			if (b[lwb].key > key)
				upb = lwb;	/* make upb tight */
		}
		/* not found; insertion would be before upb */
		km_sparsepos = upb;
		return NULL;
	}
}

private ZXchar
km_nextkey(km, key)
struct keymap *km;
ZXchar key;
{
	if (km->Type == FULL_KEYMAP) {
		while (key != NCHARS && km->u.full.map[key] == NULL)
			key++;
	} else {
		(void) km_getkey(km, key);
		key = km_sparsepos == km->u.sparse.nused
			? NCHARS : km->u.sparse.bindings[km_sparsepos].key;
	}
	return key;
}

/* Free a dataobj reference formerly bound in or as a keymap.
 * At the present time, only values that represent keymaps
 * can be usefully freed, and only those that are not marked as
 * unfreeable.  unfreeable ones have other references (mainmap
 * or procsmap), or they include a non-heap (static) allocation.
 */

void
DelObjRef(value)
data_obj	*value;
{
	if (IsKeymap(value)) {
		struct keymap	*km = (struct keymap *)value;

		if (!km->unfreeable) {
			ZXchar	k;

			for (k = 0; (k = km_nextkey(km, k)) != NCHARS; k++)
				DelObjRef(km_getkey(km, k));

			switch (km->Type) {
			case FULL_KEYMAP:
				free((UnivPtr) km->u.full.map);
				break;
			case SPARSE_KEYMAP:
				free((UnivPtr) km->u.sparse.bindings);
				break;
			}
			{
				/* remove km from list of all keymaps */
				struct keymap	**p;

				for (p = &keymaps; *p != km; p = &(*p)->next_map)
					;
				*p = (*p)->next_map;
			}
			free((UnivPtr) km);
		}
	}
}

private void
km_setkey(km, key, d)
struct keymap *km;
ZXchar key;
data_obj *d;
{
	if (km->Type == FULL_KEYMAP) {
		DelObjRef(km->u.full.map[key]);
		km->u.full.map[key] = d;
	} else {
		struct keybinding	*b = km->u.sparse.bindings;
		int nused = km->u.sparse.nused;

		if (km_getkey(km, key) != NULL) {
			/* overwriting a binding */
			int	i = km_sparsepos;

			DelObjRef(b[i].value);	/* note: overwrites km_sparsepos */
			if (d == NULL) {
				/* overwriting with NULL is actually deleting an entry */
				while (++i < nused)
					b[i-1] = b[i];
				km->u.sparse.nused -= 1;
			} else {
				b[i].value = d;
			}
		} else if (d != NULL) {
			/* inserting a new binding. */
			if (nused == km->u.sparse.nalloc) {
				/* grow the keymap */
				if (nused >= SPARSE_LIMIT) {
					/* convert to full keymap (in place!) */
					km_init(km, FULL_KEYMAP, (data_obj **) NULL);
					while (nused-- != 0)
						km->u.full.map[b[nused].key] = b[nused].value;
					free((UnivPtr) b);
					km->u.full.map[key] = d;
					return;
				} else {
					km->u.sparse.bindings = b = (struct keybinding *) erealloc(
						(UnivPtr) km->u.sparse.bindings,
						(km->u.sparse.nalloc += KEYMAP_QUANTUM)
							* sizeof(struct keybinding));
				}
			}
			km->u.sparse.nused += 1;
			for (; nused > km_sparsepos; nused--)
				b[nused] = b[nused-1];
			b[km_sparsepos].key = key;
			b[km_sparsepos].value = d;
		}
	}
}

private void
UnmarkMaps()
{
	struct keymap	*km;

	for (km = keymaps; km != NULL; km = km->next_map)
		km->mark = NO;
}

/* get the currently active keymaps into km_buf */

#define MAX_KEYMAPS	3	/* bound on number of keymaps found by get_keymaps */

private int
get_keymaps(km_buf)
struct keymap **km_buf;
{
	int nmaps = 0;

	/* add maps to array in order of decreasing priority (and specificity) */

	if (curbuf->b_map != NULL)
		km_buf[nmaps++] = curbuf->b_map;

#ifdef IPROCS
	if (curbuf->b_process != NULL)
		km_buf[nmaps++] = procsmap;
#endif

	km_buf[nmaps++] = mainmap;

	return nmaps;
}

bool
IsPrefixChar(c)
ZXchar	c;
{
	return IsKeymap(km_getkey(mainmap, c));
}

private struct keymap *
GetKeymap(m, key)
struct keymap *m;
ZXchar key;
{
	data_obj *val = km_getkey(m, key);

	return IsKeymap(val)? (struct keymap *) val : (struct keymap *) NULL;
}

private data_obj *
findmap(fmt)
const char	*fmt;
{
	struct keymap	*km;
	char	*strings[128];
	int	i;

	for (km = keymaps, i = 0; km != NULL; km = km->next_map)
		if (i < (int) elemsof(strings) - 1 && km->Name != NULL)
			strings[i++] = km->Name;
	strings[i] = NULL;

	i = complete(strings, (char *)NULL, fmt, ALLOW_OLD | ALLOW_INDEX);

	for (km = keymaps; ; km = km->next_map) {
		if (km->Name != NULL && i-- == 0) {
			km->unfreeable = YES;
			return (data_obj *) km;
		}
	}
}

private void
BindSequence(m, keys, k_len, obj)
struct keymap *m;
char *keys;
int k_len;
data_obj *obj;
{
	int i;

	if (k_len == 0)
		complain("can't bind empty key sequence");
	for (i = 0; i < k_len - 1; i++) {
		struct keymap *submap = GetKeymap(m, ZXC(keys[i]));

		if (submap == NULL) {
			submap = km_new(SPARSE_KEYMAP, (data_obj **)NULL, (char *)NULL);
			km_setkey(m, ZXC(keys[i]), (data_obj *) submap);
		}
		m = submap;
	}
	km_setkey(m, ZXC(keys[i]), obj);
#ifdef MAC
	/* info for About Jove ... */
	if (obj != NULL && obj_type(obj) == COMMAND) {
		struct cmd	*cmd = (struct cmd *) obj;
		char	map = 0;

		if (m->Type == FULL_KEYMAP) {
			if (m->u.full.map == MainKeys)
				map = F_MAINMAP;
			else if (m->u.full.map == EscKeys)
				map = F_PREF1MAP;
			else if (m->u.full.map == CtlxKeys)
				map = F_PREF2MAP;
		}
		if (map != 0) {
			cmd->c_map = map;
			cmd->c_key = ZXC(keys[i]);	/* see about_j() in mac.c */
		}
	}
#endif
}

private void
DoBind(findproc, map)
data_obj *(*findproc) ptrproto((const char *));
struct keymap *map;
{
	data_obj *d = (*findproc) (ProcFmt);
	char keys[64];
	int i;
	struct keymap *m;

	s_mess(": %f %s ", d->Name);
	if (obj_type(d) == COMMAND && ((struct cmd *)d)->c_proc == Unbound)
		d = NULL;
	i = 0;
	m = map;
	for (;;) {
		ZXchar c = addgetc();

		if (c == EOF)
			break;
		if (i == sizeof(keys) - 1)
			complain("key sequence too long");
		keys[i++] = c;
		if (!InJoverc) {
			if (is_an_arg()) {
				/* Disgusting hack to allow more interactive power.
				 * This ought to be replaced by a cleaner mechanism.
				 */
				if (c == '\r' || c == '\n') {
					i -= 1;
					break;
				}
				if (c == '\\')
					keys[i-1] = addgetc();
			} else {
				if ((m = GetKeymap(m, c)) == NULL)
					break;
			}
		}
	}
	BindSequence(map, keys, i, d);
}

private void
DoLBind(findproc)
data_obj *(*findproc) ptrproto((const char *));
{
	if (curbuf->b_map == NULL)
		curbuf->b_map = km_new(SPARSE_KEYMAP, (data_obj **)NULL, (char *)NULL);
	DoBind(findproc, curbuf->b_map);
}

/* bind a command to a key in the buffer's local keymap. */
void
LBindAKey()
{
	DoLBind(findcom);
}

/* bind a macro to a key in the buffers local keymap. */
void
LBindMac()
{
	DoLBind(findmac);
}

void
LBindMap()
{
	DoLBind(findmap);
}

void
BindAKey()
{
	DoBind(findcom, mainmap);
}

void
BindMac()
{
	DoBind(findmac, mainmap);
}

void
BindMap()
{
	DoBind(findmap, mainmap);
}

#ifdef IPROCS

void
PBindAKey()
{
	DoBind(findcom, procsmap);
}

void
PBindMac()
{
	DoBind(findmac, procsmap);
}

void
PBindMap()
{
	DoBind(findmap, procsmap);
}

#endif

void
Unbound()
{
	complain("%f");
}

void
KeyDesc()
{
	struct keymap *maps[MAX_KEYMAPS];
	int nmaps;

	nmaps = get_keymaps(maps);
	s_mess(ProcFmt);
	while (YES) {
		int i;
		bool	still_hope = NO;
		ZXchar	key = addgetc();

		for (i = 0; i < nmaps; i++) {
			if (maps[i] != NULL) {
				data_obj *cp = km_getkey(maps[i], key);

				if (cp != NULL) {
					if (!IsKeymap(cp)) {
						add_mess("is bound to %s.", cp->Name);
						stickymsg = YES;
						return;
					}
					still_hope = YES;
				}
				maps[i] = (struct keymap *) cp;
			}
		}
		if (!still_hope)
			break;
	}
	add_mess("is unbound.");
}

private void
DescMap(map, pref)
struct keymap *map;
char *pref;
{
	if (map != NULL && !map->mark) {
		ZXchar	c1, c2;

		map->mark = YES;
		for (c1 = km_nextkey(map, 0); c1 < NCHARS; c1 = km_nextkey(map, c2 + 1)) {
			data_obj	*c1obj = km_getkey(map, c1);
			char keydescbuf[40];

			c2 = c1;
			do; while (++c2 < NCHARS && c1obj == km_getkey(map, c2));
			c2 -= 1;
			swritef(keydescbuf, sizeof(keydescbuf),
				c1 == c2 ? "%s %p" : c1 + 1 == c2 ? "%s {%p,%p}" : "%s [%p-%p]",
				pref, c1, c2);
			if (IsKeymap(c1obj)) {
#ifdef PCNONASCII
				/* horrible kludge to handle PC non-ASCII keys */
				if (c1 == PCNONASCII) {
					ZXchar	pc;
					struct keymap	*pcm = (struct keymap *)c1obj;

					c2 = c1;	/* don't handle range */
					for (pc = km_nextkey(pcm, 0); pc < NCHARS; pc = km_nextkey(pcm, pc + 1)) {
						data_obj	*pcobj = km_getkey(pcm, pc);
						const char	*as = pc < elemsof(altseq)? altseq[pc] : NULL;
						char pckeydescbuf[40];

						if (as == NULL)
							swritef(pckeydescbuf, sizeof(pckeydescbuf),
								"%s %p %p", pref, PCNONASCII, pc);
						else
							swritef(pckeydescbuf, sizeof(pckeydescbuf),
								"%s %s", pref, as);
						if (IsKeymap(pcobj))
							DescMap((struct keymap *)pcobj, pckeydescbuf);
						else
							Typeout("%-18s %s", pckeydescbuf, pcobj->Name);
					}
					continue;
				}
#endif /* PCNONASCII */
				DescMap((struct keymap *)c1obj, keydescbuf);
			} else {
				Typeout("%-18s %s", keydescbuf, c1obj->Name);
			}
		}
		map->mark = NO;
	}
}

void
DescBindings()
{
	TOstart("Key Bindings");
	UnmarkMaps();
	DescMap(mainmap, NullStr);
	DescMap(curbuf->b_map, "Local:");
#ifdef IPROCS
	DescMap(procsmap, "Proc:");
#endif
	TOstop();
}

private char *
fb_aux(cp, map, prefix, buf, room)
register data_obj	*cp;
struct keymap	*map;
char	*prefix,
	*buf;
size_t	room;
{
	char	*bufp = buf;

	if (map != NULL && !map->mark) {
		ZXchar	c1, c2;

		map->mark = YES;
		for (c1 = km_nextkey(map, 0); c1 < NCHARS; c1 = km_nextkey(map, c2 + 1)) {
			data_obj	*c1obj = km_getkey(map, c1);

			c2 = c1;
			if (c1obj == cp) {
				do ; while (++c2 < NCHARS && c1obj == km_getkey(map, c2));
				c2 -= 1;
				swritef(bufp, room - (bufp-buf),
					c1==c2? "%s%p, " : c1+1==c2? "%s{%p,%p}, " : "%s[%p-%p], ",
					prefix, c1, c2);
				bufp += strlen(bufp);
			}
			if (IsKeymap(c1obj)) {
				char	prefbuf[20];

#ifdef PCNONASCII
				/* horrible kludge to handle PC non-ASCII keys */
				if (c1 == PCNONASCII) {
					struct keymap	*pcm = (struct keymap *)c1obj;
					ZXchar	pc;

					c2 = c1;	/* don't handle range */
					for (pc = km_nextkey(pcm, 0); pc < NCHARS; pc = km_nextkey(pcm, pc + 1)) {
						const char	*as = pc < elemsof(altseq)? altseq[pc] : NULL;
						data_obj	*pcobj = km_getkey(pcm, pc);

						if (pcobj == cp) {
							if (as == NULL)
								swritef(bufp, room - (bufp-buf),
									"%s%p %p, ", prefix, PCNONASCII, pc);
							else
								swritef(bufp, room - (bufp-buf),
									"%s%s, ", prefix, as);
							bufp += strlen(bufp);
						}
						if (IsKeymap(pcobj)) {
							if (as == NULL)
								swritef(prefbuf, sizeof(prefbuf),
									"%s%p %p ", prefix, PCNONASCII, pc);
							else
								swritef(prefbuf, sizeof(prefbuf),
									"%s%s ", prefix, as);
							bufp = fb_aux(cp, (struct keymap *) pcobj,
								prefbuf, bufp, room-(bufp-buf));
						}
					}
					continue;
				}
#endif /* PCNONASCII */
				swritef(prefbuf, sizeof(prefbuf), "%s%p ", prefix, c1);
				bufp = fb_aux(cp, (struct keymap *) c1obj, prefbuf, bufp,
					room-(bufp-buf));
			}
		}
		map->mark = NO;
	}
	return bufp;
}

private void
find_binds(dp, buf, size)
data_obj *dp;
char *buf;
size_t size;
{
	char	*endp;

	UnmarkMaps();
	buf[0] = '\0';
	endp = fb_aux(dp, mainmap, NullStr, buf, size);
	endp = fb_aux(dp, curbuf->b_map, "Local:", endp, size - (endp - buf));
#ifdef IPROCS
	endp = fb_aux(dp, procsmap, "Proc:", endp, size - (endp - buf));
#endif
	if ((endp > buf+2) && (strcmp(endp-2, ", ") == 0))
		endp[-2] = '\0';
}

private void
ShowDoc(doc_type, dp, show_bindings)
char *doc_type;
data_obj *dp;
bool show_bindings;
{
	char pattern[100];
	char	CmdDb[FILESIZE];	/* path for cmds.doc */
	File *fp;

	swritef(CmdDb, sizeof(CmdDb), "%s/cmds.doc", ShareDir);
	fp = open_file(CmdDb, iobuff, F_READ, YES);
	Placur(ILI, 0);
	flushscreen();
	swritef(pattern, sizeof(pattern), "^:entry \"%s\" \"%s\"$",
		dp->Name, doc_type);
	TOstart("Help");
	for (;;) {
		if (f_gets(fp, genbuf, (size_t) LBSIZE)) {
			Typeout("There is no documentation for \"%s\".", dp->Name);
			break;
		}
		if (genbuf[0] == ':' && LookingAt(pattern, genbuf, 0)) {
			/* found it ... let's print it */
			static const char entrystr[] = ":entry";

			if (show_bindings) {
				char binding[128];

				find_binds(dp, binding, sizeof(binding));
				if (blnkp(binding)) {
					Typeout("To invoke %s, type \"ESC X %s<cr>\".",
						dp->Name, dp->Name);
				} else {
					Typeout("Type \"%s\" to invoke %s.",
						binding, dp->Name);
				}
			} else
				Typeout("%s", dp->Name);
			Typeout(NullStr);
			while (!f_gets(fp, genbuf, (size_t) LBSIZE)
					&& strncmp(genbuf, entrystr, sizeof(entrystr) - 1) != 0)
				Typeout("%s", genbuf);
			break;
		}
	}
	f_close(fp);
	TOstop();
}

void
DescCom()
{
	ShowDoc("Command", findcom(ProcFmt), YES);
}

void
DescVar()
{
	ShowDoc("Variable", findvar(ProcFmt), NO);
}

void
Apropos()
{
	register const struct cmd *cp;
	register struct macro *m;
	register const struct variable *v;
	char *ans;
	bool
		anyfs = NO,
		anyvs = NO,
		anyms = NO;
	char buf[MAXCOLS];

	ans = ask((char *) NULL, ": %f (keyword) ");
	if (strcmp(ans, "?") == 0)
		ans = NullStr;	/* matches everything */
	TOstart("Help");
	for (cp = commands; cp->Name != NULL && !TOabort; cp++)
		if (sindex(ans, cp->Name)) {
			if (!anyfs) {
				anyfs = YES;
				Typeout("Commands");
				Typeout("--------");
			}
			find_binds((data_obj *) cp, buf, sizeof(buf));
			if (buf[0] != '\0')
				Typeout(": %-35s (%s)", cp->Name, buf);
			else
				Typeout(": %s", cp->Name);
		}
	for (v = variables; v->Name != NULL && !TOabort; v++)
		if (sindex(ans, v->Name)) {
			if (!anyvs) {
				anyvs = YES;
				if (anyfs)
					Typeout(NullStr);
				Typeout("Variables");
				Typeout("---------");
			}
			vpr_aux(v, buf, sizeof(buf));
			Typeout(": set %-26s %s", v->Name, buf);
		}
	for (m = macros; m != NULL && !TOabort; m = m->m_nextm)
		if (sindex(ans, m->Name)) {
			if (!anyms) {
				anyms = YES;
				if (anyfs || anyvs)
					Typeout(NullStr);
				Typeout("Macros");
				Typeout("------");
			}
			find_binds((data_obj *) m, buf, sizeof(buf));
			if (buf[0])
				Typeout(": %-35s (%s)", m->Name, buf);
			else
				Typeout(": %s", m->Name);
		}
	TOstop();
}

void
InitKeymaps()
{
	struct keymap *km;

	mainmap = km_new(FULL_KEYMAP, MainKeys, "global-map");

	/* setup ESC map */
	km = km_new(FULL_KEYMAP, EscKeys, "ESC-map");
	km_setkey(mainmap, ESC, (data_obj *) km);

	/* setup Ctlx map */
	km = km_new(FULL_KEYMAP, CtlxKeys, "CtlX-map");
	km_setkey(mainmap, CTL('X'), (data_obj *) km);

#ifdef  PCNONASCII
	km = km_new(FULL_KEYMAP, NonASCIIKeys, "non-ASCII-map");
	km_setkey(mainmap, PCNONASCII, (data_obj *) km);
#endif

#ifdef IPROCS
	procsmap = km_new(SPARSE_KEYMAP, (data_obj **) NULL, "process-map");
	procsmap->unfreeable = YES;
	BindSequence(procsmap, "\r", 1, (data_obj *) FindCmd(ProcNewline));
#endif
}

/*
 * Dispatch a character.  If the specified character maps to a sub keymap,
 * this routine reads more characters until (1) a command is found, or (2) an
 * unbound key error occurs.  Callers of this routine can be assured that it
 * won't return before completing a key sequence.
 */
void
dispatch(c)
ZXchar c;
{
	struct keymap *maps[MAX_KEYMAPS];
	int nmaps;

	if (InMacDefine)
		note_dispatch();
	this_cmd = OTHER_CMD;
	nmaps = get_keymaps(maps);

	while (YES) {
		int	i;
		bool	still_hope = NO;

		for (i = 0; i < nmaps; i++) {
			if (maps[i] != NULL) {
				data_obj *cp = km_getkey(maps[i], c);

				if (cp != NULL) {
					if (!IsKeymap(cp)) {
						ExecCmd(cp);
						return;
					}
					still_hope = YES;
				}
				maps[i] = (struct keymap *) cp;
			}
		}
		if (!still_hope) {
			char strokes[128];

			pp_key_strokes(strokes, sizeof(strokes));
			s_mess("[%sunbound]", strokes);
			rbell();
			clr_arg_value();
			stickymsg = NO;
			break;
		}
		c = waitchar();
		if (c == AbortChar) {
			message("[Aborted]");
			rbell();
			break;
		}
	}
}
