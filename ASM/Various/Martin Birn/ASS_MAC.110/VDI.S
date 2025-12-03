;ASS_MAC Version 1.10
;====================
;
;Assembler:     GFA, Version 1.5
;Versionsdatum: 13.10.1990
;
;Macros fÅr:    GEM-VDI
;
;(C) 1989,90 by
;Martin Birn, Knoblochstraûe 51, D-7100 Heilbronn
;
;NÑhere Informationen enthÑlt die Datei LIESMICH.DOK.
;-------------------------------------------------------------------------------

                .BSS 

;
;VDI-Parameterblock
;
contrl:         .DS.w 12
intin:          .DS.w 256     ;ggf. abÑndern (STRINGLéNGE!!!)
ptsin:          .DS.w 8
intout:         .DS.w 256     ;ggf. abÑndern (STRINGLéNGE!!!)
ptsout:         .DS.w 12

                .DATA 

pb:             .DC.l contrl,intin,ptsin,intout,ptsout

                .TEXT 

;
;Hilfsmacro VDI
;

                .MACRO VDI opcode,c1,c3
                move.w        \opcode,(a0)
                move.w        \c1,2(a0)
                move.w        \c3,6(a0)
                jsr           vditrap
                .ENDM 

;
;Hilfsmacro VQ_GDOS
;
;liefert 0, falls GDOS nicht installiert ist.

                .MACRO VQ_GDOS
                move.w        #-2,d0
                trap          #2
                cmpi.w        #-2,d0
                sne           d0
                ext.w         d0
                .ENDM 

;
;Funktionen
;

                .MACRO V_OPNWK work_in
                move.l        \work_in,pb+4
                lea.l         contrl,a0
                VDI           #1,#6,#11
                move.l        #intin,pb+4
                .ENDM 

                .MACRO V_CLSWK handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #2,#0,#0
                .ENDM 

                .MACRO V_OPNVWK work_in,handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                move.l        \work_in,pb+4
                VDI           #100,#6,#11
                move.l        #intin,pb+4
                .ENDM 

                .MACRO V_CLSVWK handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #101,#0,#0
                .ENDM 

                .MACRO V_CLRWK handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #3,#0,#0
                .ENDM 

                .MACRO V_UPDWK handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #4,#0,#0
                .ENDM 

                .MACRO VST_LOAD_FONTS handle,select
                move.w        \select,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #119,#0,#1
                .ENDM 

                .MACRO VST_UNLOAD_FONTS handle,select
                move.w        \select,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #120,#0,#1
                .ENDM 

                .MACRO VS_CLIP handle,clip_flag,pxyarray
                move.w        \clip_flag,intin
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #129,#2,#1
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_PLINE handle,count,pxyarray
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #6,\count,#0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_PMARKER handle,count,pxyarray
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #7,\count,#0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_GTEXT handle,x,y,string
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)
                movea.l       \string,a0
                lea.l         intin,a1
                move.w        #-1,d0
                clr.w         d1
