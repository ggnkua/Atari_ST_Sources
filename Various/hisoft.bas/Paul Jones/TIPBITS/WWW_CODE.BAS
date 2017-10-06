'$option k100y
DEFINT a-z
'$include f:\hbasic\source\gemaes.bh

LIBRARY "gemaes","gemdos","speedo","falcon","gemvdi","xbios"
WINDOW OFF
CALL vsf_color(8)
path$="C:\*.htm"
file$=""
button=0
primpt$="Select HTML to load..."
CALL fsel_exinput(path$,file$,button,prompt$)
path$=LEFT$(path$,LEN(path$)-5)
IF file$="" THEN SYSTEM
OPEN path$+file$ FOR INPUT AS #1
l&=LOF(1)
m&=mxalloc&(l&,0)
IF m&=0 THEN CLOSE #1:STOP
BLOAD #1,m&,l&
CLOSE #1
dum=wind_get(desk,wf_workxywh,x,y,w,h)
handle=wind_create(w_name+w_closer+w_mover+w_smaller+w_sizer+w_vslide,x,y,w,h)
dum=rsrc_gaddr(r_tree,tools_form,tools_addr&)
dum=wind_calc(wc_border,w_name+w_closer+w_mover+w_smaller+w_sizer+w_vslide,100,100,500,300,x,y,w,h)
title$="WWW HTML reader"+CHR$(0)
title&=SADD(title$)
dum=wind_set(handle,wf_name,PEEKW(VARPTR(title&)),PEEKW(VARPTR(title&)+2),0,0)
dum=wind_open(handle,x,y,w,h)
buffer&=mxalloc&(16,0)
IF buffer&=0 THEN STOP
dum=vst_load_fonts
CALL vst_font(vqt_name(25,name$))
font=12
dum=vst_arbpt(12,0,chrh,0,0)
DO
message=evnt_multi(mu_mesag,0,0,0,0,0,0,0,0,0,0,0,0,0,buffer&,0,0,0,0,0,0,0)
IF (message AND mu_mesag)=mu_mesag THEN CALL message_received
LOOP
STOP


SUB redraw
SHARED buffer&
LOCAL x,y,w,h,dum         
dum=wind_update(beg_update)
dum=wind_get(PEEKW(buffer&+6),wf_firstxywh,x,y,w,h)
WHILE w>0 AND h>0
CALL vs_clip(1,x,y,x+w-1,y+h-1)
CALL text_print
CALL vs_clip(0,0,0,0,0)
dum=wind_get(PEEKW(buffer&+6),wf_nextxywh,x,y,w,h)
WEND
dum=wind_update(end_update)
END SUB


