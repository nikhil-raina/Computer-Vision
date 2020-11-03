im = zeros(512,512, 'double'); % initialize
for col = 1:256
    for row = 1:512
        im(row,col) = 0.0;  % set right half to 0.0 or white
    end
end
for col = 257:512
    for row = 1:512
        im(row,col) = 1.0;  % set left half to 0.0 or black
    end
end

fourier = fft2(im);     % get the fourier transform of the matrix
shift = fftshift(fourier);  % use ffshift w/ fourier 

threshold = 20;       % the threshold for pixels


imagesc(im);
figure;
imagesc(abs(shift));


