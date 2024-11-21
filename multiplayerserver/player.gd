extends Button


var username = "Default"
var color : Color = Color.RED
var kills = 0	
var deaths = 0




# Called when the node enters the scene tree for the first time.
func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	


func _on_pressed() -> void:
	Server.kick_player(name)
	queue_free()
