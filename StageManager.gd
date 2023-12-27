extends CanvasLayer


const MAIN = ("res://world.tscn")
const FOREST = ("res://forest.tscn")
const HOUSE = ("res://World/Tscn/house_1.tscn")

func _ready():
	get_node("ColorRect").hide()
	get_node("Label").hide()
	

func changeStage(stage_path):
	get_node("/root/Ui").hide()
	get_node("ColorRect").show()
	get_node("Label").show()
	get_node("Anim").play("TransIN")
	await get_node("Anim").animation_finished
	
	get_tree().change_scene_to_file(stage_path)
	
	get_node("Anim").play("TransOUT")
	get_node("/root/Ui").show()
	await get_node("Anim").animation_finished
	get_node("ColorRect").hide()
	get_node("Label").hide()
	
	
