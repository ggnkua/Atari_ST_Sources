/*----------------------------------------------------------------------------------------
	AVLTree.cp, class for handling automatically balanced binary trees
	
	9.12.1998 by Manfred Lippert, mani@mani.de

	last change: 10.7.2000
----------------------------------------------------------------------------------------*/

#include <AVLTree.h>
#if AVLTREE_DEBUG
#include <stdio.h>
#endif

// AVL element:

AVL::~AVL() {
}

AVL *AVL::get_next() const {
	const AVL *such = get_right();
	if (such) {
		AVL *left;
		while ((left = such->get_left()) != 0L) {
			such = left;
		}
		return const_cast<AVL *>(such);
	}
	such = this;
	while (such && such->direction == AVLDIR_RIGHT) {
		such = such->get_top();
	}
	if (such) {
		return such->get_top();
	}
	return const_cast<AVL *>(such);
}

AVL *AVL::get_prev() const {
	const AVL *such = get_left();
	if (such) {
		AVL *right;
		while ((right = such->get_right()) != 0L) {
			such = right;
		}
		return const_cast<AVL *>(such);
	}
	such = this;
	while (such && such->direction == AVLDIR_LEFT) {
		such = such->get_top();
	}
	if (such) {
		return such->get_top();
	}
	return const_cast<AVL *>(such);
}

// AVL tree:

AVLTree::AVLTree() {
	root = 0;
	counter = 0;
}

AVLTree::~AVLTree() {
}

void AVLTree::empty_with_killing() {
	AVL *elem;
	while ((elem = get_root()) != 0) {
		kill(elem);
	}
/*
	UngŸnstig! Zerstšrung eines Elementes kšnnte Zerstšrung anderer mit sich ziehen,
	daher kšnnte der "next"-Zeiger ins Leere zeigen!

	AVL *elem = get_first();
	AVL *next;
	while (elem) {
		next = elem->get_next();
		kill(elem);				// alle Elemente zerstšren
		elem = next;
	}
*/
}

void AVLTree::little_rotate_left(AVL *elem) {
	AVL *top = elem->get_top();
	AVL *left = elem->get_left();
	AVL *grand_right = left->get_right();

	if (!top) {
		root = left;
	} else {
		if (elem->direction == AVLDIR_LEFT) {
			top->left = left;
		} else {
			top->right = left;
		}
	}
	left->direction = elem->direction;
	left->top = top;
	elem->left_height = left->right_height++;

	left->right = elem;
	elem->top = left;
	elem->direction = AVLDIR_RIGHT;

	elem->left = grand_right;
	if (grand_right) {				// 1.2.2000 war manchmal 0!
		grand_right->top = elem;
		grand_right->direction = AVLDIR_LEFT;
	}
}

void AVLTree::little_rotate_right(AVL *elem) {
	AVL *top = elem->get_top();
	AVL *right = elem->get_right();
	AVL *grand_left = right->get_left();

	if (!top) {
		root = right;
	} else {
		if (elem->direction == AVLDIR_LEFT) {
			top->left = right;
		} else {
			top->right = right;
		}
	}
	right->top = top;
	right->direction = elem->direction;
	elem->right_height = right->left_height++;

	right->left = elem;
	elem->top = right;
	elem->direction = AVLDIR_LEFT;

	elem->right = grand_left;
	if (grand_left) {				// 1.2.2000 war manchmal 0!
		grand_left->top = elem;
		grand_left->direction = AVLDIR_RIGHT;
	}
}

