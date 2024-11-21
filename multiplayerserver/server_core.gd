extends Node





func _on_timer_timeout() -> void:
	Server.check_for_disconnects()
