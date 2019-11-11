int win;                        /* window handle */
 
int menu_title, menu_item;      /* menu selected */
int mn_line, mn_point, mn_erase, mn_quit, mn_about, mn_style, mn_text, mn_circle, mn_rect;
                                /*  menu item numbers */
       
int x, y, old_x, old_y;   /* mouse co-ordinates */
 
int event_type;                /* event type (keyboard,mouse..) */
 
int ch;                        /* character typed */
char text[2];                  /* char to write on the screen */
 
int draw_type; /*indicate if clear,draw point,draw line etc */
 
int info;                       /* the info dialog box number */
 
 
/* Text Style dialog box variables */
int style;                       /* box number */
int style_1style, style_2style, style_3style, style_4style, style_5style;
int style_writing;
int style_1angle, style_2angle, style_3angle, style_4angle;
int angle_writing;

void create_dial();
void draw_it();
void create_menu();
void dial_style();


#define max(a,b) ((a)>(b)?(a):(b))
#define abs(a) ((a)>0?(a):-(a))
 
/*----------------------*/
/*      main            */
/*----------------------*/
void ic_main()
{
        win = open_window(0x1, 0, 0, 0, 0, " Draw....", "");
        create_menu();
        create_dial();
        do 
        {
                event_type = event(&menu_title, &menu_item, 0, &ch, &x, &y);
                if (event_type == 1)        /* key pressed */
                {
                        ch %= 256;
                        if (ch < 32)
                        {
                                menu_title = 0;
                                event_type = 3;
                                switch (ch)
                                {
                                case 3: /*Ctrl C = circle */
                                        menu_item = mn_circle;
                                        break ;
                                case 5: /* Ctrl E = erase */
                                        menu_item = mn_erase;
                                        break ;
                                case 12:/* Ctrl L = line */
                                        menu_item = mn_line;
                                        break ;
                                case 16:/* Ctrl P = point */
                                        menu_item = mn_point;
                                        break ;
                                case 17: /* Ctrl Q = quit */
                                        menu_item = mn_quit;
                                        break ;
                                case 18:/* Ctrl R = rectangle */
                                        menu_item = mn_rect;
                                        break ;
                                case 19:/* Ctrl S = text style */
                                        menu_item = mn_style;
                                         break ;
                                case 20:/* Ctrl T = position text */
                                        menu_item = mn_text;
                                        break ;
                                }
                        }
                        else 
                        {
                                vst_rotation(1, angle_writing);
                                vst_effects(1, style_writing);
                                text[0] = ch;
                                text[1] = 0;
                                v_gtext(1, x, y, text);
                                vst_rotation(1, 0);
                                vst_effects(1, 0);
                        }
                }
                if (event_type == 2)        /* mouse button*/
                        draw_it();
                if (event_type == 3)        /* menu item selected */
                {
                        if (menu_item == mn_point || menu_item == mn_line || menu_item == mn_text
                        || menu_item == mn_rect || menu_item == mn_circle)
                        {
                                check_menu(draw_type);
                                draw_type = menu_item;
                                check_menu(menu_item);
                                if (menu_item == mn_text)
                                        graf_mouse(3, 0);
                                else 
                                        graf_mouse(0, 0);
                        }
                        if (menu_item == mn_erase)
                                clear_window(win);
                        if (menu_item == mn_about)
                                draw_box(info);
                        if (menu_item == mn_style)
                                dial_style();
                        if (menu_title)
                                select_menu(menu_title);
                }
        }
        while (menu_item != mn_quit);
        delete_menu();
        close_window(win);
        graf_mouse(0, 0);
}
/*----------------------*/
/*    create_menu()     */
/*----------------------*/
void create_menu()
{
        mn_about = init_menu(" Desk ", " About draw ", 2, 8);
        title_menu(" Options ");
                mn_quit = item_menu("  HiSoft C      ^Q");
                mn_erase = item_menu("  Erase drawing ^E");
                mn_style = item_menu("  Text Style    ^S");
        title_menu(" Draw ");
                mn_point = item_menu("  Draw a point      ^P");
                mn_line = item_menu("  Draw a line       ^L");
                mn_text = item_menu("  Text position     ^T");
                mn_rect = item_menu("  Draw a rectangle  ^R");
                mn_circle = item_menu("  Draw a circle     ^C");
        check_menu(mn_line);
        draw_type = mn_line;
        draw_menu();
}
/*----------------------*/
/*      draw_it         */
/*----------------------*/
void draw_it()
{
int xc, yc;
short pxy[4];
        if (draw_type == mn_line)
        {
                graf_mouse(7, 0);
                mouse(&xc, &yc, 1);
                graf_mouse(0, 0);
                draw(xc, yc, x, y);
        }
        if (draw_type == mn_point)
        {
                draw(x, y, x, y);
                old_x = x;
                old_y = y;
        }
        if (draw_type == mn_circle)
        {
                graf_mouse(7, 0);
                mouse(&xc, &yc, 1);
                graf_mouse(0, 0);
                v_circle(1, x, y, max(abs(x-xc), abs(y-yc)));
        }
        if (draw_type == mn_rect)
        {
                graf_mouse(7, 0);
                mouse(&xc, &yc, 1);
                graf_mouse(0, 0);
                vsf_interior(1, 2);
                vsf_style(1, 16);
                pxy[0] = x;
                pxy[1] = y;
                pxy[2] = xc;
                pxy[3] = yc;
                v_rfbox(1, pxy);
                vsf_interior(1, 1);
        }
}
/*----------------------*/
/*      dial_style       */
/*----------------------*/
void dial_style()
{
        draw_box(style);
        if (readbut_box(style, style_1angle))
                angle_writing = 0;
        if (readbut_box(style, style_2angle))
                angle_writing = 900;
        if (readbut_box(style, style_3angle))
                angle_writing = 1800;
        if (readbut_box(style, style_4angle))
                angle_writing = 2700;
        style_writing = 0;
        if (readbut_box(style, style_1style))
                style_writing = 1;
        if (readbut_box(style, style_2style))
                style_writing += 2;
        if (readbut_box(style, style_3style))
                style_writing += 4;
        if (readbut_box(style, style_4style))
                style_writing += 8;
        if (readbut_box(style, style_5style))
                style_writing += 16;
}
/*----------------------*/
/*      create_dial     */
/*----------------------*/
void create_dial()
{
        /* create the info dialog box */
        info = init_box(30, 8, 4);
        button_box(info, 12, 6, "  OK  ", 7);
        text_box(info, 8, 1, "Paleochrome...");
        text_box(info, 2, 3, "HiSoft C toolbox");
        text_box(info, 2, 4, "Demstration.");
       
        /* create the Text Style dialog box */
        style = init_box(43, 12, 13);
        button_box(style, 18, 10, " OK ", 7);
        text_box(style, 6, 2, "Angle to display text");
        style_1angle = button_box(style, 6, 4, "   0 ", 17);
        style_2angle = button_box(style, 13, 4, "  90 ", 17);
        style_3angle = button_box(style, 20, 4, " 180 ", 17);
        style_4angle = button_box(style, 27, 4, " 270 ", 17);
       
        text_box(style, 12, 6, "Text style");
        style_1style = button_box(style, 2, 8, "bold", 1);
        style_2style = button_box(style, 8, 8, "grey", 1);
        style_3style = button_box(style, 14, 8, "italic", 1);
        style_4style = button_box(style, 22, 8, "underlined", 1);
        style_5style = button_box(style, 33, 8, "outlined", 1);
}
