
/* 
 * you have to define a long constant
 * _MY_MAGIC "MAGI"
 * to identify your program
 * 
 */

#ifndef _XBRA_H
#define _XBRA_H

typedef void	(*xptr)();

typedef struct _Xbra
{
  long	xbra_magic;
  long	my_magic;
  xptr	next;
  short	jump;
  void	(*this) ();
}	XBRA_STRUCT;

#define _XBRA_MAGIC	0x58425241L /* "XBRA" */
//#define _MY_MAGIC	0x00000000
#define _JMP_OPCODE	0x4EF9
#define _JSR_OPCODE	0x4EB9

#define _XBRA_VEC(x)	( (void (*)()) &(x.jump) )

#define _XBRA_INIT(fn)	{		   \
			   _XBRA_MAGIC,    \
			   _MY_MAGIC,    \
			   (xptr) 0,       \
			   _JMP_OPCODE,    \
			   (void (*)()) fn \
			}

#define _TRAP_VEC(n,x)	((void (*) ()) (((long) n << 24) | (long) &(x.jump)))

#define _TRAP_INIT(fn)	{		   \
			   _XBRA_MAGIC,    \
			   _MY_MAGIC,    \
			   (xptr) 0,       \
			   _JSR_OPCODE,    \
			   (void (*)()) fn \
			}
#endif /* _XBRA_H */
