################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Yasutaka Hisano, 1007739093
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
# screen_grid:
    # .space 16384


##############################################################################
# Mutable Data
##############################################################################
ball_x_speed: .word -1
ball_y_speed: .word 1
player_life: .word 3
speed: .word 200
# screen_grid:
    # .space 16384
    # .word 15232

panel_position: .word 15472

ball_position: .word 15232

panel_color: .word 0xff0000

byte_typed: .word 0
num_typed: .word 0

block1_color: .word 0x00ff00
block1_life: .word 1
block2_color: .word 0xffff00
block2_life: .word 1
block3_color: .word 0x0000ff
block3_color2: .word 0x77c3ec
block3_color3: .word 0xb8e2f2
block3_life: .word 3
block4_color: .word 0xff6600
num_p_pressed: .word 0
block1_row2: .word 0xa020f0
block1_row2_life: .word 1
block2_row2: .word 0x964b00 #brown
block2_row2_life: .word 1
block3_row2: .word 0x90ee90 #light green
block3_row2_life: .word 1
block4_row2: .word 0x717D7E #grey
block4_row2_life: .word 1

block1_row3: .word 0x154360
block1_row3_life: .word 1
block2_row3: .word 0xffc0cb
block2_row3_life: .word 1
block3_row3: .word 0x641E16
block3_row3_life: .word 1
block4_row3: .word 0x186A3B
block4_row3_life: .word 1

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    li $t0 -1
    sw $t0 ball_x_speed
    li $t0 1
    sw $t0 ball_y_speed
    li $t0 15472
    sw $t0 panel_position
    li $t0 15232
    sw $t0 ball_position
    li $t0 60
    sw $t0 speed
    
    li $t1, 0xff0000        # $t1 = red
    li $t2, 0xffffff
    li $t3, 0x00ff00
    
    lw $t0, ADDR_DSPL    # $t0 = base address for display
    addi $t0 $t0 15468
    li $t4 0
    li $t5 9
draw_panel:
    beq $t4 $t5 create_horizontal_wall
    addi $t0 $t0 4
    sw $t1 ($t0)
    addi $t4 $t4 1
    j draw_panel
    
create_horizontal_wall:
    lw $t0, ADDR_DSPL    # $t0 = base address for display
    li $t7 0xffffff
    li $t4 0
    li $t5 64
    lw $t2, ADDR_DSPL
create_horizontal_wall_loop:
    beq $t4 $t5 create_pixel
    addi $t2 $t2 4
    sw $t7 ($t2)
    sw $t7 ($t0)
    addi $t0 $t0 252
    sw $t7 ($t0)
    addi $t0 $t0 4
    addi $t4 $t4 1
    j create_horizontal_wall_loop
create_pixel:
    li $t2, 0xffffff
    lw $t0, ADDR_DSPL    # $t0 = base address for display
    sw $t2, 15232($t0)
    li $t9 0
    lw $a0 block1_color
    lw $a1 block2_color
    lw $a2 block3_color
    lw $a3 block4_color
    lw $s0 block1_life
    lw $s1 block2_life
    lw $s2 block3_life
    # lw $s3 block4_row2_life
create_block_loop:
    lw $t0, ADDR_DSPL 
    addi $t0 $t0 1284
    add $t0 $t0 $t9
    li $t4 0
    li $t5 15
    # lw $t6 block1_color
create_block:
    # lw $t1 block1_life
    beq $s0 0 create_block2
    beq $t4 $t5 create_block2
    sw $a0 ($t0)
    addi $t0 $t0 256
    sw $a0 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j create_block
create_block2:
    # lw $t1 block2_life
    beq $s1 0 create_block3
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1344
    add $t0 $t0 $t9
    li $t4 0
    li $t5 16
    # lw $t6 block2_color
create_block2_loop:
    beq $t4 $t5 create_block3
    sw $a1 ($t0)
    addi $t0 $t0 256
    sw $a1 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j create_block2_loop
    
