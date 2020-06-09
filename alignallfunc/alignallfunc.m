%% 导入照片
clear
close all
height = 3456;
width = 5184;
numPics = 13;
file_name = 'coference hall';
zmin = 1;
zmax = 256;
imgCell = cell( numPics, 1 );
B = zeros(numPics,1);   %保存曝光时间
img = [ width, height, 3, 13];    %保存图片
%计算运行时间
t = cputime;

%图片命名
for i=1:numPics;
 s1 = 'img';
 s2 = [ int2str(i) ];
 if( i < 10 )
     s2 = [ '0' s2 ];
 end
 s3 = '.jpg';
 s = [ file_name s2 s3 ];
 imgCell{i} = imread(s);
 imgCell{i} = imresize(imgCell{i},0.3);
 info = imfinfo(s);          %提取图片信息
 B(i) = info.DigitalCamera.ExposureTime;
end

%% 图片对齐
iterator = 5;    %设置align迭代次数
for time = 1:2;       %两次loop，后面的图片轮流和第一张对照，两次后确保所有照片都做好对齐
    for i=2:numPics;
     [ imgCell{1} , imgCell{i} ] = imgalign(imgCell{1}, imgCell{i}, iterator );
    end
end
'finish alignment.'
timg_cost = cputime - t
t = cputime;

%% 计算每个像素点位置处的权重
%align后的每张图片大小
imgSize = size(imgCell{1}(:,:,1));
height = imgSize(1);
width = imgSize(2);

numPixels = 50;
for i=1:numPixels;
    x = randi(width);
    y = randi(height);
    for j=1:numPics;
        img = imgCell{j};
        Zr(i,j) = img(y,x,1);
        Zg(i,j) = img(y,x,2);
        Zb(i,j) = img(y,x,3);
    end
end
%对曝光时间取对数
B = log(B);
B(1)=log(13); B(2)=log(10); B(3)=log(4); B(4)=log(3.2); B(5)=log(1);
B(6)=log(0.8); B(7)=log(0.3); B(8)=log(1/4); B(9)=log(1/60); B(10)=log(1/80);
B(11)=log(1/320); B(12)=log(1/400); B(13)=log(1/1000);

[ 13, 10, 4, 3.2, 1, 0.8, 0.3, 1/4, 1/60, 1/80, 1/320, 1/400, 1/1000];

l = 1;
%设置简单化处理后的权重系数曲线
w = zeros(1,256);
w(1:128) = (1:128);
w(129:256)=(128:-1:1);
%计算得图片像素点的原本权重和本身亮度
[gr, lEr] = gsolve(Zr,B,l,w);
[gg, lEg] = gsolve(Zg,B,l,w);
[gb, lEb] = gsolve(Zb,B,l,w);

'G function get'
time_cost = cputime - t
t = cputime;

gcell = cell(3,1);
gcell{1} = gr;
gcell{2} = gg;
gcell{3} = gb;

%计算得到处理后的各点亮度/‘能量’
hdrImg = zeros(height,width,3);
for c = 1:3;
    for i = 1:height;
        for j = 1:width;
            wij = 0;
            lEg = 0;
            for k = 2:numPics;
                lE = gcell{c}(imgCell{k}(i,j,c)+1) - B(k);
                lEg = w(imgCell{k}(i,j,c)+1)*lE + lEg;
                wij = wij + w(imgCell{k}(i,j,c)+1);
            end
            lEg = lEg/wij;      %计算平均亮度
            hdrImg(i,j,c) = exp(lEg);
            hdrImg3(i,j,c) = lEg;
        end
    end
end

%% for histogram picture
% hdrImgG = hdrImg3(:,:,2);
% imshow(hdrImgG);
% figure,imshow(hdrImg3);
% colormap jet


'finish the hdr image'
time_cost = cputime - t

%% tone mappping by matlab   
maxPix = max(max(max(hdrImg(:,:,:))));
hdrImg2 = hdrImg/maxPix;

rgbImg = tonemap(hdrImg2);
% figure;
% imshow(rgbImg)

%% other's tonemapping
% 直接代数方法处理亮度分配
hdrImg3 = hdrImg(:,:,1)*0.299 + hdrImg(:,:,2)*0.587 + hdrImg(:,:,3)*0.114;
maxPix = max(max(hdrImg3));
minPix = min(min(hdrImg3));

%% Tone mapping 
t = cputime;
% 正则化
minP = min(min(hdrImg));
for c=1:3
    hdrImg(:,:,c) = hdrImg(:,:,c)/min(minP);
end

%% 调用自己写的tone mapping 函数处理
lightness = [ 0.06, 0.08, 0.1, 0.12,0.14];
for num = 1 : size(lightness,2);
    mapImg = zeros(height, width, 3);
    for c = 1:3;
        hdrI = hdrImg(:,:,c);
        mapImg(:,:,c) = toneMapping(hdrI,lightness(num));
    end
    max(max(mapImg));
    min(min(mapImg));
    mapImg = round(mapImg*256);
    mapImg = uint8(mapImg);
%     figure;
%     imshow(mapImg)
%   输出结果
    output_name = [ file_name num2str(lightness(num)) '_hdrImg.jpg' ];
    imwrite(mapImg, output_name);
end

'finish tone mapping'
time_cost = cputime - t

%% show non-linear curve   
figure
plot(gg);
title('gg');
figure
plot(gr);
title('gr');
figure
plot(gb);
title('gb');

%% 分别处理得到去雾、锐化、对比度增强、双边滤波后的图片
testlist = {};

testlist{1} = haze_reduce(mapImg);
testlist{2} = sharpen_pic(mapImg);
testlist{3} = Contrast_Enhance(mapImg);
testlist{4} = bilateral(mapImg);

%% 引入评价函数，比较四个处理后的优劣，输出最优处理后的图片
load modelparameters.mat
 NIQE_Index = zeros(4,1);
 for i = 1:4;
 blocksizerow    = 96;
 blocksizecol    = 96;
 blockrowoverlap = 0;
 blockcoloverlap = 0;

im =testlist{i};
% figure;
% imshow(im);
NIQE_Index(i,1) = computequality(im,blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap, ...
    mu_prisparam,cov_prisparam);
 end
 [optimize_one I] = max(NIQE_Index(:));
 figure,imshow(testlist{I(1)});

