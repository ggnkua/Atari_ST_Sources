#ifndef FIRELIST
  #define FIRELIST
  #define SORT_ORDER_UP   1
  #define SORT_ORDER_DOWN 2
  #include <osbind.h>
  #include <stdio.h>
  #include <stdlib.h>
  typedef struct _list
  {
    char    *data;
    long    size;
    long    sizeentity;
    long    used;
    struct  _list *next;
  } MLIST;

  void sort_list( MLIST *start,int (*compare)(const void *, const void *,const int),int sort_order,int sort_type);
  void free_list( MLIST **start );
  void *get_entity( MLIST *start, long number);
  void *new_entity( MLIST **start , size_t size, long num_alloc );
  void del_entity( MLIST **start , long number );
  void del_entity( MLIST **start , long number );
#endif