create_block3:
    # lw $t1 block3_life
    bne $t9 0 create_block3_other_row
    beq $s2 0 create_block4
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1408
    add $t0 $t0 $t9
    li $t4 0
    li $t5 16
    lw $t2 block3_life
    beq $t2 3 set_blue
    beq $t2 2 set_lightblue
    beq $t2 1 set_transparent
    j create_block4
    
set_blue:
    lw $t6 block3_color
    j create_block3_loop
set_lightblue:
    lw $t6 block3_color2
    j create_block3_loop
set_transparent:
    lw $t6 block3_color3
    j create_block3_loop
create_block3_loop:
    beq $t4 $t5 create_block4
    sw $t6 ($t0)
    addi $t0 $t0 256
    sw $t6 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j create_block3_loop

create_block3_other_row:
    # lw $t1 block2_life
    beq $s2 0 create_block4
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1408
    add $t0 $t0 $t9
    li $t4 0
    li $t5 16
    # lw $t6 block2_color
create_block3_loop_other_row:
    beq $t4 $t5 create_block4
    sw $a2 ($t0)
    addi $t0 $t0 256
    sw $a2 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j create_block3_loop_other_row
    
create_block4:
    bne $t9 0 create_block4_other_row
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1472
    add $t0 $t0 $t9
    li $t4 0
    li $t5 15
    # lw $t6 block4_color
create_block4_loop:
    beq $t4 $t5 repeat_each_row
    sw $a3 ($t0)
    addi $t0 $t0 256
    sw $a3 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j create_block4_loop
    
create_block4_other_row:
    # lw $t1 block2_life
    beq $s3 0 repeat_each_row
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1472
    add $t0 $t0 $t9
    li $t4 0
    li $t5 15
    # lw $t6 block2_color
create_block4_loop_other_row:
    beq $t4 $t5 repeat_each_row
    sw $a3 ($t0)
    addi $t0 $t0 256
    sw $a3 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j create_block4_loop_other_row

repeat_each_row:
    addi $t9 $t9 1024
    beq $t9 1024 assign_row2
    beq $t9 2048 assign_row3
    beq $t9 3072 start_if_space

assign_row2:
    lw $a0 block1_row2
    lw $a1 block2_row2
    lw $a2 block3_row2
    lw $a3 block4_row2
    lw $s0 block1_row2_life
    lw $s1 block2_row2_life
    lw $s2 block3_row2_life
    lw $s3 block4_row2_life
    j create_block_loop
assign_row3:
    lw $a0 block1_row3
    lw $a1 block2_row3
    lw $a2 block3_row3
    lw $a3 block4_row3
    lw $s0 block1_row3_life
    lw $s1 block2_row3_life
    lw $s2 block3_row3_life
    lw $s3 block4_row3_life
    j create_block_loop
    
start_if_space:
    lw $t0, ADDR_KBRD
    lw $t8, ($t0) # Load f i r s t word from k e y b o a r d
    bne $t8, 1, start_if_space# I f f i r s t word 1 , key i s p r e s s e d
# # . . .
keyboard_space_input: # A key i s p r e s s e d
    lw $t2, 4($t0) # Load s e c o n d word from k e y b o a r d
    beq $t2, 0x20 game_loop
    j start_if_space
game_loop:
    lw $t0, ADDR_KBRD
    lw $t8, ($t0) # Load f i r s t word from k e y b o a r d
    bne $t8, 1, skipped# I f f i r s t word 1 , key i s p r e s s e d
# # . . .
keyboardinput: # A key i s p r e s s e d
    lw $t2, 4($t0) # Load s e c o n d word from k e y b o a r d
    beq $t2, 0x64, respond_to_d
    beq $t2, 0x61, respond_to_a
    beq $t2, 0x71 exit_game
    beq $t2 0x70 pause_game
    j skipped

pause_game:
    lw $t0, ADDR_KBRD
    lw $t8, ($t0)
    bne $t8, 1, pause_game
    lw $t2, 4($t0)
    beq $t2 0x70 game_loop
    j pause_game

