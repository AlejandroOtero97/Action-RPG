extends CharacterBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

@export var ACCELERATION = 300
@export var MAX_SPEED = 25
@export var FRICTION = 200
@export var WANDER_TARGET_RANGE = 4

@onready var sprite = $AnimatedSprite
@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var hurtbox = $HurtBox
@onready var soft_collision = $SoftCollision
@onready var wander_controller = $WanderController
@onready var animation_player = $AnimationPlayer


enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

func _ready():
	randomize()
	sprite.frame = randf_range(0, sprite.sprite_frames.get_frame_count("Fly")-1)
	state = pick_random_state([IDLE, WANDER, WANDER])

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			
		WANDER:
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
				
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
			
	if soft_collision.is_colliding():
		velocity += soft_collision.get_pushed_vector() * delta * 400
	move_and_slide()
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0
	
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.set_wander_timer(randf_range(1, 3))

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_hurt_box_area_entered(area):
	stats.health -= area.damage
	if "position" in area.owner:
		var direction = ( position - area.owner.position ).normalized()
		velocity = direction * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_hurt_box_invincibility_started():
	animation_player.play("Start")

func _on_hurt_box_invincibility_ended():
	animation_player.play("Stop")
