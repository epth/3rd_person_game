extends Spatial
var BULLET_SPEED = 30
var BULLET_DAMAGE = 15
const KILL_TIMER = 4
var timer = 0
var hit_something = false
var aim_object=null
var has_look_at=false
var aim_position=null
var origin_global_transform
var has_global_transform=false
var parent_object=null
var attacked_target=null
var has_reparent=false
var enter_times=0

func _ready():
    var body=yield($Area,"body_entered")
    collided(body)
#    $Area.connect("body_entered", self, "collided")
    
func _physics_process(delta):
    timer += delta
    if hit_something:
#        $Area.disconnect("body_entered", self, "collided")
        if (not has_reparent) and is_instance_valid(attacked_target) :
            var last_trs=self.global_transform
            self.get_parent().remove_child(self)
            attacked_target.add_child(self)
#            attacked_target.call_deferred("add_child", self)
            self.global_transform=last_trs
            has_reparent=true
        
        if timer>= KILL_TIMER*2:
            queue_free()
    else:
        var forward_dir
        if aim_position and not has_look_at:
            look_at(get_global_transform().origin*2-aim_position,Vector3(1,1,1))
            has_look_at=true
        forward_dir = global_transform.basis.z.normalized()
        global_translate(forward_dir * BULLET_SPEED * delta)
        
        if timer >= KILL_TIMER:
            queue_free()

func collided(body):
    if hit_something == false:
        if body.has_method("can_be_hit"):
            body.attack_target=parent_object
            body.behit_damage=BULLET_DAMAGE
            #body.be_hit(BULLET_DAMAGE, origin_global_transform)
        attacked_target=body
    hit_something = true
    
