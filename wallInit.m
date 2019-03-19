%function wallInit
    import motor
    global left_wall
    global right_wall
    
    left_wall = motor;
    right_wall = motor;
    connect(left_wall, '28250158');
    connect(right_wall, '28250420');
    home(left_wall);
    home(right_wall);
    moveto(left_wall, 40);
    moveto(right_wall, 40);