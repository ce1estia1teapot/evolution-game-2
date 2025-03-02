extends Node3D

@onready var n_particle_effects : GPUParticles3D = $Particles/SpiralParticles

func _ready() -> void:
	n_particle_effects.restart()
