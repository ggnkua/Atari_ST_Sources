/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "jctype.h"
#include "fp.h"
#include "chars.h"
#include "disp.h"
#include "ask.h"
#include "commands.h"
#include "macros.h"
#include "extend.h"
#include "fmt.h"
/* #include "util.h" */

private void
	pop_macro_stack proto((void));

private struct macro
	*ask_macname proto((const char *, int));

private bool	UnsavedMacros = NO;	/* are there any macros that need saving to a file? */

struct macro	*macros = NULL;		/* macros */
bool	InMacDefine = NO;

private void
add_mac(new)
struct macro	*new;
{
	register struct macro	*mp,
				*prev = NULL;

	for (mp = macros; mp != NULL; prev = mp, mp = mp->m_nextm)
		if (mp == new)
			return;

	if (prev)
		prev->m_nextm = new;
	else
		macros = new;
	new->m_nextm = NULL;
	new->Type = MACRO;
}

/* To execute a macro, we have a "stack" of running macros.  Whenever
   we execute a macro, we push it on the stack, run it, then pop it
   from the stack.  */
struct m_thread {
	struct m_thread	*mt_prev;
	struct macro	*mt_mp;
	int	mt_offset,
		mt_count;
};

private struct m_thread	*mac_stack = NULL;

private struct m_thread *
alloc_mthread()
{
	return (struct m_thread *) emalloc(sizeof (struct m_thread));
}

private void
free_mthread(t)
struct m_thread	*t;
{
	free((UnivPtr) t);
}

void
unwind_macro_stack()
{
	while (mac_stack != NULL)
		pop_macro_stack();
}

private void
pop_macro_stack()
{
	register struct m_thread	*m;

	if ((m = mac_stack) == NULL)
		return;
	mac_stack = m->mt_prev;
	free_mthread(m);
}

private void
push_macro_stack(m, count)
register struct macro	*m;
int	count;
{
	register struct m_thread	*t;

	for (t = mac_stack; t != NULL; t = t->mt_prev)
		if (t->mt_mp == m)
			complain("[Cannot execute macro recusively]");
	if (count <= 0)
		complain("[Cannot execute macro a negative number of times]");
	t = alloc_mthread();
	t->mt_prev = mac_stack;
	mac_stack = t;
	t->mt_offset = 0;
	t->mt_mp = m;
	t->mt_count = count;
}

void
do_macro(mac)
struct macro	*mac;
{
	push_macro_stack(mac, arg_value());
}

private struct macro	KeyMacro = {	/* Macro used for defining */
	MACRO, "keyboard-macro", 0, NULL, NULL
};

private int	kmac_len;
private int	kmac_buflen = 0;

void
mac_init()
{
	add_mac(&KeyMacro);
}

void
mac_putc(c)
char	c;
{
	if (kmac_len >= kmac_buflen) {
		KeyMacro.m_body = erealloc((UnivPtr) KeyMacro.m_body, (size_t) kmac_buflen + 16);
		kmac_buflen += 16;
	}
	KeyMacro.m_body[kmac_len++] = c;
}

void
note_dispatch()
{
	if (kmac_len > 0)
		KeyMacro.m_len = kmac_len - 1;
}

bool
in_macro()
{
	return (mac_stack != NULL);
}

ZXchar
mac_getc()
{
	struct m_thread	*mthread;
	struct macro	*m;

	if ((mthread = mac_stack) == NULL)
		return EOF;
	m = mthread->mt_mp;
	if (mthread->mt_offset == m->m_len) {
		mthread->mt_offset = 0;
		if (--mthread->mt_count == 0)
			pop_macro_stack();
		return mac_getc();
	}
	return ZXC(m->m_body[mthread->mt_offset++]);
}

private void
MacDef(m, name, len, body)
struct macro	*m;	/* NULL, or def to overwrite */
char	*name;	/* must be stable if m isn't NULL */
int	len;
char	*body;
{
	if (m == NULL) {
		m = (struct macro *) emalloc(sizeof *m);
		m->Name = name;
	} else {
		if (m->m_body != NULL)
			free((UnivPtr) m->m_body);
	}
	m->m_len = len;
	if (len == 0) {
		m->m_body = NULL;
	} else {
		m->m_body = emalloc((size_t) len);
		byte_copy(body, m->m_body, (size_t) len);
	}
	add_mac(m);
	if (!InJoverc)
		UnsavedMacros = YES;
}

