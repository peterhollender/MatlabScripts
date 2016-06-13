function set_gif_fps(gif_filename,fps,loop_count)
if ~exist('loop_count','var')
    loop_count = inf;
end
[imdata map] = imread(gif_filename);
imwrite(imdata,map,gif_filename,'DelayTime',1/fps,'LoopCount',loop_count);