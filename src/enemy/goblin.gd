extends CharacterBody2D

const ENEMY_ATTACK_AREA:PackedScene = preload("res://src/enemy/enemy_attack_area_2d_scene.tscn")

@onready var texture:Sprite2D = get_node("Texture")
@export var move_speed:float = 190.0  #ligeiramente menor que a nossa
@onready var animation:AnimationPlayer = get_node("Animation")
@export var distance_treshold:float = 60.0
@onready var colision:CollisionShape2D = get_node("Collision") 
@onready var goblin:CharacterBody2D = get_node("Goblin")
#trazendo de knight
var player_ref:CharacterBody2D = null #a referência do cavaleiro
@export var damage: int = 1
@export var health:int = 3
var can_attack:bool = true 
var can_die:bool = false

@onready var aux_animation: AnimationPlayer = get_node("AuxiliaryAnimation")

func _physics_process(_delta):
	if can_die:
		return
	
	if player_ref == null or player_ref.can_die: #se nosso personagem morre, ele para
		velocity = Vector2.ZERO #garantir que vai voltar para idle
		animate()
		return
	
	var direction: Vector2 = global_position.direction_to(player_ref.global_position) #já vem normalizada
	var distance: float = global_position.distance_to(player_ref.global_position)
	#print(distance)
	
	velocity = move_speed * direction
	animate(distance)
	move_and_slide()
	
	
func spawn_attack_area()->void:
	var attack_area = ENEMY_ATTACK_AREA.instantiate()
	'''bug
	#attack_area.position = position + Vector2(0,28) #a posição de nossa área de ataque será a posição do gobin + um offset referente á posição da colisão 
	#attack_area.position = position + colision.position #código melhorado: a posição de nossa área de ataque será a posição do gobin + um offset referente á posição da colisão 
	#se usarmos só position no offset ele vai pegar a posição do goblin no plano e somar o offsef, o que vai deslocar muito a área de ataque
	#omitimos position, pq como o script é de goblin ele já roda sobre o objeto correto
	'''
	attack_area.position =  colision.position
	add_child(attack_area)

func animate(distance:float = distance_treshold)-> void:
	#flip
	if velocity.x >0 :
		texture.flip_h = false
	if velocity.x<0:
		texture.flip_h = true
	#atacar
	if distance < distance_treshold:
		animation.play("attack")
		return
	#perseguir
	if velocity != Vector2.ZERO:
		animation.play("run")
		return
	#parado
	animation.play("idle")

func _on_detection_area_body_entered(body):
	player_ref = body


func _on_detection_area_body_exited(_body): #o _ nas variáveis de função serve para comentar o que nao é usado
	player_ref = null


func update_health(damage:int)->void:
	health-=damage
	if health<=0:
		can_die = true
		animation.play("death")
		#attack_area_colision.disabled = true #desabilitando a colisão ao morrer
		#attack_area_colision.set_deferred("disabled",true) #desabilitando a colisão ao morrer de outra maneira
		print("Enemy Died!")
		return
	
	aux_animation.play("hit")
		


func _on_animation_animation_finished(anim_name:String) -> void:
	if anim_name == "death":
		queue_free()#exclui o inimigo apos a morte
	
