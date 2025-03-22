extends RigidBody3D

func _ready():
	self.transform = Transform3D.IDENTITY  # Reset transform to avoid physics bugs
