function show_local_diffs()
    im_original = im2double( imread('cameraman.tif'));
    im_new = block_avg_cameraman();
    im_diff = im_new - im_original;
    imagesc(im_diff);
    colormap(copper(256));
    hold on;
    axis image;
end
