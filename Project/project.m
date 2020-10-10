im = imread('SCAN0129.jpg');
im = im2double( im );

%filter to smooth the image
fltr = fspecial('gauss', [15 15], 1.4);
im = imfilter(im, fltr, 'same', 'repl');
%maybe add an open here idk

%turn image into a binary image threshold should change based on histogram
bw = imbinarize(im,.6); 

imagesc(bw)


