>>>>>>>>>>> Demonstration of byte alignment of window interior <<<<<<<<<<<

#define FEATURES    0x0fef	/* what border features are used   */
WORD	msg[8];			/* message from evnt_multi	   */
GRECT	work_area;		/* defines working area 	   */
WORD	w_hndl;			/* handle for window being changed */

	wind_calc(1, FEATURES, msg[4], msg[5], msg[6], msg[7], 
		&work_area.g_x, &work_area.g_y, &work_area.g_w, 
		&work_area.g_h);
	work_area.g_x = align_x(work_area.g_x);
	work_area.g_w = align_x(work_area.g_w);
	wind_calc(0, FEATURES, work_area.g_x, work_area.g_y, 
		work_area.g_w, work_area.g_h, &msg[4], &msg[5], 
		&msg[6], &msg[7]); 
	wind_set(w_hndl, WF_CXYWH, msg[4], msg[5], msg[6], msg[7]);

>>>>>>>>>>>>>>>>>>>>> Subroutine for above <<<<<<<<<<<<<<<<<<<<<<<<<<<<<

	WORD
align_x(x)		/* forces word alignment for column position	*/
	WORD	x;		/*   rounding to nearest word		*/
	{
	return((x & 0xfff0) + ((x & 0x0008) ? 0x0010 : 0));
	}	

>>>>>>>>>>>>>>>>>>>>> Standard v_gtext binding <<<<<<<<<<<<<<<<<<<<<<<<<

	WORD
v_gtext( handle, x, y, string)
	WORD handle, x, y;
	BYTE *string;
	{
	WORD i;
	ptsin[0] = x;
	ptsin[1] = y;
	i = 0;
	while (intin[i++] = *string++)	/* Copy characters to intin    */
		;			/* There is NO error checking! */
	contrl[0] = 8;
	contrl[1] = 1;
	contrl[3] = --i;
	contrl[6] = handle;
	vdi();
	}