.\~sl:          addq.w        #1,d0
                move.b        (a0)+,d1
                move.w        d1,(a1)+
                bne           .\~sl
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #8,#1,d0
                .ENDM 

                .MACRO V_FILLAREA handle,count,pxyarray
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #9,\count,#0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_CELLARRAY handle,pxyarray,row_length,el_used,num_rows,wrt_mode,colarray
                move.l        \colarray,pb+4
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                move.w        \row_length,14(a0)
                move.w        \el_used,16(a0)
                move.w        \num_rows,18(a0)
                move.w        \wrt_mode,20(a0)
                move.w        \num_rows,d0
                mulu.w        \row_length,d0
                VDI           #110,#2,d0
                move.l        #intin,pb+4
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_CONTOURFILL handle,x,y,index
                move.w        \index,intin
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #103,#1,#1
                .ENDM 

                .MACRO VR_RECFL handle,pxyarray
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #114,#2,#0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_BAR handle,pxyarray
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        #1,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#2,#0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_ARC handle,x,y,radius,begang,endang
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)+
                clr.l         (a0)+
                clr.l         (a0)+
                move.w        \radius,(a0)+
                clr.w         (a0)
                lea.l         intin,a0
                move.w        \begang,(a0)+
                move.w        \endang,(a0)
                lea.l         contrl,a0
                move.w        #2,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#4,#2
                .ENDM 

                .MACRO V_PIE handle,x,y,radius,begang,endang
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)+
                clr.l         (a0)+
                clr.l         (a0)+
                move.w        \radius,(a0)+
                clr.w         (a0)
                lea.l         intin,a0
                move.w        \begang,(a0)+
                move.w        \endang,(a0)
                lea.l         contrl,a0
                move.w        #3,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#4,#2
                .ENDM 

                .MACRO V_CIRCLE handle,x,y,radius
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)+
                clr.l         (a0)+
                move.w        \radius,(a0)+
                clr.w         (a0)
                lea.l         contrl,a0
                move.w        #4,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#3,#0
                .ENDM 

                .MACRO V_ELLIPSE handle,x,y,xradius,yradius
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)+
                move.w        \xradius,(a0)+
                move.w        \yradius,(a0)
                lea.l         contrl,a0
                move.w        #5,10(a0)
                move.w        \handle,12(a0)
                VDI           11,2,0
                .ENDM 

                .MACRO V_ELLARC handle,x,y,xradius,yradius,begang,endang
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)+
                move.w        \xradius,(a0)+
                move.w        \yradius,(a0)
                lea.l         intin,a0
                move.w        \begang,(a0)+
                move.w        \endang,(a0)
                lea.l         contrl,a0
                move.w        #6,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#2,#2
                .ENDM 

                .MACRO V_ELLPIE handle,x,y,xradius,yradius,begang,endang
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)+
                move.w        \xradius,(a0)+
                move.w        \yradius,(a0)
                lea.l         intin,a0
                move.w        \begang,(a0)+
                move.w        \endang,(a0)
                lea.l         contrl,a0
                move.w        #7,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#2,#2
                .ENDM 

                .MACRO V_RBOX handle,pxyarray
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        #8,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#2,#0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_RFBOX handle,pxyarray
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        #9,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#2,#0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_JUSTIFIED handle,x,y,string,length,word_space,char_space
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)+
                move.w        \length,(a0)+
                clr.w         (a0)
                movea.l       \string,a0
                lea.l         intin,a1
                move.w        \word_space,(a0)+
                move.w        \char_space,(a0)+
                move.w        #1,d0
                clr.w         d1
