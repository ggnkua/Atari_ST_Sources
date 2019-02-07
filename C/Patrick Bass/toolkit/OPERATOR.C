
/*
 * DEGAS Elite Screen Operator!
 * version 121386
 * File: OPERATOR.C
 * (c) 1987 Antic Publishing
 * Written by Patrick Bass
 *
 *--------------------------------*/

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"
#include "portab.h"

#include "operator.h"

#define   TRUE           (1)
#define   FALSE          (0)
#define   CANCEL         (0)
#define   NO             (2)
#define   ERROR          (-1)
#define   begin          {
#define   end            }
#define   wend           }
#define   repeat         }
#define   next           }
#define   endif          }
#define   endswitch      }
#define   not            !
#define   equals         ==
#define   does_not_equal !=
#define   then
#define   AND            &&
#define   OR             ||
#define   ANDed_with     &
#define   ORed_with      |
#define   EORed_with     ^
#define   DELAY          for( delay=0; delay<32767; delay++ );
#define   CONSOL         2
#define   CR             13
#define   LF             10
#define   MAXSLIDE       120
#define   JIFFYTIME      (.0166667)
#define   QUEUESIZE      40
#define   LOREZ          0
#define   MEDREZ         1
#define   HIREZ          2
#define   DEGAS00        0xDE00
#define   DEGAS01        0xDE01
#define   DEGAS80        0xDE80
#define   DEGAS81        0xDE81
#define   LWGET(x)       ( (int) *((int *)(x)) )
#define   B1OB_W(x)      (dialog0+(x)*sizeof(OBJECT)+20)
#define   B1OB_H(x)      (dialog0+(x)*sizeof(OBJECT)+22)

/*------------------------------------------*/
extern int  gl_apid;

/*------------------------------------------*/
int  contrl[ 12 ],
     intin[ 128 ], ptsin[ 128 ],
     intout[ 128 ], ptsout[ 128 ],
     work_in[]={ 1,1,1,1,1,1,1,1,1,1,2 }, work_out[ 57 ],
     gem_handle, menu_id, button,
     key0, key1, key2, key3, key4, key5,
     printable, aborted,
     DE_id, menu_id, slots, resolution,
     xres, yres, seq_size,

     /* corners of Dialog Box   */
     x0,  y0,  w0,  h0, xd0, yd0, wd0, hd0,
     x1,  y1,  w1,  h1, xd1, yd1, wd1, hd1,

     /* Operations activity flags.  TRUE="Use Me!" */
     bwmsk_flag, band_flag, bor_flag, beor_flag, bns_flag, bnd_flag,

     /* corner of AND box */
     bax, bay, baw, bah,

     /* corner of OR box */
     box, boy, bow, boh,

     /* corner of EOR box */
     bex, bey, bew, beh,

     /* corner of WithMASK box */
     bwx, bwy, bww, bwh,

     /* corner of NOT SOURCE box */
     bnsx, bnsy, bnsw, bnsh,

     /* corner of NOT DEST box */
     bndx, bndy, bndw, bndh,

     /* corners of Source Number window */
     src_nx, src_ny, src_nw, src_nh,

     /* corners of Mask Number window */
     msk_nx, msk_ny, msk_nw, msk_nh,

     /* corners of Dest Number window */
     des_nx, des_ny, des_nw, des_nh,

     /* Corners of Exit button */
     bxx, bxy, bxw, bxh,

     /* Corners of View button */
     bvx, bvy, bvw, bvh,

     /* Corners of Perform button */
     bpx, bpy, bpw, bph,

     msgbuff[ 20 ], keycode, ret,
     l, done, slidpos[ 10 ], slidmax[ 10 ],

     i, j, k, n, x, y, handle,
     gr_1, gr_2, gr_3, gr_4,
     ptemp[ 1 ], temp,
     diax, diay, diaw, diah,
     formresult, key,

     srcpix, maskpix, destpix;

/*------------------------------------------*/
char rs_strings[]="[1][I can't operate|without|DEGAS Elite.][ Sorry ]",
     strack[ 100 ],
     tempstring[ 100 ],
     fsequence[ 100 ],
     debug[ 100 ];

/*------------------------------------------*/
long      *s_ptrs, screen[ 15 ], dialog0;

