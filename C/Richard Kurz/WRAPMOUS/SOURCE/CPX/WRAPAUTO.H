#define TRUE 1
#define FALSE 0

#define MAX_PROG 20

typedef struct
{
    int fix;
    long (*set_vec)(void);
    struct
    {
        char name[15];
        int c_flag;
        int t_flag;
        int d_flag;
    }pf[MAX_PROG];
    struct
    {
        int tiefe;
        int nr;
        int nap[MAX_PROG];
    }sa;
    struct
    {
        int s_flag;
        int w_flag;
        int mw[6];
        int mf[6];
        int rand[4];
    }d[3];
    int j_flag;
    int r_flag;
    int rp_flag;
    int rsm_flag;
    int ms_flag;
}INF;

typedef struct
{
    unsigned char head;
    char dx,dy;
} RELMOUSE;
  
int get_cookie(unsigned long cookie,unsigned long *value);
int make_cookie(unsigned long cookie,unsigned long value);

void do_speed(RELMOUSE *m,int dev);
void do_wrap(RELMOUSE *m,int dev);
void do_changes(RELMOUSE *m);

void set_mouse(RELMOUSE *nm);