respond_to_d:
    lw $t2, panel_position
    li $t0 15572
    bgt $t2 $t0 skipped
    li $t0 0
    li $t1 0
    lw $t1 panel_color
    li $t3, 0x000000
    lw $t2, panel_position
    lw $t0, ADDR_DSPL
    add $t0 $t0 $t2
    # addi $t0 $t0 15476
    sw $t3 ($t0)
    addi $t0 $t0 36
    sw $t1 ($t0)
    li $t4 0
    addi $t4 $t2 4
    sw $t4, panel_position
    j skipped
    
respond_to_a:
    lw $t2, panel_position
    li $t0 15368
    blt $t2 $t0 skipped
    li $t0 0
    li $t1 0
    lw $t1 panel_color
    li $t3, 0x000000
    lw $t0, ADDR_DSPL
    add $t0 $t0 $t2
    addi $t0 $t0 -4
    sw $t1 ($t0)
    addi $t0 $t0 36
    sw $t3 ($t0)
    li $t4 0
    addi $t4 $t2 -4
    sw $t4, panel_position
    j skipped
skipped:
check_if_die:
    lw $t0 ball_position
    bgt $t0 16128 deal_death

check_block:
    lw $t0 ball_position
    lw $t1 ADDR_DSPL
    add $t1 $t1 $t0
    lw $t2 ball_x_speed
    beq $t2 1 check_block_up_right
    bne $t2 1 check_block_up_left

check_block_up_right:
    lw $t3 ball_y_speed
    bne $t3 1 check_block_down_right
    add $t1 $t1 -252
    lw $t4 ($t1)
    lw $t2 block1_color
    beq $t4 $t2 delete_block_from_up_right
    lw $t2 block2_color
    beq $t4 $t2 delete_block_from_up_right
    lw $t2 block3_color
    beq $t4 $t2 delete_block_from_up_right
    lw $t2 block3_color2
    beq $t4 $t2 delete_block_from_up_right
    lw $t2 block3_color3
    beq $t4 $t2 delete_block_from_up_right
    lw $t2 block4_color
    beq $t4 $t2 collision_roof
    li $t2 0xa020f0
    beq $t4 $t2 delete_block_from_up_right
    li $t2 0x964b00
    beq $t4 $t2 delete_block_from_up_right
    li $t2 0x90ee90
    beq $t4 $t2 delete_block_from_up_right
    li $t2 0x717D7E
    beq $t4 $t2 delete_block_from_up_right
    li $t2 0x154360
    beq $t4 $t2 delete_block_from_up_right
    li $t2 0xffc0cb
    beq $t4 $t2 delete_block_from_up_right
    li $t2 0x641E16
    beq $t4 $t2 delete_block_from_up_right
    li $t2 0x186A3B
    beq $t4 $t2 delete_block_from_up_right
    j check_wall

check_block_down_right:
    add $t1 $t1 260
    lw $t4 ($t1)
    lw $t2 block1_color
    beq $t4 $t2 delete_block_from_down_right
    lw $t2 block2_color
    beq $t4 $t2 delete_block_from_down_right
    lw $t2 block3_color
    beq $t4 $t2 delete_block_from_down_right
    lw $t2 block3_color2
    beq $t4 $t2 delete_block_from_down_right
    lw $t2 block3_color3
    beq $t4 $t2 delete_block_from_down_right
    lw $t2 block4_color
    beq $t4 $t2 collision_roof
    li $t2 0xa020f0
    beq $t4 $t2 delete_block_from_down_right
    li $t2 0x964b00
    beq $t4 $t2 delete_block_from_down_right
    li $t2 0x90ee90
    beq $t4 $t2 delete_block_from_down_right
    li $t2 0x717D7E
    beq $t4 $t2 delete_block_from_down_right
    li $t2 0x154360
    beq $t4 $t2 delete_block_from_down_right
    li $t2 0xffc0cb
    beq $t4 $t2 delete_block_from_down_right
    li $t2 0x641E16
    beq $t4 $t2 delete_block_from_down_right
    li $t2 0x186A3B
    beq $t4 $t2 delete_block_from_down_right
    j check_wall
