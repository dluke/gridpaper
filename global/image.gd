
extends Object

# core methods
static func img_rotate_left(image):
	"""
	# create a new image which is a perfect clockwise rotation
	# if you need to do this faster it suggested as contribution godot but rejected
	https://github.com/godotengine/godot/pull/19233
	"""
	var new = Image.new()
	var imsize = image.get_size()
	new.create(imsize.y, imsize.x, false, image.get_format())
	image.lock()
	new.lock()
	for i in range(imsize.x):
		for j in range(imsize.y):
			new.set_pixel(j, i, image.get_pixel(i, j))
	new.unlock()
	image.unlock()
	return new

static func img_rotate_right(image):
	image.flip_y()
	var new = img_rotate_left(image)
	return new

# convenience methods 
static func tex_rotate_right(texture):
	var new = ImageTexture.new()
	new.create_from_image(img_rotate_right(texture.get_data()))
	return new

# convenience methods 
static func tex_rotate_left(texture):
	var new = ImageTexture.new()
	new.create_from_image(img_rotate_left(texture.get_data()))
	return new

static func texture_cardinal_directions(texture):
	var flipped = ImageTexture.new()
	var image = texture.get_data()
	image.flip_y()
	flipped.create_from_image(image)

	var cardinal = [texture, tex_rotate_left(texture),
		flipped, tex_rotate_left(flipped)]
	return cardinal

