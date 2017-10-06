#ifndef DLLUTIL_H
#define DLLUTIL_H

#ifdef DLLUTIL_INTERNALS

  typedef struct dl_header {
	  struct dl_header *next;
	  struct dl_header *prev;
  } DllHeader;

  typedef struct dl_list {
	  struct dl_header *head;
	  struct dl_header *tail;
	  struct dl_header *cur;
  } DlList;

#else

  typedef struct dl_header {
	  void *next;
	  void *prev;
  } DllHeader;

  typedef struct dl_list {
	  void *head;
	  void *tail;
	  void *cur;
  } DlList;

#endif

#if __STDC__
  #ifdef DLLUTIL_INTERNALS
	extern void *dl_insert(DlList *list,  DllHeader *afteritem, DllHeader *newitem);
	extern void *dl_addhead(DlList *list, DllHeader *item);
	extern void *dl_addtail(DlList *list, DllHeader *item);
	extern void  dl_remove(DlList *list,  DllHeader *item);
	extern void  dl_freelist(DlList *list, void (*freefunc)(DlList *, void *));
	extern int	 dl_seek(DlList *list, long count, int whence);
	extern long  dl_tell(DlList *list);
  #else
	extern void *dl_insert(void *list,	void *afteritem, void *newitem);
	extern void *dl_addhead(void *list, void *item);
	extern void *dl_addtail(void *list, void *item);
	extern void  dl_remove(void *list,	void *item);
	extern void  dl_freelist(void *list, void (*freefunc)());
	extern int	 dl_seek(void *list, long count, int whence);
	extern long  dl_tell(void *list);
  #endif
#else
  extern void *dl_insert();
  extern void *dl_addhead();
  extern void *dl_addtail();
  extern void  dl_remove();
  extern void  dl_freelist();
  extern int   dl_seek();
  extern long  dl_tell();
#endif

#ifndef SEEK_SET
  #define SEEK_SET 0
  #define SEEK_CUR 1
  #define SEEK_END 2
#endif

#endif