check_block_up_left:
    lw $t3 ball_y_speed
    bne $t3 1 check_block_down_left
    add $t1 $t1 -260
    lw $t4 ($t1)
    lw $t2 block1_color
    beq $t4 $t2 delete_block_from_up_left
    lw $t2 block2_color
    beq $t4 $t2 delete_block_from_up_left
    lw $t2 block3_color
    beq $t4 $t2 delete_block_from_up_left
    lw $t2 block3_color2
    beq $t4 $t2 delete_block_from_up_left
    lw $t2 block3_color3
    beq $t4 $t2 delete_block_from_up_left
    lw $t2 block4_color
    beq $t4 $t2 collision_roof
    li $t2 0xa020f0
    beq $t4 $t2 delete_block_from_up_left
    li $t2 0x964b00
    beq $t4 $t2 delete_block_from_up_left
    li $t2 0x90ee90
    beq $t4 $t2 delete_block_from_up_left
    li $t2 0x717D7E
    beq $t4 $t2 delete_block_from_up_left
    li $t2 0x154360
    beq $t4 $t2 delete_block_from_up_left
    li $t2 0xffc0cb
    beq $t4 $t2 delete_block_from_up_left
    li $t2 0x641E16
    beq $t4 $t2 delete_block_from_up_left
    li $t2 0x186A3B
    beq $t4 $t2 delete_block_from_up_left
    j check_wall

check_block_down_left:
    add $t1 $t1 252
    lw $t4 ($t1)
    lw $t2 block1_color
    beq $t4 $t2 delete_block_from_down_left
    lw $t2 block2_color
    beq $t4 $t2 delete_block_from_down_left
    lw $t2 block3_color
    beq $t4 $t2 delete_block_from_down_left
    lw $t2 block3_color2
    beq $t4 $t2 delete_block_from_down_left
    lw $t2 block3_color3
    beq $t4 $t2 delete_block_from_down_left
    lw $t2 block4_color
    beq $t4 $t2 collision_roof
    li $t2 0xa020f0
    beq $t4 $t2 delete_block_from_down_left
    li $t2 0x964b00
    beq $t4 $t2 delete_block_from_down_left
    li $t2 0x90ee90
    beq $t4 $t2 delete_block_from_down_left
    li $t2 0x717D7E
    beq $t4 $t2 delete_block_from_down_left
    li $t2 0x154360
    beq $t4 $t2 delete_block_from_down_left
    li $t2 0xffc0cb
    beq $t4 $t2 delete_block_from_down_left
    li $t2 0x641E16
    beq $t4 $t2 delete_block_from_down_left
    li $t2 0x186A3B
    beq $t4 $t2 delete_block_from_down_left
    j check_wall
    
delete_block_from_up_right:
    li $t8 -1
    sw $t8 ball_y_speed
    j delete_take_action
delete_block_from_down_right:
    li $t8 1
    sw $t8 ball_y_speed
    j delete_take_action
delete_block_from_up_left:
    li $t8 -1
    sw $t8 ball_y_speed
    j delete_take_action
delete_block_from_down_left:
    li $t8 1
    sw $t8 ball_y_speed
    j delete_take_action
    
delete_take_action:
    lw $t5 block1_color
    lw $t6 block2_color
    lw $t0 block3_color
    lw $t1 block3_color2
    lw $t2 block3_color3
    beq $t4 $t5 delete_block1
    beq $t4 $t6 delete_block2
    beq $t4 $t0 decrement1_block3
    beq $t4 $t1 decrement2_block3
    beq $t4 $t2 decrement3_block3
    li $a0 0xa020f0
    beq $t4 $a0 delete_block1_row2
    li $a0 0x964b00
    beq $t4 $a0 delete_block2_row2
    li $a0 0x90ee90
    beq $t4 $a0 delete_block3_row2
    li $a0 0x717D7E
    beq $t4 $a0 delete_block4_row2
    li $a0 0x154360
    beq $t4 $a0 delete_block1_row3
    li $a0 0xffc0cb
    beq $t4 $a0 delete_block2_row3
    li $a0 0x641E16
    beq $t4 $a0 delete_block3_row3
    li $a0 0x186A3B
    beq $t4 $a0 delete_block4_row3
    
