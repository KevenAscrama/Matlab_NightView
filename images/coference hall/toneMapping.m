function [mapImg]=toneMapping(img, lightness)
   m = size(img);
   height = m(1);
   width = m(2); 
   imgA = exp(1)+img;    % 添加exp(1)使得后面对数计算正常
   %计算缩放后亮度
   N = height*width;
   Lw = 0;
   for i = 1:height;
       for j = 1:width;
           Lw = log( imgA(i,j) ) + Lw;
       end
   end
   Lw = Lw/N;    % 计算平均亮度
   a = lightness;
   Lm = a*imgA/Lw;   % 缩放后亮度=亮度系数*原亮度/平均亮度，范围并不在0-1之间
   Lwhite = max(max(Lm));    %最大亮度
  
   for i = 1:height;
       for j = 1:width;
           Lm(i,j) = Lm(i,j)/(1+Lm(i,j));    %计算像素最终亮度，[0,1]
       end
   end
   %
   mapImg = Lm;
   
end

