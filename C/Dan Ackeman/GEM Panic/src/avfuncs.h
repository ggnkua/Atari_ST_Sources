#ifndef _AVFUNCS_H_
#define _AVFUNCS_H_

#define AV_PROTOKOLL		0x4700
#define AV_SENDKEY			0x4710
#define VA_START			0x4711
#define AV_EXIT				0x4736
#define AV_STARTED			0x4738

extern char	*va_helpbuf;

extern void do_help(char *pattern);

extern void start_avsystem(void);
extern void exit_avsystem(void);
extern int send_vastart(char *path, char *cmdline);
extern short get_avserver(void);
extern void send_avprot(void);
extern void send_avexit(void);
extern int send_extmessage(int extapp, int msg0, int msg2, int msg3, int msg4, int msg5, int msg6, int msg7);

#endif