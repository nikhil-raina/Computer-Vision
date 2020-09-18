function HW_04_Study_Edge_Statistics( )
addpath( [ '..' filesep() 'TEST_IMAGES' filesep() ] );
addpath( [ '.'  filesep() 'TEST_IMAGES' filesep() ] );

%
%  This might generate a warning, but leave it in:
%
addpath( [ '..' filesep() '..' filesep() 'TEST_IMAGES' filesep() ] );

%
% Demonstrates walking through a cell array:
%
% Create a cell array of filenames:
file_list_of_names = { ...
    'TBK_wood_work.jpg', ...
    'TBK_Road_Home.jpg', ...
    'TBK_B70_IN_SUN_0900.jpg', ...
    'TBK_OLD_LANDMARK_Dr.jpg', ...
    'TBK_Yellow_Cart_Sign.jpg', ...
    'TBK_Orange_Balloon_Infinity.jpg', ...
    'TBK_Buckle_Up_Next_Million_Miles_DSCF0372.jpg', ...
    'TBK_CAMO_FAILURE_small.jpg', ...
    'TBK_IMG_20150804_BEST_TRAFFIC_CONE.jpg', ...
    'TBK_relaxing_jaguar_wallpaper.jpg', ...
    'TBK_WALL_IMG_1064.jpg', ...
    'TBK_Parent_Drop_Off.jpg' };

%     'Parent_Drop_off.jpg', ...

    for hw_part_number = 1:2
        
        fprintf('WORKING ON HOMEWORK PART NUMBER:  %2d\n', hw_part_number);
        
        for idx=1:length(file_list_of_names)
            % If you index a cell array using parenthesis, (), you get a copy of the cell,
            % which is worthless to us.  We want the CONTENTS of the cell so we can work with it.
            %
            % To get the contents of a cell array, use braces, {}.
            fn = file_list_of_names{idx};

            %
            %
            %
            HW_04_Your_Last_Name_Edge_Stats_and_Display( fn, hw_part_number );

            disp('pausing for four seconds...');
            pause(4);

            close( gcf );
            close( gcf );
        end
    end

end

