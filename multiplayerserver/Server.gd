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


func _input(event: InputEvent) -> void:
	pass
	#if Input.is_action_just_pressed("ui_accept"):
		##debugging features
		#print()
		#print(multiplayer.get_peers())
		#for peer in connected_peer_ids:
			#if multiplayer.get_peers().count(peer) <= 0:
				#print(str(peer)+ " kicked")
				#kick_player(peer)

@rpc
func test_connection():
	pass


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
	rpc_id(player_id,"recieve_map",map_name)
	
	#rpc_id(player_id,"recieve_player_data")
	
	#await get_tree().create_timer(1).timeout
	rpc_id(player_id, "add_previously_connected_player_characters", connected_peer_ids, connected_peer_usernames, connected_peer_colors)
	
	rpc("add_newly_connected_player_character", player_id)
	add_player_character(player_id)
	
	rpc_id(player_id, "recieve_player_data",player_id)
	#rpc_id(player_id,"recieve_player_data",player_id)
	
@rpc
func recieve_player_data():
	pass

@rpc("any_peer","reliable")
func send_player_data(player_id,color,username):
		
	
	#rpc_id(int(player_id),"recieve_map",map_name)
	
	
	#rpc_id(int(player_id), "add_previously_connected_player_characters", connected_peer_ids, connected_peer_usernames, connected_peer_colors)
	
	#connected_peer_ids.append(player_id)
	
	for player in get_children():
		if str(player_id) == player.name:
			player.color = color
			player.username = username
	
	connected_peer_colors.append(color)
	connected_peer_usernames.append(username)
	print("Sent player data")
	rpc("server_message", username + " joined the game")
	rpc("update_colors",connected_peer_ids,connected_peer_colors)
	#rpc("add_newly_connected_player_character", player_id)
	#await get_tree().create_timer(1).timeout
	#add_player_character(player_id)
	
	
		
func Peer_Disconnected(player_id):
	print("User "+str(player_id)+" disconnected")
	
	
@rpc('any_peer', 'call_remote', 'reliable')
func recieve_map(map):
	print(map)
	
	
	
func add_player_character(peer_id):
	#connected_peer_ids.append(peer_id)
	#connected_peer_usernames.append(username)
	#connected_peer_colors.append(color)
	var player_character = preload("res://Objects/player.tscn").instantiate()
	player_character.set_multiplayer_authority(int(peer_id))
	player_character.name = str(player_character.get_multiplayer_authority())
	#player_character.color = color
	#player_character.username = username
	#player_character.text = username
	add_child(player_character)
	connected_peer_ids.append(peer_id)
	#rpc("update_colors", peer_id)
	#print("Adding player: "+str(peer_id)+" With color: "+ str(color))
		
	
@rpc
func add_newly_connected_player_character(new_peer_id):
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
			connected_peer_colors.pop_at(i)
			rpc("server_message",str(connected_peer_usernames.pop_at(i)) + " left the game.")
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
func update_colors(player_ids,player_colors):
	pass
	
@rpc("any_peer")
func send_rocket(direction, position,target,fly_direction,player_name):
	print(direction)
	rpc("send_rocket",direction, position,target,fly_direction,player_name)
	
@rpc("any_peer")
func send_grenade(direction, position,target,fly_direction,player_name):
	print(direction)
	rpc("send_grenade",direction, position,target,fly_direction,player_name)

@rpc("any_peer")
func send_fireball(direction, position,target,fly_direction,player_name):
	print(direction)
	rpc("send_fireball",direction, position,target,fly_direction,player_name)


func kick_player(player_id):
	rpc("remove_other_player",str(player_id))
	get_node(str(player_id)).queue_free()
	for i in connected_peer_ids.size():
		if str(player_id) == str(connected_peer_ids[i]):
			connected_peer_ids.pop_at(i)
			connected_peer_colors.pop_at(i)
			
			rpc("server_message",str(connected_peer_usernames.pop_at(i)) + " left the game.")
			break

@rpc	
func update_cosmetics():
	pass

@rpc("any_peer")
func broadcast_chat(player_name,text):
	rpc("new_chat",player_name,text)

@rpc
func new_chat(player_name,text):
	pass

@rpc
func damage_player(damage,to,from):
	pass

@rpc("any_peer","call_local","reliable")
func hit_player(damage,to,from):
	rpc("damage_player",damage,to,from)
	
@rpc("any_peer","reliable")
func frag(to,from = "1"):
	print(get_username(from)+ " fragged "+get_username(to))
	
	if from == "1":
		get_node(to).kills -=1
	elif from == to or from == null:
		get_node(to).kills -=1
	else:
		get_node(from).kills +=1
	
	var connected_peers_copy = connected_peer_ids.duplicate(true)
	var sorted_frags = []
	var sorted_names = []
	var sorted_colors = []
	
	while connected_peers_copy.size() > 0:
		var most_frags = get_children()[0].kills
		var most_index =0
		for i in connected_peers_copy.size():
			if get_children()[i].kills >= most_frags:
				most_frags = get_child(i).kills
				most_index = i
		
		sorted_colors.append(connected_peer_colors[most_index])
		sorted_names.append(connected_peer_usernames[most_index])
		sorted_frags.append(get_child(most_index).kills)
		connected_peers_copy.pop_at(most_index)
	rpc("server_message",(get_username(str(to))+ " was killed by "+get_username(str(from))))
			
		
	rpc("update_scoreboard",sorted_names,sorted_colors,sorted_frags)

@rpc
func update_scoreboard(name_array,color_array,frag_array):
	pass

func check_for_disconnects():
	for peer in connected_peer_ids:
			if multiplayer.get_peers().count(peer) <= 0:
				print(str(peer)+ " kicked")
				kick_player(peer)
				
@rpc
func server_message(message):
	pass	

func get_username(player_id):
	for player in get_children():
		if player.is_in_group("Player") and player.name == str(player_id):
			return player.username
	return "no name"		
