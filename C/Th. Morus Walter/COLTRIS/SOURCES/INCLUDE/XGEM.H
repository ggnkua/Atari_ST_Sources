/*     GEM.H

       GEM AES Makros

*/

#if  !defined(__AES__)
     #include <aes.h>
     #include <magx.h>
#endif
#if  !defined(__MYGEM__)
     #include <mygem.h>
#endif

#if  !defined(__XGEM__)

#define __XGEM__

#define   obj_state(tree,objc)		(((tree)+(objc))->ob_state)
#define   obj_flags(tree,objc)		(((tree)+(objc))->ob_flags)
#define   obj_spec(tree,objc)		(((tree)+(objc))->ob_spec.free_string)
#define   obj_tedstr(tree,objc)		(( ((tree)+(objc))->ob_spec.tedinfo)->te_ptext)

#define   obj_select(tree,objc)		obj_state(tree,objc)|=SELECTED
#define   obj_unselect(tree,objc)	obj_state(tree,objc)&=~SELECTED
#define   obj_selected(tree,objc)	(obj_state(tree,objc)&SELECTED)

#define   obj_shadow(tree,objc)		obj_state(tree,objc)|=SHADOWED
#define   obj_unshadow(tree,objc)	obj_state(tree,objc)&=~SHADOWED

#define   obj_outline(tree,objc)	obj_state(tree,objc)|=OUTLINED
#define   obj_unoutline(tree,objc)	obj_state(tree,objc)&=~OUTLINED

#define   obj_check(tree,objc)		obj_state(tree,objc)|=CHECKED
#define   obj_uncheck(tree,objc)	obj_state(tree,objc)&=~CHECKED
#define   obj_checked(tree,objc)	(obj_state(tree,objc)&CHECKED)

#define   obj_disable(tree,objc)	obj_state(tree,objc)|=DISABLED
#define   obj_enable(tree,objc)		obj_state(tree,objc)&=~DISABLED
#define   obj_disabled(tree,objc)	(obj_state(tree,objc)&DISABLED)

#define   obj_hide(tree,objc)		obj_flags(tree,objc)|=HIDETREE
#define   obj_unhide(tree,objc)		obj_flags(tree,objc)&=~HIDETREE
#define   obj_hidden(tree,objc)		(obj_flags(tree,objc)&HIDETREE)

/*
	alte versionen, do not use
*/
#define   objc_state(tree,objc)         (((tree)+(objc))->ob_state)
#define   objc_flags(tree,objc)         (((tree)+(objc))->ob_flags)
#define   objc_spec(tree,objc)          (((tree)+(objc))->ob_spec.free_string)
#define   objc_tedstr(tree,objc)        (( ((tree)+(objc))->ob_spec.tedinfo)->te_ptext)

#define   objc_select(tree,objc)        objc_state(tree,objc)|=SELECTED
#define   objc_unselect(tree,objc)      objc_state(tree,objc)&=~SELECTED
#define   objc_selected(tree,objc)      (objc_state(tree,objc)&SELECTED)
#define   objc_shadow(tree,objc)        objc_state(tree,objc)|=SHADOWED
#define   objc_unshadow(tree,objc)      objc_state(tree,objc)&=~SHADOWED
#define   objc_outlined(tree,objc)      objc_state(tree,objc)|=OUTLINED
#define   objc_unoutlined(tree,objc)    objc_state(tree,objc)&=~OUTLINED
#define   objc_checked(tree,objc)       objc_state(tree,objc)|=CHECKED
#define   objc_unchecked(tree,objc)     objc_state(tree,objc)&=~CHECKED
#define   objc_disabled(tree,objc)      objc_state(tree,objc)|=DISABLED
#define   objc_enabled(tree,objc)       objc_state(tree,objc)&=~DISABLED
#define   objc_normal(tree,objc)        objc_state(tree,objc)=NORMAL
#define   objc_hide(tree,objc)          objc_flags(tree,objc)|=HIDETREE
#define   objc_unhide(tree,objc)        objc_flags(tree,objc)&=~HIDETREE

#define   objc_set_selected(tree,objc)  objc_change(tree,objc,0,0,0,640,400,SELECTED,1)
#define   objc_set_disabled(tree,objc)  objc_change(tree,objc,0,0,0,640,400,DISABLED,1)
#define   objc_set_outlined(tree,objc)  objc_change(tree,objc,0,0,0,640,400,OUTLINED,1)
#define   objc_set_normal(tree,objc)    objc_change(tree,objc,0,0,0,640,400,NORMAL,1)

#endif

