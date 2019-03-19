function soft2wall(byte)
    global left_wall
    global right_wall
    import motor
    
    distanceSet = [15,15;35,5;35,10;35,15;5,35;10,35;15,35;35,35];
    velocitySet = [50,35,28,22,35,28,22];
    
    if byte < 8
        setvelocity(left_wall, velocitySet(byte), 2000);
        setvelocity(right_wall, velocitySet(byte), 2000);
        fprintf('Moving left wall to %d...', distanceSet(byte,1));
        moveto(left_wall, 50-distanceSet(byte,1));
        disp('Done');
        fprintf('Moving right wall to %d...', distanceSet(byte,2));
        moveto(right_wall, 50-distanceSet(byte,2));
        disp('Done');    
    else
        setvelocity(left_wall, velocitySet(byte-7), 2000);
        setvelocity(right_wall, velocitySet(byte-7), 2000);
        fprintf('Homing to 35...');
        moveto(left_wall, 50-distanceSet(8,1));
        moveto(right_wall, 50-distanceSet(8,2));
        disp('Done'); 
    end
end