extends Node


enum Dir {RIGHT, DOWN, LEFT, UP, DOWN_LAYER, UP_LAYER}

var e_x = Vector2(1,0)
var e_y = Vector2(0,1)
var Direction = {'right':e_x, 'down':e_y, 'left':-e_x, 'up':-e_y}

var One = Vector2(1,1)


# can get enum from packed scene?

enum State {Connect, Disconnect}