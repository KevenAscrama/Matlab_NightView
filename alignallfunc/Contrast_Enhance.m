function f = Contrast_Enhance(x)
src = x;
%------imadjust--------------------------------
super_sce1 = imadjust(src,[.2 .3 0;.6 .7 1],[]);
%-------histeq---------------------------------
RGB_R = histeq(src(:,:,1));
RGB_G = histeq(src(:,:,2));
RGB_B = histeq(src(:,:,3));
super_sce2 = cat(3,RGB_R,RGB_G,RGB_B);
%------adapthisteq-----------------------------
Lab = rgb2lab(src);
L = Lab(:,:,1)./100;
L = adapthisteq(L,'NumTiles',[8,8],'ClipLimit',0.0001);
Lab(:,:,1) = L*100;
f = lab2rgb(Lab);
%----------------------------------------------
% figure,montage({src,super_sce1,super_sce2,super_sce3});
% figure,imshow(super_sce3);
end
