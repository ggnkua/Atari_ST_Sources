/* WA - AESutils.h / 14.12.90 */

# ifndef __AESUTILS__
# define __AESUTILS__

/* --- general --- */

extern bool toggle(bool *b) ;
extern bool toggle_bit(uword *w, uword b) ;

# ifndef NULL
#define   NULL   ( (void*) 0L )
# endif

extern int dummy ;

/* --- A E S --- */

/* --- event --- */

extern bool keyboard_state(int state);
extern bool chk_aes_buffer ( int w, int h ) ;
extern MFDB *get_aes_buffer ( int w, int h ) ;

# define LEFT_BUTTON	0x01
# define RIGHT_BUTTON	0x02
# define BOTH_BUTTONS	(LEFT_BUTTON|RIGHT_BUTTON)

/* --- mouse --- */

# define MouseOff()   			graf_mouse ( M_OFF, 0 )
# define MouseOn()	  			graf_mouse ( M_ON,  0 )
# define MouseArrow() 			graf_mouse ( ARROW, 0 )
# define MouseBusy()  			graf_mouse ( BUSYBEE, 0 )
# define MouseBusyBee() 		graf_mouse ( BUSYBEE, 0 )
# define MousePointHand()		graf_mouse ( POINT_HAND, 0 )
# define MouseFlatHand()		graf_mouse ( FLAT_HAND, 0 )
# define MouseThinCross()		graf_mouse ( THIN_CROSS, 0 )
# define MouseThickCross()		graf_mouse ( THICK_CROSS, 0 )
# define MouseOutlineCross()	graf_mouse ( OUTLN_CROSS, 0 )
# define MouseUser(mf)			graf_mouse ( USER_DEF, mf )

/* --- rectangle --- */

# define VALpoint(point) (point).x, (point).y
# define REFpoint(point) &(point).x, &(point).y

extern TRectangle NullRectangle ;

extern bool rc_intersect(TRectangle *r1, TRectangle *r2) ;
extern bool inside_rect(int x, int y, TRectangle *rect) ;


# define SetRectangle(rect,xx,yy,ww,hh) \
	(rect).x = xx ; (rect).y = yy; (rect).w = ww; (rect).h = hh
# define AssignRectangle(source,dest) \
	(dest).x = (source).x; (dest).y = (source).y; \
	(dest).w = (source).w; (dest).h = (source).h
# define RectangleNotEmpty(rect) ((rect).w && (rect).h)
# define RectanglesEqual(r1,r2) (  (r1).x == (r2).x \
								&& (r1).y == (r2).y \
								&& (r1).w == (r2).w \
								&& (r1).h == (r2).h )
# define DimensionsEqual(r1,r2) (  (r1).w == (r2).w \
								&& (r1).h == (r2).h )

# define VALrect(rect) (rect).x, (rect).y, (rect).w, (rect).h
# define REFrect(rect) &(rect).x, &(rect).y, &(rect).w, &(rect).h
# define R0 0,0,0,0
# define VALrectEnd(r) r.x, r.y, r.x+r.w-1, r.y+r.h-1

# define DECxy(a,b) (a).x -= (b).x ; (a).y -= (b).y

# define printf_rectangle(mesg,r)	printf ( mesg "= %4d:%4d %4d:%4d\n", VALrect ( r ) )

/* --- window --- */

typedef int WINDOWhandle ;

# define DESK_TOP 0

# define WindCreate(elements,rect) \
	wind_create( elements, (rect).x, (rect).y, (rect).w, (rect).h)

# define WindOpen(window,rect) \
	wind_open( window, (rect).x, (rect).y, (rect).w, (rect).h )

# define WindClose(window)	wind_close  ( window )
# define WindDelete(window) wind_delete ( window )

# define WindUpdateBegin()	wind_update(BEG_UPDATE)
# define WindUpdateEnd()	wind_update(END_UPDATE)
# define WindMouseBegin()	wind_update(BEG_MCTRL)
# define WindMouseEnd()		wind_update(END_MCTRL)

# define WindCalc(what,elements,in,out) \
		wind_calc(what,elements,VALrect(in),REFrect(out))


/* --- ... get --- */

# define WindGetTop(window) \
	wind_get( 0, WF_TOP, &window)

# define WindGetWork(window,rect) \
	wind_get  ( window, WF_WORKXYWH, \
				&(rect).x, &(rect).y, &(rect).w, &(rect).h )

