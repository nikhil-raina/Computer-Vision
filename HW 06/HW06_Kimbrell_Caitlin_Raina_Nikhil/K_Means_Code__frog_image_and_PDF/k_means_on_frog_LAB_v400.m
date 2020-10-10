function k_means_on_frog_LAB_v400()
% Cluster image to see if number of objects is identifyable:

dst_wts = [ 1/40 1/15 1/10 1/7 1/5 1/4 1/2 1 100 ]; 

    im_orig     = imread('science_frog.jpg');   % This version is 720x960x3
    
    im          = imresize( im_orig, 0.25 );    % Creates SMALLER version.
    dims        = size( im );
    im_lab      = rgb2lab( im );
    
    %
    %  NOISE CLEANING
    %
    %  MEDIAN FILTER EACH PLANE SEPARATELY:
    %
    im_lab(:,:,1)   = medfilt2( im_lab(:,:,1), [7 7] );
    im_lab(:,:,2)   = medfilt2( im_lab(:,:,2), [7 7] );
    im_lab(:,:,3)   = medfilt2( im_lab(:,:,3), [7 7] );
    
    % ADD SOME GAUSSIAN BLUR:
    %     fltr        = fspecial( 'gauss', [15 15], 1.5 );
    %     im          = imfilter( im, fltr, 'same', 'repl' );
    
    [xs, ys]    = meshgrid( 1:dims(2), 1:dims(1) );
    
    lums        = im_lab(:,:,1);
    aStr        = im_lab(:,:,2);
    bStr        = im_lab(:,:,3);

%   k = ceil( ( dims(1)*dims(2) / target_size )^(1/sqrt(2)) )
%   for k = K_MIN : 2 : K_MAX
        
    for wt = dst_wts
        
        for k = [ 16 ]
            attributes  = [ xs(:)*wt, ys(:)*wt, double(lums(:)), double(aStr(:)), double(bStr(:)) ];

            tic;
%             cluster_id  = kmeans( attributes, k, 'Dist', 'Cityblock', 'Replicate', 3, 'MaxIter', 250 );
            cluster_id  = kmeans( attributes, k, 'Replicate', 3, 'MaxIter', 250 );
            toc
            
            im_new      = reshape( cluster_id, dims(1), dims(2) );

            figure('Position',[10 10 1200 800]);
            imagesc( im_new );
            colormap( jet );
            title( sprintf('k = %d,  distance wt = %8.5f ', k, wt), 'FontSize', 24 );
            colorbar
            drawnow;
            pause(1);
            
         end
    end

end