/*------------------------------------------*/
float     slidstep[ 10 ], slidacc[ 10 ];

OBJECT *rsc_pointer;

/*------------------------------------------*/
main()
begin
     int x, result, event;

     appl_init();
     gem_handle=graf_handle( &i, &i, &i, &i );
     menu_id=menu_register( gl_apid,"  Screen Operator" );

     result=rsrc_load( "OPERATOR.RSC" );
     if( result<0 )then begin
          form_alert( 1,"[1][ Operator Resource | not found! ][ Danger! ]");
     endif

     rsrc_gaddr( 0, 0, &dialog0 );
   
     band_flag=FALSE;
     bor_flag=FALSE;
     beor_flag=FALSE;
     bns_flag=FALSE;
     bnd_flag=FALSE;

     srcpix=1; maskpix=2; destpix=3;

     graf_mouse( 0, 0L );
     v_show_c( gem_handle, 0 );

     do begin
          event=evnt_multi( MU_MESAG,
                              1, 1, ret,
                              0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0,
                              msgbuff, 0, 0,
                              &ret, &ret, &ret,
                              &ret, &ret, &ret );

          if( event & MU_MESAG )then begin

               if( msgbuff[ 0 ] equals AC_OPEN )then begin
                    if( msgbuff[ 4 ] equals menu_id )then begin
                         v_opnvwk( work_in, &gem_handle, work_out );

                         inquire();

                         v_clsvwk( gem_handle );
                    endif
               endif

               if( msgbuff[ 0 ] equals DEGAS80 )then begin
                    v_opnvwk( work_in, &gem_handle, work_out );
                    xres=work_out[ 0 ]; yres=work_out[ 1 ];

                    menu_handle();

                    v_clsvwk( gem_handle );
               endif

          endif

     repeat while( TRUE );
end
/*-------------------------------------------*/
inquire()
begin
     DE_id=appl_find( "DEGELITE" );
     if( DE_id<0 )then form_alert( 1, rs_strings );

     if( DE_id >=0 )then begin
          msgbuff[ 0 ]=DEGAS00;
          msgbuff[ 1 ]=gl_apid;
          msgbuff[ 2 ]=0;
          appl_write( DE_id, 16, msgbuff );
     endif
end
/*-------------------------------------------*/
menu_handle()
begin
     int  ix, iy, amount, x, pressed, mx, my, vdest;
     char  *pointer, z;

     x0=( xres/2 )-10;
     y0=( yres/2 )-10;
     w0=h0=20;

     s_ptrs=(char *)(  ( (long)msgbuff[ 3 ]<<16 )ORed_with
                    (  ( (long)msgbuff[ 4 ] )ANDed_with 0x0000ffffL) );

     for( ix=0; ix<15; screen[ ix++ ]=ERROR );
     slots=msgbuff[ 5 ];
     for( ix=0; ix<slots; ++ix )begin
          screen[ ix ]=s_ptrs[ ix ];
     next

     wind_update( TRUE );
     form_center( dialog0, &xd1, &yd1, &wd1, &hd1 );

     form_dial( 0, x1, y1, w1, h1, xd1, yd1, wd1, hd1 );
     form_dial( 1, x1, y1, w1, h1, xd1, yd1, wd1, hd1 );

     set1_button_state();

     objc_draw( dialog0, 0, 2, xd1, yd1, wd1, hd1 );

     ftoa( (float)srcpix, tempstring,0 );
     adjust( dialog0, SRCNUM, tempstring,src_nx,src_ny,src_nw,src_nh);
     ftoa( (float)maskpix, tempstring,0 );
     adjust( dialog0, MASKNUM, tempstring,msk_nx,msk_ny,msk_nw,msk_nh);
     ftoa( (float)destpix, tempstring, 0 );
     adjust( dialog0, DESTNUM, tempstring,des_nx,des_ny,des_nw,des_nh);

     do begin
          key1=form_do( dialog0, 0 );

          if( key1 equals BPERFORM )then begin
               operate();
               rsc_pointer=( OBJECT *)dialog0;
               rsc_pointer[ BPERFORM ].ob_state=NORMAL;
               objc_draw( dialog0, BPERFORM, 1, bpx, bpy,
                                                bpw, bph );
          endif

          if( ( key1 equals BNOTSRC )
            OR( key1 equals BNOTDEST )
            OR( key1 equals SRCDN )
            OR( key1 equals SRCUP )
            OR( key1 equals MASKDN )
            OR( key1 equals MASKUP )
            OR( key1 equals DESTDN )
            OR( key1 equals DESTUP )
            OR( key1 equals BAND )
            OR( key1 equals BOR )
            OR( key1 equals BEOR )
            OR( key1 equals BWMASK) )then begin

               filter_key( key1 );
          endif

          if( key1 equals BVIEW )then begin
               vdest=destpix;
               if( vdest >= 3 )then vdest=( vdest+4 );
               Setscreen( screen[ vdest ], screen[ vdest ], -1 );

               do begin
                    vq_mouse( gem_handle, &pressed, &mx, &my );
               repeat while( pressed );

               Setscreen( screen[ 0 ], screen[ 0 ], -1 );
          endif

     repeat while( key1 does_not_equal BEXIT );

     rsc_pointer=( OBJECT *)dialog0;
     rsc_pointer[ BEXIT ].ob_state=NORMAL;
     objc_draw( dialog0, BEXIT, 1, bxx, bxy, bxw, bxh );

     form_dial( 2, x1, y1, w1, h1, xd1, yd1, wd1, hd1 );
     form_dial( 3, x1, y1, w1, h1, xd1, yd1, wd1, hd1 );
     wind_update( FALSE );
