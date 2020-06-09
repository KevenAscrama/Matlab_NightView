function f = haze_reduce(x)
A = x;
%figure;
%imshow(A);
AInv = imcomplement(A);
% BInv = imreducehaze(AInv);
% B = imcomplement(BInv);
% % figure;
% imshow(B);
BInv_2 = imreducehaze(AInv,'Method','approx','ContrastEnhancement','boost');
BImp = imcomplement(BInv_2);
% figure,imshow(BImp)

%----Convert the input image from the RGB colorspace to the L*a*b* colorspace-------

% Lab = rgb2lab(A);
% LInv = imcomplement(Lab(:,:,1)./100);
% LEnh = imcomplement(imreducehaze(LInv,'ContrastEnhancement','none'));
% LabEnh(:,:,1) = LEnh.*100;
% LabEnh(:,:,2:3) = Lab(:,:,2:3) * 2;
% AEnh = lab2rgb(LabEnh);

%--------improve results using Denoising----------------

% Denosing_pic = imguidedfilter(B);
f = imguidedfilter(BImp); 
% figure,imshow(Denosing_pic2);

%--------estimate illumination map-------------------

% [BInv,TInv] = imreducehaze(AInv,'Method','approx','ContrastEnhancement','none');
% T = imcomplement(TInv);
% figure,subplot(1,2,1);
% imshow(A);
% subplot(1,2,2);
% imshow(T);
% colormap(gca,hot(256));





