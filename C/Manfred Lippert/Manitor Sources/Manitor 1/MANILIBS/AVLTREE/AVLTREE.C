#include <manilibs\AVLTree\AVLTree.h>

#pragma warn -par
static int16 AVL_std_compare(AVLTree *tree, AVL *a, AVL *b) {
	return 0;
}

static AVL *AVL_std_get_root(AVLTree *tree, Err *err) {
	return tree->root;
}

static AVL *AVL_std_get_top(AVLTree *tree, AVL *a, Err *err) {
	return a->top;
}

static AVL *AVL_std_get_left(AVLTree *tree, AVL *a, Err *err) {
	return a->left;
}

static AVL *AVL_std_get_right(AVLTree *tree, AVL *a, Err *err) {
	return a->right;
}
#pragma warn .par

AVLTree_vtab AVLTree_std_vtab = {
	AVL_std_compare,
	AVL_std_get_root,
	AVL_std_get_top,
	AVL_std_get_left,
	AVL_std_get_right
};

/* vtab darf 0L sein, dann wird Standard verwendet */
void AVLTree_init(AVLTree *tree, AVLTree_vtab *vtab) {
	tree->root = 0L;
	tree->vtab = vtab ? vtab : &AVLTree_std_vtab;
}

static void AVL_little_rotate_left(AVLTree *tree, AVL *elem, Err *err) {
	AVL *top = AVL_top(tree, elem, err);
	AVL *left = AVL_left(tree, elem, err);
	AVL *grand_right = AVL_right(tree, left, err);

	if (Error(err)) {
		return;
	}

	if (!top) {
		tree->root = left;
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
	grand_right->top = elem;
	grand_right->direction = AVLDIR_LEFT;
}

static void AVL_little_rotate_right(AVLTree *tree, AVL *elem, Err *err) {
	AVL *top = AVL_top(tree, elem, err);
	AVL *right = AVL_right(tree, elem, err);
	AVL *grand_left = AVL_left(tree, right, err);

	if (Error(err)) {
		return;
	}

	if (!top) {
		tree->root = right;
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
	grand_left->top = elem;
	grand_left->direction = AVLDIR_RIGHT;
}

static void AVL_big_rotate_left(AVLTree *tree, AVL *elem, Err *err) {
	AVL *top = AVL_top(tree, elem, err);
	AVL *left = AVL_left(tree, elem, err);
	AVL *grand_right = AVL_right(tree, left, err);
	AVL *great_grand_left = AVL_left(tree, grand_right, err);
	AVL *great_grand_right = AVL_right(tree, grand_right, err);

	if (Error(err)) {
		return;
	}

	left->right_height = grand_right->left_height;
	grand_right->left_height = elem->left_height - 1;
	elem->left_height = grand_right->right_height;
	grand_right->right_height = elem->right_height + 1;

	if (!top) {
		tree->root = grand_right;
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

	great_grand_left->top = left;
	great_grand_left->direction = AVLDIR_RIGHT;

	great_grand_right->top = elem;
	great_grand_right->direction = AVLDIR_LEFT;
}

static void AVL_big_rotate_right(AVLTree *tree, AVL *elem, Err *err) {
	AVL *top = AVL_top(tree, elem, err);
	AVL *right = AVL_right(tree, elem, err);
	AVL *grand_left = AVL_left(tree, right, err);
	AVL *great_grand_left = AVL_left(tree, grand_left, err);
	AVL *great_grand_right = AVL_right(tree, grand_left, err);

	if (Error(err)) {
		return;
	}

	right->left_height = grand_left->right_height;
	grand_left->right_height = elem->right_height - 1;
	elem->right_height = grand_left->left_height;
	grand_left->left_height = elem->left_height + 1;

	if (!top) {
		tree->root = grand_left;
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

	great_grand_right->top = right;
	great_grand_right->direction = AVLDIR_LEFT;

	great_grand_left->top = elem;
	great_grand_left->direction = AVLDIR_RIGHT;
}

/* H”he des Astes um eins erh”hen und ggf. aufbalancieren */
static void AVL_growbalance(AVLTree *tree, AVL *elem, int8 child_direction, int8 grandchild_direction, Err *err) {
	do {
		if (child_direction == AVLDIR_LEFT) {
			if (++elem->left_height > elem->right_height + 1) {	/* muž rotiert werden? */
				if (child_direction != grandchild_direction) {
					AVL_big_rotate_left(tree, elem, err);
				} else {
					AVL_little_rotate_left(tree, elem, err);
				}
				return;
			}
			if (elem->left_height <= elem->right_height) {	/* Vater wird nicht h”her? */
				return;
			}
		} else {
			if (++elem->right_height > elem->left_height + 1) {	/* muž rotiert werden? */
				if (child_direction != grandchild_direction) {
					AVL_big_rotate_right(tree, elem, err);
				} else {
					AVL_little_rotate_right(tree, elem, err);
				}
				return;
			}
			if (elem->right_height <= elem->left_height) {	/* Vater wird nicht h”her? */
				return;
			}
		}
		grandchild_direction = child_direction;
		child_direction = elem->direction;
		elem = AVL_top(tree, elem, err);
	} while (elem && Ok(err));
}

void AVL_insert(AVLTree *tree, AVL *elem, Err *err) {
	AVL *pos = AVL_search_nearest(tree, elem, &elem->direction, err);
	if (Error(err)) {
		return;
	}
	elem->top = pos;
	elem->left = 0L;
	elem->right = 0L;
	elem->left_height = 0;
	elem->right_height = 0;
	if (!pos) {			/* Noch kein Element - als Root eingefgt */
		tree->root = elem;
	} else {						/* ggf. ausbalancieren */
		if (elem->direction == AVLDIR_LEFT) {	/* links eingefgt */
			pos->left = elem;
			AVL_growbalance(tree, pos, AVLDIR_LEFT, AVLDIR_ROOT, err);
		} else {										/* rechts eingefgt */
			pos->right = elem;
			AVL_growbalance(tree, pos, AVLDIR_RIGHT, AVLDIR_ROOT, err);
		}
	}
}

static void AVL_swap(AVLTree *tree, AVL *a, AVL *b, Err *err) {
	AVL *a_top = AVL_top(tree, a, err);
	AVL *a_left = AVL_left(tree, a, err);
	AVL *a_right = AVL_right(tree, a, err);
	AVL *b_top = AVL_top(tree, b, err);
	AVL *b_left = AVL_left(tree, b, err);
	AVL *b_right = AVL_right(tree, b, err);

	if (Error(err)) {
		return;
	}

	{								/* Inhalt von a und b tauschen */
		AVL help = *a;
		*a = *b;
		*b = help;
	}

	if (a->top == a) {				/* a zeigt auf sich selbst (-> b muž auf a gezeigt haben, daher muž a jetzt auf b zeigen) */
		a->top = b;
	} else if (a->left == a) {		/* a zeigt auf sich selbst */
		a->left = b;
	} else if (a->right == a) {	/* a zeigt auf sich selbst */
		a->right = b;
	}

	if (b->top == b) {				/* b zeigt auf sich selbst */
		b->top = a;
	} else if (b->left == b) {		/* b zeigt auf sich selbst */
		b->left = a;
	} else if (b->right == b) {	/* b zeigt auf sich selbst */
		b->right = a;
	}

	if (!a_top) {
		tree->root = b;							/* a war Root, jetzt wird es b */
	} else if (a_top != b) {
		if (b->direction == AVLDIR_LEFT) {	/* Element ber a bekommt jetzt b als Nachfolger */
			a_top->left = b;
		} else {
			a_top->right = b;
		}
	}

	if (!b_top) {
		tree->root = a;							/* b war Root, jetzt wird es a */
	} else if (b_top != a) {
		if (a->direction == AVLDIR_LEFT) {	/* Element ber b bekommt jetzt a als Nachfolger */
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

static void AVL_shrinkbalance(AVLTree *tree, AVL *elem, int8 child_direction, Err *err) {
	int8 elem_direction;
	AVL *top;

	do {

		elem_direction = elem->direction;
		top = AVL_top(tree, elem, err);
		
		if (child_direction == AVLDIR_LEFT) {
			if (--elem->left_height < elem->right_height - 1) {	/* muž rotiert werden? */
				AVL *right = AVL_right(tree, elem, err);				/* Ursache (l„ngeren Enkel-Ast) feststellen */
				if (Error(err)) {
					return;
				}
				if (right->left_height > right->right_height) {		/* innerer Knoten */
					AVL_big_rotate_right(tree, elem, err);
				} else {
					AVL_little_rotate_right(tree, elem, err);
				}
				if (!top || Error(err)) {
					return;
				}
				if (elem_direction == AVLDIR_LEFT) {
					elem = AVL_left(tree, top, err);
					if (Error(err)) {
						return;
					}
					if (elem->left_height == top->left_height - 1 || elem->right_height == top->left_height - 1) {
						return;
					}
				} else {
					elem = AVL_right(tree, top, err);
					if (Error(err)) {
						return;
					}
					if (elem->left_height == top->right_height - 1 || elem->right_height == top->right_height - 1) {
						return;
					}
				}
			} else if (elem->left_height < elem->right_height) {	/* Vater wird nicht kleiner? */
				return;
			}
		} else {
			if (--elem->right_height < elem->left_height - 1) {	/* muž rotiert werden? */
				AVL *left = AVL_left(tree, elem, err);					/* Ursache (l„ngeren Enkel-Ast) feststellen */
				if (Error(err)) {
					return;
				}
				if (left->left_height < left->right_height) {		/* innerer Knoten */
					AVL_big_rotate_left(tree, elem, err);
				} else {
					AVL_little_rotate_left(tree, elem, err);
				}
				if (!top || Error(err)) {
					return;
				}
				if (elem_direction == AVLDIR_LEFT) {
					elem = AVL_left(tree, top, err);
					if (Error(err)) {
						return;
					}
					if (elem->left_height == top->left_height - 1 || elem->right_height == top->left_height - 1) {
						return;
					}
				} else {
					elem = AVL_right(tree, top, err);
					if (Error(err)) {
						return;
					}
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

void AVL_remove(AVLTree *tree, AVL *elem, Err *err) {
	{
		AVL *tausch = AVL_left(tree, elem, err);					/* vom linken Unterbaum... */
		if (Error(err)) {
			return;
		}
		if (tausch) {														/* (falls vorhanden) */
			AVL *el2;
			do {
				while ((el2 = AVL_right(tree, tausch, err)) != 0L && Ok(err)) {	/* ...das rechteste suchen... */
					tausch = el2;
				}
				if (Error(err)) {
					return;
				}
				AVL_swap(tree, elem, tausch, err);					/* ...und mit dem zu l”schenden vertauschen */
				if (Error(err)) {
					return;
				}
				tausch = AVL_left(tree, elem, err);					/* weiterversuchen (tausch muž noch kein Blatt sein!) */
				if (Error(err)) {
					return;
				}
			} while (tausch);
		} else {
			AVL *el2;
			tausch = AVL_right(tree, elem, err);					/* oder vom rechten Unterbaum... */
			if (Error(err)) {
				return;
			}
			if (tausch) {
				do {
					while ((el2 = AVL_left(tree, tausch, err)) != 0L && Ok(err)) {	/* ...das linkeste suchen... */
						tausch = el2;
					}
					if (Error(err)) {
						return;
					}
					AVL_swap(tree, elem, tausch, err);				/* ...und mit dem zu l”schenden vertauschen */
					if (Error(err)) {
						return;
					}
					tausch = AVL_right(tree, elem, err);			/* weiterversuchen (tausch muž noch kein Blatt sein!) */
					if (Error(err)) {
						return;
					}
				} while (tausch);
			}
		}
	}

	/* Jetzt elem (Blatt) entfernen: */

	{
		AVL *top = AVL_top(tree, elem, err);
		if (Error(err)) {
			return;
		}
		if (!top) {
			tree->root = 0L;		/* War letztes Element */
		} else {
			if (elem->direction == AVLDIR_LEFT) {
				top->left = 0L;
				AVL_shrinkbalance(tree, top, AVLDIR_LEFT, err);
			} else {
				top->right = 0L;
				AVL_shrinkbalance(tree, top, AVLDIR_RIGHT, err);
			}
		}
	}
}

AVL *AVL_search(AVLTree *tree, AVL *elem, Err *err) {
	AVL *such = AVL_root(tree, err);
	int16 comp;
	while (Ok(err) && such) {
		comp = AVL_compare(tree, elem, such);
		if (comp == 0) {
			return such;
		}
		if (comp < 0) {
			such = AVL_left(tree, such, err);
		} else {
			such = AVL_right(tree, such, err);
		}
	}
	return such;
}

AVL *AVL_search_nearest(AVLTree *tree, AVL *elem, int8 *direction, Err *err) {
	AVL *such = AVL_root(tree, err);
	AVL *next;
	int16 comp;
	if (Error(err)) {
		return 0L;
	}
	while (such) {
		comp = AVL_compare(tree, elem, such);
		if (comp < 0) {
			next = AVL_left(tree, such, err);
			if (Error(err)) {
				return 0L;
			}
			if (!next) {
				*direction = AVLDIR_LEFT;
				return such;
			}
		} else {
			next = AVL_right(tree, such, err);
			if (Error(err)) {
				return 0L;
			}
			if (!next) {
				*direction = AVLDIR_RIGHT;
				return such;
			}
		}
		such = next;
	}
	return such;
}

AVL *AVL_first(AVLTree *tree, Err *err) {
	AVL *elem = AVL_root(tree, err);
	if (Ok(err) && elem) {
		AVL *left;
		while ((left = AVL_left(tree, elem, err)) != 0L && Ok(err)) {
			elem = left;
		}
	}
	return elem;
}

AVL *AVL_last(AVLTree *tree, Err *err) {
	AVL *elem = AVL_root(tree, err);
	if (Ok(err) && elem) {
		AVL *right;
		while ((right = AVL_right(tree, elem, err)) != 0L && Ok(err)) {
			elem = right;
		}
	}
	return elem;
}

AVL *AVL_next(AVLTree *tree, AVL *elem, Err *err) {
	AVL *such = AVL_right(tree, elem, err);
	if (Error(err)) {
		return 0L;
	}
	if (such) {
		AVL *left;
		while ((left = AVL_left(tree, such, err)) != 0L) {
			if (Error(err)) {
				return 0L;
			}
			such = left;
		}
		return such;
	}
	such = elem;
	while (such && such->direction == AVLDIR_RIGHT) {
		such = AVL_top(tree, such, err);
		if (Error(err)) {
			return 0L;
		}
	}
	if (such) {
		return AVL_top(tree, such, err);
	}
	return such;
}

AVL *AVL_prev(AVLTree *tree, AVL *elem, Err *err) {
	AVL *such = AVL_left(tree, elem, err);
	if (Error(err)) {
		return 0L;
	}
	if (such) {
		AVL *right;
		while ((right = AVL_right(tree, such, err)) != 0L) {
			if (Error(err)) {
				return 0L;
			}
			such = right;
		}
		return such;
	}
	such = elem;
	while (such && such->direction == AVLDIR_LEFT) {
		such = AVL_top(tree, such, err);
		if (Error(err)) {
			return 0L;
		}
	}
	if (such) {
		return AVL_top(tree, such, err);
	}
	return such;
}

void AVL_resort(AVLTree *tree, AVL_compare_func neu_compare, Err *err) {
	AVL *elem;
	AVL *next;
	AVLTree neu_tree;								/* neuer Baum */
	AVLTree_vtab neu_vtab = *tree->vtab;	/* Neue virtuelle Funktionen (zun„chst alle bernehmen)... */
	if (neu_compare) {
		neu_vtab.compare = neu_compare;		/* ...mit neuer compare-Funktion */
	}
	AVLTree_init(&neu_tree, &neu_vtab);		/* Baum anfangen */
	elem = AVL_first(tree, err);
	if (Error(err)) {
		return;
	}
	while (elem) {									/* Alle Elemente durchgehen */
		next = AVL_next(tree, elem, err);
		if (Error(err)) {
			return;
		}
		AVL_remove(tree, elem, err);			/* Aus altem Baum aush„ngen */
		if (Error(err)) {
			return;
		}
		AVL_insert(&neu_tree, elem, err);		/* In neuen Baum einh„ngen */
		if (Error(err)) {
			return;
		}
		elem = next;
	}
	{
		AVLTree_vtab *old_vtab = tree->vtab;	/* Alte Tabelle merken */
		*tree = neu_tree;				/* Neuen Baum bernehmen */
		tree->vtab = old_vtab;		/* aber alte Funktions-Tabelle */
		*old_vtab = neu_vtab;		/* aber mit neuen Funktionen */
	}
}