end

/*----------------------------------------------*/
operate()
begin
     int   index, src, msk, des;
     long  *source, *mask, *dest;
     long  temp1, temp2, temp3;

     src=srcpix;
     if( src >= 3 )then src=src+4;
     msk=maskpix;
     if( msk >= 3 )then msk=msk+4;
     des=destpix;
     if( dest >= 3 )then des=des+4;

     source=screen[ src ];
     mask=screen[ msk ];
     dest=screen[ des ];

     v_hide_c( gem_handle );
     Setscreen( screen[ des ], screen[ des ], -1 );

     for( index=0; index<8000; index++ )begin
              
          temp1=( *source++ );
          temp2=( *mask++ );
          temp3=( *dest );

          if( bns_flag equals TRUE )then temp1=( temp1^0xFFFFFFFF );

          if( bwmsk_flag equals TRUE )then begin
               if( band_flag equals TRUE )then begin
                    temp3=( temp1 ANDed_with temp2 );
               endif
               if( bor_flag equals TRUE )then begin
                    temp3=( temp1 ORed_with temp2 );
               endif
               if( beor_flag equals TRUE )then begin
                    temp3=( temp1 EORed_with temp2 );
               endif
          endif

          if( bwmsk_flag equals FALSE )then begin
               if( band_flag equals TRUE )then begin
                    temp3=( temp1 ANDed_with temp3 );
               endif
               if( bor_flag equals TRUE )then begin
                    temp3=( temp1 ORed_with temp3 );
               endif
               if( beor_flag equals TRUE )then begin
                    temp3=( temp1 EORed_with temp3 );
               endif
          endif

          if(  ( band_flag equals FALSE )
            AND( bor_flag equals FALSE  )
            AND( beor_flag equals FALSE )
            AND( bwmsk_flag equals FALSE) )then temp3=temp1;

          if( bnd_flag equals TRUE )then temp3=( temp3^0xFFFFFFFF );
          ( *dest++ )=temp3;
     next

     Setscreen( screen[ 0 ], screen[ 0 ], -1 );
     v_show_c( gem_handle );
end

