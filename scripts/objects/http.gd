extends Node2D


func _ready():
	# Create an HTTP request node and connect its completion signal.
	#download()
	print(OS.get_executable_path())


func download():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	http_request.download_file = "file.png"

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request("https://via.placeholder.com/512")
	if error != OK:
		push_error("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("File couldn't be downloaded.")

	#var image = Image.new()
	#var error = image.load_png_from_buffer(body)
	#if error != OK:
		#push_error("Couldn't load the image.")

	#var texture = ImageTexture.create_from_image(image)

	# Display the image in a TextureRect node.
	#var texture_rect = TextureRect.new()
	#add_child(texture_rect)
	#texture_rect.texture = texture
	
	
	
	print("done")
