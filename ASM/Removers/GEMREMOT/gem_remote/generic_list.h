// liste génériques en C
#ifndef __GENERIC_LIST_H
#define __GENERIC_LIST_H

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define PROTOLIST(type,name) \
typedef struct __##name##_cell \
{ \
    type obj; \
    struct __##name##_cell *next; \
} name##_cell; \
typedef name##_cell *name; \
inline name empty_##name(void); \
inline int is_empty_##name(name l); \
inline type name##_car(name l); \
inline name name##_cdr(name l); \
name name##_cons(type a,name l); \
name name##_append(name l1,name l2); \
void delete_##name(name l);

#define DEFLIST(type,name) \
inline name empty_##name(void) \
{ \
  return NULL; \
} \
inline int is_empty_##name(name l) \
{ \
  return (l==NULL); \
} \
inline type name##_car(name l) \
{ \
/*  assert(!is_empty_##name(l)); */ \
  return l->obj; \
} \
inline name name##_cdr(name l) \
{ \
/*  assert(!is_empty_##name(l)); */ \
  return l->next; \
} \
name name##_cons(type a,name l) \
{ \
  name newlist; \
  newlist=(name)malloc(sizeof(name##_cell)); \
  assert(newlist != NULL); \
  newlist->next=l; \
  newlist->obj=a; \
  return newlist; \
} \
name name##_append(name l1,name l2) \
{ \
  name tmp; \
  if(is_empty_##name(l1)) \
    return l2; \
  tmp=l1; \
  while(!is_empty_##name(name##_cdr(l1))) \
  { \
    l1=name##_cdr(l1); \
  } \
  l1->next=l2; \
  return tmp; \
} \
void delete_##name(name l) \
{ \
  name tmp; \
  while(!is_empty_##name(l)) \
  { \
    tmp=name##_cdr(l); \
    l->next=NULL; \
    free(l); \
    l=tmp; \
  } \
}

#endif // __GENERIC_LIST_H
