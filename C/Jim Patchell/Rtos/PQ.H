//----------------------------------------------------------
//
// Priority Queue Class
//
// The elements of the Q consist of an Array of pointers
// To the various elements of the Q
// No real data actuall exists in this thing.
//
//----------------------------------------------------------

#ifndef PQ__H
#define PQ__H

class PQ {
	int (*cmp)(void **,void **);		/*	compare two objects		*/
	int nitems;							/*	number of items in heap		*/
	int maxitems;						/*	maximum number of items in heap	*/
	void **bottom;						/*	prt to most recently added item	*/
	void **heap;						/*	pointer to the heap itself		*/
	void swap(void **,void **);
	void ReheapUp(void);
	void ReheapDown(void);
public:
	PQ(int ne,int (*c)(void **,void **));
	~PQ();
	Insert(void *item);
	int Delete(void **target);
	void *Get(void) {return heap[0];}	//return pointer to highest priority item
	int NumElem(void){return nitems;}	//get total number of items
	int Replace(void **target,void *item);
	int Remove(void **target,int (*cmp)(void **,void **),void *item);
	void *Get(int i) {return heap[i];}	//return pointer to indexed item
};

#endif
