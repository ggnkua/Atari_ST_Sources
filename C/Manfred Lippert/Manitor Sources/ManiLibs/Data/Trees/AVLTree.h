/*----------------------------------------------------------------------------------------
	AVLTree.h, class for handling automatically balanced binary trees
	
	9.12.1998 by Manfred Lippert, mani@mani.de

	last change: 24.8.2001
----------------------------------------------------------------------------------------*/

#ifndef __ManiLibs_AVLTree_H__
#define __ManiLibs_AVLTree_H__

/*××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××
	MP-safe:			yes, if a tree object is manipulated by one thread per time only
						(must be protected self by CriticalRegions!)
	MP-callable:	any context
××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××*/

#define AVLTREE_DEBUG 0

#include <Types2B.h>

#define AVLDIR_ROOT		0	// Root kann allerdings auch andere Directions haben! (undefiniert)
#define AVLDIR_LEFT		1
#define AVLDIR_RIGHT		2

class AVL {

friend class AVLTree;

	AVL *top;
	AVL *left;
	AVL *right;
	int16 left_height;
	int16 right_height;
	int8 direction;			// AVLDIR_ROOT, AVLDIR_LEFT, AVLDIR_RIGHT

public:
	virtual ~AVL();

	AVL *get_top() const {return top;};
	AVL *get_left() const {return left;};
	AVL *get_right() const {return right;};
	AVL *get_next() const;
	AVL *get_prev() const;
};

class AVLTree {
	AVL *root;
	int32 counter;

	void little_rotate_left(AVL *elem);
	void little_rotate_right(AVL *elem);
	void big_rotate_left(AVL *elem);
	void big_rotate_right(AVL *elem);
	void growbalance(AVL *elem, int8 child_direction, int8 grandchild_direction);
	void swap(AVL *a, AVL *b);
	void shrinkbalance(AVL *elem, int8 child_direction);
	void resort_rekursive(AVL *elem);

public:
	AVLTree();
	virtual ~AVLTree() = 0;

	virtual int32 compare(AVL *a, AVL *b) const = 0;
	virtual int32 compare(AVL *a, int32 val) const = 0;
	virtual int32 compare(AVL *a, void *ptr) const = 0;

	AVL *get_root() const {return root;};
	AVL *get_first() const;
	AVL *get_last() const;

	int32 get_counter() const {return counter;};

	void insert(AVL *elem);		// Element einhŠngen
	void remove(AVL *elem);		// Element ausklinken
	void kill(AVL *elem);		// Element ausklinken und zerstšren

	AVL *search(AVL *elem) const;
	AVL *search_nearest(AVL *elem, int8 *direction = (int8 *)0) const;
	AVL *search_nearest_leaf(AVL *elem, int8 *direction = (int8 *)0) const;
	AVL *search_left_nearest(AVL *elem) const;	// nearest but "lefter" (mostly smaller) or equal
	AVL *search_right_nearest(AVL *elem) const;	// nearest but "righter" (mostly bigger) or equal

	AVL *search(int32 val) const;
	AVL *search_nearest(int32 val, int8 *direction = (int8 *)0) const;
	AVL *search_nearest_leaf(int32 val, int8 *direction = (int8 *)0) const;
	AVL *search_left_nearest(int32 val) const;	// nearest but "lefter" (mostly smaller) or equal
	AVL *search_right_nearest(int32 val) const;	// nearest but "righter" (mostly bigger) or equal

	AVL *search(void *ptr) const;
	AVL *search_nearest(void *ptr, int8 *direction = (int8 *)0) const;
	AVL *search_nearest_leaf(void *ptr, int8 *direction = (int8 *)0) const;
	AVL *search_left_nearest(void *ptr) const;	// nearest but "lefter" (mostly smaller) or equal
	AVL *search_right_nearest(void *ptr) const;	// nearest but "righter" (mostly bigger) or equal


	void resort();				// Elemente neu sortieren (z.B. wenn sich compare geŠndert hat, oder viele Elemente verŠndert wurden)

	void empty_with_removing() {root = 0; counter = 0;};
	void empty_with_killing();

#if AVLTREE_DEBUG
	boolean debug();
#endif
};


// Einfachere Benutzung durch Templates:


template <class T>
class Node : public AVL {
public:
//	virtual ~Node();
	T *get_top() const {return (T *)AVL::get_top();};
	T *get_left() const {return (T *)AVL::get_left();};
	T *get_right() const {return (T *)AVL::get_right();};
	T *get_next() const {return (T *)AVL::get_next();};
	T *get_prev() const {return (T *)AVL::get_prev();};
};

template <class T>
class Tree : public AVLTree {
public:
//	virtual ~Tree();

/* Zur Benutzung zu implementieren (Vorschlag):

	int32 compare(T *a, T *b) const;				// zu implementieren
	int32 compare(T *a, int32 val) const;		// zu implementieren
	int32 compare(T *a, void *ptr) const;		// zu implementieren

	virtual int32 compare(AVL *a, AVL *b) const {
		return compare((T *)a, (T *)b);
	};
	virtual int32 compare(AVL *a, int32 val) const {
		return compare((T *)a, val);
	};
	virtual int32 compare(AVL *a, void *ptr) const {
		return compare((T *)a, ptr);
	};
*/

	T *get_root() const {return (T *)AVLTree::get_root();};
	T *get_first() const {return (T *)AVLTree::get_first();};
	T *get_last() const {return (T *)AVLTree::get_last();};

	void insert(T *elem) {AVLTree::insert((AVL *)elem);};
	void remove(T *elem) {AVLTree::remove((AVL *)elem);};
	void kill(T *elem) {AVLTree::kill((AVL *)elem);};

	T *search(T *elem) const {return (T *)AVLTree::search((AVL *)elem);};
	T *search_nearest(T *elem, int8 *direction = (int8 *)0) const {
		return (T *)AVLTree::search_nearest((AVL *)elem, direction);
	};
	T *search_nearest_leaf(T *elem, int8 *direction = (int8 *)0) const {
		return (T *)AVLTree::search_nearest_leaf((AVL *)elem, direction);
	};
	T *search_left_nearest(T *elem) const {
		return (T *)AVLTree::search_left_nearest((AVL *)elem);
	};
	T *search_right_nearest(T *elem) const {
		return (T *)AVLTree::search_right_nearest((AVL *)elem);
	};

	T *search(int32 val) const {return (T *)AVLTree::search(val);};
	T *search_nearest(int32 val, int8 *direction = (int8 *)0) const {
		return (T *)AVLTree::search_nearest(val, direction);
	};
	T *search_nearest_leaf(int32 val, int8 *direction = (int8 *)0) const {
		return (T *)AVLTree::search_nearest_leaf(val, direction);
	};
	T *search_left_nearest(int32 val) const {
		return (T *)AVLTree::search_left_nearest(val);
	};
	T *search_right_nearest(int32 val) const {
		return (T *)AVLTree::search_right_nearest(val);
	};

	T *search(void *ptr) const {return (T *)AVLTree::search(ptr);};
	T *search_nearest(void *ptr, int8 *direction = (int8 *)0) const {
		return (T *)AVLTree::search_nearest(ptr, direction);
	};
	T *search_nearest_leaf(void *ptr, int8 *direction = (int8 *)0) const {
		return (T *)AVLTree::search_nearest(ptr, direction);
	};
	T *search_left_nearest(void *ptr) const {
		return (T *)AVLTree::search_left_nearest(ptr);
	};
	T *search_right_nearest(void *ptr) const {
		return (T *)AVLTree::search_right_nearest(ptr);
	};
};

#endif
