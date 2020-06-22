#ifndef _SHELL_H_
#define _SHELL_H_

#include "k_defs.h"

unsigned long XA_shell_write(short clnt_pid, AESPB *pb);
unsigned long XA_shell_read(short clnt_pid, AESPB *pb);
unsigned long XA_shell_find(short clnt_pid, AESPB *pb);
unsigned long XA_shell_envrn(short clnt_pid, AESPB *pb);

#endif