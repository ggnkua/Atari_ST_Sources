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

import struct

import _gem

from error import GEMError
from constants import *

def alert(message,type=None,buttons=('Ok',),default=None):
    """Displays a generic GEM alert box with the specified
    message.  The type of box may also be specified as one
    of ('none', 'exclamation', 'question', 'stop', 'info',
    'disk', 'bomb').  The buttons parameter can contain a 
    tuple or list of button texts (up to 3, as limited by
    GEM."""
    
    alert_types = ['none', 'exclamation', 'question',
                   'stop', 'info', 'disk', 'bomb']
    try:
        internal_type = alert_types.index(type.lower())
    except ValueError:
        raise GEMError('Unknown alert box type')
    except AttributeError:
        if type is None:
            internal_type = 0
        else:
            internal_type = type
    
    if default is None:
        default = 0
    elif type(default) is str:
        try:
            default = buttons.index(default)
        except ValueError:
            raise GEMError('Could not locate default button')
    
    bstring = ''
    if len(buttons) > 3:
        buttons = buttons[0:3]
    for button in buttons:
        if len(button) > 10:
            button = button[0:10]
        bstring = bstring + button + '|'
    bstring = bstring[:-1]
    
    astring = "[{0}][{1}][{2}]".format(repr(internal_type),
                                       message, bstring)
    
    return _gem.form_alert(default, astring)
    
def window_update(action):
    """Issues a 'wind_update()' call to the AES with the specified
    argument.  The action argument must be END_UPDATE, BEG_UPDATE,
    END_MCTRL, or BEG_MCTRL."""
    _gem.wind_update(action)
    
def basic_file_dialog(path):
    """Opens a basic file selection dialog starting at the
    specified path."""
    window_update(BEG_MCTRL)
    ret = _gem.fsel_input(path)
    window_update(END_MCTRL)
    return ret
    
class Window:
    """A class wrapping GEM windows and their functionality"""
    
    def __init__(self, type=NAME|FULLER|MOVER|CLOSER|SIZER):
        """Creates (but does not show) a window"""
        self.id = _gem.wind_create(type,(0,0,10,10))
        self.name = None
    
    def open(self,rect):
        """Opens a window using the the specified rectangle (x,y,w,h)"""
        _gem.wind_open(self.id, rect)
        
    def close(self):
        """Closes (but does not destroy) a window"""
        _gem.wind_close(self.id)
        
    def destroy(self):
        """Deletes an existing GEM window"""
        _gem.wind_delete(self.id)
        self.id = None
    
    def resize(self,rect):
        """Resizes/moves a window"""
        _gem.wind_set(self.id,WF_CURRXYWH,rect)
    
    def top(self):
        """Sets the current window to topmost"""
        _gem.wind_set(self.id,WF_TOP,(self.id,0,0,0))
    
    def set_name(self,name):
        """Sets the name of a window"""
        _gem.wind_set_string(self.id,WF_NAME,name)
        self.name = name
        
    def begin_update(self):
        window_update(BEG_UPDATE)
    
    def end_update(self):
        window_update(END_UPDATE)

    def get_size(self):
        """Returns the window position and size"""
        return _gem.wind_get(self.id,WF_CURRXYWH)

    def get_work_rect(self):
        """Returns this window's current work area rectangle"""
        return _gem.wind_get(self.id,WF_WORKXYWH)
        
    def get_invalid_rectangles(self):
        """Returns a list of rectangles requiring redrawing"""
        rects = []
        r = _gem.wind_get(self.id,WF_FIRSTXYWH)
        while r[2] > 0 or r[3] > 0:
            rects.append(r)
            r = _gem.wind_get(self.id,WF_NEXTXYWH)
        
        return rects
        
    def intersect_work_area(self,rect):
        """Returns the intersecting region of a rectangle and the window's workspace"""
        wrect = self.get_work_rect()

        tw = min(wrect[0]+wrect[2], rect[0]+rect[2])
        th = min(wrect[1]+wrect[3], rect[1]+rect[3])
        tx = max(wrect[0], rect[0])
        ty = max(wrect[1], rect[1])
        
        if (tw > tx) and (th > ty):
            return (tx, ty, tw-tx, th-ty)
        else:
            return None
            
    def graphics_handle(self):
        """Returns a VDI handle to the screen"""
        vh,ignore = _gem.graf_handle()
        return vh

