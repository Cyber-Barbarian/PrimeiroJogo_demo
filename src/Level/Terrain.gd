extends Node2D

const DEFAULT_LAYER:int = 0
const FOAM : PackedScene = preload("res://src/foam/foam.tscn")
var water_used_cells:Array

@onready var grass_tilemap:TileMap = get_node("Grass")
@onready var water_tilemap:TileMap = get_node("Water")
@onready var grass_used_cells: Array

func _ready() -> void:
	#print(grass_tilemap.get_used_rect()) #retângulo que encapsula todo o terreno de grama
	var used_grass_rect: Rect2 = grass_tilemap.get_used_rect()
	grass_used_cells = grass_tilemap.get_used_cells(DEFAULT_LAYER)#lista dos tiles de grama
	#print(grass_used_cells)
	generate_water_tiles(used_grass_rect)
	generate_foam_tiles()
	
func generate_water_tiles(used_rect: Rect2) -> void:
	#loop for pegando os limites do retângulo que encapsula a grama e adicionando +10 pixels à esquerda e à direita, abaixo e acima
	for x in range(used_rect.position.x -10, used_rect.size.x +10):
		for y in range(used_rect.position.y -10, used_rect.size.x +10):
			#condicional para resolver o bug de movimentação
			if grass_used_cells.has(Vector2i(x,y)):
				continue
			
			#print(Vector2(x,y))#podemos ver aqui todos os pontos que devem receber a água
			#set_cell serve para configurar uma célula na mão
			water_tilemap.set_cell(DEFAULT_LAYER,#layer
			Vector2i(x,y),#coordenada preenchida
			DEFAULT_LAYER,#source_id, se olhar no tile de água da pra ver que é 0 
			Vector2i(0,0))#atlas coodinate
			
	water_used_cells = water_tilemap.get_used_cells(DEFAULT_LAYER)#lista das células com  água

func generate_foam_tiles()->void:
	#vamos pegar um terreno de grama e olhar para os 4 vizinhos. se tiver água recebe maré
	for cell in grass_used_cells:
		if check_neighbors(cell):
			#print("spawn foam")
			spawn_foam(cell)
	#print(cell)

func check_neighbors(cell: Vector2i)->bool:
	var left_neighbor = Vector2i(cell.x-1,cell.y)
	var right_neighbor = Vector2i(cell.x+1,cell.y)
	var bottom_neighbor = Vector2i(cell.x,cell.y-1)
	var up_neighbor = Vector2i(cell.x,cell.y+1)
	
	var neighbors_list: Array = [left_neighbor, right_neighbor,up_neighbor,bottom_neighbor]
	
	for neighbor in neighbors_list:
		if water_used_cells.has(neighbor):
			return true
	return false	
		
func spawn_foam(foam_cell:Vector2i)->void:
	var foam = FOAM.instantiate()
	foam.position = foam_cell * 64.0 #posicionando a maré de acordo com a posição da célula(64 px)
	foam.position+=Vector2(32,32)#adicionamos um offset pq a textura da maré está centralizada no original.fizemos aqui pra não mexer lá 
	add_child(foam)
	
