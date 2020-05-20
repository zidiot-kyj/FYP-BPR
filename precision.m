function [prec,err]  = precision(recSet,testSet,u,varargin)
N=length(recSet);
if (~isempty(varargin{:}))
    thres = varargin{1}{1};
    groundTruth = testSet(testSet(:,2)>=thres,1);
    if (length(varargin{1})>1)
        N=varargin{1}{2};
    end
else
    groundTruth = testSet(:,1);
end


if (~isempty(testSet))
   err = 0;
   prec = length(intersect(recSet(1:N,1), groundTruth))/N;
else
    err = 1;
    prec = 0;
end
