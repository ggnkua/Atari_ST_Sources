#ifdef __STDC__
# define	P(s) s
#else
# define P(s) ()
#endif


/* bitmap.c */
long count_bits P((ushort *buf , long num ));
int bitcount P((unsigned int wrd ));
long alloc_zone P((int drive ));
unshort alloc_inode P((int drive ));
int free_zone P((long zone , int drive ));
int free_inode P((unsigned inum , int drive ));
long alloc_bit P((ushort *buf , long num , long last ));
long free_bit P((ushort *buf , long bitnum ));

/* cache.c */
int init_cache P((void ));
void l_sync P((void ));
cache *in_cache P((long numr , int drive , cache_control *control , cache **guess ));
bufr *cget_block P((long numr , int drive , cache_control *control ));
cache *cache_put P((long numr , int drive , cache_control *control ));
cache *cache_get P((long numr , int drive , cache_control *control , cache **guess ));
int cput_block P((long numr , int drive , void *buf , cache_control *control ));
long writeout P((cache_control *control , cache *p ));
long readin P((long *zone_list , int num , int drive , cache_control *control ));
void m_invalidate P((int drv ));

/* check.c */
void chk_zone P((long start , int count , int drive ));
void chk_iblock P((long start , super_info *psblk ));

/* dir.c */
long search_dir P((const char *name , unsigned inum , int drive , int flag ));
int badname P((char *name ));
long is_parent P((unsigned dir1 , unsigned dir2 , int drive ));

/* dummyfs.c */
long no_lookup P((fcookie *dir , char *name , fcookie *entry ));
long no_creat P((fcookie *dir , char *name , unsigned mode , int attr , fcookie *entry ));
DEVDRV *no_getdev P((fcookie *file , long *special ));
long no_getxattr P((fcookie *file , XATTR *xattr ));
long no_chown P((fcookie *file , int uid , int gid ));
long no_chmode P((fcookie *file , unsigned mode ));
long no_mkdir P((fcookie *dir , char *name , unsigned mode ));
long no_rmdir P((fcookie *dir , char *name ));
long no_remove P((fcookie *dir , char *name ));
long no_getname P((fcookie *root , fcookie *dir , char *pathname , int length ));
long no_opendir P((DIR *dirh , int flag ));
long no_readdir P((DIR *dirh , char *name , int namelen , fcookie *fc ));
long no_rewinddir P((DIR *dirh ));
long no_closedir P((DIR *dirh ));
long no_rlabel P((fcookie *dir , char *name , int namelen ));
long no_wlabel P((fcookie *dir , char *name ));
long no_dfree P((fcookie *dir , long *buffer ));
long dummy_fscntl P((fcookie *dir , char *name , int cmd , long arg ));
long no_rename P((fcookie *olddir , char *oldname , fcookie *newdir , char *newname ));
long no_hardlink P((fcookie *fromdir , char *fromname , fcookie *todir , char *toname ));
long no_symlink P((fcookie *dir , char *name , char *to ));
long no_readlink P((fcookie *file , char *buf , int len ));
long no_chattr P((fcookie *file , int attr ));
long no_pathconf P((fcookie *dir , int which ));

/* inode.c */
int read_inode P((unsigned num , d_inode *rip , int drv ));
int write_inode P((unsigned num , d_inode *rip , int drv ));
d_inode1 *get_inode1 P((unsigned inum , int drive , int **flag , cache **guess ));
d_inode *get_inode2 P((unsigned inum , int drive , int **flag , cache **guess ));
void trunc_inode P((d_inode *rip , int drive , long count , int zap ));
long itruncate P((unsigned inum , int drive , long length ));

/* io.c */
void crwabs P((int rw , void *buf , unsigned num , long recno , int dev ));

/* main.c */
FILESYS *minix_init P((struct kerinfo *k ));
int update P((long bp ));
void do_sync P((long signum ));
int minix_sanity P((int drv ));

