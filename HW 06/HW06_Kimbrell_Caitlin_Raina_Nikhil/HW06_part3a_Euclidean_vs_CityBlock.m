function HW06_part3a_Euclidean_vs_CityBlock
    % adding required directory to the path
    addpath('TEST_IAMGES');
    addpath('../TEST_IAMGES');
    addpath('../../TEST_IAMGES');
    
    im = imread('HW_06_MacBeth_Regular.jpg');
    %im_rot = imread('HW_06_MacBeth_Rotated.jpg');
    
    %size fo the image
    dimension = size(im);
    
    %filter to smooth the image
    fltr = fspecial('gauss', [15 15], 1.4);
    im = imfilter(im, fltr, 'same', 'repl');
    im = rgb2ycbcr(im);
    
    %filter to smooth the image
    
    %matrix matching the size of the image
    [xs, ys] = meshgrid(1:dimension(2), 1:dimension(1));
    
    %separating the respective color channels.
    im_red = im(:,:,1);
    im_green = im(:,:,2);
    im_blue = im(:,:,3);
    
    %default weight for the pixels
    pixel_weight = 1;
    
    %k value to be taken
    k = 60;
    
    %initialising all the attributes with the meshgrid and the weight that
    %had been found and initialised before.
    attr_reg = [xs(:)*pixel_weight, ys(:)*pixel_weight, ... 
                    double(im_red(:)), double(im_green(:)), ... 
                    double(im_blue(:))];
            
    %implementing the Euclidean method for clustering
    [cluster_indx_E, cluster_center_E] = kmeans(attr_reg, k, ...
                                                'Distance', 'sqeuclidean');
    
    %implementing the CityBlock method for clustering
    [cluster_indx_CB, cluster_center_CB] = kmeans(attr_reg, k, ...
                                                'Distance', 'cityblock');
    
    %changes the cluster centers to int
    center_to_int_E = uint8(cluster_center_E(:,3:end));
    center_to_int_CB = uint8(cluster_center_CB(:,3:end));

    %back to rgb from ycbcr
    center_to_int_E = ycbcr2rgb(center_to_int_E);
    center_to_int_CB = ycbcr2rgb(center_to_int_CB);
    
    %reshaping the image to avoid loss of data
    im_reshape_E = reshape(cluster_indx_E, dimension(1), dimension(2));
    im_reshape_CB = reshape(cluster_indx_CB, dimension(1), dimension(2));

    
    %splitting the channels of the cluster matrix
    im_1_E = center_to_int_E(:,1);
    im_2_E = center_to_int_E(:,2);
    im_3_E = center_to_int_E(:,3);
    im_1_CB = center_to_int_CB(:,1);
    im_2_CB = center_to_int_CB(:,2);
    im_3_CB = center_to_int_CB(:,3);
    
    %forming the new image
    im_new_E = im_1_E(im_reshape_E);
    im_new_E(:,:,2) = im_2_E(im_reshape_E);
    im_new_E(:,:,3) = im_3_E(im_reshape_E);
    im_new_CB = im_1_CB(im_reshape_CB);
    im_new_CB(:,:,2) = im_2_CB(im_reshape_CB);
    im_new_CB(:,:,3) = im_3_CB(im_reshape_CB);
    
    imshow(im_new_E);
    title('Euclidean Distance', 'FontSize', 15 );

    figure
    imshow(im_new_CB);
    title('CityBlock Distance', 'FontSize', 15 );


end