class Event:
    def __init__(self):
        pass
        
    def process(self):
        pass
        
class MouseButtonEvent(Event):
    """A base mouse button event class"""
    def __init__(self, clicks=1, mask=MB_LEFT, state=0):
        Event.__init__(self)
        self.clicks = clicks
        self.mask = mask
        self.requested_state = state
        
        self.returned_button = None
        self.returned_state = None
        self.returned_clicks = None
        self.position = None
        
class MouseMovementEvent(Event):
    def __init__(self):
        Event.__init__(self)
        raise RuntimeError("Not yet implemented")
        
class TimerEvent(Event):
    def __init__(self, length=1000):
        Event.__init__(self)
        self.length = length
        
class KeyboardEvent(Event):
    def __init__(self):
        Event.__init__(self)
        
        self.keycode = None

class MessageEvent(Event):
    def __init__(self):
        Event.__init__(self)

        self.message = None
        self.sender_id = None
        self.extended_data = None
        self.raw_message = None
    
    def get_word(self,index):
        """Retrieves a word from the raw message array"""
        if index > 7:
            raise ValueError('Message index must be between 0 and (including) 7.')
        try:
            ret = struct.unpack_from("@h",self.raw_message,offset=index*2)
        except SystemError:
            print 'Warning: SystemError on struct.unpack_from in get_word()'
            return 0
        return ret[0]
        
    def process(self):
        self.message = self.get_word(0)
        self.sender_id = self.get_word(1)
        
        extended_data_length = self.get_word(2)
        #if extended_data_length > 0:
        #    self.extended_data = _gem.appl_read(self.sender_id,extended_data_length)
        #else:
        #    self.extended_data = None

