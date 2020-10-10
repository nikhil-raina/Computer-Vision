function HW06_part1_Changing_K_only
    % adding required directory to the path
    addpath('TEST_IAMGES');
    addpath('../TEST_IAMGES');
    addpath('../../TEST_IAMGES');
    % load the pictures and convert to doubles
    im_macbeth = im2double(imread('HW_06_MacBeth_Regular.jpg'));
    im_balls = im2double(imread('BALLS_FIVE_7537_shrunk.jpg'));

    % convert to indexes and recieve the image and a colormap
    [im_macbeth_ind, macbeth_map] = rgb2ind( im_macbeth , 27, 'nodither');
    [im_balls_ind, ball_map] = rgb2ind(im_balls, 15, 'nodither');

    % display new images and colormaps
    imagesc(im_macbeth_ind);
    colormap(macbeth_map);
    figure
    imagesc(im_balls_ind);
    colormap(ball_map);
end