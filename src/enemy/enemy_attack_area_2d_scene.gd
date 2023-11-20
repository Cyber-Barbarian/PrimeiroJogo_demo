extends Area2D

@export var damage:int = 1

func _on_body_entered(body) -> void:
	body.update_health(damage) # body e necessariamente o corpo do nosso personagem por conta de amsk 1

func _on_lifetime_timeout():
	queue_free()#exclui toda a EnemyAttackArea2D após o timeout
