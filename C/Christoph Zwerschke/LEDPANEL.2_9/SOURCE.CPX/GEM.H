/*     GEM.H

       GEM AES Makros

*/

#if  !defined(__GEM__)

#define __GEM__

#if  !defined(__AES__)
     #include <aes.h>
#endif

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

