
#ifndef _XGRIFF_H
#define _XGRIFF_H

#ifdef __TURBOC__

#define playflag _playflag
extern short _playflag;
#define xgetcookie(a,b) _xgetcookie(a,b)
int cdecl _xgetcookie(long cookie, long *value);
#define mod_init _mod_init
int _mod_init(void);
#define mod_play(a) _mod_play(a)
int cdecl _mod_play(void *modaddr);
#define mod_stop _mod_stop
void _mod_stop(void);
#define mod_backward _mod_backward
void _mod_backward(void);
#define mod_forward _mod_forward
void _mod_forward(void);
#define mod_setup(a,b) _mod_setup(a,b)
void cdecl _mod_setup(short typ, long value);
#define checkbuf _checkbuf
void _checkbuf(void);

#else

extern short playflag;
int cdecl xgetcookie(long cookie, long *value);
int mod_init(void);
int cdecl mod_play(void *modaddr);
void mod_stop(void);
void mod_backward(void);
void mod_forward(void);
void cdecl mod_setup(short typ, long value);
void checkbuf(void);

#endif

#endif