.\~sl:          addq.w        #1,d0
                move.b        (a0)+,d1
                move.w        d1,(a1)+
                bne           .\~sl
                lea.l         contrl,a0
                move.w        #10,10(a0)
                move.w        \handle,12(a0)
                VDI           #11,#2,d0
                .ENDM 

                .MACRO VSWR_MODE handle,mode
                move.w        \mode,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #32,#0,#1
                .ENDM 

                .MACRO VS_COLOR handle,index,rgb_in
                lea.l         intin,a0
                move.w        \index,(a0)+
                movea.w       rgb_in,a1
                move.l        (a1)+,(a0)+
                move.w        (a1)+,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #14,#0,#4
                .ENDM 

                .MACRO VSL_TYPE handle,style
                move.w        \style,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #15,#0,#1
                .ENDM 

                .MACRO VSL_UDSTY handle,pattern
                move.w        \pattern,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #113,#0,#1
                .ENDM 

                .MACRO VSL_WIDTH handle,width
                lea.l         ptsin,a0
                move.w        \width,(a0)+
                clr.w         (a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #16,#1,#0
                .ENDM 

                .MACRO VSL_COLOR handle,color_index
                move.w        \color_index,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #17,#0,#1
                .ENDM 

                .MACRO VSL_ENDS handle,beg_style,end_style
                lea.l         intin,a0
                move.w        \beg_style,(a0)+
                move.w        \end_style,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #108,#0,#2
                .ENDM 

                .MACRO VSM_TYPE handle,symbol
                move.w        \symbol,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #18,#0,#1
                .ENDM 

                .MACRO VSM_HEIGHT handle,height
                lea.l         ptsin,a0
                clr.w         (a0)+
                move.w        \height,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #19,#1,#0
                .ENDM 

                .MACRO VSM_COLOR handle,color_index
                move.w        \color_index,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #20,#0,#1
                .ENDM 

                .MACRO VST_HEIGHT handle,height
                lea.l         ptsin,a0
                clr.w         (a0)+
                move.w        \height,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #12,#1,#0
                .ENDM 

                .MACRO VST_POINT handle,point
                move.w        \point,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #107,#0,#1
                .ENDM 

                .MACRO VST_ROTATION handle,angle
                move.w        \angle,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #13,#0,#1
                .ENDM 

                .MACRO VST_FONT handle,font
                move.w        \font,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #21,#0,#1
                .ENDM 

                .MACRO VST_COLOR handle,color_index
                move.w        \color_index,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #22,#0,#1
                .ENDM 

                .MACRO VST_EFFECTS handle,effect
                move.w        \effect,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #106,#0,#1
                .ENDM 

                .MACRO VST_ALIGNMENT handle,hor_in,vert_in
                lea.l         intin,a0
                move.w        \hor_in,(a0)+
                move.w        \vert_in,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #39,#0,#2
                .ENDM 

                .MACRO VSF_INTERIOR handle,style
                move.w        \style,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #23,#0,#1
                .ENDM 

                .MACRO VSF_STYLE handle,style_index
                move.w        \style_index,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #24,#0,#1
                .ENDM 

                .MACRO VSF_COLOR handle,color_index
                move.w        \color_index,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #25,#0,#1
                .ENDM 

                .MACRO VSF_PERIMETER handle,per_vis
                move.w        \per_vis,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #104,#0,#1
                .ENDM 

                .MACRO VSF_UPDAT handle,pfill_pat,planes
                move.l        \pfill_pat,pb+4
                move.w        \planes,d0
                lsl.w         #4,d0
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #112,#0,d0
                .ENDM 

                .MACRO VRO_CPYFM handle,wr_mode,pxyarray,psrcmfdb,pdesmfdb
                move.w        \wr_mode,intin
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.l        \psrcmfdb,14(a0)
                move.l        \pdesmfdb,18(a0)
                move.w        \handle,12(a0)
                VDI           #109,#4,#1
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO VRT_CPYFM handle,wr_mode,pxyarray,psrcmfdb,pdesmfdb,color_index
                lea.l         intin,a0
                move.w        \wr_mode,(a0)+
                movea.l       \color_index,a1
                move.l        (a1),(a0)
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.l        \psrcmfdb,14(a0)
                move.l        \pdesmfdb,18(a0)
                move.w        \handle,12(a0)
                VDI           #121,#4,#3
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO VR_TRNFM handle,psrcmfdb,pdesmfdb
                lea.l         contrl,a0
                move.l        \psrcmfdb,14(a0)
                move.l        \pdesmfdb,18(a0)
                move.w        \handle,12(a0)
                VDI           #110,#0,#0
                .ENDM 

                .MACRO V_GET_PIXEL handle,x,y
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #105,#1,#0
                .ENDM 

                .MACRO VSIN_MODE handle,dev_type,mode
                lea.l         intin,a0
                move.w        \dev_type,(a0)+
                move.w        \mode,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #33,#0,#2
                .ENDM 

                .MACRO VRQ_LOCATOR handle,x,y
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #28,#1,#0
                .ENDM 

                .MACRO VSM_LOCATOR handle,x,y
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #28,#1,#0
                .ENDM 

                .MACRO VRQ_VALUATOR handle,valuator_in
                move.w        \valuator_in,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #29,#0,#1
                .ENDM 

                .MACRO VSM_VALUATOR handle,val_in
                move.w        \val_in,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #29,#0,#1
                .ENDM 

                .MACRO VRQ_CHOICE handle,ch_in
                move.w        \ch_in,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #30,#0,#1
                .ENDM 

                .MACRO VSM_CHOICE handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #30,#0,#0
                .ENDM 

                .MACRO VRQ_STRING handle,max_length,echo_mode,echo_xy
                lea.l         intin,a0
                move.w        \max_length,(a0)+
                move.w        \echo_mode,(a0)
                move.l        \echo_xy,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #31,\echo_mode,#2
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO VSM_STRING handle,max_length,echo_mode,echo_xy
                lea.l         intin,a0
                move.w        \max_length,(a0)+
                move.w        \echo_mode,(a0)
                move.l        \echo_xy,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #31,\echo_mode,#2
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO VSC_FORM handle,pcur_form
                move.l        \pcur_form,pb+4
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #111,#0,#37
                move.l        #intin,pb+4
                .ENDM 

                .MACRO VEX_TIMV handle,tim_addr
                lea.l         contrl,a0
                move.l        \tim_adr,14(a0)
                move.w        \handle,12(a0)
                VDI           #118,#0,#0
                .ENDM 

                .MACRO V_SHOW_C handle,reset
                move.w        \reset,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #122,#0,#1
                .ENDM 

                .MACRO V_HIDE_C handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #123,#0,#0
                .ENDM 

                .MACRO VQ_MOUSE handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #124,#0,#0
                .ENDM 

                .MACRO VEX_BUTV handle,pusrcode
                lea.l         contrl,a0
                move.l        \pusrcode,14(a0)
                move.w        \handle,12(a0)
                VDI           #125,#0,#0
                .ENDM 

                .MACRO VEX_MOTV handle,pusrcode
                lea.l         contrl,a0
                move.l        \pusrcode,14(a0)
                move.w        \handle,12(a0)
                VDI           #126,#0,#0
                .ENDM 

                .MACRO VEX_CURV handle,pusrcode
                lea.l         contrl,a0
                move.l        \pusrcode,14(a0)
                move.w        \handle,12(a0)
                VDI           #127,#0,#0
                .ENDM 

                .MACRO VQ_KEY_S handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #128,#0,#0
                .ENDM 

                .MACRO VQ_EXTND handle,owflag
                move.w        \owflag,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #102,#0,#1
                .ENDM 

                .MACRO VQ_COLOR handle,color_index,set_flag
                lea.l         intin,a0
                move.w        color_index,(a0)+
                move.w        \set_flag,(a0)
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #26,#0,#2
                .ENDM 

                .MACRO VQL_ATTRIBUTES handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #102,#0,#0
                .ENDM 

                .MACRO VQM_ATTRIBUTES handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #36,#0,#0
                .ENDM 

                .MACRO VQF_ATTRIBUTES handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #37,#0,#0
                .ENDM 

                .MACRO VQT_ATTRIBUTES handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #38,#0,#0
                .ENDM 

                .MACRO VQT_EXTENT handle,string
                movea.l       \string,a0
                lea.l         intin,a1
                move.w        #-1,d0
                clr.w         d1
.\~sl:          addq.w        #1,d0
                move.b        (a0)+,d1
                move.w        d1,(a1)+
                bne           .\~sl
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #116,#0,d0
                .ENDM 

                .MACRO VQT_WIDTH handle,element_num
                move.w        \element_num,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #130,#0,#1
                .ENDM 

                .MACRO VQ_CELLARRAY handle,pxyarray,row_length,num_rows
                move.l        \pxyarray,pb+8
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                move.w        \row_length,14(a0)
                move.w        \num_rows,16(a0)
                VDI           #27,#2,d0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO VQIN_MODE handle,dev_type
                move.w        \dev_type,intin
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #115,#0,#1
                .ENDM 

                .MACRO VQT_FONTINFO handle
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #131,#0,#0
                .ENDM 

;ACHTUNG!!!
;Die folgende Funktion ist erst ab GEM 2.0 implementiert!

                .MACRO VQT_JUSTIFIED handle,x,y,string,length,word_space,char_space
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)+
                move.w        \length,(a0)+
                clr.w         (a0)
                movea.l       \string,a0
                lea.l         intin,a1
                move.w        \word_space,(a0)+
                move.w        \char_space,(a0)+
                move.w        #1,d0
                clr.w         d1
