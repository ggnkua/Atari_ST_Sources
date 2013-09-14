/*	Modified GDvq_extend() to use passed in buffer
 *	dlf - 8/31/88
 */

#include    "portab.h"

extern    WORD    contrl[];
extern    WORD    intin[];
extern    WORD    ptsin[];
extern    WORD    intout[];
extern    WORD    ptsout[];

extern    WORD	*pioff, *iioff, *pooff, *iooff;

extern    vdi();

#define i_ptsin(ptr) pioff = ptr
#define i_intin(ptr) iioff = ptr
#define i_intout(ptr) iooff = ptr
#define i_ptsout(ptr) pooff = ptr

extern    i_ptr();
extern    i_ptr2();
extern    m_lptr2();

WORD
GDv_opnwk( work_in, handle, work_out,xres,yres,buffer)
WORD work_in[], *handle, work_out[];
WORD xres,yres;
long *buffer;
{
   i_intin( work_in );
   i_intout( work_out );
   i_ptsout( work_out + 45 );

   contrl[0] = 1;
   if(xres && yres)	   /* if xres and yres not zero */
   {
       	contrl[1] = 4;
       	ptsin[0] = xres;
       	ptsin[1] = yres;
	stuffpt(buffer,&ptsin[2]);	   /* Put buffer into ptsin[2][3] */
   }
   else
	contrl[1] = 0;    /* Clear the flag	       */

   contrl[3] = 11;        /* pass down xform mode also */
   vdi();

   if((contrl[0] == 1) && (contrl[1] == 2 || contrl[1] == 0))
	*buffer = 0L;
   else
	stuffpt(&contrl[0],buffer);

   *handle = contrl[6];    

   i_intin( intin );
   i_intout( intout );
   i_ptsout( ptsout );
   i_ptsin( ptsin );	/* must set in 68k land so we can ROM it */
}


WORD
v_pgcount(handle, count)
WORD handle;
WORD count;
{
   contrl[0] = 5;
   contrl[1] = 0;
   contrl[3] = 0;
   contrl[5] = 2000;
   contrl[6] = handle;
   intin[0]  = count;
   vdi();
}


    WORD
GDv_updwk( handle,buffer,clrflag,status )
WORD handle;
long *buffer;
WORD clrflag;
WORD *status;
{
    contrl[0] = 4;

    contrl[1] = clrflag;
    if(*buffer)
    {
	contrl[3] = 2;
	stuffpt(buffer,&intin[0]);
    }
    else
	contrl[3] = 0;
    contrl[6] = handle;
    vdi();
    *status = intout[0];
}


    WORD
GDvq_extnd( handle, owflag, work_out,xres,yres,buffer )
WORD handle, owflag, work_out[];
WORD xres,yres;
long *buffer;
{
    i_intin( intin );	/* must set in 68k land so we can ROM it */
    i_ptsin( ptsin );	/* since bss can't have initialized data */

    i_intout( work_out );
    i_ptsout( work_out + 45 );
    intin[0] = owflag;

    contrl[0] = 102;
    contrl[3] = 0;

    if(xres && yres)
    {
	contrl[1] = 2;
	ptsin[0] = xres;
	ptsin[1] = yres;
	if (*buffer) {
	   stuffpt( buffer, &intin[1] );
	   contrl[3] = 2;
	}
    }
    else
	contrl[1] = 0;
    contrl[3]++;
    contrl[6] = handle;
    vdi();

    i_intout( intout );
    i_ptsout( ptsout );
}


    WORD
GDv_justified( handle, x, y, string, length, word_space, char_space)
WORD handle, x, y, length, word_space, char_space;
unsigned char string[];
{
    WORD *intstr;

    ptsin[0] = x;
    ptsin[1] = y;
    ptsin[2] = length;
    ptsin[3] = 0;
    intin[0] = word_space;
    intin[1] = char_space;
    intstr = &intin[2];
    while (*intstr++ = *string++)
        ;

    contrl[0] = 11;
    contrl[1] = 2;
    contrl[3] = (int) (intstr - intin) - 1;
    contrl[5] = 10;
    contrl[6] = handle;
    vdi();
}


    WORD
vmicron( handle,xmicron,ymicron)
WORD handle;
WORD xmicron;
WORD ymicron;
{
   contrl[0] = 5;
   contrl[1] = 0;
   contrl[3] = 0;
   contrl[5] = 3000;
   contrl[6] = handle;
   intin[0]  = xmicron;
   intin[1]  = ymicron;
   vdi();
}
