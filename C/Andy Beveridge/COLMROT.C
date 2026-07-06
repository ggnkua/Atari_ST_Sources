/******************************************************************
*                                                                 *
* Another example C + assembler program. This one lets you draw   *
* with the mouse in lots of colours and then spins all the        *
* colours about using the example assembler binding in COLROT.ASM *
* The result is quite pretty but don't try it unless you've got   *
* a colour monitor cos it don't work in monochrome - sorry.       *
*           Needs to be linked to GEMLIB and COLROT.              *
*                                                                 *
*                    by ABD December 1985                         *
*                                                                 *
******************************************************************/


#include	<stdio.h>	/* Standard includes from compiler disk */
#include	<gemdefs.h>	/* assorted useful VDI macro's    */
#include	<portab.h>	/* include type def macro's etc   */

#define	RAD 8			/* size of the blob */

 extern palrot();		/* This function from assembler example */
				/* see file COLROT.ASM			*/

 WORD	phys_handle,handle,dummy,mx,my;
 WORD	pxyarray[4] = {0,0,639,399};

main()
{
	WORD  c=4,xm,ym,buttons,i,j;

	gem_init();		/* initialise a virtual workstation */

	vs_clip(handle,TRUE,pxyarray);

	vsf_interior(handle,SOLID);
	vsf_perimeter(handle,FALSE);

	graf_mouse(7,0L);

	do {
		vq_mouse(handle,&buttons,&xm,&ym);
		if(buttons & 1){
			v_hide_c(handle);		/* remove mouse	*/

			v_circle(handle,xm,ym,RAD);	/* do blobs	*/
			v_circle(handle,mx-xm,ym,RAD);
			v_circle(handle,mx-xm,my-ym,RAD);
			v_circle(handle,xm,my-ym,RAD);

			v_show_c(handle,1);		/* put it back	*/
			if( ++c > 15)			/* next colour	*/
				c=4;
			vsf_color(handle,c);		/* set fill color */
		}
	} while( ! (buttons & 2) );

	while(buttons)			/* wait till not pressed */
		vq_mouse(handle,&buttons,&xm,&ym);

	for(i=0;i<32767;i++)		/* de-bounce */
		;

	do {
	palrot(4,15);
	vq_mouse(handle,&buttons,&xm,&ym);

	for(i=0;i<xm;i++)		/* delay a while */
		for(j=0;j<xm;j++)
			;
	} while(! buttons);

	v_clsvwk(handle);		/* close up the workstation */

}	/* before we exit */

gem_init()
{
	WORD  i;
	WORD  work_in[11],work_out[57];
	/* NOTE: if the data out from opnvwk() */
	/* is needed elsewhere it may be more  */
	/* convenient to declare it as an      */
	/*   external static or global         */

	appl_init();		/* open the application	*/

	phys_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);

	handle=phys_handle;	/* handle will contain our virtual handle */

	for(i=0;i<10;i++)
		work_in[i] = 1;		/* set all defaults before we open it */
	work_in[10] = 2;		/* use raster co-ordinates */

	v_opnvwk(work_in,&handle,work_out);	/* open the workstation	*/
	mx = pxyarray[2] = work_out[0];		/* max x co-ordinate	*/
	my = pxyarray[3] = work_out[1];		/* max y co-ordinate	*/
	v_hide_c(handle);			/* remove the mouse	*/
	v_clrwk(handle);			/* then clear it	*/
	v_show_c(handle,0);			/* & put mouse back	*/

}

