var queue_array:=Array()
var cur
var cur_index=0
func set_queue(arr:=Array()):
    queue_array=arr
    
func get_random_next():
    randomize()
    cur_index=randi() % queue_array.size()
    cur=queue_array[cur_index]
    return cur

func get_next():
    cur_index+=1
    cur=queue_array[cur_index]
    return cur