delete_block1:
    lw $t0 speed
    addi $t0 $t0 -20
    sw $t0 speed
    lw $t2 block1_life
    addi $t2 $t2 -1
    sw $t2 block1_life
    lw $t0, ADDR_DSPL    # $t0 = base address for display
    addi $t0 $t0 1284
    li $t4 0
    li $t5 15
    li $t6 0x000000
delete_block1_loop:
    beq $t4 $t5 update_color
    sw $t6 ($t0)
    addi $t0 $t0 256
    sw $t6 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j delete_block1_loop
    
delete_block2:
    lw $t0 speed
    addi $t0 $t0 -20
    sw $t0 speed
    lw $t2 block2_life
    addi $t2 $t2 -1
    sw $t2 block2_life
    lw $t0, ADDR_DSPL    # $t0 = base address for display
    addi $t0 $t0 1344
    li $t4 0
    li $t5 16
    li $t6 0x000000
delete_block2_loop:
    beq $t4 $t5 update_color
    sw $t6 ($t0)
    addi $t0 $t0 256
    sw $t6 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j delete_block2_loop
    
    
decrement1_block3:
    lw $t0 speed
    addi $t0 $t0 -10
    sw $t0 speed
    lw $t0 block3_life
    addi $t0 $t0 -1
    sw $t0 block3_life
    lw $t0, ADDR_DSPL    # $t0 = base address for display
    addi $t0 $t0 1408
    li $t4 0
    li $t5 16
    lw $t6 block3_color2
    # sw $t6 block3_color
delete_block3_loop1:
    beq $t4 $t5 update_color
    sw $t6 ($t0)
    addi $t0 $t0 256
    sw $t6 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j delete_block3_loop1
    
decrement2_block3:
    lw $t0 speed
    addi $t0 $t0 -10
    sw $t0 speed
    lw $t0 block3_life
    addi $t0 $t0 -1
    sw $t0 block3_life
    lw $t0, ADDR_DSPL    # $t0 = base address for display
    addi $t0 $t0 1408
    li $t4 0
    li $t5 16
    lw $t6 block3_color3
    # sw $t6 block3_color
delete_block3_loop2:
    beq $t4 $t5 update_color
    sw $t6 ($t0)
    addi $t0 $t0 256
    sw $t6 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j delete_block3_loop2    
    
decrement3_block3:
    lw $t0 speed
    addi $t0 $t0 -10
    sw $t0 speed
    lw $t0 block3_life
    addi $t0 $t0 -1
    sw $t0 block3_life
    lw $t0, ADDR_DSPL    # $t0 = base address for display
    addi $t0 $t0 1408
    li $t4 0
    li $t5 16
    li $t6 0x000000
    # sw $t6 block3_color
delete_block3_loop3:
    beq $t4 $t5 update_color
    sw $t6 ($t0)
    addi $t0 $t0 256
    sw $t6 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j delete_block3_loop3   
    
delete_block1_row2:
    lw $t0 speed
    addi $t0 $t0 -3
    sw $t0 speed
    lw $t2 block1_row2_life
    addi $t2 $t2 -1
    sw $t2 block1_row2_life
    lw $t0 block1_row2
    li $t1 0x000000
    sw $t1 block1_row2
    j update_color
delete_block2_row2:
    lw $t0 speed
    addi $t0 $t0 -3
    sw $t0 speed
    lw $t2 block2_row2_life
    addi $t2 $t2 -1
    sw $t2 block2_row2_life
    lw $t0 block2_row2
    li $t1 0x000000
    sw $t1 block2_row2
    j update_color
