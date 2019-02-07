
/*
 * DEGAS Elite Page Flipper!
 * version 121286
 * File: PAGEFLIP.C
 * (c) 1987 Antic Publishing
 * Written by Patrick Bass
 *
 */

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"
#include "portab.h"

#include "pageflip.h"

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
#define   DELAY          for( delay=0; delay<32767; delay++ );
#define   CONSOL         2
#define   CR             13
#define   LF             10
#define   JIFFYTIME      (.0166667)
#define   MAXSLIDE       119
#define   QUEUESIZE      42
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

/*------------------------*/
extern int  gl_apid;

/*------------------------*/
int  contrl[ 12 ],
     intin[ 128 ], ptsin[ 128 ],
     intout[ 128 ], ptsout[ 128 ],
     work_in[]={ 1,1,1,1,1,1,1,1,1,1,2 }, work_out[ 57 ],
     gem_handle, menu_id, button,
     key0, key1, key2, key3, key4, key5,
     printable, aborted,
     DE_id, menu_id, forever=0, slots, resolution,
     xres, yres, seq_size,

     /* box 1 fsequence box size */
     b1fs_x, b1fs_y, b1fs_w, b1fs_h, 

     /* box 1 TRACK0 box size */
     tx, ty, tw, th, 

     /* box 1 SLIDER box size */
     sx, sy, sw, sh, 

     /* corners of Dialog Box   */
     x0,  y0,  w0,  h0, xd0, yd0, wd0, hd0,
     x1,  y1,  w1,  h1, xd1, yd1, wd1, hd1,

     slider0,

     /* Button activity flags   */
     b1flag, b2flag, b3flag, b4flag,
     b5flag, b6flag, b7flag, b8flag,

     /* Corners of buttons  */
     b1b1x, b1b2x, b1b3x, b1b4x, b1b5x, b1b6x, b1b7x, b1b8x, b1bcx,b1bbx,
     b1b1y, b1b2y, b1b3y, b1b4y, b1b5y, b1b6y, b1b7y, b1b8y, b1bcy,b1bby,
     b1b1w, b1b2w, b1b3w, b1b4w, b1b5w, b1b6w, b1b7w, b1b8w, b1bcw,b1bbw,
     b1b1h, b1b2h, b1b3h, b1b4h, b1b5h, b1b6h, b1b7h, b1b8h, b1bch,b1bbh,

     /* Corners of Exit button */
     b1bxx, b1bxy, b1bxw, b1bxh,

     msgbuff[ 20 ], keycode, ret,
     i, j, k, l, done, slidpos[ 10 ], slidmax[ 10 ];


