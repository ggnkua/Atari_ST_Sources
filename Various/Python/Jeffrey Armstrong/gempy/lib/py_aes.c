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

#include "ldg_Python.h"
#include <gem.h>
#include <macros.h>

extern PyObject *GEMError;

/* --- Application Library --- */
PyObject* __CDECL py_appl_init(PyObject *self, PyObject *args)
{
int ret;

    ret = appl_init();
    return Py_BuildValue("i",ret);
}

PyObject* __CDECL py_appl_exit(PyObject *self, PyObject *args)
{
int ret;

    ret = appl_exit();
    return Py_BuildValue("i",ret);
}

PyObject* __CDECL py_appl_write(PyObject *self, PyObject *args)
{
int ret;
int app_id;
char *message;
int buflen;
int msg_length;
    
    if(!PyArg_ParseTuple(args,"iis#",&app_id,&msg_length,&message,&buflen))
        return NULL;
    
    if(buflen < msg_length) {
        PyErr_SetString(GEMError,"Data length's are dangerously inconsistent in appl_write");
        return NULL;
    }
    
    ret = appl_write(app_id,msg_length,message);
    return Py_BuildValue("i",ret);
}

PyObject* __CDECL py_appl_read(PyObject *self, PyObject *args)
{
int ret;
int app_id;
char *message;
int msg_length;
PyObject *ret_obj;
    
    if(!PyArg_ParseTuple(args,"ii",&app_id,&msg_length))
        return NULL;
    
    if(msg_length <= 0) {
        PyErr_SetString(GEMError,"Data length of zero requested in appl_read");
        return NULL;
    }
    
    message = (char *)malloc(msg_length*sizeof(char));
    ret = appl_read(app_id,msg_length,message);
    
    if(ret == 0) {
        PyErr_SetString(GEMError,"Application read request failed");
        return NULL;
    }
    
#ifdef PYTHON_3_API
    ret_obj = Py_BuildValue("y#",ret_obj,msg_length);
#else
    ret_obj = Py_BuildValue("s#",ret_obj,msg_length);
#endif

    free(message);
    return ret_obj;
}

/* --- Forms Library --- */
PyObject* __CDECL py_form_alert(PyObject *self, PyObject *args)
{
char *text;
int x;
    
    if(!PyArg_ParseTuple(args,"is",&x,&text))
        return NULL;
        
    x = form_alert(x,text);
    return Py_BuildValue("i",x);
}

