/*----------------------------------------------------------------------------------------
	LinkedList.cp, class for handling (doubly) linked lists
	
	9.12.1998 by Manfred Lippert, mani@mani.de

	last change: 23.3.2001
----------------------------------------------------------------------------------------*/

#include <LinkedList.h>

Listable::~Listable() {
}

LinkedList::LinkedList() {
	first = 0;
	last = 0;
}

LinkedList::~LinkedList() {
}

void LinkedList::empty_with_killing() {
	while(last) {
		kill(last);
	}
}

void LinkedList::insert(Listable *element, Listable *pos, int16 posdef) {
	if (!first) {
		element->next = 0;
		element->prev = 0;
		first = element;
		last = element;
	} else {
		switch(posdef) {
		case LINK_START:
			pos = first;
			// NOBREAK
		case LINK_BEFORE:
			if (!pos) {
				pos = first;
			}
			element->next = pos;
			element->prev = pos->prev;
			if (element->prev) {
				element->prev->next = element;
			}
			pos->prev = element;
			break;
		case LINK_END:
			pos = last;
			// NOBREAK
		case LINK_AFTER:
			if (!pos) {
				pos = last;
			}
			element->prev = pos;
			element->next = pos->next;
			if (element->next) {
				element->next->prev = element;
			}
			pos->next = element;
		}
		if (!element->prev) {
			first = element;
		}
		if (!element->next) {
			last = element;
		}
	}
}

void LinkedList::remove(Listable *element) {
	if (element->next) {
		element->next->prev = element->prev;
	} else {
		last = element->prev;
	}
	if (element->prev) {
		element->prev->next = element->next;
	} else {
		first = element->next;
	}
}

void LinkedList::kill(Listable *element) {
	remove(element);
	delete element;
}

void LinkedList::swap(Listable **a, Listable **b) {
	register Listable *aa = *a;
	register Listable *bb = *b;
	register Listable *merk = aa->prev;
	aa->prev = bb->prev;
	bb->prev = merk;
	merk = aa->next;
	aa->next = bb->next;
	bb->next = merk;
	
	if (aa->prev == aa) {
		aa->prev = bb;
	} else if (aa->prev) {
		aa->prev->next = aa;
	} else {
		first = aa;
	}

	if (bb->prev == bb) {
		bb->prev = aa;
	} else if (bb->prev) {
		bb->prev->next = bb;
	} else {
		first = bb;
	}

	if (aa->next == aa) {
		aa->next = bb;
	} else if (aa->next) {
		aa->next->prev = aa;
	} else {
		last = aa;
	}

	if (bb->next == bb) {
		bb->next = aa;
	} else if (bb->next) {
		bb->next->prev = bb;
	} else {
		last = bb;
	}

	*a = bb;
	*b = aa;
}

void LinkedList::correct_after_swap(Listable **to_correct, Listable *a_swapped, Listable *b_swapped) {
	if (*to_correct == a_swapped) {
		*to_correct = b_swapped;
	} else if (*to_correct == b_swapped) {
		*to_correct = a_swapped;
	}
}