SUB text_print
SHARED handle,m&,chrh,font,l&,effects,tally
LOCAL x,y,w,h,dum,ty,tx,mpos&,alignx,cmd$,title&
LOCAL advx,i,bit$,line$,letter$,size,np,title$,name$,test$
LOCAL count,tally$,corr,b_n,oldfont,oldsize,valign,dum
CALL vswr_mode(2)
dum=wind_get(handle,wf_workxywh,x,y,w,h)
CALL v_bar(x,y,x+w-1,y+h-1)
ty=y+10
tx=x-25
size=12
font=12
tally$=""
corr=0
effects=0
mpos&=m&
line$=""
tally=0
WHILE ty+chrh=<y+h+12 AND mpos&<m&+l&
	letter$=CHR$(PEEKB(mpos&))
	INCR mpos&
	CALL vqt_advance(ASC(letter$),advx,0,0,0)
	INCR advx
	SELECT CASE letter$
		CASE CHR$(10)
			letter$=""
			CALL vqt_advance(32,advx,0,0,0)
		CASE CHR$(13)
			letter$=""
			CALL vqt_advance(32,advx,0,0,0)
		CASE "<"
			cmd$="<"
			WHILE RIGHT$(cmd$,1)<>">"
				cmd$=cmd$+CHR$(PEEKB(mpos&))
				INCR mpos&
			WEND
			bit$=CHR$(PEEKB(mpos&))
			IF bit$=CHR$(32) THEN
				line$=line$+CHR$(32)
				CALL vqt_advance(32,advx,0,0,0)
				alignx=alignx+advx
				INCR mpos&
			END IF
			cmd$=UCASE$(cmd$)
			SELECT CASE cmd$
			CASE "<SUB>"
				oldsize=size
				size=size/2
				valign=2
			CASE "</SUB>"
				size=oldsize
				valign=-2
			CASE "<SUP>"
				oldsize=size
				size=size/2
				valign=1
			CASE "</SUP>"
				size=oldsize
				valign=-1
			CASE "<HR>"
				CALL vsf_color(9)
				CALL v_bar(x+10,ty,x+w-11,ty+1)
				CALL vsf_color(0)
				CALL v_bar(x+11,ty+1,x+w-11,ty+1)
				CALL v_bar(x+w-11,ty,x+w-11,ty)
				CALL vsf_color(8)
				np=1
			CASE "<UL>"
				x=x+40
			CASE "</UL>"
				x=x-40
				np=1
			CASE "<LI>"
				np=1
				b_n=1
			CASE "<H1>"
				oldfont=font
				oldsize=size
				font=14
				size=25
				np=1
			CASE "</H1>"
				font=oldfont
				size=oldsize
				np=1
			CASE "<H2>"
				oldsize=size
				oldfont=font
				font=14
				size=18
				np=1
			CASE "</H2>"
				font=oldfont
				size=oldsize
				np=1
			CASE "<H3>"
				oldfont=font
				oldsize=size
				font=13
				size=15
				np=1
			CASE "</H3>"
				size=oldsize
				font=oldfont
				np=1
			CASE "<H4>"
				oldfont=font
				font=14
				x=x+10
				np=1
			CASE "</H4>"
				font=oldfont
				x=x-10
				np=1
			CASE "<H5>"
				oldfont=font
				oldsize=size
				font=13
				size=10
				x=x+10
				np=1  
			CASE "</H5>"
				font=oldfont
				size=oldsize
				x=x-10
				np=1
			CASE "<H6>"
				oldfont=font
				oldsize=size
				x=x+15
				font=14
				size=7
				np=1
			CASE "</H6>"
				font=oldfont
				size=oldsize
				x=x-15
				np=1
			CASE "<B>"
				IF font=12 THEN font=14
				IF font=13 THEN font=15
			CASE "</B>"
				IF font=15 THEN font=13
				IF font=14 THEN font=12
			CASE "<I>"
				IF font=14 THEN font=15
				IF font=12 THEN font=13
			CASE "</I>"
				IF font=13 THEN font=12
				IF font=15 THEN font=14
			CASE "<U>"
				effects=8
			CASE "</U>"
				effects=0
			CASE "<P>"
				np=1
			CASE "<TITLE>"
				bit$=""
				WHILE bit$<>">"
					bit$=CHR$(PEEKB(mpos&))
					INCR mpos&
					title$=title$+bit$
				WEND
				title$=LEFT$(title$,LEN(title$)-8)+CHR$(0)
				title&=SADD(title$)
				dum=wind_set(handle,wf_name,PEEKW(VARPTR(title&)),PEEKW(VARPTR(title&)+2),0,0)
			CASE "<CENTER>"
				count=0
				tally$=""
				corr=0
				DO
					INCR count
					bit$=CHR$(PEEKB(mpos&+count))
					IF bit$="<" THEN
						test$="<"
						WHILE RIGHT$(test$,1)<>">"
							INCR count
							test$=test$+CHR$(PEEKB(mpos&+count))
						WEND
						bit$=""
					END IF
					IF UCASE$(test$)="</CENTER>" THEN EXIT LOOP
					tally$=tally$+bit$
				LOOP
				FOR count=1 TO LEN(tally$)
					CALL vqt_advance(ASC(RIGHT$(LEFT$(tally$,count),1)),advx,0,0,0)
					corr=corr+advx
				NEXT count
			CASE "</CENTER>"
				np=1
			
			CASE "<RIGHT>"
				count=0
				tally$=""
				corr=0
				DO
					INCR count
					bit$=CHR$(PEEKB(mpos&+count))	
					IF bit$="<" THEN
					test$="<"
						WHILE RIGHT$(test$,1)<>">"
							INCR count
							test$=test$+CHR$(PEEKB(mpos&+count))
						WEND
					END IF
					IF UCASE$(test$)="</RIGHT>" THEN EXIT LOOP
					tally$=tally$+bit$
				LOOP
				FOR count=1 TO LEN(tally$)
					CALL vqt_advance(ASC(RIGHT$(LEFT$(tally$,count),1)),advx,0,0,0)
					corr=corr+advx+4
				NEXT count
				corr=-corr
			CASE "</RIGHT>"
				np=1
				
			END SELECT
			IF tx+alignx=<w+x-1 THEN
				CALL v_ftext(tx,ty,line$)
				line$=""
				tx=tx+alignx
				alignx=0
			ELSE
				ty=ty+chrh
				tx=x+3
				CALL v_ftext(tx,ty,line$)
				tx=tx+alignx
				alignx=0
				line$=""
			END IF
			letter$=""
			advx=0
			IF corr<>0 THEN
				SELECT CASE corr
					CASE >0
						tx=((x+w-1)/2)-(corr/2)
					CASE <0
						tx=(x+w-1)+corr
				END SELECT
				corr=0
			END IF
			IF valign>0 THEN
				IF valign=1 THEN ty=ty-(chrh/2) ELSE ty=ty+(chrh/6)
				valign=0 
			END IF
			CALL vst_font(vqt_name(font,name$))
			dum=vst_arbpt(size,0,chrh,0,0)
			CALL vst_effects(effects)
			IF np>0 THEN
				ty=ty+chrh
				tx=x+3
				np=0
			END IF
			IF valign<0 THEN
				IF valign=-1 THEN ty=ty+(chrh/2) ELSE ty=ty-(chrh/6)
				valign=0
			END IF
			IF b_n>0 THEN
				CALL v_ftext(x-20,ty,CHR$(249))
				b_n=0
			END IF
		CASE CHR$(32)
			line$=line$+CHR$(32)
			alignx=alignx+advx
			advx=0
			IF tx+alignx=<w+x-1 THEN
				CALL v_ftext(tx,ty,line$)
				line$=""
				tx=tx+alignx
				alignx=0
			ELSE
				ty=ty+chrh
				tx=x+3
				CALL v_ftext(tx,ty,line$)
				tx=tx+alignx
				alignx=0
				line$=""
			END IF
			letter$=""
	END SELECT
	alignx=alignx+advx
	line$=line$+letter$