# define WindGetFirst(window,rect) \
	wind_get  ( window, WF_FIRSTXYWH, \
			  &(rect).x, &(rect).y, &(rect).w, &(rect).h )

# define WindGetCurr(window,rect) \
	wind_get  ( window, WF_CURRXYWH, \
				  &(rect).x, &(rect).y, &(rect).w, &(rect).h )

# define WindGetFull(window,rect) \
	wind_get  ( window, WF_FULLXYWH, \
				  &(rect).x, &(rect).y, &(rect).w, &(rect).h )

# define WindGetPrev(window,rect) \
	wind_get  ( window, WF_PREVXYWH, \
				  &(rect).x, &(rect).y, &(rect).w, &(rect).h )

# define WindGetNext(window,rect) \
	wind_get  ( window, WF_NEXTXYWH, \
			  &(rect).x, &(rect).y, &(rect).w, &(rect).h )

# define WindGetHSpos(window,value) \
	wind_get  ( window, WF_HSLIDE, &value )
# define WindGetVSpos(window,value) \
	wind_get  ( window, WF_VSLIDE, &value )
# define WindGetHSsize(window,value) \
	wind_get  ( window, WF_HSLSIZE, &value )
# define WindGetVSsize(window,value) \
	wind_get  ( window, WF_VSLSIZE, &value )


/* --- ... set --- */

# define WindSetName(window,name) \
	wind_set(window,WF_NAME,name)

# define WindSetInfo(window,info) \
	wind_set(window,WF_INFO,info)

# define WindSetTop(window) \
	wind_set(window, WF_TOP, 0, 0, 0, 0)
# define WindSetKind(window,kind) \
	wind_set(window, WF_KIND, kind, 0, 0, 0)
# define WindSetCurr(window,rect) \
	wind_set  ( window, WF_CURRXYWH, \
				  (rect).x, (rect).y, (rect).w, (rect).h )

# define WindSetNewDesk(tree,object) \
	wind_set  ( DESK_TOP, WF_NEWDESK, tree, object )

# define WindSetHSpos(window,value) \
	wind_set  ( window, WF_HSLIDE, value )
# define WindSetVSpos(window,value) \
	wind_set  ( window, WF_VSLIDE, value )
# define WindSetHSsize(window,value) \
	wind_set  ( window, WF_HSLSIZE, value )
# define WindSetVSsize(window,value) \
	wind_set  ( window, WF_VSLSIZE, value )


/* --- graf --- */

# define GrafGrowbox(from,to) \
	graf_growbox ( (from).x, (from).y, (from).w, (from).h, \
					(to).x,	(to).y,	 (to).y,	  (to).h )

# define GrafShrinkbox(to,from) \
	graf_growbox ( (to).x,	(to).y,	 (to).y,	  (to).h, \
				   (from).x, (from).y, (from).w, (from).h )
# define GrafDragbox(box,frame,stop) \
	graf_dragbox (	(box).w, (box).h, (box).x, (box).y, \
					(frame).x, (frame).y, (frame).w, (frame).h, \
					&(stop).x, &(stop).y )

/* --- clip --- */

extern void clipping(int handle, int x, int y, int w, int h, int on_off);

# define ClippingOn(h,r) clipping( h, VALrect(r), TRUE )
# define ClippingOff(h)	 clipping( h, 0, 0, 0, 0, FALSE )


/* --- menu ---*/

#define ME_HIDE         0
#define ME_SHOW         1

# define MenuShow(tree) menu_bar(tree, ME_SHOW)
# define MenuHide(tree) menu_bar(tree, ME_HIDE)


# define ME_INVERS		0
# define ME_NORMAL		1

# define MenuNormal(tree,entry) menu_tnormal(tree, entry, ME_NORMAL)
# define MenuInvers(tree,entry) menu_tnormal(tree, entry, ME_INVERS)

/* --- resource --- */

# define RsrcGetAddr(type,index,result) rsrc_gaddr(type,index, (void *)result)
# define RsrcLoad(filename)				rsrc_load(filename)
# define RsrcFree()						rsrc_free()


/* --- object --- */

extern char **object_text_ptr(OBJECT *tree, int obj);
extern char *object_text(OBJECT *tree, int obj);
extern void replace_icols(OBJECT *tree, int from, int to,
										int oldcol, int newcol) ;

