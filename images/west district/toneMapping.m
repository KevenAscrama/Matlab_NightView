function [mapImg]=toneMapping(img, lightness)
   m = size(img);
   height = m(1);
   width = m(2); 
   imgA = exp(1)+img;    % ���exp(1)ʹ�ú��������������
   %�������ź�����
   N = height*width;
   Lw = 0;
   for i = 1:height;
       for j = 1:width;
           Lw = log( imgA(i,j) ) + Lw;
       end
   end
   Lw = Lw/N;    % ����ƽ������
   a = lightness;
   Lm = a*imgA/Lw;   % ���ź�����=����ϵ��*ԭ����/ƽ�����ȣ���Χ������0-1֮��
   Lwhite = max(max(Lm));    %�������
  
   for i = 1:height;
       for j = 1:width;
           Lm(i,j) = Lm(i,j)/(1+Lm(i,j));    %���������������ȣ�[0,1]
       end
   end
   %
   mapImg = Lm;
   
end