PyObject* __CDECL py_form_dial(PyObject *self, PyObject *args)
{
int id;
int lx, ly, lw, lh;
int bx, by, bw, bh;
int ret;
    
    if(!PyArg_ParseTuple(args,"i(iiii)(iiii)",&id,&lx,&ly,&lw,&lh,&bx,&by,&bw,&bh))
        return NULL;
    
    ret = form_dial(id, lx, ly, lw, lh, bx, by, bw, bh);
    
    if(ret == 0) {
        PyErr_SetString(GEMError,"Form dial call failed");
        return NULL;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_form_do(PyObject *self, PyObject *args)
{
PyObject *obj;
int x;
int ret;
    
    if(!PyArg_ParseTuple(args,"Oi",&obj,&x))
        return NULL;
        
    ret = form_do(PyCapsule_GetPointer(obj,NULL),x);
    return Py_BuildValue("i",ret);
}

PyObject* __CDECL py_form_center(PyObject *self, PyObject *args)
{
PyObject *obj;
short x,y,w,h;
int ret;
    
    if(!PyArg_ParseTuple(args,"O",&obj))
        return NULL;
        
    form_center(PyCapsule_GetPointer(obj,NULL),&x,&y,&w,&h);
    
    return Py_BuildValue("(iiii)",(int)x,(int)y,(int)w,(int)h);
}

/* --- Graphics Library --- */
PyObject* __CDECL py_graf_handle(PyObject *self)
{
short wchar,hchar,wcell,hcell;
int ret;
    
    ret = graf_handle(&wchar, &hchar, &wcell, &hcell);
    return Py_BuildValue("i(iiii)",ret,(int)wchar,(int)hchar,(int)wcell,(int)hcell);
}

PyObject* __CDECL py_graf_mouse(PyObject self, PyObject *args)
{
int mouse;

    if(!PyArg_ParseTuple(args,"i",&mouse))
        return NULL;

    if(mouse == USER_DEF) {
        PyErr_SetString(GEMError,"User-defined mouse pointers not currently supported");
        return NULL;
    }
    
    if(graf_mouse(mouse,NULL) == 0) {
        PyErr_SetString(GEMError,"Mouse cursor setting failed");
        return NULL;
    }

    Py_INCREF(Py_None);
    return Py_None;
}

/* --- Resources Library --- */
PyObject* __CDECL py_rsrc_load(PyObject *self, PyObject *args)
{
char *file;
int x;
    
    if(!PyArg_ParseTuple(args,"s",&file))
        return NULL;
        
    if(rsrc_load(file) == 0) {
        PyErr_SetString(GEMError,"Resource failed to load");
        return NULL;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_rsrc_gaddr(PyObject *self, PyObject *args)
{
char *file;
int type, index;
void *gaddr;
    
    if(!PyArg_ParseTuple(args,"ii",&type,&index))
        return NULL;
        
    if(rsrc_gaddr(type,index,&gaddr) == 0) {
        PyErr_SetString(GEMError,"Resource item was not found");
        return NULL;
    }
    
    return PyCapsule_New(gaddr,NULL,NULL);
}

/* --- Windows Library --- */
PyObject* __CDECL py_wind_create(PyObject *self, PyObject *args)
{
int type, x, y, w, h;
int ret;
    
    if(!PyArg_ParseTuple(args,"i(iiii)",&type,&x,&y,&w,&h))
        return NULL;
    
    return Py_BuildValue("i",wind_create(type,x,y,w,h));
}

PyObject* __CDECL py_wind_close(PyObject *self, PyObject *args)
{
int id;
    
    if(!PyArg_ParseTuple(args,"i",&id))
        return NULL;
    
    if(wind_close(id) == 0) {
        PyErr_SetString(GEMError,"Window failed to close");
        return NULL;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_wind_delete(PyObject *self, PyObject *args)
{
int id;
    
    if(!PyArg_ParseTuple(args,"i",&id))
        return NULL;
    
    if(wind_delete(id) == 0) {
        PyErr_SetString(GEMError,"Window was not deleted");
        return NULL;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_wind_open(PyObject *self, PyObject *args)
{
int id, x, y, w, h;
int ret;
    
    if(!PyArg_ParseTuple(args,"i(iiii)",&id,&x,&y,&w,&h))
        return NULL;
        
    ret = wind_open(id,x,y,w,h);
    if(ret == 0) {
        PyErr_SetString(GEMError,"Window could not be opened");
        return NULL;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_wind_get(PyObject *self, PyObject *args)
{
int id, gp;
short p1, p2, p3, p4;
int w1, w2, w3, w4;
int ret;
    
    if(!PyArg_ParseTuple(args,"ii",&id,&gp))
        return NULL;
        
    ret = wind_get(id,gp,&p1,&p2,&p3,&p4);
    
    w1 = (int)p1;
    w2 = (int)p2;
    w3 = (int)p3;
    w4 = (int)p4;
    
    if(ret == 0) {
        PyErr_SetString(GEMError,"Window request failed");
        return NULL;
    }
    
    switch(gp) {
    
        case WF_WORKXYWH:
        case WF_WINXCFG:
        case WF_WINX:
        case WF_WIDGETS:
        case WF_UNICONIFY:
        case WF_TOP:
        case WF_PREVXYWH:
        case WF_OWNER:
        case WF_NTOOLBAR:
        case WF_NEXTXYWH:
        case WF_MINXYWH:
        case WF_FULLXYWH:
        case WF_FTOOLBAR:
        case WF_FIRSTXYWH:
        /* case WF_DDELAY: */
        case WF_CURRXYWH:
            return Py_BuildValue("(iiii)", w1, w2, w3, w4);
            break;
        case WF_DCOLOR:
        case WF_ICONIFY:
        case WF_NEWDESK:
            return Py_BuildValue("(iii)", w1, w2, w3);
            break;
        case WF_MENU:
        case WF_TOOLBAR:
        case WF_M_WINDLIST:
            return Py_BuildValue("(ii)", w1, w2);
            break;
        /* case XA:
         *   return Py_BuildValue("ii", ret, w1);
         *   break;
         */
        case WF_BEVENT:
        case WF_BOTTOM:
        case WF_HSLIDE:
        case WF_HSLSIZE:
        case WF_KIND:
        case WF_M_OWNER:
        case WF_SHADE:
        case WF_VSLIDE:
        case WF_VSLSIZE:
        default:
            return Py_BuildValue("i", w1);
            break;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_wind_update(PyObject *self, PyObject *args)
{
int op;
int ret;
    
    if(!PyArg_ParseTuple(args,"i",&op))
        return NULL;
    if(wind_update(op) == 0) {
        PyErr_SetString(GEMError,"Window update failed");
        return NULL;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_wind_set_string(PyObject *self, PyObject *args)
{
int id, sp;
char *str;
short w1, w2;

    if(!PyArg_ParseTuple(args,"iiz",&id,&sp,&str))
        return NULL;

    wind_set_str(id,sp,str);
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_wind_set(PyObject *self, PyObject *args)
{
int id, sp;
int w1, w2, w3, w4;
int ret;
PyObject *tpl;

    if(!PyArg_ParseTuple(args,"ii|O",&id,&sp,&tpl))
        return NULL;
    
    w1 = 0; w2 = 0; w3 = 0; w4 = 0;
    
    switch(sp) {
        case WF_BEVENT:
        case WF_BOTTOMALL:
        case WF_HSLIDE:
        case WF_HSLSIZE:
        case WF_M_BACKDROP:
        case WF_SHADE:
        case WF_STACK:
        case WF_TOPALL:
        case WF_VSLIDE:
        case WF_VSLSIZE:
        case WF_WHEEL:
            PyArg_ParseTuple(tpl,"i",&w1);
            break;
        case WF_COLOR:
        case WF_INFO:
        case WF_MENU:
        case WF_NAME:
        case WF_OPTS:
            PyArg_ParseTuple(tpl,"ii",&w1,&w2);
            break;
        case WF_DCOLOR:
        case WF_NEWDESK:
            PyArg_ParseTuple(tpl,"iii",&w1,&w2,&w3);
            break;
        case WF_CURRXYWH:
        /* case WF_DDELAY: */
        case WF_FULLXYWH:
        case WF_ICONIFY:
        case WF_PREVXYWH:
        case WF_UNICONIFYXYWH:
        case WF_WIDGETS:
        case WF_WINXCFG:
            PyArg_ParseTuple(tpl,"iiii",&w1,&w2,&w3,&w4);
            break;
    }
    
    ret = wind_set(id,sp,w1,w2,w3,w4);
    if(ret == 0) {
        PyErr_SetString(GEMError,"Window set failed");
        return NULL;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}


/* --- Event Library --- */
PyObject* __CDECL py_evnt_multi(PyObject *self, PyObject *args, PyObject *kwargs)
{

EVMULT_IN em_in;
EVMULT_OUT em_out;


/* Because this is possibly the ugliest call ever created in the C
 * language, we'll use the same variable names as the docs use.
 */
int ev_mflags, ev_mbclicks, ev_mbmask, ev_mbstate, ev_mm1flags, ev_mm1x, ev_mm1y, ev_mm1width, ev_mm1height, ev_mm2flags;
int ev_mm2x, ev_mm2y, ev_mm2width, ev_mm2height, ev_mtlocount, ev_mthicount, ev_mmox, ev_mmoy;
int ev_mmbutton, ev_mmokstate, ev_mkreturn, ev_mbreturn;

static char message[16];

int ret;

PyObject *mbuttons;
PyObject *mmovement;
long int timer;

static char *kwlist[] = {"mouse_buttons","mouse_movement","timer",NULL};

    mbuttons = NULL;
    mmovement = NULL;
    timer = 0l;

    if(!PyArg_ParseTupleAndKeywords(args, kwargs, "i|OOl", kwlist,
                                     &ev_mflags, &mbuttons, &mmovement, &timer))
    //if(!PyArg_ParseTuple(args,"i",&ev_mflags))
        return NULL;
            
    //form_alert(0,"[3][Args parsed][Ok]");
    em_in.emi_flags = (short)ev_mflags;
    
    /* Timer handling */
    em_in.emi_tlow = loword(timer);
    em_in.emi_thigh = hiword(timer);

    /* Mouse button handling */
    if(mbuttons != NULL) {
        PyArg_ParseTuple(mbuttons,"iii",&ev_mbclicks,&ev_mbmask,&ev_mbstate);
        em_in.emi_bclicks = (short)ev_mbclicks;
        em_in.emi_bmask = (short)ev_mbmask;
        em_in.emi_bstate = (short)ev_mbstate;
    }
    
    /* Mouse movement handling */
    if(mmovement != NULL) {
        PyArg_ParseTuple(mmovement,"iiiiiiiiii)",&ev_mm1flags,&ev_mm1x,&ev_mm1y,&ev_mm1width,ev_mm1height,
                                                        &ev_mm2flags,&ev_mm2x,&ev_mm2y,&ev_mm2width,ev_mm2height);
        em_in.emi_m1leave = (short)ev_mm1flags;
        em_in.emi_m1.g_x = (short)ev_mm1x;
        em_in.emi_m1.g_y = (short)ev_mm1y;
        em_in.emi_m1.g_w = (short)ev_mm1width;
        em_in.emi_m1.g_h = (short)ev_mm1height;
        
        em_in.emi_m2leave = (short)ev_mm2flags;
        em_in.emi_m2.g_x = (short)ev_mm2x;
        em_in.emi_m2.g_y = (short)ev_mm2y;
        em_in.emi_m2.g_w = (short)ev_mm2width;
        em_in.emi_m2.g_h = (short)ev_mm2height;
    }

    /* Use the not-so-portable fast multi call */
    ret = evnt_multi_fast(&em_in, message, &em_out);
    //form_alert(0,"[3][Args parsed][Ok]");
//#ifdef PYTHON_3_API
    //return Py_BuildValue("{s:i,s:y#,s:(ii),s:(ii),s:(ii)}", 
//#else
    return Py_BuildValue("{s:i,s:s#,s:(ii),s:(ii),s:(ii)}", 
//#endif
                            "events", ret, 
                            "message", message, 16, 
                            "mouse_position", (int)em_out.emo_mouse.p_x, (int)em_out.emo_mouse.p_y, 
                            "mouse_button", (int)em_out.emo_mbutton, (int)em_out.emo_mclicks,
                            "key", (int)em_out.emo_kreturn,(int)em_out.emo_kmeta);
}

/* Menu Library */
PyObject* __CDECL py_menu_bar(PyObject *self, PyObject *args)
{
PyObject *object;
int action;
int ret;

    if(!PyArg_ParseTuple(args,"Oi",&object, &action))
        return NULL;

    ret = menu_bar(PyCapsule_GetPointer(object,NULL),action);
    
    if(ret == 0) {
        PyErr_SetString(GEMError,"Menu bar failed to set properly");
        return NULL;
    }    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_menu_tnormal(PyObject *self, PyObject *args)
{
PyObject *object;
int action;
int menu;
int ret;

    if(!PyArg_ParseTuple(args,"Oii",&object, &menu, &action))
        return NULL;

    ret = menu_tnormal(PyCapsule_GetPointer(object,NULL),(short)menu,(short)action);
    
    if(ret == 0) {
        PyErr_SetString(GEMError,"Menu tnormal failed to set properly");
        return NULL;
    }    
    Py_INCREF(Py_None);
    return Py_None;
}

/* Object Library */
PyObject* __CDECL py_objc_draw(PyObject *self, PyObject *args)
{
PyObject *object;
int id,depth;
int cx, cy, cw, ch;
int ret;
    
    if(!PyArg_ParseTuple(args,"Oii(iiii)",&object,&id,&depth,&cx,&cy,&cw,&ch))
        return NULL;
    
    ret = objc_draw(PyCapsule_GetPointer(object,NULL),id,depth,cx,cy,cw,ch);
    
    if(ret == 0) {
        PyErr_SetString(GEMError,"Object draw call failed");
        return NULL;
    }
    
    Py_INCREF(Py_None);
    return Py_None;
}

/* File Selector Library */
PyObject* __CDECL py_fsel_input(PyObject *self, PyObject *args)
{
PyObject *ret;
char *path;
char *default_file;

char *use_path;
char *use_file;
int result;
int pathlen;
    
    default_file = NULL;
    
    if(!PyArg_ParseTuple(args,"s|s",&path,&default_file))
        return NULL;
    
    pathlen = strlen(path);
    if(pathlen < 200) pathlen = 200;
    
    use_path = (char *)malloc(pathlen*sizeof(char));
    strcpy(use_path,path);
    
    use_file = (char *)malloc(13*sizeof(char));
    use_file[0] = '\0';
    if(default_file != NULL) {
        if(strlen(default_file) <= 12)
            strcpy(use_file,default_file);
    }    
    
    if(fsel_input(use_path,use_file,&result) == 0) {
        PyErr_SetString(GEMError,"Basic File Selector call failed.");
        return NULL;
    }
    
    if(result == 0) {
        free(use_path);
        free(use_file);
        Py_INCREF(Py_None);
        return Py_None;
    } else {
        ret = Py_BuildValue("ss",use_path,use_file);
        return ret;
    }
}