/*----------------------------------------------*/
set1_button_state()
begin
     rsc_pointer=( OBJECT *)dialog0;

     objc_offset( dialog0, BEXIT, &bxx, &bxy );
     bxw=( LWGET( B1OB_W( BEXIT )))-1;
     bxh=( LWGET( B1OB_H( BEXIT )))-1;

     objc_offset( dialog0, BVIEW, &bvx, &bvy );
     bvw=( LWGET( B1OB_W( BVIEW )))-1;
     bvh=( LWGET( B1OB_H( BVIEW )))-1;

     objc_offset( dialog0, BPERFORM, &bpx, &bpy );
     bpw=( LWGET( B1OB_W( BPERFORM )))-1;
     bph=( LWGET( B1OB_H( BPERFORM )))-1;

     objc_offset( dialog0, BAND, &bax, &bay );
     baw=( LWGET( B1OB_W( BAND )))-1;
     bah=( LWGET( B1OB_H( BAND )))-1;
     if( band_flag equals TRUE )then begin
          rsc_pointer[ BAND ].ob_state=SELECTED;
     endif
     if( band_flag equals FALSE )then begin
          rsc_pointer[ BAND ].ob_state=NORMAL;
     endif

     objc_offset( dialog0, BOR, &box, &boy );
     bow=( LWGET( B1OB_W( BOR )))-1;
     boh=( LWGET( B1OB_H( BOR )))-1;
     if( bor_flag equals TRUE )then begin
          rsc_pointer[ BOR ].ob_state=SELECTED;
     endif
     if( bor_flag equals FALSE )then begin
          rsc_pointer[ BOR ].ob_state=NORMAL;
     endif

     objc_offset( dialog0, BEOR, &bex, &bey );
     bew=( LWGET( B1OB_W( BEOR )))-1;
     beh=( LWGET( B1OB_H( BEOR )))-1;
     if( beor_flag equals TRUE )then begin
          rsc_pointer[ BEOR ].ob_state=SELECTED;
     endif
     if( beor_flag equals FALSE )then begin
          rsc_pointer[ BEOR ].ob_state=NORMAL;
     endif

     objc_offset( dialog0, BWMASK, &bwx, &bwy );
     bww=( LWGET( B1OB_W( BWMASK )))-1;
     bwh=( LWGET( B1OB_H( BWMASK )))-1;
     if( bwmsk_flag equals TRUE )then begin
          rsc_pointer[ BWMASK ].ob_state=SELECTED;
     endif
     if( bwmsk_flag equals FALSE )then begin
          rsc_pointer[ BWMASK ].ob_state=NORMAL;
     endif

     objc_offset( dialog0, BNOTSRC, &bnsx, &bnsy );
     bnsw=( LWGET( B1OB_W( BNOTSRC )))-1;
     bnsh=( LWGET( B1OB_H( BNOTSRC )))-1;
     if( bns_flag equals TRUE )then begin
          rsc_pointer[ BNOTSRC ].ob_state=SELECTED;
     endif
     if( bns_flag equals FALSE )then begin
          rsc_pointer[ BNOTSRC ].ob_state=NORMAL;
     endif

     objc_offset( dialog0, BNOTDEST, &bndx, &bndy );
     bndw=( LWGET( B1OB_W( BNOTDEST )))-1;
     bndh=( LWGET( B1OB_H( BNOTDEST )))-1;
     if( bnd_flag equals TRUE )then begin
          rsc_pointer[ BNOTDEST ].ob_state=SELECTED;
     endif
     if( bnd_flag equals FALSE )then begin
          rsc_pointer[ BNOTDEST ].ob_state=NORMAL;
     endif

     objc_offset( dialog0, SRCNUM, &src_nx, &src_ny );
     src_nw=( LWGET( B1OB_W( SRCNUM )))-1;
     src_nh=( LWGET( B1OB_H( SRCNUM )))-1;

     objc_offset( dialog0, MASKNUM, &msk_nx, &msk_ny );
     msk_nw=( LWGET( B1OB_W( MASKNUM )))-1;
     msk_nh=( LWGET( B1OB_H( MASKNUM )))-1;

     objc_offset( dialog0, DESTNUM, &des_nx, &des_ny );
     des_nw=( LWGET( B1OB_W( DESTNUM )))-1;
     des_nh=( LWGET( B1OB_H( DESTNUM )))-1;
end
    
