function [rh,err]  = rankhit(recSet,testSet,u,varargin)

threshold = min(testSet(:,2));
if (~isempty(varargin{1}))
    N = varargin{1}{1};
    if (N>length(recSet))
        fprintf('Cannot use N=%d in rankHit\n',N);
        fprintf('Instead using max N of %d\n',length(recSet));
        N = length(recSet);
    end        
    
    if (length(varargin{1})>1)
        threshold=varargin{1}{2};
    end
else
    N = length(recSet);
end
testSet = testSet(testSet(:,2)>=threshold,:);
if (isempty(testSet))
    err=1;
    rh=0;
    return;
end

R = recSet(1:N,:);

irank(R(:,1))=(1:N)';

A = createPairwiseGraphs([ones(size(R,1),1),R(:,1), R(:,2)]);

B = createPairwiseGraphs([ones(size(testSet,1),1),testSet(:,1), testSet(:,2)]);
A = A{1}; B = B{1};

maxItems = max(max(size(A)),max(size(B)));

[i,j,v]=find(A); A = sparse(i,j,v,maxItems,maxItems);
[i,j,v]=find(B); B = sparse(i,j,v,maxItems,maxItems);

B = 1.0*sign(B); A = 1.0*sign(A); 
G = sparse(1:N,1:N,irank*10000)*double(A~=0)+ double(A~=0)*sparse(1:N,1:N,irank);

C= 1.0*(A.*B)>0;
G = sparse(G.*C);

fp = fopen('tt.txt','a');
[i,j]=find(C);
[i,j,v]=find(G);
fprintf(fp,'%d\t%d\t%d\t%d\n',[i,j,floor(v/10000),mod(v,10000)]');
fclose(fp);

if (nnz(B)>0)
    err = 0;
    rh = sum(sum(C))/ nnz(B);
else
    err = 1;
    rh = 0;
end