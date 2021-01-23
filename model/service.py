from nameko.events import EventDispatcher
from nameko.rpc import rpc

from model.exceptions import NotFound

import json
import random

class ModelService:

    TRAVEL_DISTANCE_AVG =  12.421
    TRAVEL_DISTANCE_STDDEV = 8.967

    name = 'model_travel_distance'

    event_dispatcher = EventDispatcher()

    @rpc
    def get_travel_distance(self):
    	min_travel_distance = self.TRAVEL_DISTANCE_AVG - self.TRAVEL_DISTANCE_STDDEV
    	max_travel_distance = self.TRAVEL_DISTANCE_AVG + self.TRAVEL_DISTANCE_STDDEV
    	travel_distance = random.uniform( min_travel_distance, max_travel_distance )
    	
    	response = json.dumps({'travel_distance': travel_distance})
    	return response