/*------------------------------------------*/
char rs_strings[]="[1][|I can't operate|without|DEGAS Elite!][ Sorry ]",
     fps[ 50 ],
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
     menu_id=menu_register( gl_apid,"  Page Flipper " );

     result=rsrc_load( "PAGEFLIP.RSC" );
     if( result<0 )then begin
          form_alert( 1,"[1][ Flipper Resource | not found! ][ Danger ]");
     endif

     rsrc_gaddr( 0, 0, &dialog0 );

     slider0=( MAXSLIDE-10 );

     objc_offset( dialog0, FSEQ, &b1fs_x, &b1fs_y );
     b1fs_w=( LWGET( B1OB_W( FSEQ )))-1;
     b1fs_h=( LWGET( B1OB_H( FSEQ )))-1;

     objc_offset( dialog0, TRACK0, &tx, &ty );
     tw=( LWGET( B1OB_W( TRACK0 )))-1;
     th=( LWGET( B1OB_H( TRACK0 )))-1;

     objc_offset( dialog0, BSPEED, &sx, &sy );
     sw=( LWGET( B1OB_W( BSPEED )))-1;
     sh=( LWGET( B1OB_H( BSPEED )))-1;

     for( x=0; x<QUEUESIZE; fsequence[ x++ ]=0 );
     strcat( fsequence, " 1" );
     seq_size=strlen( fsequence );

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
     int  ix, iy, amount, x, pressed, mx, my;
     char  *pointer, z;

     x0=( xres/2 )-10; y0=( yres/2 )-10; w0=h0=20;

     s_ptrs=(char *)(  ( (long)msgbuff[ 3 ]<<16 )
           ORed_with(  ( (long)msgbuff[ 4 ] )ANDed_with 0x0000ffffL) );

     for( ix=0; ix<15; screen[ ix++ ]=ERROR );
     slots=msgbuff[ 5 ];
     for( ix=0; ix<slots; ++ix )begin
          screen[ ix ]=s_ptrs[ ix ];
     next

     wind_update( TRUE );
     form_center( dialog0, &xd1, &yd1, &wd1, &hd1 );

     objc_offset( dialog0, FSEQ, &b1fs_x, &b1fs_y );
     b1fs_w=( LWGET( B1OB_W( FSEQ )))-1;
     b1fs_h=( LWGET( B1OB_H( FSEQ )))-1;

     form_dial( 0, x1, y1, w1, h1, xd1, yd1, wd1, hd1 );
     form_dial( 1, x1, y1, w1, h1, xd1, yd1, wd1, hd1 );

     set1_button_state();

     objc_draw( dialog0, 0, 2, xd1, yd1, wd1, hd1 );

     reset( 0, dialog0, TRACK0, BSPEED, MAXSLIDE, slider0 );
     seq_size=strlen( fsequence );
     adjust( dialog0, FSEQ, fsequence, b1fs_x, b1fs_y, b1fs_w, b1fs_h );

     amount=(float)( (slidmax[ 0 ]-slidpos[ 0 ])+1 );
     amount=(float)(( ((float)60)/amount )+((float).05) );
     ftoa( (float)amount, fps, 1 );
     adjust( dialog0, TRACK0, fps, tx, ty, tw, th ); 

     do begin
          key1=form_do( dialog0, 0 );

          if( key1 equals BPERFORM )then begin
               flip_it();
               objc_change(dialog0,BEXIT,0,b1bxx,b1bxy,b1bxw,b1bxh,0,1);
          endif

          if( ( key1 equals BCLEAR   )OR
              ( key1 equals BBKSPACE )OR
              ( key1 equals B1 )OR( key1 equals B2 )OR
              ( key1 equals B3 )OR( key1 equals B4 )OR
              ( key1 equals B5 )OR( key1 equals B6 )OR
              ( key1 equals B7 )OR( key1 equals B8 ) )then begin

                    filter_key( key1 );
          endif

          if( ( key1 equals SPEEDDN )
            OR( key1 equals SPEEDUP )
            OR( key1 equals BSPEED  ) )then begin

              do_slider(0,dialog0,TRACK0,BSPEED,SPEEDDN,SPEEDUP,key1);
              key1=( FALSE );

          endif

     repeat while( key1 does_not_equal BEXIT );

     rsc_pointer=( OBJECT *)dialog0;
     rsc_pointer[ BEXIT ].ob_state=NORMAL;
     objc_draw( dialog0, BEXIT, 1, b1bxx, b1bxy, b1bxw, b1bxh );

     form_dial( 2, x1, y1, w1, h1, xd1, yd1, wd1, hd1 );
     form_dial( 3, x1, y1, w1, h1, xd1, yd1, wd1, hd1 );
     wind_update( FALSE );
end