delete_block3_row2:
    lw $t0 speed
    addi $t0 $t0 -3
    sw $t0 speed
    lw $t2 block3_row2_life
    addi $t2 $t2 -1
    sw $t2 block3_row2_life
    lw $t0 block3_row2
    sw $t1 block3_row2
    li $t1 0x000000
    sw $t1 block3_row2
    j update_color
delete_block4_row2:
    lw $t0 speed
    addi $t0 $t0 -3
    sw $t0 speed
    lw $t2 block4_row2_life
    addi $t2 $t2 -1
    sw $t2 block4_row2_life
    lw $t0 block4_row2
    sw $t1 block4_row2
    li $t1 0x000000
    sw $t1 block4_row2
    j update_color

delete_block1_row3:
    lw $t0 speed
    addi $t0 $t0 -3
    sw $t0 speed
    lw $t2 block1_row3_life
    addi $t2 $t2 -1
    sw $t2 block1_row3_life
    lw $t0 block1_row3
    li $t1 0x000000
    sw $t1 block1_row3
    j update_color
delete_block2_row3:
    lw $t0 speed
    addi $t0 $t0 -5
    sw $t0 speed
    lw $t2 block2_row3_life
    addi $t2 $t2 -1
    sw $t2 block2_row3_life
    lw $t0 block2_row3
    li $t1 0x000000
    sw $t1 block2_row3
    j update_color
delete_block3_row3:
    lw $t0 speed
    addi $t0 $t0 -5
    sw $t0 speed
    lw $t2 block3_row3_life
    addi $t2 $t2 -1
    sw $t2 block3_row3_life
    lw $t0 block3_row3
    sw $t1 block3_row3
    li $t1 0x000000
    sw $t1 block3_row3
    j update_color
delete_block4_row3:
    lw $t0 speed
    addi $t0 $t0 -5
    sw $t0 speed
    lw $t2 block4_row3_life
    addi $t2 $t2 -1
    sw $t2 block4_row3_life
    lw $t0 block4_row3
    sw $t1 block4_row3
    li $t1 0x000000
    sw $t1 block4_row3
    j update_color

update_color:
    li $t9 1024
    lw $a0 block1_row2
    lw $a1 block2_row2
    lw $a2 block3_row2
    lw $a3 block4_row2
    lw $s0 block1_row2_life
    lw $s1 block2_row2_life
    lw $s2 block3_row2_life
    lw $s3 block4_row2_life
    # lw $s3 block4_row2_life
update_block_loop:
    lw $t0, ADDR_DSPL 
    addi $t0 $t0 1284
    add $t0 $t0 $t9
    li $t4 0
    li $t5 15
    # lw $t6 block1_color
update_block:
    # lw $t1 block1_life
    beq $t4 $t5 update_block2
    sw $a0 ($t0)
    addi $t0 $t0 256
    sw $a0 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j update_block
update_block2:
    # lw $t1 block2_life
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1344
    add $t0 $t0 $t9
    li $t4 0
    li $t5 16
    # lw $t6 block2_color
update_block2_loop:
    beq $t4 $t5 update_block3
    sw $a1 ($t0)
    addi $t0 $t0 256
    sw $a1 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j update_block2_loop
    
update_block3:
    # lw $t1 block3_life
    bne $t9 0 update_block3_other_row
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1408
    add $t0 $t0 $t9
    li $t4 0
    li $t5 16
    beq $s2 3 update_blue
    beq $s2 2 update_lightblue
    beq $s2 1 update_transparent
    beq $s2 0 update_black
    j update_block4
    
update_blue:
    lw $t6 block3_color
    j update_block3_loop
update_lightblue:
    lw $t6 block3_color2
    j update_block3_loop
update_transparent:
    lw $t6 block3_color3
    j update_block3_loop
update_black:
    li $t6 0x000000
    j update_block_loop
update_block3_loop:
    beq $t4 $t5 update_block4
    sw $t6 ($t0)
    addi $t0 $t0 256
    sw $t6 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j update_block3_loop

update_block3_other_row:
    # lw $t1 block2_life
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1408
    add $t0 $t0 $t9
    li $t4 0
    li $t5 16
    # lw $t6 block2_color
