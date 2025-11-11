   ********************************************************
   *  v_bit_image       Chet Walters         09-03-89     *
   *                                                      *
   *  This program is patterened after the v_bit program  *
   *  uploaded on GEnie on 09-03-89 by Craig Daymon. With *
   *  additional information gleaned from various other   *
   *  sources it's coded here with DEVPAC from Michtron.  *
   *                                                      *
   *  The program requires GDOS or G+PLUS be on board     *
   *  with a printer driver installed as device #21.      *
   *                                                      *
   *  The v_bit_image macro here defined can be trans-    *
   *  ferred to any macro assembler.  The VID params      *
   *  and intin, intout, ptsin, control arrays conform    *
   *  to GEM standards and need not be 'verbose' in       *
   *  this listing.  Other unlisted macro calls conform   *
   *  to GEM and should be clear to anyone perusing       *
   *  this source.                                        *
   ********************************************************

   opt a+ o+

   OUTPUT   .PRG   

   include  gemmacro.s


push macro
      move.\0  \1,-(sp)
   endm

********** v-bit-image macro define **********************

; this macro does no error checking! clobbers d0-d2/a0-a2

; call with - vdihandle,filename,num_pts,aspect,xscal,yscal,
;             halign,valign,minx,miny,maxx,maxy

; <order here seems cryptic but conforms with documented 'C' calls>

;  vdihandle = usually current_handle or result from v_opnwk 

;  filename = address of filename nul terminated

;  num_pts  0 = take from file  1 = upper left then calc from file
;           2 = use sent points to define rectangle

;  aspect   0 = ignore ratio  1 = preserve ratio

;  xscal    0 = integral  1 = fractional
;  yscal    ditto

;  halign   0 = block left  1 = centered  2 = block right
;  valign   0 = block top   1 = centered  2 = block bottom

;  minx     minimum x for align
;  miny     minimum y for align
;  maxx     maximum x for align
;  maxy     maximum x for align


v_bit_image macro
      move.w   #5,contrl      opcode
      move.w   #23,contrl5    funtion id#
      clr.w    contrl2
      clr.w    contrl4
      clr.w    contrl3        safety
      move.w   \1,contrl6     store handle
      move.w   \3,contrl1     where to get points
      move.w   \4,intin       keep aspect?
      move.w   \5,intin+2     xscal
      move.w   \6,intin+4     yscal
      move.w   \7,intin+6     halign
      move.w   \8,intin+8     valign
      move.w   \9,ptsin       minx
      move.w   \a,ptsin+2     miny
      move.w   \b,ptsin+4     maxx
      move.w   \c,ptsin+6     maxy
      
      move.l   \2,a0          pointer to filename
      move.l   #intin+10,a1   pointer to destination
      clr.l    d0             counter
\@    addq.b   #1,d0          here we store the filename
      addq.l   #1,a1          in the least significant bytes of
      move.b   (a0)+,(a1)+    the intin array (VDI likes words)
      bne      \@
      addq.b   #4,d0          add '5' to the words of fname
      move.w   d0,contrl3     set length of entire intin array
      move.l   #vdi_params,d1 pointer to our arrays
      move.w   #115,d0        VDI opcode
      trap  #2                do it!

   endm     


********************************************************


   move.l   4(a7),a3    
   move.l   #ustack,a7
   move.l   $c(a3),d0      
   add.l    $14(a3),d0     
   add.l    $1c(a3),d0     
   add.l    #$100,d0    
   push.l   d0
   push.l   a3
   push.w   #0
   push.w   #$4a
   trap  #1
   lea      12(sp),sp
   
   appl_init
   move.w   d0,ap_id    

   graf_mouse  #0

chk_gdos
   move.w   #-2,d0
   trap  #2
   cmp.w    #-2,d0
   bne   gdos_ok
   form_alert  #1,#nogdos
   bra   byebye

gdos_ok
   push.w  #$19            Get current drive
   trap #1
   addq.l  #2,sp
   move.w  d0,olddrv       Save for later restore
   add.b   #65,d0
   move.l  #imgdir,a3      For personal use only
   move.b  d0,(a3)+
   move.l  #imgext,a0
   move.w  #6,d5
cpydir:
   move.b  (a0)+,(a3)+     Copy the default paths into
   dbf     d5,cpydir       our working directory area

   graf_handle             just for curiousity
   move.w   int_out,current_handle

   move.w   #21,intin         set device #21 printer
   move.w   #1,intin+2        init block (verbose for clarity)
   move.w   #1,intin+4
   move.w   #1,intin+6
   move.w   #1,intin+8
   move.w   #1,intin+10
   move.w   #1,intin+12
   move.w   #1,intin+14
   move.w   #1,intin+16
   move.w   #1,intin+18
   move.w   #2,intin+20
   move.w   #2,intin+22

   v_opnwk                    open real workstation

   move.w   current_handle,d0 take a look
   move.w   intout+6,mic_w    save device micron width
   move.w   intout+8,mic_h    save device micron height

   move.l   #25400,d1         total microns/inch (universal truth)
   divu     mic_w,d1          divided by device pixel width
   asl.w    #3,d1             times 8 is 8 inch page
   move.w   d1,maxx           save big x
   move.l   #25400,d1         same for y
   divu     mic_h,d1
   mulu     #10,d1            10 inch high page
   move.w   d1,maxy           save big y

gfile
   fsel_input #imgdir,#imname
   tst.b d0
   beq   exit

   move.l   #imgdir,a0         macro needs entire path & name
   move.l   #filename,a1
   bsr      copytoz
toslash
   cmp.b    #'\',-(a1)
   bne      toslash
   addq.l   #1,a1
   move.l   #imname,a0
   bsr      copytoz
   clr.b    imname            zero name for next time    

******** call with - vdihandle,filename,num_pts,aspect,xscal,yscal,
*******              halign,valign,minx,miny,maxx,maxy

   v_bit_image current_handle,#filename,#2,#1,#0,#0,#1,#1,minx,miny,maxx,maxy 

   v_updwk                    call update work to do it
   v_clrwk                    when done clear it
   bra   gfile                go for another file

exit
   v_clswk
    
   push.w  olddrv         Reset current drive and pathname
   push.w  #$0E
   trap #1
   addq.l  #4,sp
   push.l  #defpth
   push.w  #$3B
   trap #1
   addq.l  #6,sp

byebye
   appl_exit
   push.w   #0
   trap  #1


******** SUBROUTINES

copytoz ;------ enter with source a0 dest a1
   move.b   (a0)+,(a1)+
   bne      copytoz
   rts

   SECTION  DATA
   even

imgext   dc.b  ':\*.IMG',0
defpth   dc.b  ':\*.*',0

nogdos
   dc.b  '[3][   GDOS not found!|'
   dc.b  '                        |'
   dc.b  'Must load GDOS or G+Plus|'
   dc.b  'with device #21 as printer][    OH    ]',0

   SECTION  BSS
   even

ap_id    ds.w 1

********** array for holding  v_bit_image values
mic_w    ds.w  1     device micron width
mic_h    ds.w  1     device micron height
minx     ds.w  1     left x coord
miny     ds.w  1     top y coord
maxx     ds.w  1     maximum x coord
maxy     ds.w  1     maximum y coord

olddrv   ds.w  1
imgdir   ds.b    128
imname   ds.b     16

filename ds.b  128

   ds.l  100         
ustack   ds.w  1     

* include runtimes

   include aeslib.s
   include vdilib.s
