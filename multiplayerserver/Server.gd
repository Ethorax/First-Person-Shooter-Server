extends Node

var network = ENetMultiplayerPeer.new()
var port  = 6969
var max_players = 32
var gateway

var connected_peer_ids = []
var connected_peer_usernames = []
var connected_peer_colors = []

var most_recent_username
var most_recent_color

#Game Variables
var map_name : String = "DefaultDM"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	network.peer_connected.connect(Peer_Connected)
	network.peer_disconnected.connect(Peer_Disconnected)
	multiplayer.peer_connected.connect(Peer_Connected)
	start_server()
	print(get_path())
	print(multiplayer.get_unique_id())


func start_server():
	#gateway = SceneMultiplayer.create_default_interface()
	#network.create_server(port,max_players)
	#get_tree().set_multiplayer(gateway)
	#print("Server Started")
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_players)
	multiplayer.multiplayer_peer = peer
	multiplayer.server_relay = true
	
	
	
	
	
#@rpc("any_peer")
func Peer_Connected(player_id):
	print("User "+str(player_id)+" connected")
	#rpc_id(player_id,"recieve_map",map_name)
	#
	#rpc_id(player_id,"recieve_player_data")
	
	#await get_tree().create_timer(1).timeout
	#rpc_id(player_id, "add_previously_connected_player_characters", connected_peer_ids, connected_peer_usernames, connected_peer_colors)
	#
	#rpc("add_newly_connected_player_character", player_id)
	#add_player_character(player_id,most_recent_color,most_recent_username)
	rpc_id(player_id,"recieve_player_data",player_id)
	
@rpc
func recieve_player_data():
	pass

@rpc("any_peer")
func send_player_data(player_id,color,username):
		
	
	rpc_id(int(player_id),"recieve_map",map_name)
	
	
	rpc_id(int(player_id), "add_previously_connected_player_characters", connected_peer_ids, connected_peer_usernames, connected_peer_colors)
	
	connected_peer_ids.append(player_id)
	connected_peer_colors.append(color)
	connected_peer_usernames.append(username)
	
	rpc("add_newly_connected_player_character", player_id,connected_peer_colors[-1])
	add_player_character(player_id,color,username)
	
		
func Peer_Disconnected(player_id):
	print("User "+str(player_id)+" disconnected")
	
	
@rpc('any_peer', 'call_remote', 'reliable')
func recieve_map(map):
	print(map)
	
	
	
func add_player_character(peer_id,color,username):
	#connected_peer_ids.append(peer_id)
	#connected_peer_usernames.append(username)
	#connected_peer_colors.append(color)
	var player_character = preload("res://player.tscn").instantiate()
	player_character.set_multiplayer_authority(int(peer_id))
	player_character.name = str(player_character.get_multiplayer_authority())
	
	add_child(player_character)
	player_character.color = color
	player_character.username = username
	rpc("update_colors", peer_id)
		
	
@rpc
func add_newly_connected_player_character(new_peer_id, color):
	pass
	
@rpc
func add_previously_connected_player_characters(peer_ids,peer_names,peer_colors):
	pass
	
@rpc("any_peer")
func remove_player(player_id):
	#if get_tree().get_multiplayer().has_peer(player_id):
	network.disconnect_peer(player_id)
	print("Player kicked with ID: " + str(player_id))
	rpc("remove_other_player",player_id)
	for player in get_children():
		if player.get_multiplayer_authority() == player_id:
			player.queue_free()
			break
	for i in connected_peer_ids.size():
		if int(connected_peer_ids[i]) ==  player_id:
			connected_peer_ids.pop_at(i)
			break
			
@rpc
func remove_other_player(player_id):
	pass

@rpc
func kill_player(player_id):
	pass

@rpc
func knockback_player(player_id):
	pass

@rpc
func update_colors(player_id):
	pass
	
@rpc("any_peer")
func send_rocket(direction, position,target,fly_direction,player_name):
	print(direction)
	rpc("send_rocket",direction, position,target,fly_direction,player_name)





@rpc	
func update_cosmetics():
	pass
