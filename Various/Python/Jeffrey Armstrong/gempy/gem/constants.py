#  This file is part of gempy.
# 
#   gempy - https://github.com/ArmstrongJ/gempy
#   Copyright (C) 2011 Jeffrey Armstrong
#   <jeffrey.armstrong@approximatrix.com>
# 
#   Foobar is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as 
#   published by the Free Software Foundation, either version 3 of 
#   the License, or (at your option) any later version.
# 
#   Foobar is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
# 

from messages import *

# Window Constants
NAME =	   0x0001 	    # Title-bar
CLOSER =   0x0002 	    # Close-box
FULLER =   0x0004 	    # Fuller-box
MOVER =	   0x0008 	    # Window may be moved by user
INFO =	   0x0010 	    # Info-line
SIZER =	   0x0020 	    # Sizer-box
UPARROW =  0x0040 	    # Up-arrow
DNARROW =  0x0080 	    # Down-arrow
VSLIDE =   0x0100 	    # Vertical slider
LFARROW =  0x0200 	    # Left arrow
RTARROW =  0x0400 	    # Right arrow
HSLIDE =   0x0800 	    # Horizontal slider
HOTCLOSEBOX = 0x1000 	# Close-box with auto-repeat
MENUBAR =  0x1000 	    # Menu bar (XaAES)
BACKDROP = 0x2000  	    # Background-box
ICONIFIER = 0x4000 	    # Iconify-button
BORDER =   0x8000 	    # Border sizing

# Window Update Values
END_UPDATE = 0
BEG_UPDATE = 1
END_MCTRL = 2
BEG_MCTRL = 3

# Window Set/Get Messages
WF_KIND	 = 1
WF_NAME	 = 2
WF_INFO	 = 3
WF_WORKXYWH	 = 4
WF_CURRXYWH	 = 5
WF_PREVXYWH	 = 6
WF_FULLXYWH	 = 7
WF_HSLIDE	 = 8
WF_VSLIDE	 = 9
WF_TOP	 = 10
WF_FIRSTXYWH	 = 11
WF_NEXTXYWH	 = 12
WF_IGNORE	 = 13
WF_FIRSTAREAXYWH	 = 13
WF_NEWDESK	 = 14
WF_HSLSIZE	 = 15
WF_VSLSIZE	 = 16
WF_SCREEN	 = 17
WF_COLOR	 = 18
WF_ATTRB	 = 18
WF_DCOLOR	 = 19
WF_SIZETOP	 = 19
WF_OWNER	 = 20
WF_BEVENT	 = 24
WF_BOTTOM	 = 25
WF_ICONIFY	 = 26
WF_UNICONIFY	 = 27
WF_UNICONIFYXYWH	 = 28
WF_TOOLBAR	 = 30
WF_FTOOLBAR	 = 31
WF_NTOOLBAR	 = 32
WF_MENU	 = 33
WF_WHEEL	 = 40
WF_OPTS	 = 41
WF_CALCF2W	 = 42
WF_CALCW2F	 = 43
WF_CALCF2U	 = 44
WF_CALCU2F	 = 45
WF_MAXWORKXYWH	 = 46
WF_M_BACKDROP	 = 100
WF_M_OWNER	 = 101
WF_M_WINDLIST	 = 102
WF_MINXYWH	 = 103
WF_INFOXYWH	 = 104
WF_WIDGETS	 = 200
WF_USER_POINTER	 = 230
WF_WIND_ATTACH	 = 231
WF_TOPMOST	 = 232
WF_OBFLAG	 = 1001
WF_OBTYPE	 = 1002
WF_OBSPEC	 = 1003
X_WF_MENU	 = 4352
X_WF_DIALOG	 = 4608
X_WF_DIALWID	 = 4864
X_WF_DIALHT	 = 5120
X_WF_DFLTDESK	 = 5376
X_WF_MINMAX	 = 5632
X_WF_HSPLIT	 = 5888
X_WF_VSPLIT	 = 6144
X_WF_SPLMIN	 = 6400
X_WF_HSLIDE2	 = 6656
X_WF_VSLIDE2	 = 6912
X_WF_HSLSIZE2	 = 7168
X_WF_VSLSIZE2	 = 7424
X_WF_DIALFLGS	 = 7680
X_WF_OBJHAND	 = 7936
X_WF_DIALEDIT	 = 8192
X_WF_DCOLSTAT	 = 8448
WF_WINX	 = 22360
WF_WINXCFG	 = 22361
WF_DDELAY	 = 22362
WF_SHADE	 = 22365
WF_STACK	 = 22366
WF_TOPALL	 = 22367
WF_BOTTOMALL	 = 22368
XA	 = 22593

# Resource Constants
R_TREE	     = 0
R_OBJECT	 = 1
R_TEDINFO	 = 2
R_ICONBLK	 = 3
R_BITBLK	 = 4
R_STRING	 = 5
R_IMAGEDATA	 = 6
R_OBSPEC	 = 7
R_TEPTEXT	 = 8
R_TEPTMPLT	 = 9
R_TEPVALID	 = 10
R_IBPMASK	 = 11
R_IBPDATA	 = 12
R_IBPTEXT	 = 13
R_BIPDATA	 = 14
R_FRSTR	     = 15
R_FRIMG	     = 16

# Event types
MU_KEYBD	 = 0x0001
MU_BUTTON	 = 0x0002
MU_M1	     = 0x0004
MU_M2	     = 0x0008
MU_MESAG	 = 0x0010
MU_TIMER	 = 0x0020
MU_WHEEL	 = 0x0040
MU_MX	     = 0x0080
MU_KEYBD4	 = 0x0100
MU_NORM_KEYBD	 = 0x0100
MU_DYNAMIC_KEYBD	 = 0x0200
X_MU_DIALOG	 = 0x4000

# Mouse Button Masks
MB_LEFT = 0x0001
MB_RIGHT = 0x0002
MB_CENTER = 0x0004

MB_KRSHIFT = 0x0001
MB_KLSHIFT = 0x0002
MB_KCONTROL = 0x0004
MB_KALT = 0x0008

# Menu menu_bar() definitions
MENU_HIDE = 0 
MENU_SHOW = 1 
MENU_INSTL = 100

# Menu Hightlight Defintions
MENU_HIGHLIGHT = 0
MENU_NORMAL = 1