#do file Car_Parking_System.vhd

quit -sim
vsim -t ns work.car_parking_system_vhdl(behavioral)

add wave -divider "Inputs:"
add wave -label "Clock" -color blue clk
add wave -label "Reset" -color "magenta" reset
add wave -label "Front Sensor" -color "cyan" front_sensor 
add wave -label "Back Sensor" -color "cyan" back_sensor
add wave -label "Password" -color "yellow" password

add wave -divider "Signals:"
add wave -label "Current State" -color "orange" current_state
add wave -label "Next State" -color "purple" next_state
add wave -label "Car Count" -color "white" car_count

add wave -divider "Outputs:"
add wave -label "Green LED" -color "Forest Green" GREEN_LED
add wave -label "Red LED" -color "Red" RED_LED


force clk 0 0, 1 {5 ns} -r 10
force front_sensor 1
force back_sensor 0
force reset 1

## First car
force password 00
run 25 ns
force password 01
run 20 ns

## Second and third car
force password 01
run 10 ns
force back_sensor 1
run 20 ns
force back_sensor 0
run 20 ns

## Fourth and fifth car
force password 01
run 10 ns
force back_sensor 1
run 20 ns
force password 11
run 20 ns
force back_sensor 0
force password 01
run 20 ns

## Sixth car
force back_sensor 1
run 30 ns
force back_sensor 0
force password 01
run 30 ns