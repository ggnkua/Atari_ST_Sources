
typedef  int  cdecl  (*CB_FUNC) (int);

typedef  struct ism_api {
            void   cdecl  (* ext_objects)   (int i, int rsc);
            void   cdecl  (* set_trees)     (int i, long trees[], int global[], int len);
            int    cdecl  (* open_window)   (int i, int rsc, int edit);
            int    cdecl  (* close_window)  (int i, int rsc);
            void   cdecl  (* callback)      (int i, int rsc, CB_FUNC click, CB_FUNC key);
            void   cdecl  (* change_flags)  (int i, int rsc, int obj, int what, int flags, int state);
            void   cdecl  (* do_popup)      (int i, int pu, int *sel, int par, int obj, int len);
            void   cdecl  (* editing)       (int i, int rsc, int what, int edit);
            int    cdecl  (* top_window)    (int i, int rsc);
            void   cdecl  (* rsc_size)      (int i, int rsc, int width, int height, int parent);
            void   cdecl  (* free_string)   (int i, int rsc, int obj, int par, char txt[], int len);
            void   cdecl  (* tedinfo)       (int i, int rsc, int obj, int par, int w, char txt[], int len);
            void   cdecl  (* finish_user)   (int i);
            void   cdecl  (* finish_server) (int i);
    } ISM_API;

typedef  struct ism_para {
            void      *module_resident;
            int       index;
            int       char_width, char_height;
            int       protocol, connection;
            ISM_API   *server_api;
    } ISM_PARA;

typedef  long  cdecl  (* IND_FUNC) (ISM_PARA  *module_data);

typedef  struct ism_specs {
            IND_FUNC  ism_init, ism_term, ism_user, ism_server;
            ICONBLK   *ism_icon;
            int       ism_num_trees, ism_protocol, ism_tos;
            char      ism_name[17];
    } ISM_SPECS;

#define  ISM_UDP       1
#define  ISM_TCP       2

#define  ACT_USER      1
#define  ACT_SERVER    2

typedef  struct ism_internals {
            char      ism_name[17], ism_ictxt[13], ism_icon[96];
            char      file[14], resident[64];
            int       action, rsc_offset, rsc_num, protocol, tos;
            long      ism_dterm, ism_duser, ism_dserver;
            IND_FUNC  ism_init, ism_term, ism_user, ism_server;
            BASPAG    *basepage;
    } ISM_INTERN;