void
NameMac()
{
	char	*name = NULL;
	struct macro	*m;

	if (KeyMacro.m_len == 0)
		complain("[No keyboard macro to name!]");
	if (in_macro() || InMacDefine)
		complain("[Can't name while defining/executing]");
	if ((m = ask_macname(ProcFmt, ALLOW_OLD | ALLOW_INDEX | ALLOW_NEW)) == NULL)
		name = copystr(Minibuf);
	if (m == &KeyMacro)
		complain("[Can't name it that!]");
	MacDef(m, name, KeyMacro.m_len, KeyMacro.m_body);
}

void
RunMacro()
{
	do_macro((struct macro *) findmac(ProcFmt));
}

private void
pr_putc(c, fp)
ZXchar	c;
File	*fp;
{
	if (c == '\\' || c == '^') {
		f_putc('\\', fp);
		f_putc(c, fp);
	} else {
		char	buf[PPWIDTH];
		char	*p;

		PPchar(c, buf);
		for (p = buf; *p != '\0'; p++)
			f_putc(*p, fp);
	}
}

void
WriteMacs()
{
	struct macro	*m;
	char
		fnamebuf[FILESIZE];
	File	*fp;
	int	i;

	(void) ask_file((char *)NULL, (char *)NULL, fnamebuf);
	fp = open_file(fnamebuf, iobuff, F_WRITE, YES);

	/* Don't write the keyboard macro which is always the first */
	for (m = macros->m_nextm; m != NULL; m = m->m_nextm) {
		fwritef(fp, "define-macro %s ", m->Name);
		for (i = 0; i < m->m_len; i++)
			pr_putc(ZXC(m->m_body[i]), fp);
#ifdef USE_CRLF
		f_putc('\r', fp);
#endif /* USE_CRLF */
		f_putc(EOL, fp);
	}
	close_file(fp);
	UnsavedMacros = NO;
}

void
DefKBDMac()
{
	struct macro	*m = ask_macname(ProcFmt,
		ALLOW_OLD | ALLOW_INDEX | ALLOW_NEW);
	ZXchar	c;
	char
		*macro_name = m == NULL? copystr(Minibuf) : m->Name,
		*macro_body,
		macro_buffer[LBSIZE];
	int	len;

	if (m == &KeyMacro)
		complain("[Can't name it that!]");
	/* ??? I hope that this ask doesn't change *m! */
	macro_body = ask(NullStr, ": %f %s enter body: ", macro_name);
	len = 0;
	while ((c = ZXC(*macro_body++)) != '\0') {
		if (c == '\\' || c == '^')
			c = DecodePair(c, ZXC(*macro_body++));
		if (len >= LBSIZE)
			complain("Macro to large");
		macro_buffer[len++] = c;
	}
	MacDef(m, macro_name, len, macro_buffer);
}

void
Remember()
{
	/* We're already executing the macro; ignore any attempts
	   to define the keyboard macro while we are executing. */
	if (in_macro())
		return;
	if (InMacDefine)
		message("[Already defining ... continue with definition]");
	else {
		UpdModLine = YES;
		InMacDefine = YES;
		kmac_len = KeyMacro.m_len = 0;
		message("Defining...");
	}
}

void
Forget()
{
	UpdModLine = YES;
	if (InMacDefine) {
		message("Keyboard macro defined.");
		InMacDefine = NO;
	} else
		complain("[end-kbd-macro: not currently defining macro!]");
}

void
ExecMacro()
{
	do_macro(&KeyMacro);
}

void
MacInter()
{
	if (Asking)
		Interactive = YES;
}

bool
ModMacs()
{
	return UnsavedMacros;
}

/* Ask for macro name, with completion.
 * Flags is passed directly to complete.  If ALLOW_NEW is on,
 * the name might be new, in which case NULL is returned and the
 * actual name in in Minibuf.
 */

private struct macro *
ask_macname(prompt, flags)
const char	*prompt;
int flags;
{
	char	*strings[100];
	register char	**strs = strings;
	register int	com;
	register struct macro	*m;

	for (m = macros; m != NULL; m = m->m_nextm) {
		if (strs == &strings[elemsof(strings)-1])
			complain("[too many macros]");
		*strs++ = m->Name;
	}
	*strs = NULL;

	if ((com = complete(strings, (char *)NULL, prompt, flags)) < 0)
		return NULL;
	m = macros;
	while (--com >= 0)
		m = m->m_nextm;
	return m;
}

data_obj *
findmac(prompt)
const char	*prompt;
{
	return (data_obj *)ask_macname(prompt, ALLOW_OLD | ALLOW_INDEX);
}
