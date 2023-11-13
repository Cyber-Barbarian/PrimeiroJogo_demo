extends CharacterBody2D

var player_ref:CharacterBody2D = null #a referência do cavaleiro
@export var move_speed:float = 190.0  #ligeiramente menor que a nossa
@onready var animation:AnimationPlayer = get_node("Animation")
@export var distance_treshold:float = 60.0

#trazendo de knight
@export var damage: int = 1
@export var health:int = 3
var can_attack:bool = true 
var can_die:bool = false
@onready var aux_animation: AnimationPlayer = get_node("AuxiliaryAnimation")

func _physics_process(_delta):
	if can_die:
		return
	
	if player_ref == null:
		velocity = Vector2.ZERO #garantir que vai voltar para idle
		animate()
		return
	
	var direction: Vector2 = global_position.direction_to(player_ref.global_position) #já vem normalizada
	var distance: float = global_position.distance_to(player_ref.global_position)
	#print(distance)
	
	velocity = move_speed * direction
	animate(distance)
	move_and_slide()
	
	

func animate(distance:float = distance_treshold)-> void:
	if distance < distance_treshold:
		animation.play("attack")
		return
	if velocity != Vector2.ZERO:
		animation.play("run")
		return
	animation.play("idle")

func _on_detection_area_body_entered(body):
	player_ref = body


func _on_detection_area_body_exited(_body): #o _ nas variáveis de função serve para comentar o que nao é usado
	player_ref = null


func update_healt(damage:int)->void:
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
	
