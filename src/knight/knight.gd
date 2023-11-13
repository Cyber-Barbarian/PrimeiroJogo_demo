extends CharacterBody2D

@onready var animation: AnimationPlayer = get_node("Animation")
@onready var texture:Sprite2D = get_node("Texture")
@onready var attack_area_colision: CollisionShape2D = get_node("AttackArea/Collision")
@onready var aux_animation: AnimationPlayer = get_node("AuxiliarAnimation")

@export var damage: int = 1
@export var move_speed:float = 256.0
@export var health:int = 5

var can_attack:bool = true 
var can_die:bool = false

func _physics_process(_delta: float) -> void:
	if (can_attack == false or can_die):
		return
	
	move()
	animate()
	attack_handler()

func move()->void:
	#estabelecendo direção
	var direction: Vector2 = get_direction()
	#print(direction.length())
	#velocity é palavra reservada. também é um vetor 2d
	velocity = direction * move_speed
	move_and_slide() #método nativo de CharacterBody2d
	
func get_direction() -> Vector2:
	return Vector2 (
		Input.get_axis("ui_left","ui_right"),
		Input.get_axis("ui_up","ui_down")
	).normalized()

func animate() -> void:
	#print(velocity.x)
	if velocity.x<0:
		texture.flip_h=true
		attack_area_colision.position.x = -56
	if velocity.x>0:
		texture.flip_h=false
		attack_area_colision.position.x = 56
		
	if velocity != Vector2.ZERO:
		animation.play("run")
		return	
	animation.play("idle")

func attack_handler() -> void:
	if Input.is_action_just_pressed("space_bar") and can_attack:
		can_attack = false
		animation.play("attack")
		






func _on_animation_finished(anim_name:String) -> void: #esse sinal vai rodar no fim de cada animação
	match anim_name:
		"attack":
			can_attack=true
		"death":
			get_tree().reload_current_scene()#reset após a morte

func _on_attack_area_body_entered(body:Node2D) -> void:
	#essa função notifica qualquer corpo que entre na área 
	body.update_healt(damage)

func update_healt(damage:int)->void:
	health-=damage
	if health<=0:
		can_die = true
		animation.play("death")
		#attack_area_colision.disabled = true #desabilitando a colisão ao morrer
		attack_area_colision.set_deferred("disabled",true) #desabilitando a colisão ao morrer de outra maneira
		print("You Died!")
		return
	
	aux_animation.play("hit")
		
