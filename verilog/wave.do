onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_ac/clk
add wave -noupdate /tb_ac/reset
add wave -noupdate /tb_ac/p_out
add wave -noupdate /tb_ac/in
add wave -noupdate /tb_ac/weightin
add wave -noupdate -radix sfixed /tb_ac/out
add wave -noupdate /tb_ac/out_en
add wave -noupdate /tb_ac/bias
add wave -noupdate /tb_ac/bound_level
add wave -noupdate /tb_ac/step
add wave -noupdate /tb_ac/en
add wave -noupdate /tb_ac/en_relu
add wave -noupdate /tb_ac/en_mp
add wave -noupdate /tb_ac/i
add wave -noupdate /tb_ac/j
add wave -noupdate /tb_ac/A0/weight
add wave -noupdate /tb_ac/A0/bias
add wave -noupdate /tb_ac/A0/bound_level
add wave -noupdate /tb_ac/A0/step
add wave -noupdate /tb_ac/A0/en
add wave -noupdate /tb_ac/A0/en_relu
add wave -noupdate /tb_ac/A0/clk
add wave -noupdate /tb_ac/A0/reset
add wave -noupdate /tb_ac/A0/en_mp
add wave -noupdate /tb_ac/A0/in
add wave -noupdate /tb_ac/A0/P0/in
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_ac/A0/P0/inp
add wave -noupdate /tb_ac/A0/P0/b_out
add wave -noupdate /tb_ac/A0/out_pe
add wave -noupdate /tb_ac/A0/en_mp_d2
add wave -noupdate /tb_ac/A0/out_relu
add wave -noupdate /tb_ac/A0/out
add wave -noupdate /tb_ac/A0/out_en
add wave -noupdate /tb_ac/A0/out_en_pe
add wave -noupdate /tb_ac/A0/en_relu_d
add wave -noupdate /tb_ac/A0/en_relu_d2
add wave -noupdate /tb_ac/A0/en_mp_d
add wave -noupdate /tb_ac/A0/P0/weight
add wave -noupdate /tb_ac/A0/P0/bias
add wave -noupdate /tb_ac/A0/P0/out
add wave -noupdate /tb_ac/A0/P0/clk
add wave -noupdate /tb_ac/A0/P0/reset
add wave -noupdate /tb_ac/A0/P0/wei
add wave -noupdate /tb_ac/A0/P0/mulout
add wave -noupdate /tb_ac/A0/P0/d_mulout
add wave -noupdate /tb_ac/A0/P0/addout
add wave -noupdate /tb_ac/A0/P0/addout_1
add wave -noupdate /tb_ac/A0/P0/en
add wave -noupdate /tb_ac/A0/P0/en_d
add wave -noupdate /tb_ac/A0/P0/bound_level
add wave -noupdate /tb_ac/A0/P0/bound_level_d
add wave -noupdate /tb_ac/A0/P0/step
add wave -noupdate /tb_ac/A0/P0/step_d
add wave -noupdate /tb_ac/A0/P0/uxor
add wave -noupdate /tb_ac/A0/P0/p_step
add wave -noupdate /tb_ac/A0/P0/mux_f_s
add wave -noupdate /tb_ac/A0/P0/out_en
add wave -noupdate /tb_ac/A0/P0/adder_final_B
add wave -noupdate /tb_ac/A0/P0/adder_final_out
add wave -noupdate /tb_ac/A0/m0/in
add wave -noupdate /tb_ac/A0/m0/en
add wave -noupdate /tb_ac/A0/m0/en_mp
add wave -noupdate /tb_ac/A0/m0/clk
add wave -noupdate /tb_ac/A0/m0/reset
add wave -noupdate /tb_ac/A0/m0/out
add wave -noupdate /tb_ac/A0/m0/out_en
add wave -noupdate /tb_ac/A0/m0/en_count
add wave -noupdate /tb_ac/A0/m0/en2
add wave -noupdate /tb_ac/A0/m0/comparator_out
add wave -noupdate /tb_ac/A0/m0/mux_out
add wave -noupdate /tb_ac/A0/m0/count
add wave -noupdate /tb_ac/A0/m0/count_out
add wave -noupdate /tb_ac/A0/m0/com_en_and
add wave -noupdate /tb_ac/A0/m0/mux_in_s
add wave -noupdate /tb_ac/A0/m0/mux_in
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {229740 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {195920 ps} {273840 ps}
