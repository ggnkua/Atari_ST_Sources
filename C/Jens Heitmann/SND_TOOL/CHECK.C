#include "extern.h"

/* --------------------------
	 | Give sample statistics |
	 -------------------------- */
void check_sample(void)
{
OBJECT *chk_fm;
long i, l, f, m;
char c, c1;

rsrc_gaddr(R_TREE, CHECK_FM, &chk_fm);

m = l = f = 0;
c1 = 0;
for (i = 0; i < total; i++)
	{
	c = o_bytes[i];
	if (c == -128 || c == 127)
		{
		l++;
		
		if (c1 == c)
			m++;
		else
			{
			if (m > f)
				f = m;
			m = 1;
			}
		}
	else
		{
		if (m > f)
			f = m;
		m = 0;
		}
	c1 = c;
	}
	
if (m > f)
	f = m;
		
ltoa(total, chk_fm[SMP_LEN].ob_spec.free_string, 10);
ltoa(l, chk_fm[SMP_MAX].ob_spec.free_string, 10);
ltoa(f, chk_fm[SMP_FOLL].ob_spec.free_string, 10);
  
dialog(chk_fm);
}
