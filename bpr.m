function [P,Q,B] = bpr(Ytrain, k, alpha, lambdaP, lambdaQi,lambdaQj, chooseSam, MR, SIM, SIM_NOR)

M = size(Ytrain,2); % number of items
U = size(Ytrain,1); % number of users  

factorisationParams={...
    true,          ... % dorandinit
    10,            ... % numPasses
    1000000,       ... % numSamples
    true,         ... % uniformsampling
    0.02,          ... % lambdaB
    10000,         ... % numLossSamples
    true,          ... % byuser
    true           ... % resampling
    };

tic;
[i,j,v]=find(Ytrain);
R = [i,j,v];
%% STEP 1: create the quaduple of [u, i, j, rat_diff] from the
% original [u,i,rat] data.  Note that each pair should only
% appear once in P i.e. if [u,i,j, rat_diff] appears, we should
% NOT also include [u,j, i, -rat_diff]. If we do, the Rbar below
% would be identically zero always.  Also, the function skips
% all pairs where rat_diff=0.
fprintf('%f createPairwise...\n',toc);
P = createPairwiseTriples(R,true);

indx=find(P(:,1)~=0);
P= P(indx,:);   

    
%% STEP 2: Create Ruij in a form that makes computation easier
% Let's label all the pairs (i,j) by the number i+M*(j-1), so that
% the pairs are now uniquely identified by a number from 1 to M*M
% Now create a sparse matrix of size U x M*M to hold all the Ruij
% Although this has a very large number of cols, we can still handle it
% because of the sparse representation

% create a set of triples, with the new pair labelling

%fprintf('%f RR...\n',toc);
RR = [P(:,1),P(:,2)+M*(P(:,3)-1),P(:,4)];

% Now create the sparse U x M*M matrix of ruij
fprintf('%f Ruij...\n',toc);
Ruij = sparse(RR(:,1),RR(:,2),RR(:,3),U, M*M);
    
% run the matrix factorisation to compute the factors P and Q

fprintf('%f Factorisation...\n',toc);

[P,Q,B] = bprFactorisation(MR, SIM, SIM_NOR, Ruij, k, 'PQ.mat',alpha, lambdaP, lambdaQi,lambdaQj, chooseSam, factorisationParams{:});
end

