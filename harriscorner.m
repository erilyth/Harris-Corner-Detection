img = imread('Images/image1.png');

%Coefficients -> Variables
HarrisCoeff = 0.04;
thresh = 0;

%Convert given image to gray scale with a single value for each pixel
pixlen = size(img,3);
for i=1:pixlen
    for j=1:pixlen
        if i ~= j
            img(:,:,i) = img(:,:,i) + img(:,:,j);
        end
    end
    img(:,:,i) = img(:,:,i) / pixlen;
end
img = img(:,:,1);

%Display original image
figure();
imshow(img);

corners = zeros(size(img,1), size(img,2));

imgDerivativeX = abs(conv2(img, [-1 0 1; -2 0 2; -1 0 1]));
imgDerivativeY = abs(conv2(img, [-1 -2 -1; 0 0 0; 1 2 1]));

imgDerivativeX = imcrop(imgDerivativeX, [2 2 size(imgDerivativeX,2)-3 size(imgDerivativeX,1)-3]);
imgDerivativeY = imcrop(imgDerivativeY, [2 2 size(imgDerivativeY,2)-3 size(imgDerivativeY,1)-3]);

IxIx = imgDerivativeX .*  imgDerivativeX;
IyIy = imgDerivativeY .*  imgDerivativeY;
IxIy = imgDerivativeX .*  imgDerivativeY;

neighbourMat = [1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1];
IxIx = conv2(IxIx, neighbourMat);
IxIy = conv2(IxIy, neighbourMat);
IyIy = conv2(IyIy, neighbourMat);

IxIx = imcrop(IxIx, [3 3 size(IxIx,2)-5 size(IxIx,1)-5]);
IxIy = imcrop(IxIy, [3 3 size(IxIy,2)-5 size(IxIy,1)-5]);
IyIy = imcrop(IyIy, [3 3 size(IyIy,2)-5 size(IyIy,1)-5]);

cornerness = zeros(size(img,1), size(img,2));
for i=1:size(img,1)
    for j=1:size(img,2)
        matrixM = [IxIx(i,j) IxIy(i,j); IxIy(i,j) IyIy(i,j)];
        %value1 and value2 are the eigen values, 
        %det(matrixM) = value1 * value2 and 
        %trace(matrixM) = value1 + value2
        %cornerness(i,j) = value1 * value2 - HarrisCoeff * (value1 + value2) * (value1 + value2);
        cornerness(i,j) = det(matrixM) - HarrisCoeff * (trace(matrixM) ^ 2);
        if cornerness(i,j) > thresh
            corners(i,j) = 255;
            disp(cornerness(i,j));
        end
    end
end

%Display corners found
figure();
imshow(corners);