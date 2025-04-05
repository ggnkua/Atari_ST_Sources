/*
 * from K&R "The C Programming language"
 * Table lookup routines
 * structure and definitions
 *
 */

					/* basic table entry */
struct hashlist {
	char	*name;
	char	*def;
	struct	hashlist *next;		/* next in chain     */
};
					/* basic table entry */
struct lexlist {
	char	*name;
	int	val;			/* lexical value     */
	int	flag;			/* optional flag val */
	struct	lexlist  *link;		/* next in chain     */
};


#define HASHMAX	100			/* size of hashtable */