void AVLTree::big_rotate_left(AVL *elem) {
	AVL *top = elem->get_top();
	AVL *left = elem->get_left();
	AVL *grand_right = left->get_right();
	AVL *great_grand_left = grand_right->get_left();
	AVL *great_grand_right = grand_right->get_right();

	left->right_height = grand_right->left_height;
	grand_right->left_height = (int16)(elem->left_height - 1);
	elem->left_height = grand_right->right_height;
	grand_right->right_height = (int16)(elem->right_height + 1);

	if (!top) {
		root = grand_right;
	} else {
		if (elem->direction == AVLDIR_LEFT) {
			top->left = grand_right;
		} else {
			top->right = grand_right;
		}
	}

	grand_right->top = top;
	grand_right->direction = elem->direction;
	grand_right->left = left;
	grand_right->right = elem;

	left->top = grand_right;
	left->right = great_grand_left;

	elem->top = grand_right;
	elem->direction = AVLDIR_RIGHT;
	elem->left = great_grand_right;

	if (great_grand_left) {
		great_grand_left->top = left;
		great_grand_left->direction = AVLDIR_RIGHT;
	}

	if (great_grand_right) {
		great_grand_right->top = elem;
		great_grand_right->direction = AVLDIR_LEFT;
	}
}

void AVLTree::big_rotate_right(AVL *elem) {
	AVL *top = elem->get_top();
	AVL *right = elem->get_right();
	AVL *grand_left = right->get_left();
	AVL *great_grand_left = grand_left->get_left();
	AVL *great_grand_right = grand_left->get_right();

	right->left_height = grand_left->right_height;
	grand_left->right_height = (int16)(elem->right_height - 1);
	elem->right_height = grand_left->left_height;
	grand_left->left_height = (int16)(elem->left_height + 1);

	if (!top) {
		root = grand_left;
	} else {
		if (elem->direction == AVLDIR_LEFT) {
			top->left = grand_left;
		} else {
			top->right = grand_left;
		}
	}

	grand_left->top = top;
	grand_left->direction = elem->direction;
	grand_left->right = right;
	grand_left->left = elem;

	right->top = grand_left;
	right->left = great_grand_right;

	elem->top = grand_left;
	elem->direction = AVLDIR_LEFT;
	elem->right = great_grand_left;

	if (great_grand_right) {
		great_grand_right->top = right;
		great_grand_right->direction = AVLDIR_LEFT;
	}

	if (great_grand_left) {
		great_grand_left->top = elem;
		great_grand_left->direction = AVLDIR_RIGHT;
	}
}

// Hšhe des Astes um eins erhšhen und ggf. ausbalancieren
void AVLTree::growbalance(AVL *elem, int8 child_direction, int8 grandchild_direction) {
	do {
		if (child_direction == AVLDIR_LEFT) {
			if (++elem->left_height > elem->right_height + 1) {	// mu§ rotiert werden?
				if (child_direction != grandchild_direction) {
					big_rotate_left(elem);
				} else {
					little_rotate_left(elem);
				}
				return;
			}
			if (elem->left_height <= elem->right_height) {			// Vater wird nicht hšher?
				return;
			}
		} else {
			if (++elem->right_height > elem->left_height + 1) {	// mu§ rotiert werden?
				if (child_direction != grandchild_direction) {
					big_rotate_right(elem);
				} else {
					little_rotate_right(elem);
				}
				return;
			}
			if (elem->right_height <= elem->left_height) {			// Vater wird nicht hšher?
				return;
			}
		}
		grandchild_direction = child_direction;
		child_direction = elem->direction;
		elem = elem->get_top();
	} while (elem);
}

void AVLTree::insert(AVL *elem) {
	AVL *pos = search_nearest_leaf(elem, &elem->direction);
	elem->top = pos;
	elem->left = 0;
	elem->right = 0;
	elem->left_height = 0;
	elem->right_height = 0;
	if (!pos) {			/* Noch kein Element - als Root eingefŸgt */
		root = elem;
	} else {						/* ggf. ausbalancieren */
		if (elem->direction == AVLDIR_LEFT) {	/* links eingefŸgt */
			pos->left = elem;
			growbalance(pos, AVLDIR_LEFT, AVLDIR_ROOT);
		} else {								/* rechts eingefŸgt */
			elem->direction = AVLDIR_RIGHT;	// kšnnte hier auch AVLDIR_ROOT sein, falls gleiches schon Element existiert
			pos->right = elem;
			growbalance(pos, AVLDIR_RIGHT, AVLDIR_ROOT);
		}
	}

	counter++;
#if AVLTREE_DEBUG
	if (!debug()) {
		printf(">>> Error in AVLTree::insert()!\n");
	}
#endif
}

