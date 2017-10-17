#include "gemform.h"

#define vdi_dummy 0L
#define vdi_control_ptr(n)   *((void**)(vdi_control +n))
#define vdi_intin_ptr(n)     *((void**)(vdi_intin   +n))
#define vdi_intout_long(n)   *((long*) (vdi_intout  +n))

static void _vdi_trap_esc(VDIPB * vdipb, long cntrl_0_1, long cntrl_3, long cntrl_5, short handle)
{
	__asm__ volatile (
		"movea.l	%0,a0\n\t"	/* &vdipb */
		"move.l	a0,d1\n\t"
		"move.l	(a0),a0\n\t"	/* vdipb->control */
		"move.l	%1,(a0)+\n\t"	/* cntrl_0, cntrl_1 */
		"move.l	%2,(a0)+\n\t"	/* cntrl_2, cntrl_3 */
		"move.l	%3,(a0)+\n\t"	/* cntrl_4, cntrl_5 */
		"move.w	%4,(a0)\n\t"	/* handle */
		"move.w	#115,d0\n\t"	/* 0x0073 */
		"trap	#2"
		:
		: "a"(vdipb), "g"(cntrl_0_1), "g"(cntrl_3), "g"(cntrl_5), "g"(handle)
		: "a0", "d0", "d1", "memory"
	);
}
#define VDI_TRAP_ESC(vdipb, handle, opcode, subop, cntrl_1, cntrl_3) \
	_vdi_trap_esc (&vdipb, (opcode##uL<<16)|cntrl_1, cntrl_3, subop, handle)

static void _vdi_trap_00(VDIPB * vdipb, long cntrl_0_1, short handle)
{
	__asm__ volatile (
		"movea.l %0,a0\n\t"	/* &vdipb */
		"move.l  a0,d1\n\t"
		"move.l  (a0),a0\n\t"	/* vdipb->control */
		"move.l  %1,(a0)+\n\t"	/* cntrl_0, cntrl_1 */
		"eor.l   d0,d0\n\t"
		"move.l  d0,(a0)+\n\t"	/* cntrl_2, cntrl_3 */
		"move.l  d0,(a0)+\n\t"	/* cntrl_4, cntrl_5 */
		"move.w  %2,(a0)\n\t"	/* handle */
		"move.w  #115,d0\n\t"	/* 0x0073 */
		"trap    #2"
		:
		: "a"(vdipb), "g"(cntrl_0_1), "g"(handle)
		: "a0", "d0","d1","memory"
	);
}
#define VDI_TRAP_00(vdipb, handle, opcode) \
	_vdi_trap_00(&vdipb, (opcode##uL<<16), handle)
	
#define VDI_TRAP(vdipb, handle, opcode, cntrl_1, cntrl_3) \
	VDI_TRAP_ESC(vdipb, handle, opcode, 0, cntrl_1, cntrl_3)

#define VDI_PARAMS(a,b,c,d,e) \
	VDIPB vdi_params;         \
	vdi_params.control = a;   \
	vdi_params.intin   = b;   \
	vdi_params.ptsin   = c;   \
	vdi_params.intout  = d;   \
	vdi_params.ptsout  = e;

void v_opnvwk(short work_in[], short *handle, short work_out[])
{
	short vdi_control[VDI_CNTRLMAX]; 
	VDI_PARAMS(vdi_control, work_in, 0L, &work_out[0], &work_out[45] );
	VDI_TRAP(vdi_params, *handle, 100, 0, 11);
	*handle = vdi_control[6];
}

void v_clsvwk(short handle)
{
	short vdi_control[VDI_CNTRLMAX]; 
	VDI_PARAMS(vdi_control, 0L, 0L, vdi_dummy, vdi_dummy);
	VDI_TRAP_00(vdi_params, handle, 101);
}

void vq_extnd(short handle, short flag, short work_out[])
{
	short vdi_control[VDI_CNTRLMAX]; 
	VDI_PARAMS(vdi_control, &flag, 0L, &work_out[0], &work_out[45] );
	VDI_TRAP(vdi_params, handle, 102, 0, 1);
}

void vro_cpyfm(short handle, short mode, short pxy[], MFDB *src, MFDB *dst)
{
	short vdi_control[VDI_CNTRLMAX]; 
	VDI_PARAMS(vdi_control, &mode, pxy, vdi_dummy, vdi_dummy);
	vdi_control_ptr(7) = src;
	vdi_control_ptr(9) = dst;
	VDI_TRAP(vdi_params, handle, 109, 4, 1);
}