.\~sl:          addq.w        #1,d0
                move.b        (a0)+,d1
                move.w        d1,(a1)+
                bne           .\~sl
                lea.l         contrl,a0
                move.w        \handle,12(a0)
                VDI           #132,#2,d0
                .ENDM 


;
;ESCAPE-FUNKTIONEN
;

                .MACRO VQ_CHCELLS handle
                lea.l         contrl,a0
                move.w        #1,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_EXIT_CUR handle
                lea.l         contrl,a0
                move.w        #2,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_ENTER_CUR handle
                lea.l         contrl,a0
                move.w        #3,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_CURUP handle
                lea.l         contrl,a0
                move.w        #4,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_CURDOWN handle
                lea.l         contrl,a0
                move.w        #5,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_CURRIGHT handle
                lea.l         contrl,a0
                move.w        #6,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_CURLEFT handle
                lea.l         contrl,a0
                move.w        #7,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_CURHOME handle
                lea.l         contrl,a0
                move.w        #8,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_EEOS handle
                lea.l         contrl,a0
                move.w        #9,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_EEOL handle
                lea.l         contrl,a0
                move.w        #10,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_CURADDRESS handle,row,column
                lea.l         intin,a0
                move.w        \row,(a0)+
                move.w        \column,(a0)
                lea.l         contrl,a0
                move.w        #11,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO V_CURTEXT handle,string
                lea.l         intin,a0
                movea.l       \string,a1
                move.w        #-1,d0
                clr.w         d1
