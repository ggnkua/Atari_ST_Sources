
#define VSPIKE	0
#define VLOOP	1
#define VHOOK	2
#define VMOVE	3
#define VROTATE	4
#define VSIZE	5
#define VCLONE	6
#define VKILL	7
#define VCOLOR	8
#define VBOP	9
#define VZ	10
#define VSAMPLE	11

extern int (*v_table[])();
extern int (*w_table[])();

#define WACTIVATE 0
#define WEDIT	  1
#define WCLONE    2
#define WSPLICE		3
#define WKILL		4
#define WSCISSORS	5


