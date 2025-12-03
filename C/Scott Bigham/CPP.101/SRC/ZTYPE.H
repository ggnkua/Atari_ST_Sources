#define Z_ct1 (unsigned char)0x01
#define Z_ct2 (unsigned char)0x02
#define Z_isx (unsigned char)0x03
#define Z_fsx (unsigned char)0x08
#define Z_oct (unsigned char)0x10

extern unsigned char Z_type[];
extern void Z_type_init();

#define is_ctoks(c)	(Z_type[(unsigned char)c]&Z_ct1)
#define is_ctok(c)	(Z_type[(unsigned char)c]&Z_ct2)
#define is_isuff(c)	(Z_type[(unsigned char)c]&Z_isx)
#define is_fsuff(c)	(Z_type[(unsigned char)c]&Z_fsx)
#define is_octal(c)	(Z_type[(unsigned char)c]&Z_oct)
