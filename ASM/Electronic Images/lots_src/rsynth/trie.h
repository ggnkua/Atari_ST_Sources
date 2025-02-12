/* $Id: trie.h,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
typedef struct trie_s *trie_ptr;

extern void trie_insert PROTO((trie_ptr *r,char *s,void *value));
extern void *trie_lookup PROTO((trie_ptr *r,char **sp));
