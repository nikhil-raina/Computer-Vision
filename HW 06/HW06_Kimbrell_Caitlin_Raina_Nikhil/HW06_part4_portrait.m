function HW06_part4_portrait
    %read in the image.
    im = imread('Raina_portrait.jpg');
    im = imresize(im, [640 480]);
    %imwrite(im, 'resized_image.jpg');
    %im = imread('resized_image.jpg');
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
    pixel_weight = 0.3;
    
    %k value to be taken
    k = 200;
    
    %initialising all the attributes with the meshgrid and the weight that
    %had been found and initialised before.
    attr = [xs(:)*pixel_weight, ys(:)*pixel_weight, double(im_red(:)), ...
                double(im_green(:)), double(im_blue(:))];
            
    %implementing the K-means method for clustering
    [cluster_indx, cluster_center] = kmeans(attr, k);
    
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
    adding_edges(im_new);
    %imwrite(im_new, 'cartoon_image_Raina.jpg');
end

function adding_edges(image)
    %finding the edges in the image
    im_gray = rgb2gray(image);
    
    % creating a filter for x and y values
    fltr_dx = [-1 0 1] / 2;
    fltr_dy = fltr_dx.';
    
    
    % getting separate filters for each axis.
    di_dx = imfilter(im_gray, fltr_dx, 'same', 'repl');
    di_dy = imfilter(im_gray, fltr_dy, 'same', 'repl');

    % increasing the contrast of the edges
    di_mag = sqrt(double(di_dy.^2 + di_dx.^2));
    
    % getting the most contrasting edges
    im_edges = di_mag > 15; 
        
    % recreating the image and adding the edges, but in black.
    im_red = image(:,:,1);
    im_green = image(:,:,2);
    im_blue = image(:,:,3);
    
    % making the edges black for each channel
    im_red(im_edges) = 0;
    im_green(im_edges) = 0;
    im_blue(im_edges) = 0;
    
    im_new = im_red;
    im_new(:,:,2) = im_green;
    im_new(:,:,3) = im_blue;
    
    imshow(im_new);

    imwrite(im_new, 'cartoon_image_with_edges_Raina.jpg');

end