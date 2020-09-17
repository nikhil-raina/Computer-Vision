function test_fifty_shades()
    resulting_image = fifty_shades_of_gray();
    imshow(resulting_image);
    imwrite(resulting_image, 'Fifty_Shades_of_Gray.png');
end