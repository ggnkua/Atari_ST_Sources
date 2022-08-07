extern int (*c_dest)();

extern int (*m_dest)();
extern int (*v_dest)();

extern int (*s_function)();

#define return_to_menu {c_dest = m_dest; return;}

extern struct s_sequence *cur_sequence;
extern WORD cur_sequ_ix;

extern WORD s_mode; /* type of object can select*/

extern WORD redraw_flag;
/*for menus to redraw upon entry*/

struct control 
    {
    struct menu *m;
    struct selection *sel;
    struct virtual_input *vis;
    struct s_sequence *seq;
    };


