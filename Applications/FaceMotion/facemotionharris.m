prevlistX = zeros(100,1);
prevlistY = zeros(100,1);

initialized = 0;

for i=1:5
    img = imread(strcat(strcat('Images/FaceMotion/',int2str(i)),'.gif'));
    previmg = img;
    if i >= 2
        previmg = imread(strcat(strcat('Images/FaceMotion/',int2str(i-1)),'.gif'));
    end
    %Coefficients -> Variables
    HarrisCoeff = 0.04;
    thresh = 10000000000;

    %Convert given image to gray scale with a single value for each pixel
    pixlen = size(img,3);
    for i=1:pixlen
        for j=1:pixlen
            if i ~= j
                img(:,:,i) = img(:,:,i) + img(:,:,j);
                previmg(:,:,i) = previmg(:,:,i) + previmg(:,:,j);
            end
        end
        img(:,:,i) = img(:,:,i) / pixlen;
        previmg(:,:,i) = previmg(:,:,i) / pixlen;
    end
    img = img(:,:,1);
    previmg = previmg(:,:,1);

    %Display original image
    figure();
    %imshow(img);

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

    curlistX = zeros(100,1);
    curlistY = zeros(100,1);
    curIdxx = 1;
    
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
                if i > 5 && i < size(img,1) - 5 && j > 5 && j < size(img,2) - 5
                    curlistX(curIdxx) = i;
                    curlistY(curIdxx) = j;
                    curIdxx = curIdxx + 1;
                end
                %disp(cornerness(i,j));
            end
        end
    end

    %Display corners found
    figure();
    %imshow(corners);
    
    if initialized == 0
        initialized = 1;
        
    else
        newX = 0;
        newY = 0;
        for kk=1:100
            best_match = 0;
            best_cor = 0;
            if curlistX(kk) ~= 0 && curlistY(kk) ~= 0
                for ck=1:100
                    if prevlistX(ck) ~= 0 && prevlistY(ck) ~= 0
                        correlation = corr2(img(curlistX(kk)-5:curlistX(kk)+5,curlistY(kk)-5:curlistY(kk)+5),previmg(prevlistX(ck)-5:prevlistX(ck)+5,prevlistY(ck)-5:prevlistY(ck)+5));
                        if best_cor < correlation
                            best_cor = correlation;
                            best_match = ck;
                        end
                    end
                end
            end
            if best_match ~= 0
                newX = newX + (curlistX(kk) - prevlistX(best_match)) / 100.0;
                newY = newY + (curlistY(kk) - prevlistY(best_match)) / 100.0;
            end
        end
        disp('Position change delta');
        disp(newX);
        disp(newY);
        disp('End, move to next time step');
    end
    prevlistX = curlistX;
    prevlistY = curlistY;
end