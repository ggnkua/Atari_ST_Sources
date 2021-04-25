63000 DEF PROC Gemdefs
63015 'MULTI EVENT FLAGS
63020 K_Rshift=$1:K_Lshift=$2:K_Ctrl=$4:K_Alt=$8
63025 Scr_Mgr=$1:Ap_Msg=0
63030 Mu_Keybd=$1:Mu_Button=$2:Mu_M1=$4:Mu_M2=$8:Mu_Mesag=$10:Mu_Timer=$20
63035 Mn_Selected=10:Wm_Redraw=20:Wm_Topped=21:Wm_Closed=22:Wm_Fulled=23:Wm_Arrowed=24:Wm_Hslid=25
63040 Wm_Vslid=26:Wm_Sized=27:Wm_Moved=28:Wm_Newtop=29:Ac_Open=40:Ac_Close=41
63045 Ct_Update=50:Ct_Move=51:Ct_Newtop=52
63050 'FORM FLAGS
63055 Fmd_Start=0:Fmd_Grow=1:Fmd_Shrink=2:Fmd_Finish=3
63060 'WINDOW FLAGS
63065 Wname=$1:Closer=$2:Fuller=$4:Mover=$8:Info=$10:Sizer=$20:Uparrow=$40:Dnarrow=$80
63070 Vslide=$100:Lfarrow=$200:Rtarrow=$400:Hslide=$800
63075 Wc_Border=0:Wc_Work=1
63080 Wf_Kind=1:Wf_Name=2:Wf_Info=3:Wf_Workxywh=4:Wf_Currxywh=5:Wf_Prevxywh=6:Wf_Fullxywh=7:Wf_Hslide=8
63085 Wf_Vslide=9:Wf_Top=10:Wf_Firstxywh=11:Wf_Nextxywh=12:Wf_Resvd=13:Wf_Newdesk=14:Wf_Hslsize=15
63090 Wf_Vslsize=16:Wf_Screen=17
63095 Wa_Uppage=0:Wa_Dnpage=1:Wa_Upline=2:Wa_Dnline=3:Wa_Lfpage=4:Wa_Rtpage=5:Wa_Lfline=6:Wa_Rtline=7
63100 'UPDATE FLAGS
63105 End_Update=0:Beg_Update=1:End_Mctrl=2:Beg_Mctrl=3
63110 'MOUSE FORMS
63115 Arrow=0:Text_Crsr=1:Hourglass=2:Point_Hand=3:Flat_Hand=4:Thin_Cross=5:Thick_Cross=6:Outln_Cross=7
63120 User_Def=255:M_Off=256:M_On=257
63125 'RESOURCE DATA TYPES
63130 R_Tree=0:R_Object=1:R_Tedinfo=2:R_Iconblk=3:R_Bitblk=4:R_String=5:R_Imagedata=6:R_Obspec=7
63135 R_Teptext=8:R_Teptmplt=9:R_Tepvalid=10:R_Ibpmask=11:R_Ibpdata=12:R_Ibptext=13:R_Bipdata=14
63140 R_Frstr=15:R_Frimg=16
63145 'OBJEKT FLAGS
63150 Root=0
63155 Max_Len=81
63160 Max_Depth=8
63165 Ip_Hollow=0:Ip_1patt=1:Ip_2patt=2:Ip_3patt=3:Ip_4patt=4:Ip_5patt=5:Ip_6patt=6:Ip_Solid=7
63170 Md_Replace=1:Md_Trans=2:Md_Xor=3:Md_Erase=4
63175 All_White=0:S_And_D=1:S_And_Notd=2:S_Only=3:Nots_And_D=4:D_Only=5:S_Xor_D=6:S_Or_D=7:Not_Sord=8
63180 Not_Sxord=9:D_Invert=10:Not_D=11:S_Or_Notd=12:Nots_Or_D=13:Not_Sandd=14:All_Black=15
63185 Ibm=3:Small=5
63190 G_Box=20:G_Text=21:G_Boxtext=22:G_Image=23:G_Progdef=24:G_Ibox=25:G_Button=26:G_Boxchar=27
63195 G_String=28:G_Ftext=29:G_Fboxtext=30:G_Icon=31:G_Title=32
63200 None=$0:Selectable=$1:Default=$2:Exitb=$4:Editable=$8:Rbutton=$10:Lastob=$20:Touchexit=$40
63205 Hidetree=$80:Indirect=$100
63210 Normal=$0:Selected=$1:Crossed=$2:Checked=$4:Disabled=$8:Outlined=$10:Shadowed=$20
63215 White=0:Black=1:Red=2:Green=3:Blue=4:Cyan=5:Yellow=6:Magenta=7:Lwhite=8:Lblack=9:Lred=10:Lgreen=11
63220 Lblue=12:Lcyan=13:Lyellow=14:Lmagenta=15
63225 Edstart=0:Edinit=1:Edchar=2:Edend=3
63230 Te_Left=0:Te_Right=1:Te_Cntr=2
63235 RETURN