/*----------------------------------------------*/
set1_button_state()
begin
     rsc_pointer=( OBJECT *)dialog0;

     objc_offset( dialog0, BCLEAR, &b1bcx, &b1bcy );
     b1bcw=( LWGET( B1OB_W( BCLEAR )))-1;
     b1bch=( LWGET( B1OB_H( BCLEAR )))-1;

     objc_offset( dialog0, BBKSPACE, &b1bbx, &b1bby );
     b1bbw=( LWGET( B1OB_W( BBKSPACE )))-1;
     b1bbh=( LWGET( B1OB_H( BBKSPACE )))-1;

     objc_offset( dialog0, BEXIT, &b1bxx, &b1bxy );
     b1bxw=( LWGET( B1OB_W( BEXIT )))-1;
     b1bxh=( LWGET( B1OB_H( BEXIT )))-1;

     objc_offset( dialog0, B8, &b1b8x, &b1b8y );
     b1b8w=( LWGET( B1OB_W( B8 )))-1;
     b1b8h=( LWGET( B1OB_H( B8 )))-1;
     rsc_pointer[ B8 ].ob_state=SHADOWED;  b8flag=TRUE;
     if( screen[ 12 ] equals 0 )then begin
          rsc_pointer[ B8 ].ob_state=DISABLED;  b8flag=FALSE;
     endif

     objc_offset( dialog0, B7, &b1b7x, &b1b7y );
     b1b7w=( LWGET( B1OB_W( B7 )))-1;
     b1b7h=( LWGET( B1OB_H( B7 )))-1;
     rsc_pointer[ B7 ].ob_state=SHADOWED;  b7flag=TRUE;
     if( screen[ 11 ] equals 0 )then begin
          rsc_pointer[ B7 ].ob_state=DISABLED;  b7flag=FALSE;
     endif

     objc_offset( dialog0, B6, &b1b6x, &b1b6y );
     b1b6w=( LWGET( B1OB_W( B6 )))-1;
     b1b6h=( LWGET( B1OB_H( B6 )))-1;
     rsc_pointer[ B6 ].ob_state=SHADOWED;  b6flag=TRUE;
     if( screen[ 10 ] equals 0 )then begin
          rsc_pointer[ B6 ].ob_state=DISABLED;  b6flag=FALSE;
     endif

     objc_offset( dialog0, B5, &b1b5x, &b1b5y );
     b1b5w=( LWGET( B1OB_W( B5 )))-1;
     b1b5h=( LWGET( B1OB_H( B5 )))-1;
     rsc_pointer[ B5 ].ob_state=SHADOWED;  b5flag=TRUE;
     if( screen[ 9 ] equals 0 )then begin
          rsc_pointer[ B5 ].ob_state=DISABLED;  b5flag=FALSE;
     endif

     objc_offset( dialog0, B4, &b1b4x, &b1b4y );
     b1b4w=( LWGET( B1OB_W( B4 )))-1;
     b1b4h=( LWGET( B1OB_H( B4 )))-1;
     rsc_pointer[ B4 ].ob_state=SHADOWED;  b4flag=TRUE;
     if( screen[ 8 ] equals 0 )then begin
          rsc_pointer[ B4 ].ob_state=DISABLED;  b4flag=FALSE;
     endif

     objc_offset( dialog0, B3, &b1b3x, &b1b3y );
     b1b3w=( LWGET( B1OB_W( B3 )))-1;
     b1b3h=( LWGET( B1OB_H( B3 )))-1;
     rsc_pointer[ B3 ].ob_state=SHADOWED;  b3flag=TRUE;
     if( screen[ 7 ] equals 0 )then begin
          rsc_pointer[ B3 ].ob_state=DISABLED;  b3flag=FALSE;
     endif

     objc_offset( dialog0, B2, &b1b2x, &b1b2y );
     b1b2w=( LWGET( B1OB_W( B2 )))-1;
     b1b2h=( LWGET( B1OB_H( B2 )))-1;
     rsc_pointer[ B2 ].ob_state=SHADOWED;  b2flag=TRUE;
     if( screen[ 2 ] equals 0 )then begin
          rsc_pointer[ B2 ].ob_state=DISABLED;  b2flag=FALSE;
     endif

     objc_offset( dialog0, B1, &b1b1x, &b1b1y );
     b1b1w=( LWGET( B1OB_W( B1 )))-1;
     b1b1h=( LWGET( B1OB_H( B1 )))-1;
     rsc_pointer[ B1 ].ob_state=SHADOWED;  b1flag=TRUE;
end
    
/*----------------------------------------------*/
flip_it()
begin
     int  x, y, pressed, mx, my, iy,
          frame, len_sequence, index, exit;

     exit=FALSE;
     len_sequence=strlen( fsequence )+1;
     v_hide_c( gem_handle );

     if( len_sequence > 2 )then begin
          do begin
               for( frame=1; frame<len_sequence; frame++ )begin

                    x=( fsequence[ frame ]-48 );
                    if( ( x>0 )AND( x<9 ) )then begin
                         if( x >= 3 )then x=x+4;

                         Setscreen( (long)screen[ x ], (long)screen[ x ], -1);

                         for( y=0; y<(MAXSLIDE-slidpos[ 0 ])+1; y++ )begin
                              Vsync();
                              graf_mkstate( &mx, &my, &pressed, &my );
                              if( pressed )then begin
                                   y=(( MAXSLIDE-slidpos[ 0 ] )+2 );
                                   frame=( len_sequence+1 );
                                   exit=TRUE;
                              endif
                         next
                    endif
               next
          repeat while( exit equals FALSE );
     endif

     v_show_c( gem_handle );
     if( len_sequence < 3 )then begin
          form_alert( 1, "[1][ Please select at least | one picture to flip. ][ Exit ]" );
     endif

     Setscreen( (long)screen[ 0 ], (long)screen[ 0 ], -1 );
