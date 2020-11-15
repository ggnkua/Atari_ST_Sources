import gem
import gem.vdi

# Taken from resource headers
MENU = 0
M_ABOUT = 7
M_QUIT = 16
ABOUT = 1
B_ABOUT_OK = 1

def redraw(window):

    window.begin_update()
    vh = window.graphics_handle()
    gem.vdi.vsf_color(vh,0)
    
    for r in window.get_invalid_rectangles():
        todraw = window.intersect_work_area(r)
        if todraw is not None:
            gem.vdi.vs_clip(vh, True, todraw)
            gem.vdi.bar(vh,todraw)
            gem.vdi.vs_clip(vh, False, todraw)

    window.end_update()

class AppMessageEvent(gem.MessageEvent):
    def __init__(self,app):
        gem.MessageEvent.__init__(self)
        
        self.app = app
        self.window = app.windows[0]
    
    def handle_menu(self, item, title=None):
        if item == M_QUIT:
            self.app.send_message((gem.WM_CLOSED, 0, 0, self.window.id))
            
        elif item == M_ABOUT:
            dlg = self.app.get_resource_address(gem.R_TREE,ABOUT)
            self.app.draw_tree(dlg,2)
            self.app.form_do(dlg)
        
        if title is not None:
            self.app.set_menu_state(title)
    
    def process(self):
        
        # First call the super's process()
        gem.MessageEvent.process(self)
        
        if self.message == gem.WM_CLOSED:
            self.app.event_processing = False
        
        elif self.message == gem.WM_TOPPED:
            self.window.top()
            
        elif self.message == gem.WM_MOVED or self.message == gem.WM_SIZED:
            rect = (self.get_word(4),self.get_word(5),self.get_word(6),self.get_word(7))
            self.window.resize(rect)
            
        elif self.message == gem.WM_REDRAW:
            redraw(self.window)
        
        # Menu handling
        elif self.message == gem.MN_SELECTED:
            self.handle_menu(self.get_word(4),title=self.get_word(3))

def start_app():

    app = gem.Application()
    
    app.load_resource("simple.rsc")
    
    app.set_menu(MENU)

    w = app.new_window((60,60,500,300),'Awesome!')
    
    app.message_event = AppMessageEvent(app)
    
    app.event_loop()
    
    app.destroy()
    

if __name__ == "__main__":
    start_app()