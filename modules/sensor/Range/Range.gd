extends RayCast3D

class_name RangeSensor

@export var _timer:Timer
@export var _range_publisher:RangePublisher

var vehicle:Vehicle = null:
	set(_vehicle):
		vehicle = _vehicle
		if name.is_empty():
			return
		if not vehicle:
			return 
		if not vehicle.Setting:
			return 
		if not vehicle.Setting.sensors.has(name):
			return 
		var sensor_setting:SimulatorSettings.Sensor = vehicle.Setting.sensors[name]
		if not sensor_setting.type == SimulatorSettings.SENSOR_TYPE.RANGE:
			return 
		
		position = sensor_setting.location
		target_position = sensor_setting.rotation * Vector3(sensor_setting.range_distance, 0.0, 0.0)
		
		_range_publisher.domain_id = vehicle.Setting.domain_id
		_range_publisher.topic_name = vehicle.Setting.name + "/" + name
		_range_publisher.max_range = sensor_setting.range_distance
		_range_publisher.initialize()
		
		_timer.wait_time = 1.0 / sensor_setting.hz
		
func _on_publish_timer_timeout():
	_range_publisher.publish((get_collision_point() - global_position).length())
	pass
