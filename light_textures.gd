extends Node

var soft_radial: Texture2D


func _ready() -> void:
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var center := Vector2(63.5, 63.5)
	for y in range(128):
		for x in range(128):
			var distance := Vector2(x, y).distance_to(center) / 64.0
			var alpha := pow(clampf(1.0 - distance, 0.0, 1.0), 2.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	soft_radial = ImageTexture.create_from_image(image)