end

/*---------------------------------------------------------*/
filter_key( keypress )
int  keypress;
begin
     int x;

     rsc_pointer=( OBJECT *)dialog0;

     if( keypress equals BCLEAR )then begin
          rsc_pointer[ BCLEAR ].ob_state=SELECTED;
          objc_draw( dialog0, BCLEAR, 1, b1bcx,b1bcy,b1bcw,b1bch );
          for( x=0; x<QUEUESIZE; fsequence[ x++ ]=0 );
          strcat( fsequence, " " );
          seq_size=strlen( fsequence );
          adjust( dialog0, FSEQ, fsequence,
                    b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          rsc_pointer[ BCLEAR ].ob_state=SHADOWED;
          objc_draw( dialog0, BCLEAR, 1, b1bcx,b1bcy,b1bcw,b1bch );
     endif

     if( keypress equals BBKSPACE )then begin
          rsc_pointer[ BBKSPACE ].ob_state=SELECTED;
          objc_draw(dialog0,BBKSPACE,1,b1bbx,b1bby,b1bbw,b1bbh);
          if( seq_size>1 )then begin
               seq_size=( strlen( fsequence ) )-1;
               fsequence[ seq_size ]=0;
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ BBKSPACE ].ob_state=SHADOWED;
          objc_draw(dialog0,BBKSPACE,1,b1bbx,b1bby,b1bbw,b1bbh);
     endif

     if( keypress equals B1 )then begin
          rsc_pointer[ B1 ].ob_state=SELECTED;
          objc_draw(dialog0,B1,1,b1b1x,b1b1y,b1b1w,b1b1h);
          if( seq_size<QUEUESIZE )then begin
               strcat( fsequence, "1" );
               seq_size=strlen( fsequence );
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ B1 ].ob_state=SHADOWED;
          objc_draw(dialog0,B1,1,b1b1x,b1b1y,b1b1w,b1b1h);
     endif 

     if(( keypress equals B2 )AND( b2flag equals TRUE ))then begin
          rsc_pointer[ B2 ].ob_state=SELECTED;
          objc_draw(dialog0,B2,1,b1b2x,b1b2y,b1b2w,b1b2h);
          if( seq_size<QUEUESIZE )then begin
               strcat( fsequence, "2" );
               seq_size=strlen( fsequence );
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ B2 ].ob_state=SHADOWED;
          objc_draw(dialog0,B2,1,b1b2x,b1b2y,b1b2w,b1b2h);
     endif 

     if(( keypress equals B3 )AND( b3flag equals TRUE ))then begin
          rsc_pointer[ B3 ].ob_state=SELECTED;
          objc_draw(dialog0,B3,1,b1b3x,b1b3y,b1b3w,b1b3h);
          if( seq_size<QUEUESIZE )then begin
               strcat( fsequence, "3" );
               seq_size=strlen( fsequence );
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ B3 ].ob_state=SHADOWED;
          objc_draw(dialog0,B3,1,b1b3x,b1b3y,b1b3w,b1b3h);
     endif

     if(( keypress equals B4 )AND( b4flag equals TRUE ))then begin
          rsc_pointer[ B4 ].ob_state=SELECTED;
          objc_draw(dialog0,B4,1,b1b4x,b1b4y,b1b4w,b1b4h);
          if( seq_size<QUEUESIZE )then begin
               strcat( fsequence, "4" );
               seq_size=strlen( fsequence );
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ B4 ].ob_state=SHADOWED;
          objc_draw(dialog0,B4,1,b1b4x,b1b4y,b1b4w,b1b4h);
     endif 

     if(( keypress equals B5 )AND( b5flag equals TRUE ))then begin
          rsc_pointer[ B5 ].ob_state=SELECTED;
          objc_draw(dialog0,B5,1,b1b5x,b1b5y,b1b5w,b1b5h);
          if( seq_size<QUEUESIZE )then begin
               strcat( fsequence, "5" );
               seq_size=strlen( fsequence );
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ B5 ].ob_state=SHADOWED;
          objc_draw(dialog0,B5,1,b1b5x,b1b5y,b1b5w,b1b5h);
     endif 

     if(( keypress equals B6 )AND( b6flag equals TRUE ))then begin
          rsc_pointer[ B6 ].ob_state=SELECTED;
          objc_draw(dialog0,B6,1,b1b6x,b1b6y,b1b6w,b1b6h);
          if( seq_size<QUEUESIZE )then begin
               strcat( fsequence, "6" );
               seq_size=strlen( fsequence );
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ B6 ].ob_state=SHADOWED;
          objc_draw(dialog0,B6,1,b1b6x,b1b6y,b1b6w,b1b6h);
     endif 

     if(( keypress equals B7 )AND( b7flag equals TRUE ))then begin
          rsc_pointer[ B7 ].ob_state=SELECTED;
          objc_draw(dialog0,B7,1,b1b7x,b1b7y,b1b7w,b1b7h);
          if( seq_size<QUEUESIZE )then begin
               strcat( fsequence, "7" );
               seq_size=strlen( fsequence );
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ B7 ].ob_state=SHADOWED;
          objc_draw(dialog0,B7,1,b1b7x,b1b7y,b1b7w,b1b7h);
     endif 

     if(( keypress equals B8 )AND( b8flag equals TRUE ))then begin
          rsc_pointer[ B8 ].ob_state=SELECTED;
          objc_draw(dialog0,B8,1,b1b8x,b1b8y,b1b8w,b1b8h);
          if( seq_size<QUEUESIZE )then begin
               strcat( fsequence, "8" );
               seq_size=strlen( fsequence );
               adjust( dialog0, FSEQ, fsequence,
                         b1fs_x, b1fs_y, b1fs_w, b1fs_h );
          endif
          rsc_pointer[ B8 ].ob_state=SHADOWED;
          objc_draw(dialog0,B8,1,b1b8x,b1b8y,b1b8w,b1b8h);
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

