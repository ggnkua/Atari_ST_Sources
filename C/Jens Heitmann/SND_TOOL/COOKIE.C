#include "extern.h"

/* ----------------
	 | Check cookie |
	 ---------------- */
void cookie_chk(void)
{
OBJECT *ausg_tree;
unsigned long val;
int ret, set = OP_PSG;

play_mode = PSG;
rsrc_gaddr(R_TREE, AUSG_SEL, &ausg_tree);
ret = get_cookie('_SND', &val);

if (!ret || !(val & 2))
	{
	ausg_tree[OP_DMA].ob_state |= DISABLED;
	ausg_tree[OT_DMA].ob_state |= DISABLED;
	menu_adr[SET_MW].ob_state |= DISABLED;
	}
else
	{
	set = OP_DMA;
	play_mode = DMA;
	send_mwire();
	}

if (ret && !(val & 1))
	{
	ausg_tree[OP_PSG].ob_state |= DISABLED;
	ausg_tree[OT_PSG].ob_state |= DISABLED;
	}
ausg_tree[set].ob_state |= SELECTED;

if (get_cookie('_CPU', &cpu_type))
	cpu_type += 68000L;

get_cookie('_MCH', &machine);
}

/* --------------------
	 | Get cookie value |
	 -------------------- */
int get_cookie(unsigned long cookie, unsigned long *value)
{
long old_stack;
long *jar;

old_stack=Super(0L);
jar = *((long **)0x5a0L);
Super((void *)old_stack);

if (!jar)
	return 0;

do
	{
	if (*jar == cookie)
		{
		if (value)
			*value=jar[1];

		return 1;
		}
	else
		jar= &(jar[2]);

	}while(*jar);

return 0;
}
