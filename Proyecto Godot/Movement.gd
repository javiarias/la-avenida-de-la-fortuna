extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ady_Banco = ["Central_1", "Central_2", "Central_3", "Central_4"]

var ady_Central_1 = ["Central_Conexion_1", "Central_Conexion_3", "Banco"]
var ady_Central_2 = ["Central_Conexion_1", "Central_Conexion_2", "Banco"]
var ady_Central_3 = ["Central_Conexion_2", "Central_Conexion_3", "Banco"]
var ady_Central_4 = ["Central_Conexion_3", "Central_Conexion_4", "Banco"]

var ady_Central_Conexion_1 = ["1_1", "1_2", "Central_1", "Central_2"]
var ady_Central_Conexion_2 = ["2_1", "2_2", "Central_2", "Central_3"]
var ady_Central_Conexion_3 = ["3_1", "3_2", "Central_3", "Central_4"]
var ady_Central_Conexion_4 = ["4_1", "4_2", "Central_4", "Central_1"]

var ady_1_1 = ["Central_Conexion_1", "1_4"]
var ady_1_2 = ["Central_Conexion_1", "1_3"]
var ady_1_3 = ["Peaje_1_2", "1_2", "1_6"]
var ady_1_4 = ["Peaje_1_4", "1_1", "1_5"]
var ady_1_5 = ["Palo_1", "1_4"]
var ady_1_6 = ["Palo_1", "1_3"]

var ady_2_1 = ["Central_Conexion_2", "2_4"]
var ady_2_2 = ["Central_Conexion_2", "2_3"]
var ady_2_3 = ["Peaje_2_2", "2_2", "2_6"]
var ady_2_4 = ["Peaje_2_4", "2_1", "2_5"]
var ady_2_5 = ["Palo_2", "2_4"]
var ady_2_6 = ["Palo_2", "2_3"]

var ady_3_1 = ["Central_Conexion_3", "3_4"]
var ady_3_2 = ["Central_Conexion_3", "3_3"]
var ady_3_3 = ["Peaje_3_2", "3_2", "3_6"]
var ady_3_4 = ["Peaje_3_4", "3_1", "3_5"]
var ady_3_5 = ["Palo_3", "3_4"]
var ady_3_6 = ["Palo_3", "3_3"]

var ady_4_1 = ["Central_Conexion_4", "4_4"]
var ady_4_2 = ["Central_Conexion_4", "4_3"]
var ady_4_3 = ["Peaje_4_2", "4_2", "4_6"]
var ady_4_4 = ["Peaje_4_4", "4_1", "4_5"]
var ady_4_5 = ["Palo_4", "4_4"]
var ady_4_6 = ["Palo_4", "4_3"]

var ady_Peaje_1_2 = ["1_3", "2_4"]
var ady_Peaje_2_3 = ["2_3", "3_4"]
var ady_Peaje_3_4 = ["3_3", "4_4"]
var ady_Peaje_4_1 = ["4_3", "1_4"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
