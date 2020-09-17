m3 = magic(3)
m3^2
m3.^2

disp('What is the difference between m3.^2 and m3^2?');

disp('Which command is short hand for m3 * m3?');

mstacked = [ m3 , 20+m3 ]

disp('What is mstacked( 3, 2 ) ?');

disp('What is size(mstacked,1)?');

disp('What is size(mstacked,2)?');

disp('What is length(mstacked)?');

disp('Try the following command and report what results:');
fprintf('%2d, ', [ 23, 31, 43 ] );


% Run this command set:
for variable = mstacked 
    fprintf('%d, ', variable );
    fprintf('\n');
end
disp('How many times did the loop iterate?');

disp('Is the matrix printed out normally, or transposed?  What happened and why?');
