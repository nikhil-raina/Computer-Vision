function HW_08_Image_Driver()
    for idx = 78:98 
        file_name = strcat('Images__Hello_World/IMG_39',int2str(idx),'.jpg');
        if exist(file_name, 'file') ~= 0
            HW_08_Nikhil_Raina(file_name);  % set to 1 to prompt user interaction
            pause(4)
            
            close( gcf );
            close( gcf );
        end
    end
end