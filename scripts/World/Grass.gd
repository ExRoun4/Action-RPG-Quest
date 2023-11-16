extends Node2D

func _on_AnimatedSprite_animation_finished():
	queue_free()

func _on_Hitbox_area_entered(area):
	if area.collision_layer == 2 and area.name == "AttackRange":
		$AnimatedSprite.play("Destroyed")