/*---------------------------------------------------------*/
filter_key( keypress )
int  keypress;
begin
     int x;

     rsc_pointer=( OBJECT *)dialog0;

     if( keypress equals SRCDN )then begin
          if( srcpix>1 )then begin
               srcpix--;
               ftoa( (float)srcpix, tempstring,0 );
               adjust( dialog0, SRCNUM, tempstring, src_nx, src_ny,
                                                    src_nw, src_nh );
          endif
     endif

     if( keypress equals SRCUP )then begin
          x=( srcpix+1 );
          if( x>=3 )then x=( x+4 );
          if(  ( screen[ x ] != 0 )
            AND( srcpix < 8  ) )then begin
               srcpix++;
               ftoa( (float)srcpix, tempstring,0 );
               adjust( dialog0, SRCNUM, tempstring, src_nx, src_ny,
                                                    src_nw, src_nh );
          endif
     endif

     if( keypress equals MASKDN )then begin
          if( maskpix>1 )then begin
               maskpix--;
               ftoa( (float)maskpix, tempstring,0 );
               adjust( dialog0, MASKNUM, tempstring, msk_nx, msk_ny,
                                                     msk_nw, msk_nh );
          endif
     endif

     if( keypress equals MASKUP )then begin
          x=( maskpix+1 );
          if( x>=3 )then x=( x+4 );
          if(  ( screen[ x ] != 0 )
            AND( maskpix < 8       ) )then begin
               maskpix++;
               ftoa( (float)maskpix, tempstring,0 );
               adjust( dialog0, MASKNUM, tempstring, msk_nx, msk_ny,
                                                     msk_nw, msk_nh );
          endif
     endif

     if( keypress equals DESTDN )then begin
          if( destpix>1 )then begin
               destpix--;
               ftoa( (float)destpix, tempstring, 0 );
               adjust( dialog0, DESTNUM, tempstring, des_nx, des_ny,
                                                     des_nw, des_nh );
          endif
     endif

     if( keypress equals DESTUP )then begin
          x=( destpix+1 );
          if( x>=3 )then x=( x+4 );
          if(  ( screen[ x ] != 0 )
            AND( destpix < 8       ) )then begin
               destpix++;
               ftoa( (float)destpix, tempstring, 0 );
               adjust( dialog0, DESTNUM, tempstring, des_nx, des_ny,
                                                    des_nw, des_nh );
          endif
     endif

     if( keypress equals BNOTSRC )then begin
          bns_flag=( not bns_flag );
          if( bns_flag equals TRUE )then begin
               rsc_pointer[ BNOTSRC ].ob_state=SELECTED;
               objc_draw( dialog0, BNOTSRC, 1, bnsx,bnsy,bnsw,bnsh);
          endif

          if( bns_flag equals FALSE )then begin
               rsc_pointer[ BNOTSRC ].ob_state=NORMAL;
               objc_draw( dialog0, BNOTSRC, 1, bnsx,bnsy,bnsw,bnsh);
          endif
     endif

     if( keypress equals BNOTDEST )then begin
          bnd_flag=( not bnd_flag );
          if( bnd_flag equals TRUE )then begin
               rsc_pointer[ BNOTDEST ].ob_state=SELECTED;
               objc_draw( dialog0, BNOTDEST, 1, bndx,bndy,bndw,bndh);
          endif

          if( bnd_flag equals FALSE )then begin
               rsc_pointer[ BNOTDEST ].ob_state=NORMAL;
               objc_draw( dialog0, BNOTDEST, 1, bndx,bndy,bndw,bndh);
          endif
     endif

     if( keypress equals BAND )then begin
          band_flag=( not band_flag );
          if( band_flag equals TRUE )then begin
               rsc_pointer[ BAND ].ob_state=SELECTED;
               objc_draw( dialog0, BAND, 1, bax,bay,baw,bah);
               bor_flag=FALSE;
               rsc_pointer[ BOR ].ob_state=NORMAL;
               objc_draw( dialog0, BOR, 1, box,boy,bow,boh);
               beor_flag=FALSE;
               rsc_pointer[ BEOR ].ob_state=NORMAL;
               objc_draw( dialog0, BEOR, 1, bex,bey,bew,beh);
          endif

          if( band_flag equals FALSE )then begin
               rsc_pointer[ BAND ].ob_state=NORMAL;
               objc_draw( dialog0, BAND, 1, bax,bay,baw,bah);

               if( ( bor_flag equals FALSE )
                AND( beor_flag equals FALSE) )then begin
                    bwmsk_flag=FALSE;
                    rsc_pointer[ BWMASK ].ob_state=NORMAL;
                    objc_draw( dialog0, BWMASK, 1, bwx,bwy,bww,bwh);
               endif
          endif
     endif

     if( keypress equals BOR )then begin
          bor_flag=( not bor_flag );
          if( bor_flag equals TRUE )then begin
               rsc_pointer[ BOR ].ob_state=SELECTED;
               objc_draw( dialog0, BOR, 1, box,boy,bow,boh);
               band_flag=FALSE;
               rsc_pointer[ BAND ].ob_state=NORMAL;
               objc_draw( dialog0, BAND, 1, bax,bay,baw,bah);
               beor_flag=FALSE;
               rsc_pointer[ BEOR ].ob_state=NORMAL;
               objc_draw( dialog0, BEOR, 1, bex,bey,bew,beh);
          endif

          if( bor_flag equals FALSE  )then begin
               rsc_pointer[ BOR ].ob_state=NORMAL;
               objc_draw( dialog0, BOR, 1, box,boy,bow,boh);

               if( ( band_flag equals FALSE )
                AND( beor_flag equals FALSE) )then begin
                    bwmsk_flag=FALSE;
                    rsc_pointer[ BWMASK ].ob_state=NORMAL;
                    objc_draw( dialog0, BWMASK, 1, bwx,bwy,bww,bwh);
               endif

          endif
     endif

     if( keypress equals BEOR )then begin
          beor_flag=( not beor_flag );
          if( beor_flag equals TRUE )then begin
               rsc_pointer[ BEOR ].ob_state=SELECTED;
               objc_draw( dialog0, BEOR, 1, bex,bey,bew,beh);
               band_flag=FALSE;
               rsc_pointer[ BAND ].ob_state=NORMAL;
               objc_draw( dialog0, BAND, 1, bax,bay,baw,bah);
               bor_flag=FALSE;
               rsc_pointer[ BOR ].ob_state=NORMAL;
               objc_draw( dialog0, BOR, 1, box,boy,bow,boh);
          endif

          if( beor_flag equals FALSE )then begin
               rsc_pointer[ BEOR ].ob_state=NORMAL;
               objc_draw( dialog0, BEOR, 1, bex,bey,bew,beh);

               if( ( band_flag equals FALSE )
                AND( bor_flag equals FALSE ))then begin
                    bwmsk_flag=FALSE;
                    rsc_pointer[ BWMASK ].ob_state=NORMAL;
                    objc_draw( dialog0, BWMASK, 1, bwx,bwy,bww,bwh);
               endif
          endif
     endif

     if( keypress equals BWMASK )then begin

          if( ( band_flag equals TRUE )
            OR(  bor_flag equals TRUE )
            OR( beor_flag equals TRUE ))then begin

               bwmsk_flag=( not bwmsk_flag );

               if( bwmsk_flag equals TRUE )then begin
                    rsc_pointer[ BWMASK ].ob_state=SELECTED;
                    objc_draw( dialog0, BWMASK, 1, bwx,bwy,bww,bwh);
               endif

               if( bwmsk_flag equals FALSE )then begin
                    rsc_pointer[ BWMASK ].ob_state=NORMAL;
                    objc_draw( dialog0, BWMASK, 1, bwx,bwy,bww,bwh);
               endif
          endif
     endif

end

/*-----------------------------------------------*/
adjust( box_addr, object, string, x, y, w, h )
long box_addr;
int  object, x, y, w, h;
char *string;
begin
     set_text( box_addr, object, string );
     objc_draw( box_addr, object, 1, x, y, w, h );
end

/*-----------------------------------------------*/
set_text( tree, object, string )
OBJECT    *tree;
int       object;
char      *string;
begin
     TEDINFO   *obj_spec;

     obj_spec=(TEDINFO *)( tree+object )->ob_spec;
     obj_spec->te_ptext=( string );
     obj_spec->te_txtlen=( strlen( string ));
end

/*-------------------------------------------*/
strcat( to, from )
char *to, *from;
begin
     while ( *to) ++to;
     while ( *to++ = *from++ );
end

/*-------------------------------------------*/
strlen( string )
char *string;
begin
     int  x;

     for( x=0; *string++; ++x );
     return x;
end