update_block3_loop_other_row:
    beq $t4 $t5 update_block4
    sw $a2 ($t0)
    addi $t0 $t0 256
    sw $a2 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j update_block3_loop_other_row
    
update_block4:
    bne $t9 0 update_block4_other_row
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1472
    add $t0 $t0 $t9
    li $t4 0
    li $t5 15
    # lw $t6 block4_color
update_block4_loop:
    beq $t4 $t5 update_each_row
    sw $a3 ($t0)
    addi $t0 $t0 256
    sw $a3 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j update_block4_loop
    
update_block4_other_row:
    # lw $t1 block2_life
    lw $t0, ADDR_DSPL
    addi $t0 $t0 1472
    add $t0 $t0 $t9
    li $t4 0
    li $t5 15
    # lw $t6 block2_color
update_block4_loop_other_row:
    beq $t4 $t5 update_each_row
    sw $a3 ($t0)
    addi $t0 $t0 256
    sw $a3 ($t0)
    addi $t0 $t0 -256
    addi $t0 $t0 4
    addi $t4 $t4 1
    j update_block4_loop_other_row
update_each_row:
    addi $t9 $t9 1024
    beq $t9 2048 update_row3
    beq $t9 3072 move_ball
    
update_row3:
    lw $a0 block1_row3
    lw $a1 block2_row3
    lw $a2 block3_row3
    lw $a3 block4_row3
    lw $s0 block1_row3_life
    lw $s1 block2_row3_life
    lw $s2 block3_row3_life
    lw $s3 block4_row3_life
    j update_block_loop

check_wall:
    lw $t0 ball_position
    li $t2 256
    addi $t0 $t0 -4
    div $t0, $t2       # i mod 2
    mfhi $t6        # temp for the mod
    beq $t6, 0, collision_wall
    addi $t0 $t0 12
    div $t0, $t2       # i mod 2
    mfhi $t6        # temp for the mod
    beq $t6, 0, collision_wall
    j check_roof_or_panel
    
collision_wall:
    li $t0 -1
    lw $t1 ball_x_speed
    mult $t1 $t0
    mflo $t1
    sw $t1 ball_x_speed
    j move_ball
    
check_roof_or_panel:
    lw $t0 ball_position
    blt $t0 512 collision_roof
    j check_panel_or_block
collision_roof:
    li $t3 0x000000
    lw $t4 ball_position
    lw $t5 ADDR_DSPL
    add $t5 $t5 $t4
    addi $t5 $t5 4
    lw $t9 ($t5)
    bne $t3 $t9 collision_block_horizontal
    addi $t5 $t5 -8
    lw $t9 ($t5)
    bne $t3 $t9 collision_block_horizontal
    li $t0 -1
    lw $t1 ball_y_speed
    mult $t1 $t0
    mflo $t1
    sw $t1 ball_y_speed
    j update_color
check_panel_or_block:
    lw $t0 ball_y_speed
    beq $t0 1 check_forward_right
    bne $t0 1 check_backward_right
    j update_color
    
check_forward_right:
    lw $t5 ball_x_speed
    bne $t5 1 check_forward_left
    lw $t0 ball_position
    lw $t1 ADDR_DSPL
    addi $t0 $t0 -252
    add $t1 $t1 $t0
    lw $t6 ($t1)
    li $t3 0x000000
    bne $t6 $t3 collision_roof
    j update_color
    
check_forward_left:
    lw $t0 ball_position
    lw $t1 ADDR_DSPL
    addi $t0 $t0 -260
    add $t1 $t1 $t0
    lw $t6 ($t1)
    li $t3 0x000000
    bne $t6 $t3 collision_roof
    j update_color
check_backward_right:
    lw $t5 ball_x_speed
    bne $t5 1 check_backward_left
    lw $t0 ball_position
    lw $t1 ADDR_DSPL
    addi $t0 $t0 260
    add $t1 $t1 $t0
    lw $t6 ($t1)
    li $t3 0x000000
    bne $t6 $t3 collision_roof
    j update_color