void AVLTree::swap(AVL *a, AVL *b) {
	AVL *a_top = a->get_top();
	AVL *a_left = a->get_left();
	AVL *a_right = a->get_right();
	AVL *b_top = b->get_top();
	AVL *b_left = b->get_left();
	AVL *b_right = b->get_right();

	{								/* Inhalt von a und b tauschen */
		int16 a_lheight = a->left_height;
		int16 a_rheight = a->right_height;
		int8 a_dir = a->direction;

		a->top = b_top;
		a->left = b_left;
		a->right = b_right;
		a->left_height = b->left_height;
		a->right_height = b->right_height;
		a->direction = b->direction;

		b->top = a_top;
		b->left = a_left;
		b->right = a_right;
		b->left_height = a_lheight;
		b->right_height = a_rheight;
		b->direction = a_dir;

/*
		AVL help = *a;	// geht nicht wegen virtueller Funktionen in AVL
		*a = *b;
		*b = help;
*/
	}

	if (a->top == a) {				/* a zeigt auf sich selbst (-> b mu§ auf a gezeigt haben, daher muž a jetzt auf b zeigen) */
		a->top = b;
	} else if (a->left == a) {		/* a zeigt auf sich selbst */
		a->left = b;
	} else if (a->right == a) {		/* a zeigt auf sich selbst */
		a->right = b;
	}

	if (b->top == b) {				/* b zeigt auf sich selbst */
		b->top = a;
	} else if (b->left == b) {		/* b zeigt auf sich selbst */
		b->left = a;
	} else if (b->right == b) {		/* b zeigt auf sich selbst */
		b->right = a;
	}

	if (!a_top) {
		root = b;							/* a war Root, jetzt wird es b */
	} else if (a_top != b) {
		if (b->direction == AVLDIR_LEFT) {	/* Element Ÿber a bekommt jetzt b als Nachfolger */
			a_top->left = b;
		} else {
			a_top->right = b;
		}
	}

	if (!b_top) {
		root = a;							/* b war Root, jetzt wird es a */
	} else if (b_top != a) {
		if (a->direction == AVLDIR_LEFT) {	/* Element Ÿber b bekommt jetzt a als Nachfolger */
			b_top->left = a;
		} else {
			b_top->right = a;
		}
	}

	if (a_left && a_left != b) {
		a_left->top = b;		/* linker Nachfolger von a bekommt jetzt b als Vater */
	}
	if (a_right && a_right != b) {
		a_right->top = b;		/* rechter Nachfolger von a bekommt jetzt b als Vater */
	}

	if (b_left && b_left != a) {
		b_left->top = a;		/* linker Nachfolger von b bekommt jetzt a als Vater */
	}
	if (b_right && b_right != a) {
		b_right->top = a;		/* rechter Nachfolger von b bekommt jetzt a als Vater */
	}

}

