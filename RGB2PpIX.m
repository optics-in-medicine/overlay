function [P af] = RGB2PpIX( RGB_image, wl_image, mpar )
%RGB2PPIX Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
    % mpar.inv_mat = [1.165 1.963; 0.276 0.781; 0.084 0.176]; %w IR
    % filter. af is made up.
    
    % mpar.inv_mat = [1.165 2.013; 0.276 0.833; 0.084 0.308]; %af made-up.
    mpar.inv_mat = [1.165 0.249; 0.276 0.201; 0.084 0.483]; %with IR filter.
    
    mpar.options = optimset('Display','off','TolFun',1e-8, 'MaxIter',100);
    mpar.calfact = 0.0143;
    mpar.om = 1;
    mpar.alpha = -0.7
end
    
[X, Y, junk] = size(RGB_image);
P = zeros(X,Y);
af = zeros(X,Y);

corr_fact = mpar.om ./ (wl_image(:,:,3) .* wl_image(:,:,1) .^ mpar.alpha);
phi_corr = RGB_image ./repmat(corr_fact, [1 1 3]);

for x = 1:X;
    for y = 1:Y;
        %x_t = lsqnonneg(mpar.inv_mat, squeeze( RGB_image(x,y,:) ), mpar.options);
        x_t = lsqlin(mpar.inv_mat, squeeze( RGB_image(x,y,:) ));
        P(x,y) = x_t(1) .* mpar.calfact;
        af(x,y) = x_t(2);
    end
end


end