/* minixdev.c */
long m_open P((FILEPTR *f ));
long m_close P((FILEPTR *f , int pid ));
long m_read P((FILEPTR *f , char *buf , long len ));
long m_read1 P((FILEPTR *f , char *buf , long len ));
long m_read2 P((FILEPTR *f , char *buf , long len ));
long m_seek P((FILEPTR *f , long offset , int flag ));
long m_write P((FILEPTR *f , char *buf , long len ));
long m_ioctl P((FILEPTR *f , int mode , void *buf ));
long m_datime P((FILEPTR *f , int *timeptr , int flag ));
long m_select P((FILEPTR *f , long proc , int mode ));
void m_unselect P((FILEPTR *f , long proc , int mode ));

/* minixfs.c */
long m_dskchng P((int d ));
long m_root P((int dev , fcookie *dir ));
long m_lookup P((fcookie *dir , char *name , fcookie *entry ));
long m_creat P((fcookie *dir , char *name , unsigned mode , int attr , fcookie *entry ));
DEVDRV *m_getdev P((fcookie *file , long *special ));
long m_getxattr P((fcookie *file , XATTR *xattr ));
long m_chown P((fcookie *file , int uid , int gid ));
long m_chmode P((fcookie *file , unsigned mode ));
long m_mkdir P((fcookie *dir , char *name , unsigned mode ));
long m_rmdir P((fcookie *dir , char *name ));
long m_remove P((fcookie *dir , char *name ));
long m_getname P((fcookie *root , fcookie *dir , char *pathname , int length ));
long m_opendir P((DIR *dirh , int flag ));
long m_readdir P((DIR *dirh , char *name , int namelen , fcookie *fc ));
long m_rewinddir P((DIR *dirh ));
long m_closedir P((DIR *dirh ));
void set_atime P((fcookie *fc ));
long m_rlabel P((fcookie *dir , char *name , int namelen ));
long m_wlabel P((fcookie *dir , char *name ));
long m_dfree P((fcookie *dir , long *buffer ));
long m_fscntl P((fcookie *dir , char *name , int cmd , long arg ));
long m_rename P((fcookie *olddir , char *oldname , fcookie *newdir , char *newname ));
long m_hardlink P((fcookie *fromdir , char *fromname , fcookie *todir , char *toname ));
long m_symlink P((fcookie *dir , char *name , char *to ));
long m_readlink P((fcookie *file , char *buf , int len ));
long m_chattr P((fcookie *file , int attr ));
long m_pathconf P((fcookie *dir , int which ));
long m_release P((fcookie *fc ));
long m_dupcookie P((fcookie *dest , fcookie *src ));

/* misc.c */
int inode_busy P((unsigned inum , int drive , int flag ));
void btos_cpy P((char *to , const char *from ));
int stob_ncpy P((char *to , const char *from , long n ));

/* trans.c */
int do_trans P((long flag , int drive ));
char *tosify P((const char *name , int flag , int mnamlength ));

/* zone.c */
int read_zone P((long num , void *buf , int drive , cache_control *control ));
bufr *get_zone P((long num , int drive ));
cache *cget_zone P((long num , int drive , cache_control *control , cache **guess ));
cache *cput_zone P((long num , int drive , cache_control *control ));
int write_zone P((long num , void *buf , int drive , cache_control *control ));
int write_zones P((long num , void *buf , int drive , cache_control *control ));
int read_zones P((long num , void *buf , int drive , cache_control *control ));
long find_zone P((d_inode *rip , long numr , int drive , int flag ));
long find_zone11 P((d_inode1 *rip , long numr , int drive , int flag , f_cache *fch ));
long find_zone1 P((d_inode *rip , long numr , int drive , int flag ));
long find_zone2 P((d_inode *rip , long numr , int drive , int flag , f_cache *fch ));
int next_zone P((d_inode *rip , long numr , void *buf , int drive ));
int cnext_zone P((d_inode *rip , long numr , bufr **buf , int drive ));
long l_write P((unsigned inum , long pos , long len , const void *buf , int drive ));
long l_write1 P((unsigned inum , long pos , long len , const void *buf , int drive ));
long l_write2 P((unsigned inum , long pos , long len , const void *buf , int drive ));

#undef P