void AVLTree::shrinkbalance(AVL *elem, int8 child_direction) {
	int8 elem_direction;
	AVL *top;

	do {

		elem_direction = elem->direction;
		top = elem->get_top();
		
		if (child_direction == AVLDIR_LEFT) {
			if (--elem->left_height < elem->right_height - 1) {	/* mu§ rotiert werden? */
				AVL *right = elem->get_right();					/* Ursache (lŠngeren Enkel-Ast) feststellen */
				if (right->left_height > right->right_height) {	/* innerer Knoten */
					big_rotate_right(elem);
				} else {
					little_rotate_right(elem);
				}
				if (!top) {
					return;
				}
				if (elem_direction == AVLDIR_LEFT) {
					elem = top->get_left();
					if (elem->left_height == top->left_height - 1 || elem->right_height == top->left_height - 1) {
						return;
					}
				} else {
					elem = top->get_right();
					if (elem->left_height == top->right_height - 1 || elem->right_height == top->right_height - 1) {
						return;
					}
				}
			} else if (elem->left_height < elem->right_height) {	/* Vater wird nicht kleiner? */
				return;
			}
		} else {
			if (--elem->right_height < elem->left_height - 1) {	/* mu§ rotiert werden? */
				AVL *left = elem->get_left();						/* Ursache (lŠngeren Enkel-Ast) feststellen */
				if (left->left_height < left->right_height) {	/* innerer Knoten */
					big_rotate_left(elem);
				} else {
					little_rotate_left(elem);
				}
				if (!top) {
					return;
				}
				if (elem_direction == AVLDIR_LEFT) {
					elem = top->get_left();
					if (elem->left_height == top->left_height - 1 || elem->right_height == top->left_height - 1) {
						return;
					}
				} else {
					elem = top->get_right();
					if (elem->left_height == top->right_height - 1 || elem->right_height == top->right_height - 1) {
						return;
					}
				}
			} else if (elem->right_height < elem->left_height) {	/* Vater wird nicht kleiner? */
				return;
			}
		}

		child_direction = elem_direction;
		elem = top;

	} while (elem);
}

void AVLTree::remove(AVL *elem) {
	{
		AVL *tausch = elem->get_left();					/* vom linken Unterbaum... */
		if (tausch) {									/* (falls vorhanden) */
			AVL *el2;
			do {
				while ((el2 = tausch->get_right()) != 0L) {	/* ...das rechteste suchen... */
					tausch = el2;
				}
				swap(elem, tausch);							/* ...und mit dem zu lšschenden vertauschen */
				tausch = elem->get_left();					/* weiterversuchen (tausch mu§ noch kein Blatt sein!) */
			} while (tausch);
		} else {
			AVL *el2;
			tausch = elem->get_right();					/* oder vom rechten Unterbaum... */
			if (tausch) {
				do {
					while ((el2 = tausch->get_left()) != 0L) {/* ...das linkeste suchen... */
						tausch = el2;
					}
					swap(elem, tausch);						/* ...und mit dem zu lšschenden vertauschen */
					tausch = elem->get_right();				/* weiterversuchen (tausch mu§ noch kein Blatt sein!) */
				} while (tausch);
			}
		}
	}

	/* Jetzt elem (Blatt) entfernen: */

	{
		AVL *top = elem->get_top();
		if (!top) {
			root = 0;			/* War letztes Element */
		} else {
			if (elem->direction == AVLDIR_LEFT) {
				top->left = 0;
				shrinkbalance(top, AVLDIR_LEFT);
			} else {
				top->right = 0;
				shrinkbalance(top, AVLDIR_RIGHT);
			}
		}
	}

	counter--;
#if AVLTREE_DEBUG
	if (!debug()) {
		printf(">>> Error in AVLTree::remove()!\n");
	}
#endif
}

void AVLTree::kill(AVL *elem) {
	remove(elem);
	delete elem;
}

AVL *AVLTree::search(AVL *elem) const {
	AVL *such = get_root();
	int32 comp;
	while (such) {
		comp = compare(elem, such);
		if (comp == 0) {
			return such;
		}
		if (comp < 0) {
			such = such->get_left();
		} else {
			such = such->get_right();
		}
	}
	return such;
}

AVL *AVLTree::search_nearest(AVL *elem, int8 *direction) const {
	AVL *such = get_root();
	AVL *next;
	int32 comp;
	if (direction) {
		*direction = AVLDIR_ROOT;	// matches exactly or not found
	}
	while (such) {
		comp = compare(elem, such);
		if (comp == 0) {
			return such;
		}
		if (comp < 0) {
			next = such->get_left();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_LEFT;	// element to search for is "lefter" than found one
				}
				return such;
			}
		} else {
			next = such->get_right();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_RIGHT;	// element to search for is "righter" than found one
				}
				return such;
			}
		}
		such = next;
	}
	return such;
}

