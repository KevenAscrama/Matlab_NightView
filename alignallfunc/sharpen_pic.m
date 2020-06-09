function f = sharpen_pic(x)
src = x;
SrcYcbcr = rgb2ycbcr(src);
SrcY = SrcYcbcr(:,:,1);
size = 3;
sigma = 1;
amount = 1.5;
threshold = 15;
gaussFilter = fspecial('gaussian',[size,size],sigma);
SrcY_lf = imfilter(SrcY,gaussFilter,'symmetric');

SrcY_hf = SrcY - SrcY_lf;
imLabel = (SrcY_hf>threshold);
imLabel = uint8(imLabel);
imDstY = uint8(SrcY+amount*SrcY_hf.*imLabel);
% figure,imshow([SrcY,SrcY_lf,SrcY_hf,imDstY]);
SrcYcbcr(:,:,1) = imDstY;
f = ycbcr2rgb(uint8(SrcYcbcr));
% figure,montage({src,imDst});
% figure,imshow(imDst);
end
