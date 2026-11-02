extends CharacterBody3D

enum Estado { QUIETO, CAMINAR, CORRER, AIRE }
const RUIDO = [0.0, 1.2, 4.5, 0.0]

@export var camara: Camera3D
@export var speed_caminar = 3.0
@export var speed_correr = 5.2
@export var tiempo_arranque = 0.30
@onready var anim = $Modelo/AnimationPlayer

var multiplicador = 1.0
var empuje = Vector3.ZERO
var accion = ""
var avance = Vector3.ZERO

var estado = Estado.QUIETO
var ruido = 0.0

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

	var objetivo = direction * speed * multiplicador
	var paso = speed / tiempo_arranque * delta
	avance = avance.move_toward(objetivo, paso)

	velocity.x = avance.x + empuje.x
	velocity.z = avance.z + empuje.z

	if direction.length() > 0:
		basis = Basis.looking_at(direction)

	move_and_slide()

	var antes = estado
	estado = elegir_estado()
	ruido = RUIDO[estado]
	if estado != antes:
		print("estado ", Estado.keys()[estado], " Â· ruido ", ruido, " m")
	animar()

func elegir_estado():
	if not is_on_floor():
		return Estado.AIRE
	var rapidez = Vector2(velocity.x, velocity.z).length()
	if rapidez < 0.1:
		return Estado.QUIETO
	if rapidez > speed_caminar + 0.1:
		return Estado.CORRER
	return Estado.CAMINAR

func animar():
	if accion != "":
		anim.play(accion)
		return
	match estado:
		Estado.QUIETO: anim.play("idle")
		Estado.CAMINAR: anim.play("walk")
		Estado.CORRER: anim.play("sprint")
		Estado.AIRE: anim.play("fall")
