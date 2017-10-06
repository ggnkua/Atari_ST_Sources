#include <wx_lib.h>
#include <alloc.h>

void	main()
{
	int		count,
			vh,
			gh,
			junk,
			gl_wchar,
			gl_hchar,
			work_in[11],
			work_out[57];
	Window	ws;

	/* Initialization */
	appl_init();
	gh = graf_handle(&gl_wchar,&gl_hchar,&junk,&junk);
	for (count = 0;count < 10;count ++) {
		work_in[count] = 1;
	}
	work_in[10] = 2;
	vh = gh;
	v_opnvwk(work_in,&vh,work_out);
	/* Workout */
	wx_init(&ws,vh,gl_wchar,gl_hchar);
	wx_new(&ws);
	wx_settype(&ws,INFO|NAME|MOVER|FULLER|CLOSER);
	wx_open(&ws);
	wx_name(&ws,"This is a test.");
	wx_info(&ws,"Wombats have been here.");
	wx_clear(&ws);
	wx_puts(&ws,"This is a test of wx_puts().\n");
	wx_printf(&ws,"This is another test, this time of wx_printf().\n");
	for (count = 1;count <= 30;count++) {
		wx_printf(&ws,"This is a bigger test of wx_printf().\n#%d.\n",count);
	}
	for (count = 1;count <= 50;count ++) {
		wx_printf(&ws,"This");
	}
	wx_size(&ws,100,100);
	wx_clear(&ws);
	for (count = 1;count <= 30;count++) {
		wx_printf(&ws,"This is a bigger test of wx_printf().\n#%d.\n",count);
	}
	wx_move(&ws,30,30);
	wx_clear(&ws);
	for (count = 1;count <= 30;count++) {
		wx_printf(&ws,"This is a bigger test of wx_printf().\n#%d.\n",count);
	}
	wx_full(&ws);
	wx_clear(&ws);
	for (count = 1;count <= 30;count++) {
		wx_printf(&ws,"This is a bigger test of wx_printf().\n#%d.\n",count);
	}
	wx_close(&ws);
	wx_free(&ws);
	appl_exit();
}
