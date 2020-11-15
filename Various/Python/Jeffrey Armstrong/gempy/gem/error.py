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

class GEMError(Exception):
    """An exception related to GEM"""
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)