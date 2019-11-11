var queue_array:=Array()
var cur
var cur_index=0
var last
func set_queue(arr:=Array()):
    queue_array=arr
    
func get_random_next():
    randomize()
    cur_index=randi() % queue_array.size()
    cur=queue_array[cur_index]
    last=cur
    return cur

func get_next():
    cur_index+=1
    cur=queue_array[cur_index]
    last=cur
    return cur

func get_one():
    last=queue_array[cur_index]
    
    if cur_index+1<len(queue_array):
        cur_index+=1
        cur=queue_array[cur_index]
    return last
