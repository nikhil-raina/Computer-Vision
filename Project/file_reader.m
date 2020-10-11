function file_reader()
% currently our function works well for scans 120 - 132
% not as effective with the other iamge scans and we are working on a fix
    for idx = 120:132
        file_name = strcat('PROJ_IMAGES/SCAN0',int2str(idx),'.jpg');
        if exist(file_name, 'file') ~= 0
            project(file_name);
            pause(1)
        end
    end
end
