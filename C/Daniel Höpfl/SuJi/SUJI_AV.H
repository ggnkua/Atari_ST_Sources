#ifndef __DH_SUJI_AV_H_
#define __DH_SUJI_AV_H_

#define AV_PROTOKOLL	0x4700#define VA_PROTOSTATUS	0x4701#define VA_START		0x4711#define AV_EXIT			0x4736#define AV_SENDKEY		0x4710#define VA_FILEFONT		0x4713#define AV_ASKFILEFONT	0x4712#define VA_FONTCHANGED	0x4739#define AV_OPENWIND		0x4720#define VA_WINDOPEN		0x4721#define AV_XWIND		0x4740#define VA_XOPEN		0x4741#define AV_SENDCLICK	0x4709#define AV_STARTPROG	0x4722#define VA_PROGSTART	0x4723#define AV_VIEW			0x4751#define VA_VIEWED		0x4752#define AV_FILEINFO		0x4753#define VA_FILECHANGED	0x4754#define AV_STARTED		0x4738#define AV_DRAG_ON_WINDOW	0x4734#define VA_DRAG_COMPLETE	0x4735#define AV_WHAT_IZIT	0x4732#define VA_THAT_IZIT	0x4733#define AV_DELFILE		0x4757
#define VA_FILEDELETED	0x4758
extern int av_server;extern unsigned long av_server_kennt;extern char *av_string;extern unsigned long *av_del_list;
int get_av_server(void);void init_av_protokoll(void);void exit_av_protokoll(void);
#endif