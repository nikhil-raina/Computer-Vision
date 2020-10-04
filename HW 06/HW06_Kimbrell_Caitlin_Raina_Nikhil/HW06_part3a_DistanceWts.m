function HW06_part3a_DistanceWts
    % adding required directory to the path
    addpath('TEST_IAMGES');
    addpath('../TEST_IAMGES');
    addpath('../../TEST_IAMGES');

    %read in the image.
    im = imread('Corel_Image_198023.jpg');
    
    %size fo the image
    dimension = size(im);
    
    %filter to smooth the image
    fltr = fspecial('gauss', [15 15], 1.4);
    im = imfilter(im, fltr, 'same', 'repl');
    im = rgb2ycbcr(im);
    
    %matrix matching the size of the image
    [xs, ys] = meshgrid(1:dimension(2), 1:dimension(1));
    
    
    %separating the respective color channels.
    im_red = im(:,:,1);
    im_green = im(:,:,2);
    im_blue = im(:,:,3);
    
    %default weight for the pixels
    pixel_weight = 0.9;
    
    %k value to be taken
    k = 64;
    
    %initialising all the attributes with the meshgrid and the weight that
    %had been found and initialised before.
    attr = [xs(:)*pixel_weight, ys(:)*pixel_weight, double(im_red(:)), ...
                double(im_green(:)), double(im_blue(:))];
            
    %implementing the K-means method for clustering
    [cluster_indx, cluster_center] = kmeans(attr, k, 'MaxIter', 200);
    
    %changes the cluster centers to int
    center_to_int = uint8(cluster_center(:,3:end));
    
    %back to rgb from ycbcr
    center_to_int = ycbcr2rgb(center_to_int);
    
    %reshaping the image to avoid loss of data
    im_reshape = reshape(cluster_indx, dimension(1), dimension(2));
    
    %splitting the channels of the cluster matrix
    im_1 = center_to_int(:,1);
    im_2 = center_to_int(:,2);
    im_3 = center_to_int(:,3);
    
    %forming the new image
    im_new = im_1(im_reshape);
    im_new(:,:,2) = im_2(im_reshape);
    im_new(:,:,3) = im_3(im_reshape);
    
    imshow(im_new);
    
end