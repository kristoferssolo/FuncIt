extends KinematicBody2D

const GRAVITY = 5

var liftSpeed = 0
var accelerationSpeed = 2
var deccelerationSpeed = 20
var maxSpeed = 250

var worldSpace2d = null
var coreRay = {}

var bullet = preload("res://source/entities/ts_bot/Bot_Bullet.tscn")

var desiredLocation = Vector2(0,0)
var movementVector = Vector2(0,0)
var weightVector = Vector2(0,0)
var interactionRays = []
var degreeTracker

var startVector = Vector2(0,5)
var startPosition = Vector2(0,5)
var maxRay = 65
var interactionRay = null

var degreeStep = 60
var fireRate = 12
var time = 0
var rotationAmount = 0
var rand_generate = RandomNumberGenerator.new()

var timer = 15
var hp = 50

var activeHitBoost = Vector2(0,0)

export(int, "Passive", "Friendly", "Agressive") var Mode

func _ready():
	desiredLocation = position
	startVector += global_position
	pass

func _physics_process(delta):
	Global.set('bot_weapon', self)
	time += delta
	timer += delta
	rand_generate.randomize()
	get_interaction()
	if interactionRays[0]["interacted"]: 
		if liftSpeed > 0: liftSpeed = move_toward(liftSpeed, 0, deccelerationSpeed)
	elif position.y - desiredLocation.y > 1: 
		liftSpeed -= accelerationSpeed
	elif position.y - desiredLocation.y  < -1: 
		liftSpeed += GRAVITY
	for ray in interactionRays:
		if ray["interacted"]:
			liftSpeed += -ray["end"].normalized().y *  maxSpeed
	liftSpeed = clamp(liftSpeed, -maxSpeed, maxSpeed)
# warning-ignore:return_value_discarded
	move_and_slide(Vector2(0,liftSpeed))
	if Mode == 0:
		$ts_bot_sprite.play("passive_idle")
		$TsBotSpriteWeaponOn.hide()
		$TsBotSpriteWeaponOff.hide()
	elif Mode == 1:
		$ts_bot_sprite.play("friendly_idle")
		$TsBotSpriteWeaponOn.hide()
		$TsBotSpriteWeaponOff.show()
	elif Mode == 2:
		if fireRate < 20: fireRate = 5*fireRate
		$ts_bot_sprite.play("agressive_idle")
		$TsBotSpriteWeaponOn.show()
		$TsBotSpriteWeaponOff.hide()
	if time > 60 / fireRate and Mode >= 1:
		rotationAmount = rand_generate.randi_range(1,36)
		$TsBotSpriteWeaponOff.rotation = 360/rotationAmount
		$TsBotSpriteWeaponOn.rotation = 360/rotationAmount
		time = 0
		shoot_bot()
	move_and_slide(activeHitBoost)
	activeHitBoost = Vector2(move_toward(activeHitBoost.x, 0, 2), move_toward(activeHitBoost.y, 0, 2))

func get_interaction():
	degreeTracker = 0
	interactionRays = []
	worldSpace2d = get_world_2d().direct_space_state
	if time > 5 and Mode == 0: Mode = 1
	while degreeTracker < 360 + degreeStep:
		interactionRay = worldSpace2d.intersect_ray(startVector, Vector2(0,maxRay).rotated(deg2rad(degreeTracker)) + global_position, [self])
		var interacted = false
		if "position" in interactionRay and interactionRay["collider"].is_in_group("Player"):
			interacted = true
			if timer > 15: 
				Mode += 1
				timer = 0
		interactionRays.append({"start": startVector, "end": Vector2(0,maxRay).rotated(deg2rad(degreeTracker)) + global_position, "degrees": degreeTracker,"ray": interactionRay, "interacted": interacted})
		degreeTracker += degreeStep

func shoot_bot():
	var b = bullet.instance()
	get_parent().add_child(b)
	b.global_position = self.global_position
	b.global_rotation = 360/rotationAmount - 180

func hit_by_damager(damage, b_rotation, b_velocity):
	hp -= damage
	$HUD/health_bar.value = hp
	activeHitBoost = b_velocity.rotated(b_rotation)*250
	Mode = 2
	if hp <= 0:
		queue_free()
		get_tree().call_group("bot_listener", "bot_died")
