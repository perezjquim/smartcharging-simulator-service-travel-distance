from nameko.events import EventDispatcher
from nameko.rpc import rpc

from model1.exceptions import NotFound

class Model1Service:
    name = 'model1'

    event_dispatcher = EventDispatcher()

    @rpc
    def get_model1(self):
        return "MODEL 1 SAYS YES!"
