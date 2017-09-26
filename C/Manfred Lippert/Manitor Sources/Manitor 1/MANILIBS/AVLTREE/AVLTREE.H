#ifndef __MANILIBS_AVLTREE_H__
#define __MANILIBS_AVLTREE_H__

#ifndef __PORTAB__
#include <portab.h>
#endif

#include <manilibs\Err\Err.h>

#define AVLDIR_ROOT	0	/* Root kann allerdings auch andere Directions haben! (undefiniert) */
#define AVLDIR_LEFT	1
#define AVLDIR_RIGHT	2

typedef struct _AVL {
	struct _AVL *top;
	struct _AVL *left;
	struct _AVL *right;
	int16 left_height;
	int16 right_height;
	int8 direction;	/* AVLDIR_ROOT, AVLDIR_LEFT, AVLDIR_RIGHT */
} AVL;

typedef int16 (*AVL_compare_func)(struct _AVLTree *tree, AVL *a, AVL *b);	/* <0:a<b; 0:a==b; >0:a>b */

typedef struct {
	AVL_compare_func compare;
	AVL *(*get_root)(struct _AVLTree *tree, Err *err);
	AVL *(*get_top)(struct _AVLTree *tree, AVL *a, Err *err);
	AVL *(*get_left)(struct _AVLTree *tree, AVL *a, Err *err);
	AVL *(*get_right)(struct _AVLTree * tree, AVL *a, Err *err);
} AVLTree_vtab;

typedef struct _AVLTree {
	AVL *root;
	AVLTree_vtab *vtab;
} AVLTree;

extern AVLTree_vtab AVLTree_std_vtab;

void AVLTree_init(AVLTree *tree, AVLTree_vtab *vtab);
#define AVL_compare(tree, a, b) ((tree)->vtab->compare(tree, a, b))
#define AVL_root(tree, err) ((tree)->vtab->get_root(tree, err))
#define AVL_top(tree, a, err) ((tree)->vtab->get_top(tree, a, err))
#define AVL_left(tree, a, err) ((tree)->vtab->get_left(tree, a, err))
#define AVL_right(tree, a, err) ((tree)->vtab->get_right(tree, a, err))

void AVL_insert(AVLTree *tree, AVL *elem, Err *err);
void AVL_remove(AVLTree *tree, AVL *elem, Err *err);

AVL *AVL_search(AVLTree *tree, AVL *elem, Err *err);
AVL *AVL_search_nearest(AVLTree *tree, AVL *elem, int8 *direction, Err *err);

AVL *AVL_first(AVLTree *tree, Err *err);
AVL *AVL_last(AVLTree *tree, Err *err);
AVL *AVL_next(AVLTree *tree, AVL *elem, Err *err);
AVL *AVL_prev(AVLTree *tree, AVL *elem, Err *err);

void AVL_resort(AVLTree *tree, AVL_compare_func neu_compare, Err *err);


#endif
