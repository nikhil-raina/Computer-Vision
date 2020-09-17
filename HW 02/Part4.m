
im            = imread('my_photo.jpg');  % Searches the path to find this file.
im_grn        = im(:,:,2);
im_smaller    = imresize( im_grn, 0.5 );
imagesc( im_smaller );
axis image

disp('What is the variable im_smaller?');

surf( im_smaller, 'LineStyle', 'none' );
rotate3d on
axis tight
disp('Now rotate the surface around for a while.  Study the features.');

colormap( gray(256) )
disp('What is the relationship between the height and the shading on the surface plot?')

view( 150, 50 )
disp('What does this do?')
