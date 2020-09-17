im = imread('my_photo.jpg');  % Searches the path to find this file.
im_grn = im(:,:,2);

disp('Here is one display routine:');
imshow( im_grn )

disp('Here is a second display routine:');
imagesc( im_grn )
disp('What is the difference between these two commands?')

colormap( hot )
colormap( gray(256) )
colormap( 1-gray(256) )
disp('What does the colormap() command do to the displayed image ?')