AVL *AVLTree::search_nearest_leaf(AVL *elem, int8 *direction) const {
	AVL *such = get_root();
	AVL *next;
	int32 comp;
	while (such) {
		comp = compare(elem, such);
		if (comp < 0) {
			next = such->get_left();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_LEFT;	// element to search for is "lefter" than found one
				}
				return such;
			}
		} else {
			next = such->get_right();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_RIGHT;	// element to search for is "righter" than found one
				}
				return such;
			}
		}
		such = next;
	}
	return such;
}

AVL *AVLTree::search_left_nearest(AVL *elem) const {	// find nearest but "lefter" (mostly smaller) or equal element
	int8 direction;
	AVL *such = search_nearest(elem, &direction);
	if (such && direction == AVLDIR_LEFT) {	// found, but element to search for is "lefter" (wrong - found element must be lefter!)
		do {
			such = such->get_prev();				// hopefully, this one is "lefter" (but it can be equal to already found one)
		} while (such && compare(such, elem) > 0);	// while the found one is righter
	}
	return such;
}

AVL *AVLTree::search_right_nearest(AVL *elem) const {	// find nearest but "righter" (mostly bigger) or equal element
	int8 direction;
	AVL *such = search_nearest(elem, &direction);
	if (such && direction == AVLDIR_RIGHT) {	// found, but element to search for is "righter" (wrong - found element must be lefter!)
		do {
			such = such->get_next();				// hopefully, this one is "righter" (but it can be equal to already found one)
		} while (such && compare(such, elem) < 0);	// while the found one is lefter
	}
	return such;
}

AVL *AVLTree::search(int32 val) const {
	AVL *such = get_root();
	int32 comp;
	while (such) {
		comp = compare(such, val);
		if (comp == 0) {
			return such;
		}
		if (comp > 0) {
			such = such->get_left();
		} else {
			such = such->get_right();
		}
	}
	return such;
}

AVL *AVLTree::search_nearest(int32 val, int8 *direction) const {
	AVL *such = get_root();
	AVL *next;
	int32 comp;
	if (direction) {
		*direction = AVLDIR_ROOT;	// matches exactly or not found
	}
	while (such) {
		comp = compare(such, val);
		if (comp == 0) {
			return such;
		}
		if (comp > 0) {
			next = such->get_left();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_LEFT;
				}
				return such;
			}
		} else {
			next = such->get_right();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_RIGHT;
				}
				return such;
			}
		}
		such = next;
	}
	return such;
}

AVL *AVLTree::search_nearest_leaf(int32 val, int8 *direction) const {
	AVL *such = get_root();
	AVL *next;
	int32 comp;
	while (such) {
		comp = compare(such, val);
		if (comp > 0) {
			next = such->get_left();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_LEFT;
				}
				return such;
			}
		} else {
			next = such->get_right();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_RIGHT;
				}
				return such;
			}
		}
		such = next;
	}
	return such;
}

AVL *AVLTree::search_left_nearest(int32 val) const {	// find nearest but "lefter" (mostly smaller) or equal element
	int8 direction;
	AVL *such = search_nearest(val, &direction);
	if (such && direction == AVLDIR_LEFT) {	// found, but element to search for is "lefter" (wrong - found element must be lefter!)
		do {
			such = such->get_prev();				// hopefully, this one is "lefter" (but it can be equal to already found one)
		} while (such && compare(such, val) > 0);	// while the found one is righter
	}
	return such;
}

AVL *AVLTree::search_right_nearest(int32 val) const {	// find nearest but "righter" (mostly bigger) or equal element
	int8 direction;
	AVL *such = search_nearest(val, &direction);
	if (such && direction == AVLDIR_RIGHT) {	// found, but element to search for is "righter" (wrong - found element must be lefter!)
		do {
			such = such->get_next();				// hopefully, this one is "righter" (but it can be equal to already found one)
		} while (such && compare(such, val) < 0);	// while the found one is lefter
	}
	return such;
}

AVL *AVLTree::search(void *ptr) const {
	AVL *such = get_root();
	int32 comp;
	while (such) {
		comp = compare(such, ptr);
		if (comp == 0) {
			return such;
		}
		if (comp > 0) {
			such = such->get_left();
		} else {
			such = such->get_right();
		}
	}
	return such;
}

