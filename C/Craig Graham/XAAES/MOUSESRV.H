/*
	XaAES - Mouse Server
*/
#ifndef _MOUSESRV_H_
#define _MOUSESRV_H_

void hook_mouse_button(void);

void preserve_regs(void);
#pragma inline preserve_regs() {"48e7c0c0";}		/* MOVEM.L d0-d1/a0-a1,-(a7) */
void restore_regs(void);
#pragma inline restore_regs() {"4cdf0303";}			/* MOVEM.L (a7)+,d0-d1/a0-a1 */

#endif