/************************************************************************/
/*																		*/
/*	VDICOLOR.C	04-09-94												*/
/*																		*/
/*	(c) 94	pARTner														*/
/*			sYSTems														*/
/*	---------///------------------------								*/
/*	A handmade software by Marco De Luca								*/
/*																		*/
/************************************************************************/

#include <stdio.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>


void color_palette	(int phys_handle, int colors, int flag);
void do_it			(int colors);

/*	------------------------------------------------------------------	*/
/*	Globale Variablen													*/
/*	------------------------------------------------------------------	*/
int work_in[12],
	work_out[57];

int handle,
	phys_handle;

extern _app;


/************************************************************************/
/*	main()																*/
/************************************************************************/
main ()
{
	int i, dummy, msg_buf[8], colors;

	if (appl_init() < 0)
		return 1;

	for (i = 1; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	phys_handle = graf_handle (&dummy, &dummy, &dummy, &dummy);
	work_in[0]  = handle = phys_handle;
	v_opnvwk (work_in, &handle, work_out);
	colors = work_out[13];

	if (_app)
		do_it(colors);
	else
		if (menu_register (dummy, "  Colortest") != -1)
			while (1)
			{
				evnt_mesag (msg_buf);
				if (msg_buf[0] == AC_OPEN)
					do_it(colors);
			}

	v_clsvwk (handle);
	appl_exit();
	return 0;
}

/************************************************************************/
/*	do_it()																*/
/************************************************************************/
void do_it (int colors)
{
	color_palette(phys_handle, colors, 0);	/*	save color palette	*/
	color_palette(phys_handle, colors, 2);	/*	fade out			*/
	color_palette(phys_handle, colors, 3);	/*	fade in				*/
	color_palette(phys_handle, colors, 4);	/*	invert				*/
	evnt_timer (10000,0);					/*	mal so lassen...	*/
	color_palette(phys_handle, colors, 1);	/*	restore palette		*/
}

/************************************************************************/
/*																		*/
/*	color_palette()														*/
/*																		*/
/*	Get or set color palette.											*/
/*																		*/
/*	->	flag	0	= get color palette									*/
/*				1	= set color palette									*/
/*				2	= fade out											*/
/*				3	= fade in											*/
/*																		*/
/*	<-	-																*/
/*																		*/
/************************************************************************/
void color_palette (int phys_handle, int colors, int flag)
{
	static int col[256][3];
	int rgb[3];
	int i, j;
	int step = 10;	/*	fade out/in	*/


	if (colors > 256)	colors = 256;

	switch (flag)
	{
		/*	----------------------------------------------------------	*/
		/*	Save color palette											*/
		/*	----------------------------------------------------------	*/
		case 0:	for (i = 0; i < colors; i++)
				{
					vq_color (phys_handle, i, 0, &rgb[0]);
					col[i][0] = rgb[0];
					col[i][1] = rgb[1];
					col[i][2] = rgb[2];
				}
				break;

		/*	----------------------------------------------------------	*/
		/*	Restore color palette										*/
		/*	----------------------------------------------------------	*/
		case 1:	for (i = 0; i < colors; i++)
				{
					rgb[0] = col[i][0];
					rgb[1] = col[i][1];
					rgb[2] = col[i][2];
					vs_color (phys_handle, i, &rgb[0]);
				}
				break;

		/*	----------------------------------------------------------	*/
		/*	Fade out													*/
		/*	----------------------------------------------------------	*/
		case 2:	for (j = 0; j < (1000 / step); j++)
				{
					for (i = 0; i < colors; i++)
					{
						vq_color (phys_handle, i, 0, &rgb[0]);
						rgb[0] -= step;	if (rgb[0] < 0)		rgb[0] = 0;
						rgb[1] -= step;	if (rgb[1] < 0)		rgb[1] = 0;
						rgb[2] -= step;	if (rgb[2] < 0)		rgb[2] = 0;
						vs_color (phys_handle, i, &rgb[0]);
					}
				}
				break;

		/*	----------------------------------------------------------	*/
		/*	Fade in														*/
		/*	----------------------------------------------------------	*/
		case 3:	for (j = 0; j < (1000 / step); j++)
				{
					for (i = 0; i < colors; i++)
					{
						vq_color (phys_handle, i, 0, &rgb[0]);
						rgb[0] += step;	if (rgb[0] > col[i][0])	rgb[0] = col[i][0];
						rgb[1] += step;	if (rgb[1] > col[i][1])	rgb[1] = col[i][1];
						rgb[2] += step;	if (rgb[2] > col[i][2])	rgb[2] = col[i][2];
						vs_color (phys_handle, i, &rgb[0]);
					}
				}
				break;

		/*	----------------------------------------------------------	*/
		/*	Invert														*/
		/*	----------------------------------------------------------	*/
		case 4:	for (i = 0; i < colors; i++)
				{
					vq_color (phys_handle, i, 0, &rgb[0]);
					rgb[0] = 1000 - rgb[0];
					rgb[1] = 1000 - rgb[1];
					rgb[2] = 1000 - rgb[2];
					vs_color (phys_handle, i, &rgb[0]);
				}
	}
}
