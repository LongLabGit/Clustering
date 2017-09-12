import numpy as np
from phy import IPlugin
from phy.cluster.views import (FeatureView)
class MyKwikFeatureView(IPlugin):
    def attach_to_controller(self, controller):
        @controller.connect
        def on_add_view(gui, view):
            if isinstance(view, FeatureView):
                view.grid_dim[3][0] = '0C,0C'
                #view.grid_dim[3][1] = 'time,0B'
            #view.grid_dim[2][0] = 'time,1A',
            #view.grid_dim[3][0] = 'time,1B',
            #view.grid_dim[0][1] = '0A,1A',
            #view.grid_dim[1][1] = '0A,1B',
            #view.grid_dim[2][1] = '0A,1C',
            #view.grid_dim[3][1] = '0A,0B',
            #view.grid_dim[0][2] = '0B,1A',
            #view.grid_dim[1][2] = '0B,1B',
            #view.grid_dim[2][2] = '0B,1C',
            #view.grid_dim[3][2] = '0B,0C',
            #view.grid_dim[0][3] = '1A,1B',
            #view.grid_dim[1][3] = '1A,1C',
            #view.grid_dim[2][3] = '1B,1C',
            #view.grid_dim[3][3] = '1B,0C'
