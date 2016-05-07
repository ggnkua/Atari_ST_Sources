#include "extern.h"

extern DIALOG playopt_dia, mboard_dia;

/* ----------------
	 | Check cookie |
	 ---------------- */
void cookie_chk(void)
{
OBJECT *ausg_tree, *ausg_tree2;
unsigned long val;
int ret, set = ONPSG, set2 = MBPSG;

play_dev = PSG;
rsrc_gaddr(R_TREE, PLAYOPT, &ausg_tree);
rsrc_gaddr(R_TREE, ALLINONE, &ausg_tree2);
playopt_dia.tree = ausg_tree;
mboard_dia.tree = ausg_tree2;

ret = get_cookie('_SND', &val);

if (!ret || !(val & 2))
	{
	ausg_tree[ONDMA].ob_state |= DISABLED;
	ausg_tree2[MBDMA].ob_state |= DISABLED;
	menu_adr[SETMWIRE].ob_state |= DISABLED;
	}
else
	{
	set = ONDMA;
	set2 = MBDMA;
	play_dev = DMA;
	}

if (!ret || !(val & 4))
	{
	ausg_tree[ONCODEC].ob_state |= DISABLED;
	ausg_tree2[MBCODEC].ob_state |= DISABLED;
	}
else
	{
	menu_adr[SETMWIRE].ob_state |= DISABLED;
	set = ONCODEC;
	set2 = MBCODEC;
	play_dev = CODEC;
	falcon_flg = 1;
	}
	
if (ret && !(val & 1))
	{
	ausg_tree[ONPSG].ob_state |= DISABLED;
	ausg_tree2[MBPSG].ob_state |= DISABLED;
	}

ausg_tree[set].ob_state |= SELECTED;
ausg_tree2[set2].ob_state |= SELECTED;

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
