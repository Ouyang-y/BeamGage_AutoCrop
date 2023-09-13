%{ V2
.修复超出边界的图无法截取
.加入完成提示框
%}
% 质心截图
%   ①去边(截图)
%   ②将原彩图转为灰度图
%   ③取灰度图质心
%   ④取原图周围的子图并输出到文件
% 需要改动的变量：outputsize
% 输出结果在.\output文件夹中
%
clear

outputsize = [350,350];  % [height,weight]

path = uigetdir([],'请选择图片所在文件夹');
outputpath = [path,filesep,'output'];
load("OSI_rainbow.mat")

if ~isfolder(outputpath),mkdir(outputpath);end
img_path_s = dir([path,filesep,'*.tiff']);
img_path_T = struct2table(img_path_s);
img_path = cell(length(img_path_s),1);

temp = length(path);
for t = 1:length(img_path_s)
    if length(img_path_T.folder{t}) == temp
        img_path(t) = {[filesep,img_path_T.name{t}]};
    else
        img_path(t) = {[filesep,img_path_T.folder{t}(length(path)+1:end),filesep,img_path_T.name{t}]};
    end
end

% select crop range
img = imread([path,img_path{1}]);img = img(:,:,1:3);
fig = figure;
imshow(img);title('使用鼠标框选截图范围');
rect = round(getrect(fig));
imshow(imcrop(img,rect));
outputsize = round(outputsize/2)*2;
for tt = 1:length(img_path_s)
    % read image & transform to ind
    img = imread([path,img_path{tt}]);img = img(:,:,1:3);
    img = imcrop(img,rect);
    imgI = rgb2ind(img,OSI_rainbow)*2;
    [H,W] = size(imgI);
    % find centroid
    [~,x] = max(sum(imgI));
    [~,y] = max(sum(imgI,2));
    % get sub image
    cutsize = [y-outputsize(1)/2,y+outputsize(1)/2,x-outputsize(2)/2,x+outputsize(2)/2];
    if cutsize(1)<1
        cutsize(1:2) = [1,outputsize(1)+1];
        if cutsize(2)>H,cutsize(2) = H;end
    end
    if cutsize(2)>H,cutsize(2) = [H-outputsize(1),H];end
    if cutsize(3)<1
        cutsize(3:4) = [1,outputsize(2)+1];
        if cutsize(4)>W,cutsize(4) = W;end
    end
    if cutsize(4)>W,cutsize(4) = [W-outputsize(4),W];end
    subimg = img(cutsize(1):cutsize(2),cutsize(3):cutsize(4),:);
    % print log on screen
    fprintf('%d/%d：%s\n',tt,t,img_path{tt});
    % output
    imwrite(subimg,OSI_rainbow,[outputpath,img_path{tt}],"tiff","WriteMode","overwrite");

    % debug
%     imgIT = imgI;
%     imgIT(:,x) = 255;
%     imgIT(y,:) = 255;
%     imshow(imgI)
end
close(fig)
questdlg('Done!','Finished','OK','','');