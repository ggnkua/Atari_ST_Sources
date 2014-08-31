
/*
 *   Structures for interfacing to INetD ...
 */

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


/*
 *   Defines for making interfacing to INetD easy ...
 *
 *   Add two declarations to your source file :
 *
 *        int      ism_index;
 *        ISM_API  *api;
 */

#define  ISM_UDP         1
#define  ISM_TCP         2

#define  ext_objects(x)            (*api->ext_objects)   (ism_index, x)
#define  set_trees(x,y,z)          (*api->set_trees)     (ism_index, x, y, z)
#define  open_window(x,y)          (*api->open_window)   (ism_index, x, y)
#define  close_window(x)           (*api->close_window)  (ism_index, x)
#define  callback(x,y,z)           (*api->callback)      (ism_index, x, y, z)
#define  change_flags(x,y,z,a,b)   (*api->change_flags)  (ism_index, x, y, z, a, b)
#define  do_popup(x,y,z,a,b)       (*api->do_popup)      (ism_index, x, y, z, a, b)
#define  editing(x,y,z)            (*api->editing)       (ism_index, x, y, z)
#define  top_window(x)             (*api->top_window)    (ism_index, x)
#define  rsc_size(x,y,z,a)         (*api->rsc_size)      (ism_index, x, y, z, a)
#define  free_string(x,y,z,a,b)    (*api->free_string)   (ism_index, x, y, z, a, b)
#define  tedinfo(x,y,z,a,b,c)      (*api->tedinfo)       (ism_index, x, y, z, a, b, c)
#define  finish_user()             (*api->finish_user)   (ism_index)
#define  finish_server()           (*api->finish_server) (ism_index)


/*
 *   Library for handling Dialogs in Windows ...
 */

#define  BEGIN            1
#define  END              2

#define  TE_PTEXT         0
#define  TE_PTMPLT        1
#define  TE_PVALID        2

#define  CLOSER_CLICKED   0x7654
