/***********************************************/
/*        Boinkout2 configuration file         */
/* Use this file to adapt the sources to your  */
/* C compiler and to select some compilation   */
/* options.                                    */
/***********************************************/

#ifndef _BCONFIG_H
#define _BCONFIG_H


/** Define here your base operating system **/
#define OS_TOS   1           /* Our loved Ataris :-) */
#define OS_DOS   0           /* If you want to compile for PC-GEM */
#define OS_UNIX  0           /* Have you installed oAESis on your Linux? */


/** Endianess: 0=Little endian ("PCs"), 1=Big endian (Ataris) **/
#ifdef OS_TOS
#define ENDIANESS 1
#else
#define ENDIANESS 0
#endif

/** Maximal path and filename lenght **/
#ifndef PATH_MAX
#define PATH_MAX 96
#endif
#ifndef FILENAME_MAX
#define FILENAME_MAX (PATH_MAX+12)
#endif


/** Use those defines if your C library does not feature a **/
/** malloc(LONG amount).                                   **/
#if 1
/*#if OS_TOS
#define  malloc(x)  Malloc(x)
#define  free(x)    Mfree(x)
#endif*/
#if OS_DOS
#define  malloc(x)  dos_alloc(x)
#define  free(x)    dos_free(x)
#endif
#endif


/** Does your GEM Library already feature rc_intersect? **/
/* MAR -- gnugem has rc_intersect (so use 1 with gnugem) */
/* DAN -- purec does not have rc_intersect*/
#define GL_RCINTER 0

/** There are two different declarations of the objc_edit function:     **/
/** a) objc_edit(OBJECT *tree, WORD obj, WORD c, WORD *idx, WORD kind); **/
/** b) objc_edit(OBJECT *tree, WORD obj, WORD c, WORD idx, WORD kind, WORD *idx); **/
/** If your GEM library uses a), you should use following define: **/
/* MAR -- gnugem has the latter type (so use 0 with gnugem) */
#if 1
#define objc_edit(tree,obj,c,idx,kind,idxp)  objc_edit(tree,obj,c,idxp,kind)
#endif


/** Some people prefer the VDI mouse functions to the AES functions: **/
#if 1
#define HIDE_MOUSE graf_mouse(M_OFF,0L);
#define SHOW_MOUSE graf_mouse(M_ON,0L);
#else
#define HIDE_MOUSE v_hide_c(handle);
#define SHOW_MOUSE v_show_c(handle, 1);
#endif

#if OS_TOS
#ifdef __TURBOC__
#include <tos.h>
#else
#include <osbind.h>
#endif
#endif

#ifdef __GNUC__
extern int	_app;
extern short _global[];
#define AP_TERM			50
#define WM_ICONIFY		34
#define WM_UNICONIFY		35
#define WM_ALLICONIFY	36
#define WF_ICONIFY		26
#define WF_UNICONIFY		27
#define WF_UNICONIFYXYWH	28
#define ED_START        0               /* editable text field definitions */
#define ED_INIT         1
#define ED_CHAR         2
#define ED_END          3
#define ED_CRSR          100                                /* MAG!X       */
#define ED_DRAW          103                                /* MAG!X 2.00  */
#define evnt_timer(l,h) evnt_timer((long)h<<16|l)
#define evnt_multi(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w) evnt_multi(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,(long)q<<16|p,r,s,t,u,v,w)
#endif

#endif /* _BCONFIG_H */

