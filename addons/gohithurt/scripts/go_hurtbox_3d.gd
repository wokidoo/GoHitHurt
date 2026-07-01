@tool
@icon("res://addons/gohithurt/icons/go_hurtbox_3d.svg")
class_name GoHurtbox3D extends Area3D
## A detectable region that receives hits from a [GoHitbox3D].
##
## A hurtbox is passive: it performs no scanning of its own. It is
## [member Area3D.monitorable] so a [GoHitbox3D]'s shape cast can find it, and
## it reacts only when that hitbox calls [method receive_hit]. On a valid hit it
## re-emits the collision data through [signal hit_detected] for game code
## (health, damage, reactions) to consume.

## Whether the hurtbox responds to hits. While disabled, [method receive_hit]
## returns early without emitting, and the node's [member Node.process_mode] is
## set to [constant Node.PROCESS_MODE_DISABLED].
## [br][b]Note:[/b] a disabled hurtbox is still [member Area3D.monitorable], so a
## [GoHitbox3D] can still detect it; the hit is simply ignored on arrival rather
## than prevented at the shape-cast level.
@export var enabled:bool = true:
	set(val):
		enabled = val
		set_physics_process(enabled)
		if enabled:
			process_mode = Node.PROCESS_MODE_INHERIT
		else:
			process_mode = Node.PROCESS_MODE_DISABLED
## Emitted when this hurtbox accepts a hit. [param collision] is the dictionary
## forwarded by [GoHitbox3D], including its [code]source[/code] key and any
## merged [member GoHitbox3D.hit_data].
signal hit_detected(collision:Dictionary)

func _init() -> void:
	monitoring = false
	monitorable = true

func _validate_property(property: Dictionary) -> void:
	if property.name == "monitoring" or property.name == "monitorable":
		property.usage |= PropertyUsageFlags.PROPERTY_USAGE_READ_ONLY

## Called by a [GoHitbox3D] when it overlaps this hurtbox. Emits
## [signal hit_detected] with [param collision] when [member enabled] is
## [code]true[/code]; otherwise does nothing.
func receive_hit(collision:Dictionary)->void:
	if not enabled:
		return
	hit_detected.emit(collision)

## Enables the hurtbox so it responds to hits again.
func enable():
	enabled = true
## Disables the hurtbox so incoming hits are ignored.
func disable():
	enabled = false
## Enables the hurtbox for [param duration] seconds, then disables it.
## [br][b]Note:[/b] asynchronous; awaits a [SceneTreeTimer].
func enable_temporarily(duration:float = 1.0)->void:
	enabled = true
	await get_tree().create_timer(duration).timeout
	enabled = false
## Disables the hurtbox for [param duration] seconds, then re-enables it.
## [br][b]Note:[/b] asynchronous; awaits a [SceneTreeTimer].
func disable_temporarily(duration:float = 1.0)->void:
	enabled = false
	await get_tree().create_timer(duration).timeout
	enabled = true
