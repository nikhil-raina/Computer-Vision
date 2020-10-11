im = imread('SCAN0129.jpg');
im = im2double( im );

%filter to smooth the image
fltr = fspecial('gauss', [15 15], 1.4);
im = imfilter(im, fltr, 'same', 'repl');
%maybe add an open here idk

%turn image into a binary image maybe threshold should change based on
%histogram? doesnt yet
bw = imbinarize(im,.6);
lines = bw <= .4;
im_ed = edge( lines );

[cntrs, radii] = imfindcircles( im_ed, [20, 50] );
imshow(bw)
h = viscircles(centers,radii);




