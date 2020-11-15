/*  This file is part of gempy.
 *
 *  gempy - https://github.com/ArmstrongJ/gempy
 *  Copyright (C) 2011 Jeffrey Armstrong
 *  <jeffrey.armstrong@approximatrix.com>
 *
 *  Foobar is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation, either version 3 of 
 *  the License, or (at your option) any later version.
 *
 *  Foobar is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef __PY_AES_HEADERS
#define __PY_AES_HEADERS

#include "ldg_Python.h"

 PyObject* __CDECL py_appl_init(PyObject *self, PyObject *args);
 PyObject* __CDECL py_appl_exit(PyObject *self, PyObject *args);
 PyObject* __CDECL py_appl_write(PyObject *self, PyObject *args);
 PyObject* __CDECL py_appl_read(PyObject *self, PyObject *args);

 PyObject* __CDECL py_form_alert(PyObject *self, PyObject *args);
 PyObject* __CDECL py_form_dial(PyObject *self, PyObject *args);
 PyObject* __CDECL py_form_do(PyObject *self, PyObject *args);
 PyObject* __CDECL py_form_center(PyObject *self, PyObject *args);

 PyObject* __CDECL py_graf_handle(PyObject self, PyObject *args);
 PyObject* __CDECL py_graf_mouse(PyObject self, PyObject *args);

 PyObject* __CDECL py_rsrc_load(PyObject *self, PyObject *args);
 PyObject* __CDECL py_rsrc_gaddr(PyObject *self, PyObject *args);

 PyObject* __CDECL py_wind_create(PyObject *self, PyObject *args);
 PyObject* __CDECL py_wind_open(PyObject *self, PyObject *args);
 PyObject* __CDECL py_wind_get(PyObject *self, PyObject *args);
 PyObject* __CDECL py_wind_delete(PyObject *self, PyObject *args);
 PyObject* __CDECL py_wind_close(PyObject *self, PyObject *args);
 PyObject* __CDECL py_wind_set(PyObject *self, PyObject *args);
 PyObject* __CDECL py_wind_set_string(PyObject *self, PyObject *args);
 PyObject* __CDECL py_wind_update(PyObject *self, PyObject *args);

 PyObject* __CDECL py_evnt_multi(PyObject *self, PyObject *args, PyObject *kwargs);
 
 PyObject* __CDECL py_menu_bar(PyObject *self, PyObject *args);
 PyObject* __CDECL py_menu_tnormal(PyObject *self, PyObject *args);
 
 PyObject* __CDECL py_objc_draw(PyObject *self, PyObject *args);

 PyObject* __CDECL py_fsel_input(PyObject *self, PyObject *args);

#endif /* __PY_AES_HEADERS */
