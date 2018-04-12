function [result] = deadPixelFix(IntensityGray,winsize,iteration)

[m,n] = size(IntensityGray);


    for i = 1:m
        for j = 1:n
            if (IntensityGray(i,j) == 0)
           
                IntensityGray(i,j) = 0;
                
            end
        end
    end


for a = 1: iteration
    for i = 1:m
        for j = 1:n
            if (IntensityGray(i,j) == 0 || IntensityGray(i,j) == 1)
                if (i>=1+winsize && i <= m-winsize && j >= 1+winsize && j <= m-winsize)
                    submatrix = IntensityGray(i-winsize:i+winsize,j-winsize:j+winsize);
                    meanval = mean2(submatrix);
                    meanval = meanval*(2*winsize+1)^2/((2*winsize+1)^2-1);
                    IntensityGray(i,j) = meanval;
                end
            end
        end
    end
end


result = IntensityGray;
