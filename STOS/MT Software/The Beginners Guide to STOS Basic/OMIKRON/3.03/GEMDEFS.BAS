0 '
1 'Gemdefs definiert saemtliche Variablen, die unter C standardmaessig
2 'fuer die Arbeit mit GEM vordefiniert sind.
3 '
4 '
5 DEF PROC Gemdefs
6 'MULTI EVENT FLAGS
7 K_Rshift%L=$1:K_Lshift%L=$2:K_Ctrl%L=$4:K_Alt%L=$8
8 Scr_Mgr%L=$1:Ap_Msg%L=0
9 Mu_Keybd%L=$1:Mu_Button%L=$2:Mu_M1%L=$4:Mu_M2%L=$8:Mu_Mesag%L=$10:Mu_Timer%L=$20
10 Mn_Selected%L=10:Wm_Redraw%L=20:Wm_Topped%L=21:Wm_Closed%L=22:Wm_Fulled%L=23:Wm_Arrowed%L=24:Wm_Hslid%L=25
11 Wm_Vslid%L=26:Wm_Sized%L=27:Wm_Moved%L=28:Wm_Newtop%L=29:Ac_Open%L=40:Ac_Close%L=41
12 Ct_Update%L=50:Ct_Move%L=51:Ct_Newtop%L=52
13 'FORM FLAGS
14 Fmd_Start%L=0:Fmd_Grow%L=1:Fmd_Shrink%L=2:Fmd_Finish%L=3
15 'WINDOW FLAGS
16 Wname%L=$1:Closer%L=$2:Fuller%L=$4:Mover%L=$8:Info%L=$10:Sizer%L=$20:Uparrow%L=$40:Dnarrow%L=$80
17 Vslide%L=$100:Lfarrow%L=$200:Rtarrow%L=$400:Hslide%L=$800
18 Wc_Border%L=0:Wc_Work%L=1
19 Wf_Kind%L=1:Wf_Name%L=2:Wf_Info%L=3:Wf_Workxywh%L=4:Wf_Currxywh%L=5:Wf_Prevxywh%L=6:Wf_Fullxywh%L=7:Wf_Hslide%L=8
20 Wf_Vslide%L=9:Wf_Top%L=10:Wf_Firstxywh%L=11:Wf_Nextxywh%L=12:Wf_Resvd%L=13:Wf_Newdesk%L=14:Wf_Hslsize%L=15
21 Wf_Vslsize%L=16:Wf_Screen%L=17
22 Wa_Uppage%L=0:Wa_Dnpage%L=1:Wa_Upline%L=2:Wa_Dnline%L=3:Wa_Lfpage%L=4:Wa_Rtpage%L=5:Wa_Lfline%L=6:Wa_Rtline%L=7
23 'UPDATE FLAGS
24 End_Update%L=0:Beg_Update%L=1:End_Mctrl%L=2:Beg_Mctrl%L=3
25 'MOUSE FORMS
26 Arrow%L=0:Text_Crsr%L=1:Hourglass%L=2:Point_Hand%L=3:Flat_Hand%L=4:Thin_Cross%L=5:Thick_Cross%L=6:Outln_Cross%L=7
27 User_Def%L=255:M_Off%L=256:M_On%L=257
28 'RESOURCE DATA TYPES
29 R_Tree%L=0:R_Object%L=1:R_Tedinfo%L=2:R_Iconblk%L=3:R_Bitblk%L=4:R_String%L=5:R_Imagedata%L=6:R_Obspec%L=7
30 R_Teptext%L=8:R_Teptmplt%L=9:R_Tepvalid%L=10:R_Ibpmask%L=11:R_Ibpdata%L=12:R_Ibptext%L=13:R_Bipdata%L=14
31 R_Frstr%L=15:R_Frimg%L=16
32 'OBJEKT FLAGS
33 Root%L=0
34 Max_Len%L=81
35 Max_Depth%L=8
36 Ip_Hollow%L=0:Ip_1patt%L=1:Ip_2patt%L=2:Ip_3patt%L=3:Ip_4patt%L=4:Ip_5patt%L=5:Ip_6patt%L=6:Ip_Solid%L=7
37 Md_Replace%L=1:Md_Trans%L=2:Md_Xor%L=3:Md_Erase%L=4
38 All_White%L=0:S_And_D%L=1:S_And_Notd%L=2:S_Only%L=3:Nots_And_D%L=4:D_Only%L=5:S_Xor_D%L=6:S_Or_D%L=7:Not_Sord%L=8
39 Not_Sxord%L=9:D_Invert%L=10:Not_D%L=11:S_Or_Notd%L=12:Nots_Or_D%L=13:Not_Sandd%L=14:All_Black%L=15
40 Ibm%L=3:Small%L=5
41 G_Box%L=20:G_Text%L=21:G_Boxtext%L=22:G_Image%L=23:G_Progdef%L=24:G_Ibox%L=25:G_Button%L=26:G_Boxchar%L=27
42 G_String%L=28:G_Ftext%L=29:G_Fboxtext%L=30:G_Icon%L=31:G_Title%L=32
43 None%L=$0:Selectable%L=$1:Default%L=$2:Exitb%L=$4:Editable%L=$8:Rbutton%L=$10:Lastob%L=$20:Touchexit%L=$40
44 Hidetree%L=$80:Indirect%L=$100
45 Normal%L=$0:Selected%L=$1:Crossed%L=$2:Checked%L=$4:Disabled%L=$8:Outlined%L=$10:Shadowed%L=$20
46 White%L=0:Black%L=1:Red%L=2:Green%L=3:Blue%L=4:Cyan%L=5:Yellow%L=6:Magenta%L=7:Lwhite%L=8:Lblack%L=9:Lred%L=10:Lgreen%L=11
47 Lblue%L=12:Lcyan%L=13:Lyellow%L=14:Lmagenta%L=15
48 Edstart%L=0:Edinit%L=1:Edchar%L=2:Edend%L=3
49 Te_Left%L=0:Te_Right%L=1:Te_Cntr%L=2
50 RETURN
