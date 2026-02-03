/************************************************************************/
/*      TREEADDR.H  Finds pointers to within an array of OBJECT structs.*/
/*                  This is a more better and correct "C" version       */
/*                  of "TADDR.H" supplied by ATARI                      */
/*                  Author: K.Steinberger 15.2.86                       */
/*                                                                      */
/************************************************************************/

#define NIL -1
#define ROOT 0
#define OB_NEXT(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_next
#define OB_HEAD(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_head
#define OB_TAIL(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_tail
#define OB_TYPE(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_type
#define OB_FLAGS(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_flags
#define OB_STATE(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_state
#define OB_SPEC(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_spec
#define OB_X(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_x
#define OB_Y(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_y
#define OB_WIDTH(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_width
#define OB_HEIGHT(x) ((struct object *)(tree + (x) * sizeof(OBJECT)))->ob_height
