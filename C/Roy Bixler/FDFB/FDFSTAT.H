
/* fdfstat.c */
void update_total_bytes(long f_size);
void update_total_del_bytes(long f_size);
void update_num_files(void);
void update_num_which_dupd(void);
void update_num_dups(unsigned n_dups, long bytes);
void print_stats(void);
