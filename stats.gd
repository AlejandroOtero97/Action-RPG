extends Node

signal no_health
signal health_changed(value)
signal max_health_changed(value)

@export var max_health = 1: set = set_max_health

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

var health = max_health:
	get: 
		return health
	set(value): 
		health = value
		emit_signal("health_changed", health)
		if health <= 0:
			emit_signal("no_health")

func _ready():
	self.health = max_health