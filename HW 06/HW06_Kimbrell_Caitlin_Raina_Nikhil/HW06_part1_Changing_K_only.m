im_macbeth = im2double(imread('HW_06_MacBeth_Regular.jpg'));
im_balls = im2double(imread('BALLS_FIVE_7537_shrunk.jpg'));
[im_macbeth_ind, macbeth_map] = rgb2ind( im_macbeth , 27, 'nodither');
[im_balls_ind, ball_map] = rgb2ind(im_balls, 15, 'nodither');

imagesc(im_macbeth_ind);
colormap(macbeth_map);
figure
imagesc(im_balls_ind);
colormap(ball_map);