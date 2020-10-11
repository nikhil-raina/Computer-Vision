function file_reader()
    for idx = 107:159
        file_name = strcat('PROJ_IMAGES/SCAN0',int2str(idx),'.jpg');
        if exist(file_name, 'file') ~= 0
            project(file_name);
            pause(1)
        end
    end
end
