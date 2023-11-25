extends CharacterBody2D

const PlayerHurtSound = preload("res://Player/player_hurt_sound.tscn")

@export var ACCELERATION = 500
@export var MAX_SPEED = 80
@export var ROLL_SPEED = 125
@export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var roll_vector = Vector2.RIGHT
var stats = PlayerStats

@onready var animation_player = %AnimationPlayer
@onready var animation_tree = %AnimationTree
@onready var animationState = animation_tree.get("parameters/playback")
@onready var hurtbox = $HurtBox
@onready var blink_animation_player = $BlinkAnimationPlayer


func _ready():
	randomize()
	self.stats.connect("no_health", queue_free)

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state(delta):
	animationState.travel("Attack")
	@warning_ignore("integer_division")
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION/2 * delta)
	move_and_slide()
	
func move():
	move_and_slide()
	
func roll_animation_finished():
	state = MOVE
	
func attack_animation_finished():
	state = MOVE

func _on_hurt_box_area_entered(area):
	if hurtbox.invincible == false:
		stats.health -= area.damage
		hurtbox.start_invincibility(0.7)
		hurtbox.create_hit_effect()
		var player_hurt_sound = PlayerHurtSound.instantiate()
		get_tree().current_scene.add_child(player_hurt_sound)
	
func _on_hurt_box_invincibility_started():
	blink_animation_player.play("Start")

func _on_hurt_box_invincibility_ended():
	blink_animation_player.play("Stop")
