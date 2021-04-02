from nameko.events import EventDispatcher
from nameko.rpc import rpc

from model.exceptions import NotFound

import json

import tensorflow as tf

class ModelService:

    TRAVEL_DISTANCE_AVG =  12.421
    TRAVEL_DISTANCE_STDDEV = 8.967

    name = 'model_energysim_travel_distance'

    event_dispatcher = EventDispatcher( )

    @rpc
    def get_distance( self ):
        travel_distance = self.generate_distance( )
        response = json.dumps( { 'travel_distance': travel_distance } )
        return response

    def generate_distance( self ):
        shape = [ 1,1 ]
        min_travel_distance = ModelService.TRAVEL_DISTANCE_AVG - ModelService.TRAVEL_DISTANCE_STDDEV
        max_travel_distance = ModelService.TRAVEL_DISTANCE_AVG + ModelService.TRAVEL_DISTANCE_STDDEV

        tf_random = tf.random_uniform(
                shape=shape,
                minval=min_travel_distance,
                maxval=max_travel_distance,
                dtype=tf.dtypes.float32,
                seed=None,
                name=None
        )
        tf_var = tf.Variable( tf_random )

        tf_init = tf.global_variables_initializer( )
        tf_session = tf.Session( )
        tf_session.run( tf_init )

        tf_return = tf_session.run( tf_var )
        travel_distance = float( tf_return[ 0 ][ 0 ] )

        return travel_distance
