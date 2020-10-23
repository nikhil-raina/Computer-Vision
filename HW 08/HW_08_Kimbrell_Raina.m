im = imread('Images__Hello_World/IMG_3997.JPG');

% convert the image to grayscale
gray = rgb2gray(im); 

% binarize the image with a threshold of .6
bw = imbinarize(gray,.6);

% create the strel object to use close on its a rectangle because paper is
% rectangle
SE = strel('rectangle',[100 50]) ;

% perform close opertion on the binarized image to get rid of the test
bw = imclose(bw, SE);

% detect the harrisfeatures of the new processed image
points = detectHarrisFeatures(bw);
% get the strongest 1000 points
strongpoints = points.selectStrongest(1000);
imshow(im); 
hold on;
% show the strongest 1000 points.
plot(strongpoints);