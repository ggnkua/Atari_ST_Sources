#ifndef __LIST_H
#define __LIST_H

typedef struct _LIST_ENTRY
{
  struct _LIST_ENTRY *Flink ;
  struct _LIST_ENTRY *Blink ;
}
LIST_ENTRY ;

/*
/  Doubly-linked list manipulation routines.  Implemented
/  as macros but logically these are procedures.
*/

/*
/  Calculate the address of the base of the structure given its type, 
/  and an address of a field within the structure.
*/
#define CONTAINING_RECORD(address, type, field) ((type *)( \
                                                  (char*)(address) - \
                                                  (long)(&((type *)0L)->field)))
/*
  void InitializeListHead(LIST_ENTRY* ListHead)
*/
#define InitializeListHead(ListHead)   (ListHead)->Flink = (ListHead)->Blink = (ListHead)

/*
  char IsListEmpty(LIST_ENTRY* ListHead)
*/
#define IsListEmpty(ListHead)   ((ListHead)->Flink == (ListHead))

/* LIST_ENTRY* GetHeadList(LIST_ENTRY* ListHead) */
#define GetHeadList(ListHead) (ListHead)->Flink

/*
  void RemoveEntryList(LIST_ENTRY* Entry)
*/
#define RemoveEntryList(Entry) {\
    LIST_ENTRY* _EX_Blink;\
    LIST_ENTRY* _EX_Flink;\
    _EX_Flink = (Entry)->Flink;\
    _EX_Blink = (Entry)->Blink;\
    _EX_Blink->Flink = _EX_Flink;\
    _EX_Flink->Blink = _EX_Blink;\
    }

/*
  LIST_ENTRY* RemoveHeadList(LIST_ENTRY* ListHead)
*/
#define RemoveHeadList(ListHead) \
    (ListHead)->Flink;\
    {RemoveEntryList((ListHead)->Flink)}

/*
  LIST_ENTRY* RemoveTailList(LIST_ENTRY* ListHead)
*/
#define RemoveTailList(ListHead) \
    (ListHead)->Blink;\
    {RemoveEntryList((ListHead)->Blink)}

/*
  void InsertTailList(LIST_ENTRY* ListHead, LIST_ENTRY* Entry)
*/
#define InsertTailList(ListHead,Entry) {\
    LIST_ENTRY* _EX_Blink;\
    LIST_ENTRY* _EX_ListHead;\
    _EX_ListHead = (ListHead);\
    _EX_Blink = _EX_ListHead->Blink;\
    (Entry)->Flink = _EX_ListHead;\
    (Entry)->Blink = _EX_Blink;\
    _EX_Blink->Flink = (Entry);\
    _EX_ListHead->Blink = (Entry);\
    }

/*
  void InsertHeadList(LIST_ENTRY* ListHead, LIST_ENTRY* Entry)
*/
#define InsertHeadList(ListHead,Entry) {\
    LIST_ENTRY* _EX_Flink;\
    LIST_ENTRY* _EX_ListHead;\
    _EX_ListHead = (ListHead);\
    _EX_Flink = _EX_ListHead->Flink;\
    (Entry)->Flink = _EX_Flink;\
    (Entry)->Blink = _EX_ListHead;\
    _EX_Flink->Blink = (Entry);\
    _EX_ListHead->Flink = (Entry);\
    }


typedef struct _SINGLE_LIST_ENTRY
{
  struct _SINGLE_LIST_ENTRY *Next ;
}
SINGLE_LIST_ENTRY ;

/*
  SINGLE_LIST_ENTRY* PopEntryList(SINGLE_LIST_ENTRY* ListHead)
*/
#define PopEntryList(ListHead) \
    (ListHead)->Next;\
    {\
        SINGLE_LIST_ENTRY* FirstEntry;\
        FirstEntry = (ListHead)->Next;\
        if (FirstEntry != NULL) {     \
            (ListHead)->Next = FirstEntry->Next;\
        }                             \
    }


/*
  void PushEntryList(SINGLE_LIST_ENTRY* ListHead, SINGLE_LIST_ENTRY* Entry)
*/
#define PushEntryList(ListHead,Entry) \
    (Entry)->Next = (ListHead)->Next; \
    (ListHead)->Next = (Entry)

#endif
