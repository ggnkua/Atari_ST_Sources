/* C  file selector */
/* Digital Wisdom C */

#include <string.h>

short	contrl[12],
		intin[128],
		intout[128],
		ptsin[128],
		ptsout[128],
		work_in[12] = { 1,1,1,1,1,1,1,1,1,1,2 },
		work_out[57],
		handle;						/* vdi handle */

char path[80],name[20];

main()
{
	short i;
	appl_init();
	handle = graf_handle(&i,&i,&i,&i);	/* i is dummy variable */
	v_opnvwk(work_in,&handle,work_out);
	if (get_file()) {
		v_clrwk(handle);				/* clear the screen
		vst_color(handle,1)				/* black ink */
		v_gtext(handle,16,16,path);		/* print filename */
	}
	evnt_keybd();
	v_clsvwk(handle);
	appl_exit();
}

get_file()
{
	short button,len;
	strcpy(path,"A:\\*.*");			/* default path */
	path[0] += Dgetdrv();			/* set to current drive */
	strcpy(name,"");				/* null filename */
	fsel_input(path,name,&button);	/* do file selector */
	graf_mouse(0,0);				/* change mouse to pointer */
	if ( name[0]=='\0' || button==0 )
		return(0);					/* no filename or Cancel pressed */
	len = strlen(path);
	while ( path[len-1]!='\\' )		/* knock out *.* from path */
		--len;
	path[len] = '\0';				/* mark end of path */
	strcat(path,name);				/* concatenate strings */
	return(1);
}
