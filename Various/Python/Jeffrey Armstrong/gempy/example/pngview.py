import gem
import gem.vdi

import sys

import png

# Taken from resource headers
MENU = 0
M_ABOUT = 7
M_QUIT = 16
ABOUT = 1
B_ABOUT_OK = 1

class PictureWindow(gem.Window):
    def __init__(self,app,filename,wh,data):
        gem.Window.__init__(self, type=gem.NAME|gem.CLOSER|gem.MOVER)
        
        self.set_name(filename)
        self.data = data
        
        self.open((10,10,wh[0],wh[1]+10))
    
    def draw(self):

        self.begin_update()
        vh = self.graphics_handle()
        
        wrect = self.get_work_rect()
        
        for rect in self.get_invalid_rectangles():
            todraw = self.intersect_work_area(rect)
            if todraw is not None:
                gem.vdi.vs_clip(vh, True, todraw)
                image_y = 0
                for r in self.data:
                    image_x = 0
                    
                    for c in r:
                    
                        if c > 128:
                            gem.vdi.vsf_color(vh,0)
                        else:
                            gem.vdi.vsf_color(vh,1)
                        x = wrect[0] + image_x
                        y = wrect[1] + image_y
                        gem.vdi.bar(vh,(x,y,1,1))
                        image_x = image_x + 1

                    image_y = image_y + 1
                
                gem.vdi.vs_clip(vh, False, todraw)

        self.end_update()

class LoadingWindow(gem.Window):
    def __init__(self,app,filename):
        gem.Window.__init__(self, type=gem.NAME|gem.CLOSER)
        
        self.set_name("Loading "+filename)
        
        self.reader = png.Reader(filename)
        self.raw_data = self.reader.asRGBA8()
        
        self.data = []
        self.done = False
        self.row = 0
        
        #self.load_thread = threading.Thread(target=self.load)
        #self.load_thread.start()
    
    def load(self):
        rgbdata = self.raw_data[2]

        for r in rgbdata:
            self.row = self.row + 1
            
            pvalue = 0
            pcount = 0
            
            row = []
            for c in r:
                if pcount < 3:
                    pvalue = pvalue + c
                pcount = pcount + 1
                
                if pcount == 4:
                    pvalue = pvalue / 3
                    
                    row.append(pvalue)

                    #if image_x > data[0]:
                    #    raise RuntimeError("Point {0} exceeds limit {1}".format(image_x,data[0]))
                    pcount = 0
                    pvalue = 0
                    
            self.data.append(row)
            self.draw()
        
        self.done = True
        self.close()
        #self.app.send_message((0,self.app.id,0,gem.WM_CLOSED))
        
    def draw(self):
        wrect = self.get_work_rect()
        
        vh = self.graphics_handle()
        self.begin_update()
        
        for r in self.get_invalid_rectangles():
            todraw = self.intersect_work_area(r)
            if todraw is not None:
                gem.vdi.vs_clip(vh, True, todraw)
                
                w = wrect[2]*self.row/self.raw_data[1]
                
                gem.vdi.vsf_color(vh,0)
                gem.vdi.bar(vh,(wrect[0],wrect[1],w,wrect[3]))
                
                gem.vdi.vsf_color(vh,1)
                gem.vdi.bar(vh,(wrect[0]+w,wrect[1],wrect[2]-w,wrect[3]))
                
                gem.vdi.vs_clip(vh, False, todraw)
        
        self.end_update()

class AppMessageEvent(gem.MessageEvent):
    def __init__(self,app,window):
        gem.MessageEvent.__init__(self)
        
        self.app = app
        self.window = window
    
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
            self.window.draw()
        
        # Menu handling
        elif self.message == gem.MN_SELECTED:
            self.handle_menu(self.get_word(4),title=self.get_word(3))


def start_app(filename):

    app = gem.Application()
    app.load_resource("simple.rsc")
    app.set_menu(MENU)

    wload = LoadingWindow(app,filename)
    app.windows.append(wload)
    wload.open((10,10,250,50))
    wload.load()
    #app.message_event = AppMessageEvent(app,wload)

    #app.event_loop()

    wpic = PictureWindow(app,filename,(wload.raw_data[0],wload.raw_data[1]),wload.data)
    app.windows.append(wpic)
    app.message_event = AppMessageEvent(app,wpic)
    
    app.event_loop()
    
    app.destroy()
    

if __name__ == "__main__":
    print("Simple PNG Viewer for GEM")
    if len(sys.argv) < 2:
        print("Usage: {0} <png filename>".format(sys.argv[0]))
    else:
        print("Now processing {0}".format(sys.argv[1]))
        start_app(sys.argv[1])