/* Extended Object flags */

# define NOobject -1

# define EXT_FLAGS	0xfe00

# define ObjectOffset(tree,object,point) \
			objc_offset(tree,object,&(point).x,&(point).y)
# define ObjectGetRectangle(tree,object,rect) \
			objc_offset(tree,object,&(rect).x,&(rect).y); \
			(rect).w = tree[object].ob_width ;\
			(rect).h = tree[object].ob_height
# define ObjectSetOffset(tree,object,ofs) \
			tree[object].ob_x = (ofs).x ;\
			tree[object].ob_y = (ofs).y
# define ObjectSetXY(tree,object,x,y) \
			tree[object].ob_x = x ;\
			tree[object].ob_y = y

# define ObjectSetDimension(tree,object,dim_x,dim_y) \
			tree[object].ob_width  = dim_x ;\
			tree[object].ob_height = dim_y

# define ObjectGetDimension(tree,object,dim) \
			dim.x = tree[object].ob_width ;\
			dim.y = tree[object].ob_height

# define ObjectSetRectangle(tree,object,rect) \
			tree[object].ob_x = (rect).x ;\
			tree[object].ob_y = (rect).y ;\
			tree[object].ob_width = (rect).w ;\
			tree[object].ob_height = (rect).h
			
# define ObjectDraw(tree,first) \
	objc_draw(tree,first,99,0,0,screen_size.x,screen_size.y)
# define ObjectDrawClipped(tree,first,clip) \
	objc_draw(tree,first,99,VALrect(clip))

# define ObjectInfoText(tree,object) \
	(tree[object].ob_spec.tedinfo->te_ptext)
# define ObjectState(tree,obj) (tree[obj].ob_state)

# define ObjectExtFlags(tree,obj) (tree[obj].ob_flags & EXT_FLAGS)

# define ObjectChange(tree,obj,state,draw) \
	objc_change(tree,obj,0, 0,0,9999,9999, state,draw)

# define ObjectSelect(tree,obj) \
	objc_change(tree,obj,0, 0,0,9999,9999, SELECTED,1)
# define ObjectNormal(tree,obj) \
	objc_change(tree,obj,0, 0,0,9999,9999, NORMAL,1)
# define ObjectDisable(tree,obj) \
	objc_change(tree,obj,0, 0,0,9999,9999, DISABLED,1)

# define ObjectSetState(tree,obj,state) \
	tree[obj].ob_state |= state
# define ObjectClearState(tree,obj,state) \
	tree[obj].ob_state &= ~state

# define ObjectChecked(tree,obj)  ((tree[obj].ob_state & CHECKED) != 0)
# define ObjectSelected(tree,obj) ((tree[obj].ob_state & SELECTED) != 0)
# define ObjectEnabled(tree,obj)  ((tree[obj].ob_state & DISABLED) == 0)
# define ObjectDisabled(tree,obj)  ((tree[obj].ob_state & DISABLED) != 0)

# define ObjectHidden(tree,obj)   ((tree[obj].ob_flags & HIDETREE) != 0)
# define ObjectUnhidden(tree,obj) ((tree[obj].ob_flags & HIDETREE) == 0)

# define ObjectHide(tree,obj)   tree[obj].ob_flags |= HIDETREE
# define ObjectUnhide(tree,obj) tree[obj].ob_flags &= ~ HIDETREE
	
			

/* --- form --- */

extern int mouse_form_center ( OBJECT *ctree, int *cx, int *cy, int *cw, int *ch ) ;
extern int rect_center ( int *cx, int *cy, int *cw, int *ch ) ;

# define FormCenter(tree,rect) mouse_form_center(tree,REFrect(rect))
/* redefined in aesutils.c, replaces AES-LIB-function	*/

# define FormDialStart(rect) form_dial( FMD_START, R0, VALrect(rect) )
# define FormDialGrow(little,big) form_dial( FMD_GROW, \
									 VALrect(little), VALrect(big))
# define FormDialShrink(little,big) form_dial( FMD_SHRINK, \
									 VALrect(little), VALrect(big))
# define FormDialFinish(rect) form_dial( FMD_FINISH, R0, VALrect(rect) )

# define FormDo(tree,edstart) form_do(tree,edstart)

# endif __AESUTILS__
