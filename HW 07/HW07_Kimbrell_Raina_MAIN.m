function HW07_Kimbrell_Raina_MAIN()
    for idx = 3293:3343 
        file_name = strcat('ORANGE_TREES/Orange_Tree_Image_',int2str(idx),'.jpg');
        if exist(file_name, 'file') ~= 0
            DEMO__GET_RASPBERY_COLORS_released_2201(file_name, 1);  % set to 1 to prompt user interaction
            pause(1)
        end
    end
end