class Application:

    def __init__(self):
        """Initializes the GEM application"""
        self.id = _gem.appl_init()
        if self.id == -1:
            raise GEMError("The application failed to initialize")
        
        self.windows = []
        self.resource = False
        self.menu = None
        
        self.message_event = None
        self.button_event = None
        self.keyboard_event = None
        self.mouse_event = None
        self.timer_event = None
        
        self.event_processing = False
        
    def destroy(self):
        """Destroys the application"""
        window_update(BEG_UPDATE)
        for w in self.windows:
            try:
                w.close()
                w.destroy()
            except:
                pass
                
        if self.menu is not None:
            _gem.menu_bar(self.menu,MENU_HIDE)
            
        window_update(END_UPDATE)
        _gem.appl_exit(self.id)
        
    def load_resource(self,file):
        """Loads a resource file into the application."""
        try:
            _gem.rsrc_load(file)
            self.resource = True
        except:
            self.resource = False
            raise GEMError("Could not load the resource file {0}".format(file))
            
    def get_resource_item(self,type,index):
        """Returns a capsule containing a resource item"""
        return _gem.rsrc_gaddr(type,index)
    
    def set_menu(self,item,show=True):
        """Sets the application menu"""
        if type(item) is int:
            capsule = self.get_resource_address(R_OBJECT,item)
        else:
            capsule = item
        
        action = MENU_SHOW
        if type(show) is int:
            action = show
        elif not show:
            action = MENU_HIDE
        
        window_update(BEG_UPDATE)
        _gem.menu_bar(capsule, action)
        window_update(END_UPDATE)
        
        self.menu = capsule
        
    def set_menu_state(self,id,highlight=False):
        """Highlight (default) or unhighlight a menu item"""
        
        if self.menu is None:
            raise ValueError("Application's menu is None.")
        
        if highlight:
            _gem.menu_tnormal(self.menu,id,MENU_HIGHLIGHT)
        else:
            _gem.menu_tnormal(self.menu,id,MENU_NORMAL)
    
    def get_resource_address(self,type,index):
        """Retrieves the address of a resource element in a Python capsule.
        The returned object should never be directly modified."""
        if not self.resource:
            raise GEMError("A resource has not yet be loaded")
            
        return _gem.rsrc_gaddr(type, index)
        
    def new_window(self, rect, name=None, type=NAME|FULLER|MOVER|CLOSER|SIZER):
        """Opens an application-managed window"""
        w = Window(type=type)
        w.begin_update()
        if name is not None:
            w.set_name(name)
        w.open(rect)
        w.end_update()
        
        self.windows.append(w)
        return w
        
    def close_window(self,w):
        """Closes an application-managed window"""
        if w in self.windows:
            self.windows.remove(w)
            w.close()
            w.destroy()
            
    def event_loop(self):
        """Executes the GEM event loop, watching for events specified
        by the event attributes of the Application object."""
        
        self.event_processing = True
        while self.event_processing:
            
            events = 0
            kwdict = dict()
            if self.message_event is not None:
                events = events | MU_MESAG
                
            if self.button_event is not None:
                events = events | MU_BUTTON
                kwdict['mouse_buttons'] = (self.button_event.clicks, 
                                           self.button_event.mask, 
                                           self.button_event.state)
                
            if self.timer_event is not None:
                events = events | MU_TIMER
                kwdict['timer'] = self.timer_event.length
                
            if self.keyboard_event is not None:
                events = events | MU_KEYBD
                
            if self.mouse_event is not None:
                self.event_processing = False
                raise RuntimeError("Not yet implemented")
                events = events | MU_M1 | MU_M2 | MU_WHEEL | MU_MX
            
            if events == 0:
                self.event_processing = False
                raise GEMError("No event callbacks have been specified")
        
            ret = _gem.evnt_multi(events,**kwdict)
            
            if ret['events'] & MU_MESAG:
                #if type(ret['message']) is str:
                #    self.message_event.raw_message = bytearray(ret['message'])
                #else:
                self.message_event.raw_message = ret['message']
                self.message_event.process()
                
            if ret['events'] & MU_BUTTON:
                self.button_event.position = ret['mouse_position']
                self.button_event.returned_button = ret['mouse_button'][0]
                self.button_event.returned_state = ret['mouse_button'][1]
                self.button_event.returned_clicks = ret['mouse_button'][2]
                self.button_event.process()
                
            if ret['events'] & MU_TIMER:
                self.timer_event.process()
                
            if ret['events'] & MU_KEYBD:
                self.keyboard_event.keycode = ret['key']
                self.keyboard_event.process()
                
    def graphics_handle(self):
        """Returns a VDI handle to the screen"""
        vh,ignore = _gem.graf_handle()
        return vh
        
    def send_message(self, data, target=None):
        """Send a message to a gem application (self if target is None)"""
        xmsg = data
        if len(data) > 8:
            raise ValueError("Message may only be 8 words long")
        else:
            while len(xmsg) < 8:
                xmsg = xmsg + (0,)
            
        bytemsg = struct.pack("@hhhhhhhh",*xmsg)
        
        if target is None:
            ret = _gem.appl_write(self.id, 16, bytemsg)
        elif type(target) is int:
            ret = _gem.appl_write(target, 16, bytemsg)
        else:
            ret = _gem.appl_write(target.id, 16, bytemsg)
                
        return ret
        
    def draw_tree(self,object,depth,position=None,center=True):
        """Draws an AES object (usually from a resource)"""
        xpos = position
        if center:
            position = _gem.form_center(object)
        _gem.objc_draw(object,0,depth,position)
    
    def form_do(self,object):
        """Executes a form (dialog)"""
        return _gem.form_do(object,0)