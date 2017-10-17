/*
 * Definition of an entry in the mount-table.
 */

struct m_table {
	struct dev	*m_cdev;
	int		m_cminor;
	struct dev	*m_pdev;
	int		m_pminor;
	int		m_pino;
	int		m_flags;
};

/* some functions don't return integers */
extern struct inode *m_volparent();
extern struct inode *m_getiptr();

extern struct m_table *m_find();
extern struct m_table *c_mfind();
extern struct m_table *m_free();

# define	NULLMPTR	(( struct m_table * ) 0)
