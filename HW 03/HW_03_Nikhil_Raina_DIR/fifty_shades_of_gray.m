function resulting_image = fifty_shades_of_gray()
    resulting_image = zeros(480,960);
    values = linspace(0,1,50);
    for col = 1:10
        for row = 1:5
            resulting_image((row-1)*96 + 1:(row-1)*96 + 96 , ...
                (col-1)*96 + 1:(col-1)*96 + 96 ) = values(row + (col-1)*5 );
        end
    end
    imshow(resulting_image);
end

function test_fifty_shades()
    
end