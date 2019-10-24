void vspl_play(int handle,char *fname,unsigned long position);

int vspl_load_sample(int handle,char *fname,unsigned long position);
void vspl_unload_sample(int handle,int id);
void vspl_play_dma(int handle,int id);
void vspl_pause_dma(int handle,int id);
void vspl_stop_dma(int handle,int id);
int vqspl_status_dma(int handle,int id);
unsigned long vqspl_position_dma(int handle,int id);

int vspl_load_d2d(int handle,char *fname,unsigned long position);
void vspl_unload_d2d(int handle);
void vspl_play_d2d(int handle);
void vspl_pause_d2d(int handle);
void vspl_stop_d2d(int handle);
int vqspl_status_d2d(int handle);
unsigned long vqspl_position_d2d(int handle);
int vqspl_time_left_d2d(int handle);
void vspl_make_d2d(int handle);

void vsspl_monitor_on(int handle);
void vsspl_monitor_off(int handle);

int vq_driver_info(int handle,int *res0,int *drv,int *res1,int *res2, char name[27]);
