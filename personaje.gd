extends CharacterBody3D

@export var camara: Camera3D
@export var speed_caminar = 3.0
@export var speed_correr = 5.2
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

	var giro_cam = camara.global_rotation.y
	var direction = entrada.rotated(Vector3.UP, giro_cam).normalized()

	var corre = Input.is_action_pressed("correr")
	var speed = speed_correr if corre else speed_caminar

	velocity.x = direction.x * speed * multiplicador + empuje.x
	velocity.z = direction.z * speed * multiplicador + empuje.z

	if direction.length() > 0:
		basis = Basis.looking_at(direction)

	move_and_slide()

	if velocity.length() > 0.1:
		if corre:
			anim.play("sprint")
		else:
			anim.play("walk")
	else:
		anim.play("idle")
