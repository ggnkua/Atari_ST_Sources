#ifndef __LIST_H
#define __LIST_H

typedef struct _LIST_ENTRY
{
   struct _LIST_ENTRY *Flink ;
   struct _LIST_ENTRY *Blink ;
}
LIST_ENTRY ;

/*
    Calculate the address of the base of the structure given its type, and an
    address of a field within the structure.
*/

#define CONTAINING_RECORD(address, type, field) ((type *)( \
			  (char*)(address) - \
			  (char*)(&((type *)0L)->field)))

/*
    Doubly-linked list manipulation routines.  Implemented as macros
    but logically these are procedures.
*/

/* void  InitializeListHead(LIST_ENTRY* ListHead) */
#define InitializeListHead(ListHead) (\
    (ListHead)->Flink = (ListHead)->Blink = (ListHead) )

/* char IsListEmpty(LIST_ENTRY* ListHead) */
#define IsListEmpty(ListHead) (\
    ( ((ListHead)->Flink == (ListHead)) ? 1 : 0 ) )

/* LIST_ENTRY* GetHeadList(LIST_ENTRY* ListHead) */
#define GetHeadList(ListHead) (ListHead)->Flink;

/* LIST_ENTRY* RemoveHeadList(LIST_ENTRY* ListHead) */
#define RemoveHeadList(ListHead) \
    (ListHead)->Flink;\
    {\
    LIST_ENTRY* FirstEntry;\
    FirstEntry = (ListHead)->Flink;\
    FirstEntry->Flink->Blink = (ListHead);\
    (ListHead)->Flink = FirstEntry->Flink;\
    }

/* void RemoveEntryList(LIST_ENTRY* Entry) */
#define RemoveEntryList(Entry) {\
    LIST_ENTRY* _EX_Entry;\
    _EX_Entry = (Entry);\
    _EX_Entry->Blink->Flink = _EX_Entry->Flink;\
    _EX_Entry->Flink->Blink = _EX_Entry->Blink;\
    }

/* void InsertTailList(LIST_ENTRY* ListHead, LIST_ENTRY* Entry) */
#define InsertTailList(ListHead,Entry) \
    (Entry)->Flink = (ListHead);\
    (Entry)->Blink = (ListHead)->Blink;\
    (ListHead)->Blink->Flink = (Entry);\
    (ListHead)->Blink = (Entry)

/* void InsertHeadList(LIST_ENTRY* ListHead, LIST_ENTRY* Entry) */
#define InsertHeadList(ListHead,Entry) \
    (Entry)->Flink = (ListHead)->Flink;\
    (Entry)->Blink = (ListHead);\
    (ListHead)->Flink->Blink = (Entry);\
    (ListHead)->Flink = (Entry)


/* Single List */
typedef struct _SINGLE_LIST_ENTRY
{
  struct _SINGLE_LIST_ENTRY *Next ;
}
SINGLE_LIST_ENTRY ;


/* SINGLE_LIST_ENTRY* PopEntryList(SINGLE_LIST_ENTRY *ListHead) */
#define PopEntryList(ListHead) \
    (ListHead)->Next;\
    {\
    SINGLE_LIST_ENTRY* FirstEntry;\
    FirstEntry = (ListHead)->Next;\
    (ListHead)->Next = FirstEntry;\
    }


/* void PushEntryList(SINGLE_LIST_ENTRY* ListHead, SINGLE_LIST_ENTRY* Entry) */
#define PushEntryList(ListHead,Entry) \
    (Entry)->Next = (ListHead)->Next; \
    (ListHead)->Next = (Entry)


#endif