.\~sl:          addq.w        #1,d0
                move.b        (a1)+,d1
                move.w        d1,(a0)+
                bne           .\~sl
                lea.l         contrl,a0
                move.w        #12,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,d0
                .ENDM 

                .MACRO V_RVON handle
                lea.l         contrl,a0
                move.w        #13,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_RVOFF handle
                lea.l         contrl,a0
                move.w        #14,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO VQ_CURADDRESS handle
                lea.l         contrl,a0
                move.w        #15,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO VQ_TABSTATUS handle
                lea.l         contrl,a0
                move.w        #16,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_HARDCOPY handle
                lea.l         contrl,a0
                move.w        #17,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_DSPCUR handle,x,y
                lea.l         ptsin,a0
                move.w        \x,(a0)+
                move.w        \y,(a0)
                lea.l         contrl,a0
                move.w        #18,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#1,#0
                .ENDM 

                .MACRO V_RMCUR handle
                lea.l         contrl,a0
                move.w        #19,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_FORM_ADV handle
                lea.l         contrl,a0
                move.w        #20,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_OUTPUT handle,xyarray
                move.l        \xyarray,pb+8
                lea.l         contrl,a0
                move.w        #21,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#2,#0
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO V_CLEAR_DISP_LIST handle
                lea.l         contrl,a0
                move.w        #22,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_BIT_IMAGE handle,filename,aspect,x_scale,y_scale,h_align,v_align,xyarray
                move.l        \xyarray,pb+8
                lea.l         intin,a0
                move.w        \aspect,(a0)+
                move.w        \x_scale,(a0)+
                move.w        \y_scale,(a0)+
                move.w        \h_align,(a0)+
                move.w        \v_align,(a0)+
                move.w        #3,d0
                movea.l       \filename,a1
                clr.w         d1
.\~sl:          move.b        (a1)+,d1
                move.w        d1,(a0)+
                bne           .\~sl
                lea.l         contrl,a0
                move.w        #23,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#2,d0
                .ENDM 

                .MACRO VQ_SCAN handle
                lea.l         contrl,a0
                move.w        #24,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#0
                .ENDM 

                .MACRO V_ALPHA_TEXT handle,string
                lea.l         intin,a0
                movea.l       \string,a1
                move.w        #-1,d0
                clr.w         d1
