extends CharacterBody3D

@export var camara: Camera3D
@export var speed = 3.0
@onready var anim = $Modelo/AnimationPlayer

var multiplicador = 1.0
var empuje = Vector3.ZERO
var accion = ""

func _ready():
	if camara == null:
		camara = get_viewport().get_camera_3d()

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var entrada = Vector3(input_dir.x, 0.0, input_dir.y)

	var direction = (camara.global_basis * entrada)
	direction.y = 0.0
	direction = direction.normalized()

	velocity.x = direction.x * speed * multiplicador + empuje.x
	velocity.z = direction.z * speed * multiplicador + empuje.z

	if direction.length() > 0:
		basis = Basis.looking_at(direction)

	move_and_slide()

	if velocity.length() > 0.1:
		anim.play("walk")
	else:
		anim.play("idle")
