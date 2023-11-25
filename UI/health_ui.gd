extends Control

var hearts = 4: set = set_hearts
var max_hearts = 4: set = set_max_hearts
var stats = PlayerStats

@onready var heart_ui_empty = $HeartUiEmpty
@onready var heart_ui_full = $HeartUiFull


func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heart_ui_full != null:
		heart_ui_full.size.x = value * 15
		
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heart_ui_empty != null:
		heart_ui_empty.size.x = value * 15
	
func _ready():
	self.max_hearts = stats.max_health
	self.hearts = stats.health
	self.stats.connect("health_changed", set_hearts)
	self.stats.connect("max_health_changed", set_max_hearts)
