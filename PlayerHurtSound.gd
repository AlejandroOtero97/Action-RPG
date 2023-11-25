extends AudioStreamPlayer


func _on_finished():
	self.connect("finished", queue_free)