.\~sl:          addq.w        #1,d0
                move.b        (a1)+,d1
                move.w        d1,(a0)+
                bne           .\~sl
                lea.l         contrl,a0
                move.w        #25,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,d0
                .ENDM 

                .MACRO VS_PALETTE handle,palette
                move.w        \palette,intin
                lea.l         contrl,a0
                move.w        #60,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#1
                .ENDM 

                .MACRO V_SOUND handle,frequency,duration
                lea.l         intin,a0
                move.w        \frequency,(a0)+
                move.w        \duration,(a0)+
                lea.l         contrl,a0
                move.w        #61,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO VS_MUTE handle,action
                move.w        \action,intin
                lea.l         contrl,a0
                move.w        #62,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#1
                .ENDM 

                .MACRO VT_RESOLUTION handle,xres,yres
                lea.l         intin,a0
                move.w        \xres,(a0)+
                move.w        \yres,(a0)
                lea.l         contrl,a0
                move.w        #81,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO VT_AXIS handle,xres,yres
                lea.l         intin,a0
                move.w        \xres,(a0)+
                move.w        \yres,(a0)
                lea.l         contrl,a0
                move.w        #82,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO VT_ORIGIN handle,xorigin,yorigin
                lea.l         intin,a0
                move.w        \xorigin,(a0)+
                move.w        \yorigin,(a0)
                lea.l         contrl,a0
                move.w        #83,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO VQ_TDIMENSIONS handle,xdimension,ydimensin
                lea.l         intin,a0
                move.w        \xdimension,(a0)+
                move.w        \ydimension,(a0)
                lea.l         contrl,a0
                move.w        #84,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO VT_ALIGNMENT handle,dx,dy
                lea.l         intin,a0
                move.w        \dx,(a0)+
                move.w        \dy,(a0)
                lea.l         contrl,a0
                move.w        #85,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO VSP_FILM handle,index,lightness
                lea.l         intin,a0
                move.w        \index,(a0)+
                move.w        \lightness,(a0)
                lea.l         contrl,a0
                move.w        #91,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO VQP_FILMNAME handle,index
                move.w        \index,intin
                lea.l         contrl,a0
                move.w        #92,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#1
                .ENDM 

                .MACRO VSC_EXPOSE handle,state
                move.w        \state,intin
                lea.l         contrl,a0
                move.w        #93,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#1
                .ENDM 

                .MACRO V_META_EXTENTS handle,min_x,min_y,max_x,max_y
                lea.l         ptsin,a0
                move.w        \min_x,(a0)+
                move.w        \min_y,(a0)+
                move.w        \max_x,(a0)+
                move.w        \max_y,(a0)+
                lea.l         contrl,a0
                move.w        #98,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#2,#0
                .ENDM 

                .MACRO V_WRITE_META handle,num_intin,a_intin,num_ptsin,a_ptsin
                move.l        \a_intin,pb+4
                move.l        \a_ptsin,pb+8
                lea.l         contrl,a0
                move.w        #99,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,\num_ptsin,\num_intin
                move.l        #intin,pb+4
                move.l        #ptsin,pb+8
                .ENDM 

                .MACRO VM_PAGESIZE handle,pgwidth,pgheight
                lea.l         intin,a0
                clr.w         (a0)+
                move.w        \pgwidth,(a0)+
                move.w        \pgheight,(a0)
                lea.l         contrl,a0
                move.w        #99,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#3
                .ENDM 

                .MACRO VM_COORDS handle,llx,lly,urx,ury
                lea.l         intin,a0
                move.w        #1,(a0)+
                move.w        \llx,(a0)+
                move.w        \lly,(a0)+
                move.w        \urx,(a0)+
                move.w        \ury,(a0)
                lea.l         contrl,a0
                move.w        #99,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#5
                .ENDM 

                .MACRO VM_FILENAME handle,filename
                lea.l         intin,a0
                movea.l       \string,a1
                move.w        #-1,d0
                clr.w         d1
.\~sl:          addq.w        #1,d0
                move.b        (a1)+,d1
                move.w        d1,(a0)+
                bne           .\~sl
                lea.l         contrl,a0
                move.w        #100,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,d0
                .ENDM 

                .MACRO V_OFFSET handle,offset
                move.w        \offset,intin
                lea.l         contrl,a0
                move.w        #101,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#1
                .ENDM 

                .MACRO V_FONTINIT handle,font_hdr
                move.l        \font_hdr,intin
                lea.l         contrl,a0
                move.w        #102,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#2
                .ENDM 

                .MACRO V_ESCAPE2000 handle,times
                move.w        \times,intin
                lea.l         contrl,a0
                move.w        #2000,10(a0)
                move.w        \handle,12(a0)
                VDI           #5,#0,#1
                .ENDM 

;
;Aufruf der VDI-Funktionen
;


                .SECTION 60,TEXT

vditrap:        move.l        #pb,d1    ;Adresse Åbergeben
                move.w        #115,d0   ;AES-Magic
                trap          #2        ;Aufruf
                rts                     ;fertig

                .TEXT 

                .END 

