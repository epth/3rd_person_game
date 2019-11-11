extends Spatial

onready var monster_scene = preload("res://scene/MonsterBody.tscn")
const spaceing=1.5
func _ready():
    #Global.camera=$Camera
    for i in range(3):
        for j in range(3):
            var clone = monster_scene.instance()
            $Navigation/NavigationMeshInstance.add_child(clone)
            clone.global_transform.origin = $MonsterSpawnPostion.global_transform.origin+Vector3(i,0,j)*spaceing


