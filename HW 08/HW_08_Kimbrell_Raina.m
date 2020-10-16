im = imread('Images__Hello_World/IMG_3997.JPG');

% convert the image to grayscale
im = rgb2gray(im); 

% binarize the image with a threshold of .6
bw = imbinarize(im,.6);

% create the strel object to use close on its a rectangle because paper is
% rectangle
SE = strel('rectangle',[100 50]) ;

% perform close opertion on the binarized image to get rid of the test
bw = imclose(bw, SE);

% detect the harrisfeatures of the new processed image
points = detectHarrisFeatures(bw);

imshow(bw); 
hold on;
% show the strongest 100 points.
plot(points.selectStrongest(100));