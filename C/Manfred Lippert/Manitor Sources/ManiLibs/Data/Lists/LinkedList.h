/*----------------------------------------------------------------------------------------
	LinkedList.h, class for handling (doubly) linked lists
	
	9.12.1998 by Manfred Lippert, mani@mani.de

	last change: 24.8.2001
----------------------------------------------------------------------------------------*/

#ifndef __ManiLibs_LinkedList_H__
#define __ManiLibs_LinkedList_H__

/*××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××
	MP-safe:			yes, if a list object is manipulated by one thread per time only
						(must be protected self by CriticalRegions!)
	MP-callable:	any context
××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××*/

#include <Types2B.h>

/* for posdef: */
const int16 LINK_BEFORE	= 0;
const int16 LINK_AFTER	= 1;
const int16 LINK_START	= 2;
const int16 LINK_END		= 3;

class Listable {
friend class LinkedList;
	Listable *next;
	Listable *prev;
public:
	virtual ~Listable();
	Listable *get_next() const {return next;};
	Listable *get_prev() const {return prev;};
};

class LinkedList {
	Listable *first;
	Listable *last;
public:
	LinkedList();
	virtual ~LinkedList() = 0;
	void insert(Listable *element, Listable *pos = 0, int16 posdef = LINK_END);
	void remove(Listable *element);
	void kill(Listable *element);
	void swap(Listable **a, Listable **b);
	void correct_after_swap(Listable **to_correct, Listable *a_swapped, Listable *b_swapped);
	Listable *get_first() const {return first;};
	Listable *get_last() const {return last;};

	void empty_with_removing() {first = 0; last = 0;};
	void empty_with_killing();
};


// Easier to use with templates:

template <class T>
class Link : public Listable {
public:
//	virtual ~Link();
	T *get_next() const {return (T *)Listable::get_next();};
	T *get_prev() const {return (T *)Listable::get_prev();};
};

template <class T>
class List : public LinkedList {
public:
//	virtual ~List();
	void insert(T *element, T *pos = 0, int16 posdef = LINK_END) {
		LinkedList::insert((Listable *)element, (Listable *)pos, posdef);
	};
	void remove(T *element) {LinkedList::remove((Listable *)element);};
	void kill(T *element) {LinkedList::kill((Listable *)element);};
	void swap(T **a, T **b) {LinkedList::swap((Listable **)a, (Listable **)b;};
	void correct_after_swap(T **to_correct, T *a_swapped, T *b_swapped) {
		LinkedList::correct_after_swap((Listable **)to_correct, (Listable *)a_swapped, (Listable *)b_swapped);
	};
	T *get_first() const {return (T *)LinkedList::get_first();};
	T *get_last() const {return (T *)LinkedList::get_last();};
};

#endif
