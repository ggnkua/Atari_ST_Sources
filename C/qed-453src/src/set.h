#ifndef _qed_set_h_
#define _qed_set_h_

extern int		setfree	(SET set);				/* kleinste freie Nummer */
extern int		setmax	(SET set);				/* gr”žte belegte Nummer */
extern int		setmin	(SET set);				/* kleinste belegte Nummer */
extern void		setcpy	(SET set1, SET set2);
extern void		setall	(SET set);
extern void		setclr	(SET set);
extern void		setnot	(SET set);
extern void		setand	(SET set1, SET set2);
extern void		setor		(SET set1, SET set2);
extern void		setxor	(SET set1, SET set2);
extern void		setincl	(SET set, int elt);
extern void		setexcl	(SET set, int elt);
extern void		setchg	(SET set, int elt);
extern bool		setin		(SET set, int elt);
extern bool		setcmp	(SET set1, SET set2);
extern int		setcard	(SET set);
extern void		str2set	(char *str, SET set);

#endif
