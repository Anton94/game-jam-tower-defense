class_name SuicideTank
extends Tank

@export var objective_damage := 20

func get_shooter() -> Shooter:
	return null

func _ready():
	remove_child(shooter)
	shooter.queue_free()
	shooter = null
	super._ready()

func explode():
	$Explosion/AnimationPlayer.play("default_explosion")
	die_visual_effect()
