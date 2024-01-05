class_name SuicideCraft
extends Helicopter

@export var objective_damage := 20

func get_shooter() -> Shooter:
	return null

func _ready():
	remove_child(shooter)
	shooter.queue_free()
	shooter = null
	super._ready()

func _process(_delta: float) -> void:
	rotor.global_rotation = anim_sprite.global_rotation
	shadow.global_rotation = anim_sprite.global_rotation

func explode():
	$Explosion/AnimationPlayer.play("default_explosion")
	die_visual_effect()
