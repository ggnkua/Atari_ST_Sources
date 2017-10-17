#include <stdlib.h>
#ifdef __PUREC__
# include <aes.h>
# include <vdi.h>
#else
# include <gem.h>
#endif

static short vdi_handle, screenw, screenh;

static void work_open(void)
{
	static short work_in[12], work_out[57];
	int i;

	appl_init();

	/* open virtual screen workstation (screen) */
	for(i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk(work_in, &vdi_handle, work_out);

	screenw = work_out[0];
	screenh = work_out[1];

	graf_mouse(M_OFF, NULL);
	wind_update(BEG_UPDATE);

	/* reserve screen area (in newer AES a no-op) */
	form_dial(FMD_START, screenw>>1, screenh>>1, 0, 0, 0, 0, screenw, screenh);
}

static void work_close(void)
{
	/* restore screen area (in newer AES, cause WM_REDRAW) */
	form_dial(FMD_FINISH, screenw>>1, screenh>>1, 0, 0, 0, 0, screenw, screenh);

	wind_update(END_UPDATE);
	graf_mouse(M_ON, NULL);
	v_clsvwk(vdi_handle);
	appl_exit();
}

static void wait_key(void)
{
	short dummy, key;

	/* input:
	 *  event flags, mbclicks, mbmask, mbstate,
	 *  5x region 1, 5x region 2,
	 *  event buffer, low & high timer value (ms).
	 * output:
	 *  mouse co-ordinate (x,y), mouse buttons, special key and normal key
	 *  states, number of mouse clicks.
	 */
#ifdef __GEMLIB__
	evnt_multi(MU_KEYBD,
		   0, 0, 0,
		   0, 0, 0, 0, 0,
		   0, 0, 0, 0, 0,
		   NULL, 0,
		   &dummy, &dummy, &dummy, &dummy, &key, &dummy);
#else
	evnt_multi(MU_KEYBD,
		   0, 0, 0,
		   0, 0, 0, 0, 0,
		   0, 0, 0, 0, 0,
		   NULL, 0, 0,
		   &dummy, &dummy, &dummy, &dummy, &key, &dummy);
#endif
}

static void try_stuff(void)
{
	short dummy;

	/* clear screen */
	v_clrwk(vdi_handle);

	/* draw text centered to middle of screen */
	vst_alignment(vdi_handle, 1, 1, &dummy, &dummy);

	/* try to get rid of text cursor */
	v_gtext(vdi_handle, screenw>>1, screenh>>1, "Press key for v_exit_cur()");
	wait_key();
	v_exit_cur(vdi_handle);

	v_gtext(vdi_handle, screenw>>1, screenh>>1, "Press key for exit");
	wait_key();
}

int main(void)
{
	work_open();
	try_stuff();
	work_close();
	return 0;
}
