
function y = getAlphaLUT( x, L, k, x0, f )

if nargin == 4
    f = 'logistic';
end

k = k * 1;                                                              % because the slope of 
nb = 256;                                                                   % precision of transparency map.
x_8bit = abs( real( floor( (nb-1) .* x ) ) ) + 1;                           % convert [0 - 1] double values to 8bit unsigned. 
x_i = linspace(0, 1, nb);                                                   % define 255 length vector.

switch  f
    case 'logistic'
        fxk = @(x, k) 1 ./ ( 1 + exp ( -k * (x - 0.5) ) );

        % account for shift of center point.
        if x0 < 0.5
            x_ii = linspace( 0, 1, fix( nb * (x0 * 2) ) );
            y_ii = fxk(x_ii, k);
            y_i = [y_ii(:);  y_ii(end) * ones([ nb - fix( nb * (x0 * 2) )  1])];
        elseif x0 > 0.5
            x_ii = linspace( 0, 1, fix( nb * (1 - x0) * 2 ) );
            y_ii = fxk(x_ii, k);
            y_i = [y_ii(1) * ones([ nb - fix( nb * (1 - x0) * 2 )  1]); y_ii(:); ];
        else
            y_i = fxk(x_i, k);
        end

        y_n = L .* (y_i - min(y_i(:))) ./ (max(y_i(:)) - min(y_i(:)));
        % map the 8bit x matrix to the transparency values defined by the transfer
        % function.
        y = y_n(x_8bit);
    case 'power'
        
        fxk = @(x, k) x .^ k;
        y_i = fxk(x_i, k);
        y_n = L .* (y_i - min(y_i(:))) ./ (max(y_i(:)) - min(y_i(:)));
        y = y_n(x_8bit);
    case 'lin'
        y_i = k .* x_i + (0.5 - k .* x0);
        y_i(y_i > 1) = 1;
        y_i(y_i < 0) = 0;
        
        y_n = L .* (y_i - min(y_i(:))) ./ (max(y_i(:)) - min(y_i(:)));
        y = y_n(x_8bit);
        
        
end