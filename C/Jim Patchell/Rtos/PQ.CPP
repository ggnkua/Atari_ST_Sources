//----------------------------------------------------------
//
// Priority Queue Class
//
// The elements of the Q consist of an Array of pointers
// To the various elements of the Q
// No real data actually exists in this thing.
//
// copyright (c) Jim Patchell 1995,2000
//
//----------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pq.h"

//---------------------------------------------------------
//
// PQ constructor
//
// int ne;	//maximum number of elements in the priority queue
// int (*c)(void **,void**);	//compare function.  The compare
//								//function,when called is passed
//								//a pair of pointers to pointers
//								//to the objects to be compared
// The constructor initializes all of the other parameters from
// these.
//
//---------------------------------------------------------
//
PQ::PQ(int ne,int (*c)(void **,void **))
{
	cmp = c;
	nitems = 0;
	maxitems = ne;
	heap = new void *[ne];
    bottom = &heap[-1];
}

//----------------------------------------------------------
//
// PQ destructor
//
// Just needs to delete the heap that was allocated
//
//----------------------------------------------------------
//
PQ::~PQ()
{
	delete[] heap;
}

//---------------------------------------------------------
//
// PQ::Insert
//
// This function puts a new object pointer into the heap
// if space is availiable.  It then reheaps
//
//---------------------------------------------------------
//
int PQ::Insert(void *item)
{
	int space_avail;

	if((space_avail = maxitems - nitems) > 0)
	{
		++nitems;
		*(++bottom) = item;
		ReheapUp();
	}
	return space_avail;
}

//---------------------------------------------------------
//
// PQ::Delete
//
// This function deletes the highest proiority item from
// the heap.  It stores the pointer to the object in the
// location pointed to by target.  It then reheaps
//
//---------------------------------------------------------

int PQ::Delete(void **target)
{
	int SlotsInUse;

	if((SlotsInUse = nitems) > 0)
	{
		*target = *heap;		//get item from top of heap
		*heap = *bottom--;
		--nitems;
		ReheapDown();
	}
	return SlotsInUse;
}

//-----------------------------------------------------------
//
// PQ::Replace
//
// This function removes the hightest priority item from the
// heap and puts it in the location that is pointed to by
// target.  It then replaces it with the object pointed to
// by item.  Then the function reheaps.
//
//-----------------------------------------------------------

int PQ::Replace(void **target,void *item)
{
	int SlotsInUse;

	if((SlotsInUse = nitems) > 0)
	{
		if ((*cmp)(&item,heap) > 0)	//only replace if priority is less
		{
			*target = item;		//item is higher priority
		}
		else
		{
			*target = *heap;
			*heap = item;
			ReheapDown();
		}
	}
	else
		*target = item;
	return SlotsInUse;
}

//------------------------------------------------------------
//
// PQ:Remove
//
// This function removes the object pointed to by item from the
// heap and puts it into the location pointed to by target.
// Then the function reheaps
//
//------------------------------------------------------------
//
int PQ::Remove(void **target,int (*cmp)(void **,void **),void *item)
{
	int SlotsInUse;

	if((SlotsInUse = nitems)>0)
	{
		int i;
		int loop;

		for(i=0,loop=1;i<nitems && loop;++i)
		{
			if( (*cmp)(&item,&heap[i]) == 0)
			{
				*target = heap[i];
				memcpy(&heap[i],&heap[i+1],(nitems - i - 1) * sizeof(void *));
				bottom--;
				nitems--;
				ReheapDown();
				loop = 0;
			}
		}
	}
	return SlotsInUse;
}

/************************************************************************
**
** These functions are private to the class and are not accessable
**
************************************************************************/

void PQ::swap(void **s1,void **s2)
{
	void *temp;

	temp = *s1;
	*s1 = *s2;
	*s2 = temp;
}

void PQ::ReheapUp(void)
{
	int parent;		//index of parent
	int child;		//index of child
	void **pparent;	//pointer to parent
	void **pchild;	//pointer to child

	child = nitems - 1;
	while((parent = (child - 1)/2) >= 0)
	{
		pchild = &heap[child];
		pparent = &heap[parent];
		if( (*cmp)(pparent,pchild) >= 0)
			break;
		swap(pparent,pchild);
		child = parent;
	}	//end of while statement
}

void PQ::ReheapDown(void)
{
	int parent;	//index of parent
	int child;	//index of child
	void **pparent;	//pointer to parent
	void **pchild;   //pointer to child
	void **psibling;	//pointer to sibling
	void **pheap;	//pointer to heap

	pheap = heap;
	for(parent=0,child=1;child < nitems;)
	{
		pparent = &pheap[parent];
		pchild = &pheap[child];
		if(child + 1 < nitems)
		{
			psibling = pchild + 1;
			if((*cmp)(pchild,psibling) < 0)
			{
				pchild = psibling;
				child++;
			}
		}	//end of if(child + 1 < nitems)
		if((*cmp)(pparent,pchild) >= 0)
			break;
		swap(pparent,pchild);
		parent = child;
		child = parent * 2 + 1;
	}	//end of for loop
}

