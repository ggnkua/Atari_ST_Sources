/* Function prototypes. */

/* cache.c */
zone_nr alloc_zone();
void flushall();
void free_zone();
struct buf *get_block();
void invalidate();
void put_block();
void rw_block();
void rw_scattered();

/* device.c */
void dev_close();
int dev_io();
int do_ioctl();
int dev_open();
void no_call();
void rw_dev();
void rw_dev2();
int tty_exit();
void tty_open();

/* filedes.c */
struct filp *find_filp();
int get_fd();
struct filp *get_filp();

/* inode.c */
struct inode *alloc_inode();
void dup_inode();
void free_inode();
struct inode *get_inode();
void put_inode();
void update_times();
void rw_inode();
void wipe_inode();

/* link.c */
int do_link();
int do_unlink();
int do_rename();
void truncate();

/* main.c */
void main();
void reply();

/* misc.c */
int do_dup();
int do_exit();
int do_fcntl();
int do_fork();
int do_revive();
int do_set();
int do_sync();

/* mount.c */
int do_mount();
int do_umount();

/* open.c */
int do_close();
int do_creat();
int do_lseek();
int do_mknod();
int do_mkdir();
int do_open();

/* path.c */
struct inode *advance();
int search_dir();
struct inode *eat_path();
struct inode *last_dir();

/* pipe.c */
int do_pipe();
int do_unpause();
int pipe_check();
void release();
void revive();
void suspend();

/* protect.c */
int do_access();
int do_chmod();
int do_chown();
int do_umask();
int forbidden();
int read_only();

/* putc.c */
void putc();

/* read.c */
int do_read();
struct buf *rahead();
void read_ahead();
block_nr read_map();
int read_write();
int rw_user();

/* stadir.c */
int do_chdir();
int do_chroot();
int do_fstat();
int do_stat();

/* super.c */
bit_nr alloc_bit();
void free_bit();
struct super_block *get_super();
int load_bit_maps();
int mounted();
void rw_super();
int scale_factor();
int unload_bit_maps();

/* time.c */
int do_stime();
int do_time();
int do_tims();
int do_utime();

/* utility.c */
time_t clock_time();
int cmp_string();
void copy();
int fetch_name();
int no_sys();
void panic();

/* write.c */
void clear_zone();
int do_write();
struct buf *new_block();
void zero_block();

/* library */
void printk();
int receive();
int send();
int sendrec();
void sys_abort();
void sys_copy();
void sys_kill();
void sys_times();
