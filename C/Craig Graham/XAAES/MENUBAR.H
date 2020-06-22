#ifndef _MENUBAR_H_
#define _MENUBAR_H_

unsigned long XA_menu_bar(short clnt_pid, AESPB *pb);
unsigned long XA_menu_tnormal(short clnt_pid, AESPB *pb);
unsigned long XA_menu_ienable(short clnt_pid, AESPB *pb);
unsigned long XA_menu_icheck(short clnt_pid, AESPB *pb);
unsigned long XA_menu_text(short clnt_pid, AESPB *pb);
unsigned long XA_menu_register(short clnt_pid, AESPB *pb);

#endif