/*-----------------------------------------------*/
reset( number, tree, track, slide, maximum, initial )
int number, tree[][12], track, slide, maximum, initial;
begin
     float work1, work2;

     slidmax[ number ]=maximum;
     slidpos[ number ]=initial;
     work1=( tree[ track ][10]-tree[ slide ][10] );
     work2=maximum;
     work1/=work2;
     slidstep[ number ]=work1;
     work2=initial;
     slidacc[ number ]=work1*work2;
     tree[ slide ][8]=slidacc[ number ];
     objc_draw( tree, track, 1, tree[0][8], tree[0][9],
                                  tree[0][10],tree[0][11] );
end

/*------------------------------------------------------*/
do_slider( number, tree, track, slide, left, right, which )
int  tree[][12], track, slide, left, right, which;

begin
     int       tempx, tempy, sbasex, sbasey, tbasex, tbasey,
               omx, omy, mx, my, pressed, dum,
               box[ 40 ], xoffset;

     char      temp[ 30 ];

     float     amount;



     if( which equals right )then begin
          if( slidpos[ number ]<slidmax[ number ] )then begin
               slidacc[ number ]+=slidstep[ number ];
               slidpos[ number ]++;

               amount=(float)( (slidmax[ number ]-slidpos[ number ])+1 );
               amount=(float)(( ((float)60)/amount )+((float).05) );

               if( amount>9 )then begin
                    ftoa( (float)amount, fps, 0 );
               endif
               if( (amount>2)AND(amount<10) )then begin
                    ftoa( (float)amount, fps, 1 );
               endif
               if( (amount>1)AND(amount<2) )then begin
                    ftoa( (float)amount, fps, 2 );
               endif
               if( amount<1 )then begin
                    ftoa( (float)amount, fps, 3 );
               endif
               strcat( fps, " FPS" );

               set_text( tree, track, fps );

               tree[ slide ][ 8 ]=slidacc[ number ];
               objc_draw( tree, track, 1, tree[0][8], tree[0][9],
                                          tree[0][10],tree[0][11] );
          endif
     endif


     if( which equals left )then begin
          if( slidpos[ number ]>0 )then begin
               slidacc[ number ]-=slidstep[ number ];
               slidpos[ number ]--;

               amount=(float)( (slidmax[ number ]-slidpos[ number ])+1 );
               amount=(float)(( ((float)60)/amount )+((float).05) );

               if( amount>9 )then begin
                    ftoa( (float)amount, fps, 0 );
               endif
               if( (amount>2)AND(amount<10) )then begin
                    ftoa( (float)amount, fps, 1 );
               endif
               if( (amount>1)AND(amount<2) )then begin
                    ftoa( (float)amount, fps, 2 );
               endif
               if( amount<1 )then begin
                    ftoa( (float)amount, fps, 3 );
               endif
               strcat( fps, " FPS" );

               set_text( tree, track, fps );

               tree[ slide ][ 8 ]=slidacc[ number ];
               objc_draw( tree, track, 1, tree[0][8], tree[0][9],
                                          tree[0][10],tree[0][11] );
          endif
     endif


     if( which equals slide )then begin

          vsf_interior( gem_handle, 2 );
          vsf_style( gem_handle, 8 );
          vsf_color( gem_handle, 0 );
          vswr_mode( gem_handle, 3 );

          objc_offset( dialog0, BSPEED, &sx, &sy );
          sw=( LWGET( B1OB_W( BSPEED )))-1;
          sh=( LWGET( B1OB_H( BSPEED )))-1;

          objc_offset( dialog0, TRACK0, &tx, &ty );
          tw=( LWGET( B1OB_W( TRACK0 )))-1;
          th=( LWGET( B1OB_H( TRACK0 )))-1;

          objc_offset( tree, slide, &sbasex, &sbasey );
          objc_offset( tree, track, &tbasex, &tbasey );
          graf_mkstate( &mx, &my, &pressed, &my );
          xoffset=( mx-sbasex );

          do begin
               graf_mkstate( &mx, &my, &pressed, &my );

               mx=( mx-xoffset );

               if( (mx>tx)AND(mx<(tx+tw-sw)) )then begin

                    box[ 0 ]=mx; box[ 1 ]=sy;
                    box[ 2 ]=mx+sw; box[ 3 ]=sy;
                    box[ 4 ]=mx+sw; box[ 5 ]=sy+sh;
                    box[ 6 ]=mx; box[ 7 ]=sy+sh;
                    box[ 8 ]=mx; box[ 9 ]=sy;

                    v_hide_c( gem_handle );
                    v_pline( gem_handle, 5, box );
                    v_pline( gem_handle, 5, box );
                    v_show_c( gem_handle );
               endif                              

          repeat while( pressed );

          tempx=( mx );

          if( tempx does_not_equal sbasex )then begin
               if( tempx+sw > tbasex+tw )then begin
                    tempx=( tbasex+tw-sw );
               endif
               if( tempx < tbasex )then begin
                    tempx=( tbasex );
               endif
               slidacc[ number ]=tempx-tbasex;
               slidpos[ number ]=slidacc[ number ]/slidstep[ number ];
               slidacc[ number ]=slidpos[ number ];
               slidacc[ number ]*=slidstep[ number ];

               amount=(float)( (slidmax[ number ]-slidpos[ number ])+1 );
               amount=(float)(( ((float)60)/amount )+((float).05) );

               if( amount>9 )then begin
                    ftoa( (float)amount, fps, 0 );
               endif
               if( (amount>2)AND(amount<10) )then begin
                    ftoa( (float)amount, fps, 1 );
               endif
               if( (amount>1)AND(amount<2) )then begin
                    ftoa( (float)amount, fps, 2 );
               endif
               if( amount<1 )then begin
                    ftoa( (float)amount, fps, 3 );
               endif
               strcat( fps, " FPS" );
               set_text( tree, track, fps );

               tree[ slide ][ 8 ]=slidacc[ number ];
               objc_draw( tree, track, 1, tree[0][8],tree[0][9],
                                          tree[0][10],tree[0][11]);
          endif
     endif

end


