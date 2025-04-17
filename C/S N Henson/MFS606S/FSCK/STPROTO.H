#ifdef __STDC__
# define	P(s) s
#else
# define P(s) ()
#endif


/* fsck.c */
void do_fsck P((void ));
static void traverse_zones P((int (*func )(zone_nr *zone ,unsigned level )));
static int pass1 P((zone_nr *zone , unsigned level ));
static int pass1a P((zone_nr *zone , unsigned level ));
static void add_dup P((zone_nr zone ));
static void do_dup P((zone_nr zone ));
static int is_dup P((zone_nr zone ));
static int is_rem P((zone_nr zone ));
static void check_root P((void ));
static void traverse_dir P((int (*func )()));
static int add_dirent P((dir_struct *adir ));
static int addfunc P((dir_struct *dir , unsigned entry ));
static void show_name P((ilist *inl ));
static void lookup_name P((inode_stat *in ));
static int i_to_name P((dir_struct *dir , unsigned entry ));
static int mklost P((void ));
static void check_dots P((void ));
static int pass2 P((dir_struct *dir , unsigned entry ));
static int _pass2 P((dir_struct *dir , unsigned entry ));
static int pass2a P((dir_struct *dir , unsigned entry ));
static void fix_dots P((void ));
static void next_init P((void ));
static void next_inode P((void ));
static void read_inode_init P((void ));
static void read_inode P((void ));
static long alloc_inode P((void ));
static void fix_root P((void ));

#undef P
