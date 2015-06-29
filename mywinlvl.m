function I_wl = mywinlvl( I, win, lvl, im_type )
%MYWINLVL Summary of this function goes here
%   Detailed explanation goes here

if nargin == 3
    im_type = 'double';
end

switch im_type
    case 'uint8'
        p = 8;
    case 'double'
        p = 16;
    case 'uint16'
        p = 8;
    otherwise
        p = 8;
        im_type = '';
end

I = double(I);

a = fix( (lvl - win / 2) * (2^p - 1) ) + 1;
b = fix( (lvl + win / 2) * (2^p - 1) ) + 1;

y = [zeros(a, 1); linspace(0,1,b-a)'; ones(2^p - b,1)];

[rows,cols,chans] = size( I );

if chans == 1
    I_n = fix( (2^p - 1) .* (I - min(I(:))) ./ (max(I(:)) - min(I(:))) ) + 1;
    I_wl = y(I_n);
elseif chans == 3
    I_wl = zeros(size(I));
    for i = 1:3
        I_ch = I(:,:,i);
        I_n = fix( (2^p - 1) .* (I_ch - min(I_ch(:))) ./ (max(I_ch(:)) - min(I_ch(:))) ) + 1;
        I_wl(:,:,i) = y(I_n);
    end
end

if strcmpi(im_type,'uint8')
    I_wl = uint8(I_wl);
end

end
