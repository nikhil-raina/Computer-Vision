function k_means_on_frog_RGB_distance_series_v011()
% Cluster image to see if number of objects is identifyable...
K_MIN =  11; 
K_MAX =  21;

target_size = 1220;         % Approximate pixels

dst_wts = [ 1/40 1/20 1/10 1/5 1/2 1 ]; 

    im_orig     = imread('science_frog.jpg');               % This version is 720x960x3
    
    im          = imresize( im_orig, 0.5 );      % Creates 360x480 version.
    dims        = size( im );
%     im          = rgb2ycbcr( im );
    fltr        = fspecial( 'gauss', [15 15], 1.5 );
    im          = imfilter( im, fltr, 'same', 'repl' );
    
    [xs ys]     = meshgrid( 1:dims(2), 1:dims(1) );
    
    reds        = im(:,:,1);
    grns        = im(:,:,2);
    blus        = im(:,:,3);

%     k = ceil( ( dims(1)*dims(2) / target_size )^(1/sqrt(2)) )
    
    
%   for k = K_MIN : 2 : K_MAX
        
    for wt = dst_wts
        
        for k = [ 24  ]
            attributes  = [ xs(:)*wt, ys(:)*wt, double(reds(:)), double(grns(:)), double(blus(:)) ];

            tic;
            cluster_id  = kmeans( attributes, k, 'Dist', 'Cityblock', 'Replicate', 3, 'MaxIter', 250 );
            toc
            
            im_new      = reshape( cluster_id, dims(1), dims(2) );

            figure;
            imagesc( im_new );
            colormap( jet );
            title( sprintf('k = %d,  distance wt = %8.5f ', k, wt), 'FontSize', 24 );
            colorbar
            drawnow;
            
         end
    end

end