check_backward_left:
    lw $t0 ball_position
    lw $t1 ADDR_DSPL
    addi $t0 $t0 252
    add $t1 $t1 $t0
    lw $t6 ($t1)
    li $t3 0x000000
    bne $t6 $t3 collision_roof
    j update_color
    
collision_block_horizontal:
    li $t0 -1
    lw $t1 ball_x_speed
    mult $t1 $t0
    mflo $t1
    sw $t1 ball_x_speed
    j update_color
move_ball:
    lw $t1 ball_x_speed
    beq $t1 1 move_up_right
    bne $t1 1 move_up_left
    
move_up_right:
    lw $t2 ball_y_speed
    bne $t2 1 move_down_right
    li $t0 0x000000
    li $t3 0xffffff
    lw $t1 ball_position
    lw $t2 ADDR_DSPL
    add $t2 $t2 $t1
    sw $t0 ($t2)
    addi $t2 $t2 -252
    sw $t3 ($t2)
    addi $t1 $t1 -252
    sw $t1 ball_position
    j skipped2
move_up_left:
    lw $t2 ball_y_speed
    bne $t2 1 move_down_left
    li $t0 0x000000
    li $t3 0xffffff
    lw $t1 ball_position
    lw $t2 ADDR_DSPL
    add $t2 $t2 $t1
    sw $t0 ($t2)
    addi $t2 $t2 -260
    sw $t3 ($t2)
    addi $t1 $t1 -260
    sw $t1 ball_position
    j skipped2
move_down_right:
    li $t0 0x000000
    li $t3 0xffffff
    lw $t1 ball_position
    lw $t2 ADDR_DSPL
    add $t2 $t2 $t1
    sw $t0 ($t2)
    addi $t2 $t2 260
    sw $t3 ($t2)
    addi $t1 $t1 260
    sw $t1 ball_position
    j skipped2
move_down_left:
    li $t0 0x000000
    li $t3 0xffffff
    lw $t1 ball_position
    lw $t2 ADDR_DSPL
    add $t2 $t2 $t1
    sw $t0 ($t2)
    addi $t2 $t2 252
    sw $t3 ($t2)
    addi $t1 $t1 252
    sw $t1 ball_position
    j skipped2
    
deal_death:
    lw $t0 player_life
    addi $t0 $t0 -1
    lw $t1 ball_position
    lw $t2 ADDR_DSPL
    add $t2 $t2 $t1
    li $t3 0x000000
    sw $t3 ($t2)
    beq $t0 0 exit_game
    sw $t0 player_life
    lw $t0 ADDR_DSPL
    lw $t2 panel_position
    add $t0 $t0 $t2
    li $t4 0
    li $t5 9
delete_panel:
    beq $t4 $t5 main
    sw $t3 ($t0)
    addi $t0 $t0 4
    addi $t4 $t4 1
    j delete_panel
skipped2:
    li $v0, 32
    lw $a0, speed
    syscall
    lw $t0 block1_life
    lw $t1 block2_life
    lw $t2 block3_life
    bne $t0 0 game_loop
    bne $t1 0 game_loop
    bne $t2 0 game_loop
    lw $t2 block1_row2_life
    bne $t2 0 game_loop
    lw $t2 block2_row2_life
    bne $t2 0 game_loop
    lw $t2 block3_row2_life
    bne $t2 0 game_loop
    lw $t2 block4_row2_life
    bne $t2 0 game_loop
    lw $t2 block1_row3_life
    bne $t2 0 game_loop
    lw $t2 block2_row3_life
    bne $t2 0 game_loop
    lw $t2 block3_row3_life
    bne $t2 0 game_loop
    lw $t2 block4_row3_life
    bne $t2 0 game_loop
    j exit_game
exit_game:
    li $v0, 10 # t e r m i n a t e t h e program g r a c e f u l l y
    syscall

    
    

    # Check i f t h e key q was p r e s s e d
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop
