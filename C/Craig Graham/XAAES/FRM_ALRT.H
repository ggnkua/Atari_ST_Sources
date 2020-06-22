/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _FRM_ALRT_H_
#define _FRM_ALRT_H_
#include "K_DEFS.H"

short do_form_alert(short default_button, char *alert, short owner);
short click_alert_widget(XA_WINDOW *wind, XA_WIDGET *widg);

#endif
