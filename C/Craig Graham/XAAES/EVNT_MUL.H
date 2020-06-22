#ifndef _EVNT_MUL_H_
#define _EVNT_MUL_H_

#include "XA_TYPES.H"

unsigned long XA_evnt_multi(short clnt_pid,AESPB *pb);
void cancel_evnt_multi(short clnt_pid);

#endif