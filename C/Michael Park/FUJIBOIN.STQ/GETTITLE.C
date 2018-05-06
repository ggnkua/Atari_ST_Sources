/***************************************************************************/
/*                                                                         */
/*  GetTitle!  Written by Xanth Park.  23 Apr 86 (START mod: 27 Jun 86)    */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/***************************************************************************/
/*
 *      extract title rectangle from title pic
 *
 *      run in low-rez
 */

#include <osbind.h>

int
  contrl[12],intin[128],ptsin[128],intout[128],ptsout[128], /* GEM globals */
  dummy,
  gfh;  /* G.F.Handle */
int *buff;

int outbuff[40];

main(){
  int
    intin[11],intout[57],fhandle,i,j,k,*p;
  appl_init();
  gfh = graf_handle( &dummy, &dummy, &dummy, &dummy );
  for( i=0; i<10; i++ ) intin[i] = 1;
  intin[10] = 2;
  v_opnvwk( intin, &gfh, intout );
  v_hide_c( gfh );

  buff = Physbase();
  fhandle = Fopen( "TITLE.NEO", 0 );
  Fread( fhandle, 128L, buff );
  Fread( fhandle, 32000L, buff );
  Fclose( fhandle );
  p = buff+105*80+20;   /* (80,105) */
  fhandle = Fcreate( "TITLE.D8A", 0 );
  for( i=105; i<190; i++ ){
    k=0;
    for( j=0; j<40; j++ ){
      outbuff[k++] = *p; *p++=0;
    }
    Fwrite( fhandle, 80L, outbuff );
    p += 40;
  }
  Fclose( fhandle );

  v_clsvwk( gfh );
  appl_exit();
}/* main */


