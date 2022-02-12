/* Device table.  This table is indexed by major device number.  It provides
 * the link between major device numbers and the routines that process them.
 */

typedef _PROTOTYPE (void (*dmap_t), (int task, message *m_ptr) );

extern struct dmap {
  dmap_t dmap_open;
  dmap_t dmap_rw;
  dmap_t dmap_close;
  int dmap_task;
} dmap[];

