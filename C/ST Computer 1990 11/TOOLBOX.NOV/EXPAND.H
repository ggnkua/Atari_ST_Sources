/*
 * Listing 1.11, Datei : expand.h
 * Modul               : EXPAND - Argumentexpansion
 * Modifikationsdatum  : 15-Nov-89
 * Abh„ngigkeiten      : -
 */

typedef struct {
    char  reserved[21],
          fattr;
    short ftime,
          fdate;
    long  fsize;
    char  fname[14];
} FILE_DESC;

typedef struct file_desc_item {
    FILE_DESC             fdesc;
    struct file_desc_item *next,
                          *down;
} FILE_DESC_ITEM, *FILE_DESC_LIST;

typedef struct dir_desc_item {
    char                 dirpath[100];
    FILE_DESC_LIST       flist;
    struct dir_desc_item *next;
} DIR_DESC_ITEM, *DIR_DESC_LIST;

extern FILE_DESC_LIST built_flist();
extern void           concat_flist();
extern DIR_DESC_ITEM  built_dir();
extern DIR_DESC_LIST  built_dlist(),
                      expand_dlist();
extern void           drop_flist(),
                      drop_dir(),
                      drop_dlist();
