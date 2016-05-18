% Written by Ivan Podmazov, Apr/13/2014 + Apr/11-12/2015
% Distributed under CC-BY-SA 4.0 license

%% Init
clc
clear all
close all

%% Contour
dphi = 0.001;
phi = 0:dphi:(2*pi);

pic_contour =  cos((pi/2-phi) / 2).^2 .* ...
    (0.85*abs(cos((pi/2-phi) * 11/2)).^1/2 + ...
    0.1*cos((pi/2-phi) * 11/2).^20 + 0.05*cos((pi/2-phi) * 11/2).^1000);
pic_contour = pic_contour / max(pic_contour);

%% Picture
N = 1001;
q = 2;
contour_size = ((N-1) / q) + 1;
xcenter_i = (N+1)/2;
ycenter_j = 21*(N+1)/32;

picture = zeros(N, N);
for i = 1:N
    for j = 1:N
        x = (j - xcenter_i) / ((contour_size-1) / 2);
        y = (ycenter_j - i) / ((contour_size-1) / 2);
        ro = sqrt(x^2 + y^2);
        
        if y >= 0
            ang = atan2(y, x);
        else 
            ang = 2*pi + atan2(y, x);
        end;
        ang_index = round(ang / dphi) + 1;
        
        if (ro <= pic_contour(ang_index)) || ((abs(x) <= 0.005) && (y < 0) && (y > -0.33))
            picture(i, j) = 0;
        else
            d = ro - pic_contour(ang_index);
            picture(i, j) = 1 - exp(-0.5*d);
            if (ang >= (3/2*pi - pi/4)) && (ang <= (3/2*pi + pi/4))
                picture(i, j) = picture(i, j) + 0.1 * abs(sin((ang + pi/4) * 2));
            end;
        end;
    end;
end;

%% Animation
% Colormap init
pic_cm_size = 150;
pic_colormap = zeros(pic_cm_size, 3);

green_zone = 5;
green_transfer = 20;
pic_colormap(1:green_zone, 2) = 1;
first_green_brightness = 0.5;
pic_colormap(1, 2) = first_green_brightness;

black_transfer = 50;
black_zone = 20;
std_cm_size = pic_cm_size;

std_colormap = hsv(std_cm_size);
for i = 1:std_cm_size
    bri = sqrt(std_colormap(i, 1)^2 + std_colormap(i, 2)^2 + std_colormap(i, 3)^2);
    std_colormap(i, :) = std_colormap(i, :) / bri;
end;

std_colormap((std_cm_size+1):(2*std_cm_size-1), :) = std_colormap(1:(std_cm_size-1), :);
flash_zone_start = green_zone + green_transfer;
flash_zone_end = pic_cm_size - (black_transfer + black_zone);
flash_zone = flash_zone_end - flash_zone_start + 1;

% Figure init
width = 500;
height = 400;
fig = figure('Name', 'Initializing... Please wait and don''t close the window', ...
    'PaperPositionMode', 'auto', 'Position', [100 100 width height], ...
    'Resize', 'off', 'Toolbar', 'none', 'Menubar', 'none', 'NumberTitle', 'off');
axes('Parent', fig, 'Position', [0 0 1 1]);

% Animation generation
speed = -13;
frames_number = 2 * std_cm_size / abs(speed);
fps = 10;
for f = 1:frames_number
    % Colormap
    cm_f = mod((f - 1)*speed, std_cm_size) + 1;
    pic_colormap(flash_zone_start:flash_zone_end, :) = ...
        std_colormap(cm_f:(cm_f+flash_zone-1), :);

    pic_colormap((green_zone+1):(flash_zone_start-1), 1) = ...
        interp1([green_zone flash_zone_start], ...
                [0 pic_colormap(flash_zone_start, 1)], ...
                (green_zone+1):(flash_zone_start-1));
    pic_colormap((green_zone+1):(flash_zone_start-1), 2) = ...
        interp1([green_zone flash_zone_start], ...
                [1 pic_colormap(flash_zone_start, 2)], ...
                (green_zone+1):(flash_zone_start-1));
    pic_colormap((green_zone+1):(flash_zone_start-1), 3) = ...
        interp1([green_zone flash_zone_start], ...
                [0 pic_colormap(flash_zone_start, 3)], ...
                (green_zone+1):(flash_zone_start-1));

    pic_colormap((flash_zone_end+1):(pic_cm_size-black_zone), 1) = ...
        interp1([flash_zone_end (pic_cm_size-black_zone+1)], ...
                [pic_colormap(flash_zone_end, 1) 0], ...
                (flash_zone_end+1):(pic_cm_size-black_zone));
    pic_colormap((flash_zone_end+1):(pic_cm_size-black_zone), 2) = ...
        interp1([flash_zone_end (pic_cm_size-black_zone+1)], ...
                [pic_colormap(flash_zone_end, 2) 0], ...
                (flash_zone_end+1):(pic_cm_size-black_zone));
    pic_colormap((flash_zone_end+1):(pic_cm_size-black_zone), 3) = ...
        interp1([flash_zone_end (pic_cm_size-black_zone+1)], ...
                [pic_colormap(flash_zone_end, 3) 0], ...
                (flash_zone_end+1):(pic_cm_size-black_zone));

    % Plotting
    colormap(pic_colormap);
    imagesc(picture);
    axis off;
    drawnow;
    frames(f) = getframe(gcf);
    img = frame2im(frames(f));
    A = rgb2ind(img, pic_colormap);
    
    if f == 1;
        imwrite(A, pic_colormap, '4-20.gif', 'gif', 'LoopCount', Inf, 'DelayTime', 1/fps);
    else
        imwrite(A, pic_colormap, '4-20.gif', 'gif', 'WriteMode', 'append', 'DelayTime', 1/fps);
    end;
end;
set(fig, 'Name', 'LEGALIZE 4:20');

%% Playing movie
repeat_times = 1000000;
movie(fig, frames, repeat_times, fps);
close all;
