function wallDisconnect
    import motor
    global left_wall
    global right_wall
    
    home(left_wall);
    home(right_wall);
    
    disconnect(left_wall);
    disconnect(right_wall);