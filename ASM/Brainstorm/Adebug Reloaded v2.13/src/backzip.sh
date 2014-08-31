#
# Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
#                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
#
# This file is part of Adebug.
#
# Adebug is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Adebug is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Adebug; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

stzip -a adebug.zip accessor.s adebug.s adebug2.s alt_e.s atari.s databss.s
stzip -a adebug.zip disasmxx.s eval_128.s redraw.s residant.s srcdebug.s pcdebug.s
stzip -a adebug.zip mmanager.s makefile backzip.sh commands.adb

