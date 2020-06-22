#ifndef _GRAF_MOU_H_
#define _GRAF_MOU_H_

#include <VDI.H>
#include "K_DEFS.H"

extern short user_mouse;		/* User set mouse (whatever was last set with graf_mouse) */
extern MFORM *user_mouse_form;	/* - used to restore cursor after window drags, etc */

void graf_mouse(short m_shape, MFORM *mf);

unsigned long XA_graf_mouse(short clnt_pid, AESPB *pb);
unsigned long XA_graf_handle(short clnt_pid, AESPB *pb);
unsigned long XA_graf_mkstate(short clnt_pid, AESPB *pb);

#endif
