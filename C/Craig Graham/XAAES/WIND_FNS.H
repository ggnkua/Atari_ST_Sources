#ifndef _WIND_FNS_H_
#define _WIND_FNS_H_

#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "K_DEFS.H"

unsigned long XA_wind_create(short clnt_pid,AESPB *pb);
unsigned long XA_wind_open(short clnt_pid,AESPB *pb);
unsigned long XA_wind_close(short clnt_pid,AESPB *pb);
unsigned long XA_wind_find(short clnt_pid,AESPB *pb);
unsigned long XA_wind_set(short clnt_pid, AESPB *pb);
unsigned long XA_wind_get(short clnt_pid, AESPB *pb);
unsigned long XA_wind_update(short clnt_pid, AESPB *pb);
unsigned long XA_wind_delete(short clnt_pid, AESPB *pb);
unsigned long XA_wind_new(short clnt_pid, AESPB *pb);
unsigned long XA_wind_calc(short clnt_pid, AESPB *pb);

#endif