#include <vdi.h>

int (*save_vec)();
extern void new_code(void);
extern long _ov;

void lbut_init(int handle)
{
	vex_butv(handle,&new_code,&save_vec);
	_ov=(long)save_vec;
}

void lbut_exit(int handle)
{
	vex_butv(handle,save_vec,&new_code);
}
