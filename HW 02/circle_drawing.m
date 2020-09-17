% CIRCLE - Draws a circle.
%
% Usage: circle(c, r, n)
%
% Arguments:  c -  A 2-vector [x y] specifying the centre.
%             r -  The radius.
%             n -  Optional number of sides in the polygonal approximation.
%                  (defualt is 16 sides)

function circle_drawing(center, radius, nsides, color)
    
    if ( nargin == 2 )
        nsides = 32;                % Default is 32 sides.
    end
    
    if ( nargin < 4 )
        color = [1 0 1];            % Default color is magenta.
    end
        
    nsides = max(round(nsides),3); % Make sure it is an integer >= 3
    
    thetas  = linspace( 0, 2*pi, nsides );
    xs      = radius*cos(thetas)+center(1);
    ys      = radius*sin(thetas)+center(2);
    plot( xs, ys, 'Color', color, 'LineWidth', 5 );
    
end

