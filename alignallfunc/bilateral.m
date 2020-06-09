function f = bilateral(x)
Ireference = x;
degreeOfSmoothing = var(double(Ireference(:)));
f = imbilatfilt(Ireference,degreeOfSmoothing);
% imshow(Ibilat)
% title('Denoised Image Obtained Using Bilateral Filtering');
end