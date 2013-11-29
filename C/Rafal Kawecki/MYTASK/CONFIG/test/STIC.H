struct STIC
{
    int     version;
    long    magic;
    OBJECT* cdecl (*str_icon)       (char *string, int tree);
    void    cdecl (*ext_icon)       (int id, OBJECT *big, OBJECT *small, int flag);
    OBJECT* cdecl (*id_icon)        (int id, int tree);
    OBJECT* cdecl (*top_icon)       (int tree);
    OBJECT* cdecl (*menu_icon)      (int tree);
    int     cdecl (*menu_popup)     (MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata);
    int     cdecl (*menu_attach)    (int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata);
    int     cdecl (*menu_settings)  (int me_flag, MN_SET *me_values);
};