WEND	
END SUB






SUB message_received
SHARED buffer&,menu_add&
STATIC type,title$,title&,dum1,cur_pos,w,h,dum
type=PEEKW(buffer&)
SELECT CASE type
	CASE mn_selected
		CALL menu_tnormal(menu_add&,3,1)
	CASE wm_redraw
		CALL redraw
	CASE wm_topped
		dum=wind_set(PEEKW(buffer&+6),wf_top,PEEKW(buffer&+6),0,0,0)
	CASE wm_closed
		dum=mfree(buffer&)
		SYSTEM
	CASE wm_vslid
		dum=wind_set(PEEKW(buffer&+6),wf_vslide,PEEKW(buffer&+8),0,0,0)
	CASE wm_sized
		dum=wind_get(PEEKW(buffer&+6),wf_currxywh,0,0,w,h)
		dum=wind_set(PEEKW(buffer&+6),wf_currxywh,PEEKW(buffer&+8),PEEKW(buffer&+10),PEEKW(buffer&+12),PEEKW(buffer&+14))
		IF PEEKW(buffer&+12)<w OR PEEKW(buffer&+14)<h THEN CALL redraw
	CASE wm_moved
		dum=wind_set(PEEKW(buffer&+6),wf_currxywh,PEEKW(buffer&+8),PEEKW(buffer&+10),PEEKW(buffer&+12),PEEKW(buffer&+14))
	CASE wm_untopped
	
	CASE wm_ontop
	
'	CASE wm_bottom
'		dum=wind_set(PEEKW(buffer&+6),wf_bottom,PEEKW(buffer&+6),0,0,0)
	CASE wm_iconify
		dum=wind_set(PEEKW(buffer&+6),wf_iconify,PEEKW(buffer&+8),PEEKW(buffer&+10),PEEKW(buffer&+12),PEEKW(buffer&+14))
		title$="WWW"+CHR$(0)
		title&=SADD(title$)
		dum=wind_set(PEEKW(buffer&+6),wf_name,PEEKW(VARPTR(title&)),PEEKW(VARPTR(title&)+2),0,0)
	CASE wm_uniconify
		dum=wind_set(PEEKW(buffer&+6),wf_uniconify,PEEKW(buffer&+8),PEEKW(buffer&+10),PEEKW(buffer&+12),PEEKW(buffer&+14))
		title$="WWW HTML Reader"+CHR$(0)
		title&=SADD(title$)
		dum=wind_set(PEEKW(buffer&+6),wf_name,PEEKW(VARPTR(title&)),PEEKW(VARPTR(title&)+2),0,0)
	CASE ap_term
		CALL pterm0
	CASE ap_dragdrop
	
END SELECT
END SUB