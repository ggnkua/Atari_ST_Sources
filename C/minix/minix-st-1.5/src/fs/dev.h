/* Device table.  This table is indexed by major device number.  It provides
 * the link between major device numbers and the routines that process them.
 */

extern struct dmap {
  void (*dmap_open)();
  void (*dmap_rw)();
  void (*dmap_close)();
  int dmap_task;
} dmap[];

