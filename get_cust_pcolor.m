function [ new_rgb, I_par_n ] = get_cust_pcolor( I_par, cmap)
%GET_CUST_PCOLOR Summary of this function goes here
%   Detailed explanation goes here

t0 = 0;
t1 = 0;

max_par = max(I_par(:));
min_par = min(I_par(:));

a = 256;
I_par_n = (I_par - min_par) ./ ( max_par - min_par );

I_8bit = fix( real( (a * (1 + t1 - t0) - 1) .* I_par_n + a * t0 + 1 ) );  
I_8bit(I_8bit < 1) = 1; I_8bit(I_8bit > 256) = 256;

% define how each colorchannel maps to values of I_par_n (1-256).
R_map = cmap(:,1);
G_map = cmap(:,2);
B_map = cmap(:,3);

% look up corresponding R, G, and B values.
R = R_map(I_8bit);
G = G_map(I_8bit);
B = B_map(I_8bit);

% concatenate
new_rgb = cat(3, R,G,B)./255;


end
