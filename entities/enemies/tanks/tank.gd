class_name Tank
extends Enemy

@onready var shooter := $Shooter as Shooter

func get_shooter() -> Shooter:
	return $Shooter

func die() -> void:
	super.die()
	if shooter:
		shooter.die()
	$Explosion/AnimationPlayer.play("default_explosion")
