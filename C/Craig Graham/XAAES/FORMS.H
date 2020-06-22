#ifndef _FORMS_H_
#define _FORMS_H_

#include "XA_DEFS.H"
#include "XA_TYPES.H"

unsigned long XA_form_center(short clnt_pid, AESPB *pb);
unsigned long XA_form_dial(short clnt_pid, AESPB *pb);
unsigned long XA_form_button(short clnt_pid, AESPB *pb);
unsigned long XA_form_alert(short clnt_pid, AESPB *pb);
unsigned long XA_form_do(short clnt_pid, AESPB *pb);
unsigned long XA_form_error(short clnt_pid, AESPB *pb);
unsigned long XA_form_keybd(short clnt_pid, AESPB *pb);

#endif
