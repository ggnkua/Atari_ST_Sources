/* Device table.  This table is indexed by major device number.  It provides
 * the link between major device numbers and the routines that process them.
 */

extern struct dmap {
  int _PROTOTYPE ((*dmap_opcl), (int, Dev_t, int, int) );
  void _PROTOTYPE ((*dmap_io), (int, message *) );
  int dmap_task;
} dmap[];
