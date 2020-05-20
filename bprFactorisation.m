function [P,Q,B]=bprFactorisation(MR, SIM, SIM_NOR, R, k,modelFile,alpha, lambdaP, lambdaQi,lambdaQj,chooseSam, varargin)
if (nargin<2)
    k=20; % k is the number of categories
end

if (nargin<3)
    modelFile = 'PQ.mat';
end
% set default value of optional parameters
optargs={...
    true,          ... % dorandinit
    10,            ... % numPasses
    1000000,       ... % numSamples
    true,         ... % uniformsampling
    0.02,          ... % lambdaB
    10000,         ... % numLossSamples
    true,          ... % byuser
    true           ... % resampling
    };
% read values from parameters
[optargs{1:length(varargin)}] = varargin{:};
% extract the variable name for each of the parameters   
[dorandinit,numPasses,numSamples,uniformsampling,...
    lambdaB,numLossSamples,...
    byuser,resampling]=optargs{:};



%% Initialisation
nusers = size(R,1);
nitems = sqrt(size(R,2));

% Initialise P,Q and B to uniform random numbers between 0 and 1
if (dorandinit)
    P = rand(nusers,k);
    Q = rand(nitems,k);
    B = rand(nitems,1);
else
    load(modelFile);
end

% compute two arrays, row and col that hold the indices of the non-zero
% ratings in R
[row,col]=find(R);

% get row compressed representation - useful for sampling
[u,adj]=find(R);
[~,indx]=sort(u);
adj = adj(indx);
deg = sum(R~=0,2);
xadj = cumsum([1;deg]);


%% Training Phase --
tic;

% samples for training

if(chooseSam==1)
    [users,items1,items2] = Sampler(numSamples,R,row,col,xadj,adj,deg,...
            byuser,uniformsampling);
elseif(chooseSam==2)
    [users,items1,items2] = Sampler_MBP(numSamples,R,row,col,xadj,adj,deg,...
            byuser,uniformsampling);
elseif(chooseSam==3)
    [users,items1,items2] = Sampler_MIP(numSamples,R,row,col,xadj,adj,deg,...
            byuser,uniformsampling);
elseif(chooseSam==4)
    [users,items1,items2] = Sampler_LP(numSamples,R,row,col,xadj,adj,deg,...
            byuser,uniformsampling);
elseif(chooseSam==5)
    [users,items1,items2] = Sampler_MS(numSamples,nitems,nusers,row,col,xadj,adj,deg,...
            byuser,uniformsampling, MR, SIM);
elseif(chooseSam==6)
    [users,items1,items2] = Sampler_LS(numSamples,nitems,nusers,row,col,xadj,adj,deg,...
            byuser,uniformsampling, MR, SIM);
else
    [users,items1,items2] = Sampler_Combination(numSamples,nitems,nusers,row,col,xadj,adj,deg,...
            byuser,uniformsampling, MR, SIM_NOR);
end


for pass=1:numPasses,
    pass
    err = 0;
    
    obj = 0.0;
    for sample=1:numSamples
        
        user = users(sample);
        i=items1(sample);
        j=items2(sample);
        
        rhat_uij = B(i) - B(j) + P(user,:)*(Q(i,:)-Q(j,:))';
        
        z = 1.0/(1.0+exp(rhat_uij));
        
        oold = rhat_uij+log(z);
        
        B(i) = B(i) + alpha*(z - lambdaB*B(i));
        B(j) = B(j) + alpha*(-z - lambdaB*B(j));
        P(user,:) = P(user,:)+alpha*(z...
            *(Q(i,:) - Q(j,:))-lambdaP*P(user,:));
        
        Q(i,:) = Q(i,:) + alpha*(z*P(user,:)-lambdaQi*Q(i,:));
        Q(j,:) = Q(j,:) + alpha*(-z*P(user,:)-lambdaQj*Q(j,:));
        
        rhat_uij = B(i) - B(j) + P(user,:)*(Q(i,:)-Q(j,:))';
        
        z = 1.0/(1.0+exp(rhat_uij));
        onew = rhat_uij+log(z);
        
        obj = obj + onew;
        
        err= err + (onew-oold)^2;
        
    end
    
    save(modelFile, 'P','Q','B','-mat','-v7.3');
    
    if (resampling && pass<numPasses)
        if(chooseSam==1)
            [users,items1,items2] = Sampler(numSamples,R,row,col,xadj,adj,deg,...
                    byuser,uniformsampling);
        elseif(chooseSam==2)
            [users,items1,items2] = Sampler_MBP(numSamples,R,row,col,xadj,adj,deg,...
                    byuser,uniformsampling);
        elseif(chooseSam==3)
            [users,items1,items2] = Sampler_MIP(numSamples,R,row,col,xadj,adj,deg,...
                    byuser,uniformsampling);
        elseif(chooseSam==4)
            [users,items1,items2] = Sampler_LP(numSamples,R,row,col,xadj,adj,deg,...
                    byuser,uniformsampling);
        elseif(chooseSam==5)
            [users,items1,items2] = Sampler_MS(numSamples,nitems,nusers,row,col,xadj,adj,deg,...
                    byuser,uniformsampling, MR, SIM);
        elseif(chooseSam==6)
            [users,items1,items2] = Sampler_LS(numSamples,nitems,nusers,row,col,xadj,adj,deg,...
                    byuser,uniformsampling, MR, SIM);
        else
            [users,items1,items2] = Sampler_Combination(numSamples,nitems,nusers,row,col,xadj,adj,deg,...
                    byuser,uniformsampling, MR, SIM);
        end
    end
    
end
end

%% random-basic-sampling
function [users,items1,items2]=Sampler(numSamples,R,row,col,xadj,adj,deg,...
    byuser,uniformsampling)

nusers = size(R,1);
nitems = sqrt(size(R,2));

if (~byuser)
    %  pick a (user,itempair) uniformly at random
    pos = ceil(rand(numSamples,1)*length(row));
    users = row(pos);
    itempairs = col(pos);
    
else
    % pick a user uniformly at random
    users = ceil(rand(numSamples,1)*nusers);
    % pick one of the users item-pairs uniformly at random.
    itempairs = adj(xadj(users)+ceil(rand(numSamples,1).*deg(users))-1);
    
end

% pull the items out of the item-pairs
items1 = mod(itempairs-1,nitems)+1;
items2 = floor((itempairs-1)/nitems)+1;

if (uniformsampling)
    % choose a negative item uniformly at random,that hasn't been
    % rated by the user
    j = ceil(rand(numSamples,1)*nitems);
    jpair = items1+nitems*(j-1);
    
    % re-select if already rated
    indx = find(R((jpair-1)*nusers+users)~=0);
     
    while (~isempty(indx))
        jFix = ceil(rand(length(indx),1)*nitems);
        j(indx) = jFix;
        jpair(indx) = items1(indx) + nitems*(j(indx)-1);
        
        indx = indx(R((jpair(indx)-1)*nusers+users(indx))~=0);
    end
    items2 = j; 
end

fprintf('%f\tSamples generated\n',toc);

end