AVL *AVLTree::search_nearest(void *ptr, int8 *direction) const {
	AVL *such = get_root();
	AVL *next;
	int32 comp;
	if (direction) {
		*direction = AVLDIR_ROOT;	// matches exactly or not found
	}
	while (such) {
		comp = compare(such, ptr);
		if (comp == 0) {
			return such;
		}
		if (comp > 0) {
			next = such->get_left();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_LEFT;
				}
				return such;
			}
		} else {
			next = such->get_right();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_RIGHT;
				}
				return such;
			}
		}
		such = next;
	}
	return such;
}

AVL *AVLTree::search_nearest_leaf(void *ptr, int8 *direction) const {
	AVL *such = get_root();
	AVL *next;
	int32 comp;
	while (such) {
		comp = compare(such, ptr);
		if (comp > 0) {
			next = such->get_left();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_LEFT;
				}
				return such;
			}
		} else {
			next = such->get_right();
			if (!next) {
				if (direction) {
					*direction = AVLDIR_RIGHT;
				}
				return such;
			}
		}
		such = next;
	}
	return such;
}

AVL *AVLTree::search_left_nearest(void *ptr) const {	// find nearest but "lefter" (mostly smaller) or equal element
	int8 direction;
	AVL *such = search_nearest(ptr, &direction);
	if (such && direction == AVLDIR_LEFT) {	// found, but element to search for is "lefter" (wrong - found element must be lefter!)
		do {
			such = such->get_prev();				// hopefully, this one is "lefter" (but it can be equal to already found one)
		} while (such && compare(such, ptr) > 0);	// while the found one is righter
	}
	return such;
}

AVL *AVLTree::search_right_nearest(void *ptr) const {	// find nearest but "righter" (mostly bigger) or equal element
	int8 direction;
	AVL *such = search_nearest(ptr, &direction);
	if (such && direction == AVLDIR_RIGHT) {	// found, but element to search for is "righter" (wrong - found element must be lefter!)
		do {
			such = such->get_next();				// hopefully, this one is "righter" (but it can be equal to already found one)
		} while (such && compare(such, ptr) < 0);	// while the found one is lefter
	}
	return such;
}

AVL *AVLTree::get_first() const {
	AVL *elem = get_root();
	if (elem) {
		AVL *left;
		while ((left = elem->get_left()) != 0L) {
			elem = left;
		}
	}
	return elem;
}

AVL *AVLTree::get_last() const {
	AVL *elem = get_root();
	if (elem) {
		AVL *right;
		while ((right = elem->get_right()) != 0L) {
			elem = right;
		}
	}
	return elem;
}

void AVLTree::resort_rekursive(AVL *el) {
	AVL *left = el->get_left();
	AVL *right = el->get_right();
	insert(el);
	if (left) {
		resort_rekursive(left);
	}
	if (right) {
		resort_rekursive(right);
	}
}

void AVLTree::resort() {
	AVL *root = get_root();
	if (root) {
		empty_with_removing();
		resort_rekursive(root);
	}
}

#if AVLTREE_DEBUG

boolean AVLTree::debug() {
	boolean ok = TRUE;
	int32 count = 0;
	AVL *prev = 0;
	AVL *el = get_first();
	while (el) {
		if (prev) {
			if (compare(prev, el) > 0) {
				printf("Wrong AVL-Order!!! (AVLTree 0x%ld)\n", (long)this);
				ok = FALSE;
			}
		}
		count++;
		prev = el;
		el = el->get_next();
		if (count > counter * 3) {
			printf("AVL-Tree error: possibly recursion!!! (stopped counting at %ld) (AVLTree 0x%ld)\n", (long)count, (long)this);
			break;
		}
	}
	if (count != counter) {
		printf("AVL-Tree error: Wrong counter!!! (should be %ld, is %ld) (AVLTree 0x%ld)\n", (long)counter, (long)count, (long)this);
		ok = FALSE;
	}
	return ok;
}

#endif
