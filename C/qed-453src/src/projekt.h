#ifndef _qed_projekt_h_
#define _qed_projekt_h_

extern int	prj_type;
extern PATH	def_prj_path;

extern int	load_projekt	(char *filename);
extern bool	add_to_projekt	(int link, char *name, bool draw);
extern int	new_projekt		(void);

extern void	find_on_disk	(void);

extern void	set_def_prj		(void);
extern void	open_def_prj	(void);
extern void	add_to_def		(void);

extern void	init_projekt	(void);

#endif
